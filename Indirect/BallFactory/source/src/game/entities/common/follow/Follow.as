package game.entities.common.follow {
	import Box2D.Common.Math.b2Vec2;
	import decorator.Decorator;
	import game.entities.common.gameobject.GameObject;
	import game.events.StateEvent;
	import physics.PhysBody;
	import physics.PhysEvent;
	
	/**
	 * Декоратор, который осуществляет следование GameObject за IFollowable декоратором
	 * @author Division
	 */
	public class Follow extends Decorator{
		
		public static const NAME : String = "Follow";
		
		private var _go : GameObject;
		private var _followable : IFollowable;
		
		public function Follow() {
			super(NAME);
		}
		
		override public function init() : void {
			addCallback(StateEvent.INIT, initHandler);
		}
		
		private function initHandler(e : StateEvent) : void {
			_go = owner.searchDecorator(GameObject.NAME) as GameObject;
			var ev : FollowEvent = new FollowEvent(FollowEvent.REGISTER_FOLLOW, this);
			owner.sendEvent(ev);
		}
		
		public function update(target : IFollowable) : void {
			if (_go) {
				_go.x = target.getFollowPositionX();
				_go.y = target.getFollowPositionY();
				_go.rotation = target.getFollowAngle();
			}
		}
		
		override protected function destroy() : void {
			_go = null;
			_followable = null;
		}
		
	}

}