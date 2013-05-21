package video 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.text.TextField;
	
	public class LiveCamera extends Sprite
	{
		private var _camera:Camera;
		private var _video:Video;
		private var _bmp:Bitmap;
		private var _bmd:BitmapData;
		private var _trackedcolor:uint;
		private var _brightestColor:uint;
		private var _pos:Point;
		private var _circle:Sprite;
		private var _blurFilter:BlurFilter;
		
		private var _width:int;
		private var _height:int;
		
		private var blurred:Boolean;
		private var tinted:Boolean;
		private var _ct:ColorTransform;
		private var _red:Number;
		private var _green:Number;
		private var _blue:Number;
		private var _noir:Boolean;
		private var _twotone:Boolean;
		private var _inverted:Boolean;
		private var _glyphed:Boolean;;
		private var _dark:uint;
		private var _light:uint;
		private var _bluramount:int;
		private var _blurquality:int;
		
		public function LiveCamera(width:int,height:int,colorToTrack:uint=0xffffff,treshold:Number=10) 
		{	
			
			_width = width;
			_height = height;
			
			_pos = new Point(0, 0);
			
			_circle = new Sprite();
		
			_trackedcolor = uint(colorToTrack);		//cast it to int
			_video = new Video(_width, _height);
			_camera = Camera.getCamera();
			_camera.setMode(_width, _height, 30);
			_video.attachCamera(_camera);
			_video.smoothing = true;
			
			_bmd = new BitmapData(_width, _height, true, 0xffffff);
			_bmp = new Bitmap(_bmd);
			addChild(_bmp);
			
			addChild(_circle);
			
			addEventListener(MouseEvent.CLICK, onClick);
			addEventListener(Event.ENTER_FRAME, update);

		}
		
		private function onClick(e:MouseEvent):void
		{
			_trackedcolor = (_bmd.getPixel(stage.mouseX, stage.mouseY));
			//_pos.x = stage.mouseX;
			//_pos.y = stage.mouseY;
			drawCircle();
		}
		
		private function drawCircle():void
		{	
			_circle.graphics.clear();
			_circle.graphics.beginFill(_trackedcolor,1);
			_circle.graphics.drawCircle(_pos.x, _pos.y, 4);
			_circle.graphics.endFill();
		}
		
		public function noir():void {
			
			_noir = true;

		}
		
		public function unnoir():void {
			
			_noir = false;
			
		}
		
		private function update(e:Event):void 
		{
			
			renderCam();
			
			if (_glyphed) {
				putChars();
			}
			
			if (_twotone) {
				twotoneVid();
			}
			if (_inverted) {
				invertVideo();
			}
			
			if(blurred){
				_bmd.applyFilter(_bmd, new Rectangle(0, 0, _width, _height), new Point(0, 0), _blurFilter);
			}
			if (tinted) {
				_bmd.colorTransform(new Rectangle(0, 0, _width, _height), _ct);
			}
			if (_noir) {
				_bmd.applyFilter(_bmd, _bmd.rect, new Point(), new ColorMatrixFilter([1/3, 1/3, 1/3, 0, 0,1/3, 1/3, 1/3, 0, 0, 1/3, 1/3, 1/3, 0, 0, 0, 0, 0, 1, 0]));
			}
			
			getColor();
			//trace(_bmd.getPixel(stage.mouseX, stage.mouseY));
		}
		
		private function invertVideo():void
		{
			for (var i = 0; i <= _bmd.width; i++) {
				for (var j = 0; j <= _bmd.height; j++) {
					_bmd.setPixel(i, j, 0x000000 - _bmd.getPixel(i, j));
				}
			}
		}
		
		private function putChars():void {
			
			var sharp:TextField = new TextField();
			var o:TextField = new TextField();
			sharp.text = "X";
			o.text = "O";
			
			for (var i = 0; i <= _bmd.width; i++) {
				for (var j = 0; j <= _bmd.height; j++) {
					
					if (_bmd.getPixel(i, j) > 0x888888) {
						addChild(sharp);
						sharp.x = i;
						sharp.y = j;
					}else {
						addChild(o);
						o.x = i;
						o.y = j;
					}
					
				}
			}	
			
			
			
		}
		
		private function twotoneVid():void
		{
			for (var i = 0; i <= _bmd.width; i++) {
				for (var j = 0; j <= _bmd.height; j++) {
					if (_bmd.getPixel(i, j) > 0x888888) {
						_bmd.setPixel(i, j, _light);
					}else {
						_bmd.setPixel(i, j, _dark);
					}
				}
			}
		}
		
		public function tint(red:uint,green:uint,blue:uint):void {
			
			_red = red;
			_green = green;
			_blue = blue;
			
			_ct = new ColorTransform(_red, _green, _blue);
					
			tinted = true;
			
		}
		
		public function untint():void 
		{
			tinted = false;
		}
		
		public function blur(bluramount:int=6, blurquality:int=2):void {
			
			_bluramount = bluramount;
			_blurquality = blurquality;
			
			_blurFilter = new BlurFilter();
			_blurFilter.blurX = _bluramount;
			_blurFilter.blurY = _bluramount;
			_blurFilter.quality = _blurquality;
			
			
			blurred = true;
			
		}
		
		public function unblur():void 
		{
			blurred = false;
		}
		
		private function  renderCam():void 
		{
			_bmd.draw(_video);
		}
		//COLOR TRACKING
		private function getColor():void
		{
			trace(_trackedcolor);
			for (var i = 0; i < 320; i++) {
				for (var j = 0; j < 240; j++) {
					if (_bmd.getPixel(i, j) <= _trackedcolor+6400 && _bmd.getPixel(i,j)>=_trackedcolor-6400 ) {
						_circle.x = i;
						_circle.y = j;
					}
				}
			}
			
		}
		
		public function doTwotone(dark:uint = 0x222222, light:uint = 0xeeeeee):void {
			_dark = dark;
			_light = light;
			
			_twotone = true;
		}
		
		public function unTwotone():void {
			_twotone = false;
		}
		
		public function invert():void {
			_inverted = true;
		}
		
		public function uninvert():void {
			_inverted = false;
		}
		
		public function glyphIt():void {
			_glyphed = true;
		}
		
	}

}