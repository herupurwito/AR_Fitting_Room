package examples {
	import flash.display.Loader;
	import flash.geom.Matrix;
	import flash.media.Camera;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import examples.video.ColorTracker
	
	import flash.display.Graphics;
	import flash.events.MouseEvent;
	
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.utils.Cast;
	import away3d.events.Loader3DEvent;
	import away3d.lights.DirectionalLight3D;
	import away3d.loaders.AbstractParser;
	import away3d.loaders.Collada;
	import away3d.loaders.Loader3D;
	import away3d.loaders.utils.AnimationLibrary;
	import away3d.materials.BitmapMaterial;
	import flash.events.TimerEvent;
	import flash.media.Video;
	import flash.utils.Timer;
	
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.camera.FLARCamera_Away3D;
	import com.transmote.flar.camera.FLARCamera_PV3D;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.marker.FLARMarkerEvent;
	import com.transmote.flar.tracker.FLARToolkitManager;
	import com.transmote.flar.utils.geom.AwayGeomUtils;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	
	public class MultiMarkerMultiCollada extends Sprite {
		private var flarManager:FLARManager;
		
		
		
		private var view:View3D;
		private var camera3D:FLARCamera_Away3D;
		private var scene3D:Scene3D;
		private var light:DirectionalLight3D;
		
		private var markerBaju:FLARMarker;
		
		private var modelLoader:Loader3D;
		
		private var ModelContainerBaju1:ObjectContainer3D;
		private var ModelContainerBaju2:ObjectContainer3D;
		private var ModelContainerTopi1:ObjectContainer3D;
		
		private var lebar:Number = 320;
		private var tinggi:Number = 240;
		
		private var ZoomInButton:Loader; 
		private var ZoomOutButton:Loader; 
		private var NextButton:Loader; 
		private var PreviousButton:Loader; 
		private var bgButton:Loader; 
		public static var Panah:Loader; 
		
		private var _cam:ColorTracker;
		private var noUrut:Number = 0;
		private var noMarker:Number = 0;
		private var jumlahModel:Number = 2;
		// texture file for baju
		[Embed(source="../../resources/assets/jersey.png")]
		private var TextureBaju1:Class;
		
		[Embed(source="../../resources/assets/polisi.png")]
		private var TextureBaju2:Class;
		
		//texture topi
		[Embed(source="../../resources/assets/topipolisi.png")]
		private var TextureTopi1:Class;
		
		// collada file for baju
		[Embed(source="../../resources/assets/master.DAE",mimeType="application/octet-stream")]
		private var BajuDae:Class;
		
		// collada file for topi
		[Embed(source="../../resources/assets/topi.DAE",mimeType="application/octet-stream")]
		private var TopiDae:Class;
		
		public function MultiMarkerMultiCollada () {
		
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAdded);
			
			ZoomInButton = new Loader();
			ZoomInButton.load(new URLRequest("../resources/button/zoomin.jpg"));
			ZoomInButton.x = 280; ZoomInButton.y = 120;
			
			ZoomOutButton = new Loader();
			ZoomOutButton.load(new URLRequest("../resources/button/zoomout.jpg"));
			ZoomOutButton.x = 280; ZoomOutButton.y = 150;
			
			NextButton = new Loader();
			NextButton.load(new URLRequest("../resources/button/next.png"));
			NextButton.x = 280; NextButton.y = 90;
			
			
			PreviousButton = new Loader();
			PreviousButton.load(new URLRequest("../resources/button/previous.png"));
			PreviousButton.x = 280; PreviousButton.y = 60;
			
			bgButton = new Loader();
			bgButton.load(new URLRequest("../resources/button/bg.png"));
			bgButton.x = 270; bgButton.y = 50;
			bgButton.scaleX = 2.7;
			bgButton.scaleY = 8;
			
			Panah = new Loader();
			Panah.load(new URLRequest("../resources/button/arrow.png"));
			Panah.scaleX = 0.08;
			Panah.scaleY = 0.08;
			
			Panah.addEventListener(Event.ENTER_FRAME, check);
		}
		
		
		private function onAdded (evt:Event) :void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAdded);
			
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FLARToolkitManager(), this.stage);
			
			this.addChild(Sprite(this.flarManager.flarSource));
			
			// begin listening for FLARMarkerEvents.
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_ADDED, this.onMarkerAdded);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_UPDATED, this.onMarkerUpdated);
			this.flarManager.addEventListener(FLARMarkerEvent.MARKER_REMOVED, this.onMarkerRemoved);
			
			// wait for FLARManager to initialize before setting up Away3D environment.
			this.flarManager.addEventListener(Event.INIT, this.onFlarManagerInited);
			
		}
		
		private function onFlarManagerInited (evt:Event) :void {
			
			this.flarManager.removeEventListener(Event.INIT, this.onFlarManagerInited);
			
			this.scene3D = new Scene3D();
			this.camera3D = new FLARCamera_Away3D(this.flarManager, new Rectangle(0, 0, this.stage.stageWidth, this.stage.stageHeight));
			this.view = new View3D({x:0.5*this.stage.stageWidth, y:0.5*this.stage.stageHeight, scene:this.scene3D, camera:this.camera3D});
			
			this._cam = new ColorTracker(320, 240, 0xffffff, 10);
			
			//mirror
			var lebar:int = _cam.width;
			var ma:Matrix=new Matrix();
			ma.a=-1;
			ma.tx = lebar;
			this._cam.transform.matrix = ma; 
			_cam.x -= 12;
			this.addChild(this._cam);
			
			this.addChild(this.view);
			
			this.addChild(bgButton);
			this.addChild(NextButton);
			this.addChild(PreviousButton);
			this.addChild(ZoomInButton);
			this.addChild(ZoomOutButton);
			
			this.addChild(Panah);
			
			this.light = new DirectionalLight3D();
			this.light.direction = new Vector3D(500, -300, 200);
			this.scene3D.addLight(light);
			
			//--------------------------------------3D-Model baju 1----
			var colladaBaju1:Collada = new Collada();
			var ModelBaju1:ObjectContainer3D = colladaBaju1.parseGeometry(BajuDae) as ObjectContainer3D;
			ModelBaju1.materialLibrary.getMaterial("ColorEffectR177G28B149-material").material = new BitmapMaterial(Cast.bitmap(TextureBaju1));
			ModelBaju1.mouseEnabled = false;
			ModelBaju1.rotationZ = 180;

			
			// create a container for the model, that will accept matrix transformations.
			this.ModelContainerBaju1 = new ObjectContainer3D();
			this.ModelContainerBaju1.addChild(ModelBaju1);
			this.ModelContainerBaju1.visible = false;
			this.scene3D.addChild(this.ModelContainerBaju1);
			
			//--------------------------------------3D-Model baju 2----
			var colladaBaju2:Collada = new Collada();
			var ModelBaju2:ObjectContainer3D = colladaBaju2.parseGeometry(BajuDae) as ObjectContainer3D;
			ModelBaju2.materialLibrary.getMaterial("ColorEffectR177G28B149-material").material = new BitmapMaterial(Cast.bitmap(TextureBaju2));
			ModelBaju2.mouseEnabled = false;
			ModelBaju2.rotationZ = 180;
			
			// create a container for the model, that will accept matrix transformations.
			this.ModelContainerBaju2 = new ObjectContainer3D();
			this.ModelContainerBaju2.addChild(ModelBaju2);
			this.ModelContainerBaju2.visible = false;
			this.scene3D.addChild(this.ModelContainerBaju2);
			
			//--------------------------------------3D-Model topi 1----
			var ColladaTopi1:Collada = new Collada();
			ColladaTopi1.scaling = 0.6;
			var ModelTopi1:ObjectContainer3D = ColladaTopi1.parseGeometry(TopiDae) as ObjectContainer3D;
			ModelTopi1.materialLibrary.getMaterial("ColorEffectR177G28B149-material").material = new BitmapMaterial(Cast.bitmap(TextureTopi1));
			ModelTopi1.mouseEnabled = false;
			ModelTopi1.rotationZ = 180;
			ModelTopi1.y = -40;
			
			// create a container for the model, that will accept matrix transformations.
			this.ModelContainerTopi1 = new ObjectContainer3D();
			this.ModelContainerTopi1.addChild(ModelTopi1);
			this.ModelContainerTopi1.visible = false;
			this.scene3D.addChild(this.ModelContainerTopi1);
			
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			trace("[" + evt.marker.patternId + "] added");
			markerAdded(noMarker);
			this.markerBaju = evt.marker;
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			trace("[" + evt.marker.patternId + "] updated");
			markerAdded(noMarker);
			this.markerBaju = evt.marker;
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			trace("[" + evt.marker.patternId + "] removed");
			markerRemoved(noMarker);
			this.markerBaju = null;
		}
		
		public const delayInSeconds:Number = 0.5;
		public const repetitions:int = 100;
		public var angka:Number = 1;
		public var timer:Timer = new Timer(delayInSeconds * 1000, repetitions);
		public var timer2:Timer = new Timer(delayInSeconds * 1000, repetitions);
		public var timer3:Timer = new Timer(0.1 * 1000, 2);
		public var timer4:Timer = new Timer(0.1 * 1000, 2);
		
		//aksi tombol zoomin dengan color tracking
		private function iniTimer () :void {
			timer.addEventListener(TimerEvent.TIMER, timerTicked);
			timer.start();
			ModelContainerBaju1.scale(angka);
			ModelContainerBaju2.scale(angka);
			ModelContainerTopi1.scale(angka);
		}
		
		private function timerTicked(e:TimerEvent):void	{
			angka += 0.1;
			ModelContainerBaju1.scale(angka);
			ModelContainerBaju2.scale(angka);
			ModelContainerTopi1.scale(angka);
		}
		
		private function timerTicked2(e:TimerEvent):void	{
			angka -= 0.1;
			ModelContainerBaju1.scale(angka);
			ModelContainerBaju2.scale(angka);
			ModelContainerTopi1.scale(angka);
		}
		
		private function timerTicked3(e:TimerEvent):void	{
			noUrut += 1;
			if (noUrut == jumlahModel) {
				noMarker = noUrut - 1;
			} else {
				noMarker = noUrut;
			}
		}
		
		private function timerTicked4(e:TimerEvent):void	{
			noUrut -= 1;
			if (noUrut==-1) {
				noMarker = 0;
			} else {
				noMarker = noUrut;
			}
		}
		
		//event ketika tombol di sentuh
		private function check(e:Event):void {
			
			//over zoomin button
			if (e.target.hitTestObject(ZoomInButton)) {
				timer.addEventListener(TimerEvent.TIMER, timerTicked);
				timer.start();
				ModelContainerBaju1.scale(angka);
				ModelContainerBaju2.scale(angka);
				ModelContainerTopi1.scale(angka);
				ZoomInButton.scaleX = 0.7;
				ZoomInButton.scaleY = 0.7;
			} else {
				timer.stop();
				ZoomInButton.scaleX = 0.5;
				ZoomInButton.scaleY = 0.5;
			}
			
			//over zoomout button
			if (e.target.hitTestObject(ZoomOutButton)) {
				timer2.addEventListener(TimerEvent.TIMER, timerTicked2);
				timer2.start();
				ModelContainerBaju1.scale(angka);
				ModelContainerBaju2.scale(angka);
				ModelContainerTopi1.scale(angka);
				ZoomOutButton.scaleX = 0.7;
				ZoomOutButton.scaleY = 0.7;
			} else {
				timer2.stop();
				ZoomOutButton.scaleX = 0.5;
				ZoomOutButton.scaleY = 0.5;
			}
			
			//over next button
			if (e.target.hitTestObject(NextButton)) {
				if (noUrut>1) {
					timer3.stop();
				} else {
					timer3.addEventListener(TimerEvent.TIMER, timerTicked3);
					timer3.start();
				}
				NextButton.scaleX = 0.4;
				NextButton.scaleY = 0.4;
				
			} else {
				timer3.stop();
				NextButton.scaleX = 0.24;
				NextButton.scaleY = 0.24;
			}
			
			//over previous button
			if (e.target.hitTestObject(PreviousButton)) {
				if (noUrut<0) {
					timer4.stop();
				} else {
					timer4.addEventListener(TimerEvent.TIMER, timerTicked4);
					timer4.start();
				}
				PreviousButton.scaleX = 0.4;
				PreviousButton.scaleY = 0.4;
			} else {
				timer4.stop();
				PreviousButton.scaleX = 0.24;
				PreviousButton.scaleY = 0.24;
			}
		}
		
		private function onEnterFrame (evt:Event) :void {
			if (this.markerBaju) {
				if (noMarker == 0) {
					this.ModelContainerBaju1.transform = AwayGeomUtils.convertMatrixToAwayMatrix(this.markerBaju.transformMatrix);
				} else if (noMarker == 1){
					this.ModelContainerBaju2.transform = AwayGeomUtils.convertMatrixToAwayMatrix(this.markerBaju.transformMatrix);
					this.ModelContainerTopi1.transform = AwayGeomUtils.convertMatrixToAwayMatrix(this.markerBaju.transformMatrix);
				}
			}
			
			iniTimer(); 
			this.view.render();
		}
		
		private function markerAdded(markerId:int):void {
			switch(markerId) {
				case 0: {
					if (ModelContainerBaju1.visible == false) {
						ModelContainerBaju1.visible = true;
						ModelContainerBaju2.visible = false;
						ModelContainerTopi1.visible = false;
						break;
					} else {
						break;
					}
				}
				case 1: {
					if (ModelContainerBaju2.visible == false) {
						ModelContainerBaju2.visible = true;
						ModelContainerTopi1.visible = true;
						ModelContainerBaju1.visible = false;
						break;
					} else {
						break;
					}
				}
				
			}
		}
		
		private function markerRemoved(markerId:int):void {
			switch(markerId) {
				case 0: {
					if (ModelContainerBaju1.visible == true) {
						ModelContainerBaju1.visible = false;
						break;
					} else {
						break;
					}
				}
				case 1: {
					if (ModelContainerBaju2.visible == true) {
						ModelContainerBaju2.visible = false;
						ModelContainerTopi1.visible = false;
						break;
					} else {
						break;
					}
				}
			}
		}
	}
}