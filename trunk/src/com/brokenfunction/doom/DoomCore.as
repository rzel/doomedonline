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
	import com.brokenfunction.ezlo.time.*;
	import com.brokenfunction.util.AudioSynth;
	import com.brokenfunction.util.Counter;
	import com.brokenfunction.util.KeyInput;
	import com.brokenfunction.util.Fps;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	import flash.ui.Keyboard;
	
	public class DoomCore {
		private var wad:DeWad;
		private var rend:DoomRender;
		private var timeService:LazyTimeService;
		private var counter:Counter;
		private var debug:Shape;
		
		private var player:MovingThing;
		private var input:KeyInput;
		private var playerControl:Player;
		
		private var fps:Fps;
		
		public function DoomCore(container:Sprite,bin:ByteArray) {
			// start
			fps = new Fps();
			timeService = new LazyTimeService();
			input = new KeyInput(container.stage);
			input.setKey(Player.KEY_FORWARD,Keyboard.UP);
			input.setKey(Player.KEY_FORWARD,87);// w
			input.setKey(Player.KEY_RIGHT,Keyboard.RIGHT);
			input.setKey(Player.KEY_RIGHT,68);// d
			input.setKey(Player.KEY_BACKWARD,Keyboard.DOWN);
			input.setKey(Player.KEY_BACKWARD,83);// s
			input.setKey(Player.KEY_LEFT,Keyboard.LEFT);
			input.setKey(Player.KEY_LEFT,65);// a
			input.setKey(Player.KEY_STRAFE,Keyboard.CONTROL);
			input.setKey(Player.KEY_SPEED,Keyboard.SHIFT);
			input.setKey(Player.KEY_FIRE,Keyboard.SPACE);
			input.setKey(Player.KEY_USE,Keyboard.ENTER);
			input.setKey(Player.KEY_USE,69);// e
			
			// create renderer
			debug = new Shape();
			rend = new DoomRender();
			rend.x = rend.y = 100;
			//rend.debugGraphics = debug.graphics;
			container.addChild(rend.displayObject);
			debug.x = rend.x+rend.width/2;
			debug.y = rend.y+rend.height/2;
			container.addChild(debug);
			//container.addChild(fps);
			
			// process wad
			wad = new DeWad("root",bin);
			var level:DeWadLevel = wad.createLevel("E1M1",timeService,ThingInfo.OPTION_SKILLNORMAL);
			var thingProcessor:ThingProcessor = new ThingProcessor(level);
			var levelProcessor:LevelProcessor = new LevelProcessor(level);
			var playerInfo:ThingInfo = thingProcessor.player1Start;
			rend.setMap(level,wad.getTexture("SKY1"));
			player = new MovingThing(level,56,40);
			//player.debugGraphics = debug.graphics;
			if (playerInfo) {
				player.x = playerInfo.x;
				player.y = playerInfo.y;
				player.rot = playerInfo.ang;
			}
			playerControl = new Player(player,input,timeService);
			
			// finish up
			wad.clearCaches();
			counter = new Counter(35*3,35,onTick);
			onTick(0);
		}
		private function onTick(ms:uint):void {
			debug.graphics.clear();
			timeService.update(ms);
			
			rend.x = player.x;
			rend.y = player.y;
			rend.z = player.eyeZ;
			rend.rot = player.rot;
			var timeToRender:uint = rend.render(timeService.getTime(35));
			
			fps.setScriptTime(timeToRender);
		}
	}
}