(function (console, $global) { "use strict";
var $estr = function() { return js_Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.indexOf = function(a,obj,i) {
	var len = a.length;
	if(i < 0) {
		i += len;
		if(i < 0) i = 0;
	}
	while(i < len) {
		if(a[i] === obj) return i;
		i++;
	}
	return -1;
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var InkleRuntime = function() { };
InkleRuntime.__name__ = ["InkleRuntime"];
InkleRuntime.main = function() {
	ink_runtime_Choice;
	ink_runtime_CallStack;
	ink_runtime_Json;
	ink_runtime_Value;
	ink_runtime_VariablesState;
	ink_runtime_NativeFunctionCall;
	InkleRuntime.testCommandTypeEnum();
};
InkleRuntime.testCommandTypeEnum = function() {
	var arrTest = ["index0","index1"];
	console.log(arrTest[0]);
	var cmdType = 0;
	console.log(cmdType);
	var cmdTypeE = 0;
	console.log(Std.string(cmdTypeE));
	var map = new haxe_ds_StringMap();
	var mapInt = new haxe_ds_IntMap();
	var mapSet = new ink_runtime_StringHashSet();
	if(__map_reserved.abc != null) mapSet.setReserved("abc",true); else mapSet.h["abc"] = true;
	var strMapBool_h = { };
	var value = new ink_runtime_Object();
	if(__map_reserved.abc != null) map.setReserved("abc",value); else map.h["abc"] = value;
	var value1;
	value1 = __map_reserved.abc != null?map.getReserved("abc"):map.h["abc"];
	mapInt.h[1] = value1;
	var json = { 'abc' : __map_reserved.abc != null?map.getReserved("abc"):map.h["abc"]};
	console.log(ink_runtime_LibUtil.tryGetValue(map,"abc") == Reflect.field(json,"abc"));
};
InkleRuntime.testDataTypeClasses = function() {
	console.log(Type.getClass(ink_runtime_Value.Create("abc")));
	console.log(Type.getClass(ink_runtime_Value.Create("1")));
	console.log(Type.getClass(ink_runtime_Value.Create("0")));
	console.log(Type.getClass(ink_runtime_Value.Create("1.0")));
	console.log(Type.getClass(ink_runtime_Value.Create("0.01")));
	console.log(Type.getClass(ink_runtime_Value.Create(1)));
	console.log(Type.getClass(ink_runtime_Value.Create(0)));
	console.log(Type.getClass(ink_runtime_Value.Create(1.0)));
	console.log(Type.getClass(ink_runtime_Value.Create(0.01)));
	console.log(Type.getClass(ink_runtime_Value.Create(true)));
	console.log(Type.getClass(ink_runtime_Value.Create(false)));
	console.log(4);
	console.log(ink_runtime_Value.Create("1").get_isTruthy());
};
var List = function() {
	this.length = 0;
};
List.__name__ = ["List"];
List.prototype = {
	add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,first: function() {
		if(this.h == null) return null; else return this.h[0];
	}
	,last: function() {
		if(this.q == null) return null; else return this.q[0];
	}
	,clear: function() {
		this.h = null;
		this.q = null;
		this.length = 0;
	}
	,remove: function(v) {
		var prev = null;
		var l = this.h;
		while(l != null) {
			if(l[0] == v) {
				if(prev == null) this.h = l[1]; else prev[1] = l[1];
				if(this.q == l) this.q = prev;
				this.length--;
				return true;
			}
			prev = l;
			l = l[1];
		}
		return false;
	}
	,__class__: List
};
Math.__name__ = ["Math"];
var Reflect = function() { };
Reflect.__name__ = ["Reflect"];
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		if (e instanceof js__$Boot_HaxeError) e = e.val;
		return null;
	}
};
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
Reflect.getProperty = function(o,field) {
	var tmp;
	if(o == null) return null; else if(o.__properties__ && (tmp = o.__properties__["get_" + field])) return o[tmp](); else return o[field];
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
Reflect.deleteField = function(o,field) {
	if(!Object.prototype.hasOwnProperty.call(o,field)) return false;
	delete(o[field]);
	return true;
};
var Std = function() { };
Std.__name__ = ["Std"];
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
Std["int"] = function(x) {
	return x | 0;
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
Std.parseFloat = function(x) {
	return parseFloat(x);
};
var StringBuf = function() {
	this.b = "";
};
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype = {
	add: function(x) {
		this.b += Std.string(x);
	}
	,__class__: StringBuf
};
var StringTools = function() { };
StringTools.__name__ = ["StringTools"];
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
};
var ValueType = { __ename__ : true, __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] };
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; };
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; };
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
var Type = function() { };
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null; else return js_Boot.getClass(o);
};
Type.getClassName = function(c) {
	var a = c.__name__;
	if(a == null) return null;
	return a.join(".");
};
Type.createInstance = function(cl,args) {
	var _g = args.length;
	switch(_g) {
	case 0:
		return new cl();
	case 1:
		return new cl(args[0]);
	case 2:
		return new cl(args[0],args[1]);
	case 3:
		return new cl(args[0],args[1],args[2]);
	case 4:
		return new cl(args[0],args[1],args[2],args[3]);
	case 5:
		return new cl(args[0],args[1],args[2],args[3],args[4]);
	case 6:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5]);
	case 7:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
	case 8:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
	default:
		throw new js__$Boot_HaxeError("Too many arguments");
	}
	return null;
};
Type.createEmptyInstance = function(cl) {
	function empty() {}; empty.prototype = cl.prototype;
	return new empty();
};
Type["typeof"] = function(v) {
	var _g = typeof(v);
	switch(_g) {
	case "boolean":
		return ValueType.TBool;
	case "string":
		return ValueType.TClass(String);
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	case "object":
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = js_Boot.getClass(v);
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	case "function":
		if(v.__name__ || v.__ename__) return ValueType.TObject;
		return ValueType.TFunction;
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
};
var haxe_IMap = function() { };
haxe_IMap.__name__ = ["haxe","IMap"];
haxe_IMap.prototype = {
	__class__: haxe_IMap
};
var haxe_ds_IntMap = function() {
	this.h = { };
};
haxe_ds_IntMap.__name__ = ["haxe","ds","IntMap"];
haxe_ds_IntMap.__interfaces__ = [haxe_IMap];
haxe_ds_IntMap.prototype = {
	set: function(key,value) {
		this.h[key] = value;
	}
	,get: function(key) {
		return this.h[key];
	}
	,exists: function(key) {
		return this.h.hasOwnProperty(key);
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key | 0);
		}
		return HxOverrides.iter(a);
	}
	,__class__: haxe_ds_IntMap
};
var haxe_ds_ObjectMap = function() {
	this.h = { };
	this.h.__keys__ = { };
};
haxe_ds_ObjectMap.__name__ = ["haxe","ds","ObjectMap"];
haxe_ds_ObjectMap.__interfaces__ = [haxe_IMap];
haxe_ds_ObjectMap.prototype = {
	set: function(key,value) {
		var id = key.__id__ || (key.__id__ = ++haxe_ds_ObjectMap.count);
		this.h[id] = value;
		this.h.__keys__[id] = key;
	}
	,get: function(key) {
		return this.h[key.__id__];
	}
	,exists: function(key) {
		return this.h.__keys__[key.__id__] != null;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h.__keys__ ) {
		if(this.h.hasOwnProperty(key)) a.push(this.h.__keys__[key]);
		}
		return HxOverrides.iter(a);
	}
	,__class__: haxe_ds_ObjectMap
};
var haxe_ds__$StringMap_StringMapIterator = function(map,keys) {
	this.map = map;
	this.keys = keys;
	this.index = 0;
	this.count = keys.length;
};
haxe_ds__$StringMap_StringMapIterator.__name__ = ["haxe","ds","_StringMap","StringMapIterator"];
haxe_ds__$StringMap_StringMapIterator.prototype = {
	hasNext: function() {
		return this.index < this.count;
	}
	,next: function() {
		return this.map.get(this.keys[this.index++]);
	}
	,__class__: haxe_ds__$StringMap_StringMapIterator
};
var haxe_ds_StringMap = function() {
	this.h = { };
};
haxe_ds_StringMap.__name__ = ["haxe","ds","StringMap"];
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	set: function(key,value) {
		if(__map_reserved[key] != null) this.setReserved(key,value); else this.h[key] = value;
	}
	,get: function(key) {
		if(__map_reserved[key] != null) return this.getReserved(key);
		return this.h[key];
	}
	,exists: function(key) {
		if(__map_reserved[key] != null) return this.existsReserved(key);
		return this.h.hasOwnProperty(key);
	}
	,setReserved: function(key,value) {
		if(this.rh == null) this.rh = { };
		this.rh["$" + key] = value;
	}
	,getReserved: function(key) {
		if(this.rh == null) return null; else return this.rh["$" + key];
	}
	,existsReserved: function(key) {
		if(this.rh == null) return false;
		return this.rh.hasOwnProperty("$" + key);
	}
	,remove: function(key) {
		if(__map_reserved[key] != null) {
			key = "$" + key;
			if(this.rh == null || !this.rh.hasOwnProperty(key)) return false;
			delete(this.rh[key]);
			return true;
		} else {
			if(!this.h.hasOwnProperty(key)) return false;
			delete(this.h[key]);
			return true;
		}
	}
	,keys: function() {
		var _this = this.arrayKeys();
		return HxOverrides.iter(_this);
	}
	,arrayKeys: function() {
		var out = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) out.push(key);
		}
		if(this.rh != null) {
			for( var key in this.rh ) {
			if(key.charCodeAt(0) == 36) out.push(key.substr(1));
			}
		}
		return out;
	}
	,__class__: haxe_ds_StringMap
};
var ink_runtime_Assert = function() { };
ink_runtime_Assert.__name__ = ["ink","runtime","Assert"];
ink_runtime_Assert.bool = function(result,error) {
	if(!result) throw new js__$Boot_HaxeError(error);
};
var ink_runtime_CallStack = function() {
};
ink_runtime_CallStack.__name__ = ["ink","runtime","CallStack"];
ink_runtime_CallStack.createCallStack = function(rootContentContainer) {
	var me = new ink_runtime_CallStack();
	me.setupCallStack(rootContentContainer);
	return me;
};
ink_runtime_CallStack.createCallStack2 = function(toCopy) {
	var me = new ink_runtime_CallStack();
	me.setupCallStack2(toCopy);
	return me;
};
ink_runtime_CallStack.prototype = {
	get_elements: function() {
		return this.get_callStack();
	}
	,get_currentElement: function() {
		return this.get_callStack()[this.get_callStack().length - 1];
	}
	,get_currentElementIndex: function() {
		return this.get_callStack().length - 1;
	}
	,get_currentThread: function() {
		return this._threads.last();
	}
	,set_currentThread: function(value) {
		ink_runtime_Assert.bool(this._threads.length == 1,"Shouldn't be directly setting the current thread when we have a stack of them");
		this._threads.clear();
		this._threads.add(value);
		return value;
	}
	,get_canPop: function() {
		return this.get_callStack().length > 1;
	}
	,setupCallStack: function(rootContentContainer) {
		this._threads = new List();
		this._threads.add(new ink_runtime_Thread());
		this._threads.first().callstack.push(new ink_runtime_Element(0,rootContentContainer,0));
	}
	,setupCallStack2: function(toCopy) {
		this._threads = new List();
		var i_head = toCopy._threads.h;
		var i_val = null;
		while(i_head != null) {
			var otherThread;
			otherThread = (function($this) {
				var $r;
				i_val = i_head[0];
				i_head = i_head[1];
				$r = i_val;
				return $r;
			}(this));
			this._threads.add(otherThread.Copy());
		}
	}
	,SetJsonToken: function(jObject,storyContext) {
		this._threads.clear();
		var jThreads = Reflect.field(jObject,"threads");
		var _g1 = 0;
		var _g = jThreads.length;
		while(_g1 < _g) {
			var i = _g1++;
			var jThreadTok = jThreads[i];
			var jThreadObj = jThreadTok;
			var thread = ink_runtime_Thread.create(jThreadObj,storyContext);
			this._threads.add(thread);
		}
		this._threadCounter = Reflect.field(jObject,"threadCounter");
	}
	,sGetJsonToken: function() {
		var jObject = { };
		var jThreads = [];
		var i_head = this._threads.h;
		var i_val = null;
		while(i_head != null) {
			var thread;
			thread = (function($this) {
				var $r;
				i_val = i_head[0];
				i_head = i_head[1];
				$r = i_val;
				return $r;
			}(this));
			jThreads.push(thread.get_jsonToken());
		}
		jObject.threads = jThreads;
		jObject.threadCounter = this._threadCounter;
		return jObject;
	}
	,PushThread: function() {
		var newThread = this.get_currentThread().Copy();
		newThread.threadIndex = this._threadCounter;
		this._threadCounter++;
		this._threads.add(newThread);
	}
	,PopThread: function() {
		if(this.get_canPopThread()) this._threads.remove(this.get_currentThread()); else throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Can't pop thread"));
	}
	,get_canPopThread: function() {
		return this._threads.length > 1;
	}
	,Push: function(type) {
		this.get_callStack().push(new ink_runtime_Element(type,this.get_currentElement().currentContainer,this.get_currentElement().currentContentIndex,false));
	}
	,CanPop: function(type) {
		if(!this.get_canPop()) return false;
		if(type == null) return true;
		return this.get_currentElement().type == type;
	}
	,Pop: function(type) {
		if(this.CanPop(type)) {
			this.get_callStack().pop();
			return;
		} else throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Mismatched push/pop in Callstack"));
	}
	,GetTemporaryVariableWithName: function(name,contextIndex) {
		if(contextIndex == null) contextIndex = -1;
		if(contextIndex == -1) contextIndex = this.get_currentElementIndex() + 1;
		var varValue = null;
		var contextElement = this.get_callStack()[contextIndex - 1];
		varValue = ink_runtime_LibUtil.tryGetValue(contextElement.temporaryVariables,name);
		if(varValue != null) return varValue; else return null;
	}
	,SetTemporaryVariable: function(name,value,declareNew,contextIndex) {
		if(contextIndex == null) contextIndex = -1;
		if(contextIndex == -1) contextIndex = this.get_currentElementIndex() + 1;
		var contextElement = this.get_callStack()[contextIndex - 1];
		if(!declareNew && !contextElement.temporaryVariables.exists(name)) throw new js__$Boot_HaxeError(new ink_runtime_StoryException("Could not find temporary variable to set: " + name));
		{
			contextElement.temporaryVariables.set(name,value);
			value;
		}
	}
	,ContextForVariableNamed: function(name) {
		if((function($this) {
			var $r;
			var this1 = $this.get_currentElement().temporaryVariables;
			$r = this1.exists(name);
			return $r;
		}(this))) return this.get_currentElementIndex() + 1; else return 0;
	}
	,ThreadWithIndex: function(index) {
		return ink_runtime_LibUtil.findForList(this._threads,function(t) {
			return t.threadIndex == index;
		});
	}
	,get_callStack: function() {
		return this.get_currentThread().callstack;
	}
	,__class__: ink_runtime_CallStack
	,__properties__: {get_callStack:"get_callStack",get_canPopThread:"get_canPopThread",get_canPop:"get_canPop",set_currentThread:"set_currentThread",get_currentThread:"get_currentThread",get_currentElementIndex:"get_currentElementIndex",get_currentElement:"get_currentElement",get_elements:"get_elements"}
};
var ink_runtime_Element = function(type,container,contentIndex,inExpressionEvaluation) {
	if(inExpressionEvaluation == null) inExpressionEvaluation = false;
	this.currentContainer = container;
	this.currentContentIndex = contentIndex;
	this.inExpressionEvaluation = inExpressionEvaluation;
	this.temporaryVariables = new haxe_ds_StringMap();
	this.type = type;
};
ink_runtime_Element.__name__ = ["ink","runtime","Element"];
ink_runtime_Element.prototype = {
	get_currentObject: function() {
		if(this.currentContainer != null && this.currentContentIndex < this.currentContainer._content.length) return this.currentContainer._content[this.currentContentIndex];
		return null;
	}
	,set_currentObject: function(value) {
		var currentObj = value;
		if(currentObj == null) {
			this.currentContainer = null;
			this.currentContentIndex = 0;
			return this.currentContainer._content[this.currentContentIndex];
		}
		this.currentContainer = ink_runtime_LibUtil["as"](currentObj.parent,ink_runtime_Container);
		if(this.currentContainer != null) this.currentContentIndex = HxOverrides.indexOf(this.currentContainer._content,currentObj,0);
		if(this.currentContainer == null || this.currentContentIndex == -1) {
			this.currentContainer = js_Boot.__instanceof(currentObj,ink_runtime_Container)?currentObj:null;
			this.currentContentIndex = 0;
		}
		return this.currentContainer._content[this.currentContentIndex];
	}
	,Copy: function() {
		var copy = new ink_runtime_Element(this.type,this.currentContainer,this.currentContentIndex,this.inExpressionEvaluation);
		var cloner = new ink_runtime_Cloner();
		var clone = cloner.clone(this.temporaryVariables);
		copy.temporaryVariables = clone;
		return copy;
	}
	,__class__: ink_runtime_Element
	,__properties__: {set_currentObject:"set_currentObject",get_currentObject:"get_currentObject"}
};
var ink_runtime_Thread = function() {
	this.callstack = [];
};
ink_runtime_Thread.__name__ = ["ink","runtime","Thread"];
ink_runtime_Thread.create = function(jThreadObj,storyContext) {
	var me = new ink_runtime_Thread();
	me.setup(jThreadObj,storyContext);
	return me;
};
ink_runtime_Thread.prototype = {
	setup: function(jThreadObj,storyContext) {
		this.threadIndex = Std["int"](Reflect.field(jThreadObj,"threadIndex"));
		var jThreadCallstack = Reflect.field(jThreadObj,"callstack");
		var _g1 = 0;
		var _g = jThreadCallstack.length;
		while(_g1 < _g) {
			var i = _g1++;
			var jElTok = jThreadCallstack[i];
			var jElementObj = jElTok;
			var pushPopType = Reflect.field(jElementObj,"type");
			var currentContainer = null;
			var contentIndex = 0;
			var currentContainerPathStr = null;
			var currentContainerPathStrToken;
			currentContainerPathStrToken = Reflect.field(jElementObj,"cPath");
			if(currentContainerPathStrToken != null) {
				currentContainerPathStr = Std.string(currentContainerPathStrToken);
				currentContainer = ink_runtime_LibUtil.asNoInline(storyContext.ContentAtPath(ink_runtime_Path.createFromString(currentContainerPathStr)),ink_runtime_Container);
				contentIndex = Std["int"](Reflect.field(jElementObj,"idx"));
			}
			var inExpressionEvaluation = Reflect.field(jElementObj,"exp");
			var el = new ink_runtime_Element(pushPopType,currentContainer,contentIndex,inExpressionEvaluation);
			var jObjTemps = Reflect.field(jElementObj,"temp");
			el.temporaryVariables = ink_runtime_Json.JObjectToDictionaryRuntimeObjs(jObjTemps);
			this.callstack.push(el);
		}
		var prevContentObjPath;
		prevContentObjPath = Reflect.field(jThreadObj,"previousContentObject");
		if(prevContentObjPath != null) {
			var prevPath = ink_runtime_Path.createFromString(Std.string(prevContentObjPath));
			this.previousContentObject = storyContext.ContentAtPath(prevPath);
		}
	}
	,Copy: function() {
		var copy = new ink_runtime_Thread();
		copy.threadIndex = this.threadIndex;
		var _g1 = 0;
		var _g = this.callstack.length;
		while(_g1 < _g) {
			var i = _g1++;
			var e = this.callstack[i];
			copy.callstack.push(e.Copy());
		}
		copy.previousContentObject = this.previousContentObject;
		return copy;
	}
	,get_jsonToken: function() {
		var threadJObj = { };
		var jThreadCallstack = [];
		var _g1 = 0;
		var _g = this.callstack.length;
		while(_g1 < _g) {
			var i = _g1++;
			var el = this.callstack[i];
			var jObj = { };
			if(el.currentContainer != null) {
				Reflect.setField(jObj,"cPath",el.currentContainer.get_path().componentsString);
				jObj.idx = el.currentContentIndex;
			}
			jObj.exp = el.inExpressionEvaluation;
			jObj.type = el.type;
			Reflect.setField(jObj,"temp",ink_runtime_Json.DictionaryRuntimeObjsToJObject(el.temporaryVariables));
			jThreadCallstack.push(jObj);
		}
		threadJObj.callstack = jThreadCallstack;
		threadJObj.threadIndex = this.threadIndex;
		if(this.previousContentObject != null) Reflect.setField(threadJObj,"previousContentObject",Std.string(this.previousContentObject.get_path()));
		return threadJObj;
	}
	,__class__: ink_runtime_Thread
	,__properties__: {get_jsonToken:"get_jsonToken"}
};
var ink_runtime_Object = function() {
};
ink_runtime_Object.__name__ = ["ink","runtime","Object"];
ink_runtime_Object.EQUALS = function(a,b) {
	return a == b;
};
ink_runtime_Object.notEquals = function(a,b) {
	return !(a == b);
};
ink_runtime_Object.prototype = {
	get_debugMetadata: function() {
		if(this._debugMetadata == null) {
			if(this.parent != null) return this.parent.get_debugMetadata();
		}
		return this._debugMetadata;
	}
	,set_debugMetadata: function(value) {
		return this._debugMetadata = value;
	}
	,DebugLineNumberOfPath: function(path) {
		if(path == null) return null;
		var root = this.get_rootContentContainer();
		if(root != null) {
			var targetContent = root.ContentAtPath(path);
			if(targetContent != null) {
				var dm = targetContent.get_debugMetadata();
				if(dm != null) return dm.startLineNumber;
			}
		}
		return null;
	}
	,get_path: function() {
		if(this._path == null) {
			if(this.parent == null) this._path = new ink_runtime_Path(); else {
				var comps = [];
				var child = this;
				var container = ink_runtime_LibUtil["as"](child.parent,ink_runtime_Container);
				while(container != null) {
					var namedChild;
					namedChild = js_Boot.__instanceof(child,ink_runtime_INamedContent)?child:null;
					if(namedChild != null && namedChild.hasValidName) comps.push(ink_runtime_Component.createFromName(namedChild.name)); else comps.push(ink_runtime_Component.createFromIndex(HxOverrides.indexOf(container._content,child,0)));
					child = container;
					container = ink_runtime_LibUtil["as"](container.parent,ink_runtime_Container);
				}
				this._path = ink_runtime_Path.createFromComponents(comps);
			}
		}
		return this._path;
	}
	,ResolvePath: function(path) {
		if(path.isRelative) {
			var nearestContainer;
			nearestContainer = js_Boot.__instanceof(this,ink_runtime_Container)?this:null;
			if(nearestContainer == null) {
				ink_runtime_Assert.bool(this.parent != null,"Can't resolve relative path because we don't have a parent");
				nearestContainer = ink_runtime_LibUtil["as"](this.parent,ink_runtime_Container);
				ink_runtime_Assert.bool(nearestContainer != null,"Expected parent to be a container");
				ink_runtime_Assert.bool(path.components[0].isParent,"Is parent assertion failed");
				path = path.tail;
			}
			return nearestContainer.ContentAtPath(path);
		} else return this.get_rootContentContainer().ContentAtPath(path);
	}
	,ConvertPathToRelative: function(globalPath) {
		var ownPath = this.get_path();
		var minPathLength = ink_runtime_LibUtil.minI(globalPath.components.length,ownPath.components.length);
		var lastSharedPathCompIndex = -1;
		var _g = 0;
		while(_g < minPathLength) {
			var i = _g++;
			var ownComp = ownPath.components[i];
			var otherComp = globalPath.components[i];
			if(ownComp.Equals(otherComp)) lastSharedPathCompIndex = i; else break;
		}
		if(lastSharedPathCompIndex == -1) return globalPath;
		var numUpwardsMoves = ownPath.components.length - 1 - lastSharedPathCompIndex;
		var newPathComps = [];
		var _g1 = 0;
		while(_g1 < numUpwardsMoves) {
			var up = _g1++;
			newPathComps.push(ink_runtime_Component.ToParent());
		}
		var _g11 = lastSharedPathCompIndex + 1;
		var _g2 = globalPath.components.length;
		while(_g11 < _g2) {
			var down = _g11++;
			newPathComps.push(globalPath.components[down]);
		}
		var relativePath = ink_runtime_Path.createFromComponents(newPathComps,true);
		return relativePath;
	}
	,CompactPathString: function(otherPath) {
		var globalPathStr = null;
		var relativePathStr = null;
		if(otherPath.isRelative) {
			relativePathStr = otherPath.componentsString;
			globalPathStr = this.get_path().PathByAppendingPath(otherPath).componentsString;
		} else {
			var relativePath = this.ConvertPathToRelative(otherPath);
			relativePathStr = relativePath.componentsString;
			globalPathStr = otherPath.componentsString;
		}
		if(relativePathStr.length < globalPathStr.length) return relativePathStr; else return globalPathStr;
	}
	,get_rootContentContainer: function() {
		var ancestor = this;
		while(ancestor.parent != null) ancestor = ancestor.parent;
		return js_Boot.__instanceof(ancestor,ink_runtime_Container)?ancestor:null;
	}
	,Copy: function() {
		throw new js__$Boot_HaxeError(new ink_runtime_SystemNotImplementedException((function($this) {
			var $r;
			var e = Type["typeof"]($this);
			$r = e[0];
			return $r;
		}(this)) + " doesn't support copying"));
	}
	,SetChildReturnValue: function(obj,value) {
		if(obj != null) obj.parent = null;
		obj = value;
		if(obj != null) obj.parent = this;
		return value;
	}
	,Equals: function(obj) {
		return obj == this;
	}
	,__class__: ink_runtime_Object
	,__properties__: {get_rootContentContainer:"get_rootContentContainer",get_path:"get_path",set_debugMetadata:"set_debugMetadata",get_debugMetadata:"get_debugMetadata"}
};
var ink_runtime_Choice = function() {
	ink_runtime_Object.call(this);
};
ink_runtime_Choice.__name__ = ["ink","runtime","Choice"];
ink_runtime_Choice.create = function(choice) {
	var me = new ink_runtime_Choice();
	me.choicePoint = choice;
	return me;
};
ink_runtime_Choice.__super__ = ink_runtime_Object;
ink_runtime_Choice.prototype = $extend(ink_runtime_Object.prototype,{
	get_pathStringOnChoice: function() {
		return this.choicePoint.get_pathStringOnChoice();
	}
	,__class__: ink_runtime_Choice
	,__properties__: $extend(ink_runtime_Object.prototype.__properties__,{get_pathStringOnChoice:"get_pathStringOnChoice"})
});
var ink_runtime_ChoicePoint = function() {
	ink_runtime_Object.call(this);
	this.onceOnly = true;
};
ink_runtime_ChoicePoint.__name__ = ["ink","runtime","ChoicePoint"];
ink_runtime_ChoicePoint.createOnceOnly = function(onceOnly) {
	var me = new ink_runtime_ChoicePoint();
	me.onceOnly = onceOnly;
	return me;
};
ink_runtime_ChoicePoint.__super__ = ink_runtime_Object;
ink_runtime_ChoicePoint.prototype = $extend(ink_runtime_Object.prototype,{
	get_choiceTarget: function() {
		return ink_runtime_LibUtil.asNoInline(this.ResolvePath(this.pathOnChoice),ink_runtime_Container);
	}
	,get_pathStringOnChoice: function() {
		return this.CompactPathString(this.pathOnChoice);
	}
	,set_pathStringOnChoice: function(value) {
		return this.CompactPathString(this.pathOnChoice = ink_runtime_Path.createFromString(value));
	}
	,get_flags: function() {
		var flags = 0;
		if(this.hasCondition) flags |= 1;
		if(this.hasStartContent) flags |= 2;
		if(this.hasChoiceOnlyContent) flags |= 4;
		if(this.isInvisibleDefault) flags |= 8;
		if(this.onceOnly) flags |= 16;
		return flags;
	}
	,set_flags: function(value) {
		var flags = 0;
		if(this.hasCondition = (value & 1) > 0) flags |= 1; else flags |= 0;
		if(this.hasStartContent = (value & 2) > 0) flags |= 2; else flags |= 0;
		if(this.hasChoiceOnlyContent = (value & 4) > 0) flags |= 4; else flags |= 0;
		if(this.isInvisibleDefault = (value & 8) > 0) flags |= 8; else flags |= 0;
		if(this.onceOnly = (value & 16) > 0) flags |= 16; else flags |= 0;
		return flags;
	}
	,toString: function() {
		var targetLineNum = this.DebugLineNumberOfPath(this.pathOnChoice);
		var targetString = this.pathOnChoice.toString();
		if(targetLineNum != null) targetString = " line " + Std.string(targetLineNum);
		return "Choice: -> " + targetString;
	}
	,__class__: ink_runtime_ChoicePoint
	,__properties__: $extend(ink_runtime_Object.prototype.__properties__,{set_flags:"set_flags",get_flags:"get_flags",set_pathStringOnChoice:"set_pathStringOnChoice",get_pathStringOnChoice:"get_pathStringOnChoice",get_choiceTarget:"get_choiceTarget"})
});
var ink_runtime_Cloner = function() {
	this.stringMapCloner = new ink_runtime_MapCloner(this,haxe_ds_StringMap);
	this.intMapCloner = new ink_runtime_MapCloner(this,haxe_ds_IntMap);
	this.classHandles = new haxe_ds_StringMap();
	this.classHandles.set("String",$bind(this,this.returnString));
	this.classHandles.set("Array",$bind(this,this.cloneArray));
	this.classHandles.set("haxe.ds.StringMap",($_=this.stringMapCloner,$bind($_,$_.clone)));
	this.classHandles.set("haxe.ds.IntMap",($_=this.intMapCloner,$bind($_,$_.clone)));
};
ink_runtime_Cloner.__name__ = ["ink","runtime","Cloner"];
ink_runtime_Cloner.prototype = {
	returnString: function(v) {
		return v;
	}
	,clone: function(v) {
		this.cache = new haxe_ds_ObjectMap();
		var outcome = this._clone(v);
		this.cache = null;
		return outcome;
	}
	,_clone: function(v) {
		if(Type.getClassName(v) != null) return v;
		{
			var _g = Type["typeof"](v);
			switch(_g[1]) {
			case 0:
				return null;
			case 1:
				return v;
			case 2:
				return v;
			case 3:
				return v;
			case 4:
				return this.handleAnonymous(v);
			case 5:
				return null;
			case 6:
				var c = _g[2];
				if(!(this.cache.h.__keys__[v.__id__] != null)) this.cache.set(v,this.handleClass(c,v));
				return this.cache.h[v.__id__];
			case 7:
				var e = _g[2];
				return v;
			case 8:
				return null;
			}
		}
	}
	,handleAnonymous: function(v) {
		var properties = Reflect.fields(v);
		var anonymous = { };
		var _g1 = 0;
		var _g = properties.length;
		while(_g1 < _g) {
			var i = _g1++;
			var property = properties[i];
			Reflect.setField(anonymous,property,this._clone(Reflect.getProperty(v,property)));
		}
		return anonymous;
	}
	,handleClass: function(c,inValue) {
		var handle;
		var key = Type.getClassName(c);
		handle = this.classHandles.get(key);
		if(handle == null) handle = $bind(this,this.cloneClass);
		return handle(inValue);
	}
	,cloneArray: function(inValue) {
		var array = inValue.slice();
		var _g1 = 0;
		var _g = array.length;
		while(_g1 < _g) {
			var i = _g1++;
			array[i] = this._clone(array[i]);
		}
		return array;
	}
	,cloneClass: function(inValue) {
		var outValue = Type.createEmptyInstance(inValue == null?null:js_Boot.getClass(inValue));
		var fields = Reflect.fields(inValue);
		var _g1 = 0;
		var _g = fields.length;
		while(_g1 < _g) {
			var i = _g1++;
			var field = fields[i];
			var property = Reflect.getProperty(inValue,field);
			Reflect.setField(outValue,field,this._clone(property));
		}
		return outValue;
	}
	,__class__: ink_runtime_Cloner
};
var ink_runtime_CountFlags = function() { };
ink_runtime_CountFlags.__name__ = ["ink","runtime","CountFlags"];
var ink_runtime_Container = function() {
	ink_runtime_Object.call(this);
	this._content = [];
	this.namedContent = new haxe_ds_StringMap();
};
ink_runtime_Container.__name__ = ["ink","runtime","Container"];
ink_runtime_Container.__super__ = ink_runtime_Object;
ink_runtime_Container.prototype = $extend(ink_runtime_Object.prototype,{
	get_content: function() {
		return this._content;
	}
	,set_content: function(value) {
		this.AddContentList(value);
		return this._content;
	}
	,get_namedOnlyContent: function() {
		var namedOnlyContent = new haxe_ds_StringMap();
		var $it0 = this.namedContent.keys();
		while( $it0.hasNext() ) {
			var k = $it0.next();
			var value = this.namedContent.get(k);
			if(__map_reserved[k] != null) namedOnlyContent.setReserved(k,value); else namedOnlyContent.h[k] = value;
		}
		var _g1 = 0;
		var _g = this._content.length;
		while(_g1 < _g) {
			var i = _g1++;
			var c = this._content[i];
			var named;
			named = js_Boot.__instanceof(c,ink_runtime_INamedContent)?c:null;
			if(named != null && named.hasValidName) namedOnlyContent.remove(named.name);
		}
		if(!new haxe_ds__$StringMap_StringMapIterator(namedOnlyContent,namedOnlyContent.arrayKeys()).hasNext()) namedOnlyContent = null;
		return namedOnlyContent;
	}
	,set_namedOnlyContent: function(value) {
		var existingNamedOnly = this.get_namedOnlyContent();
		if(existingNamedOnly != null) {
			var $it0 = existingNamedOnly.keys();
			while( $it0.hasNext() ) {
				var k = $it0.next();
				this.namedContent.remove(k);
			}
		}
		if(value == null) return existingNamedOnly;
		var $it1 = value.keys();
		while( $it1.hasNext() ) {
			var k1 = $it1.next();
			var named = ink_runtime_LibUtil["as"](__map_reserved[k1] != null?value.getReserved(k1):value.h[k1],ink_runtime_INamedContent);
			if(named != null) this.AddToNamedContentOnly(named);
		}
		return existingNamedOnly;
	}
	,get_countFlags: function() {
		var flags = 0;
		var flagged = 1;
		if(this.visitsShouldBeCounted) flags |= 1;
		if(this.turnIndexShouldBeCounted) flags |= 2;
		if(this.countingAtStartOnly) flags |= 4;
		if(flags == 4) flags = 0;
		return flags;
	}
	,set_countFlags: function(value) {
		var flag = value;
		if((flag & 1) > 0) this.visitsShouldBeCounted = true;
		if((flag & 2) > 0) this.turnIndexShouldBeCounted = true;
		if((flag & 4) > 0) this.countingAtStartOnly = true;
		return this.get_countFlags();
	}
	,get_hasValidName: function() {
		return this.name != null && this.name.length > 0;
	}
	,get_pathToFirstLeafContent: function() {
		if(this._pathToFirstLeafContent == null) this._pathToFirstLeafContent = this.get_path().PathByAppendingPath(this.get_internalPathToFirstLeafContent());
		return this._pathToFirstLeafContent;
	}
	,get_internalPathToFirstLeafContent: function() {
		var path = new ink_runtime_Path();
		var container = this;
		while(container != null) if(container._content.length > 0) {
			path.components.push(ink_runtime_Component.createFromIndex(0));
			container = ink_runtime_LibUtil["as"](container._content[0],ink_runtime_Container);
		}
		return path;
	}
	,AddToNamedContentOnly: function(namedContentObj) {
		ink_runtime_Assert.bool(js_Boot.__instanceof(namedContentObj,ink_runtime_Object),"Can only add Runtime.Objects to a Runtime.Container");
		var runtimeObj = namedContentObj;
		runtimeObj.parent = this;
		this.namedContent.set(namedContentObj.name,namedContentObj);
	}
	,AddContent: function(contentObj) {
		this._content.push(contentObj);
		if(contentObj.parent != null) throw new js__$Boot_HaxeError(new ink_runtime_SystemException("content is already in " + Std.string(contentObj.parent)));
		contentObj.parent = this;
		this.TryAddNamedContent(contentObj);
	}
	,AddContentList: function(contentList) {
		var _g = 0;
		while(_g < contentList.length) {
			var c = contentList[_g];
			++_g;
			this.AddContent(c);
		}
	}
	,InsertContent: function(contentObj,index) {
		this._content.splice(index,0,contentObj);
		if(contentObj.parent != null) throw new js__$Boot_HaxeError(new ink_runtime_SystemException("content is already in " + Std.string(contentObj.parent)));
		contentObj.parent = this;
		this.TryAddNamedContent(contentObj);
	}
	,TryAddNamedContent: function(contentObj) {
		var namedContentObj;
		namedContentObj = js_Boot.__instanceof(contentObj,ink_runtime_INamedContent)?contentObj:null;
		if(namedContentObj != null && namedContentObj.hasValidName) this.AddToNamedContentOnly(namedContentObj);
	}
	,AddContentsOfContainer: function(otherContainer) {
		ink_runtime_LibUtil.addRangeForArray(this._content,otherContainer._content);
		var _g = 0;
		var _g1 = otherContainer._content;
		while(_g < _g1.length) {
			var obj = _g1[_g];
			++_g;
			obj.parent = this;
			this.TryAddNamedContent(obj);
		}
	}
	,ContentWithPathComponent: function(component) {
		if(component.isIndex) {
			if(component.index >= 0 && component.index < this._content.length) return this._content[component.index]; else return null;
		} else if(component.isParent) return this.parent; else {
			var foundContent = null;
			foundContent = ink_runtime_LibUtil.tryGetValueINamedContent(this.namedContent,component.name);
			if(foundContent != null) return foundContent; else throw new js__$Boot_HaxeError(new ink_runtime_StoryException("Content '" + component.name + "' not found at path: '" + Std.string(this.get_path()) + "'"));
		}
	}
	,ContentAtPath: function(path,partialPathLength) {
		if(partialPathLength == null) partialPathLength = -1;
		if(partialPathLength == -1) partialPathLength = path.components.length;
		var currentContainer = this;
		var currentObj = this;
		var _g = 0;
		while(_g < partialPathLength) {
			var i = _g++;
			var comp = path.components[i];
			if(currentContainer == null) throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Path continued, but previous object wasn't a container: " + Std.string(currentObj)));
			currentObj = currentContainer.ContentWithPathComponent(comp);
			currentContainer = js_Boot.__instanceof(currentObj,ink_runtime_Container)?currentObj:null;
		}
		return currentObj;
	}
	,BuildStringOfHierarchy: function(sb,indentation,pointedObj) {
		var appendIndentation = function() {
			var spacesPerIndent = 4;
			var _g1 = 0;
			var _g = spacesPerIndent * indentation;
			while(_g1 < _g) {
				var i = _g1++;
				sb.b += " ";
			}
		};
		appendIndentation();
		sb.b += "[";
		if(this.get_hasValidName()) sb.b += Std.string(" (" + this.name + ")");
		if(this == pointedObj) sb.b += "  <---";
		sb.b += "\n";
		indentation++;
		var _g11 = 0;
		var _g2 = this._content.length;
		while(_g11 < _g2) {
			var i1 = _g11++;
			var obj = this._content[i1];
			if(js_Boot.__instanceof(obj,ink_runtime_Container)) {
				var container = obj;
				container.BuildStringOfHierarchy(sb,indentation,pointedObj);
			} else {
				appendIndentation();
				if(js_Boot.__instanceof(obj,ink_runtime_StringValue)) {
					sb.b += "\"";
					sb.add(StringTools.replace(Std.string(obj),"\n","\\n"));
					sb.b += "\"";
				} else sb.b += Std.string(Std.string(obj));
			}
			if(i1 != this._content.length - 1) sb.b += ",";
			if(!js_Boot.__instanceof(obj,ink_runtime_Container) && obj == pointedObj) sb.b += "  <---";
			sb.b += "\n";
		}
		var onlyNamed = new haxe_ds_StringMap();
		var $it0 = this.namedContent.keys();
		while( $it0.hasNext() ) {
			var k = $it0.next();
			if((function($this) {
				var $r;
				var x = $this.namedContent.get(k);
				$r = HxOverrides.indexOf($this._content,x,0);
				return $r;
			}(this)) >= 0) continue; else {
				var value = this.namedContent.get(k);
				if(__map_reserved[k] != null) onlyNamed.setReserved(k,value); else onlyNamed.h[k] = value;
			}
		}
		if(new haxe_ds__$StringMap_StringMapIterator(onlyNamed,onlyNamed.arrayKeys()).hasNext()) {
			appendIndentation();
			sb.b += Std.string("-- named: --" + "\n");
			var $it1 = onlyNamed.keys();
			while( $it1.hasNext() ) {
				var k1 = $it1.next();
				var objV;
				objV = __map_reserved[k1] != null?onlyNamed.getReserved(k1):onlyNamed.h[k1];
				ink_runtime_Assert.bool(js_Boot.__instanceof(objV,ink_runtime_Container),"Can only print out named Containers");
				var container1 = objV;
				container1.BuildStringOfHierarchy(sb,indentation,pointedObj);
				sb.b += "\n";
			}
		}
		indentation--;
		appendIndentation();
		sb.b += "]";
	}
	,BuildStringOfHierarchyVirtual: function() {
		var sb = new StringBuf();
		this.BuildStringOfHierarchy(sb,0,null);
		return sb.b;
	}
	,__class__: ink_runtime_Container
	,__properties__: $extend(ink_runtime_Object.prototype.__properties__,{get_internalPathToFirstLeafContent:"get_internalPathToFirstLeafContent",get_pathToFirstLeafContent:"get_pathToFirstLeafContent",get_hasValidName:"get_hasValidName",set_countFlags:"set_countFlags",get_countFlags:"get_countFlags",set_namedOnlyContent:"set_namedOnlyContent",get_namedOnlyContent:"get_namedOnlyContent",set_content:"set_content",get_content:"get_content"})
});
var ink_runtime_ControlCommand = function() {
	ink_runtime_Object.call(this);
	this.commandType = -1;
};
ink_runtime_ControlCommand.__name__ = ["ink","runtime","ControlCommand"];
ink_runtime_ControlCommand.createFromCommandType = function(commandType) {
	var me = new ink_runtime_ControlCommand();
	me.commandType = commandType;
	return me;
};
ink_runtime_ControlCommand.EvalStart = function() {
	return ink_runtime_ControlCommand.createFromCommandType(0);
};
ink_runtime_ControlCommand.EvalOutput = function() {
	return ink_runtime_ControlCommand.createFromCommandType(1);
};
ink_runtime_ControlCommand.EvalEnd = function() {
	return ink_runtime_ControlCommand.createFromCommandType(2);
};
ink_runtime_ControlCommand.Duplicate = function() {
	return ink_runtime_ControlCommand.createFromCommandType(3);
};
ink_runtime_ControlCommand.PopEvaluatedValue = function() {
	return ink_runtime_ControlCommand.createFromCommandType(4);
};
ink_runtime_ControlCommand.PopFunction = function() {
	return ink_runtime_ControlCommand.createFromCommandType(5);
};
ink_runtime_ControlCommand.PopTunnel = function() {
	return ink_runtime_ControlCommand.createFromCommandType(6);
};
ink_runtime_ControlCommand.BeginString = function() {
	return ink_runtime_ControlCommand.createFromCommandType(7);
};
ink_runtime_ControlCommand.EndString = function() {
	return ink_runtime_ControlCommand.createFromCommandType(8);
};
ink_runtime_ControlCommand.NoOp = function() {
	return ink_runtime_ControlCommand.createFromCommandType(9);
};
ink_runtime_ControlCommand.ChoiceCount = function() {
	return ink_runtime_ControlCommand.createFromCommandType(10);
};
ink_runtime_ControlCommand.TurnsSince = function() {
	return ink_runtime_ControlCommand.createFromCommandType(11);
};
ink_runtime_ControlCommand.VisitIndex = function() {
	return ink_runtime_ControlCommand.createFromCommandType(12);
};
ink_runtime_ControlCommand.SequenceShuffleIndex = function() {
	return ink_runtime_ControlCommand.createFromCommandType(13);
};
ink_runtime_ControlCommand.StartThread = function() {
	return ink_runtime_ControlCommand.createFromCommandType(14);
};
ink_runtime_ControlCommand.Done = function() {
	return ink_runtime_ControlCommand.createFromCommandType(15);
};
ink_runtime_ControlCommand.End = function() {
	return ink_runtime_ControlCommand.createFromCommandType(16);
};
ink_runtime_ControlCommand.__super__ = ink_runtime_Object;
ink_runtime_ControlCommand.prototype = $extend(ink_runtime_Object.prototype,{
	Copy: function() {
		return ink_runtime_ControlCommand.createFromCommandType(this.commandType);
	}
	,ToString: function() {
		return Std.string(this.commandType);
	}
	,toString: function() {
		return Std.string(this.commandType);
	}
	,__class__: ink_runtime_ControlCommand
});
var ink_runtime_DebugMetadata = function() {
	this.sourceName = null;
	this.fileName = null;
	this.endLineNumber = 0;
	this.startLineNumber = 0;
};
ink_runtime_DebugMetadata.__name__ = ["ink","runtime","DebugMetadata"];
ink_runtime_DebugMetadata.prototype = {
	toString: function() {
		if(this.fileName != null) return "line " + this.startLineNumber + " of " + this.fileName; else return "line " + this.startLineNumber;
	}
	,__class__: ink_runtime_DebugMetadata
};
var ink_runtime_Divert = function() {
	ink_runtime_Object.call(this);
	this.pushesToStack = false;
};
ink_runtime_Divert.__name__ = ["ink","runtime","Divert"];
ink_runtime_Divert.createFromPushType = function(stackPushType) {
	var me = new ink_runtime_Divert();
	me.pushesToStack = true;
	me.stackPushType = stackPushType;
	return me;
};
ink_runtime_Divert.__super__ = ink_runtime_Object;
ink_runtime_Divert.prototype = $extend(ink_runtime_Object.prototype,{
	get_targetPath: function() {
		if(this._targetPath != null && this._targetPath.isRelative) {
			var targetObj = this.get_targetContent();
			if(targetObj != null) this._targetPath = targetObj.get_path();
		}
		return this._targetPath;
	}
	,set_targetPath: function(value) {
		this._targetPath = value;
		this._targetContent = null;
		return value;
	}
	,get_targetContent: function() {
		if(this._targetContent == null) this._targetContent = this.ResolvePath(this._targetPath);
		return this._targetContent;
	}
	,get_targetPathString: function() {
		if(this.get_targetPath() == null) return null;
		return this.CompactPathString(this.get_targetPath());
	}
	,set_targetPathString: function(value) {
		if(value == null) this.set_targetPath(null); else this.set_targetPath(ink_runtime_Path.createFromString(value));
		return value;
	}
	,get_hasVariableTarget: function() {
		return this.variableDivertName != null;
	}
	,Equals: function(obj) {
		var otherDivert;
		otherDivert = js_Boot.__instanceof(obj,ink_runtime_Divert)?obj:null;
		if(otherDivert != null) {
			if(this.get_hasVariableTarget() == otherDivert.get_hasVariableTarget()) {
				if(this.get_hasVariableTarget()) return this.variableDivertName == otherDivert.variableDivertName; else return this.get_targetPath().Equals(otherDivert.get_targetPath());
			}
		}
		return false;
	}
	,toString: function() {
		if(this.get_hasVariableTarget()) return "Divert(variable: " + this.variableDivertName + ")"; else if(this.get_targetPath() == null) return "Divert(null)"; else {
			var sb_b = "";
			var targetStr = this.get_targetPath().toString();
			var targetLineNum = this.DebugLineNumberOfPath(this.get_targetPath());
			if(targetLineNum != null) targetStr = "line " + targetLineNum;
			sb_b += "Divert";
			if(this.pushesToStack) {
				if(this.stackPushType == 1) sb_b += " function"; else sb_b += " tunnel";
			}
			sb_b += " (";
			if(targetStr == null) sb_b += "null"; else sb_b += "" + targetStr;
			sb_b += ")";
			return sb_b;
		}
	}
	,__class__: ink_runtime_Divert
	,__properties__: $extend(ink_runtime_Object.prototype.__properties__,{get_hasVariableTarget:"get_hasVariableTarget",set_targetPathString:"set_targetPathString",get_targetPathString:"get_targetPathString",get_targetContent:"get_targetContent",set_targetPath:"set_targetPath",get_targetPath:"get_targetPath"})
});
var ink_runtime_GlueType = { __ename__ : true, __constructs__ : ["Bidirectional","Left","Right"] };
ink_runtime_GlueType.Bidirectional = ["Bidirectional",0];
ink_runtime_GlueType.Bidirectional.toString = $estr;
ink_runtime_GlueType.Bidirectional.__enum__ = ink_runtime_GlueType;
ink_runtime_GlueType.Left = ["Left",1];
ink_runtime_GlueType.Left.toString = $estr;
ink_runtime_GlueType.Left.__enum__ = ink_runtime_GlueType;
ink_runtime_GlueType.Right = ["Right",2];
ink_runtime_GlueType.Right.toString = $estr;
ink_runtime_GlueType.Right.__enum__ = ink_runtime_GlueType;
var ink_runtime_Glue = function(type) {
	ink_runtime_Object.call(this);
	this.glueType = type;
};
ink_runtime_Glue.__name__ = ["ink","runtime","Glue"];
ink_runtime_Glue.__super__ = ink_runtime_Object;
ink_runtime_Glue.prototype = $extend(ink_runtime_Object.prototype,{
	get_isLeft: function() {
		return this.glueType == ink_runtime_GlueType.Left;
	}
	,get_isBi: function() {
		return this.glueType == ink_runtime_GlueType.Bidirectional;
	}
	,get_isRight: function() {
		return this.glueType == ink_runtime_GlueType.Right;
	}
	,toString: function() {
		var _g = this.glueType;
		switch(_g[1]) {
		case 0:
			return "BidirGlue";
		case 1:
			return "LeftGlue";
		case 2:
			return "RightGlue";
		}
		return "UnexpectedGlueType";
	}
	,__class__: ink_runtime_Glue
	,__properties__: $extend(ink_runtime_Object.prototype.__properties__,{get_isRight:"get_isRight",get_isBi:"get_isBi",get_isLeft:"get_isLeft"})
});
var ink_runtime_INamedContent = function() { };
ink_runtime_INamedContent.__name__ = ["ink","runtime","INamedContent"];
ink_runtime_INamedContent.prototype = {
	__class__: ink_runtime_INamedContent
};
var ink_runtime_Json = function() {
	ink_runtime_Json._controlCommandNames = [];
	ink_runtime_Json._controlCommandNames[0] = "ev";
	ink_runtime_Json._controlCommandNames[1] = "out";
	ink_runtime_Json._controlCommandNames[2] = "/ev";
	ink_runtime_Json._controlCommandNames[3] = "du";
	ink_runtime_Json._controlCommandNames[4] = "pop";
	ink_runtime_Json._controlCommandNames[5] = "~ret";
	ink_runtime_Json._controlCommandNames[6] = "->->";
	ink_runtime_Json._controlCommandNames[7] = "str";
	ink_runtime_Json._controlCommandNames[8] = "/str";
	ink_runtime_Json._controlCommandNames[9] = "nop";
	ink_runtime_Json._controlCommandNames[10] = "choiceCnt";
	ink_runtime_Json._controlCommandNames[11] = "turns";
	ink_runtime_Json._controlCommandNames[12] = "visit";
	ink_runtime_Json._controlCommandNames[13] = "seq";
	ink_runtime_Json._controlCommandNames[14] = "thread";
	ink_runtime_Json._controlCommandNames[15] = "done";
	ink_runtime_Json._controlCommandNames[16] = "end";
	var len = 17;
	var _g = 0;
	while(_g < len) {
		var i = _g++;
		if(ink_runtime_Json._controlCommandNames[i] == null) throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Control command not accounted for in serialisation"));
	}
};
ink_runtime_Json.__name__ = ["ink","runtime","Json"];
ink_runtime_Json.ListToJArray = function(serialisables) {
	var jArray = [];
	var _g = 0;
	while(_g < jArray.length) {
		var s = jArray[_g];
		++_g;
		jArray.push(ink_runtime_Json.RuntimeObjectToJToken(jArray[s]));
	}
	return jArray;
};
ink_runtime_Json.JArrayToRuntimeObjList = function(jArray,skipLast) {
	if(skipLast == null) skipLast = false;
	var count = jArray.length;
	if(skipLast) count--;
	var list = [];
	var _g = 0;
	while(_g < count) {
		var i = _g++;
		var jTok = jArray[i];
		var runtimeObj = ink_runtime_LibUtil["as"](ink_runtime_Json.JTokenToRuntimeObject(jTok),ink_runtime_Object);
		list.push(runtimeObj);
	}
	return list;
};
ink_runtime_Json.DictionaryRuntimeObjsToJObject = function(dictionary) {
	var jsonObj = new haxe_ds_StringMap();
	var $it0 = dictionary.keys();
	while( $it0.hasNext() ) {
		var k = $it0.next();
		var runtimeObj = ink_runtime_LibUtil["as"](__map_reserved[k] != null?dictionary.getReserved(k):dictionary.h[k],ink_runtime_Object);
		if(runtimeObj != null) {
			var value = ink_runtime_Json.RuntimeObjectToJToken(runtimeObj);
			jsonObj.set(k,value);
		}
	}
	return jsonObj;
};
ink_runtime_Json.JObjectToDictionaryRuntimeObjs = function(jObject) {
	var dict = new haxe_ds_StringMap();
	var _g = 0;
	var _g1 = Reflect.fields(jObject);
	while(_g < _g1.length) {
		var k = _g1[_g];
		++_g;
		var value = ink_runtime_Json.JTokenToRuntimeObject(Reflect.field(jObject,k));
		if(__map_reserved[k] != null) dict.setReserved(k,value); else dict.h[k] = value;
	}
	return dict;
};
ink_runtime_Json.JObjectToIntDictionary = function(jObject) {
	var dict = new haxe_ds_StringMap();
	var _g = 0;
	var _g1 = Reflect.fields(jObject);
	while(_g < _g1.length) {
		var k = _g1[_g];
		++_g;
		var value = Std["int"](Reflect.field(jObject,k));
		if(__map_reserved[k] != null) dict.setReserved(k,value); else dict.h[k] = value;
	}
	return dict;
};
ink_runtime_Json.IntDictionaryToJObject = function(dict) {
	var jObj = { };
	var $it0 = dict.keys();
	while( $it0.hasNext() ) {
		var k = $it0.next();
		Reflect.setField(jObj,k,__map_reserved[k] != null?dict.getReserved(k):dict.h[k]);
	}
	return jObj;
};
ink_runtime_Json.JTokenToRuntimeObject = function(token) {
	if(((token | 0) === token) || typeof(token) == "number") return ink_runtime_Value.Create(token);
	if(typeof(token) == "string") {
		var str = token;
		var firstChar = str.charAt(0);
		if(firstChar == "^") return new ink_runtime_StringValue(str.substring(1)); else if(firstChar == "\n" && str.length == 1) return new ink_runtime_StringValue("\n");
		if(str == "<>") return new ink_runtime_Glue(ink_runtime_GlueType.Bidirectional); else if(str == "G<") return new ink_runtime_Glue(ink_runtime_GlueType.Left); else if(str == "G>") return new ink_runtime_Glue(ink_runtime_GlueType.Right);
		var _g1 = 0;
		var _g = ink_runtime_Json._controlCommandNames.length;
		while(_g1 < _g) {
			var i = _g1++;
			var cmdName = ink_runtime_Json._controlCommandNames[i];
			if(str == cmdName) return ink_runtime_ControlCommand.createFromCommandType(i);
		}
		if(ink_runtime_NativeFunctionCall.CallExistsWithName(str)) return ink_runtime_NativeFunctionCall.CallWithName(str);
		if(str == "->->") return ink_runtime_ControlCommand.PopTunnel(); else if(str == "~ret") return ink_runtime_ControlCommand.PopFunction();
		if(str == "void") return new ink_runtime_VoidObj();
	}
	if(js_Boot.__instanceof(token,Dynamic)) {
		var obj = token;
		var propValue;
		propValue = Reflect.field(obj,"^->");
		if(propValue != null) return new ink_runtime_DivertTargetValue(ink_runtime_Path.createFromString(Std.string(propValue)));
		propValue = Reflect.field(obj,"^var");
		if(propValue != null) {
			var varPtr = new ink_runtime_VariablePointerValue(Std.string(propValue));
			if((propValue = Reflect.field(obj,"ci")) != null) varPtr.contextIndex = Std["int"](propValue);
			return varPtr;
		}
		var isDivert = false;
		var pushesToStack = false;
		var divPushType = 1;
		var external = false;
		propValue = Reflect.field(obj,"->");
		if(propValue != null) isDivert = true; else if((propValue = Reflect.field(obj,"f()")) != null) {
			isDivert = true;
			pushesToStack = true;
			divPushType = 1;
		} else if((propValue = Reflect.field(obj,"->t->")) != null) {
			isDivert = true;
			pushesToStack = true;
			divPushType = 0;
		} else if((propValue = Reflect.field(obj,"x()")) != null) {
			isDivert = true;
			external = true;
			pushesToStack = false;
			divPushType = 1;
		}
		if(isDivert) {
			var divert = new ink_runtime_Divert();
			divert.pushesToStack = pushesToStack;
			divert.stackPushType = divPushType;
			divert.isExternal = external;
			var target = Std.string(propValue);
			if((propValue = Reflect.field(obj,"var")) != null) divert.variableDivertName = target; else divert.set_targetPathString(target);
			divert.isConditional = propValue = Reflect.field(obj,"c");
			if(external) {
				if((propValue = Reflect.field(obj,"exArgs")) != null) divert.externalArgs = Std["int"](propValue);
			}
			return divert;
		}
		if((propValue = Reflect.field(obj,"*")) != null) {
			var choice = new ink_runtime_ChoicePoint();
			choice.set_pathStringOnChoice(Std.string(propValue));
			if((propValue = Reflect.field(obj,"flg")) != null) choice.set_flags(Std["int"](propValue));
			return choice;
		}
		if((propValue = Reflect.field(obj,"VAR?")) != null) return ink_runtime_VariableReference.create(Std.string(propValue)); else if((propValue = Reflect.field(obj,"CNT?")) != null) {
			var readCountVarRef = new ink_runtime_VariableReference();
			readCountVarRef.set_pathStringForCount(Std.string(propValue));
			return readCountVarRef;
		}
		var isVarAss = false;
		var isGlobalVar = false;
		if((propValue = Reflect.field(obj,"VAR=")) != null) {
			isVarAss = true;
			isGlobalVar = true;
		} else if((propValue = Reflect.field(obj,"temp=")) != null) {
			isVarAss = true;
			isGlobalVar = false;
		}
		if(isVarAss) {
			var varName = propValue.ToString();
			var isNewDecl = (propValue = Reflect.field(obj,"re")) == null;
			var varAss = new ink_runtime_VariableAssignment(varName,isNewDecl);
			varAss.isGlobal = isGlobalVar;
			return varAss;
		}
		if(Reflect.field(obj,"originalChoicePath") != null) return ink_runtime_Json.JObjectToChoice(obj);
	}
	if((token instanceof Array) && token.__enum__ == null) return ink_runtime_Json.JArrayToContainer(token);
	if(token == null) return null;
	throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Failed to convert token to runtime object: " + Std.string(token)));
};
ink_runtime_Json.RuntimeObjectToJToken = function(obj) {
	var container;
	container = js_Boot.__instanceof(obj,ink_runtime_Container)?obj:null;
	if(container != null) return ink_runtime_Json.ContainerToJArray(container);
	var divert;
	divert = js_Boot.__instanceof(obj,ink_runtime_Divert)?obj:null;
	if(divert != null) {
		var divTypeKey = "->";
		if(divert.isExternal) divTypeKey = "x()"; else if(divert.pushesToStack) {
			if(divert.stackPushType == 1) divTypeKey = "f()"; else if(divert.stackPushType == 0) divTypeKey = "->t->";
		}
		var targetStr;
		if(divert.get_hasVariableTarget()) targetStr = divert.variableDivertName; else targetStr = divert.get_targetPathString();
		var jObj = { };
		jObj[divTypeKey] = targetStr;
		if(divert.get_hasVariableTarget()) jObj["var"] = true;
		if(divert.isConditional) jObj.c = true;
		if(divert.externalArgs > 0) jObj.exArgs = divert.externalArgs;
		return jObj;
	}
	var choicePoint;
	choicePoint = js_Boot.__instanceof(obj,ink_runtime_ChoicePoint)?obj:null;
	if(choicePoint != null) {
		var jObj1 = { };
		Reflect.setField(jObj1,"*",choicePoint.get_pathStringOnChoice());
		Reflect.setField(jObj1,"flg",choicePoint.get_flags());
		return jObj1;
	}
	var intVal;
	intVal = js_Boot.__instanceof(obj,ink_runtime_IntValue)?obj:null;
	if(intVal != null) return intVal.value;
	var floatVal;
	floatVal = js_Boot.__instanceof(obj,ink_runtime_FloatValue)?obj:null;
	if(floatVal != null) return floatVal.value;
	var strVal;
	strVal = js_Boot.__instanceof(obj,ink_runtime_StringValue)?obj:null;
	if(strVal != null) {
		if(strVal.isNewline) return "\n"; else return "^" + strVal.value;
	}
	var divTargetVal;
	divTargetVal = js_Boot.__instanceof(obj,ink_runtime_DivertTargetValue)?obj:null;
	if(divTargetVal != null) {
		var divTargetJsonObj = { };
		divTargetJsonObj["^->"] = divTargetVal.value.componentsString;
		return divTargetJsonObj;
	}
	var varPtrVal;
	varPtrVal = js_Boot.__instanceof(obj,ink_runtime_VariablePointerValue)?obj:null;
	if(varPtrVal != null) {
		var varPtrJsonObj = { };
		varPtrJsonObj["^var"] = varPtrVal.value;
		varPtrJsonObj.ci = varPtrVal.contextIndex;
		return varPtrJsonObj;
	}
	var glue;
	glue = js_Boot.__instanceof(obj,ink_runtime_Glue)?obj:null;
	if(glue != null) {
		if(glue.get_isBi()) return "<>"; else if(glue.get_isLeft()) return "G<"; else return "G>";
	}
	var controlCmd;
	controlCmd = js_Boot.__instanceof(obj,ink_runtime_ControlCommand)?obj:null;
	if(controlCmd != null) return ink_runtime_Json._controlCommandNames[controlCmd.commandType];
	var nativeFunc;
	nativeFunc = js_Boot.__instanceof(obj,ink_runtime_NativeFunctionCall)?obj:null;
	if(nativeFunc != null) return nativeFunc._name;
	var varRef;
	varRef = js_Boot.__instanceof(obj,ink_runtime_VariableReference)?obj:null;
	if(varRef != null) {
		var jObj2 = { };
		var readCountPath = varRef.get_pathStringForCount();
		if(readCountPath != null) jObj2["CNT?"] = readCountPath; else jObj2["VAR?"] = varRef.name;
		return jObj2;
	}
	var varAss;
	varAss = js_Boot.__instanceof(obj,ink_runtime_VariableAssignment)?obj:null;
	if(varAss != null) {
		var key;
		if(varAss.isGlobal) key = "VAR="; else key = "temp=";
		var jObj3 = { };
		jObj3.key = varAss.variableName;
		if(!varAss.isNewDeclaration) jObj3.re = true;
		return jObj3;
	}
	var voidObj;
	voidObj = js_Boot.__instanceof(obj,ink_runtime_VoidObj)?obj:null;
	if(voidObj != null) return "void";
	var choice;
	choice = js_Boot.__instanceof(obj,ink_runtime_Choice)?obj:null;
	if(choice != null) return ink_runtime_Json.ChoiceToJObject(choice);
	throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Failed to convert runtime object to Json token: " + Std.string(obj)));
};
ink_runtime_Json.ContainerToJArray = function(container) {
	var jArray = ink_runtime_Json.ListToJArray(container._content);
	var namedOnlyContent = container.get_namedOnlyContent();
	var countFlags = container.get_countFlags();
	if(namedOnlyContent != null && new haxe_ds__$StringMap_StringMapIterator(namedOnlyContent,namedOnlyContent.arrayKeys()).hasNext() || countFlags > 0 || container.name != null) {
		var terminatingObj;
		if(namedOnlyContent != null) {
			terminatingObj = ink_runtime_Json.DictionaryRuntimeObjsToJObject(namedOnlyContent);
			var _g = 0;
			var _g1 = Reflect.fields(terminatingObj);
			while(_g < _g1.length) {
				var p = _g1[_g];
				++_g;
				var namedContentObj = Reflect.field(terminatingObj,p);
				var subContainerJArray = ink_runtime_LibUtil["as"](namedContentObj.Value,Array);
				if(subContainerJArray != null) {
					var attrJObj = subContainerJArray[subContainerJArray.length - 1];
					if(attrJObj != null) {
						Reflect.deleteField(attrJObj,"#n");
						if(Reflect.fields(attrJObj).length == 0) subContainerJArray[subContainerJArray.length - 1] = null;
					}
				}
			}
		} else terminatingObj = { };
		if(countFlags > 0) terminatingObj["#f"] = countFlags;
		if(container.name != null) terminatingObj["#n"] = container.name;
		jArray.push(terminatingObj);
	} else jArray.push(null);
	return jArray;
};
ink_runtime_Json.JArrayToContainer = function(jArray) {
	var container = new ink_runtime_Container();
	container.set_content(ink_runtime_Json.JArrayToRuntimeObjList(jArray,true));
	var terminatingObj = jArray[jArray.length - 1];
	if(terminatingObj != null) {
		var namedOnlyContent = new haxe_ds_StringMap();
		var _g = 0;
		var _g1 = Reflect.fields(terminatingObj);
		while(_g < _g1.length) {
			var k = _g1[_g];
			++_g;
			if(k == "#f") container.set_countFlags(Std["int"](Reflect.field(terminatingObj,k))); else if(k == "#n") container.name = Std.string(Reflect.field(terminatingObj,k)); else {
				var namedContentItem = ink_runtime_Json.JTokenToRuntimeObject(Reflect.field(terminatingObj,k));
				var namedSubContainer;
				namedSubContainer = js_Boot.__instanceof(namedContentItem,ink_runtime_Container)?namedContentItem:null;
				if(namedSubContainer != null) namedSubContainer.name = k;
				{
					if(__map_reserved[k] != null) namedOnlyContent.setReserved(k,namedContentItem); else namedOnlyContent.h[k] = namedContentItem;
					namedContentItem;
				}
			}
		}
		container.set_namedOnlyContent(namedOnlyContent);
	}
	return container;
};
ink_runtime_Json.JObjectToChoice = function(jObj) {
	var choice = new ink_runtime_Choice();
	choice.text = Std.string(Reflect.field(jObj,"text"));
	choice.index = Std["int"](Reflect.field(jObj,"index"));
	choice.originalChoicePath = Std.string(Reflect.field(jObj,"originalChoicePath"));
	choice.originalThreadIndex = Std["int"](Reflect.field(jObj,"originalThreadIndex"));
	return choice;
};
ink_runtime_Json.ChoiceToJObject = function(choice) {
	var jObj = { text : choice.text, index : choice.index, originalChoicePath : choice.originalChoicePath, originalThreadIndex : choice.originalThreadIndex};
	return jObj;
};
ink_runtime_Json.prototype = {
	__class__: ink_runtime_Json
};
var ink_runtime_LibUtil = function() { };
ink_runtime_LibUtil.__name__ = ["ink","runtime","LibUtil"];
ink_runtime_LibUtil["as"] = function(obj,type) {
	if(js_Boot.__instanceof(obj,type)) return obj; else return null;
};
ink_runtime_LibUtil.asNoInline = function(obj,type) {
	if(js_Boot.__instanceof(obj,type)) return obj; else return null;
};
ink_runtime_LibUtil.tryParseFloat = function(val) {
	return Std.parseFloat(val);
};
ink_runtime_LibUtil.tryParseInt = function(val) {
	return Std.parseInt(val);
};
ink_runtime_LibUtil.tryGetValue = function(map,prop) {
	return __map_reserved[prop] != null?map.getReserved(prop):map.h[prop];
};
ink_runtime_LibUtil.tryGetValueINamedContent = function(map,prop) {
	return __map_reserved[prop] != null?map.getReserved(prop):map.h[prop];
};
ink_runtime_LibUtil.tryGetValueDynamic = function(obj,prop) {
	return Reflect.field(obj,prop);
};
ink_runtime_LibUtil.addRangeForList = function(list,toAdd) {
	var _g_head = toAdd.h;
	var _g_val = null;
	while(_g_head != null) {
		var i;
		i = (function($this) {
			var $r;
			_g_val = _g_head[0];
			_g_head = _g_head[1];
			$r = _g_val;
			return $r;
		}(this));
		list.add(i);
	}
};
ink_runtime_LibUtil.addRangeForArray = function(list,toAdd) {
	var _g1 = 0;
	var _g = toAdd.length;
	while(_g1 < _g) {
		var i = _g1++;
		list.push(toAdd[i]);
	}
};
ink_runtime_LibUtil.listEquals = function(list,other) {
	return false;
};
ink_runtime_LibUtil.findForList = function(list,f) {
	var _g_head = list.h;
	var _g_val = null;
	while(_g_head != null) {
		var i;
		i = (function($this) {
			var $r;
			_g_val = _g_head[0];
			_g_head = _g_head[1];
			$r = _g_val;
			return $r;
		}(this));
		if(f(i)) return i;
	}
	return null;
};
ink_runtime_LibUtil.minI = function(a,b) {
	if(a < b) return a; else return b;
};
ink_runtime_LibUtil.maxI = function(a,b) {
	if(a >= b) return a; else return b;
};
ink_runtime_LibUtil.minI_ = function(a,b) {
	if(a < b) return a; else return b;
};
ink_runtime_LibUtil.maxI_ = function(a,b) {
	if(a >= b) return a; else return b;
};
var ink_runtime_MapCloner = function(cloner,type) {
	this.cloner = cloner;
	this.type = type;
	this.noArgs = [];
};
ink_runtime_MapCloner.__name__ = ["ink","runtime","MapCloner"];
ink_runtime_MapCloner.prototype = {
	clone: function(inValue) {
		var inMap = inValue;
		var map = Type.createInstance(this.type,this.noArgs);
		var $it0 = inMap.keys();
		while( $it0.hasNext() ) {
			var key = $it0.next();
			map.set(key,this.cloner._clone(inMap.get(key)));
		}
		return map;
	}
	,__class__: ink_runtime_MapCloner
};
var ink_runtime_NativeFunctionCall = function() {
	ink_runtime_Object.call(this);
	ink_runtime_NativeFunctionCall.GenerateNativeFunctionsIfNecessary();
};
ink_runtime_NativeFunctionCall.__name__ = ["ink","runtime","NativeFunctionCall"];
ink_runtime_NativeFunctionCall.CallWithName = function(functionName) {
	return ink_runtime_NativeFunctionCall.createFromName(functionName);
};
ink_runtime_NativeFunctionCall.CallExistsWithName = function(functionName) {
	ink_runtime_NativeFunctionCall.GenerateNativeFunctionsIfNecessary();
	return ink_runtime_NativeFunctionCall._nativeFunctions.exists(functionName);
};
ink_runtime_NativeFunctionCall.createFromName = function(name) {
	var me = new ink_runtime_NativeFunctionCall();
	me.set_name(name);
	return me;
};
ink_runtime_NativeFunctionCall.createFromNameAndNumParams = function(name,numberOfParamters) {
	var me = new ink_runtime_NativeFunctionCall();
	me._isPrototype = true;
	me.set_name(name);
	me.set_numberOfParameters(numberOfParamters);
	return me;
};
ink_runtime_NativeFunctionCall.GenerateNativeFunctionsIfNecessary = function() {
	if(ink_runtime_NativeFunctionCall._nativeFunctions == null) {
		ink_runtime_NativeFunctionCall._nativeFunctions = new haxe_ds_StringMap();
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("+",function(x,y) {
			return x + y;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("-",function(x1,y1) {
			return x1 - y1;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("*",function(x2,y2) {
			return x2 * y2;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("/",function(x3,y3) {
			return x3 / y3 | 0;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("%",function(x4,y4) {
			return x4 % y4;
		});
		ink_runtime_NativeFunctionCall.AddIntUnaryOp("~",function(x5) {
			return -x5;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("==",function(x6,y5) {
			if(x6 == y5) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp(">",function(x7,y6) {
			if(x7 > y6) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("<",function(x8,y7) {
			if(x8 < y7) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp(">=",function(x9,y8) {
			if(x9 >= y8) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("<=",function(x10,y9) {
			if(x10 <= y9) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("!=",function(x11,y10) {
			if(x11 != y10) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddIntUnaryOp("!",function(x12) {
			if(x12 == 0) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("&&",function(x13,y11) {
			if(x13 != 0 && y11 != 0) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("||",function(x14,y12) {
			if(x14 != 0 || y12 != 0) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("MAX",function(x15,y13) {
			if(x15 >= y13) return x15; else return y13;
		});
		ink_runtime_NativeFunctionCall.AddIntBinaryOp("MIN",function(x16,y14) {
			if(x16 < y14) return x16; else return y14;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("+",function(x17,y15) {
			return x17 + y15;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("-",function(x18,y16) {
			return x18 - y16;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("*",function(x19,y17) {
			return x19 * y17;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("/",function(x20,y18) {
			return x20 / y18;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("%",function(x21,y19) {
			return x21 % y19;
		});
		ink_runtime_NativeFunctionCall.AddFloatUnaryOp("~",function(x22) {
			return -x22;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("==",function(x23,y20) {
			if(x23 == y20) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp(">",function(x24,y21) {
			if(x24 > y21) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("<",function(x25,y22) {
			if(x25 < y22) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp(">=",function(x26,y23) {
			if(x26 >= y23) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("<=",function(x27,y24) {
			if(x27 <= y24) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("!=",function(x28,y25) {
			if(x28 != y25) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddFloatUnaryOp("!",function(x29) {
			if(x29 == 0.0) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("&&",function(x30,y26) {
			if(x30 != 0.0 && y26 != 0.0) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("||",function(x31,y27) {
			if(x31 != 0.0 || y27 != 0.0) return 1; else return 0;
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("MAX",function(x32,y28) {
			return Math.max(x32,y28);
		});
		ink_runtime_NativeFunctionCall.AddFloatBinaryOp("MIN",function(x33,y29) {
			return Math.min(x33,y29);
		});
		ink_runtime_NativeFunctionCall.AddStringBinaryOpConcat("+",function(x34,y30) {
			return x34 + y30;
		});
		ink_runtime_NativeFunctionCall.AddStringBinaryOp("==",function(x35,y31) {
			if(x35 == y31) return 1; else return 0;
		});
		var divertTargetsEqual = function(d1,d2) {
			if(d1.Equals(d2)) return 1; else return 0;
		};
		ink_runtime_NativeFunctionCall.AddOpToNativeFunc("==",2,3,divertTargetsEqual);
	}
};
ink_runtime_NativeFunctionCall.AddOpToNativeFunc = function(name,args,valType,op) {
	var nativeFunc = null;
	nativeFunc = ink_runtime_NativeFunctionCall._nativeFunctions.get(name);
	if(nativeFunc != null) {
		nativeFunc = ink_runtime_NativeFunctionCall.createFromNameAndNumParams(name,args);
		ink_runtime_NativeFunctionCall._nativeFunctions.set(name,nativeFunc);
	}
	nativeFunc.AddOpFuncForType(valType,op);
};
ink_runtime_NativeFunctionCall.AddIntBinaryOp = function(name,op) {
	ink_runtime_NativeFunctionCall.AddOpToNativeFunc(name,2,0,op);
};
ink_runtime_NativeFunctionCall.AddIntUnaryOp = function(name,op) {
	ink_runtime_NativeFunctionCall.AddOpToNativeFunc(name,1,0,op);
};
ink_runtime_NativeFunctionCall.AddFloatBinaryOp = function(name,op) {
	ink_runtime_NativeFunctionCall.AddOpToNativeFunc(name,2,1,op);
};
ink_runtime_NativeFunctionCall.AddStringBinaryOp = function(name,op) {
	ink_runtime_NativeFunctionCall.AddOpToNativeFunc(name,2,2,op);
};
ink_runtime_NativeFunctionCall.AddStringBinaryOpConcat = function(name,op) {
	ink_runtime_NativeFunctionCall.AddOpToNativeFunc(name,2,2,op);
};
ink_runtime_NativeFunctionCall.AddFloatUnaryOp = function(name,op) {
	ink_runtime_NativeFunctionCall.AddOpToNativeFunc(name,1,1,op);
};
ink_runtime_NativeFunctionCall.__super__ = ink_runtime_Object;
ink_runtime_NativeFunctionCall.prototype = $extend(ink_runtime_Object.prototype,{
	get_name: function() {
		return this._name;
	}
	,set_name: function(value) {
		this._name = value;
		if(!this._isPrototype) this._prototype = ink_runtime_NativeFunctionCall._nativeFunctions.get(this._name);
		return this._name;
	}
	,get_numberOfParameters: function() {
		if(this._prototype != null) return this._prototype.get_numberOfParameters(); else return this._numberOfParameters;
	}
	,set_numberOfParameters: function(value) {
		return this._numberOfParameters = value;
	}
	,Call: function(parameters) {
		if(this._prototype != null) return this._prototype.Call(parameters);
		if(this.get_numberOfParameters() != parameters.length) throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Unexpected number of parameters"));
		var _g_head = parameters.h;
		var _g_val = null;
		while(_g_head != null) {
			var p;
			p = (function($this) {
				var $r;
				_g_val = _g_head[0];
				_g_head = _g_head[1];
				$r = _g_val;
				return $r;
			}(this));
			if(js_Boot.__instanceof(p,ink_runtime_VoidObj)) throw new js__$Boot_HaxeError(new ink_runtime_StoryException("Attempting to perform operation on a void value. Did you forget to 'return' a value from a function you called here?"));
		}
		var coercedParams = this.CoerceValuesToSingleType(parameters);
		var coercedType = coercedParams.first().get_valueType();
		if(coercedType == 0) return this.CallParamList(coercedParams); else if(coercedType == 1) return this.CallParamList(coercedParams); else if(coercedType == 2) return this.CallParamList(coercedParams); else if(coercedType == 3) return this.CallParamList(coercedParams);
		return null;
	}
	,CallParamList: function(parametersOfSingleType) {
		var param1 = parametersOfSingleType.first();
		var valType = param1.get_valueType();
		var val1 = param1;
		var paramCount = parametersOfSingleType.length;
		if(paramCount == 2 || paramCount == 1) {
			var opForTypeObj = null;
			opForTypeObj = this._operationFuncs.h[valType];
			if(!(opForTypeObj != null)) throw new js__$Boot_HaxeError(new ink_runtime_StoryException("Can not perform operation '" + this._name + "' on " + valType));
			if(paramCount == 2) {
				var iter_head = parametersOfSingleType.h;
				var iter_val = null;
				{
					iter_val = iter_head[0];
					iter_head = iter_head[1];
					iter_val;
				}
				var param2;
				param2 = (function($this) {
					var $r;
					iter_val = iter_head[0];
					iter_head = iter_head[1];
					$r = iter_val;
					return $r;
				}(this));
				var val2 = param2;
				var opForType = opForTypeObj;
				var resultVal = opForType(val1.value,val2.value);
				return ink_runtime_Value.Create(resultVal);
			} else {
				var opForType1 = opForTypeObj;
				var resultVal1 = opForType1(val1.value);
				return ink_runtime_Value.Create(resultVal1);
			}
		} else throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Unexpected number of parameters to NativeFunctionCall: " + parametersOfSingleType.length));
	}
	,CoerceValuesToSingleType: function(parametersIn) {
		var valType = 0;
		var valTypeInt = valType;
		var _g_head = parametersIn.h;
		var _g_val = null;
		while(_g_head != null) {
			var obj;
			obj = (function($this) {
				var $r;
				_g_val = _g_head[0];
				_g_head = _g_head[1];
				$r = _g_val;
				return $r;
			}(this));
			var val = obj;
			var valValueType = val.get_valueType();
			if(valValueType > valTypeInt) valType = val.get_valueType();
		}
		var parametersOut = new List();
		var _g_head1 = parametersIn.h;
		var _g_val1 = null;
		while(_g_head1 != null) {
			var v;
			v = (function($this) {
				var $r;
				_g_val1 = _g_head1[0];
				_g_head1 = _g_head1[1];
				$r = _g_val1;
				return $r;
			}(this));
			var val1 = v;
			var castedValue = val1.Cast(valType);
			parametersOut.add(castedValue);
		}
		return parametersOut;
	}
	,_setupNameAndNumParams: function(name,numberOfParamters) {
		this._isPrototype = true;
		this.set_name(name);
		this.set_numberOfParameters(numberOfParamters);
	}
	,AddOpFuncForType: function(valType,op) {
		if(this._operationFuncs == null) this._operationFuncs = new haxe_ds_IntMap();
		var value = op;
		this._operationFuncs.set(valType,value);
	}
	,toString: function() {
		return "Native '" + this._name + "'";
	}
	,__class__: ink_runtime_NativeFunctionCall
	,__properties__: $extend(ink_runtime_Object.prototype.__properties__,{set_numberOfParameters:"set_numberOfParameters",get_numberOfParameters:"get_numberOfParameters",set_name:"set_name",get_name:"get_name"})
});
var ink_runtime_Path = function() {
	ink_runtime_Object.call(this);
	this.components = [];
};
ink_runtime_Path.__name__ = ["ink","runtime","Path"];
ink_runtime_Path.createFromHeadAndTail = function(head,tail) {
	var me = new ink_runtime_Path();
	me.components.push(head);
	ink_runtime_LibUtil.addRangeForArray(me.components,tail.components);
	return me;
};
ink_runtime_Path.createFromComponents = function(components,relative) {
	if(relative == null) relative = false;
	var me = new ink_runtime_Path();
	ink_runtime_LibUtil.addRangeForArray(me.components,components);
	me.isRelative = relative;
	return me;
};
ink_runtime_Path.createFromString = function(componentsString) {
	var me = new ink_runtime_Path();
	me.componentsString = componentsString;
	return me;
};
ink_runtime_Path.__super__ = ink_runtime_Object;
ink_runtime_Path.prototype = $extend(ink_runtime_Object.prototype,{
	PathByAppendingPath: function(otherPath) {
		return null;
	}
	,toString: function() {
		return null;
	}
	,__class__: ink_runtime_Path
});
var ink_runtime_Component = function() {
};
ink_runtime_Component.__name__ = ["ink","runtime","Component"];
ink_runtime_Component.createFromIndex = function(index) {
	var me = new ink_runtime_Component();
	ink_runtime_Assert.bool(index >= 0,"assertion failed index >=0");
	me.index = index;
	me.name = null;
	return me;
};
ink_runtime_Component.createFromName = function(name) {
	var me = new ink_runtime_Component();
	ink_runtime_Assert.bool(name != null && name.length > 0,"assertion failed:name != null && name.Length > 0");
	me.name = name;
	me.index = -1;
	return me;
};
ink_runtime_Component.ToParent = function() {
	return null;
};
ink_runtime_Component.prototype = {
	Equals: function(other) {
		return false;
	}
	,__class__: ink_runtime_Component
};
var ink_runtime_Story = function() {
};
ink_runtime_Story.__name__ = ["ink","runtime","Story"];
ink_runtime_Story.prototype = {
	ContentAtPath: function(path) {
		return null;
	}
	,__class__: ink_runtime_Story
};
var ink_runtime_SystemException = function(msg) {
	this.msg = msg;
};
ink_runtime_SystemException.__name__ = ["ink","runtime","SystemException"];
ink_runtime_SystemException.prototype = {
	toString: function() {
		return Type.getClassName(js_Boot.getClass(this)) + ":: " + this.msg;
	}
	,__class__: ink_runtime_SystemException
};
var ink_runtime_StoryException = function(message) {
	ink_runtime_SystemException.call(this,message);
};
ink_runtime_StoryException.__name__ = ["ink","runtime","StoryException"];
ink_runtime_StoryException.__super__ = ink_runtime_SystemException;
ink_runtime_StoryException.prototype = $extend(ink_runtime_SystemException.prototype,{
	__class__: ink_runtime_StoryException
});
var ink_runtime_SystemNotImplementedException = function(message) {
	ink_runtime_SystemException.call(this,message);
};
ink_runtime_SystemNotImplementedException.__name__ = ["ink","runtime","SystemNotImplementedException"];
ink_runtime_SystemNotImplementedException.__super__ = ink_runtime_SystemException;
ink_runtime_SystemNotImplementedException.prototype = $extend(ink_runtime_SystemException.prototype,{
	__class__: ink_runtime_SystemNotImplementedException
});
var ink_runtime_StringHashSet = function() {
	haxe_ds_StringMap.call(this);
};
ink_runtime_StringHashSet.__name__ = ["ink","runtime","StringHashSet"];
ink_runtime_StringHashSet.__super__ = haxe_ds_StringMap;
ink_runtime_StringHashSet.prototype = $extend(haxe_ds_StringMap.prototype,{
	add: function(variableName) {
		if(__map_reserved[variableName] != null) this.setReserved(variableName,true); else this.h[variableName] = true;
	}
	,__class__: ink_runtime_StringHashSet
});
var ink_runtime_Value = function(val) {
	ink_runtime_Object.call(this);
	this.value = val;
};
ink_runtime_Value.__name__ = ["ink","runtime","Value"];
ink_runtime_Value.Create = function(val) {
	if(typeof(val) == "boolean") {
		var b = val;
		val = (b?1:0) | 0;
	}
	if(((val | 0) === val)) return new ink_runtime_IntValue(val); else if(typeof(val) == "number") return new ink_runtime_FloatValue(val); else if(typeof(val) == "string") return new ink_runtime_StringValue(val); else if(js_Boot.__instanceof(val,ink_runtime_Path)) return new ink_runtime_DivertTargetValue(val);
	return null;
};
ink_runtime_Value.__super__ = ink_runtime_Object;
ink_runtime_Value.prototype = $extend(ink_runtime_Object.prototype,{
	Cast: function(newType) {
		return null;
	}
	,ToString: function() {
		return Std.string(this.value);
	}
	,toString: function() {
		return this.ToString();
	}
	,Copy: function() {
		return ink_runtime_Value.Create(this.get_valueObject());
	}
	,get_valueType: function() {
		return this.valueType;
	}
	,get_isTruthy: function() {
		return this.isTruthy;
	}
	,get_valueObject: function() {
		return this.value;
	}
	,__class__: ink_runtime_Value
	,__properties__: $extend(ink_runtime_Object.prototype.__properties__,{get_valueObject:"get_valueObject",get_isTruthy:"get_isTruthy",get_valueType:"get_valueType"})
});
var ink_runtime_IntValue = function(val) {
	ink_runtime_Value.call(this,val);
};
ink_runtime_IntValue.__name__ = ["ink","runtime","IntValue"];
ink_runtime_IntValue.__super__ = ink_runtime_Value;
ink_runtime_IntValue.prototype = $extend(ink_runtime_Value.prototype,{
	__class__: ink_runtime_IntValue
});
var ink_runtime_FloatValue = function(val) {
	ink_runtime_Value.call(this,val);
};
ink_runtime_FloatValue.__name__ = ["ink","runtime","FloatValue"];
ink_runtime_FloatValue.__super__ = ink_runtime_Value;
ink_runtime_FloatValue.prototype = $extend(ink_runtime_Value.prototype,{
	__class__: ink_runtime_FloatValue
});
var ink_runtime_StringValue = function(val) {
	if(val == null) val = "";
	ink_runtime_Value.call(this,val);
	this.isNewline = this.value == "\n";
	this.isInlineWhitespace = true;
	var _g1 = 0;
	var _g = this.value.length;
	while(_g1 < _g) {
		var i = _g1++;
		var c = this.value.charAt(i);
		if(c != " " && c != "\t") {
			this.isInlineWhitespace = false;
			break;
		}
	}
};
ink_runtime_StringValue.__name__ = ["ink","runtime","StringValue"];
ink_runtime_StringValue.__super__ = ink_runtime_Value;
ink_runtime_StringValue.prototype = $extend(ink_runtime_Value.prototype,{
	get_valueType: function() {
		return 2;
	}
	,get_isTruthy: function() {
		return this.value.length > 0;
	}
	,get_isNonWhitespace: function() {
		return !this.isNewline && !this.isInlineWhitespace;
	}
	,Cast: function(newType) {
		var tryVal;
		if(newType == this.get_valueType()) return this;
		if(newType == 0) {
			tryVal = Std.parseInt(this.value);
			if(tryVal != null) return new ink_runtime_IntValue(tryVal); else return null;
		}
		if(newType == 1) {
			tryVal = Std.parseFloat(this.value);
			if(tryVal != null) return new ink_runtime_FloatValue(tryVal); else return null;
		}
		throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Unexpected type cast of Value to new ValueType"));
	}
	,__class__: ink_runtime_StringValue
	,__properties__: $extend(ink_runtime_Value.prototype.__properties__,{get_isNonWhitespace:"get_isNonWhitespace"})
});
var ink_runtime_DivertTargetValue = function(val) {
	ink_runtime_Value.call(this,val);
};
ink_runtime_DivertTargetValue.__name__ = ["ink","runtime","DivertTargetValue"];
ink_runtime_DivertTargetValue.__super__ = ink_runtime_Value;
ink_runtime_DivertTargetValue.prototype = $extend(ink_runtime_Value.prototype,{
	get_targetPath: function() {
		return this.value;
	}
	,set_targetPath: function(value) {
		return this.value = value;
	}
	,get_valueType: function() {
		return 3;
	}
	,get_isTruthy: function() {
		throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Shouldn't be checking the truthiness of a divert target"));
		return false;
	}
	,Cast: function(newType) {
		if(newType == this.get_valueType()) return this;
		throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Unexpected type cast of Value to new ValueType"));
	}
	,ToString: function() {
		return "DivertTargetValue(" + Std.string(this.get_targetPath()) + ")";
	}
	,__class__: ink_runtime_DivertTargetValue
	,__properties__: $extend(ink_runtime_Value.prototype.__properties__,{set_targetPath:"set_targetPath",get_targetPath:"get_targetPath"})
});
var ink_runtime_VariablePointerValue = function(variableName,contextIndex) {
	if(contextIndex == null) contextIndex = -1;
	ink_runtime_Value.call(this,variableName);
	this.contextIndex = contextIndex;
};
ink_runtime_VariablePointerValue.__name__ = ["ink","runtime","VariablePointerValue"];
ink_runtime_VariablePointerValue.__super__ = ink_runtime_Value;
ink_runtime_VariablePointerValue.prototype = $extend(ink_runtime_Value.prototype,{
	get_valueType: function() {
		return 4;
	}
	,get_isTruthy: function() {
		throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Shouldn't be checking the truthiness of a variable pointer"));
		return false;
	}
	,Cast: function(newType) {
		if(newType == this.get_valueType()) return this;
		throw new js__$Boot_HaxeError(new ink_runtime_SystemException("Unexpected type cast of Value to new ValueType"));
	}
	,ToString: function() {
		return "VariablePointerValue(" + this.variableName + ")";
	}
	,Copy: function() {
		return new ink_runtime_VariablePointerValue(this.variableName,this.contextIndex);
	}
	,__class__: ink_runtime_VariablePointerValue
});
var ink_runtime_VariableAssignment = function(variableName,isNewDeclaration) {
	if(isNewDeclaration == null) isNewDeclaration = false;
	ink_runtime_Object.call(this);
	this.variableName = variableName;
	this.isNewDeclaration = isNewDeclaration;
};
ink_runtime_VariableAssignment.__name__ = ["ink","runtime","VariableAssignment"];
ink_runtime_VariableAssignment.__super__ = ink_runtime_Object;
ink_runtime_VariableAssignment.prototype = $extend(ink_runtime_Object.prototype,{
	toString: function() {
		return "VarAssign to " + this.variableName;
	}
	,__class__: ink_runtime_VariableAssignment
});
var ink_runtime_VariableReference = function() {
	ink_runtime_Object.call(this);
};
ink_runtime_VariableReference.__name__ = ["ink","runtime","VariableReference"];
ink_runtime_VariableReference.create = function(name) {
	var me = new ink_runtime_VariableReference();
	me.name = name;
	return me;
};
ink_runtime_VariableReference.__super__ = ink_runtime_Object;
ink_runtime_VariableReference.prototype = $extend(ink_runtime_Object.prototype,{
	get_containerForCount: function() {
		return ink_runtime_LibUtil["as"](this.ResolvePath(this.pathForCount),ink_runtime_Container);
	}
	,get_pathStringForCount: function() {
		if(this.pathForCount == null) return null;
		return this.CompactPathString(this.pathForCount);
	}
	,set_pathStringForCount: function(value) {
		if(value == null) this.pathForCount = null; else this.pathForCount = ink_runtime_Path.createFromString(value);
		return value;
	}
	,toString: function() {
		if(this.name != null) return "var(" + this.name + ")"; else {
			var pathStr = this.get_pathStringForCount();
			return "read_count(" + pathStr + ")";
		}
	}
	,__class__: ink_runtime_VariableReference
	,__properties__: $extend(ink_runtime_Object.prototype.__properties__,{set_pathStringForCount:"set_pathStringForCount",get_pathStringForCount:"get_pathStringForCount",get_containerForCount:"get_containerForCount"})
});
var ink_runtime_VariablesState = function(callStack) {
	this._globalVariables = new haxe_ds_StringMap();
	this._callStack = callStack;
};
ink_runtime_VariablesState.__name__ = ["ink","runtime","VariablesState"];
ink_runtime_VariablesState.prototype = {
	get_batchObservingVariableChanges: function() {
		return this._batchObservingVariableChanges;
	}
	,set_batchObservingVariableChanges: function(value) {
		this._batchObservingVariableChanges = value;
		if(value) this._changedVariables = new ink_runtime_StringHashSet(); else {
			if(this._changedVariables != null) {
				var $it0 = this._changedVariables.keys();
				while( $it0.hasNext() ) {
					var variableName = $it0.next();
					var currentValue = this._globalVariables.get(variableName);
					this.variableChangedEvent(variableName,currentValue);
				}
			}
			this._changedVariables = null;
		}
		return this._batchObservingVariableChanges;
	}
	,field: function(variableName) {
		var varContents;
		if((varContents = ink_runtime_LibUtil.tryGetValue(this._globalVariables,variableName)) != null) return (js_Boot.__instanceof(varContents,ink_runtime_Value)?varContents:null).get_valueObject(); else return null;
	}
	,setField: function(variableName,value) {
		var val = ink_runtime_Value.Create(value);
		if(val == null) {
			if(value == null) throw new js__$Boot_HaxeError(new ink_runtime_StoryException("Cannot pass null to VariableState")); else throw new js__$Boot_HaxeError(new ink_runtime_StoryException("Invalid value passed to VariableState: " + Std.string(value.ToString())));
		}
		this.SetGlobal(variableName,val);
	}
	,CopyFrom: function(varState) {
		var cloner = new ink_runtime_Cloner();
		this._globalVariables = cloner.clone(varState._globalVariables);
		this.variableChangedEvent = varState.variableChangedEvent;
		if(varState.get_batchObservingVariableChanges() != this.get_batchObservingVariableChanges()) {
			if(varState.get_batchObservingVariableChanges()) {
				this._batchObservingVariableChanges = true;
				this._changedVariables = cloner.clone(varState._changedVariables);
			} else {
				this._batchObservingVariableChanges = false;
				this._changedVariables = null;
			}
		}
	}
	,get_jsonToken: function() {
		return ink_runtime_Json.DictionaryRuntimeObjsToJObject(this._globalVariables);
	}
	,set_jsonToken: function(value) {
		return this._globalVariables = ink_runtime_Json.JObjectToDictionaryRuntimeObjs(value);
	}
	,GetVariableWithName: function(name,contextIndex) {
		var varValue = this.GetRawVariableWithName(name,contextIndex);
		var varPointer;
		varPointer = js_Boot.__instanceof(varValue,ink_runtime_VariablePointerValue)?varValue:null;
		if(varPointer != null) varValue = this.ValueAtVariablePointer(varPointer);
		return varValue;
	}
	,GetRawVariableWithName: function(name,contextIndex) {
		var varValue = null;
		if(contextIndex == 0 || contextIndex == -1) {
			if((varValue = ink_runtime_LibUtil.tryGetValue(this._globalVariables,name)) != null) return varValue;
		}
		varValue = this._callStack.GetTemporaryVariableWithName(name,contextIndex);
		if(varValue == null) throw new js__$Boot_HaxeError(new ink_runtime_SystemException("RUNTIME ERROR: Variable '" + name + "' could not be found in context '" + contextIndex + "'. This shouldn't be possible so is a bug in the ink engine. Please try to construct a minimal story that reproduces the problem and report to inkle, thank you!"));
		return varValue;
	}
	,ValueAtVariablePointer: function(pointer) {
		return this.GetVariableWithName(pointer.variableName,pointer.contextIndex);
	}
	,Assign: function(varAss,value) {
		var name = varAss.variableName;
		var contextIndex = -1;
		var setGlobal = false;
		if(varAss.isNewDeclaration) setGlobal = varAss.isGlobal; else setGlobal = this._globalVariables.exists(name);
		if(varAss.isNewDeclaration) {
			var varPointer;
			varPointer = js_Boot.__instanceof(value,ink_runtime_VariablePointerValue)?value:null;
			if(varPointer != null) {
				var fullyResolvedVariablePointer = this.ResolveVariablePointer(varPointer);
				value = fullyResolvedVariablePointer;
			}
		} else {
			var existingPointer = null;
			do {
				existingPointer = ink_runtime_LibUtil["as"](this.GetRawVariableWithName(name,contextIndex),ink_runtime_VariablePointerValue);
				if(existingPointer != null) {
					name = existingPointer.variableName;
					contextIndex = existingPointer.contextIndex;
					setGlobal = contextIndex == 0;
				}
			} while(existingPointer != null);
		}
		if(setGlobal) this.SetGlobal(name,value); else this._callStack.SetTemporaryVariable(name,value,varAss.isNewDeclaration,contextIndex);
	}
	,SetGlobal: function(variableName,value) {
		var oldValue = null;
		oldValue = ink_runtime_LibUtil.tryGetValue(this._globalVariables,variableName);
		this._globalVariables.set(variableName,oldValue);
		if(this.variableChangedEvent != null && !value.Equals(oldValue)) {
			if(this.get_batchObservingVariableChanges()) this._changedVariables.add(variableName); else this.variableChangedEvent(variableName,value);
		}
	}
	,ResolveVariablePointer: function(varPointer) {
		var contextIndex = varPointer.contextIndex;
		if(contextIndex == -1) contextIndex = this.GetContextIndexOfVariableNamed(varPointer.variableName);
		var valueOfVariablePointedTo = this.GetRawVariableWithName(varPointer.variableName,contextIndex);
		var doubleRedirectionPointer;
		doubleRedirectionPointer = js_Boot.__instanceof(valueOfVariablePointedTo,ink_runtime_VariablePointerValue)?valueOfVariablePointedTo:null;
		if(doubleRedirectionPointer != null) return doubleRedirectionPointer; else return new ink_runtime_VariablePointerValue(varPointer.variableName,contextIndex);
	}
	,GetContextIndexOfVariableNamed: function(varName) {
		if(this._globalVariables.exists(varName)) return 0;
		return this._callStack.get_currentElementIndex();
	}
	,__class__: ink_runtime_VariablesState
	,__properties__: {set_jsonToken:"set_jsonToken",get_jsonToken:"get_jsonToken",set_batchObservingVariableChanges:"set_batchObservingVariableChanges",get_batchObservingVariableChanges:"get_batchObservingVariableChanges"}
};
var ink_runtime_VoidObj = function() {
	ink_runtime_Object.call(this);
};
ink_runtime_VoidObj.__name__ = ["ink","runtime","VoidObj"];
ink_runtime_VoidObj.__super__ = ink_runtime_Object;
ink_runtime_VoidObj.prototype = $extend(ink_runtime_Object.prototype,{
	__class__: ink_runtime_VoidObj
});
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__name__ = ["js","_Boot","HaxeError"];
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
	__class__: js__$Boot_HaxeError
});
var js_Boot = function() { };
js_Boot.__name__ = ["js","Boot"];
js_Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js_Boot.__nativeClassName(o);
		if(name != null) return js_Boot.__resolveNativeClass(name);
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js_Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js_Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js_Boot.__interfLoop(cc.__super__,cl);
};
js_Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js_Boot.__interfLoop(js_Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js_Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js_Boot.__isNativeObj = function(o) {
	return js_Boot.__nativeClassName(o) != null;
};
js_Boot.__resolveNativeClass = function(name) {
	return $global[name];
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
String.prototype.__class__ = String;
String.__name__ = ["String"];
Array.__name__ = ["Array"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
var __map_reserved = {}
haxe_ds_ObjectMap.count = 0;
ink_runtime_CountFlags.Visits = 1;
ink_runtime_CountFlags.Turns = 2;
ink_runtime_CountFlags.CountStartOnly = 4;
ink_runtime_NativeFunctionCall.Add = "+";
ink_runtime_NativeFunctionCall.Subtract = "-";
ink_runtime_NativeFunctionCall.Divide = "/";
ink_runtime_NativeFunctionCall.Multiply = "*";
ink_runtime_NativeFunctionCall.Mod = "%";
ink_runtime_NativeFunctionCall.Negate = "~";
ink_runtime_NativeFunctionCall.Equal = "==";
ink_runtime_NativeFunctionCall.Greater = ">";
ink_runtime_NativeFunctionCall.Less = "<";
ink_runtime_NativeFunctionCall.GreaterThanOrEquals = ">=";
ink_runtime_NativeFunctionCall.LessThanOrEquals = "<=";
ink_runtime_NativeFunctionCall.NotEquals = "!=";
ink_runtime_NativeFunctionCall.Not = "!";
ink_runtime_NativeFunctionCall.And = "&&";
ink_runtime_NativeFunctionCall.Or = "||";
ink_runtime_NativeFunctionCall.Min = "MIN";
ink_runtime_NativeFunctionCall.Max = "MAX";
js_Boot.__toStr = {}.toString;
InkleRuntime.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);
