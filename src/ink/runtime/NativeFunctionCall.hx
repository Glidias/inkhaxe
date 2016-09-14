package ink.runtime;
import ink.runtime.Value;

/**
 * Done!
 * @author Glidias
 */
// tocheck:: do ALL binaryOps always return either 1 or 0 , even for string concats??
typedef BinaryOp<T> = T->T->T;
typedef UnaryOp<T> = T->T;

typedef IntBinaryOp = Int->Int->Int;
typedef IntUnaryOp = Int->Int;
typedef FloatBinaryOp = Float->Float->Float;
typedef StringBinaryOp = String->String->Int;
typedef StringBinaryOpConcat = String->String->String;
typedef FloatUnaryOp = Float->Float;
typedef BinaryOpPath = Path->Path->Int;

class NativeFunctionCall extends RObject
{

	public static inline var Add      = "+";
	public static inline var Subtract = "-";
	public static inline var Divide   = "/";
	public static inline var Multiply = "*";
	public static inline var Mod      = "%";
	public static inline var Negate   = "~";

	public static inline var Equal    = "==";
	public static inline var Greater  = ">";
	public static inline var Less     = "<";
	public static inline var GreaterThanOrEquals = ">=";
	public static inline var LessThanOrEquals = "<=";
	public static inline var NotEquals   = "!=";
	public static inline var Not      = "!";

	public static inline var And      = "&&";
	public static inline var Or       = "||";

	public static inline var Min      = "MIN";
	public static inline var Max      = "MAX";
	
	public static function CallWithName(functionName:String):NativeFunctionCall
	{
		return  NativeFunctionCall.createFromName(functionName);
	}
	
	public static function CallExistsWithName( functionName:String):Bool
	{
		GenerateNativeFunctionsIfNecessary ();
		return _nativeFunctions.exists(functionName);
	}
            
		
		
	public var name(get, set):String;
	inline function get_name():String 
	{
		return _name;
	}
	
	function set_name(value:String):String     // protected
	{
		_name = value;
		if( !_isPrototype )
			_prototype = _nativeFunctions [_name];
		return _name;
	}
	var _name:String;
	
	 public var numberOfParameters(get, set):Int;
	 function get_numberOfParameters():Int 
	{
		if (_prototype!=null) {
				return _prototype.numberOfParameters;
			} else {
				return _numberOfParameters;
			}
	}
	function set_numberOfParameters(value:Int):Int   // protected
	{
		return (_numberOfParameters = value);
	}
	var _numberOfParameters:Int;
	
	
	public function Call(parameters:List<RObject>):RObject
    {
		if (_prototype!=null) {
			return _prototype.Call(parameters);
		}

		if (numberOfParameters != parameters.length) {
			throw new SystemException ("Unexpected number of parameters");
		}

		for ( p in parameters) {
			if (Std.is(p, VoidObj))
				throw new StoryException ("Attempting to perform operation on a void value. Did you forget to 'return' a value from a function you called here?");
		}

		var coercedParams = CoerceValuesToSingleType (parameters);
		var coercedType:ValueType = coercedParams.first().valueType;

		if (coercedType == ValueType.IntType) {
			//var intValue:List<IntValue> = cast coercedParams;
			return CallParamList(coercedParams);
		} else if (coercedType == ValueType.FloatType) {
			//var floatValue:List<FloatValue> = cast coercedParams;
			return CallParamList(coercedParams);
		} else if (coercedType == ValueType.StringType) {
		//	var stringValue:List<StringValue> = cast coercedParams;
			return CallParamList(coercedParams);
		} else if (coercedType == ValueType.DivertTarget) {
			//var divertValue:List<DivertTargetValue> = cast  coercedParams;
			return CallParamList(coercedParams);
		}

		return null;
	}

	
	function CallParamList<T>( parametersOfSingleType:List<Value<T>>):Value<T>
	{
		var param1:Value<T> =  parametersOfSingleType.first(); // [0];
		var valType = param1.valueType;

		var val1 = param1;

		var paramCount = parametersOfSingleType.length;

		if (paramCount == 2 || paramCount == 1) {

			var opForTypeObj:Dynamic = null;
			opForTypeObj = _operationFuncs.get(cast valType);
			if (!(opForTypeObj!=null)) {
				throw new StoryException ("Can not perform operation '"+this.name+"' on "+valType);
			}

			// Binary
			if (paramCount == 2) {
				var iter = parametersOfSingleType.iterator();
				iter.next();
				var param2 = iter.next();

				var val2:Value<T> = param2;  //(Value<T>)

				var opForType:BinaryOp<T> = opForTypeObj;  //(BinaryOp<T>)

				// Return value unknown until it's evaluated
				var resultVal:Dynamic = opForType (val1.value, val2.value);
				return Value.Create (resultVal);
			} 

			// Unary
			else {

				var opForType:UnaryOp<T> = opForTypeObj;  //(UnaryOp<T>)

				var resultVal = opForType (val1.value);

				return Value.Create (resultVal);
			}  
		}
			
		else {
			throw new SystemException ("Unexpected number of parameters to NativeFunctionCall: " + parametersOfSingleType.length);
		}
	}
	
	
	function CoerceValuesToSingleType<T>( parametersIn:List<RObject>):List<Value<T>>
	{
		var valType:ValueType = ValueType.IntType;
		var valTypeInt:Int = cast valType;
		
		// Find out what the output type is
		// "higher level" types infect both so that binary operations
		// use the same type on both sides. e.g. binary operation of
		// int and float causes the int to be casted to a float.
		for ( obj in parametersIn) {
			var val:Value<T> = cast obj;
			var valValueType:Int = cast val.valueType;
			if (valValueType > valTypeInt) {
				valType = val.valueType;
			}
		}

		// Coerce to this chosen type
		var parametersOut = new List<Value<T>>();
		for ( v in parametersIn) {
			var val:Value<T> = cast v;
			var castedValue = val.Cast(valType);
			parametersOut.add(castedValue);
		}

		return parametersOut;
	}
		
