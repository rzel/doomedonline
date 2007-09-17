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
	public class Texture extends Image {
		private var _next:Texture;
		private var _current:Texture;
		
		public function Texture(width:uint,height:uint,offX:int = 0,offY:int = 0) {
			super(width,height,offX,offY);
			_next = _current = this;
		}
		
		public function get isAnimated():Boolean {
			return (_next != this);
		}

		public function get next():Texture {return _next;}
		public function get current():Texture {return _current;}
		
		public function set next(t:Texture):void {_next = t;}
		public function set current(t:Texture):void {_current = t;}
	}
}