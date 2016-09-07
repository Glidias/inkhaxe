package ink.runtime;

/**
 * Done!
 * @author Glidias
 */
class StoryException extends SystemException
{

	public var  useEndLineNumber:Bool;

	/// <summary>
	/// Constructs a default instance of a StoryException without a message.
	/// </summary>
	//public StoryException () { }
		
	public function new(message:String) 
	{
		super(message);
	}
	
}

class SystemNotImplementedException extends SystemException
{
	public function new(message:String)
	{
		super(message);
	}
}