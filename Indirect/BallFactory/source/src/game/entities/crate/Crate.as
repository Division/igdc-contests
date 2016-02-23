package game.entities.crate {
	import decorator.Decorator;
	import game.entities.common.detail.Detail;
	import game.events.GetItemDataEvent;
	import physics.PhysContactEvent;
	import physics.Physics;
	
	/**
	 * Ящик
	 * @author Division
	 */
	public class Crate extends Detail{
		
		public static const NAME : String = "Crate";
		
		public static const INITIALIZER_NAME : String = "CrateCreator";
		
		public static const IMAGE_NAME : String = "common/graphics/entities/crate.png";
		
		public static const WORLD_W : Number = 45 / Physics.KOEF;
		public static const WORLD_H : Number = 41 / Physics.KOEF;
		
		public function Crate() {
			super(NAME);
		}
		
		override public function init() : void {
			super.init();
			addCallback(GetItemDataEvent.GET_MENU_RADIUS, getMenuRadiusHandler);
		}
		
		private function getMenuRadiusHandler(e : GetItemDataEvent):void{
			e.menuRadius = 65;
		}
		
	}

}