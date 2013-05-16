package apps.swimmAR {
	import com.transmote.utils.ui.EmbeddedLibrary;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class SceneryManager extends Sprite {
		private static const BUBBLE_SPAWN_TIME_MIN:uint = 5;
		private static const BUBBLE_SPAWN_TIME_RANGE:uint = 20;
		private static const BUBBLE_SPAWN_MARGIN_X:Number = 200;
		private static const BUBBLE_INIT_Z:Number = 400;
		private static const DZ_KILL:Number = 400 + BUBBLE_INIT_Z;
		
		private var library:EmbeddedLibrary;
		private var bubbles:Vector.<Bubble>;
		private var kelp:Vector.<Sprite>;
		
		private var bubbleSpawnCtr:uint;
		private var bubbleSpawnTime:uint;
		
		public function SceneryManager (library:EmbeddedLibrary) {
			this.library = library;
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAdded);
		}
		
		private function onAdded (evt:Event) :void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAdded);
			this.initScenery();
		}
		
		public function update () :void {
			var i:uint = this.bubbles.length;
			var bubble:Bubble;
			while (i--) {
				bubble = this.bubbles[i];
				bubble.update();
				if (Math.abs(this.z - bubble.initZ) > DZ_KILL) {
					this.bubbles.splice(i, 1);
					this.removeChild(bubble);
				}
			}
			
			this.bubbleSpawnCtr ++;
			if (this.bubbleSpawnCtr >= this.bubbleSpawnTime) {
				this.spawnBubble();
			}
		}
		
		private function initScenery () :void {
			this.bubbles = new Vector.<Bubble>();
			this.kelp = new Vector.<Sprite>();
			
			this.spawnBubble();
		}
		
		private function spawnBubble () :void {
			var bubble:Bubble = new Bubble(this.library.getSymbolInstance("bubble"), this.z);
			bubble.x = BUBBLE_SPAWN_MARGIN_X + Math.random() * this.stage.stageWidth - 2*BUBBLE_SPAWN_MARGIN_X;
			bubble.y = this.stage.stageHeight + 200;
			bubble.z = -this.z + BUBBLE_INIT_Z;
			this.addChild(bubble);
			this.bubbles.push(bubble);
			
			this.bubbleSpawnTime = Math.floor(BUBBLE_SPAWN_TIME_MIN * Math.random()*BUBBLE_SPAWN_TIME_RANGE);
			this.bubbleSpawnCtr	= 0;
		}
	}
}