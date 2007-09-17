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
	import com.brokenfunction.ezlo.*;
	import com.brokenfunction.util.Input;
	
	public class Player {
		static public const KEY_FORWARD:uint = (1 << 0);
		static public const KEY_BACKWARD:uint = (1 << 1);
		static public const KEY_LEFT:uint = (1 << 2);
		static public const KEY_RIGHT:uint = (1 << 3);
		static public const KEY_STRAFE:uint = (1 << 4);
		static public const KEY_FIRE:uint = (1 << 5);
		static public const KEY_SPEED:uint = (1 << 6);
		static public const KEY_USE:uint = (1 << 7);
		
		private var _input:Input;
		private var _thing:MovingThing;
		
		public function Player(thing:MovingThing,input:Input,timeService:TimeService) {
			_thing = thing;
			_input = input;
			timeService.addTimeListener(onTick,35);
		}
		private function onTick(e:TimeEvent):void {
			var k:uint = _input.getInput();
			var forward:int = 0;
			var side:int = 0;
			var angle:uint = 0;
			
			if ((k & KEY_STRAFE) === KEY_STRAFE) {
				if ((k & KEY_LEFT) === KEY_LEFT) {
					side -= ((k & KEY_SPEED) === KEY_SPEED)? 40 :24;
				}
				if ((k & KEY_RIGHT) === KEY_RIGHT) {
					side += ((k & KEY_SPEED) === KEY_SPEED)? 40 :24;
				}
			} else {
				if ((k & KEY_LEFT) === KEY_LEFT) {
					angle += ((k & KEY_SPEED) === KEY_SPEED)? 1280 :640;
				}
				if ((k & KEY_RIGHT) === KEY_RIGHT) {
					angle -= ((k & KEY_SPEED) === KEY_SPEED)? 1280 :640;
				}
			}
			if ((k & KEY_FORWARD) === KEY_FORWARD) {
				forward += ((k & KEY_SPEED) === KEY_SPEED)? 50 :25;
			}
			if ((k & KEY_BACKWARD) === KEY_BACKWARD) {
				forward -= ((k & KEY_SPEED) === KEY_SPEED)? 50 :25;
			}
			forward /= 8;
			side /= 8;
			
			_thing.move(forward,side,angle,e);
		}
	}
}