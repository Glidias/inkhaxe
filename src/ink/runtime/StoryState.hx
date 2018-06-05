package ink.runtime;
import ink.random.ParkMiller;
import ink.runtime.CallStack.Thread;
import ink.runtime.Container;
import ink.runtime.Value.StringValue;

/**
 * Done!
 * @author Glidias
 */
 /// <summary>
/// All story state information is included in the StoryState class,
/// including global variables, read counts, the pointer to the current
/// point in the story, the call stack (for tunnels, functions, etc),
/// and a few other smaller bits and pieces. You can save the current
/// state using the json serialisation functions ToJson and LoadJson.
/// </summary>
class StoryState
{
  /// <summary>
	/// The current version of the state save file JSON-based format.
	/// </summary>
	public static inline var kInkSaveStateVersion:Int = 4;
	static var kMinCompatibleLoadVersion:Int = 4;
	
	/// <summary>
	/// Exports the current state to json format, in order to save the game.
	/// </summary>
	/// <returns>The save state in json format.</returns>
	 public function ToJson():String {
        return haxe.Json.stringify(jsonToken); //SimpleJson.DictionaryToText (jsonToken);
    }
	
	/// <summary>
	/// Loads a previously saved state in JSON format.
	/// </summary>
	/// <param name="json">The JSON string to load.</param>
	public function LoadJson( json:String):Void
	{
		jsonToken = haxe.Json.parse(json );  //SimpleJson.TextToDictionary (json);
	}
	
	
	/// <summary>
	/// Gets the visit/read count of a particular Container at the given path.
	/// For a knot or stitch, that path string will be in the form:
	/// 
	///     knot
	///     knot.stitch
	/// 
	/// </summary>
	/// <returns>The number of times the specific knot or stitch has
	/// been enountered by the ink engine.</returns>
	/// <param name="pathString">The dot-separated path string of
	/// the specific knot or stitch.</param>
	public function VisitCountAtPathString( pathString:String):Int
	{
		var visitCountOut = visitCounts.get(pathString);  // tocheck:, StringMap for int... does return null for Flash target
		if ( LibUtil.validInt(visitCountOut)  ) //visitCounts.TryGetValue (pathString, out visitCountOut))  //visitCountOut != null
			return visitCountOut;

		return 0;
	}
	
	// REMEMBER! REMEMBER! REMEMBER!
	// When adding state, update the Copy method, and serialisation.
	// REMEMBER! REMEMBER! REMEMBER!

	public var  outputStream(get, null):Array<RObject>; //{ get { } }
	function get_outputStream():Array<RObject> 
	{
		 return _outputStream;
	}
	
	public var currentChoices: List<Choice>; //{ get; private set; }
	public var  currentErrors:List<String>; //{ get; private set; }
	public var  variablesState:VariablesState; //{ get; private set; }
	public var  callStack:CallStack; //{ get; set; }
	public var  evaluationStack:Array<RObject>; // List<Object>; //{ get; private set; }
	public var  divertedTargetObject:RObject;// { get; set; }
	public var visitCounts:Map<String, Int>;  //{ get; private set; }
	public var turnIndices:Map<String, Int>;// { get; private set; }
	public var  currentTurnIndex:Int; // { get; private set; }
	public var  storySeed:Int;  //{ get; private set; }
	public var  didSafeExit:Bool;// { get; set; }
	
	public var story:Story;// { get; set; }
	
	public var  currentPath(get, set):Path;
	function get_currentPath():Path 
	{
		if (currentContentObject == null)
			return null;

	
		return currentContentObject.path;
	}
	function set_currentPath(value:Path):Path 
	{
		if (value != null)
			currentContentObject = story.ContentAtPath (value);
		else
			currentContentObject = null;
		return currentContentObject != null ? currentContentObject.path : null;
	}
	
