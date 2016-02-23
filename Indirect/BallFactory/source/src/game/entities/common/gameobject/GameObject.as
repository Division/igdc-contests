package game.entities.common.gameobject {
	import decorator.Decorator;
	import math.Vector2;
	import physics.Physics;
	
	/**
	 * @author Division
	 */
	public class GameObject extends Decorator {
		
		private var _pos : Vector2;
		
		public static const NAME : String = "GameObject";
		
		private var _objectName : String;
		
		/**
		 * Угол поворота в радианах
		 */
		private var _rotation : Number = 0;
		
		public function GameObject(x : Number = 0, y : Number = 0, objName : String = "", angle : Number = 0) {
			super(NAME);
			_pos = new Vector2(x, y);
			_objectName = objName;
			_rotation = angle;
		}
		
		override public function init() : void {
			owner.x = x * Physics.KOEF;
			owner.y = y * Physics.KOEF;
			addCallback(GameObjectEvent.GET_NAME, getNameHandler);
		}
		
		override public function deserialize(data : *) : void {
			if (data.@x.length()) {
				x = Number(data.@x);
			}
			if (data.@y.length()) {
				y = Number(data.@y);
			}
			if (data.@name.length()) {
				_objectName = data.@name;
			}
			if (data.@rotation.length()) {
				rotation = Number(data.@rotation) * Math.PI / 180;
			}
		}
		
		/**
		 * Запрос имени объекта
		 * Просто записываем своё имя в объект события
		 */
		private function getNameHandler(e : GameObjectEvent):void{
			e.name = _objectName;
		}

		public function set x (x : Number) : void {
			_pos.x = x;
			owner.x = x * Physics.KOEF;
		}
		
		public function get x () : Number {
			return _pos.x;
		}
		
		public function set y (y : Number) : void {
			_pos.y = y;
			owner.y = y * Physics.KOEF;
		}
		
		public function get y () : Number {
			return _pos.y;
		}
		
		public function get objectName():String { return _objectName; }
		
		public function get rotation():Number { return _rotation; }
		
		public function set rotation(value:Number):void {
			_rotation = value;
			owner.rotation = _rotation * 180/Math.PI;
		}
		
		override protected function destroy() : void {
			_pos = null;
		}
		
	}

}