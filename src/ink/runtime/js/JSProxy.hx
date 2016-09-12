package ink.runtime.js;

/**
 * ...
 * @author Glidias
 */
@:native("Proxy")
extern class JSProxy
{
	function new(target:Dynamic, handler:Dynamic);
}