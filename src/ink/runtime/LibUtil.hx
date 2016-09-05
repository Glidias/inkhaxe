package ink.runtime;
import haxe.ds.StringMap;


/**
 * done!
 * @author Glidias
 */
class LibUtil
{

	public static inline function as<T>( obj:Dynamic, type:Class<T> ):T {
		return Std.is( obj, type ) ? cast obj : null;
	}
	public static  function asNoInline<T>( obj:Dynamic, type:Class<T> ):T {
		return Std.is( obj, type ) ? cast obj : null;
	}
	
	public static inline function tryParseFloat(val:Dynamic ):Dynamic {
		return Std.parseFloat(val);  // TOCHECK: across all platforms validity
	}
	public static inline function tryParseInt(val:Dynamic ):Dynamic {
		return Std.parseInt(val); // TOCHECK: across all platforms validity
	}
	
	public static inline function tryGetValue<V:Object>(map:StringMap<V>, prop:String ):V {
		return map.get(prop); 
	}
	public static inline function tryGetValueINamedContent<V:INamedContent>(map:StringMap<V>, prop:String ):V {
		return map.get(prop); 
	}
	
	// for json tokens, you must use this!
	public static inline function tryGetValueDynamic(obj:Dynamic, prop:String ):Dynamic {
		return Reflect.field(obj, prop);  
	}

	public static function arraySequenceEquals<T>(arr1:Array<T>, arr2:Array<T>):Bool {
		if (arr1.length != arr2.length) return false;
		for (i in 0...arr1.length) {
			if (arr1[i] != arr2[i]) {
				return false;
			}
		}
		return true;
	}
	
	
	public static function addRangeForList<T>(list:List<T>, toAdd:List<T>):Void{
		for (i in toAdd) {
			list.add(i);
		}
	}
	public static function addRangeForArray<T>(list:Array<T>, toAdd:Array<T>):Void{
		for (i in 0...toAdd.length) {
			list.push(toAdd[i]);
		}
	}
	
	public static function listEquals<T>(list:List<T>, other:List<T>):Bool {
		return false;
	}
	
	public static function findForList<T>(list:List<T>, f : T -> Bool ):T {
		for ( i in list) {
			if (f(i)) {
				return i;
			}
		}
		return null;
	}
	
	static public function minI(a:Int, b:Int):Int 
	{
		return (a < b ? a : b);
	}
	static public function maxI(a:Int, b:Int):Int 
	{
		return (a >= b ? a : b);
	}
	static public inline function minI_(a:Int, b:Int):Int 
	{
		return (a < b ? a : b);
	}
	static public inline function maxI_(a:Int, b:Int):Int 
	{
		return (a >= b ? a : b);
	}
	
}