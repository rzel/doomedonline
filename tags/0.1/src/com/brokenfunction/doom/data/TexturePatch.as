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
	public class TexturePatch {
		private var _offX:uint;
		private var _offY:uint;
		private var _wall:String;
		
		public function TexturePatch(offX:uint,offY:uint,wall:String) {
			_offX = offX;
			_offY = offY;
			_wall = wall;
		}
		
		public function get offX():uint {return _offX;}
		public function get offY():uint {return _offY;}
		public function get wall():String {return _wall;}
	}
}