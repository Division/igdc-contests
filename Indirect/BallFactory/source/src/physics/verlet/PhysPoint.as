package physics.verlet {
	import math.Vector2;

	public class PhysPoint {
		
		public static var GRAVITY : Number = 0.1;
		public static var MIN : Vector2 = new Vector2(-1000,-1000); // Их желательно задать 
		public static var MAX : Vector2 = new Vector2(1000,1000); // перед стартом. Иначе будет хреново (:
		public var pos : Vector2; // Координаты
		public var prevPos : Vector2; // Предыдущие координаты
		public var m : Number; // Обратная масса
		
		public function PhysPoint(x : Number,y : Number) { // конструктор
			if (!x) x=0;
			if (!y) y=0;		
			pos = new Vector2(x,y);
			prevPos = new Vector2(x,y);
			m = 1;
		}
		
		public function stop() : void {
			prevPos.from(pos);
		}
		
		public function setPos(x : Number ,y : Number) : void {
			pos.fromXY(x,y);
			prevPos.from(pos);
		}								 
		
		public function getDir() : Vector2 { // Вектор движения частицы
			var v : Vector2 = new Vector2(pos.x,pos.y);
			v.sub(prevPos);
			return v;		
		}
		
		public function getSpeed() : Number { // Скорость частицы
			return Vector2.vLength(pos,prevPos);
		}
		
		public function toString() : String { // Для trace удобно (:
			return "pos: "+pos+" prevPos: "+prevPos+" m: "+m;
		}
		
		public function setVelocity(Velocity : Number) : void { // Установить скорость частицы
			var p : Vector2 = new Vector2(pos.x, pos.y); // Лучше её не юзать, ведь есть addForce (:
			var tmp : Vector2 = new Vector2(pos.x-prevPos.x,pos.y-prevPos.y);
			tmp.normalize();
			tmp.mult(Velocity);
			p.sub(tmp);
			prevPos.from(p);
		}
		
		public function addForce(force : Vector2) : void {// Приложить силу к частице
			prevPos.sub(force);
		}
		
		// Само движение
		public function Move() : void { // Пепец, без перегрузки операторов
			var t : Vector2 = new Vector2(pos.x, pos.y);// это выглядит довольно забавно
			var v : Vector2 = new Vector2(pos.x, pos.y);
			v.mult(2);
			v.sub(prevPos);
			pos.from(v);
			prevPos.from(t);
			
			v.from(Vector2.vmin(pos,MAX));
			v.from(Vector2.vmax(v,MIN));
			pos.from(v);
			// Хочу обработать гравитацию здесь
			addForce(Vector2.vec(0,GRAVITY));
		}
		
		public function SetMass(mass : Number) : void { // Установка массы
			m = 1/mass;
		}
	}

}