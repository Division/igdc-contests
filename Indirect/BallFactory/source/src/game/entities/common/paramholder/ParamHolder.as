package game.entities.common.paramholder {
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import decorator.Decorator;
	import game.entities.common.gameobject.GameObject;
	import game.events.GetItemDataEvent;
	import game.events.SimulationEvent;
	import game.events.StateEvent;
	import physics.PhysBody;
	
	/**
	 * Декоратор для восстановления позиции и ориентации после симуляции
	 * @author Division
	 */
	public class ParamHolder extends Decorator{
		
		public static const NAME : String = "ParamHolder";
		
		private var _x : Number = 0;
		private var _y : Number = 0;
		private var _angle : Number = 0;
		
		private var _pb : PhysBody;
		private var _go : GameObject;
		
		private var _isStatic : Boolean = true;
		
		private var _deleteAfterSimEnd : Boolean;
		
		public function ParamHolder() {
			super(NAME);
		}
		
		override public function init() : void {
			addCallback(StateEvent.INIT, initHandler);
			addCallback(SimulationEvent.SIM_START, simStart);
			addCallback(SimulationEvent.SIM_END, simEnd);
		}
		
		private function initHandler(e : StateEvent):void{
			_pb = owner.searchDecorator(PhysBody.NAME) as PhysBody;
		}
		
		private function simEnd(e : SimulationEvent):void {
			if (_deleteAfterSimEnd) {
				owner.die();
				return;
			}
			
			if (!_pb) return;
			_pb.body.SetType(b2Body.b2_staticBody);
			_pb.body.SetPosition(new b2Vec2(_x,_y));
			_pb.body.SetAngle(_angle);
			_pb.updateFollow();
		}
		
		private function simStart(e : SimulationEvent):void{
			if (!_pb) return;
			
			var ev : GetItemDataEvent = new GetItemDataEvent(GetItemDataEvent.GET_IS_STATIC);
			owner.sendEvent(ev);
			isStatic = Boolean(Number(ev.isStatic));
			
			if (!isStatic) {
				_pb.body.SetType(b2Body.b2_dynamicBody);
			}
			_x = _pb.body.GetPosition().x;
			_y = _pb.body.GetPosition().y;
			_angle = _pb.body.GetAngle();
		}
		
		override protected function destroy() : void {
			_pb = null;
		}
		
		public function get deleteAfterSimEnd():Boolean { return _deleteAfterSimEnd; }
		
		public function set deleteAfterSimEnd(value:Boolean):void {
			_deleteAfterSimEnd = value;
		}
		
		public function get isStatic():Boolean { return _isStatic; }
		
		public function set isStatic(value:Boolean):void {
			_isStatic = value;
		}
		
	}

}