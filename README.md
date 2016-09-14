# inkhaxe
Port from C# to Haxe for the ink runtime: So you can use inkle's ink engine directly for all other target platforms (Javascript, Flash, Neko, C++, Java, etc.), besides just C#.

Basically, it should run similar to the original runtime as found in https://github.com/inkle/ink/blob/master/Documentation/RunningYourInk.md
	
However, here are the differences:
	
- Package name is `ink.runtime`, not `Ink.Runtime`. So, you call something like `new ink.runtime.Story(...)`.
- BindExternalFunction has no method overloading because Haxe doesn't support it, so you must explicitly use the required function for the stipulated number of parameters, such as `BindExternalFunction0(...)`,`BindExternalFunction1(...)`,`BindExternalFunction2(...)`,`BindExternalFunction3(...)`  or use `BindExternalFunctionGeneral()` for more than 3 parameters.

Some additions:
	
- `ReflectExternalBindings(array:Array=null):Array` is a useful method to trace all required external functions from a given Story instance at runtime. It returns a new  array (or existing array in the parameter) with all external function name strings included in the array. So, you can iterate through the array to faciliate automating the process of binding to any required external functions.

Target demo platforms that have been tested and proven to work:
- Javascript

____

For any issues, check the Issues tab in the github repository.


