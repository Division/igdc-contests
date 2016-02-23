package physics {
	
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
	import decorator.Decorator;
	import decorator.DecorEvent;
	import game.entities.common.follow.Follow;
	import game.entities.common.follow.FollowEvent;
	import game.entities.common.follow.IFollowable;
	import game.entities.common.gameobject.GameObject;
	import game.events.StateEvent;
	import game.utils.geom.GeomAsset;
	import game.utils.geom.Geometry;
	import math.Vector2;
	import resourcemanager.ResManager;
	
	/**
	 * Декоратор, определяющий физическое тело
	 * @author Division
	 */
	public class PhysBody extends Decorator implements IFollowable {

		public static const NAME : String = "PhysBody";
		
		public static const SHAPE_BOX : String = "box";
		public static const SHAPE_CIRCLE : String = "circle";
		public static const SHAPE_CONVEX : String = "convex";
		
		public var bodyDef 	: b2BodyDef;
		
		private var _body 	: b2Body = null;
		public var shape 	: b2Shape = null;
		public var fixture 	: b2Fixture = null;
		
		public var initType : uint = b2Body.b2_dynamicBody;
		
		protected var _physInited : Boolean = false;
		
		protected var follow : Follow = null;
		
		public function PhysBody() {
			super(NAME, false);
		}
		
		public function initFixtureDef(fixDef : b2FixtureDef, data : *) : void {
			if (data.density.length()) {
				fixDef.density = Number(data.density);
			}
			if (data.restitution.length()) {
				fixDef.restitution = Number(data.restitution);
			}
			if (data.friction.length()) {
				fixDef.friction = Number(data.friction);
			}
/*			if (data.group.length()) {
				initGroup = Number(data.group);
			}
			if (data.categoryIndex.length()) {
				initCategoryIndex = Number(data.categoryIndex);
			}*/
			if (data.isSensor.length()) {
				fixDef.isSensor = data.isSensor == "true";
			}
		}
		
		protected function copyFixtureDef(fixtureDef : b2FixtureDef) : b2FixtureDef {
			var res : b2FixtureDef = new b2FixtureDef();
			res.density = fixtureDef.density;
			res.filter = fixtureDef.filter;
			res.friction = fixtureDef.friction;
			res.isSensor = fixtureDef.isSensor;
			res.restitution = fixtureDef.restitution;
			res.shape = fixtureDef.shape;
			res.userData = fixtureDef.userData;
			return res;
		}
		
		override public function deserialize(data : * ) : void {
			
			var defFixtureDef : b2FixtureDef = new b2FixtureDef();
			initFixtureDef(defFixtureDef, data);
			
			if (defFixtureDef.density == 0) {
				defFixtureDef.density = 1;
			}
			
			if (data.linearDamping.length()) {
				body.SetLinearDamping(Number(data.linearDamping));
			}
			if (data.angularDamping.length()) {
				body.SetAngularDamping(Number(data.angularDamping));
			}
			if (data.fixedRotation.length()) {
				body.SetFixedRotation(data.fixedRotation == "true");
			}
			
			if (data.type.length()) {
				switch(String(data.type)) {
					case "static":
						body.SetType(b2Body.b2_staticBody);
					break;
					case "dynamic":
						body.SetType(b2Body.b2_dynamicBody);
					break;
					case "kinematic":
						body.SetType(b2Body.b2_kinematicBody);
					break;
				}
			}
			if (data.rotation.length()) {
				body.SetAngle(Number(data.rotation) * Math.PI / 180);
			}
			if (data.isBullet.length()) {
				body.SetBullet(data.isBullet == "true");
			}
			
			var bx : Number = data.@x.length() ? Number(data.@x) : 0;
			var by : Number = data.@y.length() ? Number(data.@y) : 0;
			body.SetPosition(new b2Vec2(bx, by));
			
			var fd : b2FixtureDef;
			var w : Number;
			var h : Number;
			var sx : Number;
			var sy : Number;
			var angle : Number;
			var fix : b2Fixture;
			var r : Number;
			
			for each(var item : * in data.*) {
				var n : String = item.name();
				switch (n) {
					case SHAPE_BOX:
						fd = copyFixtureDef(defFixtureDef);
						w = item.width.length() ? Number(item.width) : 1;
						h = item.height.length() ? Number(item.height) : 1;
						sx = item.@x.length() ? Number(item.@x) : 0;
						sy = item.@y.length() ? Number(item.@y) : 0;
						angle = item.angle.length() ? Number(item.angle) * Math.PI / 180 : 0;
						initFixtureDef(fd, item);
						fix = addBox(sx, sy, w, h, angle, 0, fd);
						if (item.density.length()) {
							fix.SetDensity(Number(item.density));
						}
					break;
					
					case SHAPE_CIRCLE:
						fd = copyFixtureDef(defFixtureDef);
						r = item.radius.length() ? Number(item.radius) : 1;
						sx = item.@x.length() ? Number(item.@x) : 0;
						sy = item.@y.length() ? Number(item.@y) : 0;
						initFixtureDef(fd, item);
						fix = addCircle(sx, sy, r, 0, fd);
						if (item.density.length()) {
							fix.SetDensity(Number(item.density));
						}
					break;
					
					case SHAPE_CONVEX:
						var geom : GeomAsset = ResManager.getGeomAsset(item.src);
						if (geom == null) {
							trace("Невозможно загрузить ресурс модели: '" + item.src + "'");
							break;
						}
						
						var len : int = geom.geoms.length;
						var tmpFixtures : Array = new Array();
						for (var i:int = 0; i < len; i++) {
							fd = copyFixtureDef(defFixtureDef);
							tmpFixtures.push(addConvex(0, 0, geom.geoms[i], 0, 1, fd));
						}
						/*sx = item.@x.length() ? Number(item.@x) : 0;
						sy = item.@y.length() ? Number(item.@y) : 0;
						initFixtureDef(fd, item);
						fix = addCircle(sx, sy, r, 0, fd);
						if (item.density.length()) {
							fix.SetDensity(Number(item.density));
						}*/
					break;
				}
			}
		}
		
		override public function init() : void {
			initPhysics();
			addCallback(StateEvent.INIT, initHandler);
			addCallback(PhysEvent.UPDATE_BODY, updateBodyHandler);
			addCallback(FollowEvent.REGISTER_FOLLOW, regFollowHandler);
			addCallback(FollowEvent.UPDATE_FOLLOW, updateFollowHandler);
		}
		
		private function updateFollowHandler(e : FollowEvent):void{
			updateFollow();
		}
		
		private function updateBodyHandler(e : PhysEvent):void{
			updateFollow();
		}
		
		private function regFollowHandler(e : FollowEvent):void{
			follow = e.getFollow();
		}
		
		private function initHandler(e : StateEvent):void {
			var go : GameObject = owner.searchDecorator(GameObject.NAME) as GameObject;
			if (go != null) {
				body.SetPosition(new b2Vec2(go.x, go.y));
				body.SetAngle(go.rotation);
			}
			var sh : b2Fixture = body.GetFixtureList();
			while (sh) {
				sh.SetUserData(this);
				sh = sh.GetNext();
			}
			body.SetUserData(this);
		}
		
		public function initPhysics() : void {
			if (_physInited) return;
			_physInited = true;
			
			bodyDef = new b2BodyDef();
			bodyDef.type = initType;
			_body = Physics.instance.world.CreateBody(bodyDef);
		}
		
		/**
		 * Добавление окружности к телу
		 * Если передан fixtureDef, параметр density игнорируется
		 */
		public function addCircle(x : Number, y : Number, radius : Number, density : Number = 1, fixtureDef : b2FixtureDef = null) : b2Fixture {
			initPhysics();
			var sh : b2CircleShape = new b2CircleShape(radius);
			sh.SetLocalPosition(new b2Vec2(x, y));
			if (fixtureDef == null) {
				fixtureDef = new b2FixtureDef();
				fixtureDef.density = density;
			}
			fixtureDef.shape = sh;
			if (owner) {
				fixtureDef.userData = this;
			}
			return body.CreateFixture(fixtureDef);
		}
		
		/**
		 * Добавление прямоугольника к телу.
		 * Если передан fixtureDef, параметр density игнорируется
		 */
		public function addBox(x : Number, y : Number, w : Number, h : Number, ang : Number = 0, density : Number = 1, fixtureDef : b2FixtureDef = null) : b2Fixture {
			initPhysics();
			var sh : b2PolygonShape = new b2PolygonShape();
			sh.SetAsOrientedBox(w / 2, h / 2, new b2Vec2(x, y), ang);
			if (fixtureDef == null) {
				fixtureDef = new b2FixtureDef();
				fixtureDef.density = density;
			}
			fixtureDef.shape = sh;
			if (owner) {
				fixtureDef.userData = this;
			}
			return body.CreateFixture(fixtureDef);
		}
		
		/**
		 * Добавление конвекса к телу. Данные беруться из объекта геометрии geom
		 * Если передан fixtureDef, параметр density игнорируется
		 */
		public function addConvex(x : Number, y : Number, geom : Geometry, ang : Number = 0, density : Number = 1, fixtureDef : b2FixtureDef = null) : b2Fixture {
			initPhysics();
			var sh : b2PolygonShape = new b2PolygonShape();
			sh.SetAsArray(geom.vertexes, geom.vertexCount);
			if (fixtureDef == null) {
				fixtureDef = new b2FixtureDef();
				fixtureDef.density = density;
			}
			fixtureDef.shape = sh;
			if (owner) {
				fixtureDef.userData = this;
			}
			return body.CreateFixture(fixtureDef);
		}
		
		/**
		 * Добавление произвольного шейпа к телу
		 * Если передан fixtureDef, параметр density игнорируется
		 */
		public function addShape(x : Number, y : Number, shape : b2Shape, ang : Number = 0, density : Number = 1, fixtureDef : b2FixtureDef = null) : b2Fixture {
			initPhysics();
			if (fixtureDef == null) {
				fixtureDef = new b2FixtureDef();
				fixtureDef.density = density;
			}
			fixtureDef.shape = shape;
			if (owner) {
				fixtureDef.userData = this;
			}
			return body.CreateFixture(fixtureDef);
		}
		
		override protected function destroy() : void {
			Physics.instance.world.DestroyBody(body);
			_body = null;
			bodyDef = null;
			fixture = null;
			follow = null;
		}
		
		/**
		 * Получение ссылки на тело. Если тело ещё не создано, происходит его инициализация.
		 */
		public function get body() : b2Body { 
			if (!_physInited) initPhysics(); // Нафик тут условие которое всё равно проверяется внутри initPhysics? Чтоб лишний раз не дёргать метод.
			return _body;
		}
		
		public function getFollowPositionX() : Number {
			return body.GetPosition().x;
		}
		
		public function getFollowPositionY() : Number {
			return body.GetPosition().y;
		}
		
		public function getFollowAngle() : Number {
			return body.GetAngle();
		}
		
		public function updateFollow() : void {
			if (follow) {
				follow.update(this);
			}
		}
	}
	
}