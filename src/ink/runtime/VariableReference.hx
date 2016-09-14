package ink.runtime;

/**
 * Done!
 * @author Glidias
 */
class VariableReference extends RObject
{
	
	// Normal named variable
   public var name:String; // { get; set; }

    // Variable reference is actually a path for a visit (read) count
    public var pathForCount:Path;// { get; set; }
	
	public var  containerForCount(get, null):Container;
	function get_containerForCount():Container 
	{
		 return LibUtil.as( this.ResolvePath(pathForCount),  Container);
	}
         
		
	public var pathStringForCount(get, set):String;
	function get_pathStringForCount():String 
	{
		 if( pathForCount == null )
            return null;

        return CompactPathString(pathForCount);
	}
	
	function set_pathStringForCount(value:String):String 
	{
		if (value == null)
			pathForCount = null;
			else
			pathForCount =  Path.createFromString(value);
		return value;  //CompactPathString
	}

	public function new() 
	{
			super();
	}
	
	public static function create(name:String):VariableReference {
		var me:VariableReference = new VariableReference();
		me.name = name;
		return me;
	}
	
	public function toString():String
	{
		if (name != null) {
			return "var(" + name+")";// string.Format ("var({0})", name);
		} else {
			var pathStr = pathStringForCount;
			return "read_count("+pathStr+")"; // string.Format("read_count({0})", pathStr);
		}
	}
	
	
	
	
	
}