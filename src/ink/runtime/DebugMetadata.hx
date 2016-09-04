package ink.runtime;

/**
 * Done!
 * @author Glidias
 */
class DebugMetadata
{

	public var startLineNumber:Int=0;
		
        public var  endLineNumber:Int = 0;
        public var  fileName:String= null;
        public var  sourceName:String = null;

		
	public function new() 
	{
		
	}
	
	public function toString ():String
	{
		if (fileName != null) {
			return  ("line "+startLineNumber+" of "+fileName);
		} else {
			return "line " + startLineNumber;
		}

	}
	
}