	public var  currentContentObject(get, set):RObject;
	function get_currentContentObject():RObject 
	{
			return callStack.currentElement.currentObject;
	}
	function set_currentContentObject(value:RObject):RObject 
	{
		callStack.currentElement.currentObject = value;
		return value;
	}
	
	
	public var  currentContainer(get, null):Container;
	function get_currentContainer():Container 
	{
	   return callStack.currentElement.currentContainer;
	}

	
	public var previousContentObject(get, set):RObject;
	function get_previousContentObject():RObject {
		return callStack.currentThread.previousContentObject;
	}
	function set_previousContentObject(value:RObject):RObject {
		callStack.currentThread.previousContentObject = value;
		return value;
	}
	
		
	public var  hasError(get, null):Bool;
	function get_hasError():Bool {
		return currentErrors != null && currentErrors.length > 0;
	}
	

	public var  currentText(get, null ):String;
	function get_currentText():String {
		var sb = new StringBuf ();

		for ( outputObj in _outputStream) {
			var textContent = LibUtil.as( outputObj , StringValue);
			if (textContent != null) {
				sb.add(textContent.value);
			}
		}

		return sb.toString ();
	}
	

	public var  inExpressionEvaluation(get, set):Bool;
	function get_inExpressionEvaluation():Bool {
		return callStack.currentElement.inExpressionEvaluation;
	}
	function set_inExpressionEvaluation(value:Bool):Bool {
		callStack.currentElement.inExpressionEvaluation = value;
		return value;
	}
	
	

	
	public function new(story:Story) 
	{
		 this.story = story;

		_outputStream = new Array<RObject> ();

		evaluationStack = new Array<RObject> ();

		callStack =  CallStack.createCallStack(story.rootContentContainer);
		variablesState = new VariablesState (callStack);
	

		visitCounts = new Map<String, Int> ();
		turnIndices = new Map<String, Int> ();
		currentTurnIndex = -1;

		// Seed the shuffle random numbers
		var timeSeed:Int = Std.int( Date.now().getTime() ); // DateTime.Now.Millisecond;
		storySeed = Std.int(new ParkMiller(timeSeed).random())  % 100;// (new Random (timeSeed)).Next () % 100;

		currentChoices = new List<Choice> ();

		GoToStart();
	}
	
	function GoToStart(){
		this.callStack.currentElement.currentContainer = this.story.mainContentContainer;
        this.callStack.currentElement.currentContentIndex = 0;
	}
	
	// Warning: Any Runtime.Object content referenced within the StoryState will
	// be re-referenced rather than cloned. This is generally okay though since
	// Runtime.Objects are treated as immutable after they've been set up.
	// (e.g. we don't edit a Runtime.Text after it's been created an added.)
	// I wonder if there's a sensible way to enforce that..??
	public function Copy():StoryState
	{
		var copy = new StoryState(story);
		
		LibUtil.addRangeForArray(copy.outputStream, _outputStream); //copy.outputStream.AddRange(_outputStream);
		LibUtil.addRangeForList(copy.currentChoices, currentChoices); //copy.currentChoices.AddRange(currentChoices);

		if (hasError) {
			copy.currentErrors = new List<String> ();
			LibUtil.addRangeForList(copy.currentErrors, currentErrors); // copy.currentErrors.AddRange (currentErrors); 
		}
		
		copy.callStack =  CallStack.createCallStack2 (callStack);

		copy._currentRightGlue = _currentRightGlue;

		copy.variablesState = new VariablesState (copy.callStack);
		

		copy.variablesState.CopyFrom (variablesState);

		LibUtil.addRangeForArray(copy.evaluationStack, evaluationStack); // copy.evaluationStack.AddRange (evaluationStack);

		if (divertedTargetObject != null)
			copy.divertedTargetObject = divertedTargetObject;

		copy.previousContentObject = previousContentObject;

		//var cloner:Cloner = new Cloner();
		copy.visitCounts = LibUtil.cloneStrIntMap(visitCounts); //cloner.clone(visitCounts );
		
		copy.turnIndices = LibUtil.cloneStrIntMap(turnIndices); //cloner.clone( turnIndices);
	
		copy.currentTurnIndex = currentTurnIndex;
		copy.storySeed = storySeed;

		copy.didSafeExit = didSafeExit;

		return copy;
	}

