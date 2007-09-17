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

	public class AbstractEffect {
		public function AbstractEffect() {
		}
		protected function getLowestNearbyLightLevel(sector:Sector,defaultLevel:uint = 0):uint {
			var linedefs:Array = sector.linedefs;
			var minLevel:uint = sector.lightLevel;
			var linedef:Linedef, sector2:Sector;
			var i:int = linedefs.length;
			while (i-- > 0) {
				linedef = linedefs[i];
				if (!linedef.isTwoSided) continue;
				sector2 = linedef.rightSide.sector;
				if (sector2 === sector) {
					sector2 = linedef.leftSide.sector;
					if (sector2 === sector) continue;
				}
				
				if (sector2.lightLevel < minLevel) minLevel = sector2.lightLevel;
			}

			return (minLevel < sector.lightLevel)? minLevel :defaultLevel;
		}
	}
}