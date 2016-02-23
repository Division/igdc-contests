package game.entities.common.itemview {
	import decorator.Decorator;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import game.events.StateEvent;
	import game.general.GameController;
	
	/**
	 * Визуальное отображение детали
	 * @author Division
	 */
	public class ItemView extends Decorator{
		
		public static const NAME : String = "ItemView";
		
		private var _visual : Sprite;
		
		private var _objectToDisplay : DisplayObject;
		
		private var _layer : int = 0;
		private var _inheritRotation : Boolean = true;
		
		private var _x : Number = 0;
		private var _y : Number = 0;
		private var _rotation : Number = 0;
		
		public function ItemView() {
			super(NAME, false);
			_visual = new Sprite();
			_visual.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
		}
		
		private function mouseDownHandler(e:MouseEvent):void {
			GameController.instance.itemMouseDown(owner);
		}
		
		override public function init() : void {
			addCallback(StateEvent.INIT, initHandler);
		}
		
		public function setDisplayObject(obj : DisplayObject) : void {
			if (!obj) return;
			
			if (obj is Bitmap) {
				(obj as Bitmap).smoothing = true;
			}
			
			while (_visual.numChildren) {
				_visual.removeChildAt(0);
			}
			
			_visual.addChild(obj);
			_objectToDisplay = obj;
			obj.x = -obj.width / 2;
			obj.y = -obj.height / 2;
		}
		
		private function initHandler(e : StateEvent):void {
			owner.addChildToLayer(_visual, _layer, _inheritRotation);
		}
		
		override protected function destroy() : void {
			// Вообще этого можно не делать, так как все удалится автоматически
			while (_visual.numChildren) {
				_visual.removeChildAt(0);
			}
			owner.removeChild(_visual);
			
			_visual = null;
			_objectToDisplay = null;
		}
		
		public function get layer():int { return _layer; }
		
		public function set layer(value:int):void {
			_layer = value;
		}
		
		public function get inheritRotation():Boolean { return _inheritRotation; }
		
		public function set inheritRotation(value:Boolean):void {
			_inheritRotation = value;
		}
		
		public function get x():Number { return _x; }
		
		public function set x(value:Number):void {
			_x = value;
			_visual.x = _x;
		}
		
		public function get y():Number { return _y; }
		
		public function set y(value:Number):void {
			_y = value;
			_visual.y = _y;
		}
		
		public function get rotation():Number { return _rotation; }
		
		public function set rotation(value:Number):void {
			_rotation = value;
			_visual.rotation = _rotation;
		}
		
		public function get visual():Sprite { return _visual; }
	}

}