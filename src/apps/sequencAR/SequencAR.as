package apps.sequencAR {
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.tracker.FLARToolkitManager;
	import com.transmote.utils.ui.EmbeddedLibrary;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	public class SequencAR extends Sprite {
		private static const TICK_TIME:Number = 40;
		private static const MARGIN_X:Number = 40;
		private static const WIDTH:Number = 640 - 2*MARGIN_X;
		private static const HEIGHT:Number = 360;
		
		private var flarManager:FLARManager;
		private var sampleManager:SampleManager;
		private var playheadContainer:Sprite;
		private var playhead:Sprite;
		private var timer:Timer;
		private var tempo:Number = 16;
		
		[Embed('../resources/assets/apps/sequencAR.swf', mimeType='application/octet-stream')]
		private var LibraryClass:Class;
		private var library:EmbeddedLibrary;
		
		public function SequencAR () {
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
			this.initSampleManager();
			this.initPlayhead();
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
			
			this.timer = new Timer(TICK_TIME);
			this.timer.addEventListener(TimerEvent.TIMER, this.onTick);
			this.timer.start();
		}
		
		private function initFLARManager () :void {
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FLARToolkitManager(), this.stage);
			this.addChildAt(Sprite(this.flarManager.flarSource), 0);
			
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
		}
		
		private function initSampleManager () :void {
			this.sampleManager = new SampleManager(this.library, WIDTH, HEIGHT);
			this.addChild(this.sampleManager);
		}
		
		private function initPlayhead () :void {
			this.playheadContainer = new Sprite();
			this.playheadContainer.x = MARGIN_X;
			this.playheadContainer.graphics.beginFill(0xFFFFFF, 0.25);
			this.playheadContainer.graphics.drawRect(0, 0, WIDTH, HEIGHT);
			this.playheadContainer.graphics.lineStyle(2, 0xFFFFFF, 0.75);
			for (var i:int=0; i<5; i++) {
				this.playheadContainer.graphics.moveTo(i*(WIDTH/4), 0);
				this.playheadContainer.graphics.lineTo(i*(WIDTH/4), HEIGHT);
			}
			this.addChild(this.playheadContainer);
			
			this.playhead = new Sprite();
			this.playhead.graphics.lineStyle(2, 0xFFCC00);
			this.playhead.graphics.lineTo(0, HEIGHT);
			
			this.playheadContainer.addChild(this.playhead);
		}
		
		private function onTick (evt:TimerEvent) :void {
			this.playhead.x += this.tempo;
			this.playhead.x %= WIDTH;
			this.sampleManager.update(this.playhead.x, this.tempo);
		}
		
		private function onKeyDown (evt:KeyboardEvent) :void {
			switch (evt.keyCode) {
				case Keyboard.UP :
					this.tempo += 0.5;
					break;
				case Keyboard.DOWN :
					this.tempo -= 0.5;
					break;
			}
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			this.sampleManager.addMarker(evt.marker);
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			this.sampleManager.updateMarker(evt.marker);
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			this.sampleManager.removeMarker(evt.marker);
		}
	}
}