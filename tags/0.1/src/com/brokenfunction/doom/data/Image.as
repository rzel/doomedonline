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
	import flash.geom.Point;
	import flash.utils.ByteArray;

	public class Image extends BitmapData {
		private var _offX:int;
		private var _offY:int;
		private var _width:uint;
		private var _height:uint;
		
		public function Image(width:uint,height:uint,offX:int = 0,offY:int = 0) {
			super(width,height,true,0x00000000);
			_offX = offX;
			_offY = offY;
		}
		public function copyImage(img:Image,x:int = 0,y:int = 0):void {
			copyPixels(img,img.rect,new Point(x,y),null,null,true);
		}
		public function toBitmapData(colormap:Colormap,index:uint):BitmapData {
			// todo
			return null;
		}

		public function get offX():int {return _offX;}
		public function get offY():int {return _offY;}
	}
}