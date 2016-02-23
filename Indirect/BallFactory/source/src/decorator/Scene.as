package decorator {
	import decorator.Decoratable;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.ui.Keyboard;
	import game.entities.common.gameobject.GameObject;
	import game.events.StateEvent;
	import game.utils.layers.Layers;
	import math.Vector2;
	import physics.ContactListener;
	import physics.PhysBody;
	import physics.PhysContactEvent;
	import physics.Physics;
	
	/**
	 * @author Division
	 */
	public class Scene extends Sprite {
		
		private static var _instance : Scene = null;
		
		private var _entities : Array/*Decoratable*/;
		
		private var _layers : Layers;
		
		public static function get instance() : Scene {
			if (_instance == null) {
				_instance = new Scene();
			}
			
			return _instance;
		}
		
		public function get layers():Layers { return _layers; }
		
		public function init() : void {
			_entities = new Array();
			_layers = new Layers(-5,5);
			addChild(_layers);
		}
		
		public function addEntity(ent : Decoratable) : void {
			_entities.push(ent);
			_layers.addChildTo(ent, 0);
		}
		
		/**
		 * Удаление всех объектов
		 */
		public function clear() : void {
			for (var i:int = _entities.length - 1; i >= 0; i--) {
				_entities[i].destroy();
				_layers.removeChild(_entities[i]);
				_entities[i] = _entities[_entities.length - 1];
				_entities.pop();
			}
		}
		
		protected function removeDeadEntities() : void {
			for (var i:int = _entities.length - 1; i >= 0; i--) {
				if (_entities[i].timeToDie) {
					_entities[i].destroy();
					_layers.removeChild(_entities[i]);
					_entities[i] = _entities[_entities.length - 1];
					_entities.pop();
				}
			}
		}
		
		public function sendEvent(e : DecorEvent) : void {
			var tmp : Event;
			var len : int = _entities.length;
			for (var i:int = 0; i < len; i++) {
				tmp = e.clone() as Event;
				_entities[i].sendEvent(tmp);
			}
		}
		
		public function update(dt : Number) : void {
			var len : int = _entities.length;
			for (var i:int = 0; i < len; i++) {
				_entities[i].sendEvent(new StateEvent(StateEvent.UPDATE));
			}
			removeDeadEntities();
		}
		
	}

}