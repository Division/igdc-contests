package game.events {
	import decorator.DecorEvent;
	import flash.events.Event;
	
	/**
	 * INIT Вызывается после добавления всех декораторов, завершения инициазилации Decoratable
	 * UPDATE каждый кадр
	 * @author Division
	 */
	public class StateEvent extends DecorEvent{
		
		public static const INIT : String = "StateEventInit";
		public static const UPDATE : String = "StateEventUpdate";
		
		public function StateEvent(type : String) {
			super(type);
		}
		
		override public function clone() : Event {
			return new StateEvent(type);
		}
		
	}

}