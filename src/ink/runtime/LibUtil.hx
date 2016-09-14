package ink.runtime;
import haxe.ds.StringMap;
import ink.runtime.RObject;


/**
 * done!
 * @author Glidias
 */
class LibUtil
{

	public static inline function validInt(?val:Int):Bool {
		return val != null && !Math.isNaN(val);
	}
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
	
	public static inline function tryGetValue<V:RObject>(map:StringMap<V>, prop:String ):V {
		return map.get(prop); 
	}
	public static inline function tryGetValueINamedContent<V:INamedContent>(map:StringMap<V>, prop:String ):INamedContent {
		return map.get(prop); 
	}
	
	public static function jTokenToStringMap(token:Dynamic):StringMap<Dynamic> {
		var strMap = new StringMap<Dynamic>();
		for (f in Reflect.fields(token)) {
			strMap.set( f, Reflect.field(token, f));
		}
		return strMap;
	}
	
	public static function cloneStrMap<K:String,V:{ }>(map:Map<K,V>):Map<K, V> {
		var cMap = new Map<K, V>();
		for (c in map.keys()) {
			cMap.set(c, map.get(c) );
		}
		
		return cMap;
	}
	
	public static function cloneStrIntMap<K:String,V:Int>(map:Map<K,V>):Map<K, V> {
		var cMap = new Map<K, V>();
		for (c in map.keys()) {
			cMap.set(c, map.get(c) );
		}
		
		return cMap;
	}
	
	
	public static function cloneObjMap<K:{ },V:{ }>(map:Map<K,V>):Map<K, V> {
		var cMap = new Map<K, V>();
		for (c in map.keys()) {
			cMap.set(c, map.get(c) );
		}
		
		return cMap;
	}
	
	public static  function listIndexOf<T>(list:List<T>, obj:Dynamic):Int {
		var count:Int = 0;
		for (l in list) {
			if (l == obj) return count;
			count++;
		}
		return -1;
	}
	
	public static function arrayToList<T>(arr:Array<T>):List<T> {
		var list:List<T> = new List<T>();
		for (val in arr) {
			list.add(val);
		}
		return list;
	}
	
	public static inline function getArrayItemAtIndex<T>(arr:Array<T>, index:Int):T {
		return arr[index];
	}
	
	public static function getListItemAtIndex<T>(list:List<T>, index:Int):T {
		if (index < 0 || index >= list.length) return null;
		var iter = list.iterator();
		for (i in 0...index) {
			iter.next();
		}
		return iter.next();
	}
	
	// for json tokens, you must use this!
	public static inline function tryGetValueDynamic(obj:Dynamic, prop:String ):Dynamic {
		return Reflect.field(obj, prop);  
	}
	
	public static inline function clearArray<T>(arr:Array<T>):Void {
		#if (js||flash)
		untyped arr.length = 0;
		#else
		arr.splice(0,arr.length);
		#end
	}

	public static function arraySequenceEquals<T:IEquatable>(arr1:Array<T>, arr2:Array<T>):Bool {  //<T>
		if (arr1.length != arr2.length) return false;
		for (i in 0...arr1.length) {
			if (!arr1[i].Equals(arr2[i])) {  // enforced IEquatable constraint
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
	
	static public inline function removeArrayItemAtIndex<T>(arr:Array<T>, index:Int) 
	{
		arr.splice(index,1);
	}
	
}