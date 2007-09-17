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
package com.brokenfunction.doom.data {
	public class Vertex {
		private var _x:int = 0;
		private var _y:int = 0;
		
		public function Vertex(x:int,y:int) {
			_x = x;
			_y = y;
		}
		public function toString():String {
			return "(x="+_x+", y="+_y+")";
		}

		public function get x():int {return _x;}
		public function get y():int {return _y;}
	}
}