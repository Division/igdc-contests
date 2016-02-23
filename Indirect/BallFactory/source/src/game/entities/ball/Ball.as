package game.entities.ball {
	import decorator.Decorator;
	import game.entities.common.detail.Detail;
	import game.events.GetItemDataEvent;
	import physics.Physics;
	
	/**
	 * Декоратор шара
	 * @author Division
	 */
	public class Ball extends Detail{
		
		public static const NAME : String = "Ball";
		
		public static const BALL_BOWLING : int = 1;
		
		public static const BOWLING_IMAGE_NAME : String = "common/graphics/entities/BallBowling.png";
		public static const BOWLING_RADIUS : Number = 14 / Physics.KOEF;
		
		private var _type : int = 1;
		
		public function Ball(type : int = 1) {
			super(NAME);
			_type = type;
		}
		
		override public function init() : void {
			super.init();
			
			addCallback(GetItemDataEvent.GET_MENU_RADIUS, getMenuRadiusHandler);
		}
		
		private function getMenuRadiusHandler(e : GetItemDataEvent):void {
			e.menuRadius = 30;
		}
		
		public function get type():int { return _type; }
		
	}

}