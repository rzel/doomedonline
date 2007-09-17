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
	public class TextureInfo {
		private var _name:String;
		private var _width:uint;
		private var _height:uint;
		private var _patches:Array = [];
		private var _next:TextureInfo = null;
		
		public function TextureInfo(name:String,width:uint,height:uint) {
			_name = name;
			_width = width;
			_height = height;
		}
		
		public function get name():String {return _name;}
		public function get width():uint {return _width;}
		public function get height():uint {return _height;}
		public function get patches():Array {return _patches;}
		public function get next():TextureInfo {return _next;}
		
		public function set next(t:TextureInfo):void {_next = t;}
	}
}