package;

import haxe.ds.StringMap;
import ink.runtime.*;
import ink.runtime.Value;
import ink.runtime.ControlCommand;
/**
 * ...
 * @author Glidias
 */
class InkleRuntime 
{
	
	static function main() 
	{
		Choice;
		CallStack;
		Json;
		Value;
		VariablesState;
		NativeFunctionCall;
		SimpleJson;
		//trace("A");
		
		//testDataTypeClasses();
		testCommandTypeEnum();
	}
	
	static private function testCommandTypeEnum():Void
	{
		var arrTest = ["index0", "index1"];
		trace( arrTest[cast CommandType.EvalStart]);
		var cmdType:Int = cast CommandType.EvalStart;
		trace(cmdType);
		var cmdTypeE:CommandType = CommandType.EvalStart;
		trace(Std.string(cmdTypeE));
		
		var map:Map<String, Object> = new Map<String, Object>();
		var mapInt:Map<Int, Object> = new Map<Int, Object>();
		var mapSet:StringHashSet = new StringHashSet();
		mapSet.add("abc");
		
		var strMapBool:StringMap<Bool> = new StringMap<Bool>();
		
	
		
		map.set("abc", new Object());
		mapInt.set(1, map.get("abc"));
		var json:Dynamic = { "abc":map.get("abc") };
		//trace(map.get("abc") == LibUtil.tryGetValue(mapInt, 1));
		trace(LibUtil.tryGetValue(map, "abc") == LibUtil.tryGetValueDynamic(json, "abc"));
		
		
	}

	
	
	private static function testDataTypeClasses():Void {
		trace(Type.getClass( Value.Create("abc") ) );
		trace( Type.getClass(Value.Create("1")) );
		trace( Type.getClass(Value.Create("0")) );
		trace( Type.getClass(Value.Create("1.0")) );
		trace( Type.getClass(Value.Create("0.01")) );
		trace( Type.getClass(Value.Create(1)) );
		trace( Type.getClass(Value.Create(0)) );
		trace( Type.getClass(Value.Create(1.0)) );
		trace( Type.getClass(Value.Create(0.01)) );
		trace( Type.getClass(Value.Create(true)) );
		trace( Type.getClass(Value.Create(false)) );
		trace(CommandType.PopEvaluatedValue);
		trace(  Value.Create("1").isTruthy );
		
	
		//new Json();
		//trace(Json._controlCommandNames);
	}
	
	
}	
