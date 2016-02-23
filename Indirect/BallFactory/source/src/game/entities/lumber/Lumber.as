package game.entities.lumber {
	import decorator.Decorator;
	import game.entities.common.detail.Detail;
	import game.events.GetItemDataEvent;
	import physics.Physics;
	
	/**
	 * @author Division
	 */
	public class Lumber extends Detail{
		
		public static const NAME : String = "Lumber";
		
		public static const RADIUS : Number = (50/2) / Physics.KOEF;
		
		public static const IMAGE_NAME : String = "common/graphics/entities/lumber.png";
		
		public function Lumber() {
			super(NAME);
		}
		
		override public function init() : void {
			super.init();
		}
		
	}

}