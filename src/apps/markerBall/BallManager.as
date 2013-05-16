package apps.markerBall {
	import com.transmote.utils.geom.Line;
	import com.transmote.utils.time.Timeout;
	import com.transmote.utils.ui.EmbeddedLibrary;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class BallManager extends Sprite {
		private static const MIN_BASE_DELAY:Number = 500;
		private static const BASE_DELAY_RANGE:Number = 1500;
		private static const MIN_DELAY_RANGE:Number = 500;
		private static const DELAY_RANGE_RANGE:Number = 2000;
		private static const MIN_SPEED:Number = 3;
		private static const SPEED_RANGE_BASE:Number = 2;
		private static const BALL_MARGIN:Number = 50;
		private static const BALL_OFFSET:Number = 10;
		
		private var library:EmbeddedLibrary;
		private var w:Number;
		private var h:Number;
		private var ballBounds:Rectangle;
		
		private var bkgd:MovieClip;
		private var balls:Vector.<Ball>;
		private var nextBallTimeout:Timeout;
		
		private var score:Number = 0;
		private var scoreDisplay:TextField;
		private var scoreSound:Sound;
		private var missSound:Sound;
		
		
		public function BallManager (library:EmbeddedLibrary, width:Number, height:Number) {
			this.library = library;
			this.w = width;
			this.h = height;
			
			this.init();
		}
		
		public function update (cursor:MovieClip, cursorBounds:Rectangle) :void {
			if (!this.balls.length) { return; }
			
			var i:uint = this.balls.length;
			var ball:Ball;
			while (i--) {
				ball = this.balls[i];
				if (ball.update() && cursor.visible) {
					this.checkForCursorCollision(this.balls[i], cursor, cursorBounds);
				}
			}
		}
		
		private function init () :void {
			this.bkgd = this.library.getSymbolInstance("edges");
			this.addChild(this.bkgd);
			this.bkgd.getChildByName("bkgd").alpha = 0.75;
			
			this.balls = new Vector.<Ball>();
			this.ballBounds = new Rectangle(-BALL_OFFSET, -BALL_OFFSET, this.w+2*BALL_OFFSET, this.h+2*BALL_OFFSET);
			
			this.initScoreDisplay();
			this.displayScore();
			
			this.onNewBall();
			
			this.scoreSound = this.library.getSymbolInstance("money.wav") as Sound;
			this.missSound = this.library.getSymbolInstance("buzzer.wav") as Sound;
		}
		
		private function initScoreDisplay () :void {
			this.scoreDisplay = new TextField();
			this.scoreDisplay.defaultTextFormat = new TextFormat("monospace", 20, 0xFFFFFF, true);
			this.scoreDisplay.mouseEnabled = false;
			this.scoreDisplay.selectable = false;
			this.scoreDisplay.autoSize = TextFieldAutoSize.LEFT;
			this.scoreDisplay.x = 20;
			this.scoreDisplay.y = 10;
			this.addChild(this.scoreDisplay);
		}
		
		private function displayScore () :void {
			this.scoreDisplay.text = this.score.toString();
		}
		
		private function onNewBall () :void {
			this.createBall();
			this.nextBallTimeout = new Timeout(this.onNewBall, this.calcBallDelay());
		}
		
		private function createBall () :void {
			var side:uint = Math.floor(Math.random() * 4);
			var speed:Point = new Point();
			var position:Point = new Point();
			var colorIds:Vector.<uint>;
			switch (side) {
				case 0 :
					speed.x = 0;
					speed.y = this.calcBallSpeed();
					position.x = BALL_MARGIN + Math.random() * (this.w - 2*BALL_MARGIN);
					position.y = -BALL_OFFSET;
					colorIds = Vector.<uint>([0, 1, 3]);
					break;
				case 1 :
					speed.x = -this.calcBallSpeed();
					speed.y = 0;
					position.x = this.w + BALL_OFFSET;
					position.y = BALL_MARGIN + Math.random() * (this.h - 2*BALL_MARGIN);
					colorIds = Vector.<uint>([0, 1, 2]);
					break;
				case 2 :
					speed.x = 0;
					speed.y = -this.calcBallSpeed();
					position.x = BALL_MARGIN + Math.random() * (this.w - 2*BALL_MARGIN);
					position.y = this.h + BALL_OFFSET;
					colorIds = Vector.<uint>([1, 2, 3]);
					break;
				case 3 :
					speed.x = this.calcBallSpeed();
					speed.y = 0;
					position.x = -BALL_OFFSET;
					position.y = BALL_MARGIN + Math.random() * (this.h - 2*BALL_MARGIN);
					colorIds = Vector.<uint>([0, 2, 3]);
					break;
			}
			var colorId:uint = colorIds[Math.floor(Math.random()*3)];
			var ball:Ball = new Ball(this.library.getSymbolInstance("ball"), colorId, speed, this.ballBounds);
			ball.x = position.x;
			ball.y = position.y;
			this.balls.push(ball);
			this.addChild(ball);
			ball.addEventListener(Ball.BALL_SCORED, this.onBallKilled, false, 0, true);
			ball.addEventListener(Ball.BALL_MISSED, this.onBallKilled, false, 0, true);
		}
		
		private function onBallKilled (evt:Event) :void {
			var ball:Ball = evt.target as Ball;
			if (!ball) { return; }
			
			ball.removeEventListener(Ball.BALL_SCORED, this.onBallKilled);
			ball.removeEventListener(Ball.BALL_MISSED, this.onBallKilled);
			var i:uint = this.balls.indexOf(ball);
			this.balls.splice(i, 1)[0];
			
			if (evt.type == Ball.BALL_SCORED) {
				this.score ++;
				this.scoreSound.play();
			} else {
				this.score --;
				this.score = Math.max(0, this.score);
				this.missSound.play();
			}
			
			this.displayScore();
		}
		
		private function calcBallSpeed () :Number {
			var baseSpeed:Number = MIN_SPEED + 0.2*this.score;
			var speedRange:Number = Math.pow(SPEED_RANGE_BASE, 0.1*this.score);
			var ballSpeed:Number = baseSpeed + Math.random() * speedRange;
			return ballSpeed;
		}
		
		private function calcBallDelay () :Number {
			var baseDelay:Number = MIN_BASE_DELAY + Math.pow(BASE_DELAY_RANGE, 1/(1 + 0.1*this.score));
			var delayRange:Number = MIN_DELAY_RANGE + DELAY_RANGE_RANGE / (1 + 0.1*this.score);
			var ballDelay:Number = baseDelay + Math.random() * delayRange;
			return ballDelay;
		}
		
		private function checkForCursorCollision (ball:Ball, cursor:MovieClip, cursorBounds:Rectangle) :void {
			var cursorAng:Number = Math.PI * (cursor.rotation / 180);
			var cursorSlope:Number = Math.sin(cursorAng) / Math.cos(cursorAng);
			var perpSlope:Number = -1/cursorSlope;
			
			var cursorLine:Line = new Line(cursor.x, cursor.y, cursor.x+1, cursor.y+cursorSlope);
			var ballLine:Line = new Line(ball.x, ball.y, ball.x+ball.speed.x, ball.y+ball.speed.y);
			var intPt:Point = cursorLine.getIntersection(ballLine);
			
			var ballPt:Point = new Point(ball.x, ball.y);
			var cursorPt:Point = new Point(cursor.x, cursor.y);
			
			// check intPt is within cursor bounds
			if (Point.distance(cursorPt, intPt) > 0.5*cursorBounds.width*cursor.scaleX) { return; }
			
			// check if ball is touching cursor
			if (Point.distance(ballPt, intPt) > 0.5 * (ball.width + cursorBounds.height)) { return; }
			
			var intNormal:Line = new Line(intPt.x, intPt.y, intPt.x+100, intPt.y+100*perpSlope);
			var cursorLineAtBall:Line = new Line(ball.x, ball.y, ball.x+100, ball.y+100*cursorSlope);
			var reflPt:Point = intNormal.getIntersection(cursorLineAtBall);
			var reflX:Number = (ball.x + 2*(reflPt.x-ball.x));
			var reflY:Number = (ball.y + 2*(reflPt.y-ball.y));
			
			var reflAng:Number = Math.atan2(reflY-intPt.y, reflX-intPt.x);
			ball.redirect(reflAng);
		}
	}
}