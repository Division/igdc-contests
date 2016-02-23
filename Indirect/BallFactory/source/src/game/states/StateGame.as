package game.states {
	
	import game.general.Game;
	import game.general.GameController;
	import states.BasicState;
	
	/**
	 * Класс состояние "в игре"
	 * @author Division
	 */
	public class StateGame extends BasicState {
		
		private static var _instance : StateGame = null;
		
		public function StateGame() {
			if (_instance != null) {
				throw new Error("Нельзя создать более одного экземпляра StateGame");
			}
		}
		
		public static function get instance() : StateGame {
			if (_instance == null) {
				_instance = new StateGame();
			}
			return _instance;
		}
		
		override protected function initialize() : void {
			addChild(Game.instance);
		}
		
		override public function update() : void {
			Game.instance.update();
		}
		
		override public function onDeactivate() : void {
			GameController.instance.onDeactivate();
		}
		
	}

}