package actions.init {
	import actionqueue.ActionBase;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import resourcemanager.locators.CustomLocator;
	import resourcemanager.ResManager;
	
	/**
	 * Инициализация менеджера ресурсов
	 * @author Division
	 */
	public class InitResourcesAction extends ActionBase{
		
		private var _loader : URLLoader;
		
		override protected function processAction(params : Object) : void {
			processMore();
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(Event.COMPLETE, onComplete);
			//_loader.load(new URLRequest("resources.zip"));
			
			ResManager.instance.addLocator(new CustomLocator(initFinish));
		}
		
		private function onComplete(e:Event):void {
			//ResManager.instance.addLocator(new CustomLocator(initFinish, _loader.data as ByteArray));
		}
		
		private function initFinish():void {
			finish();
		}
		
	}

}