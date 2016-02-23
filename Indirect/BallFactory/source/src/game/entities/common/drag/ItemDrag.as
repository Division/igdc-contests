package game.entities.common.drag {
	import Box2D.Common.Math.b2Vec2;
	import decorator.Decorator;
	import game.entities.common.gameobject.GameObject;
	import game.events.ItemDragEvent;
	import game.events.StateEvent;
	import physics.PhysBody;
	
	/**
	 * Декоратор для перетаскивания объектов
	 * @author Division
	 */
	public class ItemDrag extends Decorator{
		
		public static const NAME : String = "ItemDrag";
		
		private var _pb : PhysBody;
		private var _go : GameObject;
		
		public function ItemDrag() {
			super(NAME);
		}
		
		override public function init() : void {
			addCallback(ItemDragEvent.MOVED, movedHandler);
			addCallback(StateEvent.INIT, initHandler);
		}
		
		private function initHandler(e : StateEvent):void{
			_pb = owner.searchDecorator(PhysBody.NAME) as PhysBody;
			_go = owner.searchDecorator(GameObject.NAME) as GameObject;
		}
		
		private function movedHandler(e : ItemDragEvent):void {
			if (_pb) {
				_pb.body.SetPosition(new b2Vec2(e.x, e.y));
				_pb.updateFollow();
			} else if (_go) {
				_go.x = e.x;
				_go.y = e.y;
			}
		}
		
		override protected function destroy() : void {
			_pb = null;
			_go = null;
		}
		
	}

}