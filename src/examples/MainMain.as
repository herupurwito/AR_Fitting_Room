package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import loop.Loop;
	import shapes.SimpleBezier;
	import shapes.SimpleCircle;
	import shapes.SimpleRectangle;
	import shapes.SimpleRoundedRectangle;
	import shapes.SimpleStar;
	import sound.LiveSound;
	import systems.GridMaker;
	import typography.TypeBox;
	import video.LiveCamera;
	
	public class MainMain extends Sprite
	{	
		
		private var _attx:Number;
		private var _atty:Number;
		private var mic:LiveSound;
		private var rect:SimpleRectangle;
		
		public function MainMain() 
		{
			var tb:TypeBox = new TypeBox(20, 20, 400, 200);
			addChild(tb);
		}
		
	
		private function drawCurves():void
		{		
			
			for (var i:Number = 0; i < 40; i++) {
				for (var j:Number = 0; j < 40; j++) {
					_attx=Math.random() * 450;
					_atty = Math.random() * 450;
					
					var curve:SimpleBezier = new SimpleBezier(225, 225,  _attx,_atty,
					 Math.random() * 450, Math.random() * 450, 0x222222, 1, .2);
					addChild(curve);
				}
			}
		}
		
	}

}