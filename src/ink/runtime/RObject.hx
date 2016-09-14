package ink.runtime;
import haxe.ds.GenericStack;
import ink.runtime.Path.Component;
import ink.runtime.StoryException.SystemNotImplementedException;

/**
 * Done!
 * @author Glidias
 */
class RObject
{
	public var parent:RObject;

	 
	public var debugMetadata(get, set):DebugMetadata;
	function get_debugMetadata():DebugMetadata 
	{
		if (_debugMetadata == null) {
			if (parent!=null) {
				return parent.debugMetadata;
			}
		}
		return _debugMetadata;
	}
	function set_debugMetadata(value:DebugMetadata):DebugMetadata 
	{
		return _debugMetadata = value;
	}
	
	// TODO: Come up with some clever solution for not having
    // to have debug metadata on the object itself, perhaps
    // for serialisation purposes at least.
	private var _debugMetadata:DebugMetadata;
	
	
	
	
	function DebugLineNumberOfPath(path:Path):Dynamic  //?int (for return data type)
	{

		if (path == null)
			return null;
		
		// Try to get a line number from debug metadata
		var root = this.rootContentContainer;
		if (root!=null) {
			var targetContent = root.ContentAtPath (path);
			if (targetContent!=null) {
				var dm = targetContent.debugMetadata;
				if (dm != null) {
					return dm.startLineNumber;
				}
			}
		}
		return null;
	}
	
	public var path(get, null):Path;
	function get_path():Path 
	{
		 if (_path == null) {
			
			if (parent == null) {
				_path = new Path ();
			} else {
				
				// Maintain a Stack so that the order of the components
				// is reversed when they're added to the Path.
				// We're iterating up the hierarchy from the leaves/children to the root.
				var comps = new GenericStack<Component>();// Array<Component> ();

				var child = this;
				var container = LibUtil.as(child.parent, Container);

				while (container!=null) {

					var namedChild = LibUtil.as(child, INamedContent);
					if (namedChild != null && namedChild.hasValidName) {
						comps.add( Component.createFromName (namedChild.name));
					} else {
						comps.add(Component.createFromIndex(container.content.indexOf(child)));
					}
					
					

					child = container;
					container = LibUtil.as(container.parent , Container);
				}

				_path =  Path.createFromComponentStack(comps);

			}

		}
		
		return _path;
	}
	private var _path:Path;
	
	private function ResolvePath(path:Path):RObject 	
	{
		if (path.isRelative) {
			var nearestContainer:Container = LibUtil.as(this, Container);
			if (nearestContainer == null) {
				Assert.bool(this.parent != null, "Can't resolve relative path because we don't have a parent");
				nearestContainer = LibUtil.as(this.parent, Container);
				Assert.bool(nearestContainer != null, "Expected parent to be a container");
				Assert.bool(path.components[0].isParent, "Is parent assertion failed" );
				path = path.tail;
			}

			return nearestContainer.ContentAtPath (path);
		} else {
			return this.rootContentContainer.ContentAtPath (path);
		}
	}
	
	function ConvertPathToRelative( globalPath:Path):Path
	{
		// 1. Find last shared ancestor
		// 2. Drill up using ".." style (actually represented as "^")
		// 3. Re-build downward chain from common ancestor

		var ownPath = this.path;

		var minPathLength:Int = LibUtil.minI(globalPath.components.length, ownPath.components.length);
		var lastSharedPathCompIndex = -1;

		for (i in 0...minPathLength) {	//int i = 0; i < minPathLength; ++i
			var ownComp =  ownPath.components[i];
			var otherComp = globalPath.components [i];

			if (ownComp.Equals(otherComp)) {
				lastSharedPathCompIndex = i;
			} else {
				break;
			}
		}

		// No shared path components, so just use global path
		if (lastSharedPathCompIndex == -1)
			return globalPath;

		var numUpwardsMoves:Int = (ownPath.components.length-1) - lastSharedPathCompIndex;

		var newPathComps = new Array<Component> ();  //Path.

		for(up in 0...numUpwardsMoves) { //int up=0; up<numUpwardsMoves; ++up
			newPathComps.push(Component.ToParent());
		}

		for (down in (lastSharedPathCompIndex + 1)...globalPath.components.length ) {  //int down = lastSharedPathCompIndex + 1; down < globalPath.components.Count; ++down
			newPathComps.push(globalPath.components[down]);
		}
		var relativePath = Path.createFromComponents(newPathComps, true); //relative:true
		return relativePath;
	}
	
	
	
	// Find most compact representation for a path, whether relative or global
	function CompactPathString( otherPath:Path):String
	{
		
		var globalPathStr:String = null;
		var relativePathStr:String = null;
		if (otherPath.isRelative) {
			relativePathStr = otherPath.componentsString;
			globalPathStr = this.path.PathByAppendingPath(otherPath).componentsString;
		} else {
			var relativePath = ConvertPathToRelative (otherPath);
			relativePathStr = relativePath.componentsString;
			globalPathStr = otherPath.componentsString;
		}

		if (relativePathStr.length < globalPathStr.length) 
			return relativePathStr;
		else
			return globalPathStr;
		
	}
	
	public var  rootContentContainer(get, null):Container;
	function get_rootContentContainer():Container  // done
	{
			var ancestor:RObject = this;
			
			while (ancestor.parent!=null) {
				ancestor = ancestor.parent;
			}
	
			return LibUtil.as(ancestor , Container);
	}
	

	

	
	public function Copy():RObject {
		//GetType ().Name 
		 throw new SystemNotImplementedException( Type.typeof(this).getName() + " doesn't support copying");
	}
	
	
	
	//ref T obj
	function SetChildReturnValue<T:RObject>(obj:T, value:T):T //where T : Runtime.Object
	{

		if (obj != null)
			obj.parent = null;

		
		obj = value;

		if(obj!=null)
			obj.parent = this;
			
		return value;
	}
		
	/// Allow implicit conversion to bool so you don't have to do:
	/// if( myObj != null ) ...
	/*	// Haxe requires this, sorry, no shortcut
	public static implicit operator bool (Object obj)
	{
		var isNull = object.ReferenceEquals (obj, null);
		return !isNull;
	}
	*/

	/// Required for implicit bool comparison
	
	public static function EQUALS(a:RObject, b:RObject):Bool
	{
		return a == b; // object.ReferenceEquals (a, b);
	}

	/// Required for implicit bool comparison
	//operator !=
	public static function notEquals(a:RObject, b:RObject):Bool
	{
		return !(a == b);
	}

	/// Required for implicit bool comparison
	public function Equals ( obj:Dynamic):Bool
	{
		return obj == this;  //return object.ReferenceEquals (obj, this);
	}
	

	
	/*
	 
	private static var _HASH_ID:Int = 0;
	private var _hashId:Int;
	
	/// Required for implicit bool comparison
	public inline function  GetHashCode ():Int
	{
		return _hashId;
	}
	
	
	
	*/

	public function new() 
	{
		//_hashId = _HASH_ID++;
	}
	
}