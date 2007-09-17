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

	public class Blink10 extends AbstractEffect {
		static private const BLINK:uint = 70;
		static private const HOLD:uint = 2;
		
		private var _sector:Sector;
		private var lightA:uint;
		private var lightB:uint;
		private var timeout:uint = 0;
		
		public function Blink10(sector:Sector,timeService:TimeService) {
			_sector = sector;
			lightA = _sector.lightLevel;
			lightB = getLowestNearbyLightLevel(_sector,0);
			timeService.addTimeListener(onTick,35);
		}
		private function onTick(e:TimeEvent):void {
			var steps:uint = e.steps;
			if (steps >= timeout) {
				if (_sector.lightLevel === lightA) {
					_sector.lightLevel = lightB;
					timeout = BLINK;
				} else {
					_sector.lightLevel = lightA;
					timeout = HOLD;
				}
			} else {
				timeout -= steps;
			}
		}
	}
}