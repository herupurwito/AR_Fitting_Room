package apps.markerBall {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.tracker.FLARToolkitManager;
	import com.transmote.utils.ui.EmbeddedLibrary;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class MarkerBall extends Sprite {
		private static const MIN_Z:Number = 200;
		private static const Z_RANGE:Number = 500;
		
		private var flarManager:FLARManager;
		private var ballManager:BallManager;
		private var cursor:MovieClip;
		private var cursorGfx:MovieClip;
		
		[Embed('../../../resources/assets/apps/markerBall.swf', mimeType='application/octet-stream')]
		private var LibraryClass:Class;
		private var library:EmbeddedLibrary;
		
		public function MarkerBall () {
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
			this.initCursor();
			this.initBallManager();
			
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function initFLARManager () :void {
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FLARToolkitManager(), this.stage);
			this.addChildAt(Sprite(this.flarManager.flarSource), 0);
			
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
		}
		
		private function initCursor () :void {
			this.cursor = this.library.getSymbolInstance("paddle") as MovieClip;
			this.addChild(this.cursor);
			this.cursor.visible = false;
			this.cursorGfx = this.cursor.getChildByName("gfx") as MovieClip;
		}
		
		private function initBallManager () :void {
			this.ballManager = new BallManager(this.library, 480, 480);
			this.addChild(this.ballManager);
		}
		
		private function onEnterFrame (evt:Event) :void {
			var cursorBounds:Rectangle = this.cursorGfx.getBounds(this.cursor);
			cursorBounds.size = new Point(cursorBounds.width*cursor.scaleX, cursorBounds.height*cursor.scaleY);
			this.ballManager.update(this.cursor, cursorBounds);
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			this.onMarkerUpdated(evt);
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			this.cursor.visible = true;
			this.cursor.x = evt.marker.x;
			this.cursor.y = evt.marker.y;
			this.cursor.scaleX = this.cursor.scaleY = this.calcCursorScale(evt.marker.z);
			this.cursor.rotation = evt.marker.rotationZ;
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			this.cursor.visible = false;
		}
		
		private function calcCursorScale (z:Number) :Number {
			var relativeDepth:Number = 1 - ((z - MIN_Z) / Z_RANGE);
			relativeDepth = Math.max(0, Math.min(relativeDepth, 1));
			return 0.5+relativeDepth;
		}
	}
}