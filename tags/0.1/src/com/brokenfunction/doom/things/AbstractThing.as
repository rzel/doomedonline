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
package com.brokenfunction.doom.things {
	import com.brokenfunction.doom.*;
	import com.brokenfunction.doom.data.*;
	
	public class AbstractThing extends Thing {
		private var _rad:uint = 0;
		private var _hanging:Boolean;
		private var _alwaysBright:Boolean;
		protected var ssector:SSector;
		protected var sector:Sector;
		
		public function AbstractThing(level:DeWadLevel,rad:uint,col:Boolean,x:int,y:int,hanging:Boolean,alwaysBright:Boolean) {
			super(x,y);
			_hanging = hanging;
			_alwaysBright = alwaysBright;
			ssector = resolveSSector(level.mainNode);
			sector = ssector.sector;
			ssector.things.push(this);
			sector.things.push(this);
		}

		public override function get rad():uint {return _rad;}
		public function set rad(r:uint):void {_rad = r;}

		public override function get z():int {
			return (_hanging)? sector.ceil :sector.floor;
		}
		public override function get lightLevel():uint {
			return (_alwaysBright)? 255 :sector.lightLevel;
		}
	}
}