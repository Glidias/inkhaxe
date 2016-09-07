package ink.runtime;
import haxe.ds.StringMap;

/**
 * Likely going to depreciate this since got own haxe json  library
 * Done!
 * @author Glidias
 */
class SimpleJson
{
	
	 public static function DictionaryToText( rootObject:StringMap<Dynamic> ):String   //Dictionary<string, object>
	{
		return new Writer(rootObject).toString();
	}
	public static function TextToDictionary ( text:String):StringMap<Dynamic>
	{
		return new Reader (text).ToDictionary ();
	}
	


}

class Reader
{
	public function new(text:String)
	{
		_text = text;
		_offset = 0;

		SkipWhitespace ();

		_rootObject = ReadObject();
	}
	
	public function ToDictionary ():StringMap<Dynamic>  //Dictionary<string, object> 
	{
		return cast _rootObject;  //(Dictionary<string, object>)
	}
	
	
	function IsNumberChar( c:String):Bool //char
	{
		// hopefully this translation below would work across all platforms
		//return c >= '0' && c <= '9' || c == '.' || c == '-' || c == '+';
		return Std.parseInt(c) >= 0 && Std.parseInt(c) <= 9 || c == '.' || c == '-' || c == '+';
	}

	function  ReadObject ():Dynamic
	{
		var currentChar = _text.charAt(_offset); // [_offset];

		if( currentChar == '{' )
			return ReadDictionary ();
		
		else if (currentChar == '[')
			return ReadArray ();

		else if (currentChar == '"')
			return ReadString ();

		else if (IsNumberChar(currentChar))
			return ReadNumber ();

		else if (TryRead ("true"))
			return true;

		else if (TryRead ("false"))
			return false;

		else if (TryRead ("null"))
			return null;
		

		throw new SystemException ("Unhandled object type in JSON: "+_text.substring(_offset, 30));
	}
	
	
	function ReadDictionary():Map<String, Dynamic> //Dictionary<string, object>
	{
		var dict = new Map<String, Dynamic>();

		Expect ("{");

		SkipWhitespace ();

		// Empty dictionary?
		if (TryRead ("}"))
			return dict;

		do {

			SkipWhitespace ();

			// Key
			var key = ReadString ();
			Expect2(key != null, "dictionary key");

			SkipWhitespace ();

			// :
			Expect (":");

			SkipWhitespace ();

			// Value
			var val = ReadObject ();
			Expect2 (val != null, "dictionary value");

			// Add to dictionary
			dict.set(key, val); // [key] = val;

			SkipWhitespace ();

		} while ( TryRead (",") );

		Expect ("}");

		return dict;
	}

	function ReadArray ():List<Dynamic>
		{
			var list = new List<Dynamic> ();

			Expect ("[");

			SkipWhitespace ();

			// Empty list?
			if (TryRead ("]"))
				return list;

			do {

				SkipWhitespace ();

				// Value
				var val = ReadObject ();

				// Add to array
				list.add (val);

				SkipWhitespace ();

			} while (TryRead (","));

			Expect ("]");

			return list;
		}

			
	function ReadString ():String
		{
			Expect ("\"");

			var startOffset = _offset;

			while( _offset < _text.length) { //for (; _offset < _text.Length; _offset++) {
				var c = _text.charAt(_offset);// [_offset];

				// Escaping. Escaped character will be skipped over in next loop.
				if (c == '\\') {
					_offset++;
				} else if( c == '"' ) {
					break;
				}
				
				_offset++;  // loop end statement
			}

			Expect ("\"");

			var str = _text.substring(startOffset, _offset - startOffset - 1);
			str = StringTools.replace(str, "\\\\", "\\");
			str = StringTools.replace (str,"\\\"", "\"");
			str = StringTools.replace (str,"\\r", "");
			str = StringTools.replace (str,"\\n", "\n");
			return str;
		}

		
	function ReadNumber ():Dynamic
		{
			var startOffset:Int = _offset;

			var isFloat = false;
			while (_offset < _text.length) {  //; _offset < _text.Length; _offset++
				var c = _text.charAt(_offset);// [_offset];
				if (c == '.') isFloat = true;
				if (IsNumberChar (c)) {
					_offset++;  // continuing...
					continue;
				}
				else
					break;
				_offset++; // continuing...
			}

			var numStr:String = _text.substring (startOffset, _offset - startOffset);

			if (isFloat) {
				var f:Float;
				f = Std.parseFloat(numStr);
				if (!Math.isNaN(f)) {  //float.TryParse (numStr, out f)
					return f;
				}
			} else {
				var i:Int;
				i =  Std.parseInt(numStr);
				if (i != null && !Math.isNaN(i) ) {  //int.TryParse (numStr, out i)
					return i;
				}
			}

			throw new SystemException ("Failed to parse number value");
		}


