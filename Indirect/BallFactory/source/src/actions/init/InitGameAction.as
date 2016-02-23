package actions.init {
	import actionqueue.ActionBase;
	import actionqueue.Actions;
	import decorator.Scene;
	import flash.events.Event;
	import game.actions.InitAction;
	import game.actions.RegDecoratorsAction;
	import game.general.Game;
	import game.states.StateGame;
	import game.states.StateMenu;
	import game.utils.Input;
	import states.StateManager;
	
	/**
	 * Инициализация игры, сцены
	 * @author Division
	 */
	public class InitGameAction extends ActionBase {
		
		private var _main : Main;
		
		public function InitGameAction(main : Main) {
			_main = main;
		}
		
		override protected function processAction(params : Object) : void {
			Actions.instance.addAction(new RegDecoratorsAction());
			Actions.instance.addAction(new InitAction());
			Input.instance.initialize(_main.stage);
			_main.addChild(StateManager.instance);
			StateManager.instance.setState(StateMenu.instance);
			StateManager.instance.addEventListener(Event.ENTER_FRAME, StateManager.instance.update);
			Game.instance.init();
			Scene.instance.init();
		}
		
	}

}