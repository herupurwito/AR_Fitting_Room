package apps.swimmAR {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.tracker.FLARToolkitManager;
	import com.transmote.utils.ui.EmbeddedLibrary;
	
	import flash.display.MovieClip;
	import flash.display.Scene;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	
	public class SwimmAR extends Sprite {
		private static const MIN_STROKE_STRENGTH:Number = 100;
		private static const STROKE_STRENGTH_MOD:Number = 0.25;
		private static const DEFAULT_TARGET_CURSOR_A:Vector3D = new Vector3D(270, 400, 0, 0);
		private static const DEFAULT_TARGET_CURSOR_B:Vector3D = new Vector3D(370, 400, 0, 0);
		private static const CURSOR_EASE_SPEED:Number = 0.2;
		
		private var flarManager:FLARManager;
		private var cursorA:Sprite;
		private var cursorB:Sprite;
		private var markerA:FLARMarker;
		private var markerB:FLARMarker;
		
		private var bkgd:Sprite;
		private var sceneryManager:SceneryManager;
		private var targetZ:Number = 0;
		private var tgt_cursorA:Vector3D;
		private var tgt_cursorB:Vector3D;
		
		[Embed('../resources/assets/apps/swimmAR.swf', mimeType='application/octet-stream')]
		private var LibraryClass:Class;
		private var library:EmbeddedLibrary;
		
		public function SwimmAR () {
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
			this.initScenery();
			this.initCursors();
			
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function initFLARManager () :void {
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FLARToolkitManager(), this.stage);
			this.addChildAt(Sprite(this.flarManager.flarSource), 0);
			
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
		}
		
		private function initScenery () :void {
			this.bkgd = this.library.getSymbolInstance("bkgd") as Sprite;
			this.addChild(this.bkgd);
			
			this.sceneryManager = new SceneryManager(this.library);
			this.addChild(this.sceneryManager);
			
			// temp for testing
			this.stage.addEventListener(MouseEvent.CLICK, this.testStroke);
		}
		
		private function initCursors () :void {
			this.cursorA = this.library.getSymbolInstance("fin");
			this.cursorA.scaleX = 1.0;
			this.cursorA.x = DEFAULT_TARGET_CURSOR_A.x;
			this.cursorA.y = DEFAULT_TARGET_CURSOR_A.y;
			this.cursorA.rotation = DEFAULT_TARGET_CURSOR_A.w;
			this.addChild(this.cursorA);
			
			this.cursorB = this.library.getSymbolInstance("fin");
			this.cursorB.scaleX = -1.0;
			this.cursorB.x = DEFAULT_TARGET_CURSOR_B.x;
			this.cursorB.y = DEFAULT_TARGET_CURSOR_B.y;
			this.cursorB.rotation = DEFAULT_TARGET_CURSOR_B.w;
			this.addChild(this.cursorB);
		}
		
		private function onEnterFrame (evt:Event) :void {
			this.stroke();
			this.updateCursors();
			
			var dz:Number = this.targetZ - this.sceneryManager.z;
			this.sceneryManager.z += dz * 0.2;
			
			this.sceneryManager.update();
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			if (this.markerA) {
				trace("add B (A present)");
				this.markerB = evt.marker;
			} else if (this.markerB) {
				this.markerA = evt.marker;
				trace("add A (B present)");
			} else {
				if (evt.marker.x < 0.5 * this.stage.stageWidth) {
					// markerA on left,
					this.markerA = evt.marker;
					trace("add A");
				} else {
					// markerB on right.
					this.markerB = evt.marker;
					trace("add B");
				}
			}
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			//
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			if (evt.marker == this.markerA) {
				this.markerA = null;
			} else if (evt.marker == this.markerB) {
				this.markerB = null;
			}
		}
		
		private function updateCursors () :void {
			this.tgt_cursorA = this.markerA ? new Vector3D(this.markerA.x, this.markerA.y, 0, this.markerA.rotationZ) : DEFAULT_TARGET_CURSOR_A;
			this.tgt_cursorB = this.markerB ? new Vector3D(this.markerB.x, this.markerB.y, 0, this.markerB.rotationZ) : DEFAULT_TARGET_CURSOR_B;
			this.updateCursor(this.cursorA, this.tgt_cursorA);
			this.updateCursor(this.cursorB, this.tgt_cursorB);
		}
		
		private function updateCursor (cursor:Sprite, cursorTgt:Vector3D) :void {
			cursor.x += CURSOR_EASE_SPEED * (cursorTgt.x - cursor.x);
			cursor.y += CURSOR_EASE_SPEED * (cursorTgt.y - cursor.y);
			
			var currRot:Number = cursor.rotation % 360;
			if (currRot < 0) { currRot += 360; }
			var tgtRot:Number = cursorTgt.w % 360;
			if (tgtRot < 0) { tgtRot += 360; }
//			cursor.rotation = cursor.rotation + CURSOR_EASE_SPEED * (tgtRot - currRot);
		}
		
		private function stroke () :void {
			if (!this.markerA || !this.markerB) { return; }
			
			var velA:Number = this.markerA.velocity.x;
			var velB:Number = this.markerB.velocity.x;
			if (Math.abs(velA) < MIN_STROKE_STRENGTH || Math.abs(velB) < MIN_STROKE_STRENGTH) { return; }
			
			trace("velA:"+velA+"; velB:"+velB);
			var strokeStrength:Number = STROKE_STRENGTH_MOD * Math.abs(velA - velB);
			trace("stroke:"+strokeStrength);
			this.targetZ -= strokeStrength;
		}
		
		private function testStroke (evt:MouseEvent) :void {
			this.targetZ -= 100;
		}
	}
}