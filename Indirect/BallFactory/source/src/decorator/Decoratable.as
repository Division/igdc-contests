package decorator {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import game.events.StateEvent;
	
	/**
	 * Класс на который вешаются декораторы
	 * И нефик от него наследоваться (:
	 * @author Division
	 */
	final public class Decoratable extends Sprite {
		/**
		 * Ссылка на последний декоратор
		 */
		protected var _lastDecorator : Decorator = null;

		protected var _id : String;
		
		/**
		 * Пора умирать. Сцена удалит объект.
		 */
		protected var _timeToDie : Boolean = false;
		
		/**
		 * Объекты которые были добавлены прямиком на слои сцены
		 * Их надо будет удалить оттуда при уничтожении
		 */
		private var _layerObjects : Array/*DisplayObject*/;
		/**
		 * Наследовать ли ориентацию родителя
		 */
		private var _inheritRotation : Array/*Boolean*/;
		
		public function Decoratable() {
			_layerObjects = new Array();
			_inheritRotation = new Array();
			addEventListener(StateEvent.UPDATE, updateHandler, false, -1);
		}
		
		private function updateHandler(e:Event):void {
			var cnt : int = _layerObjects.length;
			for (var i : int = 0; i < cnt; i++) {
				_layerObjects[i].x = x;
				_layerObjects[i].y = y;
				if (_inheritRotation[i]) {
					_layerObjects[i].rotation = rotation;
				}
			}
		}
		
		/**
		 * Добавление дочернего спрайта прямиком на слой в сцене
		 */
		public function addChildToLayer(child : DisplayObject, layer : int = 0, inheritRotation : Boolean = true) : void {
			var tmp : Sprite = new Sprite();
			tmp.addChild(child);
			_layerObjects.push(tmp);
			_inheritRotation.push(inheritRotation);
			tmp.x = x;
			tmp.y = y;
			Scene.instance.layers.addChildTo(tmp, layer);
		}
		
		/**
		 * Удаление спрайта. Спрайт будет удален из слоя сцены, если был добавлен напрямую туда
		 */
		override public function removeChild(child : DisplayObject) : DisplayObject {
			var index : int;
			// Если объект был добавлен прямо в слой сцены, удалим его оттуда
			if ((index = _layerObjects.indexOf(child.parent)) >= 0) {
				// Сохраняем ссылку на родителя (на сцене каждый спрайт помещен в другой спрайт-контейнер)
				var p : DisplayObject = child.parent;
				// Удаляем из родителя наш спрайт. На всякий случай (:
				while ((_layerObjects[index] as DisplayObjectContainer).numChildren) {
					(_layerObjects[index] as DisplayObjectContainer).removeChildAt(0);
				}
				// Укорачиваем массивы
				_layerObjects[index] = _layerObjects[_layerObjects.length - 1];
				_layerObjects.pop();
				_inheritRotation[index] = _inheritRotation[_layerObjects.length - 1];
				_inheritRotation.pop();
				// И удаляем контейнер нашего спрайта
				Scene.instance.layers.removeChild(p);
				return child;
			} else {
				trace("obj not found");
			}
			return super.removeChild(child);
		}

		
		/**
		 * Добавление декоратора
		 */
		public function addDecorator(d : Decorator) : void {			
			if (d == null) return;
			
			// Если декоратор уникальный, ищем декоратор с таким же именем
			if (d.unique) {
				var temp : Decorator = searchDecorator(d.id);
				if (temp != null) return; // Если нашли, то добавлять ничего не нужно
			}
			
			d.prevDecorator = _lastDecorator;
			d.setOwner(this);
			d.init();
			_lastDecorator = d;
		}
		
		/**
		 * Удаление декоратора
		 */
		public function removeDecorator(name : String) : void {
			var ld : Decorator = _lastDecorator;
			var prevD : Decorator = null;
			while (ld != null) {
				if (ld.id == name) {
					if (prevD) {
						prevD.prevDecorator = ld.prevDecorator;
					} else {
						_lastDecorator = ld.prevDecorator;
					}
					ld.prevDecorator = null;
					ld.doDestroy();
					return;
				}
				prevD = ld;
				ld = ld.prevDecorator;
			}
		}
		
		/**
		 * Посылка события по цепочке декораторов
		 */
		public function sendEvent(e : DecorEvent) : void {
			if (e.isAlreadySent) {
				throw new Error("Объект события '" + e.type + "' уже был использован. Создайте новый объект.");
			}
			e.makeAlreadySent();
			dispatchEvent(e);
		}
		
		public function get lastDecorator():Decorator { return _lastDecorator; }
		
		public function get id():String { return _id; }
		
		public function set id(value:String):void {
			_id = value;
		}
		
		public function get timeToDie():Boolean { return _timeToDie; }
		
		/**
		 * Возвращение декоратора по его имени
		 */
		public function searchDecorator(id : String) : Decorator {
			if (_lastDecorator == null) {
				return null;
			}
			return _lastDecorator.searchDecorator(id);
		}
		
		/**
		 * Сохранение данных объекта
		 */
		public function serialize() : * {
			return "";
		}
		
		/**
		 * Загрузка
		 */
		public function deserialize(data : *) : void {
			
		}
		
		/**
		 * Уничтожение объекта
		 */
		public function destroy():void {
			if (_lastDecorator != null){
				_lastDecorator.doDestroy();
			}
			_lastDecorator = null;
			for (var i : int = 0; i < _layerObjects.length; i++) {
				Scene.instance.layers.removeChild(_layerObjects[i]);
			}
			_layerObjects = null;
			_inheritRotation = null;
		}
		
		/**
		 * Пометить на удаление
		 */
		public function die() : void {
			_timeToDie = true;
		}
		
		// Перегружаем чтобы автоматически делать слабые ссылки
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void {
			super.addEventListener(type, listener, false, priority, true);
		}
		
	}

}