	function TryRead (textToRead:String):Bool
		{
			if (_offset + textToRead.length > _text.length)
				return false;
			
			for (i in 0...textToRead.length) {  //int i = 0; i < textToRead.Length; i++
				if (textToRead.charAt(i) != _text.charAt(_offset + i))
					return false;
			}

			_offset += textToRead.length;

			return true;
		}

	function Expect ( expectedStr:String):Void
		{
			if (!TryRead (expectedStr))
				Expect2 (false, expectedStr);
		}

	function Expect2( condition:Bool,  message:String = null)
		{
		if (!condition) {
			if (message == null) {
				message = "Unexpected token";
			} else {
				message = "Expected " + message;
			}
			message += " at offset " + _offset;

			throw new SystemException (message);
		}
	}
	
	
	function SkipWhitespace ():Void
	{
		var len:Int = _text.length;
		while (_offset < len) {
			var c = _text.charAt(_offset);
			if (c == ' ' || c == '\t' || c == '\n' || c == '\r')
				_offset++;
			else
				break;
		}
	}

		
	
	var _text:String;
	var _offset:Int;

    var _rootObject:Dynamic;
}

class Writer   // done
{
	public function new(rootObject: Dynamic )
	{
		_sb = new StringBuf ();

		WriteObject (rootObject);
	}


	function WriteObject ( obj:Dynamic):Void
	{
		if (Std.is(obj, Int)) {
			_sb.add(Std.int(obj)); //
		} else if (Std.is(obj,Float)) {
			var floatStr = Std.string(obj); // .ToString ();
			_sb.add (floatStr);
			if (!(floatStr.indexOf(".")>=0)) _sb.add (".0");
		} else if( Std.is(obj, Bool)) {
			_sb.add ( obj == true ? "true" : "false"); //(bool)
		} else if (obj == null) {
			_sb.add ("null");
		} else if (Std.is(obj, String)) {
			var str:String =  Std.string(obj);

			// Escape backslashes, quotes and newlines
			str = StringTools.replace(str, "\\", "\\\\"); // str.Replace ("\\", "\\\\");
			str = StringTools.replace(str, "\"", "\\\""); // str.Replace ("\"", "\\\"");
			str = StringTools.replace(str, "\n", "\\n"); // str.Replace ("\n", "\\n");
			str = StringTools.replace(str, "\r", ""); //str.Replace ("\r", "");

			_sb.add("\""+str+"\"");  //"\"{0}\""
		} else if (Std.is(obj, StringMap )) {  //is Dictionary<string, object>  // will checking for is DYnamic yield problems
			WriteDictionary(obj);  //Dictionary<string, object>)
		} else if (Std.is(obj, List) ) {
			WriteList(obj);  //(List<object>)
		}else {
			throw new SystemException ("ink's SimpleJson writer doesn't currently support this object: " + obj);
		}
	}



	function WriteDictionary (dict:StringMap<Dynamic>):Void //Dictionary<string, object> 
	{  
		_sb.add("{");

		var isFirst = true;
		for  (k in dict.keys()) {

			if (!isFirst) _sb.add (",");

			_sb.add ("\"");
			_sb.add (k);
			_sb.add ("\":");

			WriteObject(dict.get(k));  //keyValue.Value

			isFirst = false;
		}

		_sb.add ("}");
	}

	function WriteList(list:List<Dynamic>):Void
	{
		_sb.add ("[");

		var isFirst:Bool = true;
		for (obj in list) {
			if (!isFirst) _sb.add(",");

			WriteObject (obj);

			isFirst = false;
		}

		_sb.add ("]");
	}

	public  function toString():String
	{
		return _sb.toString();
	}


	var _sb:StringBuf;
	
}