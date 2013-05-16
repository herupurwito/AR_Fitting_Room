/* 
* PROJECT: FLARManager
* http://transmote.com/flar
* Copyright 2009, Eric Socolofsky
* --------------------------------------------------------------------------------
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or (at your option) any later version.
* 
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* 
* You should have received a copy of the GNU General Public License
* along with this framework; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
* 
* For further information please contact:
*	<eric(at)transmote.com>
*	http://transmote.com/flar
*/
package com.transmote.flar.camera {
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	
	import com.transmote.flar.FLARManager;
	import com.transmote.flar.utils.geom.AwayGeomUtils;
	import com.transmote.flar.utils.geom.FLARGeomUtils;
	
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;

	/**
	 * Extends Away's Camera3D class to set up a scene correctly
	 * for projection of 3D objects transformed by a tracker managed by FLARManager.
	 * 
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class FLARCamera_Away3D extends Camera3D {
		private var flarProjectionMatrix:Matrix3D;
		
		/**
		 * Constructor.
		 * 
		 * @param	flarManager		A reference to the FLARManager instance used by this application.
		 * @param	viewportSize	A Rectangle that describes the viewport size for the application.
		 */
		public function FLARCamera_Away3D (flarManager:FLARManager, viewportSize:Rectangle) {
			super();
			
			switch (flarManager.trackerId) {
				case FLARManager.TRACKER_ID_FLARTOOLKIT :
					this.init_FLARToolkit(flarManager, viewportSize);
					break;
				case FLARManager.TRACKER_ID_FLARE :
					this.init_flare(flarManager, viewportSize);
					break;
			}
			
			this.lens = new PerspectiveLens();
			this.zoom = 0.01 * this.flarProjectionMatrix.rawData[0];
		}
		
		private function init_FLARToolkit (flarManager:FLARManager, viewportSize:Rectangle) :void {
			this.flarProjectionMatrix = flarManager.getProjectionMatrix(FLARManager.FRAMEWORK_ID_AWAY, viewportSize);
		}
		
		private function init_flare (flarManager:FLARManager, viewportSize:Rectangle) :void {
			this.flarProjectionMatrix = flarManager.getProjectionMatrix(FLARManager.FRAMEWORK_ID_AWAY, viewportSize);
		}
	}
}