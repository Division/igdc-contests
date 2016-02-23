package physics {
	import Box2D.Collision.b2Manifold;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.Contacts.b2Contact;
	import decorator.Decoratable;
	import decorator.Decorator;
	import decorator.DecorEvent;
	
	/**
	 * Событие слушателя контактов
	 * @author Division
	 */
	public class PhysContactEvent extends DecorEvent{
		
		public static const BEGIN 		: String = "PhysContactBegin";
		public static const END 		: String = "PhysContactEnd";
		public static const PRE_SOLVE 	: String = "PhysContactPreSolve";
		public static const POST_SOLVE 	: String = "PhysContactPostSolve";
		
		public var contact 	: b2Contact = null;
		public var manifold : b2Manifold = null;
		public var impulse 	: b2ContactImpulse = null;
		
		public var fixtureA : b2Fixture;
		public var fixtureB : b2Fixture;
		public var targetShape 	: b2Shape;
		public var selfShape	: b2Shape;
		
		/**
		 * Объект Decoratable, ему посылается само событие
		 */
		public var object : Decoratable;
		
		/**
		 * Декоратор, на который ссылается shape, вызвавший событие
		 */
		public var decor  : Decorator;
		
		public function PhysContactEvent(type : String, fixtureA : b2Fixture, fixtureB : b2Fixture, contact : b2Contact, manifold : b2Manifold = null, impulse : b2ContactImpulse = null) {
			super(type);
			this.fixtureA = fixtureA;
			this.fixtureB = fixtureB;
			this.contact = contact;
			this.manifold = manifold;
			this.impulse = impulse;
			this.selfShape = fixtureA.GetShape();
			this.targetShape = fixtureB.GetShape();
			this.decor = fixtureA.GetUserData() as Decorator;
			this.object = this.decor.owner;
		}
		
	}

}