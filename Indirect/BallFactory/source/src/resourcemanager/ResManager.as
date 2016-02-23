package resourcemanager {
	import flash.display.BitmapData;
	import game.utils.geom.GeomAsset;
	
	/**
	 * Класс, отвечающий за работу с текстурами
	 * Создаёт текстуры по их именам
	 * @author Division
	 */
	public class ResManager {
		
		/**
		 * Объекты, определяющие место хранения текстур и занимающиеся их извлечением и созданием
		 */
		protected var _locators : Object/*TextureLocator*/;
		
		private static var _instance : ResManager = null;
		
		public static function get instance() : ResManager {
			if (_instance == null) {
				_instance = new ResManager();
			}
			
			return _instance;
		}
		
		public function ResManager() {
			_locators = new Object();
		}
		
		/**
		 * Добавление хранилища ресурсов
		 */
		public function addLocator(locator : ResLocator) : void {
			if (_locators[locator.name]) {
				throw new Error("ResLocator '" + locator.name + "' already exists!");
			}
			
			_locators[locator.name] = locator;
		}
		
		/**
		 * Получение текстуры по имени из локатора 'locator'
		 */
		public function GetTexture(name : String, locator : String = "default") : BitmapData {
			if (_locators[locator]) {
				return ResLocator(_locators[locator]).getTexture(name);
			} else {
				throw new Error("ResLocator '" + locator + "' does not exists");
			}
			
			return null;
		}
		
		/**
		 * Получение ресурса из локатора. На выходе может быть что угодно включая исключения
		 */
		public function GetResource(name : String, locator : String = "default") : * {
			if (_locators[locator]) {
				return ResLocator(_locators[locator]).getResource(name);
			} else {
				throw new Error("ResLocator '" + locator + "' does not exists");
			}
			
			return null;
		}
		
		/**
		 * Получение GeomAsset из локатора
		 */
		public function GetGeomAsset(name : String, locator : String = "default") : * {
			if (_locators[locator]) {
				return ResLocator(_locators[locator]).getGeomAsset(name);
			} else {
				throw new Error("ResLocator '" + locator + "' does not exists");
			}
			
			return null;
		}
		
		/**
		 * Получение ресурса из локатора. На выходе может быть что угодно включая исключения
		 */
		public static function getResource(name : String, locator : String = "default") : * {
			return instance.GetResource(name, locator);
		}
		
		/**
		 * Получение текстуры по имени из локатора 'locator'
		 */
		public static function getTexture(name : String, locator : String = "default") : BitmapData {
			return instance.GetTexture(name, locator);
		}
		
		/**
		 * Получение текстуры по имени из локатора 'locator'
		 */
		public static function getGeomAsset(name : String, locator : String = "default") : GeomAsset {
			return instance.GetGeomAsset(name, locator);
		}
		
	}

}