	/// <summary>
	/// Object representation of full JSON state. Usually you should use
	/// LoadJson and ToJson since they serialise directly to string for you.
	/// But it may be useful to get the object representation so that you
	//// can integrate it into your own serialisation system.
	/// </summary>
	 var jsonToken(get, set):Dynamic; // Dictionary<string, object> 
	function get_jsonToken():Dynamic 
	{
		var obj = {};// new Dictionary<string, object> ();

			var choiceThreads:Map<String, Dynamic>  = null;
			for ( c in currentChoices) {
				c.originalChoicePath = c.choicePoint.path.componentsString;
				c.originalThreadIndex = c.threadAtGeneration.threadIndex;

				if( callStack.ThreadWithIndex(c.originalThreadIndex) == null ) {
					if( choiceThreads == null )
						choiceThreads = new Map<String, Dynamic>();

					choiceThreads[Std.string(c.originalThreadIndex)] = c.threadAtGeneration.jsonToken;
				}
			}
			if( choiceThreads != null )
				Reflect.setField(obj, "choiceThreads", choiceThreads); // obj["choiceThreads"] = choiceThreads;

			
			Reflect.setField(obj, "callstackThreads", callStack.GetJsonToken());
			Reflect.setField(obj, "variablesState" ,variablesState.jsonToken);

			Reflect.setField(obj, "evalStack" ,Json.ArrayToJArray (evaluationStack));

			Reflect.setField(obj, "outputStream", Json.ArrayToJArray (_outputStream));

			Reflect.setField(obj, "currentChoices", Json.ListToJArray (currentChoices));

			if (_currentRightGlue!=null) {
				
				var rightGluePos:Int = _outputStream.indexOf(_currentRightGlue); 
				if( rightGluePos != -1 ) {
					Reflect.setField(obj, "currRightGlue", rightGluePos);// = _outputStream.IndexOf (_currentRightGlue);
				}
			}

			if( divertedTargetObject != null )
				Reflect.setField(obj,"currentDivertTarget",  divertedTargetObject.path.componentsString);

			Reflect.setField(obj,"visitCounts", Json.IntDictionaryToJObject (visitCounts));
			Reflect.setField(obj,"turnIndices", Json.IntDictionaryToJObject (turnIndices));
			Reflect.setField(obj,"turnIdx", currentTurnIndex);
			Reflect.setField(obj,"storySeed", storySeed);

			Reflect.setField(obj,"inkSaveVersion", kInkSaveStateVersion);

			// Not using this right now, but could do in future.
			Reflect.setField(obj,"inkFormatVersion", Story.inkVersionCurrent);

			return obj;
	}
	
