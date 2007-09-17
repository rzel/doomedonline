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
	
	public class PlayPalette {
		static private const NULL_POINT:Point = new Point(0,0);
		private var _zeros:Array = new Array(256);
		private var _ones:Array = new Array(256);
		private var _list:Array = new Array(256);
		
		public function PlayPalette(data:ByteArray,index:uint) {
			if (index >= 14) throw new Error("Invalid index");
			
			data.position += index*256;
			var i:int = 0, r:int, g:int, b:int;
			while (i < 256) {
				r = data.readUnsignedByte();
				g = data.readUnsignedByte();
				b = data.readUnsignedByte();
				// this adds more contrast, and darkens each color slightly
				r = 128+(r-128)*1.15-4;
				g = 128+(g-128)*1.15-4;
				b = 128+(b-128)*1.15-4;
				if (r < 0) r = 0;
				else if (r > 255) r = 255;
				if (g < 0) g = 0;
				else if (g > 255) g = 255;
				if (b < 0) b = 0;
				else if (b > 255) b = 255;
				_list[i] = (r << 16) | (g << 8) | b;

				_zeros[i] = 0x00;
				_ones[i] = 0xff;
				i++;
			}
		}
		public function mapPalette(bitmapData:BitmapData):void {
			bitmapData.paletteMap(bitmapData,bitmapData.rect,NULL_POINT,_zeros,_zeros,_list,null);
		}
		
		public function get list():Array {return _list;}
	}
}