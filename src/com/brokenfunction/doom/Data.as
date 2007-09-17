/*
 * ReDoom - A Doom port written for Flash
 * Copyright (C) 2007 Max Herkender
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package com.brokenfunction.doom {
	public class Data {
		static public var sintable:Array = genSin();
		static public var costable:Array = genCos();
		static public var tantable:Array = genTan();

		static private function genSin():Array {
			var sin:Array = new Array(0x10000);
			var i:int = sin.length;
			while (i-- > 0) {
				sin[i] = Math.sin((i*Math.PI)/0x8000);
			}
			return sin;
		}
		static private function genCos():Array {
			var cos:Array = new Array(0x10000);
			var i:int = cos.length;
			while (i-- > 0) {
				cos[i] = Math.cos((i*Math.PI)/0x8000);
			}
			return cos;
		}
		static private function genTan():Array {
			var tan:Array = new Array(0x10000);
			var i:int = tan.length;
			while (i-- > 0) {
				tan[i] = Math.tan((i*Math.PI)/0x8000);
			}
			return tan;
		}
	}
}