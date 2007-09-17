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
	import com.brokenfunction.doom.data.*;
	import flash.utils.ByteArray;
	
	public class LumpGroup {
		private var lumps:Object = {};
		private var _name:String;
		
		public function LumpGroup(nm:String) {
			_name = nm;
		}
		public function get name():String {
			return _name;
		}
		public function addLump(lump:Lump):void {
			if (lumps[lump.name] is Lump) {
				trace("Lump \""+lump.name+"\" in \""+_name+"\" already encountered, ignoring");
			} else {
				lumps[lump.name] = lump;
			}
		}
		public function getLump(nm:String):Lump {
			if (lumps[nm] is Lump) {
				return lumps[nm] as Lump;
			} else {
				throw new Error("Lump \""+nm+"\" in \""+_name+"\" not found");
			}
		}
		public function lumpExists(nm:String):Boolean {
			return (lumps[nm] is Lump);
		}
	}
}