package game.utils{

	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import math.Vector2;
	
	/**
	 * Данные о нажатых на клавиатуре кнопках / мышке
	 * @author Division
	 */
	public class Input extends EventDispatcher {
		
		private static var _instance : Input = null;
		
		private var _keys : Array;
		private var _mousePos : Vector2;
		private var _mouseDown : Boolean;
		
		public function Input() {
			if (_instance != null) {
				throw new Error("Невозможно создать больше одного экземпляра Input");
			}
			_keys = new Array();
			_mousePos = new Vector2();
		}
		
		/**
		 * Инициализация инпута (добавление слушателей для событий stage)
		 * @param	stage Stage он и есть
		 */
		public function initialize(stage : Stage) : void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		//
		// Обработка событий и отсылка их слушателям
		//
		
		private function mouseUpHandler(e:MouseEvent):void {
			_mouseDown = false;
			dispatchEvent(e);
		}
		
		private function mouseDownHandler(e:MouseEvent):void {
			_mouseDown = true;
			dispatchEvent(e);
		}
		
		private function mouseMoveHandler(e:MouseEvent):void {
			_mousePos.x = e.stageX;
			_mousePos.y = e.stageY;
			dispatchEvent(e);
		}
		
		private function keyUpHandler(e:KeyboardEvent):void {
			setKey(e.keyCode, false);
			dispatchEvent(e);
		}
		
		private function keyDownHandler(e:KeyboardEvent):void {
			setKey(e.keyCode, true);
			dispatchEvent(e);
		}
		
		//
		public static function get instance() : Input {
			if (_instance == null) {
				_instance = new Input();
			}
			return _instance;
		}
		
		/**
		 * Установка состояния для клавиши
		 */
		public function setKey(key : int, enabled : Boolean) : void {
			_keys[key] = enabled;
		}
		
		/**
		 * Получение состояния клавиши
		 */
		public function getKey(key : int) : Boolean {
			return Boolean(_keys[key]);
		}
		
		/**
		 * Получение координат курсора
		 */
		public function get mousePos() : Vector2 { return new Vector2(_mousePos.x,_mousePos.y); }

		/**
		 * Нажата ли кнопка мыши
		 */
		public function get mouseDown():Boolean { return _mouseDown; }
		
	}

}