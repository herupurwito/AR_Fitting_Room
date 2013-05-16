package apps.swimmAR {
	import flash.display.Sprite;
	
	public class Bubble extends Sprite {
		private static const AMP_MIN:Number = 10;
		private static const AMP_RANGE:Number = 30;
		private static const SPD_MIN:Number = 0.01;
		private static const SPD_RANGE:Number = 0.1;
		private static const Y_SPEED_MIN:Number = 1;
		private static const Y_SPEED_RANGE:Number = 3;
		private static const SIZE_MIN:Number = 1;
		private static const SIZE_RANGE:Number = 1.5;
		
		private var gfx:Sprite;
		public var initZ:Number;
		private var sinSpd:Number;
		private var sinCtr:Number;
		private var sinAmp:Number;
		private var ySpeed:Number;
		
		public function Bubble (gfx:Sprite, initZ:Number) {
			this.gfx = gfx;
			this.addChild(gfx);
			this.initZ = initZ;
			this.init();
		}
		
		public function update () :void {
			this.sinCtr += this.sinSpd;
			this.gfx.x = this.sinAmp * Math.sin(this.sinCtr);
			this.y -= this.ySpeed;
		}
		
		private function init () :void {
			this.sinCtr = Math.random() * 2*Math.PI;
			this.sinAmp = AMP_MIN + Math.random() * AMP_RANGE;
			this.sinSpd = SPD_MIN + Math.random() * SPD_RANGE;
			this.ySpeed = Y_SPEED_MIN + Math.random() * Y_SPEED_RANGE;
			this.scaleX = this.scaleY = SIZE_MIN + Math.random()*SIZE_RANGE;
			
			this.update();
		}
	}
}