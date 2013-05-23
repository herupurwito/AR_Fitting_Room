package examples.video 
{
	import examples.posisiKursor;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.utils.Timer;
	import examples.loop.Loop
	
	public class ColorTracker extends Sprite
	{
		private var _trackedcolor:uint;
		private var _treshold:uint;
		private var _circle:Sprite;
		private var _tick:Timer;
		private var _pos:Point;
		private var _bmd:BitmapData;
		private var _bmp:Bitmap;
		private var _cam:Camera;
		private var _width:int;
		private var _height:int;
		private var _yposarray:Array;
		private var _xposarray:Array;
		private var _vid:Video;
		private var _loop:Loop;
		private var _avgpos:Point;
		
		public var publicpos:Point;
		public var showcircle:Boolean;
		
		public function ColorTracker(width:int ,height:int, colorToTrack:uint, treshold:uint) 
		{	
			_width = width;
			_height = height;
			_trackedcolor = colorToTrack;
			_treshold = treshold;
			init();
		}
		
		private function init():void
		{	
			publicpos = new Point(0, 0);
			_avgpos = new Point(0, 0);
			_pos = new Point(0, 0);
			
			var index : int = 0;

			for ( var i : int = 0 ; i < Camera.names.length ; i++ ) {
				if ( Camera.names[ i ] == "USB Video Class Video" ){
				index = i;
				}
			}
			
			_cam = Camera.getCamera( String( index ) );
			
			_cam.setMode(_width, _height, 30);
			_vid = new Video(_width, _height);
			
			//_vid.scaleX = -1; 
			//_vid.x += _vid.width;
			
			_vid.attachCamera(_cam);
			_vid.smoothing = true;
			_bmd = new BitmapData(_width, _height);
			_bmp = new Bitmap(_bmd);
			
			//_bmp.scaleX = -1; 
			//_bmp.x += _bmp.width;
			
			
			addChild(_bmp);
			
			_loop = new Loop();
			_loop.addTask(render, "renderID");
			addChild(_loop);
			drawCircle();
				
			_tick = new Timer(1000);
			_tick.addEventListener(TimerEvent.TIMER, average);
			_tick.start();
			
			_xposarray = new Array();
			
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function moveCircle():void {
			
		}
		
		public function average(e:TimerEvent):Point {
			_avgpos = _pos;
			//_circle.x = _avgpos.x;
			//_circle.y = _avgpos.y;
			//trace(_avgpos);
			return _avgpos;
		}
		
		private function onClick(e:MouseEvent):void
		{
			getColorFromMousePos();
		}
		
		private function getColorFromMousePos():void
		{
			_trackedcolor = _bmd.getPixel(_width-(stage.mouseX), stage.mouseY);
			removeChild(_circle);
			drawCircle();
		}
		
		
		private function render():void {
			_circle.x += (_avgpos.x - _circle.x)/10;
			_circle.y += (_avgpos.y - _circle.y)/10;
			trackColor();
			new posisiKursor(_circle.x,_circle.y);
			_bmd.draw(_vid);
			
		}
		
		private function drawCircle():void {
			_circle = new Sprite();
			_circle.graphics.beginFill(_trackedcolor, 1);
			_circle.graphics.drawCircle(0, 0, 12);
			_circle.graphics.endFill();
			_circle.visible = false;
			addChild(_circle);
			
		}
		public function trackColor():Point {
			
			for (var i:Number = 0; i < _width; i++) {
				for (var j:Number = 0; j < _height; j++) {
					if (_bmd.getPixel(i, j) <= _trackedcolor+3200 && _bmd.getPixel(i,j)>=_trackedcolor-3200 ) {
						//_circle.x = i;
						//_circle.y = j;
						_pos.x = i;
						_pos.y = j;
						publicpos = _pos;
					}
				}
			}
			
			return _pos;
		}
	}

}