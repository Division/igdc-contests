package physics {
	import Box2D.Dynamics.b2Body;
	import decorator.DecorEvent;
	
	/**
	 * Событие физики
	 * @author Division
	 */
	public class PhysEvent extends DecorEvent{
		
		public static const UPDATE_BODY : String = "PhysEventBodyUpdate";
		
		public var body : b2Body;
		
		public function PhysEvent(type : String) {
			super(type);
		}
		
	}

}