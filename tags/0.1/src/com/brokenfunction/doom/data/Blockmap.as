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
	import flash.utils.Dictionary;
	
	public class Blockmap {
		static public const BLOCK_SHIFT:uint = 7;
		static public const BLOCK_SIZE:uint = (1 << BLOCK_SHIFT);// 128
		static private const BLOCK_MID:uint = BLOCK_SIZE >>> 1;// 64

		private var _offX:int;
		private var _offY:int;
		private var _cols:uint;
		private var _rows:uint;
		private var map:Dictionary = new Dictionary();
		
		public function Blockmap(offX:int,offY:int,cols:uint,rows:uint) {
			_offX = offX;
			_offY = offY;
			if (cols > 0xffff || rows > 0xffff) throw new Error("Blockmap given bad boundries");
			_cols = cols;
			_rows = rows;
			var i:int = _cols, j:int;
			while (i-- > 0) {
				j = _rows;
				while (j-- > 0) {
					map[(i << 16) | j] = new Block();
				}
			}
		}
		
		public function get offX():int {return _offX;}
		public function get offY():int {return _offY;}
		public function get cols():uint {return _cols;}
		public function get rows():uint {return _rows;}
		
		public function getBlock(x:uint,y:uint):Array {
			var block:Block = map[((x & 0xffff) << 16) | (y & 0xffff)];
			return (block)? block.linedefs :[];
		}
		public function setBlock(x:uint,y:uint,linedefs:Array):void {
			var block:Block = map[((x & 0xffff) << 16) | (y & 0xffff)];
			if (block) block.linedefs = linedefs;
		}
		public function getThings(x:uint,y:uint):Array {
			var block:Block = map[((x & 0xffff) << 16) | (y & 0xffff)];
			return (block)? block.things :[];
		}
	}
}
class Block {
	public var linedefs:Array = [];
	public var things:Array = [];
}