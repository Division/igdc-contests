package resourcemanager.locators {
	import deng.fzip.FZipLibrary;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.ByteArray;
	import resourcemanager.locators.ZIPLocator;
	
	/**
	 * @author Division
	 */
	public class ZIPLocatorTextureInit extends ZIPLocator {
		
		private var _finishCallback : Function;
		
		private var _lib : FZipLibrary;
		
		public function ZIPLocatorTextureInit(data : ByteArray, finishCallback : Function, name : String = "default") {
			super(data, name);
			_finishCallback = finishCallback;
			_lib = new FZipLibrary();
			_lib.formatAsBitmapData(".gif");
			_lib.formatAsBitmapData(".jpg");
			_lib.formatAsBitmapData(".png");
			_lib.addZip(_zip);
			_lib.addEventListener(Event.COMPLETE, completeHandler);
		}
		
		private function completeHandler(e:Event):void {
			if (_finishCallback != null) {
				_finishCallback.call(null);
			}
		}
		
		override protected function processGetTexture(name : String) : BitmapData {
			return _lib.getBitmapData(name);
		}
		
	}

}