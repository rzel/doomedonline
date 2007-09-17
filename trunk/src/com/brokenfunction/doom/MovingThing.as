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
	import com.brokenfunction.ezlo.*;
	
	public class MovingThing extends Thing {
		static private const MAX_MOVEMENT:uint = 25;
		static private const FRICTION:Number = 0xE8/0x100;
		
		private var speed:int = 0;
		private var vZ:int = 0;
		private var mainNode:Node;
		private var blockmap:Blockmap;
		private var sector:Sector;

		private var _z:int = 0;
		private var _height:int;
		private var _eyeHeight:int;
		private var _forward:int;
		private var _side:int;
		private var _rot:int;
		private var _time:uint;
		
		public function MovingThing(level:DeWadLevel,height:int,eyeHeight:int = -1) {
			super();
			_height = height;
			_eyeHeight = (eyeHeight < 0)? (_height/1.4) :eyeHeight;
			mainNode = level.mainNode;
			blockmap = level.blockmap;
		}
		public function move(forward:int,side:int,angle:uint,e:TimeEvent):void {
			var steps:uint = e.steps;
			
			_rot = (_rot+int(angle*e.subSteps)) & 0xffff;
			while (steps-- > 0) {
				if (vZ >= 0) {
					_forward = (_forward+forward)*FRICTION;
					_side = (_side+side)*FRICTION;
				}
				if (_forward > MAX_MOVEMENT) _forward = MAX_MOVEMENT;
				else if (_forward < -MAX_MOVEMENT) _forward = -MAX_MOVEMENT;
				if (_side > MAX_MOVEMENT) _side = MAX_MOVEMENT;
				else if (_side < -MAX_MOVEMENT) _side = -MAX_MOVEMENT;
			}
			
			var sin:Number = Data.sintable[_rot];
			var cos:Number = Data.costable[_rot];
			movX = _forward*cos+_side*sin;
			movY = _forward*sin-_side*cos;
			
			var lastSector:Sector = sector;
			if (!sector) sector = resolveSSector(mainNode).sector;
			clipMovement(blockmap,1);
			sector = resolveSSector(mainNode).sector;// lazy
			
			if (sector) {
				if (vZ < 0 && lastSector !== sector) vZ = 0;
				var tz:int = sector.floor;
				if (tz !== _z) {
					if (tz < _z) {// fall
						if (tz > (_z += (vZ -= 4))) {
							_z = tz;
						}
					} else if (tz < (_z += (vZ += 8))) {// climb
						_z = tz;
					}
				} else if (vZ) {
					vZ = 0;
				}
			}
		}

		public override function get rot():uint {return _rot;}
		public override function get z():int {return _z;}
		
		public function set rot(r:uint):void {_rot = r & 0xffff;}
		public function set z(c:int):void {_z = c;}
		
		public function get eyeZ():int {
			var bob:int = (movX*movX+movY*movY) >> 5;
			if (bob > 8) bob = 8;
			bob = bob*Data.sintable[((_time >> 2)*(8192/2.5)) & 0xffff];
			return _z+_eyeHeight+bob;
		}
	}
}