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
 * 
 */
package com.transmote.flar.utils.geom {
	import flash.geom.Matrix3D;
	
	/**
	 * @author	Eric Socolofsky
	 * @url		http://transmote.com/flar
	 */
	public class AwayGeomUtils {
		
		/**
		 * Convert a native flash Matrix3D to an Away3D-formatted Matrix3D.
		 * 
		 * TODO: Not sure why Away3D needs to convert matrices; this is probably a problem somewhere within FLARManager,
		 *		 possibly within FLARCamera_Away3D.
		 *		 For now, using <a href="http://www.miguelmoraleda.com/">Miguel Moraleda</a>'s conversion.  Thanks Miguel!
		 * 
		 * @param	mat			Matrix3D to convert.
		 * @param	bMirror		If <code>true</code>, this method will flip the resultant matrix horizontally (around the y-axis).
		 * @return				Away3D-formatted Matrix3D generated from the Matrix3D.
		 */
		public static function convertMatrixToAwayMatrix (mat:Matrix3D) :Matrix3D {
			var raw:Vector.<Number> = mat.rawData;
			raw[1] = -raw[1];
			raw[4] = -raw[4];
			raw[6] = -raw[6];
			raw[9] = -raw[9];
			raw[13] = -raw[13];
			return new Matrix3D(raw);
		}
		
		/**
		 * Format Away3D matrix (flash.geom.Matrix3D) as a String.
		 * @param	matrix	Matrix3D to return as a String.
		 * @param	sd		number of significant digits to display.
		 */
		public static function dumpMatrix3D (matrix:Matrix3D, sd:int=4) :String {
			var m:Vector.<Number> = matrix.rawData;
			return (m[0].toFixed(sd) +"\u0009"+"\u0009"+ m[1].toFixed(sd) +"\u0009"+"\u0009"+ m[2].toFixed(sd) +"\u0009"+"\u0009"+ m[3].toFixed(sd) +"\n"+
				m[4].toFixed(sd) +"\u0009"+"\u0009"+ m[5].toFixed(sd) +"\u0009"+"\u0009"+ m[6].toFixed(sd) +"\u0009"+"\u0009"+ m[7].toFixed(sd) +"\n"+
				m[8].toFixed(sd) +"\u0009"+"\u0009"+ m[9].toFixed(sd) +"\u0009"+"\u0009"+ m[10].toFixed(sd) +"\u0009"+"\u0009"+ m[11].toFixed(sd) +"\n"+
				m[12].toFixed(sd) +"\u0009"+"\u0009"+ m[13].toFixed(sd) +"\u0009"+"\u0009"+ m[14].toFixed(sd) +"\u0009"+"\u0009"+ m[15].toFixed(sd));
		}
		
		public function AwayGeomUtils () {}
	}
}