package game.utils.layers {
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	/**
	 * Менеджер слоёв
	 * @author Division
	 */
	public class Layers extends Sprite {
		
		private var _layers : Array = new Array();
		private var _startLayer : Number;
		private var _endLayer : Number;
		
		/**
		 * Нахождение слоя по объекту
		 */
		private var _indexes : Dictionary;
		
		public function Layers(startLayer : Number = -3, endLayer : Number = 3) {
			if (endLayer <= startLayer) {
				throw new Error("Индекс последнего слоя должен быть больше начального");
			}
			_layers = new Array();
			_startLayer = startLayer;
			_endLayer = endLayer;
			
			for (var i:int = _startLayer; i <= _endLayer; i++) {
				_layers[i] = new Sprite();
				super.addChild(_layers[i]);
			}
			_indexes = new Dictionary(true);
		}
		
		/**
		 * Добавление дисплейобжекта на слой
		 */
		public function addChildTo(child : DisplayObject, layer : Number = 0) : void {
			if (layer < _startLayer || layer > _endLayer) {
				throw new Error("Индекс слоя за пределами текущего менеджера слоёв");
			}
			
			// Запоминаем объект и его индекс. Пригодится при удалении.
			_indexes[child] = layer;
			_layers[layer].addChild(child); // child автоматом удалится из предыдущего родителя, если что
		}
		
		/**
		 * Удаление со слоя
		 */
		override public function removeChild(child : DisplayObject) : DisplayObject {
			var ind : * = _indexes[child];
			if (ind != undefined) { // Нашли в библиотеке, всё в порядке, удаляем
				if (_layers[ind].contains(child)) {
					return _layers[ind].removeChild(child);
				} else {
					trace("Объект "+ child +" не найден в спрайте слоя " + ind);
				}
			} else { // хм, не нашли, странно. Ищем по слоям
				trace("Объект "+ child +" не найден в библиотеке слоёв");
				for (var i:int = _startLayer; i <= _endLayer; i++) {
					if (_layers[i].contains(child)) {
						return _layers[i].removeChild(child);
					}
				}
			}
			// Нечерта не нашли
			return child;
		}
		
		public function get endLayer():Number { return _endLayer; }
		
		public function get startLayer():Number { return _startLayer; }
		
	}

}