package game.actions {
	import actionqueue.ActionBase;
	import decorator.Scene;
	import math.Vector2;
	import physics.ContactListener;
	import physics.Physics;
	
	/**
	 * Инициализация всего чего не успели ранее
	 * @author Division
	 */
	public class InitAction extends ActionBase {

		override protected function processAction(params : Object) : void {
			Physics.instance.initialize(new Vector2(0, 0), true);
			Physics.instance.setContactListener(new ContactListener());
			Physics.instance.initDebugDraw(Scene.instance);
		}
		
	}

}