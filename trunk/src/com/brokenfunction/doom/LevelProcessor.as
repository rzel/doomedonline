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
package com.brokenfunction.doom {
	import com.brokenfunction.doom.data.*;
	import com.brokenfunction.doom.effects.*;
	import flash.utils.Dictionary;
	
	public class LevelProcessor {
		public function LevelProcessor(level:DeWadLevel) {
			var sectors:Array = level.sectors;
			var i:int = sectors.length;
			var check:Dictionary = new Dictionary(true);
			while (i-- > 0) {
				processSector(sectors[i],level,check);
			}
		}
		private function randomUint():uint {
			return uint(Math.random()*uint.MAX_VALUE);
		}
		private function processSector(sector:Sector,level:DeWadLevel,check:Dictionary):void {
			var linedefs:Array = sector.linedefs;
			var i:int = linedefs.length;
			while (i-- > 0) {
				processLinedef(linedefs[i],level,check);
			}
			
			var flat:Flat = sector.ceilFlat;
			if (flat.isAnimated && !(flat in check))  {
				new AnimatedFlat(flat,level.timeService);
				check[flat] = true;
			}
			flat = sector.floorFlat;
			if (flat.isAnimated)  {
				new AnimatedFlat(flat,level.timeService);
				check[flat] = true;
			}
			
			switch (sector.type) {
				case(0x01):// random off
					new RandomBlink(sector,level.timeService);
					break;
				case(0x02):// blink every 0.5 second
				case(0x04):// blink every 0.5 second (w/ -10/20% health)
					new Blink05(sector,level.timeService);
					break;
				case(0x03):// blink every 1.0 second
					new Blink10(sector,level.timeService);
					break;
				case(0x08):// glowing light
					new Glow(sector,level.timeService);
					break;
				case(0x0a):// 30 seconds after level start, ceiling closes like a door
					// todo
					break;
				case(0x0c):// blink every 0.5 second, synchronized
					new Blink05(sector,level.timeService);
					break;
				case(0x0d):// blink every 1.0 second, synchronized
					new Blink10(sector,level.timeService);
					break;
				case(0x0e):// 300 seconds after level start, ceiling opens like a door
					// todo
					break;
			}
		}
		private function processLinedef(linedef:Linedef,level:DeWadLevel,check:Dictionary):void {
			if (linedef.isTwoSided) {
				processSidedef(linedef.rightSide,true,level,check);
				processSidedef(linedef.leftSide,true,level,check);
			} else {
				processSidedef(linedef.rightSide,false,level,check);
			}
			
			switch (linedef.type) {
				case(48):// scrolling wall
					new ScrollingWall(linedef,level.timeService);
					break;
			}
		}
		private function processSidedef(sidedef:Sidedef,ignoreMiddle:Boolean,level:DeWadLevel,check:Dictionary):void {
			var texture:Texture = sidedef.upperTexture;
			if (texture && texture.isAnimated && !(texture in check)) {
				new AnimatedTexture(texture,level.timeService);
				check[texture] = true;
			}
			texture = sidedef.middleTexture;
			if (texture && texture.isAnimated && !(texture in check)) {
				new AnimatedTexture(texture,level.timeService);
				check[texture] = true;
			}
			texture = sidedef.lowerTexture;
			if (texture && texture.isAnimated && !(texture in check)) {
				new AnimatedTexture(texture,level.timeService);
				check[texture] = true;
			}
		}
	}
}