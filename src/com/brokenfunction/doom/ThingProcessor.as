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
	import com.brokenfunction.doom.things.*;
	
	public class ThingProcessor {
		private var _wad:DeWad;// TEMPORARY
		private var _player1Start:ThingInfo;
		private var _player2Start:ThingInfo;
		private var _player3Start:ThingInfo;
		private var _player4Start:ThingInfo;
		private var _deathmatchStart:Array = [];
		
		// Real stats
		private var _enemies:uint = 0;
		private var _items:uint = 0;
		
		// Fun stats
		private var _zombies:uint = 0;
		private var _bosses:uint = 0;
		private var _imps:uint = 0;
		private var _demons:uint = 0;
		private var _lostSouls:uint = 0;
		private var _cacodemons:uint = 0;
		private var _hellKnights:uint = 0;
		private var _painElementals:uint = 0;
		private var _revenants:uint = 0;
		private var _mancubi:uint = 0;
		private var _archViles:uint = 0;
		private var _ammo:uint = 0;
		private var _barrels:uint = 0;
		private var _unknown:uint = 0;
		
		public function ThingProcessor(level:DeWadLevel) {
			trace("Loading things...");
			_wad = level.wad;
			var things:Array = level.things, thing:ThingInfo;
			var i:int = things.length;
			while (i-- > 0) {
				if ((thing = things[i] as ThingInfo)) {
					genThing(level,thing,thing.x,thing.y);
				}
			}
			_wad = null;
			trace("\tEnemies: "+_enemies);
			trace("\tItems: "+_items);
			trace("\tZombies: "+_zombies);
			trace("\tImps: "+_imps);
			trace("\tDemons: "+_demons);
			trace("\tLost Souls: "+_lostSouls);
			trace("\tCacodemons: "+_cacodemons);
			trace("\tHell Knights: "+_hellKnights);
			trace("\tPain Elementals: "+_painElementals);
			trace("\tRevenants: "+_revenants);
			trace("\tMancubi: "+_mancubi);
			trace("\tArch Viles: "+_archViles);
			trace("\tBosses: "+_bosses);
			trace("\tBarrels: "+_barrels);
			trace("\tUnknown: "+_unknown);
			trace("Loaded");
		}
		
		public function get player1Start():ThingInfo {return _player1Start;}
		public function get player2Start():ThingInfo {return _player2Start;}
		public function get player3Start():ThingInfo {return _player3Start;}
		public function get player4Start():ThingInfo {return _player4Start;}
		
		private function img(s:String):Image {
			return _wad.getImage(s);
		}
		public function genThing(level:DeWadLevel,thing:ThingInfo,x:int,y:int):void {
			switch(thing.type) {
				case(0xffff):
				case(0x0000):// nothing
					break;
				// ___________________________________________________________________________________
				//                                                                   SPECIAL POSITIONS
				case(0x0001):// Player 1 start
					if (_player1Start) trace("Player 1 start already encountered, ignoring");
					else _player1Start = thing;
					break;
				case(0x0002):// Player 2 start
					if (_player2Start) trace("Player 2 start already encountered, ignoring");
					else _player2Start = thing;
					break;
				case(0x0003):// Player 3 start
					if (_player3Start) trace("Player 3 start already encountered, ignoring");
					else _player3Start = thing;
					break;
				case(0x0004):// Player 4 start
					if (_player4Start) trace("Player 4 start already encountered, ignoring");
					else _player4Start = thing;
					break;
				case(0x000b):// Deathmatch start
					_deathmatchStart.push(thing);
					break;
				case(0x000e):// Teleport landing
					break;
				// ___________________________________________________________________________________
				//                                                                             ENEMIES
				case(0x0bbc):// 0bbc   POSS +      # FORMER HUMAN: regular pistol-shooting zombieman
					new SimpleThing(level,img("POSSA1"),20,false,x,y,false,false);
					_enemies++;
					_zombies++;
					break;
				case(0x0054):// 0054 2 SSWV +      # WOLFENSTEIN SS: guest appearance by Wolf3D blue guy
					new SimpleThing(level,img("SSWVA1"),20,false,x,y,false,false);
					_enemies++;
					_zombies++;
					break;
				case(0x0009):// 0009   SPOS +      # FORMER HUMAN SERGEANT: black armor, shotgunners
					new SimpleThing(level,img("SPOSA1"),20,false,x,y,false,false);
					_enemies++;
					_zombies++;
					break;
				case(0x0041):// 0041 2 CPOS +      # HEAVY WEAPON DUDE: red armor, chaingunners
					new SimpleThing(level,img("CPOSA1"),20,false,x,y,false,false);
					_enemies++;
					_zombies++;
					break;
				case(0x0bb9):// 0bb9   TROO +      # IMP: brown, hurl fireballs
					new SimpleThing(level,img("TROOA1"),20,false,x,y,false,false);
					_enemies++;
					_imps++;
					break;
				case(0x0bba):// 0bba   SARG +      # DEMON: pink, muscular bull-like chewers
					new SimpleThing(level,img("SARGA1"),20,false,x,y,false,false);
					_enemies++;
					_demons++;
					break;
				case(0x003a):// 003a   SARG +      # SPECTRE: invisible version of the DEMON
					_enemies++;
					_demons++;
					_unknown++;
					break;
				case(0x0bbe):// 0bbe r SKUL +     ^# LOST SOUL: flying flaming skulls, they really bite
					new SimpleThing(level,img("SKULA1"),20,false,x,y,false,false);
					_unknown++;
					_lostSouls++;
					break;
				case(0x0bbd):// 0bbd r HEAD +     ^# CACODEMON: red one-eyed floating heads. Behold...
					new SimpleThing(level,img("HEADA1"),20,false,x,y,false,false);
					_enemies++;
					_cacodemons++;
					break;
				case(0x0045):// 0045 2 BOS2 +      # HELL KNIGHT: grey-not-pink BARON, weaker
					new SimpleThing(level,img("BOS2A1C1"),20,false,x,y,false,false);
					_enemies++;
					_hellKnights++;
					break;
				case(0x0bbb):// 0bbb   BOSS +      # BARON OF HELL: cloven hooved minotaur boss
					new SimpleThing(level,img("BOSSA1"),20,false,x,y,false,false);
					_enemies++;
					_bosses++;
					break;
				case(0x0044):// 0044 2 BSPI +      # ARACHNOTRON: baby SPIDER, shoots green plasma
					new SimpleThing(level,img("BSPIA1D1"),20,false,x,y,false,false);
					_enemies++;
					_bosses++;
					break;
				case(0x0047):// 0047 2 PAIN +     ^# PAIN ELEMENTAL: shoots LOST SOULS, deserves its name
					new SimpleThing(level,img("PAINA1"),20,false,x,y,false,false);
					_enemies++;
					_painElementals++;
					break;
				case(0x0042):// 0042 2 SKEL +      # REVENANT: Fast skeletal dude shoots homing missles
					new SimpleThing(level,img("SKELC1F1"),20,false,x,y,false,false);
					_enemies++;
					_revenants++;
					break;
				case(0x0043):// 0043 2 FATT +      # MANCUBUS: Big, slow brown guy shoots barrage of
					new SimpleThing(level,img("FATTA1"),20,false,x,y,false,false);
					_enemies++;
					_mancubi++;
					break;
				case(0x0040):// 0040 2 VILE +      # ARCH-VILE: Super-fire attack, ressurects the dead!
					new SimpleThing(level,img("VILEB1E1"),20,false,x,y,false,false);
					_enemies++;
					_archViles++;
					break;
				case(0x0007):// 0007 r SPID +      # SPIDER MASTERMIND: giant walking brain boss
					new SimpleThing(level,img("SPIDA1D1"),20,false,x,y,false,false);
					_enemies++;
					_bosses++;
					break;
				case(0x0010):// 0010 r CYBR +      # CYBER-DEMON: robo-boss, rocket launcher
					new SimpleThing(level,img("CYBRA1"),20,false,x,y,false,false);
					_enemies++;
					_bosses++;
					break;
				case(0x0058):// 0058 2 BBRN +      # BOSS BRAIN: Horrifying visage of the ultimate demon
					new SimpleThing(level,img("BBRNB0"),16,false,x,y,false,false);
					_bosses++;
					break;
				case(0x0059):// 0059 2 -    -        Boss Shooter: Shoots spinning skull-blocks
					_unknown++;
					break;
				case(0x0057):// 0057 2 -    -        Spawn Spot: Where Todd McFarlane's guys appear
					_unknown++;
					break;
				case(0x0048):// 0048 2 KEEN a+     # A guest appearance by Billy
					_unknown++;
					break;
				// ___________________________________________________________________________________
				//                                                                             WEAPONS
				case(0x07d5):// 07d5   CSAW a      $ Chainsaw
					new SimpleThing(level,img("CSAWA0"),20,false,x,y,false,false);
					break;
				case(0x07d1):// 07d1   SHOT a      $ Shotgun
					new SimpleThing(level,img("SHOTA0"),20,false,x,y,false,false);
					break;
				case(0x0052):// 0052 2 SGN2 a      $ Double-barreled shotgun
					new SimpleThing(level,img("SGN2A0"),20,false,x,y,false,false);
					break;
				case(0x07d2):// 07d2   MGUN a      $ Chaingun, gatling gun, mini-gun, whatever
					new SimpleThing(level,img("MGUNA0"),20,false,x,y,false,false);
					break;
				case(0x07d3):// 07d3   LAUN a      $ Rocket launcher
					new SimpleThing(level,img("LAUNA0"),20,false,x,y,false,false);
					break;
				case(0x07d4):// 07d4 r PLAS a      $ Plasma gun
					new SimpleThing(level,img("PLASA0"),20,false,x,y,false,false);
					break;
				case(0x07d6):// 07d6 r BFUG a      $ Bfg9000
					new SimpleThing(level,img("BFUGA0"),20,false,x,y,false,false);
					break;
				// ___________________________________________________________________________________
				//                                                                                AMMO
				case(0x07d7):// 07d7   CLIP a      $ Ammo clip
					new SimpleThing(level,img("CLIPA0"),20,false,x,y,false,false);
					_ammo++;
					break;
				case(0x07d8):// 07d8   SHEL a      $ Shotgun shells
					new SimpleThing(level,img("SHELA0"),20,false,x,y,false,false);
					_ammo++;
					break;
				case(0x07da):// 07da   ROCK a      $ A rocket
					new SimpleThing(level,img("ROCKA0"),20,false,x,y,false,false);
					_ammo++;
					break;
				case(0x07ff):// 07ff r CELL a      $ Cell charge
					new SimpleThing(level,img("CELLA0"),20,false,x,y,false,false);
					_ammo++;
					break;
				case(0x0800):// 0800   AMMO a      $ Box of Ammo
					new SimpleThing(level,img("AMMOA0"),20,false,x,y,false,false);
					_ammo++;
					break;
				case(0x0801):// 0801   SBOX a      $ Box of Shells
					new SimpleThing(level,img("SBOXA0"),20,false,x,y,false,false);
					_ammo++;
					break;
				case(0x07fe):// 07fe   BROK a      $ Box of Rockets
					new SimpleThing(level,img("BROKA0"),20,false,x,y,false,false);
					_ammo++;
					break;
				case(0x0011):// 0011 r CELP a      $ Cell charge pack
					new SimpleThing(level,img("CELPA0"),20,false,x,y,false,false);
					_ammo++;
					break;
				case(0x0008):// 0008   BPAK a      $ Backpack: doubles maximum ammo capacities
					new SimpleThing(level,img("BPAKA0"),20,false,x,y,false,false);
					_ammo++;
					break;
				// ___________________________________________________________________________________
				//                                                                            KEYCARDS
				case(0x0005):// 0005   BKEY ab     $ Blue keycard
					new SimpleThingAni2(level,img("BKEYA0"),img("BKEYB0"),20,false,x,y,false,true);
					break;
				case(0x0028):// 0028 r BSKU ab     $ Blue skullkey
					new SimpleThingAni2(level,img("BSKUA0"),img("BSKUB0"),20,false,x,y,false,true);
					break;
				case(0x000d):// 000d   RKEY ab     $ Red keycard
					new SimpleThingAni2(level,img("RKEYA0"),img("RKEYB0"),20,false,x,y,false,true);
					break;
				case(0x0026):// 0026 r RSKU ab     $ Red skullkey
					new SimpleThingAni2(level,img("RSKUA0"),img("RSKUB0"),20,false,x,y,false,true);
					break;
				case(0x0006):// 0006   YKEY ab     $ Yellow keycard
					new SimpleThingAni2(level,img("YKEYA0"),img("YKEYB0"),20,false,x,y,false,true);
					break;
				case(0x0027):// 0027 r YSKU ab     $ Yellow skullkey
					new SimpleThingAni2(level,img("YSKUA0"),img("YSKUB0"),20,false,x,y,false,true);
					break;
				// ___________________________________________________________________________________
				//                                                                               ITEMS
				case(0x07de):// 07de   BON1 abcdcb ! Health Potion +1% health
					new SimpleThingAni4R(level,img("BON1A0"),img("BON1B0"),img("BON1C0"),img("BON1D0"),20,false,x,y,false,false);
					_items++;
					break;
				case(0x07df):// 07df   BON2 abcdcb ! Spirit Armor +1% armor
					new SimpleThingAni4R(level,img("BON2A0"),img("BON2B0"),img("BON2C0"),img("BON2D0"),20,false,x,y,false,false);
					_items++;
					break;
				case(0x0053):// 0053 2 MEGA abcd   ! Megasphere: 200% health, 200% armor
					new SimpleThingAni4(level,img("MEGAA0"),img("MEGAB0"),img("MEGAC0"),img("MEGAD0"),20,false,x,y,false,false);
					_items++;
					break;
				case(0x07dd):// 07dd   SOUL abcdcb ! Soulsphere, Supercharge, +100% health
					new SimpleThingAni4R(level,img("SOULA0"),img("SOULB0"),img("SOULC0"),img("SOULD0"),20,false,x,y,false,false);
					_items++;
					break;
				case(0x07e6):// 07e6 r PINV abcd   ! Invulnerability
					new SimpleThingAni4(level,img("PINVA0"),img("PINVB0"),img("PINVC0"),img("PINVD0"),20,false,x,y,false,false);
					_items++;
					break;
				case(0x07e7):// 07e7 r PSTR a      ! Berserk Strength and 100% health
					new SimpleThing(level,img("PSTRA0"),20,false,x,y,false,false);
					_items++;
					break;
				case(0x07e8):// 07e8   PINS abcd   ! Invisibility
					new SimpleThingAni4(level,img("PINSA0"),img("PINSB0"),img("PINSC0"),img("PINSD0"),20,false,x,y,false,false);
					_items++;
					break;
				case(0x07ea):// 07ea   PMAP abcdcb ! Computer map
					new SimpleThingAni4R(level,img("PMAPA0"),img("PMAPB0"),img("PMAPC0"),img("PMAPD0"),20,false,x,y,false,true);
					_items++;
					break;
				case(0x07fd):// 07fd   PVIS ab     ! Lite Amplification goggles
					new SimpleThingAni2(level,img("PVISA0"),img("PVISB0"),20,false,x,y,false,false);
					_items++;
					break;
				// ___________________________________________________________________________________
				//                                                                        MISC PICKUPS
				case(0x07db):// 07db   STIM a      $ Stimpak
					new SimpleThing(level,img("STIMA0"),20,false,x,y,false,false);
					break;
				case(0x07dc):// 07dc   MEDI a      $ Medikit
					new SimpleThing(level,img("MEDIA0"),20,false,x,y,false,false);
					break;
				case(0x07e2):// 07e2   ARM1 ab     $ Green armor 100%
					new SimpleThingAni2(level,img("ARM1A0"),img("ARM1B0"),20,false,x,y,false,false);
					break;
				case(0x07e3):// 07e3   ARM2 ab     $ Blue armor 200%
					new SimpleThingAni2(level,img("ARM2A0"),img("ARM2B0"),20,false,x,y,false,false);
					break;
				case(0x07e9):// 07e9   SUIT a      ! Radiation suit
					new SimpleThing(level,img("SUITA0"),20,false,x,y,false,false);
					// Not an item since version 1.666
					//_items++;
					break;
				// ___________________________________________________________________________________
				//                                                                           OBSTACLES
				case(0x0030):// 0030   ELEC a      # Tall, techno pillar
					new SimpleThing(level,img("ELECA0"),30,true,x,y,false,false);
					break;
				case(0x001e):// 001e r COL1 a      # Tall green pillar
					new SimpleThing(level,img("COL1A0"),16,true,x,y,false,false);
					break;
				case(0x0020):// 0020 r COL3 a      # Tall red pillar
					new SimpleThing(level,img("COL3A0"),16,true,x,y,false,false);
					break;
				case(0x001f):// 001f r COL2 a      # Short green pillar
					new SimpleThing(level,img("COL2A0"),16,true,x,y,false,false);
					break;
				case(0x0024):// 0024 r COL5 ab     # Short green pillar with beating heart
					new SimpleThingAni2(level,img("COL4A0"),img("COL4B0"),16,true,x,y,false,false);
					break;
				case(0x0021):// 0021 r COL4 a      # Short red pillar
					new SimpleThing(level,img("COL4A0"),16,true,x,y,false,false);
					break;
				case(0x0025):// 0025 r COL6 a      # Short red pillar with skull
					new SimpleThing(level,img("COL6A0"),16,true,x,y,false,false);
					break;
				case(0x002f):// 002f r SMIT a      # Stalagmite: small brown pointy stump
					new SimpleThing(level,img("SMITA0"),16,true,x,y,false,false);
					break;
				case(0x002b):// 002b r TRE1 a      # Burnt tree: gray tree
					new SimpleThing(level,img("TRE1A0"),32,true,x,y,false,false);
					break;
				case(0x0036):// 0036 r TRE2 a      # Large brown tree
					new SimpleThing(level,img("TRE2A0"),16,true,x,y,false,false);
					break;
				case(0x07ec):// 07ec   COLU a      # Floor lamp
					new SimpleThing(level,img("COLUA0"),16,true,x,y,false,true);
					break;
				case(0x0055):// 0055 2 TLMP abcd   # Tall techno floor lamp
					new SimpleThingAni4(level,img("TLMPA0"),img("TLMPB0"),img("TLMPC0"),img("TLMPD0"),16,true,x,y,false,true);
					break;
				case(0x0056):// 0056 2 TLP2 abcd   # Short techno floor lamp
					new SimpleThingAni4(level,img("TLP2A0"),img("TLP2B0"),img("TLP2C0"),img("TLP2D0"),16,true,x,y,false,true);
					break;
				case(0x0023):// 0023   CBRA a      # Candelabra
					new SimpleThing(level,img("CBRAA0"),16,true,x,y,false,true);
					break;
				case(0x002c):// 002c r TBLU abcd   # Tall blue firestick
					new SimpleThingAni4(level,img("TBLUA0"),img("TBLUB0"),img("TBLUC0"),img("TBLUD0"),16,true,x,y,false,false);
					break;
				case(0x002d):// 002d r TGRE abcd   # Tall green firestick
					// Is it actually TGRN or what?
					new SimpleThingAni4(level,img("TGRNA0"),img("TGRNB0"),img("TGRNC0"),img("TGRND0"),16,true,x,y,false,false);
					break;
				case(0x002e):// 002e   TRED abcd   # Tall red firestick
					new SimpleThingAni4(level,img("TREDA0"),img("TREDB0"),img("TREDC0"),img("TREDD0"),16,true,x,y,false,false);
					break;
				case(0x0037):// 0037 r SMBT abcd   # Short blue firestick
					new SimpleThingAni4(level,img("SMBTA0"),img("SMBTB0"),img("SMBTC0"),img("SMBTD0"),16,true,x,y,false,false);
					break;
				case(0x0038):// 0038 r SMGT abcd   # Short green firestick
					new SimpleThingAni4(level,img("SMGTA0"),img("SMGTB0"),img("SMGTC0"),img("SMGTD0"),16,true,x,y,false,false);
					break;
				case(0x0039):// 0039 r SMRT abcd   # Short red firestick
					new SimpleThingAni4(level,img("SMRTA0"),img("SMRTB0"),img("SMRTC0"),img("SMRTD0"),16,true,x,y,false,false);
					break;
				case(0x0046):// 0046 2 FCAN abc    # Burning barrel
					new SimpleThingAni3(level,img("FCANA0"),img("FCANB0"),img("FCANC0"),10,true,x,y,false,false);
					break;
				case(0x0029):// 0029 r CEYE abcb   # Evil Eye: floating eye in symbol, over candle
					new SimpleThingAni4(level,img("CEYEA0"),img("CEYEB0"),img("CEYEC0"),img("CEYEB0"),16,true,x,y,false,false);
					break;
				case(0x002a):// 002a r FSKU abc    # Floating Skull: flaming skull-rock
					new SimpleThingAni4(level,img("CEYEA0"),img("CEYEB0"),img("CEYEC0"),img("CEYEB0"),16,true,x,y,false,false);
					break;
				case(0x07f3):// 07f3   BAR1 ab+    # Barrel; not an obstacle after blown up (BEXP sprite)
					new Barrel(level,img("BAR1A0"),img("BAR1B0"),10,true,x,y);
					_barrels++;
					break;                
				case(0x0031):// 0031 r GOR1 abcb  ^# Hanging victim, twitching
					new SimpleThingAni4(level,img("GOR1A0"),img("GOR1B0"),img("GOR1C0"),img("GOR1B0"),16,true,x,y,false,false);
					break;
				case(0x0032):// 0032 r GOR2 a     ^# Hanging victim, arms out
					new SimpleThing(level,img("GOR2A0"),16,true,x,y,true,false);
					break;
				case(0x0034):// 0034 r GOR4 a     ^# Hanging pair of legs
					new SimpleThing(level,img("GOR4A0"),16,true,x,y,true,false);
					break;
				case(0x0033):// 0033 r GOR3 a     ^# Hanging victim, 1-legged
					new SimpleThing(level,img("GOR3A0"),16,true,x,y,true,false);
					break;
				case(0x0035):// 0035 r GOR5 a     ^# Hanging leg
					new SimpleThing(level,img("GOR5A0"),16,true,x,y,true,false);
					break;
				case(0x0049):// 0049 2 HDB1 a     ^# Hanging victim, guts removed
					new SimpleThing(level,img("HDB1A0"),16,true,x,y,true,false);
					break;
				case(0x004a):// 004a 2 HDB2 a     ^# Hanging victim, guts and brain removed
					new SimpleThing(level,img("HDB2A0"),16,true,x,y,true,false);
					break;
				case(0x004b):// 004b 2 HDB3 a     ^# Hanging torso, looking down
					new SimpleThing(level,img("HDB3A0"),16,true,x,y,true,false);
					break;
				case(0x004c):// 004c 2 HDB4 a     ^# Hanging torso, open skull
					new SimpleThing(level,img("HDB4A0"),16,true,x,y,true,false);
					break;
				case(0x004d):// 004d 2 HDB5 a     ^# Hanging torso, looking up
					new SimpleThing(level,img("HDB5A0"),16,true,x,y,true,false);
					break;
				case(0x004e):// 004e 2 HDB6 a     ^# Hanging torso, brain removed
					new SimpleThing(level,img("HDB6A0"),16,true,x,y,true,false);
					break;
				case(0x0019):// 0019 r POL1 a      # Impaled human
					new SimpleThing(level,img("POL1A0"),16,true,x,y,false,false);
					break;
				case(0x001a):// 001a r POL6 ab     # Twitching impaled human
					new SimpleThingAni2(level,img("POL6A0"),img("POL6B0"),16,true,x,y,false,false);
					break;
				case(0x001b):// 001b r POL4 a      # Skull on a pole
					new SimpleThing(level,img("POL4A0"),16,true,x,y,false,false);
					break;
				case(0x001c):// 001c r POL2 a      # 5 skulls shish kebob
					new SimpleThing(level,img("POL2A0"),16,true,x,y,false,false);
					break;
				case(0x001d):// 001d r POL3 ab     # Pile of skulls and candles
					new SimpleThingAni2(level,img("POL3A0"),img("POL3B0"),16,true,x,y,false,false);
					break;
				// ___________________________________________________________________________________
				//                                                                         DECORATIONS
				case(0x0022):// 0022   CAND a        Candle
					new SimpleThing(level,img("CANDA0"),16,true,x,y,false,false);
					break;
				case(0x003f):// 003f r GOR1 abcb  ^  Hanging victim, twitching
					new SimpleThingAni4(level,img("GOR1A0"),img("GOR1B0"),img("GOR1C0"),img("GOR1B0"),16,false,x,y,true,false);
					break;
				case(0x003b):// 003b r GOR2 a     ^  Hanging victim, arms out
					new SimpleThing(level,img("GOR2A0"),16,false,x,y,true,false);
					break;
				case(0x003c):// 003c r GOR4 a     ^  Hanging pair of legs
					new SimpleThing(level,img("GOR4A0"),16,false,x,y,true,false);
					break;
				case(0x003d):// 003d r GOR3 a     ^  Hanging victim, 1-legged
					new SimpleThing(level,img("GOR3A0"),16,false,x,y,true,false);
					break;
				case(0x003e):// 003e r GOR5 a     ^  Hanging leg
					new SimpleThing(level,img("GOR5A0"),16,false,x,y,true,false);
					break;
				case(0x000a):// 000a   PLAY w        Bloody mess (an exploded player)
				case(0x000c):// 000c   PLAY w        Bloody mess, this thing is exactly the same as 10
					new SimpleThing(level,img("PLAYW0"),16,false,x,y,false,false);
					break;
				case(0x0018):// 0018   POL5 a        Pool of blood and flesh
					new SimpleThing(level,img("POL5A0"),16,false,x,y,false,false);
					break;
				case(0x004f):// 004f 2 POB1 a        Pool of blood
					new SimpleThing(level,img("POB1A0"),16,false,x,y,false,false);
					break;
				case(0x0050):// 0050 2 POB2 a        Pool of blood
					new SimpleThing(level,img("POB2A0"),16,false,x,y,false,false);
					break;
				case(0x0051):// 0051 2 BRS1 a        Pool of brains
					new SimpleThing(level,img("BRS1A0"),16,false,x,y,false,false);
					break;
				case(0x000f):// 000f   PLAY n        Dead player
					new SimpleThing(level,img("PLAYN0"),16,false,x,y,false,false);
					break;
				case(0x0012):// 0012   POSS l        Dead former human
					new SimpleThing(level,img("POSSL0"),20,false,x,y,false,false);
					break;
				case(0x0013):// 0013   SPOS l        Dead former sergeant
					new SimpleThing(level,img("SPOSL0"),20,false,x,y,false,false);
					break;
				case(0x0014):// 0014   TROO m        Dead imp
					new SimpleThing(level,img("TROOM0"),20,false,x,y,false,false);
					break;
				case(0x0015):// 0015   SARG n        Dead demon
					new SimpleThing(level,img("SARGN0"),30,false,x,y,false,false);
					break;
				case(0x0016):// 0016 r HEAD l        Dead cacodemon
					new SimpleThing(level,img("HEADL0"),31,false,x,y,false,false);
					break;
				case(0x0017):// 0017 r SKUL k        Dead lost soul, invisible
					// ???
					_unknown++;
					break;
				default:
					_unknown++;
					trace("Unknown thing type (0x"+thing.type.toString(16)+")");
					break;
			}
		}
	}
}