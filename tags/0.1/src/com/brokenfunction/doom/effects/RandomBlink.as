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
package com.brokenfunction.doom.effects {
	import com.brokenfunction.doom.*;
	import com.brokenfunction.doom.data.*;
	import com.brokenfunction.ezlo.*;

	public class RandomBlink extends AbstractEffect {
		static private const MAX:uint = 32;
		
		private var _sector:Sector;
		private var timeout:uint = 0;
		private var lightA:uint;
		private var lightB:uint;
		
		public function RandomBlink(sector:Sector,timeService:TimeService) {
			_sector = sector;
			lightA = _sector.lightLevel;
			lightB = getLowestNearbyLightLevel(sector,0);
			timeService.addTimeListener(onTick,35);
		}
		private function onTick(e:TimeEvent):void {
			var steps:uint = e.steps;
			if (steps >= timeout) {
				_sector.lightLevel = lightB;
				timeout = Math.random()*MAX;
			} else {
				_sector.lightLevel = lightA;
				timeout -= steps;
			}
		}
	}
}