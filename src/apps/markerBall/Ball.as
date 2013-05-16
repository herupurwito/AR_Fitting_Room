package apps.markerBall {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Ball extends Sprite {
		public static const BALL_MISSED:String = "ballMissed";
		public static const BALL_SCORED:String = "ballScored";
		
		private var gfx:MovieClip;
		private var _colorId:uint;
		private var _speed:Point;
		private var bounds:Rectangle;
		private var redirected:Boolean = false;
		
		public function Ball (gfx:MovieClip, colorId:uint, speed:Point, bounds:Rectangle) {
			this.gfx = gfx;
			this.addChild(this.gfx);
			
			this._colorId = colorId;
			this._speed = speed;
			this.bounds = bounds;
			
			this.gfx.gotoAndStop(this._colorId + 1);
		}
		
		public function update () :Boolean {
			this.x += this._speed.x;
			this.y += this._speed.y;
			return this.checkForEdges();
		}
		
		public function redirect (ang:Number) :void {
			// bounce only once
			if (this.redirected) { return; }
			this.redirected = true;
			this.alpha = 0.5;
			
			var speedLength:Number = this.speed.length;
			this.speed.x = speedLength * Math.cos(ang);
			this.speed.y = speedLength * Math.sin(ang);
		}
		
		public function kill (bScore:Boolean) :void {
			this.removeChild(this.gfx);
			this.gfx = null;
			this.dispatchEvent(new Event(bScore ? BALL_SCORED : BALL_MISSED));
		}
		
		public function get colorId () :uint {
			return this._colorId;
		}
		
		public function get speed () :Point {
			return this._speed;
		}
		
		private function checkForEdges () :Boolean {
			// returns true if still within edges, else returns false
			if (this.y < this.bounds.top) {
				this.kill(this.colorId == 0);
				return false;
			}
			if (this.x > this.bounds.right) {
				this.kill(this.colorId == 1);
				return false;
			}
			if (this.y > this.bounds.bottom) {
				this.kill(this.colorId == 2);
				return false;
			}
			if (this.x < this.bounds.left) {
				this.kill(this.colorId == 3);
				return false;
			}
			
			return true;
		}
	}
}