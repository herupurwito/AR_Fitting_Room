package {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.tracker.FLARToolkitManager;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	[SWF(width="640", height="480", frameRate="30", backgroundColor="#FFFFFF")]
	public class FLARManagerProfiler extends Sprite {
		private var flarManager:FLARManager;
		
		public function FLARManagerProfiler () {
			this.init();
		}
		
		private function init () :void {
			this.initFLARManager();
			this.stage.addEventListener(MouseEvent.CLICK, this.onClick);
		}
		
		private function initFLARManager () :void {
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FLARToolkitManager(), this.stage);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
			this.addChild(Sprite(this.flarManager.flarSource));
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			trace("MARKER ADDED");
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			trace("MARKER REMOVED");
		}
		
		private function destroyFLARManager () :void {
			this.removeChild(Sprite(this.flarManager.flarSource));
			this.flarManager.removeEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.removeEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
			this.flarManager.dispose();
			this.flarManager = null;
		}
		
		private function onClick (evt:MouseEvent) :void {
			if (this.flarManager) {
				this.destroyFLARManager();
			} else {
				this.initFLARManager();
			}
		}
	}
}