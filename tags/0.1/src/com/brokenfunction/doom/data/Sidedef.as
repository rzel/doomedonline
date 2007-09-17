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
	public class Sidedef {
		private var _offX:int;
		private var _offY:int;
		private var _upperTexture:Texture;
		private var _lowerTexture:Texture;
		private var _middleTexture:Texture;
		private var _sector:Sector;
		
		public function Sidedef(offX:int,offY:int,upperTexture:Texture,lowerTexture:Texture,middleTexture:Texture,sector:Sector) {
			_offX = offX;
			_offY = offY;
			_upperTexture = upperTexture;
			_lowerTexture = lowerTexture;
			_middleTexture = middleTexture;
			_sector = sector;
		}
		
		public function toString():String {
			return "("+_upperTexture+" "+_middleTexture+" "+_lowerTexture+")";
		}
		
		public function get offX():int {return _offX;}
		public function get offY():int {return _offY;}
		public function get upperTexture():Texture {return _upperTexture;}
		public function get lowerTexture():Texture {return _lowerTexture;}
		public function get middleTexture():Texture {return _middleTexture;}
		public function get sector():Sector {return _sector;}
		
		public function set offX(x:int):void {_offX = x;}
		public function set offY(y:int):void {_offY = y;}
		/*public function set upperTexture(t:Texture):void {_upperTexture = t;}
		public function set lowerTexture(t:Texture):void {_lowerTexture = t;}
		public function set middleTexture(t:Texture):void { _middleTexture = t;}*/
	}
}