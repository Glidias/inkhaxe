package ink.runtime;
import ink.runtime.ControlCommand;
import ink.runtime.Value.DivertTargetValue;
import ink.runtime.Value.FloatValue;
import ink.runtime.Value.IntValue;
import ink.runtime.Value.StringValue;
import ink.runtime.Value.VariablePointerValue;
import ink.runtime.Glue;
import ink.runtime.VariableReference;

/**
 * DONE!
 * @author Glidias
 */
class Json
{

	public static function ListToJArray<T:RObject>(serialisables:List<T>):Array<Dynamic> {
		 var jArray = new Array<Dynamic>();
		for (s in serialisables) {
			jArray.push(RuntimeObjectToJToken(s));
		}
		return jArray;
	}
	
	public static inline function ArrayToJArray<T:RObject>(serialisables:Array<T>):Array<Dynamic> {
		 var jArray = new Array<Dynamic>();
		for (s in serialisables) {
			jArray.push(RuntimeObjectToJToken(s));
		}
		return jArray;
	}
	
	public static function JArrayToRuntimeObjList(jArray:Array<Dynamic>, skipLast:Bool=false):List<RObject>
	{
		var count:Int = jArray.length;
		if (skipLast)
			count--;

		var list = new List<RObject>();  //jArray.Count

		for (i in 0...count) {
			var jTok = jArray[i];
			var runtimeObj = LibUtil.as( JTokenToRuntimeObject (jTok), RObject);
			list.add(runtimeObj);
		}

		return list;
	}
	
	public static function JArrayToRuntimeObjArray(jArray:Array<Dynamic>, skipLast:Bool=false):Array<RObject>
	{
		var count:Int = jArray.length;
		if (skipLast)
			count--;

		var list = new Array<RObject>();  //jArray.Count
		
		for (i in 0...count) {
			var jTok = jArray[i];
			var runtimeObj = LibUtil.as( JTokenToRuntimeObject (jTok), RObject);
	
			list.push(runtimeObj);
		}

		return list;
	}
	
	
	
	
	 public static function DictionaryRuntimeObjsToJObject(dictionary:Map<String, RObject>):Dynamic
	{
		var jsonObj = {};
	
		for (k in dictionary.keys()) {
			var runtimeObj = LibUtil.as( dictionary.get(k), RObject);
			if (runtimeObj != null) {
				//jsonObj.set( k,  RuntimeObjectToJToken(runtimeObj) );
				Reflect.setField(jsonObj, k, RuntimeObjectToJToken(runtimeObj));
			}
		}

		return jsonObj;
	}
	
	 public static function JObjectToDictionaryRuntimeObjs(jObject:Dynamic):Map<String, RObject>
	{
		var dict = new Map<String, RObject>();  //jObject.Count
		
		for (k in Reflect.fields(jObject)) {
			dict.set(k, JTokenToRuntimeObject(Reflect.field(jObject, k)));
		
		}

		return dict;
	}
	
	public static function JObjectToIntDictionary(jObject:Dynamic ):Map<String,Int>
	{
		var dict = new Map<String, Int>();  //jObject.Count
		for (k in Reflect.fields(jObject)) {
			dict.set(k, Std.int(Reflect.field(jObject, k)));
		}
		return dict;
	}
	
	public static function IntDictionaryToJObject(dict:Map<String, Int>):Dynamic
	{
		var jObj = {};
		for (k in dict.keys()) {
			Reflect.setField(jObj, k, dict.get(k));
		}
		return jObj;
	}
	
