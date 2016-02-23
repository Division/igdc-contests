class BallPhysPoint extends PhysPoint { // Мячи могут проваливаться вниз и отталкиваться от стен...

	public var radius;
	
	public function BallPhysPoint(r) {
		radius = r;
	}
	
	public function Move() { 
		var t = new Vector2(Pos.x, Pos.y);
		var v = new Vector2(Pos.x, Pos.y);
		v.Mult(2);
		v.Sub(PrevPos);
		Pos.From(v);
		PrevPos.From(t);
		
		if (v.x<radius) {
			v.x = radius;
			var dir = GetDir();
			dir.x = Math.abs(dir.x);
			PrevPos.x = Pos.x - dir.x/3;
		}
		
		if (v.x>MAX.x-radius) {
			v.x = MAX.x-radius;
			var dir = GetDir();
			dir.x = Math.abs(dir.x);
			PrevPos.x = Pos.x + dir.x/3;
		}
		
		if (v.y<radius) {
			v.y = radius;
			var dir = GetDir();
			dir.y = Math.abs(dir.y);
			PrevPos.y = Pos.y - dir.y/3;
		}		
		
		Pos.From(v);
		// Хочу обработать гравитацию здесь
		AddForce(Vector2.Vec(0,Gravity));
	}
}