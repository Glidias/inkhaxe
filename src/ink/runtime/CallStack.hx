package ink.runtime;
import ink.runtime.Cloner;
import haxe.ds.GenericStack;
import ink.runtime.CallStack.Thread;
/**
 * DONE!
 * @author Glidias
 */
class CallStack
{
	
	public var elements(get, null):Array<Element>;
	function get_elements():Array<Element> 
	{
		return callStack;
	}

	public var currentElement(get, null):Element; 
	function get_currentElement():Element 
	{
		return callStack[callStack.length - 1];
	}

	public var currentElementIndex(get, null):Int;
	function get_currentElementIndex():Int 
	{
		return callStack.length - 1;
	}
	

	public var currentThread(get, set):Thread;
	function get_currentThread():Thread 
	{
		return _threads.last(); // _threads [_threads.length - 1];
	}
	function set_currentThread(value:Thread):Thread 
	{
		Assert.bool(_threads.length == 1, "Shouldn't be directly setting the current thread when we have a stack of them");
		_threads.clear();
		_threads.add(value);
		return value;
	}
	


	public var canPop(get, null):Bool;
	function get_canPop():Bool 
	{
		return callStack.length > 1;
	}
	
	
	public function new() 
	{
		
	}
	
	public static function createCallStack(rootContentContainer:Container):CallStack {
		var me:CallStack = new CallStack();
		me.setupCallStack(rootContentContainer);
		return me;
	}
	public  function setupCallStack(rootContentContainer:Container):Void {
		_threads = new List<Thread> ();
		_threads.add(new Thread ());

		//_threads[0]
		_threads.first().callstack.push (new Element (PushPopType.Tunnel, rootContentContainer, 0));
	
	}

	public static function createCallStack2(toCopy:CallStack):CallStack
	{
		var me:CallStack = new CallStack();
		me.setupCallStack2(toCopy);
		return me;
	}
	public  function setupCallStack2(toCopy:CallStack):Void {
		_threads = new List<Thread> ();
		var i =  toCopy._threads.iterator();
		while (i.hasNext()) {
			var otherThread = i.next();
			_threads.add(otherThread.Copy());
		}
	}
		
	// Unfortunately it's not possible to implement jsonToken since
	// the setter needs to take a Story as a context in order to
	// look up objects from paths for currentContainer within elements.
	public function  SetJsonToken( jObject:Dynamic,  storyContext:Story):Void
	{
		_threads.clear();

		var jThreads:Array<Dynamic> = Reflect.field(jObject, "threads"); // (List<object>) jObject ["threads"];

		for (i in 0...jThreads.length) {
			var jThreadTok:Dynamic = jThreads[i];
			var jThreadObj:Dynamic = jThreadTok;  //(Dictionary<string, object>)
			var thread =  Thread.create(jThreadObj, storyContext);
			_threads.add(thread);
		}

		_threadCounter = Reflect.field(jObject, "threadCounter"); // jObject ["threadCounter"];
	}
		
	// See above for why we can't implement jsonToken
	public function GetJsonToken():Dynamic {  //Dictionary<string, object> 

		var jObject = {}; // new Dictionary<string, object> ();

		var jThreads = [];  // new List<object> ()
		var i = _threads.iterator();
		while (i.hasNext()) {
			var thread:Thread =  i.next();
			jThreads.push(thread.jsonToken);
		}

		Reflect.setField(jObject, "threads", jThreads);
		Reflect.setField(jObject, "threadCounter", _threadCounter);
		//jObject ["threads"] = jThreads;
		//jObject ["threadCounter"] = _threadCounter;

		return jObject;
	}

	public function PushThread():Void
	{
		var newThread = currentThread.Copy ();
		newThread.threadIndex = _threadCounter;
		_threadCounter++;
		_threads.add (newThread);
	}

	public function PopThread():Void
	{
		if (canPopThread) {
			_threads.remove (currentThread);
		} else {
			throw new SystemException("Can't pop thread");
		}
	}

	public var canPopThread(get, null):Bool;
	function get_canPopThread():Bool 
	{
		return _threads.length > 1;
	}


	public function Push( type:PushPopType):Void
	{
		// When pushing to callstack, maintain the current content path, but jump out of expressions by default
		//inExpressionEvaluation: false
		callStack.push(new Element(type, currentElement.currentContainer, currentElement.currentContentIndex,false ));
	}

	public function CanPop( ?type:PushPopType = null):Bool {

		if (!canPop)
			return false;
		
		if (type == null)
			return true;
		
		return currentElement.type == type;
	}
		
