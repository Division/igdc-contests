package actionqueue {
	import flash.events.EventDispatcher;
	
	/**
	 * Класс очереди действий
	 * Следующее действие выполняется только по завершению предыдущего
	 * @author Division
	 */
	public class ActionQueue extends EventDispatcher {
		
		/**
		 * Массив с очередью действий
		 */
		private var _queue : Array/*ActionBase*/;
		
		/**
		 * Приостановлено ли выполнение
		 */
		private var _stopped : Boolean;
		
		/**
		 * Выполняется ли какое-либо действие в данный момент
		 */
		private var _isProcessing : Boolean;
		
		/**
		 * Текущее выполняемоей действие
		 */
		private var _curAction : ActionBase;
		
		/**
		 * Результат, полученный от последнего действия
		 */
		private var _lastResult : Object;
		
		/**
		 * Находимся ли внутри блока добавления действий
		 */
		private var _inBlock : Boolean;
		
		public function ActionQueue() {
			_stopped = true;
			_isProcessing = false;
			_queue = new Array();
			_curAction = null;
			_lastResult = null;
			_inBlock = false;
		}
		
		/**
		 * Начало задания блока действий, между которыми никак не может вклиниться другое действие
		 */
		public function beginBlock() : void {
			_inBlock = true;
		}
		
		/**
		 * Окончание блока действий, перенос добавленных за это время действий в основной массив
		 */
		public function endBlock() : void {
			_inBlock = false;
			processActions();
		}
		
		/**
		 * Добавление действия в очередь
		 * @param action объект действия
		 * @param needParams требуются ли результаты предыдущего действия для работы текущего. Если false, будет передан пустой объект params
		 */
		public function addAction(action : ActionBase, needParams : Boolean = false) : void {
			action.init(actionComplete, needParams);
			_queue.push(action);
			if (!_inBlock) {
				processActions();
			}
		}
		
		/**
		 * Начинает выполнение действий, если они не выполняются(приостановлены либо не начаты)
		 */
		public function start() : void {
			_stopped = false;
			processActions();
		}
		
		/**
		 * Приостанавливает выполнение действий.
		 * Текущее активное действие не прерывается и будет выполнено до конца
		 */
		public function stop() : void {
			_stopped = true;
		}
		
		/**
		 * Вызывает выполнение действия
		 */
		protected function processActions() : void {
			if (_stopped || !_queue.length || _isProcessing || _inBlock) return;
			
			var params : Object = _lastResult;
			_curAction = _queue[0] as ActionBase;
			
			if (params == null || !_curAction.needParams) {
				params = new Object();
				_lastResult = null;
			}
			
			_isProcessing = true;
			_curAction.startProcessing(params);
		}
		
		/**
		 * Callback, который вызывается при завершении работы действия
		 * @param result результаты работы действия
		 */
		protected function actionComplete(result : Object) : void {
			_queue.shift();
			_isProcessing = false;
			_lastResult = result;
			processActions();
		}
		
	}

}