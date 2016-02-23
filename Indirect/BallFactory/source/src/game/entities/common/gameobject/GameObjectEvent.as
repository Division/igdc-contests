package game.entities.common.gameobject {
	import decorator.DecorEvent;
	import flash.events.Event;
	
	/**
	 * Событие игрового объекта
	 * @author Division
	 */
	public class GameObjectEvent extends DecorEvent{
		
		public static const GET_NAME : String = "getGameObjectName";
		
		public var name : String;
		
		public function GameObjectEvent(type : String) {
			super(type);
		}
		
	}

}