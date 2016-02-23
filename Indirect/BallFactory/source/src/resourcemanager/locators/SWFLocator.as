package resourcemanager.locators {
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import resourcemanager.ResLocator;
	
	/**
	 * @author Division
	 */
	public class SWFLocator extends ResLocator{
		
		private var _loader : Loader;
		
		private var _callback : Function;
		
		public function SWFLocator(data : ByteArray, callback : Function, name : String = "default") {
			super(name);
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			_loader.loadBytes(data, new LoaderContext(false, new ApplicationDomain(ApplicationDomain.currentDomain)));
			_callback = callback;
		}
		
		private function completeHandler(e:Event):void {
			if (_callback != null) {
				_callback.call(null);
			}
		}
		
		override protected function processGetTexture(name : String) : BitmapData {
			name = name.replace('/', '_');
			name = name.replace('\\', "_");
			return new (_loader.contentLoaderInfo.applicationDomain.getDefinition(name) as Class)(0,0) as BitmapData;
		}
		
		override protected function processGetResource(name : String) : * {
			name = name.replace('/', '_');
			name = name.replace('\\', '_');
			return new (_loader.contentLoaderInfo.applicationDomain.getDefinition(name) as Class);
		}
		
	}

}