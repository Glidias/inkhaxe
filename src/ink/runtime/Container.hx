package ink.runtime;
import ink.runtime.Path.Component;
import ink.runtime.Value.StringValue;

/**
 * Done!
 * @author Glidias
 */

 /*  // for the interest of performance, i'd rather inline as below
@:enum
abstract CountFlags(Int)
{
	var Visits = 1;
	var Turns= 2;
	var CountStartOnly = 4;
}
//*/

class CountFlags {
	public static inline var Visits:Int = 1;
	public static inline var Turns:Int = 2;
	public static inline var CountStartOnly:Int = 4;
}

class Container extends RObject implements INamedContent
{

	public var name:String;
	public var content(get, set):Array<RObject>;
	inline function  get_content():Array<RObject> 
	{
			return _content;
	}
	
	inline function  set_content(value:Array<RObject>):Array<RObject> 
	{

		AddContentList(value);
		return _content;
	}
	private var _content:Array<RObject>;
	
	public var namedContent:Map<String, INamedContent>; //{ get; set; }
	
	public var namedOnlyContent(get, set):Map<String,RObject>;
	function get_namedOnlyContent():Map<String, RObject> 
	{
		var namedOnlyContent = new Map<String, RObject>();
		for  (k in namedContent.keys()) {
			namedOnlyContent.set(k, cast namedContent.get(k));
		}

		for (i in 0...content.length) {
			var c = content[i];
			var named = LibUtil.as( c, INamedContent);
			if (named != null && named.hasValidName) {
				namedOnlyContent.remove(named.name);
			}
		}
		
		if (!namedOnlyContent.iterator().hasNext())  { //namedOnlyContent.length == 0 
			namedOnlyContent = null;
		}

		return namedOnlyContent;
	}
	
	function set_namedOnlyContent(value:Map<String, RObject>):Map<String, RObject> 
	{
		var existingNamedOnly = this.namedOnlyContent;// get_namedOnlyContent();
		if (existingNamedOnly != null) {
			for  (k in existingNamedOnly.keys()) {
				namedContent.remove(k);
			}
		}

		if (value == null)
			return existingNamedOnly;  // is this return correct?
		
		for (k in value.keys()) {
			var named = LibUtil.as( value.get(k) , INamedContent);
			if( named != null ) // js version shouldn;t this be a boolean? ?  named.name && typeof named.hasValidName !== 'undefined'
				AddToNamedContentOnly (named);
		}
		
		return value; // existingNamedOnly;  // is this return correct?
	}

	public var visitsShouldBeCounted:Bool;// { get; set; }
    public var turnIndexShouldBeCounted:Bool;// { get; set; }
    public var countingAtStartOnly:Bool;// { get; set; }
	
	

	public var countFlags(get, set):Int; //CountFlags
	function get_countFlags():Int 
	{
		var  flags:Int = 0;
		
		if (visitsShouldBeCounted)    flags |= CountFlags.Visits;
		if (turnIndexShouldBeCounted) flags |= CountFlags.Turns;
		if (countingAtStartOnly)      flags |= CountFlags.CountStartOnly;

		// If we're only storing CountStartOnly, it serves no purpose,
		// since it's dependent on the other two to be used at all.
		// (e.g. for setting the fact that *if* a gather or choice's
		// content is counted, then is should only be counter at the start)
		// So this is just an optimisation for storage.
		if (flags == CountFlags.CountStartOnly) {
			flags = 0;
		}
		return flags;
	}
	
	function set_countFlags(value:Int):Int 
	{
		var flag = value;
		if ((flag & CountFlags.Visits) > 0) visitsShouldBeCounted = true;
		if ((flag & CountFlags.Turns) > 0)  turnIndexShouldBeCounted = true;
		if ((flag & CountFlags.CountStartOnly) > 0) countingAtStartOnly = true;
		return value;// get_countFlags();
	}
	
	public var hasValidName(get, null):Bool;
	function get_hasValidName():Bool 
	{
		 return name != null && name.length > 0;
	}
	
	/*    // somehow not used??
	public var pathToFirstLeafContent(get, null):Path;  // unusued  public
	function get_pathToFirstLeafContent():Path 
	{
		if( _pathToFirstLeafContent == null )
			_pathToFirstLeafContent = path.PathByAppendingPath (internalPathToFirstLeafContent);

		return _pathToFirstLeafContent;
	}
	var _pathToFirstLeafContent:Path;
	
	var internalPathToFirstLeafContent(get, null):Path;  // unusued  public
	function get_internalPathToFirstLeafContent():Path 
	{
		var path = new Path();
		var container = this;
		while (container != null) {
			if (container.content.length > 0) {
				path.components.push(Component.createFromIndex(0));
				container = LibUtil.as(container.content[0] , Container);
			}
		}
		return path;
	}
	*/
	
	public function new() 
	{
		super();
		
		/*
		this.name = '';
		this._pathToFirstLeafContent = null;
		this.visitsShouldBeCounted = false;
		this.turnIndexShouldBeCounted = false;
		this.countingAtStartOnly = false;
		*/
		
		_content = new Array<RObject>();
		namedContent = new Map<String, INamedContent>();
	}
	
	
	
	public function AddToNamedContentOnly( namedContentObj:INamedContent):Void {
		Assert.bool( Std.is(namedContentObj, RObject), "Can only add Runtime.Objects to a Runtime.Container");
		var runtimeObj = cast namedContentObj;
		runtimeObj.parent = this;
		namedContent.set(namedContentObj.name, namedContentObj); // namedContent[namedContentObj.name] = namedContentObj;
	}
	
	

