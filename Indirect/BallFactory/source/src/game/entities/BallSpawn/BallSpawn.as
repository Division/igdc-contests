package game.entities.BallSpawn {
	import Box2D.Common.Math.b2Vec2;
	import decorator.Decoratable;
	import decorator.Decorator;
	import decorator.Scene;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import game.entities.ball.Ball;
	import game.entities.ball.BallCreator;
	import game.entities.common.detail.Detail;
	import game.entities.common.gameobject.GameObject;
	import game.events.GetItemDataEvent;
	import game.events.SimulationEvent;
	import game.events.StateEvent;
	import physics.PhysBody;
	import physics.Physics;
	
	/**
	 * Респаун поинт для шариков
	 * @author Division
	 */
	public class BallSpawn extends Detail{
		
		public static const NAME : String = "BallSpawn";
		
		public static const INITIALIZER_NAME : String = "BallSpawnCreator";
		
		public static const IMAGE_NAME : String = "common/graphics/entities/PileLaunch.png";
		public static const HOLE_IMAGE_NAME : String = "common/graphics/entities/outPileHole.png";
		public static const BOARD_IMAGE_NAME : String = "common/graphics/entities/outPileBoard.png";
		
		public static const PILE_WIDTH	: Number = (52 + 2) / Physics.KOEF;
		public static const PILE_HEIGHT : Number = (29 + 0) / Physics.KOEF;
		
		/**
		 * Сила, которая прикладывается к шару в момент его создания
		 */
		private var _initForce : Number = 3;
		
		/**
		 * Количество шаров, которые требуется создать
		 */
		private var _ballsToSpawn : int = 3;
		
		/**
		 * Количество уже созданных шаров
		 */
		private var _ballsSpawned : int = 0;
		
		private var _createInterval : Number = 1;
		
		private var _nextTime : int = 0;
		
		private var _go : GameObject;
		
		private var _ballType : int = 1;
		
		/**
		 * Запущена ли симуляция
		 */
		private var _started : Boolean = false;
		
		public function BallSpawn() {
			super(NAME);
		}
		
		override public function init() : void {
			super.init();
			addCallback(GetItemDataEvent.GET_ITEM_PARAMS, getItemParamsHandler);
			addCallback(GetItemDataEvent.ITEM_PARAMS_UPDATE, itemParamsUpdateHandler);
			addCallback(StateEvent.INIT, initHandler);
			addCallback(GetItemDataEvent.GET_MENU_RADIUS, getMenuRadiusHandler);
			addCallback(StateEvent.UPDATE, updateHandler);
			addCallback(SimulationEvent.SIM_START, simStart);
			addCallback(SimulationEvent.SIM_END, simEnd);
			addCallback(GetItemDataEvent.ITEM_PARAMS_LOADED, itemLoadedHandler);
		}
		
		private function itemLoadedHandler(e : GetItemDataEvent):void {
			
			_ballType = e.loadedParams.ballType;
			_ballsToSpawn = e.loadedParams.ballCount;
			_initForce = e.loadedParams.power;
			_createInterval = e.loadedParams.shootDelay;
			if (isNaN(_createInterval)) _createInterval = 1;
			
		}
		
		private function itemParamsUpdateHandler(e : GetItemDataEvent):void{
			_ballType = e.newItemParams["ballType"];
			_ballsToSpawn = e.newItemParams["ballCount"];
			_initForce = e.newItemParams["power"];
			_createInterval = e.newItemParams["shootDelay"];			
		}
		
		private function getItemParamsHandler(e : GetItemDataEvent):void{
			e.itemParams["ballType"] = _ballType;
			e.itemParams["ballCount"] = _ballsToSpawn;
			e.itemParams["power"] = _initForce;
			e.itemParams["shootDelay"] = _createInterval;
		}
		
		private function simEnd(e : SimulationEvent):void {
			_started = false;
		}
		
		private function simStart(e : SimulationEvent):void {
			_started = true;
			_nextTime = getTimer() + _createInterval * 1000;
			_ballsSpawned = 0;
		}
		
		private function initHandler(e : StateEvent):void {
			addParameterList(["ballType","ballCount","power","shootDelay"]);
			_go = owner.searchDecorator(GameObject.NAME) as GameObject;
		}
		
		private function updateHandler(e : StateEvent):void {
			if (!_started) return;
			
			var time : int = getTimer();
			if (_ballsSpawned < _ballsToSpawn && time >= _nextTime) {
				spawnBall();
				_nextTime = time + _createInterval * 1000;
			}
		}
		
		private function getMenuRadiusHandler(e : GetItemDataEvent):void{
			e.menuRadius = 40;
		}
		
		private function spawnBall() : void {
			if (!_go) return;
			
			var dx : Number, dy : Number;
			dx = Math.cos(_go.rotation);
			dy = Math.sin(_go.rotation);
			
			var dir : b2Vec2 = new b2Vec2(dx,dy);
			dir.Multiply(_initForce * 20);
			
			var decor : Decoratable = new Decoratable;
			var ball : BallCreator = new BallCreator();
			ball.type = Ball.BALL_BOWLING;
			decor.addDecorator(ball);
			ball.deserialize( { x : _go.x + dx * ball.radius / 2, y : _go.y + dy * ball.radius/2 } );
			Scene.instance.addEntity(decor);
			decor.sendEvent(new StateEvent(StateEvent.INIT));
			
			var pb : PhysBody = decor.searchDecorator(PhysBody.NAME) as PhysBody;
			if (pb) {
				pb.body.ApplyForce(dir, pb.body.GetPosition());
			}
			
			_ballsSpawned++;
		}
		
		public function get ballType():int { return _ballType; }
		
		public function set ballType(value:int):void {
			_ballType = value;
		}
		
		public function get createInterval():Number { return _createInterval; }
		
		public function set createInterval(value:Number):void {
			_createInterval = value;
		}
		
		public function get ballsToSpawn():int { return _ballsToSpawn; }
		
		public function set ballsToSpawn(value:int):void {
			_ballsToSpawn = value;
		}
		
		public function get initForce():Number { return _initForce; }
		
		public function set initForce(value:Number):void {
			_initForce = value;
		}
		
	}

}