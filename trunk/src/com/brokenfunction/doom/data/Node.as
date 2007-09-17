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
package com.brokenfunction.doom.data {
	public class Node {
		private var _x:int;
		private var _y:int;
		private var _dx:int;
		private var _dy:int;
		private var _angle:uint;// BAM
		private var _ly1:int;
		private var _ly2:int;
		private var _lx1:int;
		private var _lx2:int;
		private var _ry1:int;
		private var _ry2:int;
		private var _rx1:int;
		private var _rx2:int;
		private var _leftStop:Boolean = true;
		private var _rightStop:Boolean = true;
		private var _left:Object = null;
		private var _right:Object = null;
	
		public function Node(x:int,y:int,dx:int,dy:int,angle:uint,leftY1:int,leftY2:int,leftX1:int,leftX2:int,rightY1:int,rightY2:int,rightX1:int,rightX2:int) {
			_x = x;
			_y = y;
			_dx = dx;
			_dy = dy;
			_angle = angle;
			_ly1 = leftY1;
			_ly2 = leftY2;
			_lx1 = leftX1;
			_lx2 = leftX2;
			_ry1 = rightY1;
			_ry2 = rightY2;
			_rx1 = rightX1;
			_rx2 = rightX2;
		}
		
		public function get x():int {return _x;}
		public function get y():int {return _y;}
		public function get dx():int {return _dx;}
		public function get dy():int {return _dy;}
		public function get angle():uint {return _angle;}
		public function get leftY1():int {return _ly1;}
		public function get leftY2():int {return _ly2;}
		public function get leftX1():int {return _lx1;}
		public function get leftX2():int {return _lx2;}
		public function get rightY1():int {return _ry1;}
		public function get rightY2():int {return _ry2;}
		public function get rightX1():int {return _rx1;}
		public function get rightX2():int {return _rx2;}
		
		/*public function set x(a:int):void {_x = a;}
		public function set y(b:int):void {_y = b;}
		public function set dx(x:int):void {_dx = x;}
		public function set dy(y:int):void {_dy = y;}
		public function set angle(a:uint):void {_angle = a;}
		public function set leftY1(y:int):void {_ly1 = y;}
		public function set leftY2(y:int):void {_ly2 = y;}
		public function set leftX1(x:int):void {_lx1 = x;}
		public function set leftX2(x:int):void {_lx2 = x;}
		public function set rightY1(y:int):void {_ry1 = y;}
		public function set rightY2(y:int):void {_ry2 = y;}
		public function set rightX1(x:int):void {_rx1 = x;}
		public function set rightX2(x:int):void {_rx2 = x;}*/

		public function get leftStop():Boolean {return _leftStop;}
		public function get rightStop():Boolean {return _rightStop;}
		
		public function get leftSSector():SSector {return _left as SSector;}
		public function get rightSSector():SSector {return _right as SSector;}
		public function get leftNode():Node {return _left as Node;}
		public function get rightNode():Node {return _right as Node;}
		
		public function set leftSSector(s:SSector):void {
			_leftStop = true;
			_left = s;
		}
		public function set rightSSector(s:SSector):void {
			_rightStop = true;
			_right = s;
		}
		public function set leftNode(n:Node):void {
			_leftStop = false;
			_left = n;
		}
		public function set rightNode(n:Node):void {
			_rightStop = false;
			_right = n;
		}
	}
}