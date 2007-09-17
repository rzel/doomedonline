package {
	import com.brokenfunction.doom.DoomCore;
	import com.brokenfunction.util.Fps;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.display.StageQuality;
	import flash.utils.ByteArray;
	
	//[SWF(width="960",height="600",frameRate="35",backgroundColor="#333333")]
	[SWF(width="640",height="400",frameRate="35",backgroundColor="#333333")]
	//[SWF(width="320",height="200",frameRate="35",backgroundColor="#333333")]
	public class DoomTest extends Sprite {
		[Embed(source="doom1-shareware.wad",mimeType="application/octet-stream")]
		private const DoomWad:Class;
		
		public function DoomTest() {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = StageQuality.LOW;
			scaleX = scaleY = 2;
			//scaleX = scaleY = 3;
			
			var wad:ByteArray = new DoomWad() as ByteArray;
			
			new DoomCore(this,wad);
		}
	}
}