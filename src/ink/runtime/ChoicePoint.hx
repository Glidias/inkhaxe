package ink.runtime; 
import ink.runtime.Container;

/**
 * Done!
 * @author Glidias
 */
class ChoicePoint extends RObject
{
	/// <summary>
    /// The ChoicePoint represents the point within the Story where
    /// a Choice instance gets generated. The distinction is made
    /// because the text of the Choice can be dynamically generated.
    /// </summary>
	public var pathOnChoice:Path; // { get; set; }
	
	public var  choiceTarget(get, null):Container;
	function get_choiceTarget():Container 
	{
		return LibUtil.asNoInline(this.ResolvePath(pathOnChoice), Container);
	}
	
	public var pathStringOnChoice(get, set):String;
	function get_pathStringOnChoice():String 
	{
		return CompactPathString(pathOnChoice);
	}
	function set_pathStringOnChoice(value:String):String 
	{
		pathOnChoice = Path.createFromString(value);
		return value;//CompactPathString(pathOnChoice= Path.createFromString(value));
	}
	
	
	public var  hasCondition:Bool; //{ get; set; }
    public var  hasStartContent:Bool; //{ get; set; }
    public var  hasChoiceOnlyContent:Bool; //{ get; set; }
	public var  onceOnly:Bool;  //{ get; set; }
    public var  isInvisibleDefault:Bool;// { get; set; }
	
	public var flags(get, set):Int;
	function get_flags():Int 
	{
		var flags = 0;
		if (hasCondition)         flags |= 1;
		if (hasStartContent)      flags |= 2;
		if (hasChoiceOnlyContent) flags |= 4;
		if (isInvisibleDefault)   flags |= 8;
		if (onceOnly)             flags |= 16;
		return flags;
	}
	
	function set_flags(value:Int):Int 
	{
		var flags = 0;
		
	   flags |= (hasCondition = (value & 1) > 0) ? 1 : 0;
	   flags |= (hasStartContent = (value & 2) > 0) ? 2 : 0;
		flags |= (hasChoiceOnlyContent = (value & 4) > 0) ? 4 : 0;
		 flags |= (isInvisibleDefault = (value & 8) > 0) ? 8 : 0;
		  flags |= (onceOnly = (value & 16) > 0) ? 16 : 0;  
		   
      // hasStartContent = (value & 2) > 0;
      // hasChoiceOnlyContent = (value & 4) > 0;
       //isInvisibleDefault = (value & 8) > 0;
      // onceOnly = (value & 16) > 0;
	   return flags;
	}
	
	public function new() 
	{
		super();
		onceOnly = true;
	}
	
	public static function createOnceOnly(onceOnly:Bool):ChoicePoint {
		var me:ChoicePoint = new ChoicePoint();
		me.onceOnly = onceOnly;
		return me;
	}
	
	public  function toString ():String
	{
		//int? 
		var targetLineNum:Dynamic = DebugLineNumberOfPath (pathOnChoice);
		var targetString:String = pathOnChoice.toString();

		if (targetLineNum != null) {
			targetString = " line " + targetLineNum;
		}

		return "Choice: -> " + targetString;
	}

	
}