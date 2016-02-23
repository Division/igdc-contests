class dMath {
	static var deg2rad = Math.PI/180;
	static var rad2deg = 180/Math.PI;
	
	// Расстояние от точки до отрезка
	public static function DistToSegment(p : Vector2, v1 : Vector2, v2 : Vector2) {
		var v = new Vector2(v2.x,v2.y);
		v.Sub(v1);
		var w = new Vector2(p.x,p.y);
		w.Sub(v1);
		var c1 = w.Dot(v);
		if (c1 <= 0) {
			return Vector2.VLength(p,v1);
		}
		var c2 = v.Dot(v);
		if (c2 <= c1) {
			return Vector2.VLength(p,v2);
		}
		if (!c2) return 10000; // Мегазаплатка (:
		var b = c1/c2;
		v.Mult(b);
		var Pb = new Vector2(v1.x,v1.y);
		Pb.Add(v);
		return Vector2.VLength(p,Pb);	
	}
	
	// Пересекается ли отрезок с окружностью?
	public static function LineVsCircle(v1 : Vector2, v2 : Vector2, Circle:Ball, obj : Object) {
		var h : Number;
		if ((h = dMath.DistToSegment(Circle.point.Pos,v1,v2)) < Circle.radius) {
			obj.h = h;
			return true;
		}
		return false;
	}
	
	// Сталкиваются ли две окружности?
	public static function CircleVsCircle(c1 : Ball, c2 : Ball) {
		var v = new Vector2(c1.point.Pos.x-c2.point.Pos.x,c1.point.Pos.y-c2.point.Pos.y);
		// Говорят, что квадратный корень это плохо. Не будем его использовать (:
		return v.SqLength() < (c1.radius + c2.radius)*(c1.radius + c2.radius);
	}
	
	public static function GetAngle(x,y) { // в градусах
		return Math.atan2(y,x)*rad2deg;
	}
	
	public static function GetAngleR(x,y) { // в радианах
		return Math.atan2(y,x);
	}
	
	// Знак полуплоскости
	public static function Orient(v1 : Vector2, v2 : Vector2, p : Vector2) {
		// return (a->x - c->x)*(b->y - c->y) - (a->y - c->y) * (b->x - c->x);
		return (v1.x - p.x)*(v2.y - p.y) - (v1.y - p.y)*(v2.x - p.x);
	}
	
	// Возвращает знак числа. 1 или -1 (ну или 0)
	public static function Sign(v : Number) {
		if (v>0) return 1;
		if (v<0) return -1;
		return 0;
	}
	
	public static function LineVsLine(v1 : Vector2, v2 : Vector2, v3 : Vector2, v4: Vector2) {
		var zn = (v4.y-v3.y)*(v2.x-v1.x)-(v4.x-v3.x)*(v2.y-v1.y);
		var ua = ((v4.x-v3.x)*(v1.y-v3.y)-(v4.y-v3.y)*(v1.x-v3.x))/zn;
		var ub = ((v2.x-v1.x)*(v1.y-v3.y)-(v2.y-v1.y)*(v1.x-v3.x))/zn;
		if ((ua>=0 && ua <=1) && (ub>=0 && ub <=1)) return true;
		return false;
	}
}