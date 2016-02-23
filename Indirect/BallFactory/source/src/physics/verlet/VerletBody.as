package physics.verlet {

	import Box2D.Dynamics.b2Body;
	import decorator.Decorator;
	import flash.display.MovieClip;
	import math.Vector2;
	import physics.Physics;
	
	/**
	 * Декоратор для верлетовой физики
	 * @author Division
	 */
	public class VerletBody extends Decorator {
		
		public static const NAME : String = "VerletBody";
		
		protected var _points : Array/*PhysPoint*/;
		protected var _constraints : Array/*VerletConstraint*/;
		protected var _segments : Array/*VerletSegment*/;
		
		public function VerletBody() {
			_points = new Array();
			_constraints = new Array();
			_segments = new Array();
		}
		
		public function addPoint(point : PhysPoint) : void {
			_points.push(point);
		}
		
		public function addConstraint(p1 : PhysPoint, p2 : PhysPoint, dist : Number) : void {
			var c : VerletConstraint = new VerletConstraint(p1, p1, dist);
			_constraints.push(c);
		}
		
		/**
		 * Добавление отрезка, с которым будет происходить проверка столкновений
		 */
		public function addSegment(p1 : PhysPoint, p2 : PhysPoint) : void {
			var s : VerletSegment = new VerletSegment(p1, p2);
			_segments.push(s);
		}
		
		public function update() : void {
			handleConstraints();
		}
		
		private function handleConstraints():void {
			var len : int = _constraints.length;
			for (var i:int = 0; i < len; i++) {
				_constraints[i].hadle();
			}
		}
		
		/**
		 * Расстановка физических тел в их места согласно частицам
		 */
		public function replaceBodies() : void {
			
		}
		
	}
	
	/**
	 * 
	 */
	internal class VerletConstraint {
		
		/**
		 * Длина, на которую constraint удовлетворён
		 */
		private var _len : Number;
		
		/**
		 * Физическая точка1
		 */
		private var _pointA : PhysPoint;
		
		/**
		 * Физическая точка2
		 */
		private var _pointB : PhysPoint;
		
		public function VerletConstraint(pa : PhysPoint, pb : PhysPoint, dist : Number = 0) {
			_len = dist;
			if (!_len) {
				_len = Vector2.vLength(pa.pos, pb.pos);
			}
			_pointA = pa;
			_pointB = pb;
		}
		
		/**
		 * Расслабление
		 */
		public function handle() : void {
			VerletPhysics.handleConstraint(_pointA, _pointB, _len);
		}
		
	}
	
	/**
	 * Класс для 
	 */
	internal class VerletSegment {
		
		/**
		 * Физическая точка1
		 */
		private var _pointA : PhysPoint;
		
		/**
		 * Физическая точка2
		 */
		private var _pointB : PhysPoint;		
		
		/**
		 * Физическое тело для отрезка
		 */
		private var _segmentBody : b2Body;
		
		public function VerletSegment(pa : PhysPoint, pb : PhysPoint) {
			_pointA = pa;
			_pointB = pb;
			//_segmentBody = Physics.instance.world.CreateBody();
		}
		
	}

}