	  // ----------------------
        // JSON ENCODING SCHEME
        // ----------------------
        //
        // Glue:           "<>", "G<", "G>"
        // 
        // ControlCommand: "ev", "out", "/ev", "du" "pop", "->->", "~ret", "str", "/str", "nop", 
        //                 "choiceCnt", "turns", "visit", "seq", "thread", "done", "end"
        // 
        // NativeFunction: "+", "-", "/", "*", "%" "~", "==", ">", "<", ">=", "<=", "!=", "!"... etc
        // 
        // Void:           "void"
        // 
        // Value:          "^string value", "^^string value beginning with ^"
        //                 5, 5.2
        //                 {"^->": "path.target"}
        //                 {"^var": "varname", "ci": 0}
        // 
        // Container:      [...]
        //                 [..., 
        //                     {
        //                         "subContainerName": ..., 
        //                         "#f": 5,                    // flags
        //                         "#n": "containerOwnName"    // only if not redundant
        //                     }
        //                 ]
        // 
        // Divert:         {"->": "path.target", "c": true }
        //                 {"->": "path.target", "var": true}
        //                 {"f()": "path.func"}
        //                 {"->t->": "path.tunnel"}
        //                 {"x()": "externalFuncName", "exArgs": 5}
        // 
        // Var Assign:     {"VAR=": "varName", "re": true}   // reassignment
        //                 {"temp=": "varName"}
        // 
        // Var ref:        {"VAR?": "varName"}
        //                 {"CNT?": "stitch name"}
        // 
        // ChoicePoint:    {"*": pathString,
        //                  "flg": 18 }
        //
        // Choice:         Nothing too clever, it's only used in the save state,
        //       
	public static function JTokenToRuntimeObject(token:Dynamic):RObject {
		
		
		// why is JS so wierd to think of \n as a number?!?? Let it slide?
		if ( (Std.is(token, Int) || Std.is(token, Float) )  ) {
			//if (Type.typeof(token) == Type.ValueType.TInt
			return Value.Create(token);
		}
		
		if  ( Std.is(token, String)  ) {
			
			var str:String =  Std.string(token);
			// String value
			var firstChar:String = str.charAt(0);
			if (firstChar == '^') {
				return new StringValue(str.substring(1));
			}
			else if ( (firstChar == '\n' && str.length == 1) || token == "\n" ) {  
				return new StringValue ("\n");
			}

			// Glue
			if (str == "<>")
				return new Glue (GlueType.Bidirectional);
			else if(str == "G<")
				return new Glue (GlueType.Left);
			else if(str == "G>")
				return new Glue (GlueType.Right);

			// Control commands (would looking up in a hash set be faster?)
			for (i in 0..._controlCommandNames.length) {
				var cmdName = _controlCommandNames [i];
				if (str == cmdName) {
					var cmdType:CommandType = cast i;
					return  ControlCommand.createFromCommandType(cast i);
				}
				
			}

			// Native functions
			if( NativeFunctionCall.CallExistsWithName(str) )
				return NativeFunctionCall.CallWithName (str);

			// Pop
			if (str == "->->")
				return ControlCommand.PopTunnel();
			else if (str == "~ret")
				return ControlCommand.PopFunction();

			// Void
			if (str == "void")
				return new VoidObj();
				
			trace("Failed to resolve String type!");	
		}
		
		
		// Array is always a Runtime.Container
		if (Std.is(token, Array )) {  //(List<object>
			return JArrayToContainer( token);
		}
		if (Type.typeof(token) == Type.ValueType.TObject ) {   //token is Dictionary<string, object>  Std.is(token, Dynamic)
			var obj = token;  //(Dictionary < string, object> )
			var propValue:Dynamic;

			// Divert target value to path
			propValue = LibUtil.tryGetValueDynamic(obj, "^->");
			if (propValue != null)
				return new DivertTargetValue( Path.createFromString(Std.string(propValue)));

			// VariablePointerValue
			propValue = LibUtil.tryGetValueDynamic(obj, "^var");
			if (propValue!=null) {   //obj.TryGetValue ("^var", out propValue)
				var varPtr = new VariablePointerValue(Std.string(propValue));
				if ( ( propValue=LibUtil.tryGetValueDynamic(obj, "ci") )!=null )   //obj.TryGetValue ("ci", out propValue)
					varPtr.contextIndex = Std.int(propValue);
				return varPtr;
			}

			// Divert
			var isDivert = false;
			var pushesToStack = false;
			var divPushType = PushPopType.Function;
			var external = false;
			
			propValue = LibUtil.tryGetValueDynamic(obj, "->");
			if (propValue!=null) {
				isDivert = true;
				
			}
			else if ( (propValue=LibUtil.tryGetValueDynamic(obj, "f()") )!=null ) { //obj.TryGetValue ("f()", out propValue)
				isDivert = true;
				pushesToStack = true;
				divPushType = PushPopType.Function;
			} 
			else if (   (propValue=LibUtil.tryGetValueDynamic(obj, "->t->") )!=null )  {   //obj.TryGetValue ("->t->", out propValue)
				isDivert = true;
				pushesToStack = true;
				divPushType = PushPopType.Tunnel;
			}
			else if (   (propValue=LibUtil.tryGetValueDynamic(obj, "x()") )!=null )   {   //obj.TryGetValue ("x()", out propValue)
				isDivert = true;
				external = true;
				pushesToStack = false;
				divPushType = PushPopType.Function;
			}
			if (isDivert) {
			
				var divert = new Divert ();
				divert.pushesToStack = pushesToStack;
				divert.stackPushType = divPushType;
				divert.isExternal = external;
					
				var target = Std.string(propValue);
			
				if (  (propValue=LibUtil.tryGetValueDynamic(obj, "var") )!=null ) 
					divert.variableDivertName = target;
				else {
					divert.targetPathString = target;
				}

				divert.isConditional = (propValue = LibUtil.tryGetValueDynamic(obj,"c")) != null; //obj.TryGetValue("c", out propValue);

				if (external) {
					if ( (propValue = LibUtil.tryGetValueDynamic(obj, "exArgs"))!=null )   //obj.TryGetValue ("exArgs", out propValue))
						divert.externalArgs = Std.int(propValue);
				}
				
				return divert;
			}
				
			// Choice
			if (   (propValue=LibUtil.tryGetValueDynamic(obj, "*") )!=null  ) {  // obj.TryGetValue ("*", out propValue)
				var choice = new ChoicePoint ();
					
				choice.pathStringOnChoice = Std.string( propValue );

				if ( (propValue=LibUtil.tryGetValueDynamic(obj, "flg") )!=null )  //obj.TryGetValue ("flg", out propValue)
					choice.flags = Std.int(propValue);

				return choice;
			}

			// Variable reference
			if (  (propValue=LibUtil.tryGetValueDynamic(obj, "VAR?") )!=null  ) {   //obj.TryGetValue ("VAR?", out propValue)
				return  VariableReference.create( Std.string(propValue) );
			} else if ( (propValue=LibUtil.tryGetValueDynamic(obj, "CNT?") )!=null  ) {   //obj.TryGetValue ("CNT?", out propValue)
				var readCountVarRef = new VariableReference ();
				readCountVarRef.pathStringForCount = Std.string( propValue);
				return readCountVarRef;
			}

			// Variable assignment
			var isVarAss = false;
			var isGlobalVar = false;
			if ( (propValue = LibUtil.tryGetValueDynamic(obj, "VAR=") ) != null ) {  //obj.TryGetValue ("VAR=", out propValue)
				isVarAss = true;
				isGlobalVar = true;
			} else if ( (propValue=LibUtil.tryGetValueDynamic(obj, "temp=") )!=null ) {   // obj.TryGetValue ("temp=", out propValue)
				isVarAss = true;
				isGlobalVar = false;
			}
			if (isVarAss) {
				var varName = Std.string(propValue); // .ToString ();
				var isNewDecl = (propValue=LibUtil.tryGetValueDynamic(obj, "re") ) ==null  ;   //!obj.TryGetValue("re", out propValue)
				var varAss = new VariableAssignment (varName, isNewDecl);
				varAss.isGlobal = isGlobalVar;
				return varAss;
			}

			if (Reflect.field(obj, "originalChoicePath") != null)
				return JObjectToChoice(obj);
				
			trace("Failed to resolve TObject type!");
		}

		if (token == null) {
			return null;
		}

		throw new SystemException ("Failed to convert token to runtime object: " + token + " :: "+Type.typeof(token) );
		
	}
	
	
	public static function RuntimeObjectToJToken(obj:RObject):Dynamic
	{
		var container = LibUtil.as(obj, Container);
		if (container != null) {
			return ContainerToJArray(container);
		}

		var divert:Divert = LibUtil.as(obj, Divert);
		if (divert != null) {
			var divTypeKey = "->";
			if (divert.isExternal)
				divTypeKey = "x()";
			else if (divert.pushesToStack) {
				if (divert.stackPushType == PushPopType.Function)
					divTypeKey = "f()";
				else if (divert.stackPushType == PushPopType.Tunnel)
					divTypeKey = "->t->";
			}

			var targetStr:String;
			if (divert.hasVariableTarget)
				targetStr = divert.variableDivertName;
			else {
				targetStr = divert.targetPathString;
	
			}

			var jObj:Dynamic= {};
			Reflect.setField(jObj, divTypeKey, targetStr);  // jObj[divTypeKey] = targetStr;

			if (divert.hasVariableTarget) {
				Reflect.setField(jObj, "var", true); //jObj ["var"] = true;
			}

			if (divert.isConditional) {
				Reflect.setField(jObj, "c", true); //jObj ["c"] = true;
			}

			if (divert.externalArgs > 0) {
				Reflect.setField(jObj, "exArgs", divert.externalArgs); //jObj ["exArgs"] = divert.externalArgs;
			}
			return jObj;
		}

		var choicePoint = LibUtil.as(obj, ChoicePoint);
		if (choicePoint != null) {
			var jObj:Dynamic = {};
			Reflect.setField(jObj, "*", choicePoint.pathStringOnChoice);  //jObj ["*"] = choicePoint.pathStringOnChoice;
			Reflect.setField(jObj, "flg", choicePoint.flags); //jObj ["flg"] = choicePoint.flags;
			return jObj;
		}


		var intVal = LibUtil.as(obj, IntValue);
		if (intVal!=null)
			return intVal.value;

		var floatVal = LibUtil.as(obj, FloatValue);
		if (floatVal!=null)
			return floatVal.value;
		
		var strVal = LibUtil.as(obj, StringValue);
		if (strVal!=null) {
			if (strVal.isNewline)
				return "\n";
			else
				return "^" + strVal.value;
		}

		var divTargetVal =  LibUtil.as(obj, DivertTargetValue);
		if (divTargetVal!=null) {
			var divTargetJsonObj =  {};
			Reflect.setField(divTargetJsonObj, "^->", divTargetVal.value.componentsString);
			return divTargetJsonObj;
		}
		
		var varPtrVal = LibUtil.as(obj, VariablePointerValue); 
		if (varPtrVal!=null) {
			var varPtrJsonObj = {};
			Reflect.setField(varPtrJsonObj, "^var", varPtrVal.value);
			Reflect.setField(varPtrJsonObj, "ci", varPtrVal.contextIndex);
			return varPtrJsonObj;
		}

		var glue =  LibUtil.as(obj, Glue);   
		if (glue!=null) {
			if (glue.isBi)
				return "<>";
			else if (glue.isLeft)
				return "G<";
			else
				return "G>";
		}

		var controlCmd =  LibUtil.as(obj, ControlCommand); 
		if (controlCmd!=null) {
			return _controlCommandNames[cast controlCmd.commandType];  
		}

		var nativeFunc = LibUtil.as(obj, NativeFunctionCall);
		if (nativeFunc !=null)
			return nativeFunc.name;

		// Variable reference
		var varRef = LibUtil.as(obj, VariableReference);
		if (varRef!=null) {
			var jObj = {};
			var readCountPath:String = varRef.pathStringForCount;
			if (readCountPath != null) {
				Reflect.setField(jObj, "CNT?", readCountPath); //jObj ["CNT?"] = readCountPath;
			} else {
				Reflect.setField(jObj, "VAR?", varRef.name); //jObj ["VAR?"] = varRef.name;
			}

			return jObj;
		}

		// Variable assignment
		var varAss =LibUtil.as(obj, VariableAssignment); 
		if (varAss!=null) {
			var key:String = varAss.isGlobal ? "VAR=" : "temp=";
			var jObj = {};
			Reflect.setField(jObj, key, varAss.variableName); // jObj[key] = varAss.variableName;

			// Reassignment?
			if (!varAss.isNewDeclaration)
				Reflect.setField(jObj, "re", true); // jObj ["re"] = true;

			return jObj;
		}
			
		var voidObj = LibUtil.as(obj, VoidObj);
		
		if (voidObj!=null)
			return "void";

		// Used when serialising save state only
		var choice = LibUtil.as(obj, Choice);
		if (choice!=null)
			return ChoiceToJObject (choice);

			
		throw new SystemException ("Failed to convert runtime object to Json token: " + obj);
	}
	
	
	
	
	static function  ContainerToJArray(container:Container):Array<Dynamic> {
			var jArray = ArrayToJArray (container.content);

            // Container is always an array [...]
            // But the final element is always either:
            //  - a dictionary containing the named content, as well as possibly
            //    the key "#" with the count flags
            //  - null, if neither of the above
            var namedOnlyContent = container.namedOnlyContent;
			
            var countFlags = container.countFlags;
			
			// namedOnlyContent.Count > 0
            if (namedOnlyContent != null && namedOnlyContent.iterator().hasNext()  || countFlags > 0 || container.name != null) {  // name being set is causing issues?

                var terminatingObj:Dynamic; //Dictionary<string, object> terminatingObj;
                if (namedOnlyContent != null) {
                    terminatingObj = DictionaryRuntimeObjsToJObject (namedOnlyContent);

                    // Strip redundant names from containers if necessary
                    for (p in Reflect.fields(terminatingObj)) {
						var namedContentObj = Reflect.field(terminatingObj, p);
					
                        var subContainerJArray = LibUtil.as( Reflect.field(terminatingObj, p), Array); // namedContentObj.Value; // var subContainerJArray = namedContentObj.Value as List<object>;
                        if (subContainerJArray != null) {
							
                            var attrJObj:Dynamic  = subContainerJArray[subContainerJArray.length - 1]; // LibUtil.as( subContainerJArray[subContainerJArray.length - 1], Map);
                            if (attrJObj != null) {  
							   Reflect.deleteField(attrJObj, "#n"); // attrJObj.Remove ("#n");
                                if (Reflect.fields(attrJObj).length == 0) //attrJObj.Count == 0
                                    subContainerJArray [subContainerJArray.length - 1] = null;
                            }
                        }
                    }

                } else {
			
                    terminatingObj =  {}; // new Dictionary<string, object> ();
				}
                if( countFlags > 0 )
                   Reflect.setField(terminatingObj, "#f", countFlags);// terminatingObj ["#f"] = countFlags;

                if( container.name != null )
                     Reflect.setField(terminatingObj, "#n", container.name);//terminatingObj ["#n"] = container.name;
					 
                jArray.push(terminatingObj);
            } 
            // Add null terminator to indicate that there's no dictionary
            else {
                jArray.push(null);
            }
			
			return jArray;
	}
	
