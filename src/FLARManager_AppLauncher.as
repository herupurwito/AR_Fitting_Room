package {
	import apps.magicMarker.MagicMarker;
	import apps.markerBall.MarkerBall;
	import apps.sequencAR.SequencAR;
	import apps.swimmAR.SwimmAR;
	import apps.whackAMole.WhackAMole;
	
	import flash.display.Sprite;
	
	[SWF(width="640", height="480", frameRate="30", backgroundColor="#000000")]
	public class FLARManager_AppLauncher extends Sprite {
		public function FLARManager_AppLauncher () {
			// simply uncomment whichever app you would like to launch.
			
//			this.addChild(new MagicMarker());
//			this.addChild(new WhackAMole());
			this.addChild(new MarkerBall());
//			this.addChild(new SequencAR());
		}
	}
}