package decorator {
	import flash.events.Event;
	
	/**
	 * Базовый класс события декоратора
	 * @author Division
	 */
	public class DecorEvent extends Event {
		
		private var _isAlreadySent : Boolean;
		
		public function DecorEvent(type : String) {
			super(type, false, false);
			_isAlreadySent = false;
		}
		
		public function get isAlreadySent():Boolean { return _isAlreadySent; }
		
		public function makeAlreadySent() : void {
			_isAlreadySent = true;
		}
		
	}

}