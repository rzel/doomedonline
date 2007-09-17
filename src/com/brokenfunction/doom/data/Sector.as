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
	public class Sector {
		private var _floor:int;
		private var _ceil:int;
		private var _floorFlat:Flat;
		private var _ceilFlat:Flat;
		private var _lightLevel:uint;
		private var _type:uint;
		private var _things:Array = [];
		private var _linedefs:Array = [];
		
		public function Sector(floor:int,ceil:int,floorFlat:Flat,ceilFlat:Flat,lightLevel:uint,type:uint) {
			_floor = floor;
			_ceil = ceil;
			_floorFlat = floorFlat;
			_ceilFlat = ceilFlat;
			_lightLevel = lightLevel;
			_type = type;
		}
		
		public function toString():String {
			return "(ceiling="+_ceilFlat+" @ "+_ceil+", floor="+_floorFlat+" @ "+_floor+", type="+_type+", lightLevel="+_lightLevel+", linedefs="+_linedefs.length+")";
		}

		public function get floor():int {return _floor;}
		public function get ceil():int {return _ceil;}
		public function get floorFlat():Flat {return _floorFlat;}
		public function get ceilFlat():Flat {return _ceilFlat;}
		public function get lightLevel():uint {return _lightLevel;}
		public function get type():uint {return _type;}
		public function get things():Array {return _things;}
		public function get linedefs():Array {return _linedefs;}
		
		public function set floor(f:int):void {_floor = f;}
		public function set ceil(c:int):void {_ceil = c;}
		/*public function set floorFlat(t:Flat):void {_floorFlat = t;}
		public function set ceilFlat(t:Flat):void {_ceilFlat = t;}*/
		public function set lightLevel(l:uint):void {_lightLevel = l;}
		public function set type(t:uint):void {_type = t;}
	}
}