	public function new() 
	{
		super();
		GenerateNativeFunctionsIfNecessary();
	}
	
	public static function createFromName(name:String):NativeFunctionCall {
		var me:NativeFunctionCall = new NativeFunctionCall();
		me.name = name;
		return me;
	}
	
	  // Only called internally to generate prototypes
	public static function createFromNameAndNumParams(name:String,  numberOfParamters:Int):NativeFunctionCall {
		var me:NativeFunctionCall = new NativeFunctionCall();
		me._setupNameAndNumParams(name, numberOfParamters);
		return me;
	}
	  
	inline function  _setupNameAndNumParams( name:String,  numberOfParamters:Int):Void
	{
		this._isPrototype = true;
		this.name = name;
		this.numberOfParameters = numberOfParamters;
	}
	
	static function GenerateNativeFunctionsIfNecessary():Void
	{
		if (_nativeFunctions == null) {
			_nativeFunctions = new Map<String, NativeFunctionCall> ();

			// Int operations
			
			AddIntBinaryOp(Add,      function(x, y) { return x + y;});
			AddIntBinaryOp(Subtract, function(x, y) { return x - y;});
			AddIntBinaryOp(Multiply, function(x, y) { return x * y;});
			AddIntBinaryOp(Divide,   function(x, y) { return Std.int(x / y);});
			AddIntBinaryOp(Mod,      function(x, y) { return x % y;}); 
			AddIntUnaryOp (Negate,   function(x) { return -x;}); 

			AddIntBinaryOp(Equal,    function(x, y) { return x == y ? 1 : 0;});
			AddIntBinaryOp(Greater,  function(x, y) { return x > y  ? 1 : 0;});
			AddIntBinaryOp(Less,     function(x, y) { return x < y  ? 1 : 0;});
			AddIntBinaryOp(GreaterThanOrEquals, function(x, y) { return x >= y ? 1 : 0;});
			AddIntBinaryOp(LessThanOrEquals, function(x, y) { return x <= y ? 1 : 0;});
			AddIntBinaryOp(NotEquals,function (x, y) { return x != y ? 1 : 0;});
			AddIntUnaryOp (Not,       function(x) { return x == 0 ? 1 : 0;}); 

			AddIntBinaryOp(And,      function(x, y) { return x != 0 && y != 0 ? 1 : 0;});
			AddIntBinaryOp(Or,      function(x, y) { return x != 0 || y != 0 ? 1 : 0;});

			AddIntBinaryOp(Max,      function(x, y) { return LibUtil.maxI_(x, y);});
			AddIntBinaryOp(Min,      function(x, y) { return LibUtil.minI_(x, y);});

			// Float operations
			AddFloatBinaryOp(Add,      function(x, y) { return x + y;});
			AddFloatBinaryOp(Subtract, function(x, y) { return x - y;});
			AddFloatBinaryOp(Multiply, function(x, y) { return x * y;});
			AddFloatBinaryOp(Divide,   function(x, y) { return x / y;});
			AddFloatBinaryOp(Mod,      function(x, y) { return x % y;}); // TODO: Is this the operation we want for floats?
			AddFloatUnaryOp (Negate,   function(x) { return  -x;}); 

			
			AddFloatBinaryOp(Equal,    function(x, y) { return x == y ? 1 : 0;});
			AddFloatBinaryOp(Greater,  function(x, y) { return x > y  ? 1 : 0;});
			AddFloatBinaryOp(Less,     function(x, y) { return x < y  ? 1 : 0;});
			AddFloatBinaryOp(GreaterThanOrEquals, function(x, y) { return x >= y ? 1 : 0;});
			AddFloatBinaryOp(LessThanOrEquals, function(x, y) { return x <= y ? 1 : 0;});
			AddFloatBinaryOp(NotEquals, function(x, y) { return x != y ? 1 : 0;});
			AddFloatUnaryOp (Not,       function(x) { return x == 0.0 ? 1 : 0;}); 

			AddFloatBinaryOp(And,      function(x, y) { return x != 0.0 && y != 0.0 ? 1 : 0;});
			AddFloatBinaryOp(Or,       function(x, y) { return x != 0.0 || y != 0.0 ? 1 : 0;});

			AddFloatBinaryOp(Max,      function(x, y) { return Math.max(x, y);});
			AddFloatBinaryOp(Min,      function(x, y) { return Math.min(x, y);});

			// String operations
			AddStringBinaryOpConcat(Add,     function(x, y) { return x + y; }); // concat
			AddStringBinaryOp(Equal,   function(x, y) { return x == y ? 1 : 0; });
			

			// Special case: The only operation you can do on divert target values
			//
			var divertTargetsEqual:BinaryOpPath = function( d1,  d2)  {  //BinaryOp<Path>
				return d1.Equals(d2) ? 1 : 0;
			};
			AddOpToNativeFunc (Equal, 2, ValueType.DivertTarget, divertTargetsEqual);
			
		}
	}

