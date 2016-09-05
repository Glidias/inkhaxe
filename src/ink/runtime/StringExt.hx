package ink.runtime;

/**
 * StrongJointExtension.cs
 * Done!
 * @author Glidias
 */
class StringExt
{

	public static function Join<T>( separator:String,  objects:Array<T>):String
	{
		var sb = new StringBuf ();

		var isFirst = true;
		for ( o in objects) {

			if (!isFirst)
				sb.add (separator);

			sb.add(Std.string(o));
			isFirst = false;
		}

		return sb.toString();
	}
}