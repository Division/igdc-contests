dynamic class RopePoint {
	public var point : PhysPoint;
	
	public function RopePoint() {
		point = new PhysPoint(0,0);
	}
	
	public function Update() {
		point.Move();
	}
}