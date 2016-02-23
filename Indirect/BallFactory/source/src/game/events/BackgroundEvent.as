package game.events {
	import decorator.DecorEvent;
	
	/**
	 * @author Division
	 */
	public class BackgroundEvent extends DecorEvent{
		
		public static const SET : String = "SetBackground";
		
		public var backName : String;
		
		public function BackgroundEvent(type : String, backName : String = "") {
			super(type);
			this.backName = backName;
		}
		
	}

}