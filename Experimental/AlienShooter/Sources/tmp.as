dynamic class tmp extends MovieClip{
	public var point : PhysPoint;
	
	public function tmp() {
		point = new PhysPoint(0,0);
	}
	
	public function onEnterFrame() {
		point.Move();
		_x = point.Pos.x;
		_y = point.Pos.y;
	}
}