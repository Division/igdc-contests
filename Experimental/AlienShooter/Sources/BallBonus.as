class BallBonus extends BasicEnemy {
	
	public var ind;
	
	public function BallBonus() {
		Health = 1;
		radius = 30;
		AddCircle(0,0,30);
		ind = 1;
	}
	
	public function Update() {
		super.Update();
		_x = pos.x;
		_y = pos.y;
		
		for (var i=0; i<circles.length; i++) {
			circles[i].point.AddForce(new Vector2(0,PhysPoint.Gravity));
		}
		
		if (pos.y > 700) Die = true;
		
		if (Health<=0) { // Бонус подобрали
			Die = true;
			gameman.HandleBonus(ind);
		}
		
	}
}