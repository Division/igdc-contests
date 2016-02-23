package script {
	import flash.events.Event;
	
	/**
	 * Событие скрипта
	 * @author Division
	 */
	public class ScriptEvent extends Event{
		
		public static const SCRIPT_LOADED : String = "ScriptLoaded";
		public static const SCRIPT_LOAD_ERROR : String = "ScriptLoadError";
		
		private var _scriptName : String;
		
		public function ScriptEvent(scriptName : String, type : String) {
			super(type, false, false);
			_scriptName = scriptName; 
		}
		
		public function get scriptName():String { return _scriptName; }
		
	}

}