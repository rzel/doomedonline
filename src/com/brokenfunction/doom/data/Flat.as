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
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class Flat extends ByteArray {
		static public const SKY_FLAT:Flat = new Flat();

		private var _next:Flat;
		private var _current:Flat;
		
		public function Flat(data:ByteArray = null) {
			super();
			length = 0x1000;
			if (data) writeBytes(data,data.position,length);
			_next = _current = this;
		}
		
		public function get isAnimated():Boolean {
			return (_next != this);
		}

		public function get next():Flat {return _next;}
		public function get current():Flat {return _current;}
		
		public function set next(f:Flat):void {_next = f;}
		public function set current(f:Flat):void {_current = f;}
	}
}