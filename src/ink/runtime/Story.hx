package ink.runtime;
import haxe.ds.EnumValueMap;
import haxe.ds.GenericStack;
import haxe.ds.IntMap;
import haxe.ds.StringMap;
import ink.random.ParkMiller;
import ink.runtime.Container;
import ink.runtime.Value.DivertTargetValue;
import ink.runtime.Value.IntValue;
import ink.runtime.Value.StringValue;
import ink.runtime.Value.VariablePointerValue;

/**
 * done.. except for external functions support.
 * Time to test it...
 * 
 * @author Glidias
 */

//public delegate object ExternalFunction(object[] args);
typedef ExternalFunction = Array<Dynamic>->Dynamic;	

// public delegate void VariableObserver(string variableName, object newValue);
typedef VariableObserver = String->Dynamic->Void;

@:expose
class Story extends Object
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
		super();
		setupFromContainer(null);
		
		var rootObject:StringMap<Dynamic> = LibUtil.jTokenToStringMap( haxe.Json.parse(jsonString) ); // SimpleJson.TextToDictionary(jsonString);
		
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

		//var rootObject = new Map<String, Dynamic>();
	//	rootObject.set ("inkVersion", inkVersionCurrent);
		//rootObject.set ("root", rootContainerJsonList);
		//SimpleJson.DictionaryToText(rootObject);   //
		
		return  haxe.Json.stringify({ inkVersion:inkVersionCurrent, root:rootContainerJsonList});
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

		   if (_mainContentContainer.namedContent.exists ("global decl")) {
			   
			var originalPath = state.currentPath;

			ChoosePathString ("global decl");

			// Continue, but without validating external bindings,
			// since we may be doing this reset at initialisation time.
			ContinueInternal ();

			state.currentPath = originalPath;
					
		}
	
	}

    public  function BuildStringOfHierarchy():String //virtual
	{
		var sb = new StringBuf ();

		mainContentContainer.BuildStringOfHierarchy (sb, 0, state.currentContentObject);

		return sb.toString ();
	}

		private function NextContent():Void
		{
            // Setting previousContentObject is critical for VisitChangedContainersDueToDivert
            state.previousContentObject = state.currentContentObject;

			// Divert step?
			if (state.divertedTargetObject != null) {

                state.currentContentObject = state.divertedTargetObject;
                state.divertedTargetObject = null;

                // Internally uses state.previousContentObject and state.currentContentObject
                VisitChangedContainersDueToDivert ();

                // Diverted location has valid content?
                if (state.currentContentObject != null) {
				
					trace("Divert location:"+state.currentContentObject.path.componentsString  + "  ::  "+ (state.previousContentObject!= null ? state.previousContentObject.path.componentsString : "No previousContentObject ..") );
                    return;
                }
				
				
                // Otherwise, if diverted location doesn't have valid content,
                // drop down and attempt to increment.
                // This can happen if the diverted path is intentionally jumping
                // to the end of a container - e.g. a Conditional that's re-joining
			}
			
			

            var successfulPointerIncrement:Bool = IncrementContentPointer ();
		

            // Ran out of content? Try to auto-exit from a function,
            // or finish evaluating the content of a thread
            if (!successfulPointerIncrement) {

                var didPop = false;

                if (state.callStack.CanPop (PushPopType.Function)) {
                    
                    // Pop from the call stack
                    state.callStack.Pop (PushPopType.Function);

                    // This pop was due to dropping off the end of a function that didn't return anything,
                    // so in this case, we make sure that the evaluator has something to chomp on if it needs it
                    if (state.inExpressionEvaluation) {
                        state.PushEvaluationStack (new VoidObj());
                    }

                    didPop = true;
                } 

                else if (state.callStack.canPopThread) {
                    state.callStack.PopThread ();

                    didPop = true;
                }

                // Step past the point where we last called out
                if (didPop && state.currentContentObject != null) {
					
                    NextContent ();
                }
			}
			
			if (state.currentContentObject!= null) trace("location:"+state.currentContentObject.path.componentsString  + "  ::  "+ (state.previousContentObject!= null ? state.previousContentObject.path.componentsString : "No previousContentObject ..") );
				
		}

        function IncrementContentPointer():Bool
        {
            var successfulIncrement = true;

            var currEl = state.callStack.currentElement;
            currEl.currentContentIndex++;

            // Each time we step off the end, we fall out to the next container, all the
            // while we're in indexed rather than named content
            while (currEl.currentContentIndex >= currEl.currentContainer.content.length) {

                successfulIncrement = false;

                var nextAncestor = LibUtil.as(currEl.currentContainer.parent , Container);
                if (!(nextAncestor!=null)) {
                    break;
                }

                var indexInAncestor = nextAncestor.content.indexOf (currEl.currentContainer);
                if (indexInAncestor == -1) {
                    break;
                }

                currEl.currentContainer = nextAncestor;
                currEl.currentContentIndex = indexInAncestor + 1;

                successfulIncrement = true;
            }
			
			
		
            if (!successfulIncrement)
                currEl.currentContainer = null;

            return successfulIncrement;
        }
            
        function TryFollowDefaultInvisibleChoice():Bool
        {
            var allChoices = _state.currentChoices;

            // Is a default invisible choice the ONLY choice?
            var invisibleChoices = allChoices.filter( function(c) { return c.choicePoint.isInvisibleDefault; } );  // Where (c => c.choicePoint.isInvisibleDefault).ToList();
            if (invisibleChoices.length == 0 || allChoices.length > invisibleChoices.length)
                return false;

            var choice = invisibleChoices.first(); // [0];

            ChoosePath (choice.choicePoint.choiceTarget.path);

            return true;
        }
            
        function VisitCountForContainer( container:Container):Int
        {
            if( !container.visitsShouldBeCounted ) {
                Error ("Read count for target ("+container.name+" - on "+container.debugMetadata+") unknown. The story may need to be compiled with countAllVisits flag (-c).");
                return 0;
            }

            var count:Int = 0;
            var containerPathStr = container.path.toString();
            var tryCount:Int = state.visitCounts.get(containerPathStr);  //TryGetValue (containerPathStr, out count);
			if (tryCount != null && !Math.isNaN(tryCount)) {
				count = tryCount;
			}
            return count;
        }

        function IncrementVisitCountForContainer( container:Container):Void
        {
            var count = 0;
            var containerPathStr = container.path.toString();
			 var tryCount:Int = state.visitCounts.get(containerPathStr);  //TryGetValue (containerPathStr, out count);
			if (tryCount != null && !Math.isNaN(tryCount)) {
				count = tryCount;
			}
			count++;
			state.visitCounts.set(containerPathStr, count);// [containerPathStr] = count;

        }

        function RecordTurnIndexVisitToContainer( container:Container):Void
        {
            var containerPathStr = container.path.toString();
            state.turnIndices.set(containerPathStr, state.currentTurnIndex);
        }

        function TurnsSinceForContainer( container:Container):Int
        {
            if( !container.turnIndexShouldBeCounted ) {
                Error ("TURNS_SINCE() for target ("+container.name+" - on "+container.debugMetadata+") unknown. The story may need to be compiled with countAllVisits flag (-c).");
            }

            var index:Int = 0;
            var containerPathStr = container.path.toString();
			index = state.turnIndices.get(containerPathStr);  //state.turnIndices.TryGetValue (containerPathStr, out index)
            if (index != null && !Math.isNaN(index)) {
                return state.currentTurnIndex - index;
            } else {
                return -1;
            }
        }

        // Note that this is O(n), since it re-evaluates the shuffle indices
        // from a consistent seed each time.
        // TODO: Is this the best algorithm it can be?
        function NextSequenceShuffleIndex():Int
        {
            var numElementsIntVal =LibUtil.as( state.PopEvaluationStack () , IntValue);
            if (numElementsIntVal == null) {
                Error ("expected number of elements in sequence for shuffle index");
                return 0;
            }

            var seqContainer = state.currentContainer;

            var numElements:Int = numElementsIntVal.value;

            var seqCountVal = LibUtil.as(state.PopEvaluationStack () , IntValue);
            var seqCount = seqCountVal.value;
            var loopIndex:Int = Std.int( seqCount / numElements );  // added integer type for haxe, is this correct? tocheck..
            var iterationIndex = seqCount % numElements;

            // Generate the same shuffle based on:
            //  - The hash of this container, to make sure it's consistent
            //    each time the runtime returns to the sequence
            //  - How many times the runtime has looped around this full shuffle
            var seqPathStr = seqContainer.path.toString();
            var sequenceHash = 0;
	
            for ( c in seqPathStr.split("") ) {  //lazy method 
                var resultI:Int = Std.parseInt(c);
				
				// tocheck: is this correct as of js versinons? Or issit based off addition of digits?
				sequenceHash +=  resultI != null && !Math.isNaN(resultI) ? resultI :  0;  
				//sequenceHash += c;
            }
            var randomSeed = sequenceHash + loopIndex + state.storySeed;
            var random = new ParkMiller (randomSeed);

            var unpickedIndices = new Array<Int>(); // new List<Int>();
            for (i in 0...numElements) {  //int i = 0; i < numElements; ++i
                unpickedIndices.push (i);
            }

            for (i in 0...iterationIndex) {  //int i = 0; i <= iterationIndex; ++i
                var chosen = random.randomRange(0, unpickedIndices.length - 1); // random.Next () % unpickedIndices.Count;
                var chosenIndex = unpickedIndices [chosen];
                unpickedIndices.splice(chosen, 1);  //unpickedIndices.removeAt(chosen);

                if (i == iterationIndex) {
                    return chosenIndex;
                }
            }

            throw new SystemException ("Should never reach here");
        }

	
	// Throw an exception that gets caught and causes AddError to be called,
	// then exits the flow.
	function Error( message:String,  useEndLineNumber:Bool = false)
	{
		var e = new StoryException (message);
		e.useEndLineNumber = useEndLineNumber;
		throw e;
	}
	 
		
	
	function AddError ( message:String,  useEndLineNumber:Bool)
	{
		var dm = currentDebugMetadata;

		if (dm != null) {
			var lineNum:Int = useEndLineNumber ? dm.endLineNumber : dm.startLineNumber;
			message = "RUNTIME ERROR: '"+dm.fileName+"' line "+lineNum+": "+message;
		}
		else {
			message = "RUNTIME ERROR: " + message;
		}

		state.AddError (message);

		// In a broken state don't need to know about any other errors.
		state.ForceEndFlow ();
	}
	
	var currentDebugMetadata(get, null):DebugMetadata;
	function get_currentDebugMetadata():DebugMetadata 
	{
		var dm:DebugMetadata;

		
		// Try to get from the current path first
		var currentContent = state.currentContentObject;
		if (currentContent!=null) {
			dm = currentContent.debugMetadata;
			if (dm != null) {
				return dm;
			}
		}
			
		var i:Int;
		
		// Move up callstack if possible
		
		//int i = state.callStack.elements.Count - 1; i >= 0; --i
		i = state.callStack.elements.length;
		while (i>=0) {
			var currentObj = state.callStack.elements [i].currentObject;
			if (currentObj!=null && currentObj.debugMetadata != null) {
				return currentObj.debugMetadata;
			}
			--i;
		}
		

		// Current/previous path may not be valid if we've just had an error,
		// or if we've simply run out of content.
		// As a last resort, try to grab something from the output stream
		
		//int i = state.outputStream.Count - 1; i >= 0; --i
		i = state.outputStream.length -1;
		while (i>=0) {
			var outputObj = state.outputStream [i];
			dm = outputObj.debugMetadata;
			if (dm != null) {
				return dm;
			}
			--i;
		}

		return null;
	}

	

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
	
	
	
	
		public function Continue():String
	{
		// TODO: Should we leave this to the client, since it could be
		// slow to iterate through all the content an extra time?
		if( !_hasValidatedExternals )
			ValidateExternalBindings();


		return ContinueInternal ();
	}

	
	function ContinueInternal():String
	{
		if (!canContinue) {
			throw new StoryException ("Can't continue - should check canContinue before calling Continue");
		}

		_state.ResetOutput ();

		_state.didSafeExit = false;

		_state.variablesState.batchObservingVariableChanges = true;
	
		//_previousContainer = null;

		try {

			var stateAtLastNewline:StoryState = null;

			// The basic algorithm here is:
			//
			//     do { Step() } while( canContinue && !outputStreamEndsInNewline );
			//
			// But the complexity comes from:
			//  - Stepping beyond the newline in case it'll be absorbed by glue later
			//  - Ensuring that non-text content beyond newlines are generated - i.e. choices,
			//    which are actually built out of text content.
			// So we have to take a snapshot of the state, continue prospectively,
			// and rewind if necessary.
			// This code is slightly fragile :-/ 
			//
			var limit:Int = 512;
			var count:Int = 0;
			do {
				count++;
				if (count > limit) throw "Count iteration limit reached";
				
				// Run main step function (walks through content)
				Step();

				// Run out of content and we have a default invisible choice that we can follow?
				if( !canContinue ) {
					TryFollowDefaultInvisibleChoice();
				}

				// Don't save/rewind during string evaluation, which is e.g. used for choices
				if( !state.inStringEvaluation ) {
						
					// We previously found a newline, but were we just double checking that
					// it wouldn't immediately be removed by glue?
					if( stateAtLastNewline != null ) {

						// Cover cases that non-text generated content was evaluated last step
						var currText = currentText;
						var prevTextLength:Int = stateAtLastNewline.currentText.length;

						// Output has been extended?
						if( !(currText == stateAtLastNewline.currentText) ) {  // !currText.Equals(stateAtLastNewline.currentText) 

							// Original newline still exists?
							if( currText.length >= prevTextLength && currText.charAt(prevTextLength-1) == '\n' ) {
								
								RestoreStateSnapshot(stateAtLastNewline);
								break;
							}

							// Newline that previously existed is no longer valid - e.g.
							// glue was encounted that caused it to be removed.
							else {
								stateAtLastNewline = null;
							}
						}

					}

					// Current content ends in a newline - approaching end of our evaluation
					if( state.outputStreamEndsInNewline ) {
						// If we can continue evaluation for a bit:
						// Create a snapshot in case we need to rewind.
						// We're going to continue stepping in case we see glue or some
						// non-text content such as choices.
						if ( canContinue ) {
							
							stateAtLastNewline = StateSnapshot();
							
							
						} 

						// Can't continue, so we're about to exit - make sure we
						// don't have an old state hanging around.
						else {
							stateAtLastNewline = null;
						}

					}

				}

			} while(canContinue);

			// Need to rewind, due to evaluating further than we should?
			if ( stateAtLastNewline != null ) {
				RestoreStateSnapshot(stateAtLastNewline);
			}

			// Finished a section of content / reached a choice point?
			if( !canContinue ) {

				if( state.callStack.canPopThread ) {
					Error("Thread available to pop, threads should always be flat by the end of evaluation?");
				}

				if( currentChoices.length == 0 && !state.didSafeExit && _temporaryEvaluationContainer == null ) {
					if( state.callStack.CanPop(PushPopType.Tunnel) ) {
						Error("unexpectedly reached end of content. Do you need a '->->' to return from a tunnel?");
					} else if( state.callStack.CanPop(PushPopType.Function) ) {
						Error("unexpectedly reached end of content. Do you need a '~ return'?");
					} else if( !state.callStack.canPop ) {
						Error("ran out of content. Do you need a '-> DONE' or '-> END'?");
					} else {
						Error("unexpectedly reached end of content for unknown reason. Please debug compiler!");
					}
				}

			}


		} catch ( e:StoryException) {
			
			AddError (e.msg, e.useEndLineNumber);
			
			
		} 
		
		//finally {
			
			state.didSafeExit = false;

			_state.variablesState.batchObservingVariableChanges = false;
		//}
	
		
	
		
		return currentText;
	}

	
	public var canContinue(get, null):Bool;
	function get_canContinue():Bool 
	{
		return state.currentContentObject != null && !state.hasError;
	}
      

        
	public function ContinueMaximally():String
	{
		var sb = new StringBuf ();

		while (canContinue) {
			sb.add (Continue ());
		}

		return sb.toString ();
	}
	
	public function ContentAtPath(path:Path):Object
	{
		
		return mainContentContainer.ContentAtPath (path);
	}
	
	function StateSnapshot():StoryState
	{
		return state.Copy ();
	}

	function RestoreStateSnapshot( state:StoryState):Void
	{
		_state = state;
	}
		
	function Step ()
	{
		var shouldAddToStream = true;

		// Get current content
		var currentContentObj = state.currentContentObject;
		if (currentContentObj == null) {
			return;
		}
			
		// Step directly to the first element of content in a container (if necessary)
		var currentContainer = LibUtil.as(currentContentObj , Container);
		while(currentContainer!=null) {

			// Mark container as being entered
			VisitContainer (currentContainer, true); //atStart:true

			// No content? the most we can do is step past it
			if (currentContainer.content.length == 0)
				break;

			currentContentObj = currentContainer.content[0];
			state.callStack.currentElement.currentContentIndex = 0;
			state.callStack.currentElement.currentContainer = currentContainer;

			currentContainer = LibUtil.as(currentContentObj , Container);
		}
	
		currentContainer = state.callStack.currentElement.currentContainer;

		// Is the current content object:
		//  - Normal content
		//  - Or a logic/flow statement - if so, do it
		// Stop flow if we hit a stack pop when we're unable to pop (e.g. return/done statement in knot
		// that was diverted to rather than called as a function)
		var isLogicOrFlowControl:Bool = PerformLogicAndFlowControl (currentContentObj);

		// Has flow been forced to end by flow control above?
		if (state.currentContentObject == null) {
			return;
		}

		if (isLogicOrFlowControl) {
			shouldAddToStream = false;
		}

		// Choice with condition?
		var choicePoint = LibUtil.as(currentContentObj , ChoicePoint);
		if (choicePoint!=null) {
			var choice = ProcessChoice (choicePoint);
			if (choice!=null) {
				state.currentChoices.add (choice);
			}

			currentContentObj = null;
			shouldAddToStream = false;
		}

		// If the container has no content, then it will be
		// the "content" itself, but we skip over it.
		if ( Std.is(currentContentObj , Container)) {
			shouldAddToStream = false;
		}

		// Content to add to evaluation stack or the output stream
		if (shouldAddToStream) {
				
			
			// If we're pushing a variable pointer onto the evaluation stack, ensure that it's specific
			// to our current (possibly temporary) context index. And make a copy of the pointer
			// so that we're not editing the original runtime object.
			var varPointer = LibUtil.as(currentContentObj , VariablePointerValue);
			if (varPointer!=null && varPointer.contextIndex == -1) {

				// Create new object so we're not overwriting the story's own data
				var contextIdx = state.callStack.ContextForVariableNamed(varPointer.variableName);
				currentContentObj = new VariablePointerValue (varPointer.variableName, contextIdx);
			}

			// Expression evaluation content
			if (state.inExpressionEvaluation) {
				state.PushEvaluationStack (currentContentObj);
			}
			// Output stream content (i.e. not expression evaluation)
			else {
				state.PushToOutputStream (currentContentObj);
			}
		}

		// Increment the content pointer, following diverts if necessary
		NextContent ();

		// Starting a thread should be done after the increment to the content pointer,
		// so that when returning from the thread, it returns to the content after this instruction.
		var controlCmd = LibUtil.as( currentContentObj , ControlCommand);
		if (controlCmd !=null && controlCmd.commandType == ControlCommand.CommandType.StartThread) {
			state.callStack.PushThread ();
		}
	}

	// Mark a container as having been visited
	function VisitContainer( container:Container,  atStart:Bool)
	{

		if ( !container.countingAtStartOnly || atStart ) {
			if( container.visitsShouldBeCounted )
				IncrementVisitCountForContainer (container);

			if (container.turnIndexShouldBeCounted)
				RecordTurnIndexVisitToContainer (container);
		}
	}
	
	
            
	function ProcessChoice( choicePoint:ChoicePoint):Choice
	{
		var showChoice = true;

		// Don't create choice if choice point doesn't pass conditional
		if (choicePoint.hasCondition) {
			var conditionValue = state.PopEvaluationStack ();
			if (!IsTruthy (conditionValue)) {
				showChoice = false;
			}
		}

		var startText = "";
		var choiceOnlyText = "";

		if (choicePoint.hasChoiceOnlyContent) {
			var choiceOnlyStrVal = LibUtil.as( state.PopEvaluationStack () , StringValue);
			choiceOnlyText = choiceOnlyStrVal.value;
		}

		if (choicePoint.hasStartContent) {
			var startStrVal =  LibUtil.as( state.PopEvaluationStack () , StringValue);
			startText = startStrVal.value;
		}

		// Don't create choice if player has already read this content
		if (choicePoint.onceOnly) {
			var visitCount = VisitCountForContainer (choicePoint.choiceTarget);
			if (visitCount > 0) {
				showChoice = false;
			}
		}
			
		var choice =  Choice.create(choicePoint);
		choice.threadAtGeneration = state.callStack.currentThread.Copy ();

		// We go through the full process of creating the choice above so
		// that we consume the content for it, since otherwise it'll
		// be shown on the output stream.
		if (!showChoice) {
			return null;
		}

		// Set final text for the choice
		choice.text = startText + choiceOnlyText;

		return choice;
	}

	// Does the expression result represented by this object evaluate to true?
	// e.g. is it a Number that's not equal to 1?
	function IsTruthy( obj:Object):Bool
	{
		var truthy = false;
		if (Std.is(obj,  Value) ) {
			//var val:Value = cast obj; //(Value)
			//var val:Dynamic = obj;
			var val = LibUtil.as(obj, Value);
			
			if (Std.is(val, DivertTargetValue) ) {
				var divTarget:DivertTargetValue = cast val;
				Error ("Shouldn't use a divert target (to " + divTarget.targetPath + ") as a conditional value. Did you intend a function call 'likeThis()' or a read count check 'likeThis'? (no arrows)");
				return false;
			}

			return val.isTruthy;
		}
		return truthy;
	}
	
	
	function PerformLogicAndFlowControl( contentObj:Object):Bool
	{
		
		if( contentObj == null ) {
			return false;
		}

		// Divert
		if ( Std.is(contentObj ,Divert) ) {
			
			var currentDivert:Divert = cast contentObj; //(Divert)
			
			if (currentDivert.isConditional) {
				var conditionValue = state.PopEvaluationStack ();

				// False conditional? Cancel divert
				if (!IsTruthy (conditionValue))
					return true;
			}
			
			if (currentDivert.hasVariableTarget) {
				var varName = currentDivert.variableDivertName;
				
				var varContents = state.variablesState.GetVariableWithName (varName);

				if (!( Std.is(varContents , DivertTargetValue))) {

					var intContent = LibUtil.as(varContents , IntValue);

					var errorMessage = "Tried to divert to a target from a variable, but the variable (" + varName + ") didn't contain a divert target, it ";
					if (intContent!=null && intContent.value == 0) {
						errorMessage += "was empty/null (the value 0).";
					} else {
						errorMessage += "contained '" + varContents + "'.";
					}

					Error (errorMessage);
				}

				var target:DivertTargetValue = cast varContents;  //(DivertTargetValue)
				state.divertedTargetObject = ContentAtPath(target.targetPath);

			} else if (currentDivert.isExternal) {
				CallExternalFunction (currentDivert.targetPathString, currentDivert.externalArgs);
				return true;
			} else {
				trace("ADDING divertedTargetObject to state..");
				state.divertedTargetObject = currentDivert.targetContent;
			}

			if (currentDivert.pushesToStack) {
				trace("ADDING currentDivert to callstacke.."+currentDivert.stackPushType);
				state.callStack.Push (currentDivert.stackPushType);
			}

			if (state.divertedTargetObject == null && !currentDivert.isExternal) {
				
				// Human readable name available - runtime divert is part of a hard-written divert that to missing content
				if (currentDivert!= null && currentDivert.debugMetadata.sourceName != null) {
					Error ("Divert target doesn't exist: " + currentDivert.debugMetadata.sourceName);
				} else {
					Error ("Divert resolution failed: " + currentDivert);
				}
			}

			return true;
		} 

		// Start/end an expression evaluation? Or print out the result?
		else if( Std.is(contentObj , ControlCommand) ) {
			var evalCommand:ControlCommand = cast contentObj; //(ControlCommand)
			trace( "COMMAND:"+evalCommand.commandType);
			switch (evalCommand.commandType) {

			case ControlCommand.CommandType.EvalStart:
				Assert.bool(state.inExpressionEvaluation == false, "Already in expression evaluation?");
				state.inExpressionEvaluation = true;
				//break;

			case ControlCommand.CommandType.EvalEnd:
				Assert.bool(state.inExpressionEvaluation == true, "Not in expression evaluation mode");
				state.inExpressionEvaluation = false;
				//break;

			case ControlCommand.CommandType.EvalOutput:

				// If the expression turned out to be empty, there may not be anything on the stack
				if (state.evaluationStack.length > 0) {
					
					var output = state.PopEvaluationStack ();

					// Functions may evaluate to Void, in which case we skip output
					if (!(Std.is(output, VoidObj) )) {
						// TODO: Should we really always blanket convert to string?
						// It would be okay to have numbers in the output stream the
						// only problem is when exporting text for viewing, it skips over numbers etc.
						var text = new StringValue (Std.string(output));  //output.toString ()

						state.PushToOutputStream (text);
					}

				}
				//break;

			case ControlCommand.CommandType.NoOp:
				//break;

			case ControlCommand.CommandType.Duplicate:
				state.PushEvaluationStack (state.PeekEvaluationStack ());
				//break;

			case ControlCommand.CommandType.PopEvaluatedValue:
				state.PopEvaluationStack ();
				//break;

			case ControlCommand.CommandType.PopFunction, ControlCommand.CommandType.PopTunnel:

				var popType:Int = evalCommand.commandType == ControlCommand.CommandType.PopFunction ?
					cast PushPopType.Function : cast PushPopType.Tunnel;
				
				if ( (cast state.callStack.currentElement.type) != popType || !state.callStack.canPop) {

					var names = new IntMap<String> ();
					names.set(cast PushPopType.Function, "function return statement (~ return)");
					names.set(cast PushPopType.Tunnel, "tunnel onwards statement (->->)");

					var expected:String = names.get( cast state.callStack.currentElement.type );
					if (!state.callStack.canPop) {
						expected = "end of flow (-> END or choice)";
					}

					var errorMsg = "Found " + names.get(popType) + ", when expected " + expected;

					Error (errorMsg);
				} 

				else {
					state.callStack.Pop ();
				}
				//break;

			case ControlCommand.CommandType.BeginString:
				state.PushToOutputStream (evalCommand);

				Assert.bool(state.inExpressionEvaluation == true, "Expected to be in an expression when evaluating a string");
				state.inExpressionEvaluation = false;
				//break;

			case ControlCommand.CommandType.EndString:
				
				// Since we're iterating backward through the content,
				// build a stack so that when we build the string,
				// it's in the right order
				var contentStackForString = new GenericStack<Object> ();

				var outputCountConsumed = 0;
				
				//int i = state.outputStream.Count - 1; i >= 0; --i
				var i:Int = state.outputStream.length - 1;
				
				while (i>=0) {
					var obj = state.outputStream [i];

					outputCountConsumed++;

					var command = LibUtil.as( obj , ControlCommand);
					if (command != null && command.commandType == ControlCommand.CommandType.BeginString) {
						break;
					}

					if( Std.is(obj ,StringValue) ) 
						contentStackForString.add (obj);
				}

				// Consume the content that was produced for this string
				state.outputStream.splice (state.outputStream.length - outputCountConsumed, outputCountConsumed); //state.outputStream.RemoveRange (state.outputStream.Count - outputCountConsumed, outputCountConsumed);

				// Build string out of the content we collected
				var sb = new StringBuf ();
				for ( c in contentStackForString) {
					sb.add (Std.string(c) );  //c.ToString ()
				}

				// Return to expression evaluation (from content mode)
				state.inExpressionEvaluation = true;
				state.PushEvaluationStack (new StringValue (Std.string(sb))); //sb.ToString ()
				//break;

			case ControlCommand.CommandType.ChoiceCount:
				var choiceCount = currentChoices.length;
				state.PushEvaluationStack (new IntValue (choiceCount));
				//break;

			case ControlCommand.CommandType.TurnsSince:
				var target = state.PopEvaluationStack();
				if( !( Std.is(target, DivertTargetValue) ) ) {
					var extraNote = "";
					if( Std.is(target , IntValue) )
						extraNote = ". Did you accidentally pass a read count ('knot_name') instead of a target ('-> knot_name')?";
					Error("TURNS_SINCE expected a divert target (knot, stitch, label name), but saw "+target+extraNote);
					//break;
				}
				else {	// required else because no breka avialable..
					var divertTarget = LibUtil.as(target, DivertTargetValue);
					var container =LibUtil.as( ContentAtPath (divertTarget.targetPath) , Container);
					var turnCount:Int = TurnsSinceForContainer (container);
					state.PushEvaluationStack (new IntValue (turnCount));
					//break;
				}

			case ControlCommand.CommandType.VisitIndex:
				var count = VisitCountForContainer(state.currentContainer) - 1; // index not count
				state.PushEvaluationStack (new IntValue (count));
				//break;

			case ControlCommand.CommandType.SequenceShuffleIndex:
				var shuffleIndex = NextSequenceShuffleIndex ();
				state.PushEvaluationStack (new IntValue (shuffleIndex));
				//break;

			case ControlCommand.CommandType.StartThread:
				// Handled in main step function
				//break;

			case ControlCommand.CommandType.Done:
				
				// We may exist in the context of the initial
				// act of creating the thread, or in the context of
				// evaluating the content.
				
				if (state.callStack.canPopThread) {
					state.callStack.PopThread ();
				} 

				// In normal flow - allow safe exit without warning
				else {
					state.didSafeExit = true;
				}

				//break;
			
			// Force flow to end completely
			case ControlCommand.CommandType.End:
				state.ForceEndFlow ();
				//break;

			default:
				Error ("unhandled ControlCommand: " + evalCommand);
				//break;
			}

			return true;
		}
		
		// Variable assignment
		else if ( Std.is(contentObj , VariableAssignment) ) {
			
			var varAss:VariableAssignment= cast contentObj;  //(VariableAssignment)
			var assignedVal = state.PopEvaluationStack();

			// When in temporary evaluation, don't create new variables purely within
			// the temporary context, but attempt to create them globally
			//var prioritiseHigherInCallStack = _temporaryEvaluationContainer != null;

			state.variablesState.Assign (varAss, assignedVal);

			return true;
		}

		// Variable reference
		else if ( Std.is( contentObj , VariableReference) ) {
			
			var varRef:VariableReference = cast contentObj; //(VariableReference)
			var foundValue:Object = null;


			// Explicit read count value
			if (varRef.pathForCount != null) {

				var container = varRef.containerForCount;
				var count:Int = VisitCountForContainer (container);
				foundValue = new IntValue (count);
				
			}

			// Normal variable reference
			else {
	
				foundValue = state.variablesState.GetVariableWithName (varRef.name);
				
				if (foundValue == null) {
					Error("Uninitialised variable: " + varRef.name);
					foundValue = new IntValue (0);
				}
			}
			
			state.evaluationStack.push( foundValue );

			return true;
		}

		// Native function call
		else if( Std.is(contentObj , NativeFunctionCall) ) {
			var func:NativeFunctionCall = cast contentObj; //(NativeFunctionCall)
			var funcParams = state.PopEvaluationStack1(func.numberOfParameters);
			
			var result = func.Call(LibUtil.arrayToList(funcParams));
			state.evaluationStack.push(result);
			return true;
		}
	
		// No control content, must be ordinary content
		return false;
	}
	
	public function ChoosePathString( path:String):Void
	{
		ChoosePath ( Path.createFromString(path));
	}
		
	public function  ChoosePath( path:Path):Void
	{
	
		state.SetChosenPath (path);

		// Take a note of newly visited containers for read counts etc
		VisitChangedContainersDueToDivert ();
	}
	
	function VisitChangedContainersDueToDivert():Void
        {
            var previousContentObject = state.previousContentObject;
            var newContentObject = state.currentContentObject;

            if (!(newContentObject!=null))
                return;
            
            // First, find the previously open set of containers
            var prevContainerSet = new HashSet<Container>();
            if (previousContentObject!=null) {
                var prevAncestor:Container = Std.is(previousContentObject , Container) ? LibUtil.as(previousContentObject, Container) : LibUtil.as(previousContentObject.parent, Container);
				
                while (prevAncestor!=null) {
                    prevContainerSet.add (prevAncestor);
				
                    prevAncestor = LibUtil.as( prevAncestor.parent, Container);
                }
            }

            // If the new object is a container itself, it will be visited automatically at the next actual
            // content step. However, we need to walk up the new ancestry to see if there are more new containers
           var currentChildOfContainer:Object = newContentObject;
            var currentContainerAncestor:Container = LibUtil.as( currentChildOfContainer.parent , Container);
            while (currentContainerAncestor !=null && !prevContainerSet.contains(currentContainerAncestor)) {

                // Check whether this ancestor container is being entered at the start,
                // by checking whether the child object is the first.
                var enteringAtStart:Bool = currentContainerAncestor.content.length > 0 
                    && currentChildOfContainer == currentContainerAncestor.content [0];

                // Mark a visit to this container
                VisitContainer (currentContainerAncestor, enteringAtStart);

                currentChildOfContainer = currentContainerAncestor;
                currentContainerAncestor = LibUtil.as(currentContainerAncestor.parent , Container);
            }
        }
		
		

	
	
		
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
	


