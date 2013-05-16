package apps.whackAMole {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.tracker.FLARToolkitManager;
	import com.transmote.flar.tracker.FlareManager;
	import com.transmote.utils.ui.EmbeddedLibrary;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	public class WhackAMole extends Sprite {
		private static const MOLE_MARGIN_X:Number = 120;
		private static const MOLE_MARGIN_Y:Number = 200;
		private static const MOLE_SPACING_X:Number = 200;
		private static const MOLE_SPACING_Y:Number = 200;
		private static const MOLE_HIT_OFFSET_Y:Number = 80;
		private static const MOLE_HIT_RADIUS:Number = 60;
		
		private var moleContainer:Sprite;
		private var moles:Vector.<Mole>;
		
		private var flarManager:FLARManager;
		private var cursor:MovieClip;
		
		[Embed('../resources/assets/apps/whackAMole.swf', mimeType='application/octet-stream')]
		private var LibraryClass:Class;
		private var library:EmbeddedLibrary;

		public function WhackAMole () {
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAdded);
		}
		
		private function onAdded (evt:Event) :void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAdded);
			this.initLibrary();
		}
		
		private function initLibrary () :void {
			this.library = new EmbeddedLibrary(LibraryClass);
			this.library.addEventListener(Event.INIT, this.onLibraryLoaded);
		}
		
		private function onLibraryLoaded (evt:Event) :void {
			this.library.removeEventListener(Event.INIT, this.onLibraryLoaded);
			
			this.initFLARManager();
			this.initMoles();
			this.initCursor();
		}
		
		private function initFLARManager () :void {
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FLARToolkitManager(), this.stage);
			this.addChildAt(Sprite(this.flarManager.flarSource), 0);
			
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
		}
		
		private function initCursor () :void {
			this.cursor = this.library.getSymbolInstance("hammer") as MovieClip;
			this.addChild(this.cursor);
			this.cursor.visible = false;
		}
		
		private function initMoles () :void {
			this.moleContainer = new Sprite();
			this.addChild(this.moleContainer);
			
			this.moles = new Vector.<Mole>(6, true);
			var mole:Mole;
			for (var i:uint=0; i<this.moles.length; i++) {
				mole = new Mole(this.library);
				mole.x = MOLE_MARGIN_X + (i%3) * MOLE_SPACING_X;
				mole.y = MOLE_MARGIN_Y + Math.floor(i/3) * MOLE_SPACING_Y;
				this.moles[i] = mole;
				this.moleContainer.addChild(mole);
			}
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			this.onMarkerUpdated(evt);
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			this.cursor.visible = true;
			this.cursor.gotoAndStop(1);
			this.cursor.x = evt.marker.x;
			this.cursor.y = evt.marker.y;
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			this.cursor.gotoAndPlay(1);
			this.checkForHit(evt.marker);
		}
		
		private function checkForHit (marker:FLARMarker) :void {
			var mole:Mole;
			var moleLocation:Point;
			for (var i:uint=0; i<this.moles.length; i++) {
				mole = this.moles[i];
				moleLocation = new Point(mole.x, mole.y - MOLE_HIT_OFFSET_Y);
				if (Point.distance(moleLocation, marker.centerpoint) < MOLE_HIT_RADIUS) { 
					mole.onHit();
				}
			}
		}
	}
}