	public function Pop(type:PushPopType = null):Void
	{
		if (CanPop (type)) {
			
			callStack.pop();  //callStack.RemoveAt (callStack.Count - 1);
			return;
		} else {
			throw new SystemException("Mismatched push/pop in Callstack");
		}
	}
	


	// Get variable value, dereferencing a variable pointer if necessary
	public function GetTemporaryVariableWithName( name:String,  contextIndex:Int = -1):RObject
	{
		if (contextIndex == -1)
			contextIndex = currentElementIndex+1;
		
		var varValue:RObject = null;

		var contextElement = callStack[contextIndex - 1];
		//if (contextElement == null) throw "could not find context element at callstack:" + contextElement + " at index:"+contextIndex + " :: "+name;
		
		varValue = LibUtil.tryGetValue(contextElement.temporaryVariables, name);
		if (varValue!=null) {  //contextElement.temporaryVariables.TryGetValue (name, out varValue)
			return varValue; 
		} else {
			return null;
		}
	}
		
	public function SetTemporaryVariable( name:String, value:RObject,  declareNew:Bool,  contextIndex:Int = -1)
	{
		if (contextIndex == -1)
			contextIndex = currentElementIndex+1;

		var contextElement = callStack[contextIndex - 1];
	
		
		if (!declareNew && !contextElement.temporaryVariables.exists(name)) {
			throw new StoryException("Could not find temporary variable to set: " + name);
		}

		contextElement.temporaryVariables [name] = value;
	}

	// Find the most appropriate context for this variable.
	// Are we referencing a temporary or global variable?
	// Note that the compiler will have warned us about possible conflicts,
	// so anything that happens here should be safe!
	public function ContextForVariableNamed( name:String):Int
	{
		// Current temporary context?
		// (Shouldn't attempt to access contexts higher in the callstack.)
		if (currentElement.temporaryVariables.exists (name)) {
			return currentElementIndex+1;
		} 

		// Global
		else {
			return 0;
		}
	}
		
	public function ThreadWithIndex( index:Int):Thread
	{
	
		return LibUtil.findForList(_threads, function(t:Thread):Bool { return t.threadIndex == index; } );  //_threads.Find(t => t.threadIndex == index);
	}

	//

	private var callStack(get, null):Array<Element>; // List<Element>
	function get_callStack():Array<Element> 
	{
		return currentThread.callstack;
	}

	var _threads:List<Thread>;
	var  _threadCounter:Int;

	

	
	

	
	
}

class Element
{
	 public var currentContainer:Container;
	 public var currentContentIndex:Int;

	public var inExpressionEvaluation:Bool;
	public var temporaryVariables:Map<String, RObject>; 
	public var type:PushPopType;
	
	public var currentObject(get, set):RObject;
	function get_currentObject():RObject 
	{
		 if (currentContainer != null && currentContentIndex < currentContainer.content.length) {
			// trace("Returning:"+currentContainer.content[currentContentIndex].path + ", at:"+currentContainer.name);
			return currentContainer.content[currentContentIndex];
		}
		//trace("Returning null..");
		return null;
	}
	function set_currentObject(value:RObject):RObject 
	{
		 var currentObj = value;
		if (currentObj == null) {
			currentContainer = null;
			currentContentIndex = 0;
			return null;  
		}

		currentContainer = LibUtil.as( currentObj.parent, Container);
		if (currentContainer != null) {
			currentContentIndex = currentContainer.content.indexOf(currentObj);
		}
		// Two reasons why the above operation might not work:
		//  - currentObj is already the root container
		//  - currentObj is a named container rather than being an object at an index
		if (currentContainer == null || currentContentIndex == -1) {
			currentContainer = LibUtil.as( currentObj, Container);
			currentContentIndex = 0;
			
		}
		return currentContainer.content[currentContentIndex];
	}
	
	 public function new( type:PushPopType,  container:Container,  contentIndex:Int,  inExpressionEvaluation:Bool = false) {
		this.currentContainer = container;
		this.currentContentIndex = contentIndex;
		this.inExpressionEvaluation = inExpressionEvaluation;
		this.temporaryVariables = new Map<String, RObject>();
		this.type = type;
	}


	 public function Copy():Element
	{
		var copy = new Element (this.type, this.currentContainer, this.currentContentIndex, this.inExpressionEvaluation);
			
		// TOCHECK: hopefully, this method works
		//var cloner:Cloner = new Cloner();
		var clone = LibUtil.cloneStrMap(temporaryVariables); //cloner.clone(this.temporaryVariables);
		copy.temporaryVariables = clone; //this.temporaryVariables
		return copy;
		
	}
		
	
	
}


	
class Thread
{

