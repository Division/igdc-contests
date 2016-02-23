package game.camera {
	import decorator.Scene;
	import game.general.Const;
	import math.Vector2;
	import physics.Physics;

	/**
	 * @author Division
	 */
	public class Camera{
		
		private static var _instance : Camera = null;
		
		private var _tmpPos : Vector2;
		private var _pos : Vector2;

		public static function get instance() : Camera {
			if (_instance == null) {
				_instance = new Camera();
			}
			
			return _instance;
		}
		
		public function Camera() {
			_tmpPos = new Vector2();
			_pos = new Vector2();
		}
		
		public function apply() : void {
			Scene.instance.x = -_pos.x * Physics.KOEF + Const.SCREEN_WIDTH  / 2;
			Scene.instance.y = -_pos.y * Physics.KOEF + Const.SCREEN_HEIGHT / 2;
		}
		
		public function get pos():Vector2 {
			_tmpPos.from(_pos);
			return _tmpPos;
		}
		
		public function set pos(value:Vector2):void {
			_pos = value;
		}
		
		public function set x(value:Number):void {
			_pos.x = value;
		}
		
		public function set y(value:Number):void {
			_pos.y = value;
		}
		
		public function get x():Number {
			return _pos.x;
		}
		
		public function get y():Number {
			return _pos.y;
		}
		
	}

}