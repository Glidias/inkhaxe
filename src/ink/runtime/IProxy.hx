package ink.runtime;

/**
 * @author Glidias
 */
interface IProxy 
{
  
  function field(variableName:String):Dynamic;
  function setField(variableName:String, value:Dynamic):Void;
  
}