package game.entities.triangle {
	import decorator.Decorator;
	import game.entities.common.detail.Detail;
	import game.events.GetItemDataEvent;
	import physics.Physics;
	
	/**
	 * @author Division
	 */
	public class Triangle extends Detail{
		
		public static const NAME : String = "Triangle";
		
		public static const WORLD_W : Number = 50 / Physics.KOEF;
		public static const WORLD_H : Number = 50 / Physics.KOEF;
		
		public static const IMAGE_NAME : String = "common/graphics/entities/triangle.png";
		
		public function Triangle() {
			super(NAME);
		}
		
		override public function init() : void {
			super.init();
		}
		
	}

}