class Ball extends MovieClip{
	public var point : BallPhysPoint;
	public var radius : Number;
	public var Die = false;
	
	function Ball() {
		radius = 23;
		point = new BallPhysPoint(radius);
		point.SetMass(5);
	}
	
	public function Update() {
		point.Move();
		_x = point.Pos.x;
		_y = point.Pos.y;
		if (Key.isDown(Key.SPACE)) {
			point.SetPos(200,200);
		}
		if (point.Pos.y>700) Die = true;		
	}
}