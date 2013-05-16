package apps.whackAMole {
	import com.transmote.utils.time.Timeout;
	import com.transmote.utils.ui.EmbeddedLibrary;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.media.Sound;
	
	public class Mole extends Sprite {
		private static const MIN_ACTIVATE_TIME:Number = 2000;
		private static const ACTIVATE_TIME_RANGE:Number = 5000;
		private static const MIN_DUCK_TIME:Number = 350;
		private static const DUCK_TIME_RANGE:Number = 1250;
		private static const DOWN_ANIM_TIME:Number = 150;
		private static const HIT_GFX_TIME:Number = 1500;
		
		private var library:EmbeddedLibrary;
		private var gfx:MovieClip;
		private var hitSound:Sound;
		private var hitGfx:MovieClip;
		
		private var bActive:Boolean;
		private var animTimeout:Timeout;
		private var hitTimeout:Timeout;
		
		
		public function Mole (library:EmbeddedLibrary) {
			this.library = library;
			this.init();
		}
		
		public function onHit () :void {
			if (!this.bActive) { return; }
			
			this.hitSound.play();
			this.hitGfx.visible = true;
			this.hitTimeout = new Timeout(this.onHitTimeout, HIT_GFX_TIME);
		}
		
		private function init () :void {
			this.gfx = this.library.getSymbolInstance("mound") as MovieClip;
			this.gfx.scaleX = this.gfx.scaleY = 0.5;
			this.addChild(this.gfx);
			
			this.hitSound = this.library.getSymbolInstance("yell.mp3") as Sound;
			this.hitGfx = this.gfx.getChildByName("pow") as MovieClip;
			this.hitGfx.visible = false;
			
			this.onDownAnimComplete();
		}
		
		private function onDownAnimComplete () :void {
			// "down" animation complete; queue "up" animation
			this.bActive = false;
			this.gfx.gotoAndStop(1);
			this.animTimeout = new Timeout(this.onActivateTimeout, MIN_ACTIVATE_TIME + Math.random()*ACTIVATE_TIME_RANGE);
		}
		
		private function onActivateTimeout () :void {
			// begin "up" animation, queue "down" animation
			this.bActive = true;
			this.gfx.gotoAndPlay("up");
			this.animTimeout = new Timeout(this.onDuckTimeout, MIN_DUCK_TIME + Math.random()*DUCK_TIME_RANGE);
		}
		
		private function onDuckTimeout () :void {
			// begin "down" animation
			this.gfx.gotoAndPlay("down");
			this.animTimeout = new Timeout(this.onDownAnimComplete, DOWN_ANIM_TIME);
		}
		
		private function onHitTimeout () :void {
			this.hitGfx.visible = false;
		}
	}
}