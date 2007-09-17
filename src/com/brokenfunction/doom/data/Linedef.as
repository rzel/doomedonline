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
	public class Linedef {
		static public const IMPASSIBLE:uint = (1 << 0);
		static public const BLOCK_MONSTERS:uint = (1 << 1);
		static public const TWO_SIDED:uint = (1 << 2);
		static public const UNPEGGED_UPPER:uint = (1 << 3);
		static public const UNPEGGED_LOWER:uint = (1 << 4);
		static public const SECRET:uint = (1 << 5);
		static public const BLOCK_SOUND:uint = (1 << 6);
		static public const AUTOMAP_HIDDEN:uint = (1 << 7);
		static public const AUTOMAP_VISIBLE:uint = (1 << 8);
		
		private var _start:Vertex;
		private var _end:Vertex;
		private var _length:Number;
		private var _angle:uint;// BAM
		private var _flags:uint;
		private var _type:uint;
		private var _rightSide:Sidedef;
		private var _leftSide:Sidedef;
		
		public function Linedef(start:Vertex,end:Vertex,flags:uint,type:uint,rightSide:Sidedef,leftSide:Sidedef) {
			_start = start;
			_end = end;
			_flags = flags;
			_type = type;
			_rightSide = rightSide;
			_leftSide = leftSide;
			
			var dx:int = _end.x-_start.x;
			var dy:int = _end.y-_start.y;
			_length = Math.sqrt(dx*dx+dy*dy);
			_angle = (Math.atan2(dy,dx)*(0x8000/Math.PI)) & 0xffff;
		}
		
		public function toString():String {
			return "(x1="+_start.x+", y1="+_start.y+", x2="+_end.x+", y2="+_end.y+")";
		}
		public function get start():Vertex {return _start;}
		public function get end():Vertex {return _end;}
		public function get length():Number {return _length;}
		public function get angle():uint {return _angle;}
		public function get flags():uint {return _flags;}
		public function get type():uint {return _type;}
		public function get rightSide():Sidedef {return _rightSide;}
		public function get leftSide():Sidedef {return _leftSide;}
		
		public function get isImpassible():Boolean {
			return ((_flags & IMPASSIBLE) === IMPASSIBLE);
		}
		public function get blocksMonsters():Boolean {
			return ((_flags & BLOCK_MONSTERS) === BLOCK_MONSTERS);
		}
		public function get isTwoSided():Boolean {
			return ((_flags & TWO_SIDED) === TWO_SIDED);
		}
		public function get unpeggedLower():Boolean {
			return ((_flags & UNPEGGED_LOWER) === UNPEGGED_LOWER);
		}
		public function get unpeggedUpper():Boolean {
			return ((_flags & UNPEGGED_UPPER) === UNPEGGED_UPPER);
		}
		public function get isSecret():Boolean {
			return ((_flags & SECRET) === SECRET);
		}
		public function get blocksSound():Boolean {
			return ((_flags & BLOCK_SOUND) === BLOCK_SOUND);
		}
		public function get hiddenFromAutomap():Boolean {
			return ((_flags & AUTOMAP_HIDDEN) === AUTOMAP_HIDDEN);
		}
		public function get alwaysVisibleOnAutomap():Boolean {
			return ((_flags & AUTOMAP_VISIBLE) === AUTOMAP_VISIBLE);
		}
	}
}