	function set_jsonToken(value:Dynamic):Dynamic 
	{
		var jObject = value;

		var jSaveVersion:Dynamic = null;
		jSaveVersion = LibUtil.tryGetValueDynamic(jObject, "inkSaveVersion"); 
		if (jSaveVersion == null) {   //!jObject.TryGetValue("inkSaveVersion", out jSaveVersion)
			throw new StoryException ("ink save format incorrect, can't load.");
		}
		else if ( Std.int(jSaveVersion) < kMinCompatibleLoadVersion) {
			throw new StoryException("Ink save format isn't compatible with the current version (saw '"+jSaveVersion+"', but minimum is "+kMinCompatibleLoadVersion+"), so can't load.");
		}

		callStack.SetJsonToken( Reflect.field(jObject, "callstackThreads"), story);  // ((Dictionary < string, object > )j
		
		
	
		variablesState.jsonToken = Reflect.field(jObject, "variablesState");  //(Dictionary < string, object> )

		evaluationStack = Json.JArrayToRuntimeObjArray( Reflect.field(jObject,"evalStack"));  //((List<object>)

		_outputStream = Json.JArrayToRuntimeObjArray( Reflect.field(jObject,"outputStream"));  //((List<object>)

		// tocheck: this cast should hopefully not yield problems on all targets..
		currentChoices = cast Json.JArrayToRuntimeObjList( Reflect.field(jObject,"currentChoices"));  //<Choice>((List<object>)

		var propValue:Dynamic;
		propValue = LibUtil.tryGetValueDynamic(jObject, "currRightGlue");
		if( propValue!=null ) {
			var gluePos:Int = Std.int(propValue);  //int
			if( gluePos >= 0 ) {
				_currentRightGlue = LibUtil.as( LibUtil.getArrayItemAtIndex(_outputStream, gluePos), Glue);  //_outputStream[gluePos]
			}
		}

		var currentDivertTargetPath:Dynamic;
		currentDivertTargetPath = LibUtil.tryGetValueDynamic(jObject, "currRightGlue");
		if (currentDivertTargetPath!=null) {  //jObject.TryGetValue("currentDivertTarget", out currentDivertTargetPath)
			var divertPath =  Path.createFromString( Std.string(currentDivertTargetPath) );
			divertedTargetObject = story.ContentAtPath (divertPath);
		}
			
		visitCounts = Json.JObjectToIntDictionary ( Reflect.field(jObject,"visitCounts"));  //(Dictionary<string, object>)
		turnIndices = Json.JObjectToIntDictionary (Reflect.field(jObject,"turnIndices"));  //(Dictionary<string, object>)
		currentTurnIndex = Std.int( Reflect.field(jObject,"turnIdx"));  //(int)
		storySeed = Std.int( Reflect.field(jObject,"storySeed"));  //(int)

		var jChoiceThreadsObj:Dynamic = null;
		jChoiceThreadsObj = Reflect.field(jObject, "choiceThreads");  //jObject.TryGetValue("choiceThreads", out jChoiceThreadsObj);
		var jChoiceThreads:Dynamic =  jChoiceThreadsObj;  //(Dictionary<string, object>)

		for ( c in currentChoices) {
			c.choicePoint =  cast story.ContentAtPath( Path.createFromString (c.originalChoicePath)); //(ChoicePoint)

			var foundActiveThread = callStack.ThreadWithIndex(c.originalThreadIndex);
			if( foundActiveThread != null ) {
				c.threadAtGeneration = foundActiveThread;
			} else {
				var jSavedChoiceThread = Reflect.field( jChoiceThreads, Std.string(c.originalThreadIndex) );  // (Dictionary <string, object>)
				c.threadAtGeneration =  Thread.create(jSavedChoiceThread, story);
			}
		}
		
		return value;
	}
	

	public function ResetErrors():Void
	{
		currentErrors = null;
	}
		
	public function ResetOutput():Void
	{
		LibUtil.clearArray(_outputStream); // _outputStream.clear();
	}
	
	// Push to output stream, but split out newlines in text for consistency
	// in dealing with them later.
	public function PushToOutputStream( obj:RObject):Void
	{
		var text = LibUtil.as(obj, StringValue);
		if (text!=null) {
			var listText = TrySplittingHeadTailWhitespace (text);
			if (listText != null) {
				for ( textObj in listText) {
					PushToOutputStreamIndividual (textObj);
				}
				return;
			}
		}

		PushToOutputStreamIndividual (obj);
	}
	
