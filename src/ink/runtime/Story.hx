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
import ink.runtime.js.JSProxy;


/**
 * Done!
 * 
 * @author Glidias
 */

//public delegate object ExternalFunction(object[] args);
typedef ExternalFunction = Array<Dynamic>->Dynamic;	


// public delegate void VariableObserver(string variableName, object newValue);
typedef VariableObserver = String->Dynamic->Void;

@:expose
class Story extends RObject
{
	static public inline var inkVersionCurrent:Int = 12;
	public static inline var inkVersionMinimumCompatible:Int = 12;
	
	
	public var  currentChoices(get, null):Array<Choice>;
	function get_currentChoices():Array<Choice> 
	{
		// Don't include invisible choices for external usage.
		var choices = new Array<Choice>();
		for ( c in _state.currentChoices) {
			if (!c.choicePoint.isInvisibleDefault) {
				c.index = choices.length;
				choices.push(c);
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
	
	public var hasErrorThrow(get, null):Bool;
	function get_hasErrorThrow():Bool 
	{
		return state.hasError;
	}
	
	public var variablesState(get, null):VariablesState;
	//@:getter(variablesState)
	function get_variablesState():VariablesState 
	{
		return state.variablesState;
	}
	
	#if js
	public function getVariableesStateProxy():JSProxy {
		return state.variablesState.jsProxy;
	}
	#end
	
	public var state(get, null):StoryState;
	//@:getter(state)
	inline function get_state():StoryState 
	{
		return _state;
	}
	var _state:StoryState;
	
	
	
	public function new(jsonString:String) 
	{
		super();
		setupFromContainer(null);
		
		var rootObject:Dynamic = haxe.Json.parse(jsonString); // StringMap<Dynamic> = LibUtil.jTokenToStringMap( haxe.Json.parse(jsonString) ); // SimpleJson.TextToDictionary(jsonString);
		
		var versionObj:Dynamic = Reflect.field(rootObject, "inkVersion");
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
			
		var rootToken = Reflect.field(rootObject, "root");
		if (rootToken == null)
			throw new SystemException ("Root node for ink not found. Are you sure it's a valid .ink.json file?");
		
		
		
	
		_mainContentContainer = LibUtil.as(Json.JTokenToRuntimeObject(rootToken) , Container);

		
		ResetState ();
		

		// es6 setters/getters
		#if js
		untyped window.Object.defineProperty(this, "canContinue", { get : get_canContinue  });
		untyped window.Object.defineProperty(this, "currentChoices", { get : get_currentChoices  });
		untyped window.Object.defineProperty(this, "state", { get : get_state  });
		untyped window.Object.defineProperty(this, "variablesState", { get : getVariableesStateProxy  });
		#end
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
				
					//trace("Divert location:"+state.currentContentObject.path.componentsString  + "  ::  "+ (state.previousContentObject!= null ? state.previousContentObject.path.componentsString : "No previousContentObject ..") );
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
			
			//if (state.currentContentObject!= null) trace("location:"+state.currentContentObject.path.componentsString  + "  ::  "+ (state.previousContentObject!= null ? state.previousContentObject.path.componentsString : "No previousContentObject ..") );
				
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
                ErrorThrow ("Read count for target ("+container.name+" - on "+container.debugMetadata+") unknown. The story may need to be compiled with countAllVisits flag (-c).");
                return 0;
            }

            var count:Int = 0;
            var containerPathStr = container.path.toString();
            var tryCount = state.visitCounts.get(containerPathStr);  //TryGetValue (containerPathStr, out count);
			if ( LibUtil.validInt(tryCount) ) {
				count = tryCount;
			}
            return count;
        }

        function IncrementVisitCountForContainer( container:Container):Void
        {
            var count = 0;
            var containerPathStr = container.path.toString();
			 var tryCount = state.visitCounts.get(containerPathStr);  //TryGetValue (containerPathStr, out count);
			if ( LibUtil.validInt(tryCount) ) {
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
                ErrorThrow ("TURNS_SINCE() for target ("+container.name+" - on "+container.debugMetadata+") unknown. The story may need to be compiled with countAllVisits flag (-c).");
            }

            var containerPathStr = container.path.toString();
			var index = state.turnIndices.get(containerPathStr);  //state.turnIndices.TryGetValue (containerPathStr, out index)
            if ( LibUtil.validInt(index) ) {
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
                ErrorThrow ("expected number of elements in sequence for shuffle index");
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
	
			/*
            for ( c in seqPathStr.split("") ) {  //lazy method 
                var resultI:Int =  c.charCodeAt(0);
				
				// tocheck: is this correct as of js versinons? Or issit based off addition of digits?
				sequenceHash +=  resultI != null && !Math.isNaN(resultI) ? resultI :  0;  
				//sequenceHash += c;
            }
			*/
			for ( i in 0...seqPathStr.length) {
				sequenceHash += StringTools.fastCodeAt(seqPathStr, i);
			}
            var randomSeed = sequenceHash + loopIndex + state.storySeed;
            var random = new ParkMiller (randomSeed);

            var unpickedIndices = new Array<Int>(); // new List<Int>();
            for (i in 0...numElements) {  //int i = 0; i < numElements; ++i
                unpickedIndices.push (i);
            }

            for (i in 0...iterationIndex+1) {  //int i = 0; i <= iterationIndex; ++i
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
	function ErrorThrow( message:String,  useEndLineNumber:Bool = false)
	{
		var e = new StoryException (message);
		e.useEndLineNumber = useEndLineNumber;
		throw e;
	}
	 
		
	
	function AddErrorThrow ( message:String,  useEndLineNumber:Bool)
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
		i = state.callStack.elements.length - 1;
		while (i>=0) {
			var currentObj = state.callStack.elements[i].currentObject;
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

	

	function VariableStateDidChangeEvent( variableName:String, newValueObj:RObject):Void
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

		
		// I'd rather leave it uncaught so i can see stacktrace better, even though it'll kill the app basically.
		//try {  

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
		
			var count:Int = 0;
			do {

				if (count++ > 99999) throw "Count iteration limit reached";
			
				
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
					ErrorThrow("Thread available to pop, threads should always be flat by the end of evaluation?");
				}

				if( currentChoices.length == 0 && !state.didSafeExit && _temporaryEvaluationContainer == null ) {
					if( state.callStack.CanPop(PushPopType.Tunnel) ) {
						ErrorThrow("unexpectedly reached end of content. Do you need a '->->' to return from a tunnel?");
					} else if( state.callStack.CanPop(PushPopType.Function) ) {
						ErrorThrow("unexpectedly reached end of content. Do you need a '~ return'?");
					} else if( !state.callStack.canPop ) {
						ErrorThrow("ran out of content. Do you need a '-> DONE' or '-> END'?");
					} else {
						ErrorThrow("unexpectedly reached end of content for unknown reason. Please debug compiler!");
					}
				}

			}


		//} 
		//catch ( e:StoryException) {  
		//	AddErrorThrow (e.msg, e.useEndLineNumber);
		//} 
		
		//finally {
			
			state.didSafeExit = false;

			_state.variablesState.batchObservingVariableChanges = false;
		//}
	
		
	
		
		return currentText;
	}

	
	//@:getter(canContinue) 
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
	
	public function ContentAtPath(path:Path):RObject
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
		if (choicePoint != null) {
			
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
	function IsTruthy( obj:RObject):Bool
	{
		var truthy = false;
		if (Std.is(obj,  Value) ) {
			//var val:Value = cast obj; //(Value)
			//var val:Dynamic = obj;
			var val = LibUtil.as(obj, Value);
			
			if (Std.is(val, DivertTargetValue) ) {
				var divTarget:DivertTargetValue = cast val;
				ErrorThrow ("Shouldn't use a divert target (to " + divTarget.targetPath + ") as a conditional value. Did you intend a function call 'likeThis()' or a read count check 'likeThis'? (no arrows)");
				return false;
			}

			return val.isTruthy;
		}
		return truthy;
	}
	
	
	function PerformLogicAndFlowControl( contentObj:RObject):Bool
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

					ErrorThrow (errorMessage);
				}

				var target:DivertTargetValue = cast varContents;  //(DivertTargetValue)
				state.divertedTargetObject = ContentAtPath(target.targetPath);

			} else if (currentDivert.isExternal) {
				CallExternalFunction (currentDivert.targetPathString, currentDivert.externalArgs);
				return true;
			} else {
				state.divertedTargetObject = currentDivert.targetContent;
			}

			if (currentDivert.pushesToStack) {
				state.callStack.Push (currentDivert.stackPushType);
			}

			if (state.divertedTargetObject == null && !currentDivert.isExternal) {
				
				// Human readable name available - runtime divert is part of a hard-written divert that to missing content
				if (currentDivert!= null && currentDivert.debugMetadata.sourceName != null) {
					ErrorThrow ("Divert target doesn't exist: " + currentDivert.debugMetadata.sourceName);
				} else {
					ErrorThrow ("Divert resolution failed: " + currentDivert);
				}
			}

			return true;
		} 

		// Start/end an expression evaluation? Or print out the result?
		else if( Std.is(contentObj , ControlCommand) ) {
			var evalCommand:ControlCommand = cast contentObj; //(ControlCommand)
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

					ErrorThrow (errorMsg);
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
				var contentStackForString = new GenericStack<RObject> ();

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
						
					i--;  // continuing..
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
					ErrorThrow("TURNS_SINCE expected a divert target (knot, stitch, label name), but saw "+target+extraNote);
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
				ErrorThrow ("unhandled ControlCommand: " + evalCommand);
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
			var foundValue:RObject = null;


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
					ErrorThrow("Uninitialised variable: " + varRef.name);
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
           var currentChildOfContainer:RObject = newContentObject;
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

	
	/// <summary>
	/// Chooses the Choice from the currentChoices list with the given
	/// index. Internally, this sets the current content path to that
	/// pointed to by the Choice, ready to continue story evaluation.
	/// </summary>
	public function ChooseChoiceIndex( choiceIdx:Int):Void
	{
		var choices = currentChoices;
		Assert.bool(choiceIdx >= 0 && choiceIdx < choices.length, "choice out of range");

		// Replace callstack with the one from the thread at the choosing point, 
		// so that we can jump into the right place in the flow.
		// This is important in case the flow was forked by a new thread, which
		// can create multiple leading edges for the story, each of
		// which has its own context.
		var choiceToChoose = choices [choiceIdx];
		state.callStack.currentThread = choiceToChoose.threadAtGeneration;

		ChoosePath (choiceToChoose.choicePoint.choiceTarget.path);
	}

	/// <summary>
	/// Checks if a function exists.
	/// </summary>
	/// <returns>True if the function exists, else false.</returns>
	/// <param name="functionName">The name of the function as declared in ink.</param>
	public function HasFunction ( functionName:String):Bool
	{
		try {
			return Std.is( ContentAtPath ( Path.createFromString(functionName)),  Container);
		} catch(e:haxe.io.Error) {
			return false;
		}
		return false;
	}

	/*		// Is this portion needed?
	/// <summary>
	/// Evaluates a function defined in ink.
	/// </summary>
	/// <returns>The return value as returned from the ink function with `~ return myValue`, or null if nothing is returned.</returns>
	/// <param name="functionName">The name of the function as declared in ink.</param>
	/// <param name="arguments">The arguments that the ink function takes, if any. Note that we don't (can't) do any validation on the number of arguments right now, so make sure you get it right!</param>
	public object EvaluateFunction (string functionName, params object [] arguments)
	{
		string _;
		return EvaluateFunction (functionName, out _, arguments);
	}

	/// <summary>
	/// Evaluates a function defined in ink, and gathers the possibly multi-line text as generated by the function.
	/// This text output is any text written as normal content within the function, as opposed to the return value, as returned with `~ return`.
	/// </summary>
	/// <returns>The return value as returned from the ink function with `~ return myValue`, or null if nothing is returned.</returns>
	/// <param name="functionName">The name of the function as declared in ink.</param>
	/// <param name="textOutput">The text content produced by the function via normal ink, if any.</param>
	/// <param name="arguments">The arguments that the ink function takes, if any. Note that we don't (can't) do any validation on the number of arguments right now, so make sure you get it right!</param>
	public object EvaluateFunction (string functionName, out string textOutput, params object [] arguments)
	{
		if(functionName == null) {
			throw new System.Exception ("Function is null");
		} else if(functionName == string.Empty || functionName.Trim() == string.Empty) {
			throw new System.Exception ("Function is empty or white space.");
		}

		Runtime.Container funcContainer = null;
		try {
			funcContainer = ContentAtPath (new Path (functionName)) as Runtime.Container;
		} catch (StoryException e) {
			if (e.Message.Contains ("not found"))
				throw new System.Exception ("Function doesn't exist: '" + functionName + "'");
			else
				throw e;
		}

		// We'll start a new callstack, so keep hold of the original,
		// as well as the evaluation stack so we know if the function 
		// returned something
		var originalCallstack = state.callStack;
		int originalEvaluationStackHeight = state.evaluationStack.Count;

		// Create a new base call stack element.
		// By making it point at element 0 of the base, when NextContent is
		// called, it'll actually step past the entire content of the game (!)
		// and straight onto the Done. Bit of a hack :-/ We don't really have
		// a better way of creating a temporary context that ends correctly.
		state.callStack = new CallStack (mainContentContainer);
		state.callStack.currentElement.currentContainer = mainContentContainer;
		state.callStack.currentElement.currentContentIndex = 0;

		if (arguments != null) {
			for (int i = 0; i < arguments.Length; i++) {
				if (!(arguments [i] is int || arguments [i] is float || arguments [i] is string)) {
					throw new System.ArgumentException ("ink arguments when calling EvaluateFunction must be int, float or string");
				}

				state.evaluationStack.Add (Runtime.Value.Create(arguments[i]));
			}
		}

		// Jump into the function!
		state.callStack.Push (PushPopType.Function);
		state.currentContentObject = funcContainer;

		// Evaluate the function, and collect the string output
		var stringOutput = new StringBuilder ();
		while (canContinue) {
			stringOutput.Append (Continue ());
		}
		textOutput = stringOutput.ToString ();

		// Restore original stack
		state.callStack = originalCallstack;

		// Do we have a returned value?
		// Potentially pop multiple values off the stack, in case we need
		// to clean up after ourselves (e.g. caller of EvaluateFunction may 
		// have passed too many arguments, and we currently have no way to check for that)
		Runtime.Object returnedObj = null;
		while (state.evaluationStack.Count > originalEvaluationStackHeight) {
			var poppedObj = state.PopEvaluationStack ();
			if (returnedObj == null)
				returnedObj = poppedObj;
		}

		if (returnedObj) {
			if (returnedObj is Runtime.Void)
				return null;

			// Some kind of value, if not void
			var returnVal = returnedObj as Runtime.Value;

			// DivertTargets get returned as the string of components
			// (rather than a Path, which isn't public)
			if (returnVal.valueType == ValueType.DivertTarget) {
				return returnVal.valueObject.ToString ();
			}

			// Other types can just have their exact object type:
			// int, float, string. VariablePointers get returned as strings.
			return returnVal.valueObject;
		}

		return null;
	}

	// Evaluate a "hot compiled" piece of ink content, as used by the REPL-like
	// CommandLinePlayer.
	internal Runtime.Object EvaluateExpression(Runtime.Container exprContainer)
	{
		int startCallStackHeight = state.callStack.elements.Count;

		state.callStack.Push (PushPopType.Tunnel);

		_temporaryEvaluationContainer = exprContainer;

		state.GoToStart ();

		int evalStackHeight = state.evaluationStack.Count;

		Continue ();

		_temporaryEvaluationContainer = null;

		// Should have fallen off the end of the Container, which should
		// have auto-popped, but just in case we didn't for some reason,
		// manually pop to restore the state (including currentPath).
		if (state.callStack.elements.Count > startCallStackHeight) {
			state.callStack.Pop ();
		}

		int endStackHeight = state.evaluationStack.Count;
		if (endStackHeight > evalStackHeight) {
			return state.PopEvaluationStack ();
		} else {
			return null;
		}

	}
	*/
		
		






	public var allowExternalFunctionFallbacks:Bool; // { get; set; }

		/// <summary>
        /// An ink file can provide a fallback functions for when when an EXTERNAL has been left
        /// unbound by the client, and the fallback function will be called instead. Useful when
        /// testing a story in playmode, when it's not possible to write a client-side C# external
        /// function, but you don't want it to fail to run.
        /// </summary>
      

		public function CallExternalFunction( funcName:String,  numberOfArguments:Int):Void
        {
            var func:ExternalFunction = null;
            var fallbackFunctionContainer:Container = null;
			func =  _externals.get(funcName);
            var foundExternal = func != null; // _externals.TryGetValue (funcName, out func);

            // Try to use fallback function?
            if (!foundExternal) {
                if (allowExternalFunctionFallbacks) {
                    fallbackFunctionContainer = LibUtil.as( ContentAtPath ( Path.createFromString(funcName)) , Container);
                    Assert.bool(fallbackFunctionContainer != null, "Trying to call EXTERNAL function '" + funcName + "' which has not been bound, and fallback ink function could not be found.");

                    // Divert direct into fallback function and we're done
                    state.callStack.Push (PushPopType.Function);
                    state.divertedTargetObject = fallbackFunctionContainer;
                    return;

                } else {
                    Assert.bool(false, "Trying to call EXTERNAL function '" + funcName + "' which has not been bound (and ink fallbacks disabled).");
                }
            }

            // Pop arguments
            var arguments = new Array<Dynamic>();// new List<object>();
            for (i in 0...numberOfArguments) {  //int i = 0; i < numberOfArguments; ++i
                var poppedObj = LibUtil.as( state.PopEvaluationStack () , Value);
                var valueObj = poppedObj.valueObject;
				arguments.push(valueObj); // arguments.Add (valueObj);
            }

            // Reverse arguments from the order they were popped,
            // so they're the right way round again.
            arguments.reverse();  //arguments.Reverse ();
			

            // Run the function!
            var funcResult:Dynamic = func (arguments);  //arguments.ToArray()

            // Convert return value (if any) to the a type that the ink engine can use
            var returnObj:RObject = null;
            if (funcResult != null) {
                returnObj = Value.Create (funcResult);
                Assert.bool(returnObj != null, "Could not create ink value from returned object of type " + Type.getClassName(Type.getClass(funcResult)));
            } else {
                returnObj = new VoidObj();
            }
                
            state.PushEvaluationStack (returnObj);
        }


		

		inline
		function TryCoerce<T>(value:Dynamic):Dynamic	// is this really needed since already returning Dynamic?? Engine/haxe will hopefully coerce if necessary...
        {  
			/*
			var casted:T;
            if (value == null)
                return null;

            if (Std.is(value,  T) ) {
                casted  = cast T;  //(T) value;
				return casted;
			}

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

            Assert.bool(false, "Failed to cast " + value.GetType ().Name + " to " + typeof(T).Name);

            return null;
			*/
			
			return value;// vakyel
        }

	
		
        /// <summary>
        /// General purpose delegate definition for bound EXTERNAL function definitions
        /// from ink. Note that this version isn't necessary if you have a function
        /// with three arguments or less - see the overloads of BindExternalFunction.
        /// </summary>
        //public delegate object ExternalFunction(object[] args);
		//typedef ExternalFunction:Array->Dynamic;
		

        /// <summary>
        /// Most general form of function binding that returns an object
        /// and takes an array of object parameters.
        /// The only way to bind a function with more than 3 arguments.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="func">The C# function to bind.</param>
        public function BindExternalFunctionGeneral( funcName:String,  func:ExternalFunction):Void
        {
            Assert.bool(!_externals.exists (funcName), "Function '" + funcName + "' has already been bound.");
            _externals.set(funcName,  func);
        }


        // Convenience overloads for standard functions and actions of various arities
        // Is there a better way of doing this?!
	
		// Haxe doesn't allow overloading, so must explicitly specify the number of params or use BindExternalFunctionGeneral!

        /// <summary>
        /// Bind a C# function to an ink EXTERNAL function declaration.
        /// </summary>
        /// <param name="funcName">EXTERNAL ink function name to bind to.</param>
        /// <param name="func">The C# function to bind.</param>
        public function BindExternalFunction0( funcName:String, func:Void->Dynamic):Void   // Func<object> func
        {
			Assert.bool(func != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, function(args:Array<Dynamic>):Dynamic   {  // (object[] args) =>
                Assert.bool(args.length == 0, "External function expected no arguments");
                return func();
            });
        }
		 public function BindExternalFunction1<T1>( funcName:String, func:T1->Dynamic):Void   // Func<object> func
        {
			Assert.bool(func != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, function(args:Array<Dynamic>):Dynamic   {  // (object[] args) =>
                Assert.bool(args.length == 1, "External function expected 1 argument");
				var param1:T1 = args[0];
                return func(param1);
            });
        }
		public function BindExternalFunction2<T1, T2>( funcName:String, func:T1->T2->Dynamic):Void   // Func<object> func
        {
			Assert.bool(func != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, function(args:Array<Dynamic>):Dynamic   {  // (object[] args) =>
                Assert.bool(args.length == 2, "External function expected 2 arguments");
				var param1:T1 = args[0];
				var param2:T2 = args[1];
                return func(param1, param2);
            });
        }
		public function BindExternalFunction3<T1,T2,T3>( funcName:String, func:T1->T2->T3->Dynamic):Void   // Func<object> func
        {
			Assert.bool(func != null, "Can't bind a null function");

            BindExternalFunctionGeneral (funcName, function(args:Array<Dynamic>):Dynamic   {  // (object[] args) =>
                Assert.bool(args.length == 3, "External function expected 3 arguments");
				var param1:T1 = args[0];
				var param2:T2 = args[1];
				var param3:T3 = args[2];
                return func(param1, param2, param3);
            });
        }


        /// <summary>
        /// Remove a binding for a named EXTERNAL ink function.
        /// </summary>
        public function UnbindExternalFunction( funcName:String):Void
        {
            Assert.bool (_externals.exists (funcName), "Function '" + funcName + "' has not been bound.");
            _externals.remove (funcName);
        }

        /// <summary>
        /// Check that all EXTERNAL ink functions have a valid bound C# function.
        /// Note that this is automatically called on the first call to Continue().
        /// </summary>
        public function ValidateExternalBindings():Void
        {
            ValidateExternalBindingsC (_mainContentContainer);
            _hasValidatedExternals = true;
        }

        function ValidateExternalBindingsC( c:Container):Void
        {
            for ( innerContent in c.content) {
                ValidateExternalBindingsO(innerContent);
            }
            for ( value in c.namedContent) {  //innerKeyValue
                ValidateExternalBindingsO(LibUtil.as(value , RObject));  //innerKeyValue.Value
            }
        }

        function  ValidateExternalBindingsO(o:RObject):Void
        {
            var container = LibUtil.as( o , Container);
            if (container != null) {
                ValidateExternalBindingsC(container);
                return;
            }

            var divert = LibUtil.as(o , Divert);
            if (divert!=null && divert.isExternal) {
                var name = divert.targetPathString;

                if (!_externals.exists (name)) {

                    var fallbackFunction:INamedContent = null;
					fallbackFunction = mainContentContainer.namedContent.get(name);
                    var fallbackFound:Bool = fallbackFunction!=null;  //mainContentContainer.namedContent.TryGetValue (name, out fallbackFunction);

                    var message:String = null;
                    if (!allowExternalFunctionFallbacks)
                        message = "Missing function binding for external '" + name + "' (ink fallbacks disabled)";
                    else if( !fallbackFound ) {
                        message = "Missing function binding for external '" + name + "', and no fallback ink function found.";
                    }

                    if (message != null) {
                        var errorPreamble = "ERROR: ";
                        if (divert.debugMetadata != null) {
                            errorPreamble += "'" + divert.debugMetadata.fileName+"' line " + divert.debugMetadata.startLineNumber + ": ";
                        }

                        throw new StoryException (errorPreamble + message);
                    }

                }
            }
        }
		
		
		// Added (Glidias)
		// Untested method atm..to use when you gotta need it. 
		// You can try to use this to Reflect required external bindings of current Story to a HashSet
		
		 /// <summary>
        /// Check for all EXTERNAL ink functions and apply it to an array of strings! Useful to automate auto-binding process to your own library of methods.
		///  The automation process to link the list of methods are left up to you.
		/// If array function parameter is left undefined, the function will return a new array instance consisting of function names to bind, otherwise it returns the existing array you provided..
        /// </summary>
        public function ReflectExternalBindings(array:Array<String>=null):Array<String>
        {
			if (array == null) array = new Array<String>();
            ReflectExternalBindingsC (_mainContentContainer, array);
			return array;
        }

        function ReflectExternalBindingsC( c:Container, array:Array<String>):Void
        {
            for ( innerContent in c.content) {
                ReflectExternalBindingsO(innerContent, array);
            }
            for ( value in c.namedContent) {  //innerKeyValue
                ReflectExternalBindingsO(LibUtil.as(value , RObject), array);  //innerKeyValue.Value
            }
        }

        function  ReflectExternalBindingsO(o:RObject, array:Array<String>):Void
        {
            var container = LibUtil.as( o , Container);
            if (container != null) {
               ReflectExternalBindingsC(container, array);
                return;
            }

            var divert = LibUtil.as(o , Divert);
            if (divert!=null && divert.isExternal) {
				array.push(divert.targetPathString);
            }
        }
	
	
}