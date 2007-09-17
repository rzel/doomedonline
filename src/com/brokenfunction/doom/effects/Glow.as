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

	public class Glow extends AbstractEffect {
		static private const GLOWDX:uint = 8;
		private var _sector:Sector;
		private var time:uint;
		private var dir:Boolean = false;
		private var lightA:uint;
		private var lightB:uint;
		
		public function Glow(sector:Sector,timeService:TimeService) {
			_sector = sector;
			lightA = _sector.lightLevel;
			lightB = getLowestNearbyLightLevel(sector,0);
			timeService.addTimeListener(onTick,35);
		}
		private function onTick(e:TimeEvent):void {
			var steps:uint = e.steps;
			while (steps-- > 0) {
				if (dir) {
					if ((_sector.lightLevel -= GLOWDX) < lightB) {
						_sector.lightLevel += GLOWDX;
						dir = false;
					}
				} else {
					if ((_sector.lightLevel += GLOWDX) > lightA) {
						_sector.lightLevel -= GLOWDX;
						dir = true;
					}
				}
			}
		}
	}
}