	// At both the start and the end of the string, split out the new lines like so:
	//
	//  "   \n  \n     \n  the string \n is awesome \n     \n     "
	//      ^-----------^                           ^-------^
	// 
	// Excess newlines are converted into single newlines, and spaces discarded.
	// Outside spaces are significant and retained. "Interior" newlines within 
	// the main string are ignored, since this is for the purpose of gluing only.
	//
	//  - If no splitting is necessary, null is returned.
	//  - A newline on its own is returned in an list for consistency.
	function TrySplittingHeadTailWhitespace( single:StringValue):List<StringValue> 
	{
		var str:String = single.value;

		var headFirstNewlineIdx:Int = -1;
		var headLastNewlineIdx:Int = -1;
		for (i in 0...str.length) { //int i = 0; i < str.Length; ++i
			var c:String = str.charAt(i); // [i];
			if (c == '\n') {
				if (headFirstNewlineIdx == -1)
					headFirstNewlineIdx = i;
				headLastNewlineIdx = i;
			}
			else if (c == ' ' || c == '\t')
				continue;
			else
				break;
		}

		var tailLastNewlineIdx:Int = -1;
		var tailFirstNewlineIdx:Int = -1;
		for (i in 0...str.length) { //int i = 0; i < str.Length; ++i
			var c = str.charAt(i);// [i]; 
			if (c == '\n') {
				if (tailLastNewlineIdx == -1)
					tailLastNewlineIdx = i;
				tailFirstNewlineIdx = i;
			}
			else if (c == ' ' || c == '\t')
				continue;
			else
				break;
		}

		// No splitting to be done?
		if (headFirstNewlineIdx == -1 && tailLastNewlineIdx == -1)
			return null;
			
		var listTexts = new List<StringValue> ();
		var innerStrStart = 0;
		var innerStrEnd = str.length;

		if (headFirstNewlineIdx != -1) {
			if (headFirstNewlineIdx > 0) {
				var leadingSpaces = new StringValue (str.substring (0, headFirstNewlineIdx));
				listTexts.add(leadingSpaces);
			}
			listTexts.add (new StringValue ("\n"));
			innerStrStart = headLastNewlineIdx + 1;
		}

		if (tailLastNewlineIdx != -1) {
			innerStrEnd = tailFirstNewlineIdx;
		}

		if (innerStrEnd > innerStrStart) {
			var innerStrText = str.substring (innerStrStart, innerStrEnd - innerStrStart);
			listTexts.add(new StringValue (innerStrText));
		}

		if (tailLastNewlineIdx != -1 && tailFirstNewlineIdx > headLastNewlineIdx) {
			listTexts.add (new StringValue ("\n"));
			if (tailLastNewlineIdx < str.length - 1) {
				var numSpaces:Int = (str.length - tailLastNewlineIdx) - 1;
				var trailingSpaces = new StringValue (str.substring (tailLastNewlineIdx + 1, numSpaces));
				listTexts.add(trailingSpaces);
			}
		}

		return listTexts;
	}

	
	function PushToOutputStreamIndividual( obj:RObject):Void
	{
		var glue = LibUtil.as(obj, Glue);
		var text = LibUtil.as(obj, StringValue);

		var includeInOutput = true;

		if (glue!=null) {
			
			// Found matching left-glue for right-glue? Close it.
			var foundMatchingLeftGlue = glue.isLeft && _currentRightGlue!= null && glue.parent == _currentRightGlue.parent;
			if (foundMatchingLeftGlue) {
				_currentRightGlue = null;
			}

			// Left/Right glue is auto-generated for inline expressions 
			// where we want to absorb newlines but only in a certain direction.
			// "Bi" glue is written by the user in their ink with <>
			if (glue.isLeft || glue.isBi) {
				TrimNewlinesFromOutputStream(foundMatchingLeftGlue); //stopAndRemoveRightGlue:
			}

			// New right-glue
			var isNewRightGlue = glue.isRight && _currentRightGlue == null;
			if (isNewRightGlue) {
				_currentRightGlue = glue;
			}

			includeInOutput = glue.isBi || isNewRightGlue;
		}

		else if( text!=null ) {

			if (currentGlueIndex != -1) {

				// Absorb any new newlines if there's existing glue
				// in the output stream.
				// Also trim any extra whitespace (spaces/tabs) if so.
				if (text.isNewline) {
					TrimFromExistingGlue ();
					includeInOutput = false;
				} 

				// Able to completely reset when 
				else if (text.isNonWhitespace) {
					RemoveExistingGlue ();
					_currentRightGlue = null;
				}
			} else if (text.isNewline) {
				if (outputStreamEndsInNewline || !outputStreamContainsContent)
					includeInOutput = false;
			}
		}

		if (includeInOutput) {
			_outputStream.push (obj);
		}
	}

	
	function TrimNewlinesFromOutputStream( stopAndRemoveRightGlue:Bool):Void
	{
		var removeWhitespaceFrom = -1;
		var rightGluePos = -1;
		var foundNonWhitespace = false;

		// Work back from the end, and try to find the point where
		// we need to start removing content. There are two ways:
		//  - Start from the matching right-glue (because we just saw a left-glue)
		//  - Simply work backwards to find the first newline in a string of whitespace
		var i = _outputStream.length-1;
		while (i >= 0) {
			var obj = LibUtil.getArrayItemAtIndex(_outputStream, i);// _outputStream [i];
			var cmd = LibUtil.as(obj , ControlCommand);
			var txt = LibUtil.as(obj , StringValue);
			var glue = LibUtil.as(obj , Glue);

			if (cmd!=null || (txt!=null && txt.isNonWhitespace)) {
				foundNonWhitespace = true;
				if( !stopAndRemoveRightGlue )
					break;
			} else if (stopAndRemoveRightGlue && glue!=null && glue.isRight) {
				rightGluePos = i;
				break;
			} else if (txt!=null && txt.isNewline && !foundNonWhitespace) {
				removeWhitespaceFrom = i;
			}
			i--;
		}

		// Remove the whitespace
		if (removeWhitespaceFrom >= 0) {
			i=removeWhitespaceFrom;
			while(i < _outputStream.length) {
				var text = LibUtil.as(LibUtil.getArrayItemAtIndex(_outputStream,i) , StringValue);
				if (text!=null) {
					LibUtil.removeArrayItemAtIndex(_outputStream, i); //_outputStream.remove(i);
				} else {
					i++;
				}
			}
		}

		// Remove the glue (it will come before the whitespace,
		// so index is still valid)
		if (stopAndRemoveRightGlue && rightGluePos > -1)
			LibUtil.removeArrayItemAtIndex(outputStream, rightGluePos);// _outputStream.RemoveAt (rightGluePos);
	}