	function AddOpFuncForType( valType:ValueType,  op:Dynamic):Void
	{
		if (_operationFuncs == null) {
			_operationFuncs = new Map<Int, Dynamic>();
		}

		_operationFuncs.set(cast valType, op); // [valType] = op;
	}

	static function  AddOpToNativeFunc( name:String,  args:Int,  valType:ValueType,  op:Dynamic):Void
	{
		var nativeFunc:NativeFunctionCall = null;
		nativeFunc = _nativeFunctions.get(name);
		if ( !(nativeFunc!=null)) {  //!_nativeFunctions.TryGetValue (name, out nativeFunc)
			nativeFunc =  NativeFunctionCall.createFromNameAndNumParams(name, args);
			_nativeFunctions.set( name, nativeFunc);
		}

		nativeFunc.AddOpFuncForType (valType, op);
	}
	
	
	
	 static function  AddIntBinaryOp(name:String, op:IntBinaryOp ):Void
	{
		AddOpToNativeFunc (name, 2, ValueType.IntType, op);
	}

	 static function  AddIntUnaryOp(name:String, op:IntUnaryOp):Void
	{
		AddOpToNativeFunc (name, 1, ValueType.IntType, op);
	}

	 static function  AddFloatBinaryOp(name:String, op:FloatBinaryOp):Void
	{
		AddOpToNativeFunc (name, 2, ValueType.FloatType, op);
	}

	 static function  AddStringBinaryOp(name:String, op: StringBinaryOp):Void
	{
		AddOpToNativeFunc (name, 2, ValueType.StringType, op);
	}
	 static function  AddStringBinaryOpConcat(name:String, op: StringBinaryOpConcat):Void
	{
		AddOpToNativeFunc (name, 2, ValueType.StringType, op);
	}

	 static function  AddFloatUnaryOp(name:String, op:FloatUnaryOp):Void
	{
		AddOpToNativeFunc (name, 1, ValueType.FloatType, op);
	}
	
	// typedefs as of above should be enough..
	//delegate object BinaryOp<T>(T left, T right);
	//delegate object UnaryOp<T>(T val);
	
	public function toString():String
	{
		return "Native '" + name + "'";
	}
	

	
	

	var  _prototype:NativeFunctionCall;
	var _isPrototype:Bool;
		
	var _operationFuncs:Map<Int, Dynamic>;
	
	
	 
	static var _nativeFunctions:Map<String, NativeFunctionCall>;
	
}