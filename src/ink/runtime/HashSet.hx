package ink.runtime;
import haxe.ds.HashMap;
import haxe.ds.ObjectMap;

/**
 * ...
 * @author Glidias
 */
class HashSet<K: {}> 
{
	var map:Map<K, Bool> = new Map<K, Bool>();
	
	public function new() 
	{
		
	}
	
	public function add(key:K):Void {
		map.set(key, true);
	}
	
	public function keys() {
		return map.keys();
	}
	
	public function contains(key:K):Bool {
		return map.exists(key);
	}
	
	
	
	
}