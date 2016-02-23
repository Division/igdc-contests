package math {
	
	public class Vector2 {
		
		public var x:Number;
		public var y:Number;
		
		public static function vec(px : Number, py : Number) : Vector2 {
			return new Vector2(px,py);
		}
		
		public static function vmin(v1 : Vector2, v2 : Vector2) : Vector2 {
			var res : Vector2 = new Vector2(0,0);
			res.x = (v2.x<v1.x) ? v2.x : v1.x;
			res.y = (v2.y<v1.y) ? v2.y : v1.y;
			return res;
		}
	
		public static function vmax(v1 : Vector2, v2 : Vector2) : Vector2 {
			var res : Vector2 = new Vector2(0,0);
			res.x = (v2.x>v1.x) ? v2.x : v1.x;
			res.y = (v2.y>v1.y) ? v2.y : v1.y;
			return res;
		}
		
		public function equal(v : Vector2) : Boolean {
			return Math.abs(v.x - x) < 0.00001 && Math.abs(v.y - y) < 0.00001;
		}
		
		public static function vLength(v1 : Vector2, v2 : Vector2) : Number {
			return Math.sqrt((v2.x-v1.x)*(v2.x-v1.x)+(v2.y-v1.y)*(v2.y-v1.y));
		}
		
		public static function vSqLength(v1 : Vector2, v2 : Vector2) : Number { // Квадрат длины
			return (v2.x-v1.x)*(v2.x-v1.x)+(v2.y-v1.y)*(v2.y-v1.y);
		}		
		
		public static function getNormal(v1 : Vector2, v2 : Vector2) : Vector2 {
			return new Vector2(v1.y-v2.y,v2.x-v1.x);
		}
		
		public function normal() : Vector2 {		
			return new Vector2(-y,x);
		}
		
		public function dot(v : Vector2) : Number {
			return x*v.x+y*v.y;		
		}
		
		public function Vector2(px:Number=0, py:Number=0) : void {
			fromXY(px,py);
		}	
		
		public function from(v : Vector2) : void {
			x = v.x;
			y = v.y;
		}
		
		public function fromXY(px : Number, py : Number) : void {
			x = px;
			y = py;
		}
		
		public function add(v : Vector2) : void {
			x+=v.x;
			y+=v.y;
		}
		
		public function sub(v : Vector2) : void {
			x-=v.x;
			y-=v.y;
		}
		
		public function mult(n : Number) : void {
			x*=n;
			y*=n;
		}
		
		public function normalize() : void {
			var l : Number = len();
			if (!l) return;
			x /= l;
			y /= l;
		}
		
		public function len() : Number {
			return Math.sqrt(x*x+y*y);
		}
		
		public function sqLength() : Number { // Квадрат длины
			return x*x+y*y;
		}
		
		public function toString() : String {
			return x+","+y;
		}
	}

}