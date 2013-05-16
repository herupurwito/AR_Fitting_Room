package apps.sequencAR {
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.utils.ui.EmbeddedLibrary;
	
	import flash.display.Sprite;
	import flash.media.Sound;

	public class SampleManager extends Sprite {
		private var library:EmbeddedLibrary;
		private var w:Number;
		private var h:Number;
		
		private var activeMarkers:Vector.<FLARMarker>;
		private var samples:Vector.<SampleIcon>;
		
		
		public function SampleManager (library:EmbeddedLibrary, w:Number, h:Number) {
			this.library = library;
			this.w = w;
			this.h = h;
			
			this.init();
		}
		
		public function update (playheadLoc:Number, tempo:Number) :void {
			var marker:FLARMarker;
			for (var i:uint=0; i<this.activeMarkers.length; i++) {
				marker = this.activeMarkers[i];
				if (marker.x > playheadLoc && marker.x - playheadLoc <= tempo) {
					this.samples[i].play();
				}
			} 
		}
		
		public function addMarker (marker:FLARMarker) :void {
			this.activeMarkers.push(marker);
			var sample:SampleIcon = this.createSample(marker.x, marker.y, marker.patternId);
			this.samples.push(sample);
			this.addChild(sample);
		}
		
		public function updateMarker (marker:FLARMarker) :void {
			var i:uint = this.activeMarkers.indexOf(marker);
			if (i == -1) { return; }
			
			this.samples[i].x = marker.x;
			this.samples[i].y = marker.y;
		}
		
		public function removeMarker (marker:FLARMarker) :void {
			var i:uint = this.activeMarkers.indexOf(marker);
			if (i == -1) { return; }
			
			this.activeMarkers.splice(i, 1);
			var sample:SampleIcon = this.samples[i];
			this.samples.splice(i, 1);
			this.removeChild(sample);
			sample.kill();
		}
		
		private function init () :void {
			this.activeMarkers = new Vector.<FLARMarker>();
			this.samples = new Vector.<SampleIcon>();
		}
		
		private function createSample (x:Number, y:Number, id:int) :SampleIcon {
			var newSample:SampleIcon = new SampleIcon(this.getSoundById(id));
			newSample.x = x;
			newSample.y = y;
			return newSample;
		}
		
		private function getSoundById (id:int) :Sound {
			switch (id) {
				case 0: return this.library.getSymbolInstance("kick.mp3");
				case 1: return this.library.getSymbolInstance("keys.mp3");
				case 2: return this.library.getSymbolInstance("snare.mp3");
				case 3: return this.library.getSymbolInstance("hihat.mp3");
				case 4: return this.library.getSymbolInstance("hihat_open.mp3");
				case 5: return this.library.getSymbolInstance("tom.mp3");
				default:
					return this.library.getSymbolInstance("powerKick.mp3");
			}
		}
	}
}