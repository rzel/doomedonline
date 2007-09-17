package com.brokenfunction.util {
	import flash.display.InteractiveObject;
	import flash.events.KeyboardEvent;
	import flash.events.EventDispatcher;
	
	public class KeyInput implements Input {
		private var dispatch:EventDispatcher;
		private var now:uint = 0;
		private var keys:Object = {};
		
		public function KeyInput(keyDispatcher:EventDispatcher) {
			dispatch = keyDispatcher;
			dispatch.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			dispatch.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
		}
		public function destroy():void {
			dispatch.removeEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
			dispatch.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			dispatch = null;
		}
		public function getInput(steps:uint = 0):uint {
			return now;
		}
		private function onKeyDown(e:KeyboardEvent):void {
			now |= uint(keys[e.keyCode] || 0);
		}
		private function onKeyUp(e:KeyboardEvent):void {
			now &= ~uint(keys[e.keyCode] || 0);
		}
		public function setKey(b:uint,k:uint):void {
			keys[k] = b;
		}
		public function addKey(b:uint,k:uint):void {
			if (keys[k]) {
				keys[k] |= b;
			} else {
				keys[k] = b;
			}
		}
		public function resetKeys():void {
			keys = {}
		}
	}
}