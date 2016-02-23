package physics {

	import Box2D.Collision.b2AABB;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2Fixture;
	import decorator.Decoratable;
	import flash.display.Sprite;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.b2World;
	import decorator.Decorator;
	import math.Vector2;
	
	/**
	 * Мини обёртка для Box2D
	 * @author Division
	 */
	public class Physics {
		
		private static var _koef : Number = 40;
		
		public static function get KOEF() : Number {
			return _koef;
		}
		
		public static function setKoef(k : Number) : void {
			_koef = k;
		}
		
		private static var _instance : Physics;
		
		private var _world 		: b2World;
		private var _worldAABB 	: b2AABB;
		private var _PosIterations : int = 10;
		private var _VelIterations : int = 10;
		private var _timeStep 	: Number = 1.0/30.0;
		private var _gravity 	: b2Vec2;
		private var _doSleep 	: Boolean = true;
		private var _debugDraw 	: b2DebugDraw = null;
		
		public function Physics() {
			if (_instance != null) {
				throw new Error("Нельзя создать больше одного экземпляра Physics");
			}
			_gravity = new b2Vec2(0, 0);
			_doSleep = true;
		}
		
		public function initialize(gravity : Vector2 = null, doSleep : Boolean = true) : void {
			if (!gravity) {
				gravity = new Vector2(0, 0);
			}
			_world = new b2World(new b2Vec2(gravity.x, gravity.y), doSleep);
		}
		
		public static function get instance() : Physics {
			if (_instance == null) {
				_instance = new Physics();
			}
			return _instance;
		}
		
		public function update() : void {
			_world.Step(_timeStep, _VelIterations, _PosIterations);
			
			var node : b2Body = world.GetBodyList();
			
			while (node) {
				var b : b2Body = node;
				node = node.GetNext();
				if (b.GetUserData() is Decorator) {
					var obj : Decoratable = b.GetUserData().owner as Decoratable;
					if (!obj) continue;
					if (obj.timeToDie) {
						world.DestroyBody(b);
					} else {
						var ev : PhysEvent = new PhysEvent(PhysEvent.UPDATE_BODY);
						ev.body = b;
						obj.sendEvent(ev);
					}
				}
			}
			
			_world.ClearForces();
			if (_debugDraw != null) {
				world.DrawDebugData();
			}
		}
		
		/**
		 * Инициализация дебажной отрисовки
		 */
		public function initDebugDraw(canvas : Sprite, drawScale : Number = 0, fillAlpha : Number = 0.3, lineThikness : Number = 3.0) : void {
			if (!drawScale) drawScale = KOEF;
			_debugDraw = new b2DebugDraw();
			_debugDraw.SetSprite(canvas);
			_debugDraw.SetDrawScale(drawScale);
			_debugDraw.SetFillAlpha(fillAlpha);
			_debugDraw.SetLineThickness(lineThikness);
			_debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit);
			world.SetDebugDraw(_debugDraw);
		}
		
		/**
		 * Добавление слушателя контактов
		 */
		public function setContactListener(cl : b2ContactListener) : void {
			world.SetContactListener(cl);
		}
		
		public function get world():b2World { return _world; }
		
	
		//////////////// РАБОТА С МАСКОЙ СТОЛКНОВЕНИЙ
		
		/**
		 * Задание битов для маски
		 */
		public static function setMaskBits(categories : Array, fixture : b2Fixture = null) : uint {
			var fd : b2FilterData;
			if (fixture != null) {
				fd = fixture.GetFilterData();
			} else {
				fd = new b2FilterData();
			}
			fd.maskBits = 0;
			for (var i:int = 0; i < categories.length; i++) {
				fd.maskBits |= 1 << categories[i];
			}
			if (fixture != null) {
				fixture.SetFilterData(fd);
			}
			return fd.maskBits;
		}
		
		/**
		 * Добавление битов для маски
		 */
		public static function addMaskBits(categories : Array, fixture : b2Fixture) : uint {
			var fd : b2FilterData = fixture.GetFilterData();
			for (var i:int = 0; i < categories.length; i++) {
				fd.maskBits |= 1 << categories[i];
			}
			fixture.SetFilterData(fd);
			return fd.maskBits;
		}
		
		/**
		 * Удаление битов для маски
		 */
		public static function removeMaskBits(categories : Array, fixture : b2Fixture) : uint {
			var fd : b2FilterData = fixture.GetFilterData();
			var b : uint = 0;
			for (var i:int = 0; i < categories.length; i++) {
				b |= 1 << categories[i];
			}
			b = ~b;
			fd.maskBits &= b;
			fixture.SetFilterData(fd);
			return fd.maskBits;
		}
		
		/**
		 * Установка индекса группы
		 */
		public static function setGroupIndex(ind : int, fixture : b2Fixture) : void {
			var fd : b2FilterData = fixture.GetFilterData();
			fd.groupIndex = ind;
			fixture.SetFilterData(fd);
		}
		
		/**
		 * Установка категории столкновений
		 */
		public static function setCategoryBits(bits : uint, fixture : b2Fixture) : void {
			var fd : b2FilterData = fixture.GetFilterData();
			fd.categoryBits = bits;
			fixture.SetFilterData(fd);
		}
		
	}

}