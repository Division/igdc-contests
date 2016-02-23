class BasicEnemy extends MovieClip{ // Базовый класс для врага(и бонусов).
	// Любой объект будем представлять как набор окружностей
	// со связями.
	
	public static var canvas;
	public static var gameman;
	
	public var LastHit;
	
	public var Health;
	public var circles : Array;
	public var constraints : Array;
	public var Die = false;
	public var Broke = false;
	public var radius;
	
	public var Hitc;
	public var pos;
	
	public var Check;
	
	public function BasicEnemy() {
		radius = 100;
		Hitc = 0;
		circles = new Array();
		constraints = new Array();
		LastHit = 0;
		pos = new Vector2();
		Check = 0;
	}
	
	public function SetPos(x,y) {
		for (var i=0; i<circles.length; i++) {
			circles[i].point.Pos.Add(new Vector2(x,y));
			circles[i].point.PrevPos.Add(new Vector2(x,y));
		}
	}
	
	public function AddCircle(x,y,r) {
		var cir = new Circle(x,y,r);		
		circles.push(cir);
		return circles.length-1;
	}
	
	public function AddConstraint(bi1, bi2, len) {
		var obj = new Object();
		obj.b1 = bi1;
		obj.b2 = bi2;
		obj.len = len;
		constraints.push(obj);
	}
	
	public function HandleConstraints() {
		if (constraints.length && (circles.length > 1)) {
			for (var i=0; i<constraints.length; i++) {
				Physics.HandleConstraint(circles[constraints[i].b1].point,circles[constraints[i].b2].point,constraints[i].len);
			}
		}
	}
	
	public function BallCollision(b : Ball) {
		for (var i=0; i<circles.length; i++) {
			if (dMath.CircleVsCircle(b,circles[i])) {
				Physics.HandleConstraint(b.point,circles[i].point,b.radius+circles[i].radius);
				if (getTimer()-LastHit > 100) {
					Health--;
					Hitc = 1;
					LastHit = getTimer();
				}
			}
		}
		
	}
	
	public function EnemyCollision(e : BasicEnemy) {
		var v = new Vector2(pos.x-e.pos.x,pos.y-e.pos.y);		
		if (v.SqLength()<(e.radius+radius)*(e.radius+radius)) {
			var obj = new Object();
			for (var i=0;i<circles.length; i++)
				for (var j=0;j<e.circles.length; j++) 
					if (!obj[j+"_"+i] && !obj[i+"_"+j] && dMath.CircleVsCircle(circles[i],e.circles[j])) {
						Physics.HandleConstraint(circles[i].point,e.circles[j].point,circles[i].radius+e.circles[j].radius);
						obj[j+"_"+i] = true;
					}
		}
	}
	
	public function Update() {
		for (var i=0; i<circles.length; i++) {
			circles[i].point.Move();			
		}
		
		if (Check > 0) Check-=1;
		
		HandleConstraints();		
		pos.FromXY(0,0);
		for (var i=0; i<circles.length; i++) {
			pos.Add(circles[i].point.Pos);
		}
		pos.Mult(1/circles.length);
	}
}