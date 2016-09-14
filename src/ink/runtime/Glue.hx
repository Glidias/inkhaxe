package ink.runtime;

/**
 * Done!
 * @author Glidias
 */
enum GlueType
{
	Bidirectional;
	Left;
	Right;
}
	
class Glue extends RObject
{
	public var glueType:GlueType; //{ get; set; }
	public var isLeft(get, null):Bool;
	function get_isLeft():Bool 
	{
		return glueType  == GlueType.Left;
	}
	
	public var isBi(get, null):Bool;
	function get_isBi():Bool 
	{
		return glueType == GlueType.Bidirectional;
	}
	
	public var isRight(get, null):Bool;
	function get_isRight():Bool 
	{
		return glueType == GlueType.Right;
	}
	
	public function new(type:GlueType) 
	{
		super();
		glueType = type;
	}
	public function toString():String
	{
		switch (glueType) {
			case GlueType.Bidirectional: return "BidirGlue";
			case GlueType.Left: return "LeftGlue";
			case GlueType.Right: return "RightGlue";
		}

		return "UnexpectedGlueType";
	}
	
	
	
	
	
}