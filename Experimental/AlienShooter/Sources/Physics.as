class Physics {
	// Расслабление
	public static function HandleConstraint(point1 : PhysPoint, point2 : PhysPoint, dist : Number) {
		var p1 = new Vector2(point1.Pos.x,point1.Pos.y);
		var p2 = new Vector2(point2.Pos.x,point2.Pos.y);		
		var delta = new Vector2(p2.x-p1.x, p2.y-p1.y);
		var restl = dist*dist;
		var deltalength = Math.sqrt(delta.Dot(delta));
		var diff = deltalength*(point1.m+point2.m);
		if (diff) {
			diff = (deltalength-dist)/diff;
		}
		var tv1 = new Vector2(delta.x,delta.y);
		var tv2 = new Vector2(delta.x,delta.y);		
		tv1.Mult(point1.m*0.5*diff);
		tv2.Mult(point2.m*0.5*diff);		
		p1.Add(tv1);
		p2.Sub(tv2);
		point1.Pos.From(p1);
		point2.Pos.From(p2);		
		return deltalength;
	}
	
	// Обработка столкновения отрезка с окружностью
	public static function HandleCollision(point1 : PhysPoint, point2 : PhysPoint, ball : Ball) {
		var obj = new Object();
		if (dMath.LineVsCircle(point1.Pos,point2.Pos,ball,obj)) {
			var sign = dMath.Sign(dMath.Orient(point1.PrevPos,point2.PrevPos,ball.point.PrevPos));			
			if (!obj.h) return sign;
			var n = Vector2.GetNormal(point1.Pos,point2.Pos);
			n.Normalize();
			if (isNaN(n.x)) return sign;
			var d = Math.abs(ball.radius)-Math.abs(obj.h);
			
			d*=sign;
			
			var nn = new Vector2(n.x,n.y);

			var v2 = new Vector2(n.x,n.y);
			
			n.Mult(d/10*9);
			v2.Mult(d/10);
//			n.Mult(d/2);
//			v2.Mult(d/2);
			ball.point.Pos.Add(n);
			point1.Pos.Sub(v2);
			point2.Pos.Sub(v2);
			return sign;
		}
	}
}