package examples 
{
	/**
	 * ...
	 * @author heru
	 */
	public class posisiKursor 
	{
		public static var letakkursorX:Number;
		public static var letakkursorY:Number;
		
		public function posisiKursor(Xposisi:Number,Yposisi:Number) 
		{
			letakkursorX = Xposisi;
			letakkursorY = Yposisi;
			MultiMarkerMultiCollada.Panah.x = letakkursorX;
			MultiMarkerMultiCollada.Panah.y = letakkursorY;
		}
		
	}

}