package physics {

	import Box2D.Collision.b2ContactPoint;
	import Box2D.Collision.b2Manifold;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2ContactImpulse;
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Dynamics.Contacts.b2Contact;
	import Box2D.Dynamics.Contacts.b2ContactResult;
	import decorator.Decorator;
	
	/**
	 * Слушатель контактов
	 * @author Division
	 */
	public class ContactListener extends b2ContactListener {
		
		public static const EV_BEGIN 		: 	Number = 1 << 0;
		public static const EV_END 			: 	Number = 1 << 1;
		public static const EV_PRE_SOLVE 	: 	Number = 1 << 2;
		public static const EV_POST_SOLVE 	: 	Number = 1 << 3;
		
		/**
		 * О каких событиях оповещать
		 * Смотреть установленные биты
		 */
		public var events : Number = 0;
		
		public function ContactListener(events : Number = 0) {
			if (!events) {
				events = EV_BEGIN | EV_END;
			}
			this.events = events;
		}
		
		override public function BeginContact(contact:b2Contact):void {
			if (events & EV_BEGIN) {
				var b : *;
				b = contact.GetFixtureA().GetBody().GetUserData();
				if (b is Decorator) {
					(b as Decorator).owner.sendEvent(new PhysContactEvent(PhysContactEvent.BEGIN, contact.GetFixtureA(), contact.GetFixtureB(), contact));
				}
				b = contact.GetFixtureB().GetBody().GetUserData();
				if (b is Decorator) {
					(b as Decorator).owner.sendEvent(new PhysContactEvent(PhysContactEvent.BEGIN, contact.GetFixtureB(), contact.GetFixtureA(), contact));
				}
			}
		}
		
		override public function EndContact(contact:b2Contact):void {
			if (events & EV_END) {
				var b : *;
				b = contact.GetFixtureA().GetBody().GetUserData();
				if (b is Decorator) {
					(b as Decorator).owner.sendEvent(new PhysContactEvent(PhysContactEvent.END, contact.GetFixtureA(), contact.GetFixtureB(), contact));
				}
				b = contact.GetFixtureB().GetBody().GetUserData();
				if (b is Decorator) {
					(b as Decorator).owner.sendEvent(new PhysContactEvent(PhysContactEvent.END, contact.GetFixtureB(), contact.GetFixtureA(), contact));
				}
			}
		}
		
		override public function PreSolve(contact:b2Contact, oldManifold:b2Manifold):void {
			if (events & EV_PRE_SOLVE) {
				var b : *;
				b = contact.GetFixtureA().GetBody().GetUserData();
				if (b is Decorator) {
					(b as Decorator).owner.sendEvent(new PhysContactEvent(PhysContactEvent.PRE_SOLVE, contact.GetFixtureA(), contact.GetFixtureB(), contact, oldManifold));
				}
				b = contact.GetFixtureB().GetBody().GetUserData();
				if (b is Decorator) {
					(b as Decorator).owner.sendEvent(new PhysContactEvent(PhysContactEvent.PRE_SOLVE, contact.GetFixtureB(), contact.GetFixtureA(), contact, oldManifold));
				}
			}
		}
		
		override public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse):void {
			if (events & EV_POST_SOLVE) {
				var b : *;
				b = contact.GetFixtureA().GetBody().GetUserData();
				if (b is Decorator) {
					(b as Decorator).owner.sendEvent(new PhysContactEvent(PhysContactEvent.POST_SOLVE, contact.GetFixtureA(), contact.GetFixtureB(), contact, null, impulse));
				}
				b = contact.GetFixtureB().GetBody().GetUserData();
				if (b is Decorator) {
					(b as Decorator).owner.sendEvent(new PhysContactEvent(PhysContactEvent.POST_SOLVE, contact.GetFixtureB(), contact.GetFixtureA(), contact, null, impulse));
				}
			}
		}
		
	}

}