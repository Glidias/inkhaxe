package ink.runtime;
import haxe.ds.HashMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;

/**
 * ...
 * @author Glidias
 */
@:expose
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
	
	public function clone():HashSetString {
		var c:HashSetString = new HashSetString();
		for ( p in this.keys()) {
			c.add(p);
		}
		return c;
	}
	
	
}