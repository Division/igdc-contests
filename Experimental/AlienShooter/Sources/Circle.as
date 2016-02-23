class Circle {
	public var radius;
	public var point : EnemyPhysPoint;
	
	public function Circle(x,y,r) {
		radius = r;
		point = new EnemyPhysPoint(r);
		point.SetPos(x,y);
	}
}