	function TrimFromExistingGlue():Void
	{
		var i = currentGlueIndex;
		while (i < _outputStream.length) {
			var txt =  LibUtil.as( LibUtil.getArrayItemAtIndex(_outputStream, i) , StringValue); // _outputStream [i] 
			if (txt!=null && !txt.isNonWhitespace)
				LibUtil.removeArrayItemAtIndex(_outputStream, i); // _outputStream.RemoveAt (i);
			else
				i++;
		}
	}


	// Only called when non-whitespace is appended
	function RemoveExistingGlue()
	{
		//int i = _outputStream.Count - 1; i >= 0; i--
		var i = outputStream.length;
		
		while (i>=0) {
			var c = _outputStream [i];
			if (Std.is(c , Glue)) {
				LibUtil.removeArrayItemAtIndex(outputStream, i);// _outputStream.RemoveAt (i);
			} else if( Std.is(c, ControlCommand) ) { // e.g. BeginString
				break;
			}
			i--; // continuing...
		}
	}
	
	
	

	var currentGlueIndex(get, null):Int;
	function get_currentGlueIndex():Int 
	{
		//int i = _outputStream.Count - 1; i >= 0; i--
			var i = _outputStream.length - 1;
			while (i >= 0) {
				var c = LibUtil.getArrayItemAtIndex(_outputStream, i); // _outputStream [i];
				var glue = LibUtil.as(c , Glue);
				if (glue!=null) {
					return i;
				}
				else if (Std.is(c, ControlCommand)) // e.g. BeginString
					break;
				i--; // continuing...
			}
			return -1;
			
	}
	
	
	public var  outputStreamEndsInNewline(get, null):Bool;
	function get_outputStreamEndsInNewline():Bool {
		if (_outputStream.length > 0) {
			//int i = _outputStream.Count - 1; i >= 0; i--
			var i:Int = _outputStream.length - 1;
			while (i>=0) {
				var obj = _outputStream [i];
				if (Std.is(obj,ControlCommand)) // e.g. BeginString
					break;
				var text = LibUtil.as(_outputStream [i], StringValue);
				if (text!=null) {
					if (text.isNewline)
						return true;
					else if (text.isNonWhitespace)
						break;
				}
				i--; // continuing...
			}
		}

		return false;
	}
	

