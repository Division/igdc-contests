package game.entities.plank {
	import decorator.Decorator;
	import game.entities.common.detail.Detail;
	import game.events.GetItemDataEvent;
	import physics.Physics;
	
	/**
	 * @author Division
	 */
	public class Plank extends Detail{
		
		public static const NAME : String = "Plank";
		
		public static const WORLD_W : Number = 75 / Physics.KOEF;
		public static const WORLD_H : Number = 10 / Physics.KOEF;
		
		public static const IMAGE_NAME : String = "common/graphics/entities/plank.png";
		
		public function Plank() {
			super(NAME);
		}
		
		override public function init() : void {
			super.init();
		}
		
	}

}