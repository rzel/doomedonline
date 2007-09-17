package com.brokenfunction.ezlo {
	import flash.events.Event;
	
	public class TimeEvent extends Event {
		private var _steps:uint;
		private var _time:uint;
		private var _subSteps:Number;
		
		public function TimeEvent(type:String,steps:uint,time:uint,subSteps:uint,cancelable:Boolean = false) {
			super(type,false,cancelable);
			_steps = steps;
			_time = time;
			_subSteps = subSteps;
		}
		
		public override function clone():Event {
			return new TimeEvent(type,steps,time,subSteps,cancelable);
		}
		public override function toString():String {
			return "[TimeEvent type="+type+" steps="+steps+" time="+time+" subSteps="+subSteps+" cancelable="+cancelable+"]";
		}
		
		public function get steps():uint {return _steps;}
		public function get time():uint {return _time;}
		public function get subSteps():uint {return _subSteps;}
	}
}