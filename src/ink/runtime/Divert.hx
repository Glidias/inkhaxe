package ink.runtime;

/**
 * Done!
 * @author Glidias
 */
class Divert extends RObject
{
	public var targetPath(get, set):Path;
	function get_targetPath():Path 
	{
	 // Resolve any relative paths to global ones as we come across them
	  if (_targetPath != null && _targetPath.isRelative) {
			var targetObj = targetContent;
			if (targetObj != null) {
				
				_targetPath = targetObj.path;
			}
		}
		return _targetPath;
	}
	function set_targetPath(value:Path):Path 
	{
		_targetPath = value;
        _targetContent = null;
		return value;
	}
	var _targetPath:Path;
	
	
	public var  targetContent(get, null):RObject;
	function get_targetContent():RObject 
	{
			if (_targetContent == null) {
				_targetContent = ResolvePath (_targetPath);
			}

			return _targetContent;
	}
	var _targetContent:RObject;
	
   public var  targetPathString(get, set):String;
   	function get_targetPathString():String 
	{
		var result:String;
		if (targetPath == null)
			return null;

		result = CompactPathString (targetPath);
		
		
		return result;
	}
	
	function set_targetPathString(value:String):String 
	{
		if (value == null) {
			targetPath = null;
		} else {
			
			targetPath =  Path.createFromString(value);
			
		}
		return value;  //CompactPathString??
	}
	
	
	public var variableDivertName:String; // { get; set; }
	public var hasVariableTarget(get, null):Bool;
	function get_hasVariableTarget():Bool 
	{
		 return variableDivertName != null;
	}
	public var pushesToStack:Bool;  // { get; set; }
	public var stackPushType:PushPopType;  
	
	public var isExternal:Bool;  // { get; set; }
	public var externalArgs:Int;  // { get; set; }

	public var isConditional:Bool;  // { get; set; }
	
	
	public function new() 
	{
		super();
		pushesToStack = false;
	}
	
	public static function createFromPushType(stackPushType:PushPopType):Divert {
		var me = new Divert();
		me.pushesToStack = true;
		me.stackPushType = stackPushType;
		return me;
	}

	public override function Equals ( obj:Dynamic):Bool
	{
		var otherDivert = LibUtil.as(obj,Divert);
		if (otherDivert!=null) {
			if (this.hasVariableTarget == otherDivert.hasVariableTarget) {
				if (this.hasVariableTarget) {
					return this.variableDivertName == otherDivert.variableDivertName;
				} else {
					return this.targetPath.Equals(otherDivert.targetPath);
				}
			}
		}
		return false;
	}
	
	/*
	public override int GetHashCode ()
	{
		if (hasVariableTarget) {
			const int variableTargetSalt = 12345;
			return variableDivertName.GetHashCode() + variableTargetSalt;
		} else {
			const int pathTargetSalt = 54321;
			return targetPath.GetHashCode() + pathTargetSalt;
		}
	}
	*/
	
	  public function toString():String
	{
		if (hasVariableTarget) {
			return "Divert(variable: " + variableDivertName + ")";
		}
		else if (targetPath == null) {
			return "Divert(null)";
		} else {

			var sb = new StringBuf ();

			var targetStr:String= targetPath.toString();
			var targetLineNum:Dynamic = DebugLineNumberOfPath (targetPath);
			if (targetLineNum != null) {
				targetStr = "line " + targetLineNum;
			}

			sb.add ("Divert");
			if (pushesToStack) {
				if (stackPushType == PushPopType.Function) {
					sb.add (" function");
				} else {
					sb.add (" tunnel");
				}
			}

			sb.add (" (");
			sb.add (targetStr);
			sb.add (")");

			return sb.toString();
		}
	}
	
	
	

	

	
	
	
}