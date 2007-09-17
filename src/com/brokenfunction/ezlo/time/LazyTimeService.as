package com.brokenfunction.ezlo.time {
	import com.brokenfunction.ezlo.*;
	
	public class LazyTimeService extends ConstantTimeService {
		private var pausd:LazyTimeService;
		private var _onPause:Function;
		private var _onRestore:Function;
		
		public function LazyTimeService(onPause:Function = null,onRestore:Function = null) {
			_onPause = onPause;
			_onRestore = onRestore;
		}
		public override function pause():TimeService {
			if (!pausd) {
				pausd = new LazyTimeService();
				if (_onPause != null) _onPause(pausd);
			}
			return pausd;
		}
		public override function restore():void {
			if (pausd) {
				pausd = null;
				if (_onRestore != null) _onRestore(this);
			}
		}
		public override function update(ms:uint):void {
			if (pausd) {
				super.update(0);
				pausd.update(ms);
			} else {
				super.update(ms);
			}
		}
	}
}