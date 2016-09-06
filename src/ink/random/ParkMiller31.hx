/*
 *                            _/                                                    _/
 *       _/_/_/      _/_/    _/  _/    _/    _/_/_/    _/_/    _/_/_/      _/_/_/  _/
 *      _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/
 *     _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/
 *    _/_/_/      _/_/    _/    _/_/_/    _/_/_/    _/_/    _/    _/    _/_/_/  _/
 *   _/                            _/        _/
 *  _/                        _/_/      _/_/
 *
 * POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2009 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package ink.random;





/**
 * <p>A Park-Miller-Carta PRNG (pseudo random number generator).</p>
 * <p>Integer implementation, using only 32 bit integer maths and no divisions.</p>
 * <p>See <a href="http://www.firstpr.com.au/dsp/rand31/rand31-park-miller-carta.cc.txt" target="_blank">http://www.firstpr.com.au/dsp/rand31/rand31-park-miller-carta.cc.txt</a></p>
 * <p>See <a href="http://en.wikipedia.org/wiki/Park%E2%80%93Miller_random_number_generator" target="_blank">Park-Miller random number generator</a>.</p>
 * <p>See <a href="http://lab.polygonal.de/?p=162" target="_blank">A good Pseudo-Random Number Generator (PRNG)</a>.</p>
 */
class ParkMiller31 extends RNG
{
	private static var MAX_VALUE = Limits.INT32_MAX;
	
	/**
	 * Default seed value is 1.
	 */
	public function new(seed = 1)
	{
		super();
		setSeed(seed);
	}
	
	/**
	 * @throws de.polygonal.core.util.AssertError invalid seed value (has to be in the range <arg>&#091;0, 2^31 - 1&#093;</arg> (debug only).
	 */
	override public function setSeed(seed:Int):Void
	{
		//#if (debug)
		//D.assert(seed >= 0 && seed < Limits.INT32_MAX, "seed >= 0 && seed < Limits.INT32_MAX");
		//#end
		
		super.setSeed(seed);
	}
	
	/**
	 * Returns an integral number in the interval <arg>&#091;0, 0x7fffffff)</arg>.<br/>
	 */
	override public function random():Float
	{
		var lo = 16807 * (_seed & 0xffff);
		var hi = 16807 * (_seed >>> 16);
		lo += (hi & 0x7fff) << 16;
		lo += hi >>> 15;
		
		// Check to see if the unsigned representation of lo is > MAX_VALUE
		if (lo > MAX_VALUE || lo < 0) lo -= MAX_VALUE;
		
		return _seed = lo;
	}
	
	override public function randomFloat():Float
	{
		return random() / 2147483647.;
	}
}