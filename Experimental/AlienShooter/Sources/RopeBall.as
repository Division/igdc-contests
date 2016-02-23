class RopeBall extends MovieClip {

	public var point : PhysPoint;
	public var radius : Number;
	
	public function RopeBall() {
		radius = 20;
		point = new PhysPoint();
		point.SetPos(0,0);
	}
	
	public function Update(np : Vector2) {
		_x = np.x;
		_y = np.y;
		point.PrevPos.From(point.Pos);
		point.Pos.From(np);
	}
	
	public function Collision(p : PhysPoint, r : Number) {
		var v = new Vector2(p.Pos.x-point.Pos.x,p.Pos.y-point.Pos.y);
		var sl = v.SqLength();

		if (sl<(r+radius)*(r+radius)) { // Таки столкновение
			v.Normalize();
			v.Mult(r+radius);
			v.Add(point.Pos);
			p.Pos.From(v);
		}
	}
}