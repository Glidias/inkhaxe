package ink.runtime;

/**
 * Done
 * @author Glidias
 */
/*
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.ExprTools;
*/

class Assert {
    /* Static assert */
	/*
    macro static public function s(expr:Expr, ?error:String):Expr {
        if (error == null) {
            error = "";
        }

        if (expr == null) {
            throw new Error("Expression must be non-null", expr.pos);
        }

        var value = ExprTools.getValue(Context.getTypedExpr(Context.typeExpr(expr)));

        if (value == null) {
            throw new Error("Expression value is null", expr.pos);
        }
        else if (value != true && value != false) {
            throw new Error("Expression does not evaluate to a boolean value", expr.pos);
        }
        else if(value == false) {
            throw new Error("Assertion failure: " + ExprTools.toString(expr) + " " + "[ " + error + " ]", expr.pos);
        }

        return macro { };
    }
	*/
	
	static inline public  function bool(result:Bool, ?error:String):Void {
		if (!result) throw error;
	}
}