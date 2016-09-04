package ink.runtime;
import haxe.ds.StringMap;

/**
 * done.
 * @author Glidias
 */
class StringHashSet extends StringMap<Bool>
{

	public function new() 
	{
		super();
	}
	
	public inline function add(variableName:String) 
	{
		set(variableName, true);
	}
	
}