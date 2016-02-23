package physics.verlet {
	
	import math.Vector2;
	
	public class VerletPhysics {
		// Расслабление
		public static function handleConstraint(point1 : PhysPoint, point2 : PhysPoint, dist : Number) : Number {
			var p1 : Vector2 = new Vector2(point1.pos.x,point1.pos.y);
			var p2 : Vector2 = new Vector2(point2.pos.x,point2.pos.y);		
			var delta : Vector2 = new Vector2(p2.x-p1.x, p2.y-p1.y);
			var restl : Number = dist*dist;
			var deltalength : Number = Math.sqrt(delta.dot(delta));
			var diff : Number = deltalength*(point1.m+point2.m);
			if (diff) {
				diff = (deltalength-dist)/diff;
			}
			var tv1 : Vector2 = new Vector2(delta.x,delta.y);
			var tv2 : Vector2 = new Vector2(delta.x,delta.y);		
			tv1.mult(point1.m*0.5*diff);
			tv2.mult(point2.m*0.5*diff);		
			p1.add(tv1);
			p2.sub(tv2);
			point1.pos.from(p1);
			point2.pos.from(p2);		
			return deltalength;
		}
		
		// Обработка столкновения отрезка с окружностью
		/*public static function HandleCollision(point1 : PhysPoint, point2 : PhysPoint, ball : Ball) {
			var obj = new Object();
			if (dMath.LineVsCircle(point1.pos,point2.pos,ball,obj)) {
				var sign = dMath.Sign(dMath.Orient(point1.Prevpos,point2.Prevpos,ball.point.Prevpos));			
				if (!obj.h) return sign;
				var n = Vector2.GetNormal(point1.pos,point2.pos);
				n.Normalize();
				if (isNaN(n.x)) return sign;
				var d = Math.abs(ball.radius)-Math.abs(obj.h);
				
				d*=sign;
				
				var nn = new Vector2(n.x,n.y);

				var v2 = new Vector2(n.x,n.y);
				
				n.mult(d/10*9);
				v2.mult(d/10);
	//			n.mult(d/2);
	//			v2.mult(d/2);
				ball.point.pos.add(n);
				point1.pos.sub(v2);
				point2.pos.sub(v2);
				return sign;
			}
		}*/
	}
	
}