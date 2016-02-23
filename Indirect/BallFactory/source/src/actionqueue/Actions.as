package actionqueue {
	import actionqueue.ActionQueue;
	
	/**
	 * Синглтон обёртка для очереди действий
	 * @author Division
	 */
	public class Actions extends ActionQueue{
		
		private static var _instance : Actions = null;
		
		public function Actions() {
			super();
			start();
		}
		
		public static function get instance() : Actions {
			if (_instance == null) {
				_instance = new Actions();
			}
			return _instance;
		}
		
	}

}