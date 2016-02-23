package script {
	import com.hurlant.eval.ByteLoader;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	/**
	 * @author Division
	 */
	public class ScriptEntity extends EventDispatcher {
		
		protected var _loader : Loader;
		protected var _bytes : ByteArray;
		protected var _loaded : Boolean;
		protected var _name : String;
		
		public function ScriptEntity(name : String) {
			_loader = new Loader();
			_loaded = false;
			_name = name;
		}
		
		/**
		 * Компиляция скрипта
		 * @param	source
		 */
		public function compileScript(source : String) : void {
			try {
				_bytes = ByteLoader.wrapInSWF([Scripts.instance.compile(source)]);
				_loader.loadBytes(_bytes, null);
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler, false, 0, true);
			} catch (e : Error) {
				dispatchEvent(new ScriptEvent("",ScriptEvent.SCRIPT_LOAD_ERROR));
			}
		}
		
		private function loadCompleteHandler(e:Event):void {
			_loaded = true;
			dispatchEvent(new ScriptEvent("",ScriptEvent.SCRIPT_LOADED));
		}
		
		public function destroy() : void {
			_loader.unload();
		}
		
		public function getDefinition(name : String) : Object {
			return _loader.contentLoaderInfo.applicationDomain.getDefinition(name);
		}
		
		public function get name():String { return _name; }
		
		public function get loader():Loader { return _loader; }
		
	}

}