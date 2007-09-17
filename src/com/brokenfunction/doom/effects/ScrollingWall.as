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

	public class ScrollingWall {
		private var _linedef:Linedef;
		
		public function ScrollingWall(linedef:Linedef,timeService:TimeService) {
			_linedef = linedef;
			timeService.addTimeListener(onTick,35/2);
		}
		public function onTick(e:TimeEvent):void {
			_linedef.rightSide.offX += e.steps;
			// is this also scrolled?
			//if (_linedef.isTwoSided) _linedef.leftSide.offX += e.steps;
		}
	}
}