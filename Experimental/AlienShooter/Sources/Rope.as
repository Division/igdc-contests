import flash.display.BitmapData;

class Rope { // Ацкий класс верёвки и сопутствующих вычислений
	public var ST_LEFT = 10;
	public var ST_RIGHT = 630;	
	public var TOP = 300;
	public var MinLeft : Vector2;
	public var MinRight : Vector2;	
	public var MoveWidth : Number;
	public var MoveHeight : Number;	
	public var VSpeed = 7;
	public var HMSpeed = 7;
	public var HFSpeed = 20;
	
	public var points : Array;
	public var canvas;
	public var balls;
	public var enemies;
	public var bonuses;
	public var LeftPoint : tmp;
	public var RightPoint : tmp;
	public var wid;
	public var leftPos : Vector2;
	public var rightPos : Vector2;
	
	public var RopeSeg : Array;
	public var RopeCir : Array;
	
	public var disabled;
	
	public function Rope(cnv,bls,enem,bon) {
		canvas = cnv;
		enemies = enem;
		balls = bls; // Шары
		bonuses = bon;
		points = new Array();
		RopeSeg = new Array();
		MoveWidth = 200;
		MoveHeight = 250;		
		MinLeft = new Vector2(ST_LEFT,TOP-100);
		MinRight = new Vector2(ST_RIGHT,TOP-100);
		RopeCir = new Array();
		
		disabled = 0;
		
		Init(15);
	}
	
	public function SetVars(canv,b,enem,bon) {
		canvas = canv;
		enemies = enem;
		balls = b; // Шары
		bonuses = bon;
	}
	
	public function GenRopeClips(n) {
		for (var i=0; i<n; i++) {
			var tmp = _root.attachMovie("rope","rope", _root.getNextHighestDepth());
			RopeSeg.push(tmp);
			tmp._x = points[i].point.Pos.x;
			tmp._y = points[i].point.Pos.y;
		}
		tmp = _root.attachMovie("RopeCir","ropecir", _root.getNextHighestDepth());
		tmp._x = points[0].point.Pos.x;
		tmp._y = points[0].point.Pos.y;		
		RopeCir.push(tmp);
		tmp = _root.attachMovie("RopeCir","ropecir", _root.getNextHighestDepth());
		tmp._x = points[points.length-1].point.Pos.x;
		tmp._y = points[points.length-1].point.Pos.y;		
		RopeCir.push(tmp);		
	}
	
	public function UpdateRopeClips(Dists) {
		var ang = 0;
		var len = RopeSeg.length;
		for (var i=0; i<len; i++) {
			ang = dMath.GetAngle(points[i+1].point.Pos.x-points[i].point.Pos.x,points[i+1].point.Pos.y-points[i].point.Pos.y);
			RopeSeg[i]._rotation=ang;
			RopeSeg[i]._x = points[i].point.Pos.x;
			RopeSeg[i]._y = points[i].point.Pos.y;
			// Вот здесь нам бы пришлось ещё раз считать длину каждого сегмента верёвки,
			// не будь мы достаточно хитры (:
			RopeSeg[i]._xscale = (Dists[i]/50)*(i==len-1?100:105); // Вернее было бы написать 100, но 105 смотрится ИМХО лучше
		}
		RopeCir[0].Update(leftPos);
		RopeCir[1].Update(rightPos);
	}
	
	public function Left() {
		leftPos.y += VSpeed;
		rightPos.y -= VSpeed;
		ApplyBounds();
	}
	public function Right() {
		leftPos.y -= VSpeed;
		rightPos.y += VSpeed;		
		ApplyBounds();		
	}
	public function Down() {
		leftPos.x += HMSpeed;
		rightPos.x -= HMSpeed;				
		ApplyBounds();
	}
	public function Up() {
		leftPos.x -= HFSpeed;
		rightPos.x += HFSpeed;
		ApplyBounds();
	}
	
	public function ApplyBounds() { // Не позволяем крайним точкам уходить дальше положенного
		leftPos.From(Vector2.vmin(leftPos,new Vector2(MinLeft.x+MoveWidth,MinLeft.y+MoveHeight)));
		leftPos.From(Vector2.vmax(leftPos,new Vector2(MinLeft.x,MinLeft.y)));
		rightPos.From(Vector2.vmax(rightPos,new Vector2(MinRight.x-MoveWidth,MinRight.y)));
		rightPos.From(Vector2.vmin(rightPos,new Vector2(MinRight.x,MinRight.y+MoveHeight)));
	}
	
	public function Init(count) { // Угадай что
		var temp : RopePoint;
		
		wid = (ST_RIGHT-ST_LEFT)/(count-1);
		for (var i=0; i<count; i++) {
			temp = new RopePoint();
			temp.point.SetPos(ST_LEFT+wid*i,TOP);
			points.push(temp);
		}
		leftPos = new Vector2(points[0].point.Pos.x,points[0].point.Pos.y);
		rightPos = new Vector2(points[points.length-1].point.Pos.x,points[points.length-1].point.Pos.y)
		GenRopeClips(count-1);
	}
	
