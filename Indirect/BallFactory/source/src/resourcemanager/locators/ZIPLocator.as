package resourcemanager.locators {
	import deng.fzip.FZip;
	import deng.fzip.FZipFile;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import game.utils.geom.GeomAsset;
	import resourcemanager.ResLocator;
	
	/**
	 * Создаёт текстуры из ZIP файла
	 * @author Division
	 */
	public class ZIPLocator extends ResLocator{
		
		protected var _zip : FZip;
		
		/**
		 * @param	data данные ZIP архива
		 * @param	name имя локатора
		 */
		public function ZIPLocator(data : ByteArray, name : String = "default") {
			super(name);
			_zip = new FZip();
			_zip.loadBytes(data);
		}
		
		override protected function processGetTexture(name  :String) : BitmapData {
			throw new Error("ZIPLocator does not supports textures");
			return null;
		}
		
		override protected function processGetResource(name : String) : * {
			var file : FZipFile = _zip.getFileByName(name);
			if (file) {
				return file.content;
			} else {
				trace("Error getting resource '" + name + "'");
				return null;
			}
		}
		
		override protected function processGetGeomAsset(name : String) : GeomAsset {
			var file : FZipFile = _zip.getFileByName(name);
			if (file) {
				var ga : GeomAsset = new GeomAsset();
				if (ga.load(file.content)) {
					return ga;
				} else {
					return null;
				}
			} else {
				trace("Error getting resource '" + name + "'");
				return null;
			}
		}
		
		private function completeHandler(e:Event):void {
			trace("complete");
		}
		
	}

}