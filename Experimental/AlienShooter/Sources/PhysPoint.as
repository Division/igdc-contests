class PhysPoint {
	public static var Gravity = 0.1;
	public static var MIN : Vector2; // Их желательно задать 
	public static var MAX : Vector2; // перед стартом. Иначе будет хреново (:
	public var Pos : Vector2; // Координаты
	public var PrevPos : Vector2; // Предыдущие координаты
	public var m : Number; // Обратная масса
	
	public function PhysPoint(x,y) { // конструктор
		if (!x) x=0;
		if (!y) y=0;		
		Pos = new Vector2(x,y);
		PrevPos = new Vector2(x,y);
		m = 1;
	}
	
	public function Stop() {
		PrevPos.From(Pos);
	}
	
	public function SetPos(x,y) {
		Pos.FromXY(x,y);
		PrevPos.From(Pos);
	}								 
	
	public function GetDir() { // Вектор движения частицы
		var v = new Vector2(Pos.x,Pos.y);
		v.Sub(PrevPos);
		return v;		
	}
	
	public function GetSpeed() { // Скорость частицы
		return Vector2.VLength(Pos,PrevPos);
	}
	
	public function toString() { // Для trace удобно (:
		return "Pos: "+Pos+" PrevPos: "+PrevPos+" m: "+m;
	}
	
	public function SetVelocity(Velocity : Number) { // Установить скорость частицы
		var p = new Vector2(Pos.x, Pos.y); // Лучше её не юзать, ведь есть AddForce (:
		var tmp = new Vector2(Pos.x-PrevPos.x,Pos.y-PrevPos.y);
		tmp.Normalize();
		tmp.Mult(Velocity);
		p.Sub(tmp);
		PrevPos.From(p);
	}
	
	public function AddForce(force : Vector2) {// Приложить силу к частице
		PrevPos.Sub(force);
	}
	
	// Само движение
	public function Move() { // Пепец, без перегрузки операторов
		var t = new Vector2(Pos.x, Pos.y);// это выглядит довольно забавно
		var v = new Vector2(Pos.x, Pos.y);
		v.Mult(2);
		v.Sub(PrevPos);
		Pos.From(v);
		PrevPos.From(t);
		
		v.From(Vector2.vmin(Pos,MAX));
		v.From(Vector2.vmax(v,MIN));
		Pos.From(v);
		// Хочу обработать гравитацию здесь
		AddForce(Vector2.Vec(0,Gravity));
	}
	
	public function SetMass(mass : Number) { // Установка массы
		m = 1/mass;
	}
}