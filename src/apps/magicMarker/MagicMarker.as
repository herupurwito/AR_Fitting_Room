package apps.magicMarker {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.tracker.FLARToolkitManager;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Point;

	public class MagicMarker extends Sprite {
		private static const MARKER_MOVED_MIN:Number = 5;
		private static const MARKER_MOVED_MAX:Number = 150;
		
		private static const MIN_Z:Number = 200;
		private static const Z_RANGE:Number = 1300;
		private static const MAX_STROKE_WIDTH:Number = 100;
		
		private var flarManager:FLARManager;
		private var canvas:Sprite;
		
		// hash marker locations by patternId
		private var currMarkerLocations:Vector.<Point>;
		private var lastMarkerLocations:Vector.<Point>;
		
		
		public function MagicMarker () {
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAdded);
		}
		
		private function onAdded (evt:Event) :void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAdded);
			this.init();
		}
		
		private function init () :void {
			this.initFLARManager();
			this.initCanvas();
			this.stage.addEventListener(MouseEvent.CLICK, this.onClick);
		}
		
		private function initFLARManager () :void {
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FLARToolkitManager(), this.stage);
			this.addChildAt(Sprite(this.flarManager.flarSource), 0);
			
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
		}
		
		private function initCanvas () :void {
			this.canvas = new Sprite();
			this.canvas.alpha = 0.75;
			this.canvas.filters = new Array(new BlurFilter(8, 8, 2));
			this.addChild(this.canvas);
			
			this.currMarkerLocations = new Vector.<Point>();
			this.lastMarkerLocations = new Vector.<Point>();
		}
		
		private function onClick (evt:MouseEvent) :void {
			this.canvas.graphics.clear();
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			this.onMarkerUpdated(evt);
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			this.draw(evt.marker);
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			this.currMarkerLocations[evt.marker.patternId] = this.lastMarkerLocations[evt.marker.patternId] = null;
		}
		
		private function draw (marker:FLARMarker) :void {
			if (marker.patternId >= this.currMarkerLocations.length) {
				// allocate storage for marker locations as needed
				this.currMarkerLocations.length = this.lastMarkerLocations.length = marker.patternId + 1;
			}
			
			var currMarkerLoc:Point = marker.centerpoint.clone();
			var lastMarkerLoc:Point = this.lastMarkerLocations[marker.patternId];
			this.currMarkerLocations[marker.patternId] = currMarkerLoc;
			if (!lastMarkerLoc) {
				this.lastMarkerLocations[marker.patternId] = currMarkerLoc;
				return;
			}
			
			// if marker has not moved more than MARKER_MOVED_MIN, do not draw
			if (Point.distance(currMarkerLoc, lastMarkerLoc) < MARKER_MOVED_MIN) {
				return;
			}
			
			// if marker moved more than MARKER_MOVED_MAX, do not draw;
			// most likely a glitch in marker detection
			if (Point.distance(currMarkerLoc, lastMarkerLoc) > MARKER_MOVED_MAX) {
				return;
			}
			
			// draw a line from lastMarkerLocation to currMarkerLocation
			this.canvas.graphics.lineStyle(this.getWidthByMarkerZ(marker.z), this.getColorByPatternId(marker.patternId), 1.0);
			this.canvas.graphics.moveTo(lastMarkerLoc.x, lastMarkerLoc.y);
			this.canvas.graphics.lineTo(currMarkerLoc.x, currMarkerLoc.y);
			
			// store current marker location
			this.lastMarkerLocations[marker.patternId] = currMarkerLoc;
		}
		
		private function getColorByPatternId (patternId:int) :uint {
			switch (patternId % 12) {
				case 0:		return 0xFF1919;
				case 1:		return 0xFF19E8;
				case 2:		return 0x9E19FF;
				case 3:		return 0x192EFF;
				case 4:		return 0x1996FF;
				case 5:		return 0x19FDFF;
				case 6:		return 0x19FF5A;
				case 7:		return 0x19FFAA;
				case 8:		return 0x6CFF19;
				case 9:		return 0xF9FF19;
				case 10:	return 0xFFCE19;
				case 11:	return 0xFF9A19;
				default:	return 0xCCCCCC;
			}
		}
		
		private function getWidthByMarkerZ (z:Number) :int {
			var relativeDepth:Number = 1 - ((z - MIN_Z) / Z_RANGE);
			relativeDepth = Math.max(0, Math.min(relativeDepth, 1));
			return Math.floor(MAX_STROKE_WIDTH * Math.pow(relativeDepth, 2));
		}
	}
}