package game.events {
	import decorator.DecorEvent;
	import flash.events.Event;
	
	/**
	 * События симуляции
	 * @author Division
	 */
	public class SimulationEvent extends DecorEvent{
		
		public static const SIM_START : String = "SimStart";
		public static const SIM_END : String = "SimEnd";
		
		public function SimulationEvent(type : String) {
			super(type);
		}
		
		override public function clone() : Event {
			return new SimulationEvent(type);
		}
		
	}

}