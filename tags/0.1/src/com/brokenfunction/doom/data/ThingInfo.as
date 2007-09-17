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
	public class ThingInfo {
		static public const OPTION_SKILLEASY:uint = (1 << 0);
		static public const OPTION_SKILLNORMAL:uint = (1 << 1);
		static public const OPTION_SKILLHARD:uint = (1 << 2);
		static public const OPTION_DEAF:uint = (1 << 3);
		static public const OPTION_MULTIPLAYER:uint = (1 << 4);
		
		private var _x:int = 0;
		private var _y:int = 0;
		private var _ang:uint = 0;
		private var _type:uint = 0;
		private var _options:uint = 0;
		
		public function ThingInfo(x:int,y:int,ang:uint,type:uint,options:uint) {
			_x = x;
			_y = y;
			_ang = ang;
			_type = type;
			_options = options;
		}

		public function get x():int {return _x;}
		public function get y():int {return _y;}
		public function get ang():uint {return _ang;}
		public function get type():uint {return _type;}
		public function get options():uint {return _options;}
		
		public function get isDeaf():Boolean {
			return ((_options & OPTION_DEAF) === OPTION_DEAF);
		}
	}
}