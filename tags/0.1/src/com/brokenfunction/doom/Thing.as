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
	import flash.display.Graphics;
	
	public class Thing {
		private var _x:int;
		private var _y:int;
		private var _movX:int = 0;
		private var _movY:int = 0;
		private var _debugGraphics:Graphics;
		
		public function Thing(x:int = 0,y:int = 0) {
			_x = x;
			_y = y;
		}

		public function get x():int {return _x;}
		public function get y():int {return _y;}
		public function get z():int {return 0;}
		public function get movX():int {return _movX;}
		public function get movY():int {return _movY;}
		public function get rot():uint {return 0;}
		public function get rad():uint {return 0;}
		public function get lightLevel():uint {return 0;}
		public function get debugGraphics():Graphics {return _debugGraphics;}
		
		public function set x(a:int):void {_x = a;}
		public function set y(b:int):void {_y = b;}
		public function set movX(x:int):void {_movX = x;}
		public function set movY(y:int):void {_movY = y;}
		public function set debugGraphics(g:Graphics):void {_debugGraphics = g;}
		
		public function getRelativeImage(dir:uint,time:uint):Image {
			throw new Error("No image available");
		}
		public function intersect(o:Thing):Boolean {
			return false;
		}
		
		protected function resolveSSector(node:Node):SSector {
			while (node) {
				if (node.dx*(node.y-_y) <= (node.x-_x)*node.dy) {
					if (node.leftStop) {
						return node.leftSSector;
					} else {
						node = node.leftNode;
					}
				} else {
					if (node.rightStop) {
						return node.rightSSector;
					} else {
						node = node.rightNode;
					}
				}
			}
			return null;
		}
		protected function clipMovement(blockmap:Blockmap,complex:int = 0):void {
			var ox:int = _x;
			var oy:int = _y;
			_x += _movX;
			_y += _movY;
			
			if (_debugGraphics && complex === 2) {
				_debugGraphics.lineStyle(0,0xffffff);
				_debugGraphics.drawCircle(0,0,16);
				_debugGraphics.moveTo(0,0);
				_debugGraphics.lineTo(_movX,-_movY);
				_debugGraphics.lineStyle(0,0xff00ff);
				_debugGraphics.drawCircle(_movX,-_movY,16);
			}
			
			if (!_movX && !_movY) return;
			
			// get movement boundries
			var sx:int, sy:int, ex:int, ey:int;
			if (_movX > 0) {
				sx = ox-16;
				ex = _movX+ox+16;
			} else {
				sx = _movX+ox-16;
				ex = ox+16;
			}
			if (_movY > 0) {
				sy = oy-16;
				ey = _movY+oy+16;
			} else {
				sy = _movY+oy-16;
				ey = oy+16;
			}
			sx = (sx-blockmap.offX) >> Blockmap.BLOCK_SHIFT;
			ex = (ex-blockmap.offX) >> Blockmap.BLOCK_SHIFT;
			sy = (sy-blockmap.offY) >> Blockmap.BLOCK_SHIFT;
			ey = (ey-blockmap.offY) >> Blockmap.BLOCK_SHIFT;
			if (sx < 0) sx = 0;
			if (ex >= blockmap.cols) ex = blockmap.cols-1;
			if (sy < 0) sy = 0;
			if (ey >= blockmap.rows) ey = blockmap.rows-1;
			
			var collide:Linedef = null;
			var cx:int;
			var cy:int;
			var angle:uint;
			var len:int;
			var sin:Number;
			var cos:Number;
			var x1:int;
			var y1:int;
			var dx:int;
			var dy:int;
			
			var tx:int;
			var ty:int;
			var td:int;
			var pos:Number;
			
			var nd:int = _movX*_movX+_movY*_movY;
			var na:int = (Math.atan2(_movY,_movX)*(0x8000/Math.PI)) & 0xffff;
			
			var linedef:Linedef;
			var linedefs:Array;
			
			var i:int, j:int;
			while (sx <= ex) {
				i = sy;
				while (i <= ey) {
					linedefs = blockmap.getBlock(sx,i);
					j = linedefs.length;
					while (j-- > 0) {
						linedef = linedefs[j];
						if (linedef.isImpassible) {
							if (_debugGraphics && complex === 2) drawLine(linedef,ox,oy,0x0000ff);
							
							// create adjusted linedef
							sin = Data.sintable[angle = linedef.angle];
							cos = Data.costable[angle];
							x1 = linedef.start.x-int(16*cos);
							y1 = linedef.start.y-int(16*sin);
							dx = (linedef.end.x+int(16*cos))-x1;
							dy = (linedef.end.y+int(16*sin))-y1;
							len = linedef.length+(16 << 1);
							
							if (dx*(y1-oy) >= (x1-ox)*dy) {// right side
								if (((na-angle-1) & 0xffff) >= 0x7fff) continue;
								
								angle = (angle - 0x4000) & 0xffff;
								x1 += int(16*Data.costable[angle]);
								y1 += int(16*Data.sintable[angle]);
								
								if ((pos = dy*_movX-dx*_movY) == 0) continue;
								pos = (_movY*(x1-ox)-(y1-oy)*_movX)/pos;
								if (pos <= 0 || pos >= 1) continue;
								tx = (x1+int(pos*dx))-ox;
								ty = (y1+int(pos*dy))-oy;
								
								if (_debugGraphics && complex === 2) {
									_debugGraphics.lineStyle(0,0x00ff00);
									_debugGraphics.moveTo(_movX,-_movY);
									_debugGraphics.lineTo(tx,-ty);
								}
								
								if (nd > (td = tx*tx+ty*ty)) {
									if (complex > 0) {
										collide = linedef;
										pos = (dy*(_y-y1)-(x1-_x)*dx);
										cx = x1+int((pos*cos)/len);
										cy = y1+int((pos*sin)/len);
									}
									
									_movX = tx;
									_movY = ty;
									nd = td;
								}
							}
						} else {
							if (_debugGraphics && complex === 2) drawLine(linedef,ox,oy,0xff0000);
						}
					}
					i++;
				}
				sx++;
			}
			if (collide) {
				_movX = cx-(_x = _movX+ox);
				_movY = cy-(_y = _movY+oy);
				clipMovement(blockmap,complex-1);
				_movX = _x-ox;
				_movY = _y-oy;
			} else {
				_x = _movX+ox;
				_y = _movY+oy;
			}
		}
		
		private function drawLine(linedef:Linedef,ox:int,oy:int,col:uint):void {
			_debugGraphics.lineStyle(0,col);
			_debugGraphics.moveTo((linedef.start.x-ox),-(linedef.start.y-oy));
			_debugGraphics.lineTo((linedef.end.x-ox),-(linedef.end.y-oy));
		}
	}
}