	public var callstack:Array<Element>; // Array<Element>; //List<Element>   
	public var  threadIndex:Int;
	public var previousContentObject:RObject;

	public function new() {
		callstack = new Array<Element>();
	}
	
	public static function create(jThreadObj:Dynamic, storyContext:Story) {
		var me:Thread = new Thread();
		me.setup(jThreadObj, storyContext);
		return me;
	}

	  function setup(jThreadObj:Dynamic, storyContext:Story):Void {  //: this()
		
		threadIndex = Std.int(Reflect.field( jThreadObj, "threadIndex"));

		var jThreadCallstack:Array<Dynamic> = Reflect.field(jThreadObj,"callstack");
		for (i in 0...jThreadCallstack.length) {
			var jElTok:Dynamic = jThreadCallstack[i];
			var jElementObj:Dynamic =jElTok;  // (Dictionary<string, object>)

			var pushPopType:PushPopType = Reflect.field(jElementObj, "type");  //(PushPopType)(int) jElementObj ["type"]

			var currentContainer:Container = null;
			var contentIndex:Int = 0;

			var currentContainerPathStr:String = null;
			var currentContainerPathStrToken:Dynamic;
			currentContainerPathStrToken = LibUtil.tryGetValueDynamic(jElementObj, "cPath");   //jElementObj.TryGetValue ("cPath", out currentContainerPathStrToken)
			if (currentContainerPathStrToken!=null) {
				currentContainerPathStr = Std.string(currentContainerPathStrToken);// .ToString ();
				currentContainer =LibUtil.asNoInline( storyContext.ContentAtPath(  Path.createFromString(currentContainerPathStr) ), Container );
				contentIndex = Std.int(Reflect.field(jElementObj, "idx"));
			}

			var inExpressionEvaluation:Bool = Reflect.field(jElementObj,"exp");

			var el = new Element (pushPopType, currentContainer, contentIndex, inExpressionEvaluation);

			var jObjTemps = Reflect.field(jElementObj, "temp");  // (Dictionary<string, object>)
			el.temporaryVariables = Json.JObjectToDictionaryRuntimeObjs (jObjTemps);

			callstack.push(el);
		}

		var prevContentObjPath:Dynamic;
		prevContentObjPath = LibUtil.tryGetValueDynamic(jThreadObj,"previousContentObject");  //jThreadObj.TryGetValue("previousContentObject", out prevContentObjPath)
		if( prevContentObjPath!=null ) {
			var prevPath =  Path.createFromString(Std.string(prevContentObjPath));
			previousContentObject = storyContext.ContentAtPath(prevPath);
		}
	}

	public function Copy():Thread {
		var copy = new Thread ();
		copy.threadIndex = threadIndex;
		for(i in 0...callstack.length) {
			var e = callstack[i];
			copy.callstack.push(e.Copy());
		}
		copy.previousContentObject = previousContentObject;
		return copy;
	}


	public var jsonToken(get, null):Dynamic;

	function get_jsonToken():Dynamic 
	{
		var threadJObj = {}; // new Dictionary<string, object> ();

		var jThreadCallstack = []; // new List<object> ();
		for ( i in 0...callstack.length) {
			var el:Element = callstack[i];
			var jObj = {}; // new Dictionary<string, object> ();
			if (el.currentContainer!=null) {
				Reflect.setField(jObj, "cPath",  el.currentContainer.path.componentsString); //jObj ["cPath"] = el.currentContainer.path.componentsString;
				Reflect.setField(jObj, "idx",  el.currentContentIndex);  // jObj ["idx"] = el.currentContentIndex;
			}
		
			Reflect.setField(jObj, "exp", el.inExpressionEvaluation); //jObj ["exp"] = el.inExpressionEvaluation;
			Reflect.setField(jObj, "type", el.type); //jObj ["type"] = (int) el.type;
			Reflect.setField(jObj, "temp", Json.DictionaryRuntimeObjsToJObject (el.temporaryVariables)); //jObj ["temp"] = Json.DictionaryRuntimeObjsToJObject (el.temporaryVariables);
			jThreadCallstack.push(jObj);
		}

		Reflect.setField(threadJObj, "callstack", jThreadCallstack); // threadJObj ["callstack"] = jThreadCallstack;
		Reflect.setField(threadJObj, "threadIndex", threadIndex);  //threadJObj ["threadIndex"] = threadIndex;

		if (previousContentObject != null)
			Reflect.setField(threadJObj, "previousContentObject", Std.string(previousContentObject.path));  //threadJObj ["previousContentObject"] = previousContentObject.path.ToString();

		return threadJObj;
	}
	
	
}