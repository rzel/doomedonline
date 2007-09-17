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
	
	public class SimpleThingAni4 extends AbstractThing {
		private var _img1:Image;
		private var _img2:Image;
		private var _img3:Image;
		private var _img4:Image;
		
		public function SimpleThingAni4(level:DeWadLevel,img1:Image,img2:Image,img3:Image,img4:Image,rad:uint,col:Boolean,x:int,y:int,hanging:Boolean,alwaysBright:Boolean) {
			super(level,rad,col,x,y,hanging,alwaysBright);
			_img1 = img1;
			_img2 = img2;
			_img3 = img3;
			_img4 = img4;
		}
		public override function getRelativeImage(dir:uint,time:uint):Image {
			return ((time & 0x10) === 0)? (((time & 0x08) === 0)? _img1 :_img2) :(((time & 0x08) === 0)? _img3 :_img4);
		}
	}
}