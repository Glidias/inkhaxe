package ink.runtime;
import ink.runtime.MapCloner;
import ink.runtime.Value.VariablePointerValue;
import ink.runtime.js.JSProxy;
import ink.runtime.js.JSProxyTrap;

/**
 * Done!
 * @author Glidias
 */
class VariablesState implements IProxy //implements IEnumberable<String>
{
  /// <summary>
    /// Encompasses all the global variables in an ink Story, and
    /// allows binding of a VariableChanged event so that that game
    /// code can be notified whenever the global variables change.
    /// </summary>
	
	// tocheck, contextualisation
	//internal delegate void VariableChanged(string variableName, Runtime.Object newValue);
	//internal event VariableChanged variableChangedEvent;
	public var variableChangedEvent:String->RObject->Void;
	public var variableChangedEventCallbacks:Array<String->RObject->Void> = [];
	/**
	 * This function is specific to the haxe/js version of ink. It allows to register a callback that will be called when a variable changes. The original code uses `state.variableChangedEvent += callback` instead.
	 * @param {function} callback 
	 */
	public function ObserveVariableChange(callback:String->RObject->Void){
		if (this.variableChangedEvent == null){
			this.variableChangedEvent = function(variableName:String, newValue:RObject):Void  {
				/*
				this.variableChangedEventCallbacks.forEach(cb => {
					cb(variableName, newValue);
				});
				*/
				for (cb in variableChangedEventCallbacks) {
					
					cb(variableName, newValue);
				}
			};
			
			
		}
	
		this.variableChangedEventCallbacks.push(callback);
	}
	
	
	public var batchObservingVariableChanges(get, set):Bool;
	function get_batchObservingVariableChanges():Bool 
	{
		return _batchObservingVariableChanges;
	}
	function set_batchObservingVariableChanges(value:Bool):Bool 
	{
		_batchObservingVariableChanges = value;
		if (value) {
			_changedVariables = new HashSetString();
		} 

		// Finished observing variables in a batch - now send 
		// notifications for changed variables all in one go.
		else {
			if (_changedVariables != null) {
				for (variableName in _changedVariables.keys()) {
					var currentValue = _globalVariables [variableName];
					variableChangedEvent (variableName, currentValue);
				}
			}

			_changedVariables = null;
		}
		return _batchObservingVariableChanges;
	}
	var _batchObservingVariableChanges:Bool;
	
	
	// TODO: Link this as Proxy! 
	public function field(variableName:String):Dynamic {
		var varContents:Dynamic;
		if ( (varContents=LibUtil.tryGetValue(_globalVariables, variableName)) != null )
			return ( LibUtil.as(varContents, Value).valueObject );   // should use strict cast to catch !Value type exceptions?
		else
			return null;
	}
	public function setField(variableName:String, value:Dynamic):Void {
		 var val = Value.Create(value);
		if (val == null) {
			if (value == null) {
				throw new StoryException ("Cannot pass null to VariableState");
			} else {
				throw new StoryException ("Invalid value passed to VariableState: "+Std.string(value)); //.toString()
			}
		}

		SetGlobal (variableName, val);
	}
	
		/*
		System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
		{
			return GetEnumerator();
		}
		
	 /// <summary>
        /// Enumerator to allow iteration over all global variables by name.
        /// </summary>
		public IEnumerator<string> GetEnumerator()
		{
			return _globalVariables.Keys.GetEnumerator();
		}
	*/
		
	public function new(callStack:CallStack) 
	{
		 _globalVariables = new Map<String, RObject>();
        _callStack = callStack;
		#if (js)
			_jsProxy = new JSProxy( this,  new JSProxyTrap<VariablesState>() );
		#end
	}
	

	#if (js)
	var _jsProxy:JSProxy;
	public var jsProxy(get, null):JSProxy;
	inline function get_jsProxy():JSProxy 
	{
		return _jsProxy;
	}
	#end

	/*
	function _cloneMap(map:Map<String,Dynamic>):Map<String, Object> {
		var cMap = new Map<String, Object>();
		for (c in map.keys()) {
			cMap.set(c, map.get(c) );
		}
		
		return cMap;
	}
	*/

	public function CopyFrom( varState:VariablesState):Void  
	{
			
		_globalVariables = LibUtil.cloneStrMap(varState._globalVariables); //  cloner.clone( varState._globalVariables );
		variableChangedEvent = varState.variableChangedEvent;

		if (varState.batchObservingVariableChanges != batchObservingVariableChanges) {

			if (varState.batchObservingVariableChanges) {
				_batchObservingVariableChanges = true;
				_changedVariables =   varState._changedVariables.clone(); // cloner.clone( varState._changedVariables);  //varState._changedVariables
			} else {
				_batchObservingVariableChanges = false;
				_changedVariables = null;
			}
		}
	}
	
	public var jsonToken(get, set):Dynamic; //Dictionary<string, object>
	function get_jsonToken():Dynamic 
	{
		 return Json.DictionaryRuntimeObjsToJObject(_globalVariables);
	}
	
	function set_jsonToken(value:Dynamic):Dynamic 
	{
		
		return (_globalVariables = Json.JObjectToDictionaryRuntimeObjs (value));
	}
	
