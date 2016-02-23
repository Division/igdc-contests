package script {
	import com.hurlant.eval.CompiledESC;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	/**
	 * Скриптовый движок
	 * Для работы надо заинклюдить EvalES4.swc
	 * @author Division
	 */
	public class Scripts extends EventDispatcher {
		
		private static var _instance : Scripts = null;
		
		/**
		 * Массив добавленных скриптов
		 */
		private var _scripts : Object/*ScriptEntity*/;
		
		/**
		 * Компилятор
		 */
		private var _esc : CompiledESC;
		
		public static function get instance() : Scripts {
			if (!_instance) {
				_instance = new Scripts();
			}
			
			return _instance;
		}
		
		public function get esc():CompiledESC { return _esc; }
		
		public function Scripts() {
			_esc = new CompiledESC();
			_scripts = new Object();
		}
		
		/**
		 * Компиляция в байткод
		 * @param	source исходных код
		 */
		public function compile(source : String) : ByteArray {
			return _esc.eval(source);
		}
		
		/**
		 * Добавление скрипта
		 * @param	name имя скрипта
		 * @param	source исходник скрипта
		 */
		public function addScript(name : String, source : String) : ScriptEntity {
			var scr : ScriptEntity = new ScriptEntity(name);
			scr.compileScript(source);
			if (_scripts[name]) {
				_scripts[name].destroy();
			}
			_scripts[name] = scr;
			scr.addEventListener(ScriptEvent.SCRIPT_LOADED, scriptLoadedHandler, false, 0, true);
			return scr;
		}
		
		private function scriptLoadedHandler(e:ScriptEvent):void {
			dispatchEvent(e);
		}
		
		/**
		 * Получение скрипта по имени
		 */
		public function getScript(name : String) : ScriptEntity {
			if (_scripts[name]) return _scripts[name];
			return null;
		}
		
	}

}