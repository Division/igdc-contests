import flash.filters.ColorMatrixFilter;

class EnemyAlien extends BasicEnemy{
	
	public var Dir;
	
	public var Action;
	public var NextTime;
	
	public var maxhealth;
	
	public var SleepTime = 12000;
	
	public var price;

	public var bf;
	
	public function EnemyAlien() {
		price = 100;
		maxhealth = 3;
		Health = maxhealth;
		Action = Math.random()<0.5?1:3;
		Dir = new Vector2(0,0);
		AddCircle(0,-15,20);
		AddCircle(00,15,20);
		AddConstraint(0,1,50);
		circles[0].point.AddForce(new Vector2(-2,1));
		NextTime = getTimer()+Math.floor(Math.random()*2000+1000);
		bf = false;
	}
	
	// Различные фильтры для планетян. При ударе и без сознания
	public function HandleFilters() {
		if (Hitc > 0) {
			var matrix = new Array();			
			if (!bf) {
				matrix = matrix.concat([1, Hitc*0.7, Hitc*0.7, Hitc*0.7, 0]); // red
				matrix = matrix.concat([0, 1-Hitc*0.7, 0, 0, 0]); // green
				matrix = matrix.concat([0, 0, 1-Hitc*0.7 , 0]); // blue
				matrix = matrix.concat([0, 0, 0, 100, 0]); // alpha
				Hitc -= 0.05;
			} else {
				var r = 77/255;
				var g = 150/255;
				var b = 25/255;
				var zerokoef = Hitc/1.7;
				matrix = matrix.concat([r*zerokoef+1-zerokoef, g*zerokoef, b*zerokoef, 0, 0]);
				matrix = matrix.concat([r*zerokoef, g*zerokoef+1-zerokoef, b*zerokoef, 0, 0]);
				matrix = matrix.concat([r*zerokoef, g*zerokoef, b*zerokoef+1-zerokoef, 0, 0]);
				matrix = matrix.concat([0, 0, 0, 1, 0]);
				if(!Broke) Hitc-=0.05;
			}
			var filter = new ColorMatrixFilter(matrix);
			this.filters = [filter];
		} else {
			Hitc = 0;
			bf = false;
			if (this.filters) this.filters = [];
		}
	}
	
	public function Update() {
		super.Update();
		
		if (Health<=0) {
			Broke = true;
			bf = true;
		}
		
		HandleFilters();
		
		var v = new Vector2();
		var tv = new Vector2();
		v.From(circles[0].point.Pos);
		tv.From(circles[1].point.Pos);

		tv.Sub(v);
		v.Add(circles[1].point.Pos);		
		v.Mult(1/2);
		_x = pos.x;
		_y = v.y;
		
		var temp = circles[0].point.GetDir();
		
		Dir.y =  -temp.y/5;
		
		switch(Action) {
			case 1: 
				Dir.x = 0.3;
			break;
			case 3:
				Dir.x = -0.3;
			break;
		}

		if (!Broke && getTimer() > NextTime) {
			NextTime = getTimer()+Math.random()*1000+1500;
			Dir.x = 0;
			Action++;
			if (Action>4) Action = 1;
			circles[0].point.Stop();
		} else if (Broke && pos.y<400) {
			if (getTimer()>NextTime+SleepTime) Broke = false;
			Health = maxhealth;
		}
				
		if (v.y<40) Dir.y = 0.3;
		if (v.y > 180) Dir. y = -0.1;
		
		if (!Broke) {
			circles[1].point.AddForce(new Vector2(Dir.x,Dir.y-1));
			circles[0].point.AddForce(new Vector2(0,1));		
		} else {
			circles[0].point.AddForce(new Vector2(0,PhysPoint.Gravity));
			circles[1].point.AddForce(new Vector2(0,PhysPoint.Gravity));
		}
		
		if (pos.y>700) {
			Die = true;
			GameMan.score+=price;
			gameman.UpdScore();
		}
		
		_rotation = dMath.GetAngle(tv.x,tv.y)+90;
	}
}