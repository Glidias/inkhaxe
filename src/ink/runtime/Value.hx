package ink.runtime;
import ink.runtime.Value.IntValue;

/**
 * Done!
 * @author Glidias
 */

@:enum
abstract ValueType(Int)
{
	// Used in coersion
	var IntType = 0;
	var FloatType = 1;
	var StringType = 2;

	// Not used for coersion described above
	var DivertTarget = 3;
	var VariablePointer = 4;
}
/*
class ValueType
{
	public static inline var IntType = 0;
	public static inline var FloatType = 1;
	public static inline var StringType = 2;

	// Not used for coersion described above
	public static inline var DivertTarget = 3;
	public static inline var VariablePointer = 4;
}
*/



class Value<T> extends RObject
{
	public var value:T;
	
	public  var valueType(get, null):ValueType;// { get; }
	public  var isTruthy(get, null):Bool; //{ get; }

	public function Cast<T>(newType:ValueType):Value<T> { 
		return null;
	}

	public var valueObject(get, null):Dynamic; // { get; }
	

	
	public static function Create<T>(val:Dynamic):Value<T>
	{
		// Implicitly lose precision from any doubles we get passed in
		/*
		if (Std.is(val, Float)) {
			var doub:Float = cast val;  //double doub = (double)val;
			val = doub;  //  val = (float)doub;
		}
		*/

		// Implicitly convert bools into ints
		if (Std.is(val,Bool)) {
			var b:Bool = cast val;
			val = Std.int(b ? 1 : 0);
		}
		
		// return converted instance
		if ( Std.is(val, Int)) {
			//if (val == "\n") throw "newline character treated as integer engine problem uncaught!!";
			return  cast new IntValue( val );
		}
		else if (Std.is(val,Float)) {
			return cast new FloatValue( val);
		} else if (Std.is(val, String) ) {
			return cast new StringValue ( val);
		} else if (Std.is(val, Path)) {
			return cast new DivertTargetValue( val);
		}

		return null;
	}
	

	public override function Copy():RObject
	{
		return Create(valueObject);
	}

		
	public function new(val:T) {
		super();
		value = val;

	}
  
  	public function ToString():String
	{
		return Std.string(value);
	}
	
	public function toString():String {
		return ToString();
	}

  
  // absract boilerplate
  function get_valueType():ValueType 
  {
	  return valueType;
  }
  
  function get_isTruthy():Bool 
  {
	  return isTruthy;
  }
  
  function get_valueObject():Dynamic 
  {
	  return value;
  }
  
  
}


class IntValue extends Value<Int> {
	
	public override function get_valueType():ValueType  { return ValueType.IntType; }
    public override function get_isTruthy():Bool { return value != 0; }

		
	public function new(val:Int=0) {
		super(val);
	}
	
	public override function Cast<T>( newType:ValueType):Value<T>
	{
		if (newType == valueType) {
			return cast this;
		}

		if (newType == ValueType.IntType) {
			return cast new IntValue (this.value);
		}

		if (newType == ValueType.StringType) {
			return cast new StringValue("" + this.value);
		}

		throw new SystemException ("Unexpected type cast of Value to new ValueType");
	}
	

	
}

class FloatValue extends Value<Float> {
	public function new(val:Float) {
		super(val);
	}

	
	public override function Cast<T>( newType:ValueType):Value<T>
	{
		if (newType == valueType) {
			return cast this;
		}

		if (newType == ValueType.FloatType) {
			return cast new FloatValue (this.value);
		}

		if (newType == ValueType.StringType) {
			return cast new StringValue("" + this.value);
		}

		throw new SystemException ("Unexpected type cast of Value to new ValueType");
	}
	
	
}


class StringValue extends Value<String> {  // DONE!
	
	//     public StringValue() : this("") {}
	  // public StringValue(string str) : base(str)
       // {
          
