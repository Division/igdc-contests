package decorator {
	
	/**
	 * Фабрика декораторов
	 * @author Division
	 */
	public class DecorFactory{
		
		private static var _instance : DecorFactory = null;
		
		/**
		 * Классы декораторов
		 */
		private var _decorators : Object;
		
		public function DecorFactory() {
			_decorators = new Object();
			if (_instance != null) {
				throw new Error("Невозможно создать больше одного экземпляра DecorFactory");
			}
		}
		
		public static function get instance() : DecorFactory {
			if (_instance == null) {
				_instance = new DecorFactory();
			}
			return _instance;
		}
		
		/**
		 * Регистрация декоратора в фабрике
		 */
		public function registerDecorator(name : String, classObj : Class) : void {
			var d : * = new classObj();
			if (!(d is Decorator)) throw new Error("Неверный класс декоратора");
			d = null;
			_decorators[name] = classObj;
		}
		
		/**
		 * Получение объекта декоратора по его имени
		 */
		public function getDecorator(name : String) : Decorator {
			if (_decorators[name]) {
				var d : Decorator = new _decorators[name]();
				return d;
			}
			return null;
		}
		
	}

}