package game.entities.BallReceiver {
	import decorator.Decorator;
	import game.entities.ball.Ball;
	import game.entities.common.detail.Detail;
	import game.events.GetItemDataEvent;
	import game.events.SimulationEvent;
	import game.events.StateEvent;
	import game.general.GameController;
	import physics.PhysContactEvent;
	import physics.Physics;
	
	/**
	 * @author Division
	 */
	public class BallReceiver extends Detail{
		
		public static const NAME : String = "BallReceiver";
		
		public static const IMAGE_NAME : String = "common/graphics/entities/PileReceive.png";
		public static const HOLE_IMAGE_NAME : String = "common/graphics/entities/inPileHole.png";
		public static const BOARD_IMAGE_NAME : String = "common/graphics/entities/inPileBoard.png";
		
		public static const SMALL_HEIGHT : Number = 29 / Physics.KOEF;
		public static const SMALL_WIDTH : Number = 42 / Physics.KOEF;

		public static const BIG_HEIGHT : Number = 65 / Physics.KOEF;
		public static const BIG_WIDTH : Number = 61 / Physics.KOEF;
		
		public static const V_OFFS : Number = (BIG_HEIGHT - SMALL_HEIGHT) / 2;
		
		private var _ballType : int = 1;
		private var _ballCount : int = 1;
		
		private var _ballsReceived : int = 0;
		
		public function BallReceiver() {
			super(NAME);
		}
		
		override public function init() : void {
			super.init();
			addCallback(StateEvent.INIT, initHandler);
			addCallback(GetItemDataEvent.ITEM_PARAMS_LOADED, itemLoadedHandler);
			addCallback(GetItemDataEvent.GET_ITEM_PARAMS, getItemParamsHandler);
			addCallback(GetItemDataEvent.ITEM_PARAMS_UPDATE, itemParamsUpdateHandler);
			addCallback(SimulationEvent.SIM_START, simStartHandler);
			addCallback(SimulationEvent.SIM_END, simEndHandler);
			addCallback(PhysContactEvent.BEGIN, contactHandler);
		}
		
		private function contactHandler(e : PhysContactEvent):void{
			if (!e.fixtureA.IsSensor()) return;
			var b : Ball = (e.fixtureB.GetUserData() as Decorator).owner.searchDecorator(Ball.NAME) as Ball;
			if (!b) return;
			if (b.type != _ballType || _ballsReceived >= _ballCount) return;
			
			b.owner.die();
			_ballsReceived++;
			GameController.instance.ballsReceived++;
		}
		
		private function simStartHandler(e : SimulationEvent):void{
			_ballsReceived = 0;
		}
		
		private function simEndHandler(e : SimulationEvent):void{
			
		}
		
		private function initHandler(e : StateEvent):void{
			addParameterList(["ballType","ballCount"]);
		}
		
		private function itemLoadedHandler(e : GetItemDataEvent):void {
			_ballType = e.loadedParams.ballType;
			_ballCount = e.loadedParams.ballCount;
			GameController.instance.ballsToReceive += _ballCount;
		}
		
		private function itemParamsUpdateHandler(e : GetItemDataEvent):void{
			_ballType = e.newItemParams["ballType"];
			_ballCount = e.newItemParams["ballCount"];
		}
		
		private function getItemParamsHandler(e : GetItemDataEvent):void{
			e.itemParams["ballType"] = _ballType;
			e.itemParams["ballCount"] = _ballCount;
		}
		
		public function get ballCount():int { return _ballCount; }
		
		public function set ballCount(value:int):void {
			_ballCount = value;
		}
		
		public function get ballType():int { return _ballType; }
		
		public function set ballType(value:int):void {
			_ballType = value;
		}
	}

}