	static function JArrayToContainer(jArray:Array<Dynamic>):Container  //List<object>
	{
		 var container = new Container ();
         container.content = JArrayToRuntimeObjArray(jArray, true); // JArrayToRuntimeObjList (jArray, true );  //skipLast:true

            // Final object in the array is always a combination of
            //  - named content
            //  - a "#" key with the countFlags
            // (if either exists at all, otherwise null)
            var terminatingObj:Dynamic = jArray [jArray.length - 1]; // as Dictionary<string, object>;
			
            if (terminatingObj != null) {

                var namedOnlyContent = new Map<String, RObject>();  //terminatingObj.Count

                for (k in Reflect.fields(terminatingObj)) {
		
                    if (k == "#f") {
                        container.countFlags = Std.int(Reflect.field(terminatingObj, k)); // (int) keyVal.Value;
                    } else if (k == "#n") {
                        container.name = Std.string(Reflect.field(terminatingObj, k)); // keyVal.Value.ToString ();
                    } else {
                        var namedContentItem = JTokenToRuntimeObject(Reflect.field(terminatingObj,k));
                        var namedSubContainer = LibUtil.as(namedContentItem , Container);
                        if (namedSubContainer !=null)
                            namedSubContainer.name = k;
                        namedOnlyContent.set(k, namedContentItem);
                    }
                }

                container.namedOnlyContent = namedOnlyContent;
				
            }
			

            return container;
	}
	
