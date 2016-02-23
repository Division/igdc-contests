package actionqueue {
	
	/**
	 * Базовый класс для действия
	 * @author Division
	 */
	public class ActionBase{
		
		/**
		 * Колбек, вызываемый при завершении работы действия
		 */
		private var _callback : Function;
		
		/**
		 * Требуются ли параметры от предыдущего действия
		 */
		private var _needParams : Boolean;
		
		/**
		 * Результат работы действия
		 * Заполняется при необходимости, и передаётся на вход следующему действию
		 */
		protected var _result : Object;
		
		/**
		 * Требуется ли вызвать функцию finish сразу после окончания выполнения
		 */
		protected var _completeAtOnce : Boolean;
		
		public function ActionBase() {
			_callback = null;
			_result = new Object();
			_completeAtOnce = true;
		}
		
		/**
		 * Действие, которое выполняет класс
		 * Переопределяется в потомках
		 * @param params - Object параметров, полученных от предыдущего действия. Не может быть null, будет пуст если результаты не требуются.
		 */
		protected function processAction(params : Object) : void {
			// abstract
			throw new Error("processAction method must be overriden");
		}
		
		public function startProcessing(params : Object) : void {
			processAction(params);
			if (completeAtOnce) {
				finish();
			}
		}
		
		/**
		 * Инициализация действия
		 * @param	callback колбек вызываемый по завершению действия
		 * @param	needParams требуются ли действию результаты работы предыдущего действия. Если false, то будет передан пустой объект резутьтатов
		 */
		final public function init(callback : Function, needParams : Boolean) : void {
			_callback = callback;
			_needParams = needParams;
			_completeAtOnce = true;
		}
		
		/**
		 * Функция вызывается при завершении работы действия
		 */
		final protected function finish() : void {
			_callback.call(null, _result);
		}
		
		/**
		 * Следует вызвыть, если действие не окончено на момент выхода из функции processAction
		 * В таком случае в момент окончания действия требуется вручную вызвать метод finish
		 */
		final public function processMore() : void {
			_completeAtOnce = false;
		}
		
		/**
		 * Задание результата
		 */
		protected function setResult(name : String, value : *) : void {
			_result[name] = value;
		}
		
		public function get needParams():Boolean { return _needParams; }
		
		public function get completeAtOnce():Boolean { return _completeAtOnce; }
		
	}

}