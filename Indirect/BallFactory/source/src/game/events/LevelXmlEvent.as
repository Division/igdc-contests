package game.events {
	import decorator.DecorEvent;
	import flash.events.Event;
	
	/**
	 * @author Division
	 */
	public class LevelXmlEvent extends DecorEvent{
		
		public static const GET_LEVEL_XML : String = "GetLevelXml";
		public static const GET_PARAMS_XML : String = "GetParamsXml";
		
		// Статичный из-за кривости нативных ивентов, которые пересоздают объект события при повторном диспатче.
		public static var levelXml : XML;
		
		public function LevelXmlEvent(type : String) {
			super(type);
		}
		
		override public function clone() : Event {
			return new LevelXmlEvent(type);
		}
		
	}

}