// TODO: externals-funcionality section below:

	function CallExternalFunction( funcName:String,  numberOfArguments:Int) {
		trace( "This is a stub. Will be added soon!");
	}
	function ValidateExternalBindings() {
		//trace( "This is a stub. Will be added soon!");
	}
/*
 /// <summary>
        /// An ink file can provide a fallback functions for when when an EXTERNAL has been left
        /// unbound by the client, and the fallback function will be called instead. Useful when
        /// testing a story in playmode, when it's not possible to write a client-side C# external
        /// function, but you don't want it to fail to run.
        /// </summary>
        public bool allowExternalFunctionFallbacks { get; set; }

        internal void CallExternalFunction(string funcName, int numberOfArguments)
        {
            ExternalFunction func = null;
            Container fallbackFunctionContainer = null;

            var foundExternal = _externals.TryGetValue (funcName, out func);

            // Try to use fallback function?
            if (!foundExternal) {
                if (allowExternalFunctionFallbacks) {
                    fallbackFunctionContainer = ContentAtPath (new Path (funcName)) as Container;
                    Assert (fallbackFunctionContainer != null, "Trying to call EXTERNAL function '" + funcName + "' which has not been bound, and fallback ink function could not be found.");

                    // Divert direct into fallback function and we're done
                    state.callStack.Push (PushPopType.Function);
                    state.divertedTargetObject = fallbackFunctionContainer;
                    return;

                } else {
                    Assert (false, "Trying to call EXTERNAL function '" + funcName + "' which has not been bound (and ink fallbacks disabled).");
                }
            }

            // Pop arguments
            var arguments = new List<object>();
            for (int i = 0; i < numberOfArguments; ++i) {
                var poppedObj = state.PopEvaluationStack () as Value;
                var valueObj = poppedObj.valueObject;
                arguments.Add (valueObj);
            }

            // Reverse arguments from the order they were popped,
            // so they're the right way round again.
            arguments.Reverse ();

            // Run the function!
            object funcResult = func (arguments.ToArray());

            // Convert return value (if any) to the a type that the ink engine can use
            Runtime.Object returnObj = null;
            if (funcResult != null) {
                returnObj = Value.Create (funcResult);
                Assert (returnObj != null, "Could not create ink value from returned object of type " + funcResult.GetType());
            } else {
                returnObj = new Runtime.Void ();
            }
                
            state.PushEvaluationStack (returnObj);
        }

		

        /// <summary>
        /// General purpose delegate definition for bound EXTERNAL function definitions
        /// from ink. Note that this version isn't necessary if you have a function
        /// with three arguments or less - see the overloads of BindExternalFunction.
        /// </summary>
        public delegate object ExternalFunction(object[] args);

        /// <summary>
        /// Most general form of function binding that returns an object
        /// and takes an array of object parameters.
        /// The only way to bind a function with more than 3 arguments.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="func">The C# function to bind.</param>
        public void BindExternalFunctionGeneral(string funcName, ExternalFunction func)
        {
            Assert (!_externals.ContainsKey (funcName), "Function '" + funcName + "' has already been bound.");
            _externals [funcName] = func;
        }

        object TryCoerce<T>(object value)
        {  
            if (value == null)
                return null;

            if (value is T)
                return (T) value;

            if (value is float && typeof(T) == typeof(int)) {
                int intVal = (int)Math.Round ((float)value);
                return intVal;
            }

            if (value is int && typeof(T) == typeof(float)) {
                float floatVal = (float)(int)value;
                return floatVal;
            }

            if (value is int && typeof(T) == typeof(bool)) {
                int intVal = (int)value;
                return intVal == 0 ? false : true;
            }

            if (typeof(T) == typeof(string)) {
                return value.ToString ();
            }

            Assert (false, "Failed to cast " + value.GetType ().Name + " to " + typeof(T).Name);

            return null;
        }

        // Convenience overloads for standard functions and actions of various arities
        // Is there a better way of doing this?!

        /// <summary>
        /// Bind a C# function to an ink EXTERNAL function declaration.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="func">The C# function to bind.</param>
        public void BindExternalFunction(string funcName, Func<object> func)
        {
			Assert(func != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, (object[] args) => {
                Assert(args.Length == 0, "External function expected no arguments");
                return func();
            });
        }

        /// <summary>
        /// Bind a C# Action to an ink EXTERNAL function declaration.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="act">The C# action to bind.</param>
        public void BindExternalFunction(string funcName, Action act)
        {
			Assert(act != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, (object[] args) => {
                Assert(args.Length == 0, "External function expected no arguments");
                act();
                return null;
            });
        }

        /// <summary>
        /// Bind a C# function to an ink EXTERNAL function declaration.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="func">The C# function to bind.</param>
        public void BindExternalFunction<T>(string funcName, Func<T, object> func)
        {
			Assert(func != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, (object[] args) => {
                Assert(args.Length == 1, "External function expected one argument");
                return func( (T)TryCoerce<T>(args[0]) );
            });
        }

        /// <summary>
        /// Bind a C# action to an ink EXTERNAL function declaration.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="act">The C# action to bind.</param>
        public void BindExternalFunction<T>(string funcName, Action<T> act)
        {
			Assert(act != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, (object[] args) => {
                Assert(args.Length == 1, "External function expected one argument");
                act( (T)TryCoerce<T>(args[0]) );
                return null;
            });
        }


        /// <summary>
        /// Bind a C# function to an ink EXTERNAL function declaration.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="func">The C# function to bind.</param>
        public void BindExternalFunction<T1, T2>(string funcName, Func<T1, T2, object> func)
        {
			Assert(func != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, (object[] args) => {
                Assert(args.Length == 2, "External function expected two arguments");
                return func(
                    (T1)TryCoerce<T1>(args[0]), 
                    (T2)TryCoerce<T2>(args[1])
                );
            });
        }

        /// <summary>
        /// Bind a C# action to an ink EXTERNAL function declaration.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="act">The C# action to bind.</param>
        public void BindExternalFunction<T1, T2>(string funcName, Action<T1, T2> act)
        {
			Assert(act != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, (object[] args) => {
                Assert(args.Length == 2, "External function expected two arguments");
                act(
                    (T1)TryCoerce<T1>(args[0]), 
                    (T2)TryCoerce<T2>(args[1])
                );
                return null;
            });
        }

        /// <summary>
        /// Bind a C# function to an ink EXTERNAL function declaration.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="func">The C# function to bind.</param>
        public void BindExternalFunction<T1, T2, T3>(string funcName, Func<T1, T2, T3, object> func)
        {
			Assert(func != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, (object[] args) => {
                Assert(args.Length == 3, "External function expected two arguments");
                return func(
                    (T1)TryCoerce<T1>(args[0]), 
                    (T2)TryCoerce<T2>(args[1]),
                    (T3)TryCoerce<T3>(args[2])
                );
            });
        }

        /// <summary>
        /// Bind a C# action to an ink EXTERNAL function declaration.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="act">The C# action to bind.</param>
        public void BindExternalFunction<T1, T2, T3>(string funcName, Action<T1, T2, T3> act)
        {
			Assert(act != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, (object[] args) => {
                Assert(args.Length == 3, "External function expected two arguments");
                act(
                    (T1)TryCoerce<T1>(args[0]), 
                    (T2)TryCoerce<T2>(args[1]),
                    (T3)TryCoerce<T3>(args[2])
                );
                return null;
            });
        }

        /// <summary>
        /// Remove a binding for a named EXTERNAL ink function.
        /// </summary>
        public void UnbindExternalFunction(string funcName)
        {
            Assert (_externals.ContainsKey (funcName), "Function '" + funcName + "' has not been bound.");
            _externals.Remove (funcName);
        }

        /// <summary>
        /// Check that all EXTERNAL ink functions have a valid bound C# function.
        /// Note that this is automatically called on the first call to Continue().
        /// </summary>
        public void ValidateExternalBindings()
        {
            ValidateExternalBindings (_mainContentContainer);
            _hasValidatedExternals = true;
        }

        void ValidateExternalBindings(Container c)
        {
            foreach (var innerContent in c.content) {
                ValidateExternalBindings (innerContent);
            }
            foreach (var innerKeyValue in c.namedContent) {
                ValidateExternalBindings (innerKeyValue.Value as Runtime.Object);
            }
        }

        void ValidateExternalBindings(Runtime.Object o)
        {
            var container = o as Container;
            if (container) {
                ValidateExternalBindings (container);
                return;
            }

            var divert = o as Divert;
            if (divert && divert.isExternal) {
                var name = divert.targetPathString;

                if (!_externals.ContainsKey (name)) {

                    INamedContent fallbackFunction = null;
                    bool fallbackFound = mainContentContainer.namedContent.TryGetValue (name, out fallbackFunction);

                    string message = null;
                    if (!allowExternalFunctionFallbacks)
                        message = "Missing function binding for external '" + name + "' (ink fallbacks disabled)";
                    else if( !fallbackFound ) {
                        message = "Missing function binding for external '" + name + "', and no fallback ink function found.";
                    }

                    if (message != null) {
                        string errorPreamble = "ERROR: ";
                        if (divert.debugMetadata != null) {
                            errorPreamble += string.Format ("'{0}' line {1}: ", divert.debugMetadata.fileName, divert.debugMetadata.startLineNumber);
                        }

                        throw new StoryException (errorPreamble + message);
                    }

                }
            }
        }
	*/
	
}