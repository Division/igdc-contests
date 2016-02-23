package game.general {
	import actionqueue.ActionQueue;
	import decorator.Scene;
	import flash.display.Sprite;
	import flash.events.Event;
	import game.actions.LoadLevelAction;
	import game.camera.Camera;
	import physics.Physics;
	
	/**
	 * Главный игровой класс, который помогает реализовать некоторую логику
	 * @author Division
	 */
	public class Game extends Sprite {
		
		public static const dt : Number = 1 / 30;
		
		private static var _instance : Game = null;
		
		private var _actionQueue : ActionQueue;
		
		private var _gameController : GameController;
		
		public static function get instance() : Game {
			if (_instance == null) {
				_instance = new Game();
			}
			
			return _instance;
		}
		
		public function init() : void {
			addChild(Scene.instance);
			_actionQueue = new ActionQueue();
			_actionQueue.start();
			_gameController = new GameController();
		}
		
		public function update(e : Event = null) : void {
			Physics.instance.update();
			Scene.instance.update(dt);
			//Camera.instance.apply();
			_gameController.update();
		}
		
		public function loadLevel(name : String, isEditor : Boolean = true) : void {
			_actionQueue.addAction(new LoadLevelAction(name, isEditor));
		}
		
	}

}