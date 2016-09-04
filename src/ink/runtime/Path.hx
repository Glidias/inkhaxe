package ink.runtime;
import ink.runtime.Path;
import ink.runtime.Path.Component;

/**
 * TODO
 * @author Glidias
 */
class Path extends Object
{
	// todo
	public var componentsString:String;
	public var isRelative:Bool;
	public var components:Array<Component>;  //{ get; private set; }
	public  var tail:Path;
	
	
	
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
		
	public static function createFromString(componentsString:String):Path {
		var me = new Path();
		me.componentsString = componentsString;
		return me;
		
	}
	
	// ------
	
	// TODO
	
	public function PathByAppendingPath(otherPath:Path):Path
	{
		return null;
	}
	public function toString ():String
	{
		return null;
	}
	
	
	
}

class Component 
{
	public var isParent:Bool;
	public var index:Int;
	public var name:String;
	public var isIndex:Bool;
	
	
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
			return null;
	}
	
	public function Equals(other:Component):Bool {
		return false;
	}
			
			
}