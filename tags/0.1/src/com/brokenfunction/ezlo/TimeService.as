package com.brokenfunction.ezlo {
	public interface TimeService {
		function addTimeListener(callback:Function/*<uint>*/,split:uint = 1000,priority:int = 0,useWeakReference:Boolean = false):void;
		function removeTimeListener(callback:Function/*<uint>*/,split:uint = 1000):void;
		
		function pause():TimeService;
		function restore():void;
		
		function getTime(split:uint):uint;
	}
}