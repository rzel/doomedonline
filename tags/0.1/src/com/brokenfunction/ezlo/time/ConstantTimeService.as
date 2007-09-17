package com.brokenfunction.ezlo.time {
	import com.brokenfunction.ezlo.*;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class ConstantTimeService implements TimeService {
		static private const TICK_PREFIX:String = "_tk";
		static private const BASE_PREFIX:String = TICK_PREFIX+"1000";
		static private function nullFunc():void {}
		
		private var dispatch:EventDispatcher;
		private var backtrace:Object = {};
		private var time:uint = 0;
		
		public function ConstantTimeService(target:IEventDispatcher = null) {
			dispatch = new EventDispatcher(target);
		}
		public function pause():TimeService {
			throw new Error("ConstantTimeService cannot be paused");
		}
		public function restore():void {
			throw new Error("ConstantTimeService cannot be unpaused");
		}
		public function addTimeListener(callback:Function,split:uint = 1000,priority:int = 0,useWeakReference:Boolean = false):void {
			if (split === 0) throw new Error("Cannot split 0");
			createFpsEntry(split);
			dispatch.addEventListener(TICK_PREFIX+split,callback,false,priority,useWeakReference);
		}
		public function removeTimeListener(callback:Function,split:uint = 1000):void {
			var type:String = TICK_PREFIX+split;
			dispatch.removeEventListener(type,callback);
			
			if (!dispatch.hasEventListener(type) && split in backtrace) {
				dispatch.removeEventListener(BASE_PREFIX,(backtrace[split] as FpsEntry).onTick);
			}
		}
		public function getTime(split:uint):uint {
			return createFpsEntry(split).time;
		}
		private function createFpsEntry(split:uint):FpsEntry {
			if (split in backtrace) {
				return backtrace[split];
			} else {
				var fpsObj:FpsEntry = new FpsEntry(split,TICK_PREFIX+split);
				backtrace[split] = fpsObj;
				dispatch.addEventListener(BASE_PREFIX,fpsObj.onTick);
				return fpsObj;
			}
		}
		public function update(ms:uint):void {
			dispatch.dispatchEvent(new TimeEvent(
				BASE_PREFIX,
				ms,
				(time += ms),
				ms,
				true
			));
		}
	}
}

import com.brokenfunction.ezlo.*;
import flash.events.Event;
import flash.events.IEventDispatcher;

class FpsEntry {
	private var _type:String;
	private var _split:uint;
	private var _remainder:uint = 0;
	private var _time:uint = 0;
	private var _subTime:uint = 0;
	
	public function FpsEntry(split:uint,type:String) {
		_split = split;
		_type = type;
	}
	
	public function onTick(e:TimeEvent):void {
		var i:uint = e.steps*_split;
		var subSteps:Number = i/1000;
		i += _remainder;
		i = (i-(_remainder = i%1000))/1000;
		if ((e.currentTarget as IEventDispatcher).dispatchEvent(new TimeEvent(
			_type,
			i,
			(_time += i),
			subSteps,
			e.cancelable
		))) {
			e.preventDefault()
		}
	}
	
	public function get time():uint {return _time;}
}