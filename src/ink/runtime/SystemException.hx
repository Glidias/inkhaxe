package ink.runtime;

/**
 * Done!
 * @author Glidias
 */
class SystemException
{
	public var msg:String;

	public function new(msg:String) 
	{
		this.msg = msg;
		
	}
	
	public function toString():String {
		return Type.getClassName(Type.getClass(this))+":: " + msg;
	}
	
}