       // }
	   public function new(val:String="") {
		super(val);
		
		  // Classify whitespace status
		isNewline = value == "\n";
		isInlineWhitespace = true;

		for (i in 0...value.length) {
			var c = value.charAt(i);
			if (c != ' ' && c != '\t') {
				isInlineWhitespace = false;
				break;
			}
		}

	}
	
	override function get_valueType():ValueType 
	  {
		  return ValueType.StringType;
	  }
	    override function get_isTruthy():Bool 
	  {
		  
		  return  value.length > 0;
	  }


        public var isNewline:Bool;   // { get; private set; }
        public var isInlineWhitespace:Bool; //{ get; private set; }
        public var isNonWhitespace(get, null):Bool;
		 function get_isNonWhitespace():Bool 
		{
			return !isNewline && !isInlineWhitespace;
		}

        public override function Cast<T>(newType:ValueType):Value<T>
        {
            var tryVal:Dynamic;
			if (newType == valueType) {
                return cast this;
            }

            if (newType == IntType) {

                //var parsedInt:Int;
				tryVal = LibUtil.tryParseInt(value);
                if (tryVal!=null) {
                    return cast new IntValue( tryVal);
                } else {
                    return null;
                }
            }

            if (newType == FloatType) {
                //var parsedFloat:Float;
				tryVal = LibUtil.tryParseFloat(value);
				
                if (tryVal!=null) {
                    return cast new FloatValue( tryVal);
                } else {
                    return null;
                }
            }

            throw new SystemException ("Unexpected type cast of Value to new ValueType");
        }
		
		
}

class DivertTargetValue extends Value<Path> {  // DONE!
	public function new(val:Path=null) {
		super(val);
	}
	
	public var targetPath(get, set):Path;   // { get { return this.value; } set { this.value = value; } }
    function get_targetPath():Path 
	{
		return this.value;
	}
	
	function set_targetPath(value:Path):Path 
	{
		return (this.value = value);
	}
	
	public override function get_valueType():ValueType  { return ValueType.DivertTarget; }

	 override function get_isTruthy():Bool {  throw new SystemException("Shouldn't be checking the truthiness of a divert target"); return false; }
	
	
	
	public override function Cast<T>( newType:ValueType):Value<T>
	{
		if (newType == valueType)
			return cast this;
		
		throw new SystemException ("Unexpected type cast of Value to new ValueType");
	}

	public override function ToString():String
	{
		return "DivertTargetValue(" + targetPath + ")";
	}
		
}

 // TODO: Think: Erm, I get that this contains a string, but should
 // we really derive from Value<string>? That seems a bit misleading to me.
class VariablePointerValue extends Value<String> {  // DONE!

	
	public var variableName(get, set):String;
	function get_variableName():String 
	{
		 return this.value;
	}
	
	function set_variableName(value:String):String 
	{
		return ( this.value = value);
	}
    public override  function get_valueType():ValueType {  return ValueType.VariablePointer;  }
    public override  function get_isTruthy() {   throw new SystemException("Shouldn't be checking the truthiness of a variable pointer");  return false;  }
	
	public var contextIndex:Int;

	// is this conversion correct?
	/*
	public VariablePointerValue(string variableName, int contextIndex = -1) : base(variableName)
        {
            this.contextIndex = contextIndex;
        }

        public VariablePointerValue() : this(null)
        {
        }
	*/
		public function new(variableName:String, contextIndex:Int=-1) {
		super(variableName);
		this.contextIndex = contextIndex;
	}
	
	
	  public override function Cast<T>( newType:ValueType):Value<T>
        {
            if (newType == valueType)
                return cast this;

            throw new SystemException("Unexpected type cast of Value to new ValueType");
        }

		
	public override function ToString():String
	{
		return "VariablePointerValue(" + variableName + ")";
	}
	
	public override function Copy():RObject
	{
		return new VariablePointerValue (variableName, contextIndex);
	}
	
	

}