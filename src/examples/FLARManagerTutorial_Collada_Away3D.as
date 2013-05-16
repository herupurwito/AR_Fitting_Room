package examples {
	import away3d.animators.Animator;
	import away3d.animators.BonesAnimator;
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
	import flash.utils.getTimer;
	
	/**
	 * FLARManager_Tutorial3D demonstrates how to display a Collada-formatted model
	 * using FLARManager, FLARToolkit, and Away3D. 
	 * see the accompanying tutorial writeup here:
	 * http://words.transmote.com/wp/flarmanager/inside-flarmanager/loading-collada-models/
	 * 
	 * the collada model used for this example, mario_testrun.dae, comes from Away3D's examples.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARManagerTutorial_Collada_Away3D extends Sprite {
		private var flarManager:FLARManager;
		
		private var view:View3D;
		private var camera3D:FLARCamera_Away3D;
		private var scene3D:Scene3D;
		private var light:DirectionalLight3D;
		
		private var activeMarker:FLARMarker;
		private var modelLoader:Loader3D;
		private var modelContainer:ObjectContainer3D;
		private var modelAnimator:BonesAnimator;
		
		// texture and collada file for mario
		[Embed(source="../../resources/assets/mario_tex.jpg")]
		private var Charmap:Class;
		[Embed(source="../../resources/assets/mario_testrun.dae",mimeType="application/octet-stream")]
		private var Charmesh:Class;
		
		
		public function FLARManagerTutorial_Collada_Away3D () {
			this.addEventListener(Event.ADDED_TO_STAGE, this.onAdded);
		}
		
		private function onAdded (evt:Event) :void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAdded);
			
			// pass the path to the FLARManager xml config file into the FLARManager constructor.
			// FLARManager creates and uses a FLARCameraSource by default.
			// the image from the first detected camera will be used for marker detection.
			// also pass an IFLARTrackerManager instance to communicate with a tracking library,
			// and a reference to the Stage (required by some trackers).
			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FLARToolkitManager(), this.stage);
			
			// to switch tracking engines, pass a different IFLARTrackerManager into FLARManager.
			// refer to this page for information on using different tracking engines:
			// http://words.transmote.com/wp/inside-flarmanager-tracking-engines/
			//			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FlareManager(), this.stage);
			//			this.flarManager = new FLARManager("../resources/flar/flarConfig.xml", new FlareNFTManager(), this.stage);
			
			// add FLARManager.flarSource to the display list to display the video capture.
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
			this.addChild(this.view);
			
			this.light = new DirectionalLight3D();
			this.light.direction = new Vector3D(500, -300, 200);
			this.scene3D.addLight(light);
			
			var collada:Collada = new Collada();
			collada.scaling = 10;
			var model:ObjectContainer3D = collada.parseGeometry(Charmesh) as ObjectContainer3D;
			model.materialLibrary.getMaterial("FF_FF_FF_mario1").material = new BitmapMaterial(Cast.bitmap(Charmap));
			model.mouseEnabled = false;
			model.rotationX = 90;
			this.modelAnimator = model.animationLibrary.getAnimation("default").animator as BonesAnimator;
			
			// create a container for the model, that will accept matrix transformations.
			this.modelContainer = new ObjectContainer3D();
			this.modelContainer.addChild(model);
			this.modelContainer.visible = false;
			this.scene3D.addChild(this.modelContainer);
			
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function onMarkerAdded (evt:FLARMarkerEvent) :void {
			trace("["+evt.marker.patternId+"] added");
			this.modelContainer.visible = true;
			this.activeMarker = evt.marker;
		}
		
		private function onMarkerUpdated (evt:FLARMarkerEvent) :void {
			//trace("["+evt.marker.patternId+"] updated");
			this.modelContainer.visible = true;
			this.activeMarker = evt.marker;
		}
		
		private function onMarkerRemoved (evt:FLARMarkerEvent) :void {
			trace("["+evt.marker.patternId+"] removed");
			this.modelContainer.visible = false;
			this.activeMarker = null;
		}
		
		private function onEnterFrame (evt:Event) :void {
			// apply the FLARToolkit transformation matrix to the Cube.
			if (this.activeMarker) {
				this.modelContainer.transform = AwayGeomUtils.convertMatrixToAwayMatrix(this.activeMarker.transformMatrix);
			}
			
			// update the animation and Away3D view.
			if (this.modelAnimator) {
				this.modelAnimator.update(getTimer() * .005);
			}
			this.view.render();
		}
	}
}