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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	import flash.utils.getTimer;
	/*
		TODO
		* Make minFieldOfView/maxFieldOfView change w/ rotation
		* Change the requirement for tan[] from 0xffff to 0x7fff
		* Change the e(a|b)y(1|2) to their proper (non-inverse) values
		* use atan rather than atan2, make lookup table for atan
		* Phase out findSSectors
		* Figure out what makes a middle texture stay unanimated
	*/
	public class DoomRender {
		static public const SKY_FLAT:Flat = Flat.SKY_FLAT;
		static private const EYE_DISTANCE:uint = 160;
		static private const BASE_WIDTH:uint = 320;
		static private const BASE_HEIGHT:uint = 200;
		static private const BLANK_INDEX:uint = 0xff001f;
		
		private var mainNode:Node;
		private var palette:PlayPalette;
		private var palettes:Array;
		private var cmaps:Array;
		private var sky:Image;
		private var staticThings:Array = [];
		private var maxFieldOfView:uint;// BAM
		private var minFieldOfView:uint;// BAM
		
		private var hrayAngleCache:Array;
		private var vrayCache:Array;
		private var cols:Array;
		private var thingCache:Dictionary;
		private var vertexCache:Dictionary;
		
		private var _bitmapData:BitmapData;
		private var _displayObject:Bitmap = new Bitmap();
		private var _debugGraphics:Graphics;
		private var _x:int = 0;
		private var _y:int = 0;
		private var _z:int = 0;
		private var _rot:uint = 0;// BAM
		private var _width:uint;
		private var _height:uint;
		private var _midX:int;
		private var _midY:int;
		/*
			((rotA-rotB) & 0xffff) >= 0x8000
			((rotA-rotB) & 0x8000) === 0x8000
			rotA >= rotB
			
			((rotA-rotB) & 0xffff) < 0x8000
			((rotA-rotB) & 0x8000) === 0x0000
			rotA < rotB
		*/
		public function DoomRender() {
			setSize(BASE_WIDTH,BASE_HEIGHT);
		}
		private function setSize(w:uint,h:uint):void {
			_width = w;
			_height = h;
			_midX = w/2;
			_midY = h/2;
			
			var i:int = _width;
			hrayAngleCache = new Array(i);
			cols = new Array(i);
			while (i-- > 0) {
				cols[i] = new ColumnStatus();
				hrayAngleCache[i] = (Math.atan2(_midX-i,EYE_DISTANCE)*(0x8000/Math.PI)) & 0xffff;
			}
			var vray:VRayStatus;
			i = _height;
			vrayCache = new Array(i);
			while (i-- > 0) {
				vray = vrayCache[i] = new VRayStatus();
				vray.raytan = (_midY-i)/EYE_DISTANCE;
			}
			
			minFieldOfView = (Math.atan2(_midX,EYE_DISTANCE)*(0x8000/Math.PI)) & 0xffff;
			maxFieldOfView = (Math.atan2(-_midX,EYE_DISTANCE)*(0x8000/Math.PI)) & 0xffff;
			
			_bitmapData = new BitmapData(_width,_height,false,0xffff00ff);
			_displayObject.bitmapData = _bitmapData;
		}
		public function setMap(level:DeWadLevel,skyData:Image):void {
			var wad:DeWad = level.wad;
			mainNode = level.mainNode;
			sky = skyData;
			palette = wad.getPlayPalette(0);
			thingCache = new Dictionary(true);
			vertexCache = new Dictionary(true);
			
			// Cache colormaps
			var i:int = 32;
			cmaps = new Array(i);
			while (i-- > 0) cmaps[i] = wad.getColormap(i);
			
			var vertices:Array = level.vertices;
			i = vertices.length;
			while (i-- > 0) {
				vertexCache[vertices[i]] = new VertexStatus();
			}
			
			/*// Gather segs
			var nodes:Array = [mainNode], segs:Array = [];
			var node:Node;
			while (node = nodes.pop() as Node) {
				if (node.rightStop) {
					segs.push.apply(segs,node.rightSSector);
				} else if (node.rightNode) {
					nodes.push(node.rightNode);
				}
				if (node.leftStop) {
					segs.push.apply(segs,node.leftSSector);
				} else if (node.leftNode) {
					nodes.push(node.leftNode);
				}
			}
			
			var seg:Seg;
			while (seg = segs.pop() as Seg) {
			}*/
		}
		private function findSSectors(ssectors:Array,node:Node):void {
			// This function is recursive, could lead to problems
			var ang:int = node.angle - _rot;
			if (node.dx*(node.y-_y) <= (node.x-_x)*node.dy) {// on right side?
				if (node.leftStop) ssectors.unshift(node.leftSSector);
				else findSSectors(ssectors,node.leftNode);
				if (((minFieldOfView-ang) & 0x8000) === 0x8000 || (((ang-0x8000)-maxFieldOfView) & 0x8000) === 0x8000) {
					if (node.rightStop) ssectors.unshift(node.rightSSector);
					else findSSectors(ssectors,node.rightNode);
				}
			} else {// on left side?
				if (node.rightStop) ssectors.unshift(node.rightSSector);
				else findSSectors(ssectors,node.rightNode);
				if (((ang-minFieldOfView) & 0x8000) === 0x8000 || ((maxFieldOfView-(ang-0x8000)) & 0x8000) === 0x8000) {
					if (node.leftStop) ssectors.unshift(node.leftSSector);
					else findSSectors(ssectors,node.leftNode);
				}
			}
		}
		public function render(time:uint):int {
			var i:int, j:int;
			var a:int, b:int, c:int;
			var m:Number, n:Number, p:Number, q:Number;
			var xmax:int;
			
			var cz:Number;
			var cr:uint;
			var cy1:int, cy2:int;
			var cx:int;
			var tx:int, ty:int;
			
			var ea1:uint, ea2:uint, eb1:uint;
			var ez1:Number;
			var ex1:int, ex2:int;
			var eay1:int, eay2:int;
			var eby1:int, eby2:int;
			var el:uint;
			
			var ssector:SSector;
			var things:Array = [];
			var seg:Seg;
			var thg:Thing;
			var thgc:ThingStatus;
			var linedef:Linedef;
			var aside:Sidedef;
			var bside:Sidedef;
			var sector:Sector;
			var col:ColumnStatus;
			var colmap:ByteArray;
			var vtx:Vertex;
			var vtxc:VertexStatus;
			
			var vy1:int, vy2:int;
			var vray:VRayStatus;
			
			var flatc:Flat;
			var flatf:Flat;
			var texu:Texture;
			var texm:Texture;
			var texl:Texture;
			var img:Image;

			var vertices:Dictionary = new Dictionary(true);
			var midX:int = _midX;
			var midY:int = _midY;
			var bmap:BitmapData = _bitmapData;
			var sin:Array = Data.sintable;
			var cos:Array = Data.costable;
			var tan:Array = Data.tantable;
			var rotSin:Number = sin[(-_rot) & 0xffff];
			var rotCos:Number = cos[_rot];
			
			if (_debugGraphics) {
				_debugGraphics.lineStyle(0,0xffffff);
				_debugGraphics.moveTo(0,0);
				_debugGraphics.lineTo(100*cos[(minFieldOfView+_rot) & 0xffff],-100*sin[(minFieldOfView+_rot) & 0xffff]);
				_debugGraphics.moveTo(0,0);
				_debugGraphics.lineTo(100*cos[(maxFieldOfView+_rot) & 0xffff],-100*sin[(maxFieldOfView+_rot) & 0xffff]);
			}
			
			bmap.lock();
			bmap.fillRect(bmap.rect,0xff000000 | BLANK_INDEX);
			var columns:int = _width;
			var ssectors:Array = [];
			findSSectors(ssectors,mainNode);
			i = _width;
			while (i-- > 0) {
				col = cols[i];
				col.min = 0;
				col.max = col.rows = _height;
			}
			var st:int = getTimer();
			
			i = ssectors.length;
			while (i-- > 0 && columns > 0) {
				ssector = ssectors[i];
				sector = ssector.sector;
				
				// gather things
				j = ssector.things.length;
				if (j-- > 0) {
					do {
						thg = ssector.things[j];
						thgc = thingCache[thg] || (thingCache[thg] = new ThingStatus(thg));
						thgc.dist = (rotCos*(thg.x-_x) - rotSin*(thg.y-_y))/EYE_DISTANCE;
						if (thgc.dist > 0) things.push(thgc)
					} while (j-- > 0);
					things.sortOn("dist",Array.NUMERIC | Array.DESCENDING);
					
					// draw things
					j = things.length;
					while (j-- > 0) {
						thgc = things.pop();
						// thing pre-processing
						thg = thgc.thing;
						cz = thgc.dist;
						b = Math.atan2(thg.y-_y,thg.x-_x)*(0x8000/Math.PI);
						img = thg.getRelativeImage(b & 0xffff,time);
						b = midX-int(tan[(b - _rot) & 0xffff]*EYE_DISTANCE);
						ex2 = (tx = ex1 = b-int(img.offX/cz))+int(img.width/cz)+1;
						if (ex2 < 0 || ex1 >= _width) {
							if (_debugGraphics) drawThing(thg,img.width,0x0000ff);
							continue;
						}
						eay2 = (ty = eay1 = midY-int((thg.z-_z+img.offY)/cz))+int(img.height/cz)+1;
						if (_debugGraphics) drawThing(thg,img.width,0xffaaaa);
						
						// draw thing
						if (ex1 < 0) ex1 = 0;
						if (ex2 > _width) ex2 = _width;
						if (eay1 < 0) eay1 = 0;
						if (eay2 > _height) eay2 = _height;
						if (ex1 < ex2 && eay1 < eay2) {
							a = thg.lightLevel;
							a = ((a = a/(1+(cz-1)*((255-a)/255))) > 255)? 0 :255-a;
							colmap = cmaps[a >>> 3];
							do {
								col = cols[ex1];
								if (col.rows <= 0) continue;
								if ((cy1 = eay1) < col.min) cy1 = col.min;
								if ((cy2 = eay2) > col.max) cy2 = col.max;
								c = (ex1-tx)*cz;
								do {
									if (bmap.getPixel(ex1,cy1) === BLANK_INDEX) {
										a = img.getPixel32(c,(cy1-ty)*cz);
										if (a !== 0) {
											bmap.setPixel(ex1,cy1,colmap[a & 0xff]);
											col.rows--;
										}
									}
								} while (++cy1 < cy2);
								if (col.rows <= 0) columns--;
							} while (++ex1 < ex2);
						}
					}
				}
				
				el = sector.lightLevel;
				
				j = ssector.length;
				while (j-- > 0) {
					// start seg pre-processing
					seg = ssector[j];
					linedef = seg.linedef;
					eb1 = (seg.angle-_rot) & 0xffff;
					if (eb1 > minFieldOfView && eb1 < (maxFieldOfView-0x8000)) continue;
					
					// update vertexes as needed
					vtx = seg.start;
					if (vtx in vertices) {
						vtxc = vertices[vtx];
						ea1 = vtxc.ang;
						ez1 = vtxc.dist;
						ex1 = vtxc.x;
					} else {
						vtxc = vertices[vtx] = vertexCache[vtx];
						ea1 = vtxc.ang = (int(Math.atan2(b = vtx.y-_y,a = vtx.x-_x)*(0x8000/Math.PI))-_rot) & 0xffff;
						ez1 = vtxc.dist = Math.sqrt(a*a+b*b);
						if (ea1 > 0xc000) vtxc.x = ex1 = midX-int(tan[ea1]*EYE_DISTANCE-1);
						else if (ea1 < 0x4000) vtxc.x = ex1 = midX-int(tan[ea1]*EYE_DISTANCE);
					}
					vtx = seg.end;
					if (vtx in vertices) {
						vtxc = vertices[vtx];
						ea2 = vtxc.ang;
						m = vtxc.dist;
						ex2 = vtxc.x;
					} else {
						vtxc = vertices[vtx] = vertexCache[vtx];
						ea2 = vtxc.ang = (int(Math.atan2(b = vtx.y-_y,a = vtx.x-_x)*(0x8000/Math.PI))-_rot) & 0xffff;
						m = vtxc.dist = Math.sqrt(a*a+b*b);
						if (ea2 > 0xc000) vtxc.x = ex2 = midX-int(tan[ea2]*EYE_DISTANCE-1);
						else if (ea2 < 0x4000) vtxc.x = ex2 = midX-int(tan[ea2]*EYE_DISTANCE);
					}
					if (((ea2-ea1) & 0x8000) === 0x0000) continue;
					if (ea1 >= 0x4000 && ea1 <= 0xc000) {
						if (ea2 >= 0x4000 && ea2 <= 0xc000) {
							if (_debugGraphics) drawSeg(seg,0xaa00ff);
							continue;
						}
						if (ex2 < 0) {
							if (_debugGraphics) drawSeg(seg,0x00aaff);
							continue;
						}
						ex1 = 0;
					} else if (ea2 >= 0x4000 && ea2 <= 0xc000) {
						if (ex1 >= _width) {
							if (_debugGraphics) drawSeg(seg,0x00aaff);
							continue;
						}
						ex2 = _width;
					} else if (ex2 < 0 || ex1 >= _width) {
						if (_debugGraphics) drawSeg(seg,0x0000ff);
						continue;
					}
					
					// finish pre-processing
					if (ez1 > m) m = ez1;
					eb1 = (eb1-0x8000-ea1) & 0xffff;
					linedef = seg.linedef;
					aside = seg.rightSide;
					flatc = sector.ceilFlat.current;
					flatf = sector.floorFlat.current;
					texu = aside.upperTexture;
					texm = aside.middleTexture;
					texl = aside.lowerTexture;
					if (texu) texu = texu.current;
					if (texm) texm = texm.current;
					if (texl) texl = texl.current;
					if (linedef.isTwoSided) {
						bside = seg.leftSide;
						if (flatc === SKY_FLAT && bside.sector.ceilFlat === SKY_FLAT) {
							// this is a HACK until proven otherwise
							// fixes walls in front of the sky
							eay1 = _z-sector.ceil;
							eby1 = _z-bside.sector.ceil;
							if (eay1 < eby1) eby1 = eay1;
							else eay1 = eby1;
						} else {
							eay1 = _z-sector.ceil;
							eby1 = _z-bside.sector.ceil;
							if (eby1 < eay1) eby1 = eay1;
						}
						eby2 = _z-bside.sector.floor;
						eay2 = _z-sector.floor;
						if (eby2 > eay2) eby2 = eay2;
					} else {
						bside = aside;
						eay1 = eby1 = _z-sector.ceil;
						eay2 = eby2 = _z-sector.floor;
					}
					if (_debugGraphics) drawSeg(seg,(linedef.isTwoSided)? 0xffcccc :0xffffff);
					vy1 = midY+int(eay1/m);
					vy2 = midY+int(eay2/m);
					if (vy1 < 0) vy1 = 0;
					else if (vy1 > midY) vy1 = midY;
					if (vy2 > _height) vy2 = _height;
					else if (vy2 < midY) vy2 = midY;
					
					// draw seg
					if (ex1 < 0) ex1 = 0;
					if (ex2 > _width) ex2 = _width;
					ex1--;
					while (++ex1 < ex2) {
						col = cols[ex1];
						if (col.rows <= 0) continue;
						cr = hrayAngleCache[ex1];
						
						m = sin[(eb1+(ea1-cr)) & 0xffff];
						cz = (ez1 * sin[eb1] * cos[cr]) / (EYE_DISTANCE * m);
						if (cz <= 0) continue;
						cx = (ez1 * sin[(ea1-cr) & 0xffff]) / m;
						cx += aside.offX + seg.linedefOffset;
						// draw ceiling
						cy1 = col.min;
						cy2 = midY+int(eay1/cz);
						if (cy2 > col.max) cy2 = col.max;
						if (cy1 < cy2) {
							if (flatc === SKY_FLAT) {
								a = (ex1-(_rot >>> 5)) & 0xff;
								colmap = cmaps[0];
								do {
									if (bmap.getPixel(ex1,cy1) === BLANK_INDEX) {
										bmap.setPixel(ex1,cy1,colmap[sky.getPixel(a,cy1 & 0x7f) & 0xff]);
										col.rows--;
									}
								} while (++cy1 < cy2);
							} else if (cy2 <= midY) {// Note: should be cy2 < midY
								a = (cr+_rot) & 0xffff;
								m = eay1/cos[cr];
								p = sin[a];
								q = cos[a];
								while (cy1 < vy1) {
									vray = vrayCache[--vy1];
									n = -eay1/(vray.raytan*EYE_DISTANCE);
									a = ((a = (el < 184)? el/(1+(n-1)*((184-el)/184)) :el) > 255)? 0 :255-a;
									vray.cmap = cmaps[a >>> 3];
								}
								do {
									if (bmap.getPixel(ex1,cy1) === BLANK_INDEX) {
										vray = vrayCache[cy1];
										n = m/vray.raytan;
										a = vray.cmap[flatc[(((n*p-_y) & 0x3f) << 6) | ((_x-n*q) & 0x3f)]];
										bmap.setPixel(ex1,cy1,a);
										col.rows--;
									}
								} while (++cy1 < cy2);
							} else {
								cy1 = cy2;
							}
						}
						col.min = cy1;
						a = ((a = (el < 184)? el/(1+(cz-1)*((184-el)/184)) :el) > 255)? 0 :255-a;
						colmap = cmaps[a >>> 3];
						// draw upper texture
						// HACK to fix drawing when eby1 < eby2
						cy2 = midY+int(((eby2 < eby1)? eby2 :eby1)/cz);
						if (cy2 > col.max) cy2 = col.max;
						if (col.min < cy2) col.min = cy2;
						if (cy1 < cy2) {
							if (texu) {
								ty = aside.offY-((linedef.unpeggedUpper)? eay1 :eby1);
								b = cx % texu.width;
								c = cy1-midY;
								do {
									if (bmap.getPixel(ex1,cy1) === BLANK_INDEX) {
										a = (c > 0)? ((c+1)*cz) :(c < 0)? (c*cz-1) :(c*cz);
										a = (ty+a) % texu.height;
										a = texu.getPixel32(b,(a < 0)? (a+texu.height) :a);
										if (a !== 0) {
											bmap.setPixel(ex1,cy1,colmap[a & 0xff]);
											col.rows--;
										}
									}
									c++;
								} while (++cy1 < cy2);
							} else {
								cy1 = cy2;
							}
						}
						// draw middle texture
						cy2 = midY+int(eby2/cz);
						if (cy2 > col.max) cy2 = col.max;
						if (cy1 < cy2) {
							if (texm) {
								ty = aside.offY-((linedef.unpeggedLower)? eby2 :eby1);
								b = cx % texm.width;
								c = cy1-midY;
								do {
									if (bmap.getPixel(ex1,cy1) === BLANK_INDEX) {
										a = (c > 0)? ((c+1)*cz) :(c < 0)? (c*cz-1) :(c*cz);
										a = (ty+a) % texm.height;
										a = texm.getPixel32(b,(a < 0)? (a+texm.height) :a);
										if (a !== 0) {
											bmap.setPixel(ex1,cy1,colmap[a & 0xff]);
											col.rows--;
										}
									}
									c++;
								} while (++cy1 < cy2);
							} else {
								cy1 = cy2;
							}
						}
						// draw lower texture
						cy2 = midY+int(eay2/cz);
						if (cy2 > col.max) cy2 = col.max;
						xmax = (col.max > cy1)? cy1 :col.max;
						if (cy1 < cy2) {
							if (texl) {
								ty = aside.offY-((linedef.unpeggedLower)? eay1 :eby2);
								b = cx % texl.width;
								c = cy1-midY;
								do {
									if (bmap.getPixel(ex1,cy1) === BLANK_INDEX) {
										a = (c > 0)? ((c+1)*cz) :(c < 0)? (c*cz-1) :(c*cz);
										a = (ty+a) % texl.height;
										a = texl.getPixel32(b,(a < 0)? (a+texl.height) :a);
										if (a !== 0) {
											bmap.setPixel(ex1,cy1,colmap[a & 0xff]);
											col.rows--;
										}
									}
									c++;
								} while (++cy1 < cy2);
							} else {
								cy1 = cy2;
							}
						}
						// draw floor
						cy2 = col.max;
						if (cy1 < cy2) {
							if (flatf === SKY_FLAT) {
								a = (ex1-(_rot >>> 5)) & 0xff;
								colmap = cmaps[0];
								do {
									if (bmap.getPixel(ex1,--cy2) === BLANK_INDEX) {
										bmap.setPixel(ex1,cy2,colmap[sky.getPixel(a,cy2 & 0x7f) & 0xff]);
										col.rows--;
									}
								} while (cy1 < cy2);
							} else if (cy1 >= midY) {
								a = (cr+_rot) & 0xffff;
								m = eay2/cos[cr];
								p = sin[a];
								q = cos[a];
								while (cy2 > vy2) {
									vray = vrayCache[vy2++];
									n = -eay2/(vray.raytan*EYE_DISTANCE);
									a = ((a = (el < 184)? el/(1+(n-1)*((184-el)/184)) :el) > 255)? 0 :255-a;
									vray.cmap = cmaps[a >>> 3];
								}
								do {
									if (bmap.getPixel(ex1,--cy2) === BLANK_INDEX) {
										vray = vrayCache[cy2];
										n = m/vray.raytan;
										a = vray.cmap[flatf[(((n*p-_y) & 0x3f) << 6) | ((_x-n*q) & 0x3f)]];
										bmap.setPixel(ex1,cy2,a);
										col.rows--;
									}
								} while (cy1 < cy2);
							}
						}
						col.max = (cy2 < xmax)? cy2 :xmax;
						if (col.rows <= 0) columns--;
					}
				}
			}
			if (columns > 0) {
				trace("missing rows");
			}
			palette.mapPalette(bmap);
			bmap.unlock();
			return getTimer()-st;
		}
		private function drawSeg(seg:Seg,col:uint):void {
			_debugGraphics.lineStyle(0,col);
			_debugGraphics.moveTo((seg.start.x-_x)/16,-(seg.start.y-_y)/16);
			_debugGraphics.lineTo((seg.end.x-_x)/16,-(seg.end.y-_y)/16);
		}
		private function drawThing(thing:Thing,size:int,col:uint):void {
			_debugGraphics.lineStyle(0,col);
			_debugGraphics.drawCircle((thing.x-_x)/16,-(thing.y-_y)/16,size/32);
		}
		
		public function get y():int {return _y;}
		public function get x():int {return _x;}
		public function get z():int {return _z;}
		public function get width():uint {return _width;}
		public function get height():uint {return _height;}
		public function get displayObject():DisplayObject {return _displayObject;}
		public function get debugGraphics():Graphics {return _debugGraphics;}
		
		public function set x(a:int):void {_x = a;}
		public function set y(b:int):void {_y = b;}
		public function set z(c:int):void {_z = c;}
		public function set debugGraphics(g:Graphics):void {_debugGraphics = g;}
		
		public function set rot(r:uint):void {
			_rot = r & 0xffff;
		}
		public function get rot():uint {
			return _rot;
		}
	}
}

import com.brokenfunction.doom.*;
import com.brokenfunction.doom.data.*;

class ThingStatus {
	public var dist:Number;
	public var thing:Thing;
	public function ThingStatus(t:Thing) {thing = t;}
}
class ColumnStatus {
	public var max:int;
	public var min:int;
	public var rows:int;
}
class VertexStatus {
	public var ang:uint;
	public var dist:Number;
	public var x:int;
}
class VRayStatus {
	public var raytan:Number;
	public var cmap:Colormap;
}