package states {

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Менеджер состояний игры
	 * @author Division
	 */
	public class StateManager extends Sprite {
		
		private static var _instance : StateManager = null;
		private var _currentState : BasicState = null;
		
		public function StateManager() {
			if (_instance != null) {
				throw new Error("Нельзя создать более одного экземпляра StateManager");
			}
		}
		
		public static function get instance() : StateManager {
			if (_instance == null) {
				_instance = new StateManager();
			}
			return _instance;
		}
		
		
		/**
		 * Установка состояния игры
		 */
		public function setState( state : BasicState ) : void {			
			if (state == null) {
				throw new Error("Состояние не может быть null");
			}
			if (currentState != null) {
				currentState.onDeactivate();
				if (currentState.autoManage && contains(currentState)) {
					removeChild(currentState);
				}
			}
						
			_currentState = state;
			currentState.onActivate();
			if (currentState.autoManage) {				
				addChild(currentState);
			}
			
			stage.focus = null;
		}
		
		
		/**
		 * Обновление текущего состояния
		 */
		public function update(e : Event = null) : void {
			if (currentState == null) return;
			currentState.update();
		}
		
		public function get currentState() : BasicState { 
			return _currentState; 
		}
		
	}

}