	public function Update() {
		
		if (disabled > 0) disabled--;
		
		var Dists = new Array;
		
		for (var i=0; i<points.length; i++) {
			points[i].Update();
		}
		
		for(var j=0; j<2; j++)
			for (i=0; i<points.length-1; i++) {
				// Небольшая хитрость. Нам ещё потребуются длины сегментов верёвки
				// Так что посчитаем их на этапе расслабления и будем использовать где нужно.
				Dists.push(Physics.HandleConstraint(points[i].point,points[i+1].point,wid*0.7));
			}

		// Крайние точки неподвижны...
		points[0].point.Pos.From(leftPos);
		points[points.length-1].point.Pos.From(rightPos);
		
		// Самая черная и жестокая часть игры. Проверка столкновений веревки с шарами
		if (balls.length) {
			for (i=0; i<points.length-1; i++) {
				for (j=0; j<balls.length; j++)
					Physics.HandleCollision(points[i+1].point,points[i-1].point,balls[j]);
			}

			for (i=0; i<balls.length; i++)
				for(j=0; j<2; j++) {
					RopeCir[j].Collision(balls[i].point,balls[i].radius);
				}
		}
		
		// Столконовение мячей друг с другом 
		var obj = new Object();
		if (balls.length>1) {
			for (i=0; i<balls.length; i++)
				for (j=0; j<balls.length; j++) 
					if (i!=j && !obj[i+"_"+j] && !obj[j+"_"+i]) {
						if (dMath.CircleVsCircle(balls[i],balls[j])) {
							Physics.HandleConstraint(balls[i].point,balls[j].point,balls[i].radius+balls[j].radius);
						}
						obj[i+"_"+j] = true; // Это позволит не проверять столкновения двух одинаковых мячей дважды
					}
		}
		
		// Враги сталкиваются с верёвкой
		obj = new Array();
		if (enemies.length) {
			if (disabled<=0)
				for (i=0; i<points.length-1; i++)
					for (j=0; j<enemies.length; j++) {
						for (var k=0; k<enemies[j].circles.length; k++)
							if ((enemies[j].Broke || enemies[j]._y>280) && enemies[j].Check<=0) {
								obj[k] = Physics.HandleCollision(points[i+1].point,points[i].point,enemies[j].circles[k]);
							}
							
						if (dMath.LineVsLine(enemies[j].circles[0].point.Pos,enemies[j].circles[1].point.Pos,points[i+1].point.Pos,points[i].point.Pos)) {
							enemies[j].Check = 30;
						}
					}
						
			// Столкновение врагов с шарами
			if (balls.length && enemies.length)
			for (i=0; i<enemies.length; i++)
				for (j=0; j<balls.length; j++) {
					enemies[i].BallCollision(balls[j]);
				}
			// Столкновение врагов с врагами
			obj = new Array();
			for (i=0; i<enemies.length; i++)
				for (j=0; j<enemies.length; j++)
					if (i!=j && !obj[i+"_"+j] && !obj[j+"_"+i]) {
						enemies[i].EnemyCollision(enemies[j]);
						obj[i+"_"+j]=true;
					}
					
			// Столкновение врагов с шарами верёвки
			var tv = new Vector2();
			for (i=0; i<enemies.length; i++)
				for(j=0; j<2; j++) {
					tv.FromXY(enemies[i].pos.x,enemies[i].pos.y);
					tv.Sub(RopeCir[j].point.Pos);
					if (tv.SqLength() < (RopeCir[j].radius+enemies[i].radius)*(RopeCir[j].radius+enemies[i].radius)) {
						for (var b=0; b<enemies[i].circles.length; b++) {
							RopeCir[j].Collision(enemies[i].circles[b].point,enemies[i].circles[b].radius);
						}
					}
				}
		}

		if (bonuses.length) {
			// Бонусы сталкиваются с верёвкой
			for (i=0; i<points.length-1; i++)
				for (j=0; j<bonuses.length; j++)
					for (var k=0; k<bonuses[j].circles.length; k++)
						if (bonuses[j]._y>150)
							Physics.HandleCollision(points[i+1].point,points[i-1].point,bonuses[j].circles[k]);			
			
			// Бонусы сталкиваются с шарами
			if (balls.length && bonuses.length)
			for (i=0; i<bonuses.length; i++) {
				for (j=0; j<balls.length; j++) {
					bonuses[i].BallCollision(balls[j]);
				}
				
				for(j=0; j<2; j++) {
					RopeCir[j].Collision(bonuses[i].circles[0].point,bonuses[i].radius);
				}												
				
			}
			
			// Бонусы сталкиваются с врагами
			obj = new Array();
			for (i=0; i<enemies.length; i++)
				for (j=0; j<bonuses.length; j++)
					if (!obj[i+"_"+j] && !obj[j+"_"+i]) {
						enemies[i].EnemyCollision(bonuses[j]);
						obj[i+"_"+j]=true;
					}				
		}
		
		UpdateRopeClips(Dists);
	}
}