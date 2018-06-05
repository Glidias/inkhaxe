package ink.runtime;
import haxe.ds.GenericStack;
import ink.runtime.Path;


/**
 * Done!
 * @author Glidias
 */
class Path extends RObject implements IEquatable//<Path>
{
	public static var parentId:String = "^";  // should this be inlined as  constant?

	

	

	
	public function PathByAppendingPath(pathToAppend:Path):Path
	{
		var p:Path = new Path ();

		var upwardMoves:Int = 0;
		for (i in 0...pathToAppend.components.length ) {  //int i = 0; i < pathToAppend.components.Count; ++i
			if (pathToAppend.components[i].isParent) {
				upwardMoves++;
			} else {
				break;
			}
		}

		for (i in 0...this.components.length - upwardMoves) {  //int i = 0; i < this.components.Count - upwardMoves; ++i
			p.components.push(this.components[i]);
		}

		for (i in upwardMoves...pathToAppend.components.length) {  //int i=upwardMoves; i<pathToAppend.components.Count; ++i
			p.components.push (pathToAppend.components [i]);
		}

		return p;
	}

	
	
	public var components:Array<Component>;  //{ get; private set; }
	public var isRelative:Bool; // { get; private set; }
	public var head(get, null):Component;
	function get_head():Component 
	{
		if (components.length > 0) {
			return components[0]; // .First ();
		} else {
			return null;
		}
	}
	public var tail(get, null):Path;
	function get_tail():Path 
	{
		
		if (components.length >= 2) {
			// careful, the original code uses length-1 here. This is because the second argument of List.GetRange is a number of elements to extract, wherease Array.slice uses an index
			var tailComps:Array<Component>  = components.slice(1, components.length); //  components.GetRange (1, components.Count - 1);
			return  Path.createFromComponents(tailComps);
		} 
		else {
			return Path.self;
		}
	}

	public var length(get, null):Int;
	function get_length():Int 
	{
		return components.length;
	}
	
	
	public var  lastComponent(get, null):Component;
	function get_lastComponent():Component 
	{
		if (components.length > 0) {
			return components[components.length - 1];// components.Last ();
		} else {
			return null;
		}
	}

	
	public var containsNamedComponent(get, null):Bool;
	function get_containsNamedComponent():Bool 
	{
	  for( comp in components) {
			if( !comp.isIndex ) {
				return true;
			}
		}
		return false;
	}
	
	// Constructors done
	public function new() 
	{
		super();
		components = new Array<Component> ();
	}
	
	public static function createFromHeadAndTail( head:Component,  tail:Path):Path
	{
		var me = new Path();
		me.components.push (head);
		LibUtil.addRangeForArray(me.components, tail.components); //me.components.addRange(tail.components);
		return me;
	}
	
	//IEnumerable<Component>
	
	public static function createFromComponents(components:Array<Component>,  relative:Bool = false):Path
	{
		var me = new Path();
		LibUtil.addRangeForArray(me.components, components); //me.components.AddRange(components);
		me.isRelative = relative;
		return me;
	}
	
	
	public static function createFromComponentStack(components:GenericStack<Component>,  relative:Bool = false):Path
	{
		var me = new Path();

		 //me.components.AddRange(components);
		for (c in components) {
			
			me.components.push(c);
		}
	
		me.isRelative = relative;
		return me;
	}
		
	public static function createFromString(componentsString:String):Path {
		var me = new Path();
		me.componentsString = componentsString;
		return me;
		
	}
	
	//----
	
	public static var self(get, null):Path;
	static function get_self():Path 
	{
		var path = new Path();
		path.isRelative = true;
		return path;
	}
	
	public var componentsString(get,  set):String;
	public function get_componentsString():String 
	{
		   var compsStr = components.join("."); // StringExt.Join(".", components); //StringExt.Join (".", components);
			if (isRelative)
				return "." + compsStr;
			else
				return compsStr;
	}
	function set_componentsString(value:String ):String 
	{
		//components.Clear();
		LibUtil.clearArray(components);
		
		var componentsStr = value;

		// Empty path, empty components
		// (path is to root, like "/" in file system)
		if (componentsStr == "" || componentsStr == null)  { //string.IsNullOrEmpty(componentsStr)
			return value;
		}

		// When components start with ".", it indicates a relative path, e.g.
		//   .^.^.hello.5
		// is equivalent to file system style path:
		//  ../../hello/5
		if (componentsStr.charAt(0) == '.') {
			this.isRelative = true;
			componentsStr = componentsStr.substring (1);
		} else {
			this.isRelative = false;
		}

		var componentStrings = componentsStr.split('.');
		for (str in componentStrings) {
			var index = Std.parseInt(str);
			if ( LibUtil.validInt(index) ) {  //int.TryParse (str , out index)
				components.push ( Component.createFromIndex(index));
			} else {
				components.push ( Component.createFromName(str));
			}
		}
	
		//value = get_componentsString();
		//trace("Final value:" + value);
		
		return value;
	}
	
	
	public function toString ():String
	{
		 return componentsString;
	}
	
	
	
	public override function Equals(obj:Dynamic):Bool
	{
		return EqualsPath(LibUtil.as(obj,Path));
	}
	
	
	
	public function EqualsPath(otherPath:Path):Bool
	{
		if (otherPath == null)
			return false;

		if (otherPath.components.length != this.components.length)
			return false;

		if (otherPath.isRelative != this.isRelative)
			return false;

		return LibUtil.arraySequenceEquals(otherPath.components, this.components);// otherPath.components.SequenceEqual(this.components);
	}
	
	
	/*
	public override function GetHashCode():Int
	{
		if (isIndex)
			return this.index;
		else
			return this.name.GetHashCode ();
	}
	*/

	
}

class Component implements IEquatable
{

	public var index:Int;  //x { get; private set; }
	public var name:String;  //  { get; private set; }

	public var isIndex(get, null):Bool;	
	function get_isIndex():Bool 
	{
		return index >=0;
	}
	public var isParent(get, null):Bool;
	function get_isParent():Bool 
	{
		return name == Path.parentId;
	}
	
	
	// constructors done only
	public function new( )
	{
		
	}

	public static function createFromIndex(index:Int):Component {
		
		var me = new Component();
		Assert.bool(index >= 0, "assertion failed index >=0");
		me.index = index;
		me.name = null;
		return me;
	}

	public static function createFromName( name:String):Component
	{
		var me = new Component();
		Assert.bool(name != null && name.length > 0, "assertion failed:name != null && name.Length > 0");
		me.name = name;
		me.index = -1;
		return me;
	}


	// -------
	
	static public function ToParent() :Component
	{
		return  Component.createFromName(Path.parentId);
	}
	
	public function toString():String {
		if (isIndex) {
			return Std.string(index); // .ToString ();
		} else {
			return name;
		}
	}

	/* INTERFACE ink.runtime.IEquatable.IEquatable<T> */
	
	public function Equals(obj:Dynamic):Bool 
	{
		  return EqualsComponent(LibUtil.as(obj,  Component) );
	}

	
	 public function EqualsComponent( otherComp:Component):Bool
	{
		if (otherComp != null && otherComp.isIndex == this.isIndex) {
			if (isIndex) {
				return index == otherComp.index;   
			} else {
				return name == otherComp.name;
			}
		}
		return false;
	}


			
			
}