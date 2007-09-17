package com.brokenfunction.util {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	public class Counter {
		static private const SLACK:uint = 1;
		
		private var timer:Timer;
		private var last:uint;
		private var _min:uint;
		private var _max:uint;
		private var _onTick:Function;
		
		public function Counter(min:uint,max:uint,onTick:Function) {
			super();
			_min = 1000/min;
			_max = 1000/max;
			_onTick = onTick;
			timer = new Timer(1);
			timer.addEventListener(TimerEvent.TIMER,onTimer);
			last = getTimer();
			timer.start();
		}
		private function onTimer(e:TimerEvent):void {
			var time:uint = getTimer();
			var change:uint = time-last;
			if (change >= _min) {
				change += SLACK;
				_onTick((change <= _max)? _max :change);
				last = time+SLACK;
				timer.delay = SLACK+1;
			} else {
				timer.delay = 1;
			}
		}
	}
}