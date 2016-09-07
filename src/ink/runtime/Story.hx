package ink.runtime;
import haxe.ds.StringMap;

/**
 * ...
 * @author Glidias
 */

//public delegate object ExternalFunction(object[] args);
typedef ExternalFunction = Array<Dynamic>->Dynamic;	

// public delegate void VariableObserver(string variableName, object newValue);
typedef VariableObserver = String->Dynamic->Void;

class Story
{
	static public inline var inkVersionCurrent:Int = 12;
	public static inline var inkVersionMinimumCompatible:Int = 12;
	
	
	public var  currentChoices(get, null):List<Choice>;
	function get_currentChoices():List<Choice> 
	{
		// Don't include invisible choices for external usage.
		var choices = new List<Choice>();
		for ( c in _state.currentChoices) {
			if (!c.choicePoint.isInvisibleDefault) {
				c.index = choices.length;
				choices.add(c);
			}
		}
		return choices;
	}
	
	public var currentText(get, null):String;
	function get_currentText():String 
	{
		return state.currentText;
	}
	
	public var currentErrors(get, null):List<String>;
	function get_currentErrors():List<String> 
	{
		return state.currentErrors;
	}
	
	public var hasError(get, null):Bool;
	function get_hasError():Bool 
	{
		return state.hasError;
	}
	
	public var variablesState(get, null):VariablesState;
	function get_variablesState():VariablesState 
	{
		return state.variablesState;
	}
	
	public var state(get, null):StoryState;
	function get_state():StoryState 
	{
		return _state;
	}
	var _state:StoryState;
	
	
	
	public function new(jsonString:String) 
	{
		
		setupFromContainer(null);
		
		var rootObject:StringMap<Dynamic> = SimpleJson.TextToDictionary(jsonString);
		
		var versionObj:Dynamic = rootObject.get("inkVersion");
		if (versionObj == null)
			throw new SystemException ("ink version number not found. Are you sure it's a valid .ink.json file?");

		var formatFromFile:Int = Std.int(versionObj);
		if (formatFromFile > inkVersionCurrent) {
			throw new SystemException ("Version of ink used to build story was newer than the current verison of the engine");
		} else if (formatFromFile < inkVersionMinimumCompatible) {
			throw new SystemException ("Version of ink used to build story is too old to be loaded by this verison of the engine");
		} else if (formatFromFile != inkVersionCurrent) {
			trace ("WARNING: Version of ink used to build story doesn't match current version of engine. Non-critical, but recommend synchronising.");
		}
			
		var rootToken = rootObject.get("root");//  ["root"];
		if (rootToken == null)
			throw new SystemException ("Root node for ink not found. Are you sure it's a valid .ink.json file?");
		

		_mainContentContainer = LibUtil.as(Json.JTokenToRuntimeObject(rootToken) , Container);

		ResetState (); 
	}
	
	public static function createFromContainer(contentContainer:Container):Story {
		var me:Story = Type.createEmptyInstance(Story); // new Story();
		me.setupFromContainer(contentContainer);
		return me;
	}
	public  inline function setupFromContainer(contentContainer:Container):Void {
		_mainContentContainer = contentContainer;
		_externals = new Map<String, ExternalFunction>(); 
	}
	
	
	public function ToJsonString():String
	{
		var rootContainerJsonList:Array<Dynamic> = cast Json.RuntimeObjectToJToken(_mainContentContainer);   // (List<object>) 

		var rootObject = new Map<String, Dynamic>();
		rootObject.set ("inkVersion", inkVersionCurrent);
		rootObject.set ("root", rootContainerJsonList);

		return SimpleJson.DictionaryToText (rootObject);
	}
		

	public function ResetState():Void
	{
		_state = new StoryState (this);
		
		//_state.variablesState.variableChangedEvent += VariableStateDidChangeEvent;  // C_sharp version
		//this._state.variablesState.ObserveVariableChange(this.VariableStateDidChangeEvent.bind(this));  // inkjs version
		_state.variablesState.ObserveVariableChange(VariableStateDidChangeEvent);  // haxe version (same as inkjs version)
		

		ResetGlobals ();
	}
	
	public function ResetErrors():Void
	{
		_state.ResetErrors ();
	}
	
	public function ResetCallstack():Void
	{
		_state.ForceEndFlow ();
	}
		
	public function ResetGlobals():Void
	{
		 /*  //todo
		   if (_mainContentContainer.namedContent.exists ("global decl")) {
			var originalPath = state.currentPath;

			ChoosePathString ("global decl");

			// Continue, but without validating external bindings,
			// since we may be doing this reset at initialisation time.
			ContinueInternal ();

			state.currentPath = originalPath;
			
		}
		*/
	}
	
	
	
	

	
	public var rootContentContainer:Container;
	
	public var mainContentContainer(get, null):Container;
	function get_mainContentContainer():Container 
	{
		if (_temporaryEvaluationContainer!=null) {
			return _temporaryEvaluationContainer;
		} else {
			return _mainContentContainer;
		}
	}
	var _mainContentContainer:Container;
	
	var _externals: Map<String, ExternalFunction>;
	var _variableObservers:Map<String, VariableObserver>;
	var _hasValidatedExternals:Bool;
	
	var _temporaryEvaluationContainer:Container;
	
	
	
	

	function VariableStateDidChangeEvent( variableName:String, newValueObj:Object):Void
        {
            if (_variableObservers == null)
                return;
            
            var observers:VariableObserver = null;
			observers = _variableObservers.get(variableName);
			
            if (observers!=null) {  //_variableObservers.TryGetValue (variableName, out observers)

                if (!(Std.is(newValueObj, Value)) )  {
                    throw new SystemException ("Tried to get the value of a variable that isn't a standard type");
                }
                var val = LibUtil.as(newValueObj, Value);

                observers(variableName, val.valueObject);
            }
        }
	
	
	public function ContentAtPath(path:Path):Object
	{
		
		return null;
	}
	

	


}