	public function AddContent(contentObj:RObject):Void {
		_content.push(contentObj);
		 if (contentObj.parent!=null) {
			 throw new SystemException ("content is already in " + contentObj.parent);
		 }
		contentObj.parent = this;
		
		TryAddNamedContent (contentObj);
	}

	public function AddContentList(contentList:Array<RObject>):Void {
		for ( c in contentList) {
            AddContent (c);
        }
	}
	

	// tocheck: how many calls are made to this. Verify if performance optimziation to "content.insert" for Array is worth looking into if used fequently.
	 public function InsertContent( contentObj:RObject,  index:Int):Void
	{
		
		content.insert(index, contentObj);

		if (contentObj.parent!=null) {
			throw new SystemException ("content is already in " + contentObj.parent);
		}

		contentObj.parent = this;

		TryAddNamedContent (contentObj);
	}

	
	public function TryAddNamedContent( contentObj:RObject):Void
	{
		var namedContentObj = LibUtil.as(contentObj , INamedContent);
		if (namedContentObj != null && namedContentObj.hasValidName) {
			AddToNamedContentOnly (namedContentObj);
		}
	}
	
	 public function AddContentsOfContainer( otherContainer:Container):Void
	{
	   LibUtil.addRangeForArray(content, otherContainer.content);// content.AddRange (otherContainer.content);
		for ( obj in otherContainer.content) {
			obj.parent = this;
			TryAddNamedContent (obj);
		}
	}

	function  ContentWithPathComponent(component:Component):RObject
	{
		if (component.isIndex) {

			if (component.index >= 0 && component.index < content.length) {
				return content [component.index];
			}

			// When path is out of range, quietly return nil
			// (useful as we step/increment forwards through content)
			else {
				return null;
			}

		} 

		else if (component.isParent) {
			return this.parent;
		}

		else {
			var foundContent:INamedContent = null;
			foundContent = LibUtil.tryGetValueINamedContent( namedContent, component.name);
			if ( foundContent!=null ) {  //namedContent.TryGetValue (component.name, out foundContent)
				return cast foundContent;
			} else {
				throw new StoryException ("Content '"+component.name+"' not found at path: '"+this.path+"'");
			}
		}
	}
	
	
	
	
	public function ContentAtPath(path:Path, partialPathLength:Int=-1):RObject
	{
	  if (partialPathLength == -1)
			partialPathLength = path.components.length;
		
		var currentContainer:Container = this;
		var currentObj:RObject = this;

		for (i in 0...partialPathLength) {  //int i = 0; i < partialPathLength; ++i
			var comp = path.components [i];
			if (currentContainer == null)
				throw new SystemException ("Path continued, but previous object wasn't a container: " + currentObj);
			currentObj = currentContainer.ContentWithPathComponent(comp);
			currentContainer = LibUtil.as( currentObj, Container);
		}

		return currentObj;
	}
	

	//StringBuilder
  public function BuildStringOfHierarchy( sb:StringBuf,  indentation:Int, pointedObj:RObject)
	{
		
		var appendIndentation = function():Void { 
			var  spacesPerIndent:Int = 4;
			
			//int i=0; i<spacesPerIndent*indentation;++i
			for( i in 0...spacesPerIndent*indentation) { 
				sb.add(" "); 
			} 
		};

		appendIndentation();
		sb.add("[");

		if (this.hasValidName) {
			sb.add(" (" + this.name + ")");  // // sb.AppendFormat (" ({0})", this.name);  
		}

		if (this == pointedObj) {
			sb.add ("  <---");
		}

		sb.add("\n");  //sb.AppendLine ();

		indentation++;
		
		
		for (i in 0...content.length) { //int i=0; i<content.Count; ++i

			var obj = content[i];

			if (Std.is(obj, Container)) {

				var container:Container = cast obj;  //(Container)

				container.BuildStringOfHierarchy (sb, indentation, pointedObj);

			} else {
				appendIndentation ();
				if (Std.is(obj, StringValue)) {
					sb.add ("\"");
					sb.add ( StringTools.replace( Std.string(obj), "\n", "\\n"   ));  //obj.ToString ().Replace ("\n", "\\n")
					sb.add ("\"");
				} else {
					sb.add (Std.string(obj) ); //obj.ToString ()
				}
			}

			if (i != content.length - 1) {
				sb.add(",");
			}

			//
			if ( !(Std.is(obj, Container)) && obj == pointedObj ) {  // CONSIDER: equality check here might require IEquals implementation! But this method isn't critical and only sued for dev debugging
				sb.add ("  <---");
			}
				
			sb.add("\n"); //sb.AppendLine ();
		}
			

		var onlyNamed = new Map<String, INamedContent> ();

		for (k in namedContent.keys()) {
			if (content.indexOf(cast namedContent.get(k)) >=0 ) {  //content.Contains ((Runtime.Object)objKV.Value)
				continue;
			} else {
				onlyNamed.set(k, namedContent.get(k));
			}
		}

		if (onlyNamed.iterator().hasNext()) {  //onlyNamed.length > 0
			appendIndentation();
			sb.add("-- named: --" + "\n"); //sb.AppendLine ("-- named: --");

			for (k in onlyNamed.keys()) {
				var objV:INamedContent = onlyNamed.get(k);
				Assert.bool ( Std.is(objV, Container), "Can only print out named Containers");
				var container = cast objV;
				container.BuildStringOfHierarchy (sb, indentation, pointedObj);

				sb.add("\n"); //sb.AppendLine ();

			}
		}


		indentation--;

		appendIndentation ();
		sb.add ("]");
	}
	
	
	public function BuildStringOfHierarchyVirtual():String  //virtual
 	{
		var sb = new StringBuf();
		BuildStringOfHierarchy (sb, 0, null);
		return sb.toString();
	}


	


}