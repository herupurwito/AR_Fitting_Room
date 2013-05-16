package examples.support {
	import alternativa.engine3d.containers.DistanceSortContainer;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Object3DContainer;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.primitives.Box;
	
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.camera.FLARCamera_Alternativa3D;
	import com.transmote.flar.marker.FLARMarker;
	import com.transmote.flar.utils.geom.AlternativaGeomUtils;
	
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	/**
	 * standard FLARToolkit Alternativa3D example, with our friends the Cubes.
	 * code is borrowed heavily from Makc the Great:
	 * http://makc3d.wordpress.com/2009/04/16/flartoolkit-and-alternativa3d-anyone/
	 * 
	 * the Alternativa3D platform can be found here:
	 * http://alternativaplatform.com/en/alternativa3d/
	 * please note, usage of the Alternativa3D platform is subject to Alternativa3D's licensing.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class SimpleCubes_Alternativa3D extends Sprite {
		private static const CUBE_SIZE:Number = 40;
		
		private var view:View;
		private var camera3D:FLARCamera_Alternativa3D;
		private var scene3D:Object3DContainer;
		
		private var bMirrorDisplay:Boolean;
		private var markersByPatternId:Vector.<Vector.<FLARMarker>>;	// FLARMarkers, arranged by patternId
		private var activePatternIds:Vector.<int>;						// list of patternIds of active markers
		private var containersByMarker:Dictionary;						// Cube containers, hashed by corresponding FLARMarker
		
		
		public function SimpleCubes_Alternativa3D (flarManager:FLARManager, viewportSize:Rectangle) {
			this.bMirrorDisplay = flarManager.mirrorDisplay;
			
			this.init();
			this.initEnvironment(flarManager, viewportSize);
		}
		
		public function addMarker (marker:FLARMarker) :void {
			this.storeMarker(marker);
			
			// create a new Cube, and place it inside a container (DistanceSortContainer) for manipulation
			var container:DistanceSortContainer = new DistanceSortContainer();
			var cube:Box = new Box(CUBE_SIZE, CUBE_SIZE, CUBE_SIZE);
			cube.z = 0.5 * CUBE_SIZE;
			cube.setMaterialToAllFaces(this.getMaterialByPatternId(marker.patternId));
			container.addChild(cube);
			this.scene3D.addChild(container);
			
			// associate container with corresponding marker
			this.containersByMarker[marker] = container;
		}
		
		public function removeMarker (marker:FLARMarker) :void {
			if (!this.disposeMarker(marker)) { return; }
			
			// find and remove corresponding container
			var container:Object3D = this.containersByMarker[marker];
			if (container) {
				this.scene3D.removeChild(container);
			}
			
			delete this.containersByMarker[marker]
		}
		
		private function init () :void {
			// set up lists (Vectors) of FLARMarkers, arranged by patternId
			this.markersByPatternId = new Vector.<Vector.<FLARMarker>>();
			
			// keep track of active patternIds
			this.activePatternIds = new Vector.<int>();
			
			// prepare hashtable for associating Cube containers with FLARMarkers
			this.containersByMarker = new Dictionary(true);
		}
		
		private function initEnvironment (flarManager:FLARManager, viewportSize:Rectangle) :void {
			this.scene3D = new Object3DContainer;
			this.camera3D = new FLARCamera_Alternativa3D(flarManager, viewportSize);
			this.scene3D.addChild(this.camera3D);
			
			this.view = new View(viewportSize.width, viewportSize.height);
			this.camera3D.view = this.view;
			
			this.addChild(this.view);
			
			this.addEventListener(Event.ENTER_FRAME, this.onEnterFrame);
		}
		
		private function onEnterFrame (evt:Event) :void {
			this.updateCubes();
			this.camera3D.render();
		}
		
		private function updateCubes () :void {
			// update all Cube containers according to the transformation matrix in their associated FLARMarkers
			var i:int = this.activePatternIds.length;
			var markerList:Vector.<FLARMarker>;
			var marker:FLARMarker;
			var container:Object3D;
			var j:int;
			while (i--) {
				markerList = this.markersByPatternId[this.activePatternIds[i]];
				j = markerList.length;
				while (j--) {
					marker = markerList[j];
					container = this.containersByMarker[marker];
					container.matrix = AlternativaGeomUtils.convertMatrixToAlternativaMatrix(marker.transformMatrix, this.bMirrorDisplay);
				}
			}
		}
		
		private function storeMarker (marker:FLARMarker) :void {
			// store newly-detected marker.
			
			var markerList:Vector.<FLARMarker>;
			if (marker.patternId < this.markersByPatternId.length) {
				// check for existing list of markers of this patternId...
				markerList = this.markersByPatternId[marker.patternId];
			} else {
				this.markersByPatternId.length = marker.patternId + 1;
			}
			if (!markerList) {
				// if no existing list, make one and store it...
				markerList = new Vector.<FLARMarker>();
				this.markersByPatternId[marker.patternId] = markerList;
				this.activePatternIds.push(marker.patternId);
			}
			// ...add the new marker to the list.
			markerList.push(marker);
		}
		
		private function disposeMarker (marker:FLARMarker) :Boolean {
			// find and remove marker.
			// returns false if marker's patternId is not currently active.
			
			var markerList:Vector.<FLARMarker>;
			if (marker.patternId < this.markersByPatternId.length) {
				// get list of markers of this patternId
				markerList = this.markersByPatternId[marker.patternId];
			}
			if (!markerList) {
				// patternId is not currently active; something is wrong, so exit.
				return false;
			}
			
			var markerIndex:uint = markerList.indexOf(marker);
			if (markerIndex != -1) {
				markerList.splice(markerIndex, 1);
				if (markerList.length == 0) {
					this.markersByPatternId[marker.patternId] = null;
					var patternIdIndex:int = this.activePatternIds.indexOf(marker.patternId);
					if (patternIdIndex != -1) {
						this.activePatternIds.splice(patternIdIndex, 1);
					}
				}
			}
			
			return true;
		}
		
		private function getMaterialByPatternId (patternId:int) :FillMaterial {
			switch (patternId) {
				case 0:
					return new FillMaterial(0xFF1919, 1, 1, 0x730000);
				case 1:
					return new FillMaterial(0xFF19E8, 1, 1, 0x730067);
				case 2:
					return new FillMaterial(0x9E19FF, 1, 1, 0x420073);
				case 3:
					return new FillMaterial(0x192EFF, 1, 1, 0x000A73);
				case 4:
					return new FillMaterial(0x1996FF, 1, 1, 0x003E73);
				case 5:
					return new FillMaterial(0x19FDFF, 1, 1, 0x007273);
				case 6:
					return new FillMaterial(0x19FF5A, 1, 1, 0x007320);
				case 7:
					return new FillMaterial(0x19FFAA, 1, 1, 0x007348);
				case 8:
					return new FillMaterial(0x6CFF19, 1, 1, 0x297300);
				case 9:
					return new FillMaterial(0xF9FF19, 1, 1, 0x707300);
				case 10:
					return new FillMaterial(0xFFCE19, 1, 1, 0x735A00);
				case 11:
					return new FillMaterial(0xFF9A19, 1, 1, 0x734000);
				case 12:
					return new FillMaterial(0xFF6119, 1, 1, 0x732400);
				default:
					return new FillMaterial(0xCCCCCC, 1, 1, 0x666666);
			}
		}
	}
}