	var  outputStreamContainsContent(get, null):Bool;
	function get_outputStreamContainsContent():Bool {
		for ( content in _outputStream) {
			if (Std.is(content, StringValue))
				return true;
		}
		return false;
	}


	public var  inStringEvaluation(get, null):Bool; 
	function get_inStringEvaluation():Bool {
		
		//int i = _outputStream.Count - 1; i >= 0; i--
		var i:Int = _outputStream.length - 1;
		while (i>=0) {
			var cmd = LibUtil.as(_outputStream [i] , ControlCommand);
			if (cmd!=null && cmd.commandType == ControlCommand.CommandType.BeginString) {
				return true;
			}
			i--;  // continuing
		}

		return false;
	}
	

	public function  PushEvaluationStack(obj:RObject):Void
	{
		evaluationStack.push(obj);
	}

	public function  PopEvaluationStack():RObject
	{
		//var obj =  evaluationStack [evaluationStack.length - 1];
		//evaluationStack.pop(); // evaluationStack.RemoveAt (evaluationStack.length - 1);
		//return obj;
		
		return evaluationStack.pop();
	}

	public function PeekEvaluationStack():RObject
	{
		return evaluationStack [evaluationStack.length - 1];
	}

	public function PopEvaluationStack1( numberOfObjects:Int):Array<RObject> //List<Object>
	{
		if(numberOfObjects > evaluationStack.length) {
			throw new SystemException ("trying to pop too many objects");
		}

		var popped = evaluationStack.slice(evaluationStack.length - numberOfObjects, evaluationStack.length - numberOfObjects+ numberOfObjects); // evaluationStack.GetRange(evaluationStack.length - numberOfObjects, numberOfObjects);
		evaluationStack.splice(evaluationStack.length - numberOfObjects, numberOfObjects); //evaluationStack.RemoveRange (evaluationStack.length - numberOfObjects, numberOfObjects);
		return popped;
	}


	public function ForceEndFlow():Void
	{
		currentContentObject = null;

		while (callStack.canPopThread)
			callStack.PopThread ();

		while (callStack.canPop)
			callStack.Pop ();

		currentChoices.clear ();

		didSafeExit = true;
	}

	// Don't make public since the method need to be wrapped in Story for visit counting
	public function  SetChosenPath( path:Path):Void
	{
		// Changing direction, assume we need to clear current set of choices
		currentChoices.clear();

		currentPath = path;

		currentTurnIndex++;
	}

	public function AddError( message:String):Void
	{
		// TODO: Could just add to output?
		if (currentErrors == null) {
			currentErrors = new List<String> ();
		}

		currentErrors.add (message);
	}
	
		
	// REMEMBER! REMEMBER! REMEMBER!
	// When adding state, update the Copy method and serialisation
	// REMEMBER! REMEMBER! REMEMBER!
		
	var _outputStream:Array<RObject>;  // formerly list. consider: after everything's done. de.polydonal.ds List implementation
	var _currentRightGlue:Glue;
	
}