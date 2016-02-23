package game.actions.base {
	import actionqueue.ActionBase;
	
	/**
	 * Базовый класс для загрузки уровня
	 * @author Division
	 */
	public class LoadLevelBaseAction extends ActionBase {
		
		/**
		 * Имя загружаемого уровня
		 */
		protected var _level : String;
		
		protected var _inEditor : Boolean;
		
		public function LoadLevelBaseAction(level : String, inEditor : Boolean) {
			_level = level;
			_inEditor = inEditor;
		}
		
	}

}