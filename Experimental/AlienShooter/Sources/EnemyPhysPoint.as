class EnemyPhysPoint extends PhysPoint { // Мячи могут проваливаться вниз и отталкиваться от стен...

	public var radius;
	
	public function EnemyPhysPoint(r) {
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
		
		Pos.From(v);
	}
}