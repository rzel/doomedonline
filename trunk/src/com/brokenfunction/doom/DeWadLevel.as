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
	import flash.utils.ByteArray;
	
	public class DeWadLevel {
		private var _wad:DeWad;
		private var _timeService:TimeService;
		private var _mainNode:Node;
		private var _blockmap:Blockmap;
		private var _things:Array;
		private var _reject:Reject;
		private var _vertices:Array;
		private var _sectors:Array;
		private var _maxX:int = 0;
		private var _maxY:int = 0;
		private var _minX:int = 0;
		private var _minY:int = 0;
		
		public function DeWadLevel(wad:DeWad,data:ByteArray,levelLump:LumpGroup,timeService:TimeService,thingRequire:uint = 0) {
			trace("Loading map...")
			_wad = wad;
			_timeService = timeService;
			
			var lump:Lump;
			try {
				lump = levelLump.getLump("SECTORS");
				data.position = lump.offset;
				_sectors = processSectors(data,lump.size);
			} catch (e:Error) {
				throw new Error("Couldn't load sectors: "+e.message);
			}
			try {
				lump = levelLump.getLump("SIDEDEFS");
				data.position = lump.offset;
				var sidedefs:Array = processSidedefs(data,lump.size,_sectors);
			} catch (e:Error) {
				throw new Error("Couldn't load sidedefs: "+e.message);
			}
			try {
				lump = levelLump.getLump("VERTEXES");
				data.position = lump.offset;
				_vertices = processVerticies(data,lump.size);
			} catch (e:Error) {
				throw new Error("Couldn't load vertices: "+e.message);
			}
			try {
				lump = levelLump.getLump("LINEDEFS");
				data.position = lump.offset;
				var linedefs:Array = processLinedefs(data,lump.size,_vertices,sidedefs);
			} catch (e:Error) {
				throw new Error("Couldn't load linedefs: "+e.message);
			}
			try {
				lump = levelLump.getLump("SEGS");
				data.position = lump.offset;
				var segs:Array = processSegs(data,lump.size,_vertices,linedefs);
			} catch (e:Error) {
				throw new Error("Couldn't load segs: "+e.message);
			}
			try {
				lump = levelLump.getLump("SSECTORS");
				data.position = lump.offset;
				var ssectors:Array = processSSectors(data,lump.size,segs);
			} catch (e:Error) {
				throw new Error("Couldn't load ssectors: "+e.message);
			}
			try {
				lump = levelLump.getLump("NODES");
				data.position = lump.offset;
				_mainNode = processNodes(data,lump.size,ssectors);
			} catch (e:Error) {
				throw new Error("Couldn't load nodes: "+e.message);
			}
			try {
				lump = levelLump.getLump("BLOCKMAP");
				data.position = lump.offset;
				_blockmap = processBlockmap(data,lump.size,linedefs);
			} catch (e:Error) {
				throw new Error("Couldn't load blockmap: "+e.message);
			}
			try {
				lump = levelLump.getLump("THINGS");
				data.position = lump.offset;
				_things = processThings(data,lump.size,thingRequire);
			} catch (e:Error) {
				throw new Error("Couldn't load things: "+e.message);
			}
			try {
				lump = levelLump.getLump("REJECT");
				data.position = lump.offset;
				_reject = processReject(data,lump.size,_sectors);
			} catch (e:Error) {
				throw new Error("Couldn't load reject: "+e.message);
			}
			trace("Loaded");
		}
		private function processVerticies(data:ByteArray,max:uint):Array {
			var out:Array = [];
			var x:int, y:int;
			
			while (max >= 4) {
				x = data.readShort();
				y = data.readShort();
				
				if (x > _maxX) _maxX = x;
				else if (x < _minX) _minX = x;
				if (y > _maxY) _maxY = y;
				else if (y < _minY) _minY = y;
				
				out.push(new Vertex(x,y));
				max -= 4;
			}
			
			trace("\tVerticies: "+out.length+((max)? " (residue "+max+")" :""));
			return out;
		}
		private function processLinedefs(data:ByteArray,max:uint,vertices:Array,sidedefs:Array):Array {
			var out:Array = [];
			var from:uint, to:uint;
			var flags:uint, type:uint;
			var rightSide:uint, leftSide:uint;
			var rightSide2:Sidedef, leftSide2:Sidedef;
			var tag:uint;
			var linedef:Linedef;
			
			while (max >= 14) {
				from = data.readUnsignedShort() & 0x7fff;
				to = data.readUnsignedShort() & 0x7fff;
				flags = data.readUnsignedShort();
				type = data.readUnsignedShort();
				tag = data.readUnsignedShort();
				rightSide = data.readUnsignedShort();
				leftSide = data.readUnsignedShort();
				
				if (rightSide !== 0xffff) {
					if (!(rightSide in sidedefs)) throw new Error("Invalid \"right\" sidedef ("+rightSide+")");
					rightSide2 = sidedefs[rightSide] as Sidedef;
				} else {
					throw new Error("Missing right sidedef");
				}
				if ((flags & Linedef.TWO_SIDED) === Linedef.TWO_SIDED) {
					if (leftSide === 0xffff) throw new Error("Two-sided linedef is missing left side");
					if (!(leftSide in sidedefs)) throw new Error("Invalid \"left\" sidedef ("+leftSide+")");
					leftSide2 = sidedefs[leftSide] as Sidedef;
				} else {
					if (leftSide !== 0xffff) throw new Error("One-sided linedef has a left side (egads!)");
					leftSide2 = null;
				}
				if (!(from in vertices)) throw new Error("Invalid \"from\" vertex ("+from+")");
				if (!(to in vertices)) throw new Error("Invalid \"to\" vertex ("+to+")");
				
				out.push(linedef = new Linedef(
					vertices[from] as Vertex,
					vertices[to] as Vertex,
					flags,
					type,
					rightSide2,
					leftSide2
				));
				if (rightSide2) rightSide2.sector.linedefs.push(linedef);
				if (leftSide2) leftSide2.sector.linedefs.push(linedef);
				
				max -= 14;
			}
			
			trace("\tLinedefs: "+out.length+((max)? " (residue "+max+")" :""));
			return out;
		}
		private function processSidedefs(data:ByteArray,max:uint,sectors:Array):Array {
			var out:Array = [], lpos:uint;
			var offX:int, offY:int;
			var upperTexture:String, lowerTexture:String, middleTexture:String;
			var upperTexture2:Texture, lowerTexture2:Texture, middleTexture2:Texture;
			var sector:uint;
			
			while (max >= 30) {
				offX = data.readShort();
				offY = data.readShort();
				upperTexture = readStr8(data);
				lowerTexture = readStr8(data);
				middleTexture = readStr8(data);
				sector = data.readUnsignedShort();
				
				if (!(sector in sectors)) throw new Error("Invalid sector ("+sector+")");
				
				lpos = data.position;
				upperTexture2 = (upperTexture == "-")? null :_wad.getTexture(upperTexture);
				lowerTexture2 = (lowerTexture == "-")? null :_wad.getTexture(lowerTexture);
				middleTexture2 = (middleTexture == "-")? null :_wad.getTexture(middleTexture);
				data.position = lpos;
				
				out.push(new Sidedef(
					offX,
					offY,
					upperTexture2,
					lowerTexture2,
					middleTexture2,
					sectors[sector] as Sector
				));
				max -= 30;
			}
			
			trace("\tSidedefs: "+out.length+((max)? " (residue "+max+")" :""));
			return out;
		}
		private function processSectors(data:ByteArray,max:uint):Array {
			var out:Array = [], lpos:uint;
			var floor:int, ceil:int;
			var floorFlat:String, ceilFlat:String;
			var floorFlat2:Flat, ceilFlat2:Flat;
			var lightLevel:uint;
			var type:uint;
			var tag:uint;
			
			while (max >= 26) {
				floor = data.readShort();
				ceil = data.readShort();
				floorFlat = readStr8(data);
				ceilFlat = readStr8(data);
				lightLevel = data.readUnsignedShort();
				type = data.readUnsignedShort();
				tag = data.readUnsignedShort();
				
				//if (floorFlat == "F_SKY1") throw new Error("No support for floors as F_SKY1 flats");
				
				lpos = data.position;
				floorFlat2 = (floorFlat == "F_SKY1")? Flat.SKY_FLAT :_wad.getFlat(floorFlat);
				ceilFlat2 = (ceilFlat == "F_SKY1")? Flat.SKY_FLAT :_wad.getFlat(ceilFlat);
				data.position = lpos;
				
				out.push(new Sector(
					floor,
					ceil,
					floorFlat2,
					ceilFlat2,
					lightLevel,
					type
				));
				max -= 26;
			}
			
			trace("\tSectors: "+out.length+((max)? " (residue "+max+")" :""));
			return out;
		}
		private function processNodes(data:ByteArray,max:uint,ssectors:Array):Node {
			var offset:uint = data.position;
			var nodes:Array = [];
			var x:int, y:int;
			var dx:int, dy:int;
			var angle:uint;
			var leftY1:int, leftY2:int, leftX1:int, leftX2:int;
			var rightY1:int, rightY2:int, rightX1:int, rightX2:int;
			
			while (max >= 28) {
				x = data.readShort();
				y = data.readShort();
				dx = data.readShort();
				dy = data.readShort();
				angle = (Math.atan2(dy,dx)*(0x8000/Math.PI)) & 0xffff;
				leftY1 = data.readShort();
				leftY2 = data.readShort();
				leftX1 = data.readShort();
				leftX2 = data.readShort();
				rightY1 = data.readShort();
				rightY2 = data.readShort();
				rightX1 = data.readShort();
				rightX2 = data.readShort();
				data.position += 4;// Skip left and right sub-nodes
				
				nodes.push(new Node(
					x,y,
					dx,dy,
					angle,
					leftY1,leftY2,leftX1,leftX2,
					rightY1,rightY2,rightX1,rightX2
				));
				max -= 28;
			}
			
			var i:uint = 0, subnode:uint;
			var node:Node;
			
			while (node = nodes[i]) {
				data.position = (i++)*28+offset+24;
				
				subnode = data.readUnsignedShort();
				if ((subnode & 0x8000) === 0x8000) {
					if (!(node.rightSSector = ssectors[subnode & 0x7fff] as SSector)) {
						throw new Error("Invalid right ssector ("+(subnode & 0x7fff)+")");
					}
				} else if (!(node.rightNode = nodes[subnode] as Node)) {
					throw new Error("Invalid right node ("+subnode+")");
				}
				
				subnode = data.readUnsignedShort();
				if ((subnode & 0x8000) === 0x8000) {
					if (!(node.leftSSector = ssectors[subnode & 0x7fff] as SSector)) {
						throw new Error("Invalid left ssector ("+(subnode & 0x7fff)+")");
					}
				} else if (!(node.leftNode = nodes[subnode] as Node)) {
					throw new Error("Invalid left node ("+subnode+")");
				}
			}
			
			if (nodes.length <= 0) throw new Error("There must be more than one node");
			
			trace("\tNodes: "+nodes.length+((max)? " (residue "+max+")" :""));
			return nodes[nodes.length-1] as Node;// The "last" node is the root node
		}
		private function processSSectors(data:ByteArray,max:uint,segs:Array):Array {
			var out:Array = [], rstart:uint;
			var ssector:SSector;
			var start:uint = 0, len:uint = 0, i:int;
			while (max >= 4) {
				len = data.readUnsignedShort();
				start = data.readUnsignedShort();
				
				if (start !== rstart) throw new Error("Segs not in proper order ("+start+" != "+rstart+")");
				if (start+len > segs.length) throw new Error("SSector accesses invalid segs ("+segs.length+" < "+start+"+"+len+")");
				
				out.push(ssector = new SSector(len));
				
				i = len;
				while (i-- > 0) ssector[i] = segs[start+i];
				
				rstart += len;
				max -= 4;
			}
			
			trace("\tSSectors: "+out.length+((max)? " (residue "+max+")" :""));
			return out;
		}
		private function processSegs(data:ByteArray,max:uint,vertices:Array,linedefs:Array):Array {
			var out:Array = [];
			var from:uint, to:uint;
			var angle:uint;
			var linedef:uint;
			var reverseDir:uint;
			var linedefOffset:int;
			
			while (max >= 12) {
				from = data.readUnsignedShort();
				to = data.readUnsignedShort();
				angle = data.readUnsignedShort();
				linedef = data.readUnsignedShort();
				reverseDir = data.readUnsignedShort();
				linedefOffset = data.readUnsignedShort();
				
				if (!(from in vertices)) throw new Error("Invalid \"from\" vertex ("+from+")");
				if (!(to in vertices)) throw new Error("Invalid \"to\" vertex ("+to+")");
				if (!(linedef in linedefs)) throw new Error("Invalid linedef ("+linedef+")");
				if ((reverseDir & ~0x1) !== 0x0) throw new Error("reverseDir isn't specific ("+reverseDir+")");
				
				out.push(new Seg(
					vertices[from] as Vertex,
					vertices[to] as Vertex,
					angle,
					linedefs[linedef] as Linedef,
					(reverseDir & 0x1) === 0x1,
					linedefOffset
				));
				max -= 12;
			}
			
			trace("\tSegs: "+out.length+((max)? " (residue "+max+")" :""));
			return out;
		}
		private function processBlockmap(data:ByteArray,max:uint,linedefs:Array):Blockmap {
			var offset:uint = data.position;
			
			var offX:int = data.readShort();
			var offY:int = data.readShort();
			var columns:uint = data.readUnsignedShort();
			var rows:uint = data.readUnsignedShort();
			var entries:uint = columns*rows;
			var blockmap:Blockmap = new Blockmap(offX,offY,columns,rows);
			
			var i:uint = 0;
			var linedef:uint;
			var blocklist:Array;
			while (i < entries) {
				data.position = offset+8+(i << 1);
				data.position = offset+(data.readUnsignedShort() << 1);
				if (data.readUnsignedShort() !== 0x0000) throw new Error("Blocklist "+i+"/"+(entries-1)+" does not start with 0x0000");
				blocklist = [];
				
				while ((linedef = data.readUnsignedShort()) !== 0xffff) {
					if (!(linedef in linedefs)) throw new Error("Invalid linedef ("+linedef+")");
					blocklist.push(linedefs[linedef] as Linedef);
				}
				
				blockmap.setBlock(i % columns,i / columns,blocklist);
				i++;
			}
			
			trace("\tBlockmap: "+columns+"x"+rows);
			return blockmap;
		}
		private function processThings(data:ByteArray,max:uint,require:uint = 0):Array {
			var offset:uint = data.position;
			var out:Array = [], total:uint = 0;
			var x:int;
			var y:int;
			var ang:uint;
			var type:uint;
			var options:uint
			while (max >= 10) {
				x = data.readShort();
				y = data.readShort();
				ang = ((data.readUnsignedShort()*0x8000)/180) & 0xffff;
				type = data.readUnsignedShort();
				options = data.readUnsignedShort();
				
				if ((options & require) === require) out.push(new ThingInfo(x,y,ang,type,options));
				total++;
				max -= 10;
			}
			
			trace("\tThings: "+out.length+"/"+total+((max)? " (residue "+max+")" :""));
			return out;
		}
		private function processReject(data:ByteArray,max:uint,sectors:Array):Reject {
			var offset:uint = data.position;
			var reject:Reject = new Reject();
			var cols:uint = sectors.length;
			var bmax:uint = cols*cols;
			var trueMax:uint = (bmax >>> 3)+(((bmax & 0x7) !== 0)? 1 :0);
			if (max < trueMax) bmax = (max << 3);

			var pos:uint = 0, t:uint;
			while (bmax >= 8) {
				t = data.readUnsignedByte();
				if ((t & 0x80) === 0x80) processReject2(reject,sectors,pos);
				if ((t & 0x40) === 0x40) processReject2(reject,sectors,pos+1);
				if ((t & 0x20) === 0x20) processReject2(reject,sectors,pos+2);
				if ((t & 0x10) === 0x10) processReject2(reject,sectors,pos+3);
				if ((t & 0x08) === 0x08) processReject2(reject,sectors,pos+4);
				if ((t & 0x04) === 0x04) processReject2(reject,sectors,pos+5);
				if ((t & 0x02) === 0x02) processReject2(reject,sectors,pos+6);
				if ((t & 0x01) === 0x01) processReject2(reject,sectors,pos+7);
				pos += 8;
				bmax -= 8;
			}
			if (bmax >= 1) {
				t = data.readUnsignedByte();
				if ((t & 0x80) === 0x80) processReject2(reject,sectors,pos);
				pos++;
				if (--bmax >= 1) {
					if ((t & 0x40) === 0x40) processReject2(reject,sectors,pos);
					pos++;
					if (--bmax >= 1) {
						if ((t & 0x20) === 0x20) processReject2(reject,sectors,pos);
						pos++;
						if (--bmax >= 1) {
							if ((t & 0x10) === 0x10) processReject2(reject,sectors,pos);
							pos++;
							if (--bmax >= 1) {
								if ((t & 0x08) === 0x08) processReject2(reject,sectors,pos);
								pos++;
								if (--bmax >= 1) {
									if ((t & 0x04) === 0x04) processReject2(reject,sectors,pos);
									pos++;
									if (--bmax >= 1) {
										if ((t & 0x02) === 0x02) processReject2(reject,sectors,pos);
										pos++;
										if (--bmax >= 1) {
											if ((t & 0x01) === 0x01) processReject2(reject,sectors,pos);
											pos++;
										}
									}
								}
							}
						}
					}
				}
			}
			
			trace("\tReject: "+pos+" pairs "+((max < trueMax)? " ("+(trueMax-max)+" bytes missing)" :(max > trueMax)? " (residue "+(max-trueMax)+")" :""));
			return reject;
		}
		private function processReject2(reject:Reject,sectors:Array,pos:uint):void {
			var cols:uint = sectors.length;
			var a:uint = pos % cols;
			var b:uint = pos / cols;
			if (!(a in sectors)) throw new Error("Invalid column sector ("+a+"/"+cols+")");
			if (!(b in sectors)) throw new Error("Invalid row sector ("+b+"/"+cols+")");
			reject.setReject(sectors[a] as Sector,sectors[b] as Sector);
		}

		public function get wad():DeWad {return _wad;}
		public function get timeService():TimeService {return _timeService;}
		public function get mainNode():Node {return _mainNode;}
		public function get blockmap():Blockmap {return _blockmap;}
		public function get things():Array {return _things.concat();}
		public function get reject():Reject {return _reject;}
		public function get sectors():Array {return _sectors.concat();}
		public function get vertices():Array {return _vertices.concat();}

		public function get minX():int {return _minX;}
		public function get maxX():int {return _maxX;}
		public function get minY():int {return _minY;}
		public function get maxY():int {return _maxY;}
		
		static private function getAlternateTextures():Object {
			var out:Object = {};
			// doom 1 shareware
			out["SW1BRCOM"] = "SW2BRCOM";
			out["SW1BRN1"] = "SW2BRN1";
			out["SW1BRN2"] = "SW2BRN2";
			out["SW1BRNGN"] = "SW2BRNGN";
			out["SW1BROWN"] = "SW2BROWN";
			out["SW1COMM"] = "SW2COMM";
			out["SW1COMP"] = "SW2COMP";
			out["SW1DIRT"] = "SW2DIRT";
			out["SW1EXIT"] = "SW2EXIT";
			out["SW1GRAY"] = "SW2GRAY";
			out["SW1GRAY1"] = "SW2GRAY1";
			out["SW1METAL"] = "SW2METAL";
			out["SW1PIPE"] = "SW2PIPE";
			out["SW1SLAD"] = "SW2SLAD";
			out["SW1STARG"] = "SW2STARG";
			out["SW1STON1"] = "SW2STON1";
			out["SW1STON2"] = "SW2STON2";
			out["SW1STONE"] = "SW2STONE";
			out["SW1STRTN"] = "SW2STRTN";
			// doom 1 registered
			out["SW1BLUE"] = "SW2BLUE";
			out["SW1CMT"] = "SW2CMT";
			out["SW1GARG"] = "SW2GARG";
			out["SW1GSTON"] = "SW2GSTON";
			out["SW1HOT"] = "SW2HOT";
			out["SW1LION"] = "SW2LION";
			out["SW1SATYR"] = "SW2SATYR";
			out["SW1SKIN"] = "SW2SKIN";
			out["SW1VINE"] = "SW2VINE";
			out["SW1WOOD"] = "SW2WOOD";
			// doom 2
			out["SW1PANEL"] = "SW2PANEL";
			out["SW1ROCK"] = "SW2ROCK";
			out["SW1MET2"] = "SW2MET2";
			out["SW1WDMET"] = "SW2WDMET";
			out["SW1BRIK"] = "SW2BRIK";
			out["SW1MOD1"] = "SW2MOD1";
			out["SW1ZIM"] = "SW2ZIM";
			out["SW1STON6"] = "SW2STON6";
			out["SW1TEK"] = "SW2TEK";
			out["SW1MARB"] = "SW2MARB";
			out["SW1SKULL"] = "SW2SKULL";
			return out;
		}
	}
}