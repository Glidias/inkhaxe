package ink.runtime;
import haxe.ds.EnumValueMap;

/**
 * ...
 * @author Glidias
 */
class HashSetEnum<K> extends EnumValueMap<K, Bool>  // shoudln't extend but compose, in case someone uses method like "set" which isn't allowed.
{

	public function new() 
	{
		
	}
	
	public inline function add(key:K):Void {
		set(key, true);
	}
	
	
	
	public inline function contains(key:K):Bool {
		return map.get(key);
	}
	
}