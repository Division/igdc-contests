package decorator {
	import flash.display.DisplayObject;

	/**
	 * Базовый декоратор
	 * @author Division
	 */
	public class Decorator {
		
		/**
		 * Имя декоратора
		 */
		protected var _id : String;
		
		/**
		 * Ссылка на предыдущий декоратор
		 */
		private var _prevDecorator : Decorator = null;
		
		private var _listeners : Array/*ListenerRec*/;
		
		/**
		 * Объект-хозяин
		 */
		private var _owner : Decoratable;

		/**
		 * Данные, переданные для загрузки
		 */
		public var config : *;
		
		/**
		 * Если true, то к объекту может быть добавлен только один декоратор такого типа
		 */
		private var _unique : Boolean = true;
		
		/**
		 * В конструктор передаём id декоратора
		 */
		public function Decorator(name : String, unique : Boolean = true) : void {
			id = name;
			_listeners = new Array();
			_unique = unique;
		}
		
		/**
		 * Уничтожение данных декоратора
		 */
		public function doDestroy() : void {
			if (prevDecorator != null) {
				prevDecorator.doDestroy();
				prevDecorator = null;
			}
			removeEventListeners();
			destroy();
			_prevDecorator = null;
			_owner = null;
			_listeners = null;
		}
		
		protected function addCallback(type : String, listener : Function) : void {
			if (!owner) return;
			owner.addEventListener(type, listener);
			_listeners.push(new ListenerRec(type, listener));
		}
		
		public function removeCallback(type : String, listener : Function) : void {
			if (!owner) return;
			for (var i:int = 0; i < _listeners.length; i++) {
				if (_listeners[i].listener == listener && _listeners[i].type == type) {
					_listeners[i] = _listeners[_listeners.length - 1];
					_listeners.pop();
					owner.removeEventListener(type, listener);
					return;
				}
			}
		}
		
		protected function removeEventListeners() : void {
			if (!owner) return;
			for (var i:int = 0; i < _listeners.length; i++) {
				owner.removeEventListener(_listeners[i].type, _listeners[i].listener);
				_listeners[i].clear();
			}
			_listeners = new Array();
		}
		
		protected function destroy() : void {
			
		}
		
		/**
		 * Обработка события
		 */
		protected function onEvent(e : DecorEvent) : void {
			
		}
		
		/**
		 * Инициализация (вида/позиции/чего угодно)
		 * Подписка на события
		 */
		public function init() : void {
			
		}
		
		public function get owner():Decoratable { return _owner; }
		
		public function setOwner(value:Decoratable):void {
			_owner = value;
		}
		
		public function get prevDecorator():Decorator { return _prevDecorator; }
		
		public function set prevDecorator(value:Decorator):void {
			_prevDecorator = value;
		}
		
		public function get id():String { return _id; }
		
		public function set id(value:String):void {
			_id = value;
		}
		
		public function get unique():Boolean { return _unique; }
		
		/**
		 * Сохранение данных декоратора
		 */
		public function serialize() : * {
			return "";
		}
		
		/**
		 * Загрузка декоратора по некоторым параметрам
		 */
		public function deserialize(data : *) : void {
			
		}
		
		/**
		 * Поиск откликаемся, если ищут нас, иначе передать дальше по цепочке
		 */
		final public function searchDecorator(id : String) : Decorator {
			if (id == this._id) {
				return this;
			}
			if (_prevDecorator != null) {
				return _prevDecorator.searchDecorator(id);
			}
			return null;
		}
		
	}

}