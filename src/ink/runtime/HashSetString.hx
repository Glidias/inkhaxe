package ink.runtime;
import haxe.ds.HashMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;

/**
 * ...
 * @author Glidias
 */
class HashSetString 
{
	var map:StringMap<Bool> = new StringMap<Bool>();
	
	public function new() 
	{
		
	}
	
	public function add(key:String):Void {
	
		map.set(key, true);
	}
	
	public function keys() {
		return map.keys();
	}
	
	public function contains(key:String):Bool {
		return map.get(key);
	}
	
	
}