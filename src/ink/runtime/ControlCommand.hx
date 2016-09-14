package ink.runtime;

/**
 * Done!
 * @author Glidias
 */
class ControlCommand extends RObject
{

	public var commandType:CommandType;  // CommandType { get; protected set; }
	
	public function new() 
	{
		super();
		commandType = CommandType.NotSet;
	}
	
	public static function createFromCommandType(commandType:CommandType):ControlCommand {
		var me:ControlCommand = new ControlCommand();
		me.commandType = commandType;
		return me;
	}
	
	override public function  Copy():RObject
	{
		return  ControlCommand.createFromCommandType(commandType);
	}

	 // The following static factory methods are to make generating these objects
        // slightly more succinct. Without these, the code gets pretty massive! e.g.
        //
        //     var c = new Runtime.ControlCommand(Runtime.ControlCommand.CommandType.EvalStart)
        // 
        // as opposed to
        //
        //     var c = Runtime.ControlCommand.EvalStart()

        public static function EvalStart():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.EvalStart);
        }

        public static function EvalOutput():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.EvalOutput);
        }

        public static function EvalEnd():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.EvalEnd);
        }

        public static function Duplicate():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.Duplicate);
        }

        public static function PopEvaluatedValue():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.PopEvaluatedValue);
        }

        public static function PopFunction():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.PopFunction);
        }

        public static function PopTunnel():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.PopTunnel);
        }
            
        public static function BeginString():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.BeginString);
        }

        public static function EndString():ControlCommand {
            return  ControlCommand.createFromCommandType(CommandType.EndString);
        }

        public static function NoOp():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.NoOp);
        }

        public static function ChoiceCount():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.ChoiceCount);
        }

        public static function TurnsSince():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.TurnsSince);
        }

        public static function VisitIndex():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.VisitIndex);
        }
            
        public static function SequenceShuffleIndex():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.SequenceShuffleIndex);
        }

        public static function StartThread():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.StartThread);
        }

        public static function Done():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.Done);
        }

        public static function End():ControlCommand {
            return ControlCommand.createFromCommandType(CommandType.End);
        }

        public inline  function ToString ():String  //override
        {
            return Std.string(commandType);  //.ToString()
        }
		public  function toString ():String  //override
        {
            return ToString();  
        }
	
}

/*
class CommandType
{
	public static inline var NotSet:Int = -1;
	public static inline var EvalStart:Int= 0;
	public static inline var EvalOutput:Int= 1;
	public static inline var EvalEnd:Int= 2;
	public static inline var Duplicate:Int= 3;
	public static inline var PopEvaluatedValue:Int= 4;
	public static inline var PopFunction:Int= 5;
	public static inline var PopTunnel:Int= 6;
	public static inline var BeginString:Int= 7;
	public static inline var EndString:Int= 8;
	public static inline var NoOp:Int= 9;
	public static inline var ChoiceCount:Int= 10;
	public static inline var TurnsSince:Int= 11;
	public static inline var VisitIndex:Int= 12;
	public static inline var SequenceShuffleIndex:Int= 13;
	public static inline var StartThread:Int= 14;
	public static inline var Done:Int= 15;
	public static inline var End:Int= 16;
	public static inline var TOTAL_VALUES:Int = 17;
}
*/

@:enum
abstract CommandType(Int)
{
	var NotSet = -1;
	var EvalStart= 0;
	var EvalOutput= 1;
	var EvalEnd= 2;
	var Duplicate= 3;
	var PopEvaluatedValue= 4;
	var PopFunction= 5;
	var PopTunnel= 6;
	var BeginString= 7;
	var EndString= 8;
	var NoOp= 9;
	var ChoiceCount= 10;
	var TurnsSince= 11;
	var VisitIndex= 12;
	var SequenceShuffleIndex= 13;
	var StartThread= 14;
	var Done= 15;
	var End= 16;
	var TOTAL_VALUES = 17;
}