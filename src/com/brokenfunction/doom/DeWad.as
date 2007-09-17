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
	import com.brokenfunction.util.AudioSynth;
	import flash.geom.ColorTransform;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	
	public class DeWad extends LumpGroup {
		static private const MAP_START:RegExp = /^(E[0-9]M[0-9]|MAP[0-9]{2})$/;
		static private const MAP_CONTINUE:RegExp = /^(THINGS|LINEDEFS|SIDEDEFS|VERTEXES|SEGS|SSECTORS|NODES|SECTORS|REJECT|BLOCKMAP)$/;
		static private const BLANK_IGNORE:RegExp = /^(P(|1|2|3)|S|F(|1|2|3))_(START|END)$/;
		static private const LUMP_SEQUENCE_LIST:Object = genLumpSequenceList();
		static private const TEXTURE_SEQUENCE_LIST:Object = genTextureSequenceList();
		
		private var data:ByteArray;
		private var levels:Object = {};
		
		private var imageCache:Object = {};
		private var flatCache:Object = {};
		private var soundCache:Object = {};
		private var playpalCache:Object = {};
		private var colormapCache:Object = {};
		private var textureCache:Object = {};
		private var textureInfoCache:Object;

		private var _wadType:String = "";
		private var _lumps:uint = 0;
		private var _dirpos:uint = 0;
		
		public function DeWad(name:String,d:ByteArray) {
			super(name);
			data = d;
			processWad();
		}
		
		// ___________________________________________________________________________________
		//                                                               WAD DIRECTORY PARSING
		private function processWad():void {
			trace("Processing WAD ("+data.length+" bytes)");
			try {
				data.position = 0;
				data.endian = Endian.LITTLE_ENDIAN;
				// readMultiByte is broken?
				var str1:uint = data.readUnsignedByte();
				var str2:uint = data.readUnsignedByte();
				var str3:uint = data.readUnsignedByte();
				var str4:uint = data.readUnsignedByte();
				_wadType = String.fromCharCode(str1,str2,str3,str4);
				if (_wadType == "IWAD") {
					trace("WAD type: IWAD");
					_lumps = data.readUnsignedInt();
					trace("Lumps: "+_lumps);
					_dirpos = data.readUnsignedInt();
					data.position = _dirpos;
					processDirectory();
				} else if (_wadType == "PWAD") {
					trace("WAD type: PWAD");
					throw new Error("Sorry, not compatible with PWADs (Patch WADs)");
				} else {
					throw new Error("Unknown WAD type (if it is a WAD)");
				}
			} catch (e:Error) {
				throw new Error("Could not load wad: "+e.message);
			}
		}
		private function processDirectory():void {
			var i:int = 0;
			var lump:Lump, group:LumpGroup;
			var isLevel:Boolean = false;
			var isSequence:Boolean = false;
			var sequenceFirst:Lump, endSequence:String;
			while (i++ < _lumps) {
				// sequences
				if (isSequence) {
					lump = (lump.next = new Lump(data));
					if (lump.name == endSequence) {
						lump.next = sequenceFirst;
						isSequence = false;
					}
				} else {
					lump = new Lump(data);
					if (lump.name in LUMP_SEQUENCE_LIST) {
						isSequence = true;
						sequenceFirst = lump;
						endSequence = LUMP_SEQUENCE_LIST[lump.name];
					}
				}
				
				// levels
				if (isLevel) {
					if (MAP_CONTINUE.exec(lump.name) != null) {
						group.addLump(lump);
						continue;
					} else {
						isLevel = false;
					}
				}
				if (MAP_START.exec(lump.name) != null) {// level indicator
					isLevel = true;
					group = new LumpGroup(lump.name);
					if (levels[group.name] is LumpGroup) {
						trace("Level \""+group.name+"\" already encountered, ignoring");
					} else {
						levels[lump.name] = group;
					}
					continue;
				}
				
				// empty lumps
				if (lump.size === 0 && BLANK_IGNORE.exec(lump.name) == null) {
					trace("Entry \""+lump.name+"\" has no size, ignoring");
					continue;
				}
				
				addLump(lump);
			}
			if (isSequence) {
				throw new Error("Sequence \""+sequenceFirst.name+"\" is missing end \""+endSequence+"\"");
			}
		}
		public function createLevel(name:String,timeService:TimeService,thingRequire:uint = 0):DeWadLevel {
			try {
				if (levels[name] is LumpGroup) {
					return new DeWadLevel(this,data,levels[name],timeService,thingRequire);
				} else {
					throw new Error("Level not found");
				}
			} catch (e:Error) {
				throw new Error("Could not load level \""+name+"\": "+e.message);
			}
			return null;
		}
		
		// ___________________________________________________________________________________
		//                                                                  WAD FORMAT PARSING
		private function createImage(lump:Lump):Image {
			var offset:uint = data.position = lump.offset;
			
			// header
			var width:uint = data.readUnsignedShort();
			var height:uint = data.readUnsignedShort();
			var offX:int = data.readShort();
			var offY:int = data.readShort();
			var image:Image = new Image(width,height,offX,offY);
			
			// columns
			var y:int, i:int, col:ByteArray;
			while (width-- > 0) {
				data.position = offset+8+width*4;
				data.position = offset+data.readUnsignedInt();
				while ((y = data.readUnsignedByte()) !== 0xff) {
					i = data.readUnsignedByte();
					data.position++;// unknown byte
					while (i-- > 0) {
						image.setPixel32(width,y++,0xff000000 | data.readUnsignedByte());
					}
					data.position++;// unknown byte
				}
			}
			return image;
		}
		private function createFlat(lump:Lump):Flat {
			data.position = lump.offset;
			return new Flat(data);
		}
		public function createSound(name:String):AudioSynth {// needs to be "lump:Lump"
			try {
				data.position = getLump(name).offset;
				data.position += 2;// Unknown entry
				var sampleRate:uint = data.readUnsignedShort();
				var samples:uint = data.readUnsignedShort();
				data.position += 2;// Unknown entry
				
				if (sampleRate !== 11025) throw new Error("Unknown sample rate");
				
				var synth:AudioSynth = new AudioSynth(
					AudioSynth.SAMPLE_RATE_11025,
					AudioSynth.CHANNELS_MONO,
					AudioSynth.DEPTH_8BIT
				);
				synth.writeBytes(data,data.position,samples);
				synth.close();
				return synth;
			} catch (e:Error) {
				throw new Error("Could not load audio \""+name+"\": "+e.message);
			}
			return null;
		}
		private function createPlayPalette(index:uint):PlayPalette {
			data.position = getLump("PLAYPAL").offset;
			return new PlayPalette(data,index);
		}
		private function createColormap(index:uint):Colormap {
			data.position = getLump("COLORMAP").offset;
			return new Colormap(data,index);
		}
		private function createPNames():Array {
			var out:Array = [];
			data.position = getLump("PNAMES").offset;
			var max:uint = data.readUnsignedInt();
			while (max-- > 0) {
				out.push(readStr8(data).toUpperCase());// force upper case
			}
			return out;
		}
		private function createTextureList(pnames:Array):Object {
			var out:Object = {};
			data.position = getLump("TEXTURE1").offset;
			createTextureList2(out,pnames);
			if (lumpExists("TEXTURE2")) {
				data.position = getLump("TEXTURE2").offset;
				createTextureList2(out,pnames);
			}
			return out;
		}
		private function createTextureList2(out:Object,pnames:Array):void {
			var offset:uint = data.position;
			var name:String;
			var width:uint
			var height:uint;
			var offX:int;
			var offY:int;
			var wall:uint;
			var textureInfo:TextureInfo;
			var isSequence:Boolean = false;
			var endSequence:String, sequenceFirst:TextureInfo;
			var i:uint = 0, j:uint = data.readUnsignedInt(), k:uint;
			while (i < j) {
				data.position = offset+4+i*4;
				data.position = offset+data.readUnsignedInt();
				
				name = readStr8(data);
				data.position += 4; // masking (???)
				width = data.readUnsignedShort();
				height = data.readUnsignedShort();
				data.position += 4; // column directory (obsolete)
				
				// sequences
				if (isSequence) {
					textureInfo.next = new TextureInfo(name,width,height);
					textureInfo = textureInfo.next;
					if (name == endSequence) {
						textureInfo.next = sequenceFirst;
						isSequence = false;
					}
				} else {
					textureInfo = new TextureInfo(name,width,height);
					if (name in TEXTURE_SEQUENCE_LIST) {
						endSequence = TEXTURE_SEQUENCE_LIST[name];
						isSequence = true;
						sequenceFirst = textureInfo;
					}
				}
				
				// patches
				k = data.readUnsignedShort();
				while (k-- > 0) {
					offX = data.readShort();
					offY = data.readShort();
					wall = data.readUnsignedShort();
					data.position += 4;// "stepdir" and "colormap" entries, skipped
					
					if (!(wall in pnames)) throw new Error("Invalid pname index ("+wall+")");
					
					textureInfo.patches.push(new TexturePatch(
						offX,
						offY,
						pnames[wall] as String
					));
				}
				
				if (name in out) {
					trace("TextureInfo \""+name+"\" already encountered, ignoring");
				} else {
					out[name] = textureInfo;
				}
				i++;
			}
			if (isSequence) {
				throw new Error("Texture sequence \""+sequenceFirst.name+"\" is missing end \""+endSequence+"\"");
			}
		}
		private function createTexture(info:TextureInfo):Texture {
			var texture:Texture = new Texture(info.width,info.height);
			var patches:Array = info.patches;
			var patch:TexturePatch;
			var i:int = 0;
			while (i < patches.length) {
				patch = patches[i] as TexturePatch;
				texture.copyImage(
					getImage(patch.wall),
					patch.offX,
					patch.offY
				);
				i++;
			}
			return texture;
		}
		
		// ___________________________________________________________________________________
		//                                                                  DATA TYPE CREATORS
		public function getImage(name:String):Image {
			try {
				return imageCache[name] || (imageCache[name] = createImage(getLump(name)));
			} catch (e:Error) {
				throw new Error("Could not load image \""+name+"\": "+e.message);
			}
			return null;
		}
		public function getFlat(name:String):Flat {
			try {
				if (name in flatCache) {
					return flatCache[name];
				} else {
					var lump:Lump = getLump(name)
					var flat:Flat = flatCache[name] = createFlat(lump);
					if (lump.next) flat.next = getFlat(lump.next.name);// too recursive?
					return flat;
				}
			} catch (e:Error) {
				throw new Error("Could not load flat \""+name+"\": "+e.message);
			}
			return null;
		}
		public function getPlayPalette(index:uint = 0):PlayPalette {
			try {
				return playpalCache[index] || (playpalCache[index] = createPlayPalette(index));
			} catch (e:Error) {
				throw new Error("Could not load play palette: "+e.message);
			}
			return null;
		}
		public function getColormap(index:uint = 0):Colormap {
			try {
				return colormapCache[index] || (colormapCache[index] = createColormap(index));
			} catch (e:Error) {
				throw new Error("Could not load colormap: "+e.message);
			}
			return null;
		}
		public function getTexture(name:String):Texture {
			name = name.toUpperCase();// force uppercase
			try {
				if (name in textureCache) {
					return textureCache[name];
				} else {
					var info:TextureInfo = getTextureInfo(name);
					var texture:Texture = textureCache[name] = createTexture(info);
					if (info.next) texture.next = getTexture(info.next.name);// too recursive?
					return texture;
				}
			} catch (e:Error) {
				throw new Error("Could not load texture \""+name+"\": "+e.message);
			}
			return null;
		}
		public function getTextureInfo(name:String):TextureInfo {
			name = name.toUpperCase();// force uppercase
			try {
				if (!textureInfoCache) textureInfoCache = createTextureList(createPNames());
				if (name in textureInfoCache) {
					return textureInfoCache[name];
				} else {
					throw new Error("Not found");
				}
			} catch (e:Error) {
				throw new Error("Could not load texture info \""+name+"\": "+e.message);
			}
			return null;
		}
		public function clearCaches():void {
			imageCache = {};
			flatCache = {};
			playpalCache = {};
			colormapCache = [];
			textureCache = {};
			textureInfoCache = null;
		}
		
		// ___________________________________________________________________________________
		//                                                                          DOOM STUFF
		static private function genLumpSequenceList():Object {
			var out:Object = {};
			out["NUKAGE1"] = "NUKAGE3";// doom 1 shareware
			out["FWATER1"] = "FWATER4";// doom 1 registered
			out["SWATER1"] = "SWATER4";// nowhere (probably doom 1 registered)
			out["LAVA1"] = "LAVA4";// doom 1 registered
			out["BLOOD1"] = "BLOOD3";// doom 1 registered
			out["RROCK05"] = "RROCK08";// doom 2
			out["SLIME01"] = "SLIME04";// doom 2
			out["SLIME05"] = "SLIME08";// doom 2
			out["SLIME09"] = "SLIME12";// doom 2
			return out;
		}
		static private function genTextureSequenceList():Object {
			var out:Object = {};
			out["BLODGR1"] = "BLODGR4";// doom 1 registered
			out["BLODRIP1"] = "BLODRIP4";// doom 2 + doom 1 registered
			out["FIREBLU1"] = "FIREBLU2";// doom 2 + doom 1 registered
			out["FIRLAV3"] = "FIRELAVA";// doom 2 + doom 1 registered
			out["FIREMAG1"] = "FIREMAG3";// doom 2 + doom 1 registered
			out["FIREWALA"] = "FIREWALL";// doom 2 + doom 1 registered
			out["GSTFONT1"] = "GSTFONT3";// doom 2 + doom 1 registered
			out["ROCKRED1"] = "ROCKRED3";/// doom 2 + doom 1 registered
			out["SLADRIP1"] = "SLADRIP3";// doom 1 shareware/registered
			out["BFALL1"] = "BFALL4";// doom 2
			out["SFALL1"] = "SFALL4";// doom 2
			out["WFALL1"] = "WFALL4";// final doom
			out["DBRAIN1"] = "DBRAIN4";// doom 2
			return out;
		}
	}
}
