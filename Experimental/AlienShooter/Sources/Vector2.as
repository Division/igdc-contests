class Vector2 {
	
	public var x;
	public var y;	
	
	public static function Vec(px,py) {
		return new Vector2(px,py);
	}
	
	public static function vmin(v1 : Vector2, v2 : Vector2) {
		var res = new Vector2(0,0);
		res.x = (v2.x<v1.x) ? v2.x : v1.x;
		res.y = (v2.y<v1.y) ? v2.y : v1.y;
		return res;
	}

	public static function vmax(v1 : Vector2, v2 : Vector2) {
		var res = new Vector2(0,0);
		res.x = (v2.x>v1.x) ? v2.x : v1.x;
		res.y = (v2.y>v1.y) ? v2.y : v1.y;
		return res;
	}
	
	public static function VLength(v1,v2 : Vector2) {
		return Math.sqrt((v2.x-v1.x)*(v2.x-v1.x)+(v2.y-v1.y)*(v2.y-v1.y));
	}
	
	public static function GetNormal(v1,v2 : Vector2) {
		return new Vector2(v1.y-v2.y,v2.x-v1.x);
	}
	
	public function Normal() {		
		return new Vector2(-y,x);
	}
	
	public function Dot(v : Vector2) {
		return x*v.x+y*v.y;		
	}
	
	public function Vector2(px, py) {
		FromXY(px,py);
	}	
	
	public function From(v : Vector2) {
		x = v.x;
		y = v.y;
	}
	
	public function FromXY(px,py) {
		x = px;
		y = py;		
	}
	
	public function Add(v : Vector2) {
		x+=v.x;
		y+=v.y;
	}
	
	public function Sub(v : Vector2) {
		x-=v.x;
		y-=v.y;
	}
	
	public function Mult(n : Number) {
		x*=n;
		y*=n;
	}
	
	public function Normalize() {
		var l = len();
		if (!l) return;
		x /= l;
		y /= l;
	}
	
	public function len() {
		return Math.sqrt(x*x+y*y);
	}
	
	public function SqLength() { // Квадрат длины
		return x*x+y*y;
	}
	
	public function toString() {
		return x+","+y;
	}
}