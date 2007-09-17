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
	public class Seg {
		private var _start:Vertex;
		private var _end:Vertex;
		private var _angle:uint;// BAM
		private var _linedef:Linedef;
		private var _reverseDir:Boolean;
		private var _linedefOffset:int;
		
		public function Seg(start:Vertex,end:Vertex,angle:uint,linedef:Linedef,reverseDir:Boolean,linedefOffset:int) {
			_start = start;
			_end = end;
			_angle = angle;
			//_angle = Math.atan2(_end.y-_start.y,_end.x-_start.x)*(0x8000/Math.PI)) & 0xffff;
			_linedef = linedef;
			_reverseDir = reverseDir;
			_linedefOffset = linedefOffset;
		}
		
		public function get start():Vertex {return _start;}
		public function get end():Vertex {return _end;}
		public function get angle():uint {return _angle;}
		public function get linedef():Linedef {return _linedef;}
		public function get reverseDir():Boolean {return _reverseDir;}
		public function get linedefOffset():int {return _linedefOffset;}

		public function get rightSide():Sidedef {
			return (_reverseDir)? _linedef.leftSide :_linedef.rightSide;
		}
		public function get leftSide():Sidedef {
			return (_reverseDir)? _linedef.rightSide :_linedef.leftSide;
		}
		public function get sector():Sector {
			return ((_reverseDir)? _linedef.leftSide :_linedef.rightSide).sector;
		}
	}
}