	public function GetVariableWithName( name:String):RObject {
		
		return _GetVariableWithName(name, -1);
	}
		
	 function _GetVariableWithName( name:String,  contextIndex:Int):RObject
	{
	   var varValue:RObject = GetRawVariableWithName (name, contextIndex);

		// Get value from pointer?
		var varPointer = LibUtil.as(varValue , VariablePointerValue);
		if (varPointer!=null) {
			varValue = ValueAtVariablePointer (varPointer);
		}

		return varValue;
	}
	
	function GetRawVariableWithName( name:String,  contextIndex:Int):RObject
	{
		var varValue:RObject = null;
		// 0 context = global
		if (contextIndex == 0 || contextIndex == -1) {
			if ( (varValue=LibUtil.tryGetValue(_globalVariables,  name) )  != null ) {
				return varValue;
			}
		} 

		// Temporary
		varValue = _callStack.GetTemporaryVariableWithName (name, contextIndex);

		if (varValue == null)
			throw new SystemException ("RUNTIME ERROR: Variable '"+name+"' could not be found in context '"+contextIndex+"'. This shouldn't be possible so is a bug in the ink engine. Please try to construct a minimal story that reproduces the problem and report to inkle, thank you!");

		return varValue;
	}
		
		
	public function ValueAtVariablePointer( pointer:VariablePointerValue):RObject
	{
		return _GetVariableWithName (pointer.variableName, pointer.contextIndex);
	}

		
		
	public function Assign( varAss:VariableAssignment, value:RObject):Void
	{
		var name = varAss.variableName;
		var contextIndex:Int = -1;

		// Are we assigning to a global variable?
		var setGlobal:Bool = false;
		if (varAss.isNewDeclaration) {
			setGlobal = varAss.isGlobal;
		} else {
			setGlobal = _globalVariables.exists (name);
		}
		
	

		// Constructing new variable pointer reference
		if (varAss.isNewDeclaration) {
			var varPointer =LibUtil.as( value ,VariablePointerValue);
			if (varPointer!=null) {
				var fullyResolvedVariablePointer = ResolveVariablePointer (varPointer);
				value = fullyResolvedVariablePointer;
			}

		} 


		// Assign to existing variable pointer?
		// Then assign to the variable that the pointer is pointing to by name.
		else {

			// De-reference variable reference to point to
			var existingPointer:VariablePointerValue = null;
			do {
				existingPointer = LibUtil.as( GetRawVariableWithName (name, contextIndex) , VariablePointerValue);
				if (existingPointer!=null) {
					name = existingPointer.variableName;
					contextIndex = existingPointer.contextIndex;
					setGlobal = (contextIndex == 0);
				}
			} while(existingPointer!=null);
		}

		
		if (setGlobal) {
			SetGlobal (name, value);
		} else {
			_callStack.SetTemporaryVariable (name, value, varAss.isNewDeclaration, contextIndex);
		}
	}
	
	
	
	function SetGlobal( variableName:String,  value:RObject):Void
	{
		var oldValue:RObject = null;
		
		oldValue = LibUtil.tryGetValue(_globalVariables, variableName);
		//_globalVariables.TryGetValue (variableName, out oldValue);
		
		_globalVariables.set(variableName, value);
		
		if (variableChangedEvent != null && !value.Equals (oldValue)) {

			if (batchObservingVariableChanges) {
				_changedVariables.add (variableName);
			} else {
				variableChangedEvent (variableName, value);
			}
		}
		
	}
	
	// Given a variable pointer with just the name of the target known, resolve to a variable
	// pointer that more specifically points to the exact instance: whether it's global,
	// or the exact position of a temporary on the callstack.
	function ResolveVariablePointer( varPointer:VariablePointerValue):VariablePointerValue
	{
		var contextIndex:Int = varPointer.contextIndex;

		if( contextIndex == -1 )
			contextIndex = GetContextIndexOfVariableNamed (varPointer.variableName);

		var valueOfVariablePointedTo = GetRawVariableWithName (varPointer.variableName, contextIndex);
		
		// Extra layer of indirection:
		// When accessing a pointer to a pointer (e.g. when calling nested or 
		// recursive functions that take a variable references, ensure we don't create
		// a chain of indirection by just returning the final target.
		var doubleRedirectionPointer = LibUtil.as(valueOfVariablePointedTo,  VariablePointerValue);
		if (doubleRedirectionPointer!=null) {
			return doubleRedirectionPointer;
		} 

		// Make copy of the variable pointer so we're not using the value direct from
		// the runtime. Temporary must be local to the current scope.
		else {
			return new VariablePointerValue (varPointer.variableName, contextIndex);
		}
	}

	// 0  if named variable is global
	// 1+ if named variable is a temporary in a particular call stack element
	function GetContextIndexOfVariableNamed( varName:String):Int
	{
		if (_globalVariables.exists(varName))
			return 0;

		return _callStack.currentElementIndex;
	}
	
	
	
	

	 var _globalVariables:Map<String, RObject>;
		
   // Used for accessing temporary variables
	var _callStack:CallStack;
	var _changedVariables:HashSetString;
}