package ink.runtime.js;
import ink.runtime.IProxy;

/**
 * @author Glidias
 */
class JSProxyTrap<T:IProxy>
{
	
	
	public function new() {
	
	}
	public function get(target:T, property:String):Dynamic {
		return target.field(property);
	}
	
	public function set(target:T, property:String, value:Dynamic):Void {
		target.setField(property, value);
	}
}