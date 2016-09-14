package ink.runtime;

/**
 * Done!
 * @author Glidias
 */
class VariableAssignment extends RObject
{
	
	public var variableName:String; // { get; protected set; }
    public var isNewDeclaration:Bool; // { get; protected set; }
	public var isGlobal:Bool;// { get; set; }

	public function new(variableName:String=null, isNewDeclaration:Bool=false	) 
	{
		super();
		this.variableName = variableName;
        this.isNewDeclaration = isNewDeclaration;
	}
	
	public function toString():String {
		 return "VarAssign to " + variableName;
	}
	
}