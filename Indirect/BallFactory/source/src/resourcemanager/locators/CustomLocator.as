package resourcemanager.locators {

	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import resourcemanager.locators.ZIPLocatorTextureInit;
	
	/**
	 * @author Division
	 */
	public class CustomLocator extends ZIPLocatorTextureInit{
		
		[Embed("../../resources/resources.zip", mimeType="application/octet-stream")]
		private var _zipData : Class;
		
		private var _loader : Loader;
		
		public function CustomLocator(finishCallback : Function, bd : ByteArray = null) {
			var bd : ByteArray = new _zipData as ByteArray;
			
			super(bd, finishCallback, "default");
		}
		
	}

}