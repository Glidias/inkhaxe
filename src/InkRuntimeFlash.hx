package;
import flash.Lib;
import flash.display.Sprite;
import flash.errors.Error;
import flash.utils.JSON;
import ink.runtime.Path;
import ink.runtime.Story;


/**
 * ...
 * @author Glidias
 */
class InkRuntimeFlash extends Sprite
{

	public function new() 
	{
		super();
			
		var story:Story = new Story('{"inkVersion":12,"root":[[{"->":"start"},null],"done",{"start":[["^Hello world","\\n",["ev","str",{"f()":".^.s"},"/str","/ev",{"*":".^.c","flg":18},{"s":["^Hut 14.",null],"c":[{"f()":".^.^.s"},"\\n","^The door was locked after I sat down.","\\n","end",{"#f":5}]}],null],{"#f":3}],"global decl":["ev",0,{"VAR=":"forceful"},0,{"VAR=":"evasive"},0,{"VAR=":"teacup"},0,{"VAR=":"gotcomponent"},0,{"VAR=":"drugged"},0,{"VAR=":"hooper_mentioned"},0,{"VAR=":"losttemper"},0,{"VAR=":"admitblackmail"},0,{"VAR=":"hooperClueType"},0,{"VAR=":"hooperConfessed"},0,{"VAR=":"smashingWindowItem"},0,{"VAR=":"notraitor"},0,{"VAR=":"revealedhooperasculprit"},0,{"VAR=":"smashedglass"},0,{"VAR=":"muddyshoes"},0,{"VAR=":"framedhooper"},0,{"VAR=":"putcomponentintent"},0,{"VAR=":"throwncomponentaway"},0,{"VAR=":"piecereturned"},0,{"VAR=":"longgrasshooperframe"},0,{"VAR=":"DEBUG"},"/ev","end",null],"#f":3}]}');
		story.ToJsonString();
		
	
	}
	
	static function main() 
	{
		
		Lib.current.addChild( new InkRuntimeFlash() );
	}
	
	
	
}
