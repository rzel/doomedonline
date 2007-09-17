package com.brokenfunction.util {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	public class Fps extends TextField {
		public const maxTimers:uint = 4;
		
		private var txtA:String;
		private var txtB:String;
		private var lastMem:uint = uint.MAX_VALUE;
		private var baseMem:uint = uint.MAX_VALUE;
		private var timr:Array;// uint
		private var cnt:Array;// uint
		private var stime:int;
		
		public function Fps() {
			super();
			
			autoSize = TextFieldAutoSize.LEFT;
			background = true;
			backgroundColor = 0xffffff;
			//border = true;
			//borderColor = 0x000000;
			multiline = false;
			selectable = false;
			type = TextFieldType.DYNAMIC;
			wordWrap = false;
			defaultTextFormat = new TextFormat();
			defaultTextFormat.font = "Verdana";
			defaultTextFormat.size = 8;
			mouseEnabled = true;
			addEventListener(MouseEvent.CLICK,onClick);
			addEventListener(Event.ENTER_FRAME,onEnterFrame);
			text = (txtA = "...")+(txtB = "");
			var i:uint = maxTimers;
			timr = new Array(i);
			cnt = new Array(i);
			while (i > 0) {
				i--;
				timr[i] = setTimeout(onStartCount,(i+1*1000)/maxTimers,i);
			}
		}
		private final function onStartCount(i:uint):void {
			cnt[i] = 0;
			timr[i] = setInterval(onCount,1000,i);
		}
		private final function onCount(i:uint):void {
			txtA = cnt[i].toString();
			cnt[i] = 0;
			update();
		}
		public function startScriptTime():void {
			stime = getTimer();
		}
		public function stopScriptTime():void {
			setScriptTime(getTimer()-stime)
		}
		public function setScriptTime(t:uint):void {
			txtB = " ("+t+")";
			update();
		}
		private function update():void {
			var mem:uint = flash.system.System.totalMemory;
			lastMem = (mem < lastMem)? (baseMem = mem) :mem;
			text = txtA+txtB+" "+uint(baseMem/1024)+"+"+uint((mem-baseMem)/1024)+"kB";
		}
		private function onClick(e:MouseEvent):void {
			background = !background;
		}
		private function onEnterFrame(e:Event):void {
			var i:uint = maxTimers;
			while (i > 0) {
				cnt[--i]++
			}
		}
	}
}
