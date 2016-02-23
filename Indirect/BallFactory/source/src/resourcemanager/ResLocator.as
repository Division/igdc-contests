package resourcemanager {
	import flash.display.BitmapData;
	import game.utils.geom.GeomAsset;
	
	/**
	 * Класс, определяющий хранилище текстур
	 * ZIP архивы/swf файлы итд
	 * @author Division
	 */
	public class ResLocator {
		
		public static const DEFAULT : String = "default";
		
		/**
		 * Имя локатора
		 */
		protected var _name : String;
		
		/**
		 * Кеш, чтобы не создавать копию уже созданного ресурса
		 */
		protected var _cache : Object;
		
		public function ResLocator(name : String = DEFAULT) {
			_name = name;
			_cache = new Object();
		}
		
		/**
		 * Получение объекта из кеша
		 */
		protected function getFromCache(name : String) : * {
			if (_cache[name]) {
				return _cache[name];
			} else {
				return null;
			}
		}
		
		/**
		 * Запись объекта в кеш
		 */
		protected function writeToCache(name : String, data : *) : void {
			_cache[name] = data;
		}
		
		/**
		 * Получение текстуры
		 */
		final public function getTexture(name : String) : BitmapData {
			var c : BitmapData;
			c = (getFromCache(name) as BitmapData);
			if (c) {
				return c;
			} else {
				c = processGetTexture(name);
				writeToCache(name, c);
				return c;
			}
		}
		
		/**
		 * Получение набора геометрий
		 */
		final public function getGeomAsset(name : String) : GeomAsset {
			var c : GeomAsset;
			c = (getFromCache(name) as GeomAsset);
			if (c) {
				return c;
			} else {
				c = processGetGeomAsset(name);
				writeToCache(name, c);
				return c;
			}
		}
		
		protected function processGetGeomAsset(name : String) : GeomAsset{
			return null; // abstract
		}
		
		protected function processGetTexture(name : String) : BitmapData {
			return null; // abstract
		}
		
		/**
		 * Получение произвольного ресурса
		 */
		public function getResource(name : String) : * {
			var c : * ;
			c = getFromCache(name);
			if (c) {
				return c;
			} else {
				c = processGetResource(name);
				writeToCache(name, c);
				return c;
			}
		}
		
		protected function processGetResource(name : String) : * {
			return null; // abstract
		}
		
		public function get name() : String {
			return _name;
		}
		
	}

}