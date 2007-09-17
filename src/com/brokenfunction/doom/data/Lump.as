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
	import com.brokenfunction.doom.readStr8;
	import flash.utils.ByteArray;
	
	public class Lump {
		private var _offset:uint;
		private var _size:uint;
		private var _name:String;
		private var _next:Lump = null;
		
		public function Lump(data:ByteArray) {
			_offset = data.readUnsignedInt();
			_size = data.readUnsignedInt();
			_name = readStr8(data);
		}
		public function toString():String {
			return "(name="+_name+", start="+_offset+", size="+_size+")";
		}
		
		public function get offset():uint {return _offset;}
		public function get size():uint {return _size;}
		public function get name():String {return _name;}
		public function get next():Lump {return _next;}
		
		public function set next(l:Lump):void {_next = l;}
	}
}