	static function JObjectToChoice(jObj:Dynamic):Choice  //Dictionary<string, object> 
	{
		var choice = new Choice();
		choice.text = Std.string(Reflect.field(jObj, "text")); // jObj ["text"].ToString();
		choice.index = Std.int( Reflect.field(jObj, "index") ); // jObj ["index"];
		choice.originalChoicePath = Std.string( Reflect.field(jObj, "originalChoicePath") ); // jObj ["originalChoicePath"].ToString();
		choice.originalThreadIndex = Std.int( Reflect.field(jObj, "originalThreadIndex") ); //  jObj ["originalThreadIndex"];
		return choice;
	}

	
	static function ChoiceToJObject( choice:Choice):Dynamic
	{
		var jObj = {
			text: choice.text,
			index: choice.index,
			originalChoicePath: choice.originalChoicePath,
			originalThreadIndex: choice.originalThreadIndex
		};
		
		/*
		jObj ["text"] = choice.text;
		jObj ["index"] = choice.index;
		jObj ["originalChoicePath"] = choice.originalChoicePath;
		jObj ["originalThreadIndex"] = choice.originalThreadIndex;
		*/
		return jObj;
	}
		
	 

	
	 static var _controlCommandNames:Array<String> = {
		 _controlCommandNames = new Array<String>(); // [CommandType.TOTAL_VALUES];
		//	 _controlCommandNames.length
		_controlCommandNames[cast CommandType.EvalStart] = "ev";
		_controlCommandNames[cast CommandType.EvalOutput] = "out";
		_controlCommandNames[cast CommandType.EvalEnd] = "/ev";
		_controlCommandNames[cast CommandType.Duplicate] = "du";
		_controlCommandNames[cast CommandType.PopEvaluatedValue] = "pop";
		_controlCommandNames[cast CommandType.PopFunction] = "~ret";
		_controlCommandNames[cast CommandType.PopTunnel] = "->->";
		_controlCommandNames[cast CommandType.BeginString] = "str";
		_controlCommandNames[cast CommandType.EndString] = "/str";
		_controlCommandNames[cast CommandType.NoOp] = "nop";
		_controlCommandNames[cast CommandType.ChoiceCount] = "choiceCnt";
		_controlCommandNames[cast CommandType.TurnsSince] = "turns";
		_controlCommandNames[cast CommandType.VisitIndex] = "visit";
		_controlCommandNames[cast CommandType.SequenceShuffleIndex] = "seq";
		_controlCommandNames[cast CommandType.StartThread] = "thread";
		_controlCommandNames[cast CommandType.Done] = "done";
		_controlCommandNames[cast CommandType.End] = "end";
		
		
		var len:Int  =  cast CommandType.TOTAL_VALUES;
		for ( i in 0...len) {
			 if (_controlCommandNames [i] == null)
                    throw new SystemException("Control command not accounted for in serialisation");
		}
		
		_controlCommandNames;
	 }
	
}