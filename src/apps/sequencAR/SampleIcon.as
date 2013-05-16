package apps.sequencAR {
	import com.transmote.utils.time.Timeout;
	
	import flash.display.Sprite;
	import flash.media.Sound;
	
	public class SampleIcon extends Sprite {
		private static const ACTIVE_TIME:Number = 1000;
		private static const SIZE_INACTIVE:Number = 30;
		private static const SIZE_ACTIVE:Number = 40;
		
		private var sample:Sound;
		
		public function SampleIcon (sample:Sound) {
			this.sample = sample;
			this.renderInactive();
		}
		
		public function play () :void {
			this.sample.play();
			this.renderActive();
		}
		
		public function kill () :void {
			try {
				this.sample.close();
			} catch (e:Error) {
				//
			}
			this.sample = null;
		}
		
		private function renderActive () :void {
			this.graphics.clear();
			this.graphics.lineStyle(4, 0x33FF33);
			this.graphics.drawRect(-0.5*SIZE_ACTIVE, -0.5*SIZE_ACTIVE, SIZE_ACTIVE, SIZE_ACTIVE);
			var timeout:Timeout = new Timeout(this.renderInactive, ACTIVE_TIME);
		}
		
		private function renderInactive () :void {
			this.graphics.clear();
			this.graphics.lineStyle(2, 0x99FF99);
			this.graphics.drawRect(-0.5*SIZE_INACTIVE, -0.5*SIZE_INACTIVE, SIZE_INACTIVE, SIZE_INACTIVE);
		}
	}
}