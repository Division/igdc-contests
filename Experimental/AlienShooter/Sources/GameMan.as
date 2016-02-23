import flash.display.BitmapData;

class GameMan {
	
	public var Ready = false;
	public var enemies : Array;	
	public var canvas : MovieClip;
	public var rope : Rope;
	public var CloudMan : CloudManager;
	public var balls : Array; // Массив с мячами		
	public var bonuses : Array; // Массив с бонусами
	public var sky;
	
	public var guiclip;
	public var enemyclip;
	
	public static var score = 0;
	public var scoretext;
	public var livestext;
	
	private var maxenemies;
	private var LastAddTime=0;

	public var lives;
	
	public var ScoreDif;
	public var LastScore;
	
	public var PrevBonus;
	
	public var gpause : Boolean;
	
	public var gomc;
	
	public var startLives;
	
	public var SECRET_CODE = "sviborg";
	public var typed_secret = "";
	
	public var sviborg = false;
	
	public function onKeyUp() {
		if (sviborg) return;
		typed_secret += String.fromCharCode(Key.getAscii());
		typed_secret = typed_secret.substr(-SECRET_CODE.length);
		if (typed_secret==SECRET_CODE) {
			SVIBORG();
		}
	}
	
	public function SVIBORG() {
		sviborg = true;
		var bd = BitmapData.loadBitmap("sviborgimg");
		for (var i=0; i<balls.length; i++) {
			var tc = balls[i].createEmptyMovieClip("tc",balls[i].getNextHighestDepth());
			var b = tc.attachBitmap(bd,100);
			tc._x=-23;
			tc._y=-23;			
		}
	}
	
	public function GameMan() {
		Ready = true;		

		Key.addListener(this);
		
		GenSky();
		CloudMan = new CloudManager();
		
		PrevBonus = 0;
		
		ScoreDif = 300;
		LastScore = 0;
		
		startLives = 3;
		
		lives = startLives;		
		
		gpause = false;
		
		PhysPoint.MIN = new Vector2(0,0);
		PhysPoint.MAX = new Vector2(640,480);
						
		canvas = _root.createEmptyMovieClip("canvas",10000);
		canvas.lineStyle(1, 0x000000, 100);
		
		enemyclip = _root.createEmptyMovieClip("enemyclip",_root.getNextHighestDepth());
		
		balls = new Array();
		enemies = new Array();
		bonuses = new Array();
	
		HandleBonus(1);
		
		maxenemies = 1;
		
		rope = new Rope(canvas,balls,enemies,bonuses);
		BasicEnemy.canvas = canvas;
		BasicEnemy.gameman = this;
		
		guiclip = _root.createEmptyMovieClip("guiclip",999999);		
		scoretext = guiclip.createTextField("score",guiclip.getNextHighestDepth(),10,10,100,20);
		livestext = guiclip.createTextField("lives",guiclip.getNextHighestDepth(),550,10,100,20);

		UpdScore();
	}
	
	public function GenSky() {
		var bd = BitmapData.loadBitmap("sky");
		sky = _root.createEmptyMovieClip("sky", _root.getNextHighestDepth());
		sky.attachBitmap(bd,sky.getNextHighestDepth());
	}
	
	public function HandleBonus(type) {
		switch(type) {
			case 1: // Добавим шар
				AddBall(Math.random()*400+120,50);
			break;
			
			case 2: // Вырубим всех
				for (var i=0; i<enemies.length; i++) {
					enemies[i].Broke = true;
					enemies[i].Hitc = 1;
					enemies[i].bf = true;
				}
			break;
			
			case 3: // Жизнь
				lives += 1;
			break;
			
			case 4: // "Прозрачная" верёвка
				rope.disabled = 500;
			break;
		}
		UpdScore();		
	}
	
	public function UpdScore() {
		scoretext.text = "Score: "+score;
		livestext.text="Lives: "+lives;		
	}
	
	public function GameProcess() { 
		// Следим за количеством врагов
		// Управляем бонусами итд.
		var ec = enemies.length;
		if (ec<maxenemies && getTimer()>LastAddTime+2000) {
			LastAddTime = getTimer();
			var type = 1;
			
			if (score>500) type += Math.random()*100 < 40 ? 1 : 0;
			if (score>1500) type += Math.random()*100 < 40 ? 1 : 0;			
			AddEnemy(100+Math.random()*440,-100-Math.random()*300,type);
		}
		
		var ds = 0;
		if (ds = score-LastScore >=ScoreDif) {
			LastScore = score - ds;
			ScoreDif+=75;
			ds = Math.floor(Math.random()*4)+1;
			if (ds == PrevBonus) ds=(ds+1)%3+1;
			PrevBonus = ds;
			AddBonus(Math.random()*400+120,-100,ds);
		}
		
		if (lives<=0) {
			if (!gpause) {
				gpause = true;
				GameOver();
			}
		}		
		
		if (balls.length==0) {
			if (!gpause)
				HandleBonus(1);
		}
		
		if (score > 0) maxenemies = 2;
		if (score > 700) maxenemies = 3;
		if (score > 1700) maxenemies = 4;
		if (score > 2500) maxenemies = 5;
		if (score > 3500) maxenemies = 6;
		if (score > 4000) maxenemies = 7;
		if (score > 4500) maxenemies = 8;
		
	}
	
	public function Restart() {
		// Удалить все мячи/бонусы/враги
		for (var i=0; i<balls.length; i++) {
			balls[i].removeMovieClip();
		}
		balls = new Array();
		
		for (var i=0; i<enemies.length; i++) {
			enemies[i].removeMovieClip();
		}
		enemies = new Array();
		
		for (var i=0; i<bonuses.length; i++) {
			bonuses[i].removeMovieClip();
		}
		bonuses = new Array();		
		
		rope.SetVars(canvas,balls,enemies,bonuses);
		
		lives = startLives;
		
		score = 0;
		maxenemies = 1;
		UpdScore();
		
		gpause = false;
		gomc.removeMovieClip();
	}
	
	public function GameOver() {
		gomc = _root.attachMovie("game_over","gameover",_root.getNextHighestDepth());
		gomc._x = 640/2 - gomc._width/2;
		gomc._y = 480/2 - gomc._height/2;		
		gomc.txt.text = score;
		gomc.restart_btn.onPress = mx.utils.Delegate.create(this,Restart);
	}
	
	public function AddBonus(x,y,type) {
		var tmp : MovieClip;
		switch (type) {
			case 1:
				tmp = enemyclip.attachMovie("bonus_ball","bonus",enemyclip.getNextHighestDepth());			
			break;
			case 2:
				tmp = enemyclip.attachMovie("bonus_disable","bonus",enemyclip.getNextHighestDepth());
			break;
			case 3:
				tmp = enemyclip.attachMovie("bonus_life","bonus",enemyclip.getNextHighestDepth());
			break;
			case 4:
				tmp = enemyclip.attachMovie("bonus_stunn","bonus",enemyclip.getNextHighestDepth());
			break;			
		}
		tmp.SetPos(x,y);
		bonuses.push(tmp);
	}
	
	public function AddBall(x,y) {
		if (!sviborg) {
			var tmp = enemyclip.attachMovie("ball","bl",enemyclip.getNextHighestDepth());
		} else {
			var tmp = enemyclip.attachMovie("sball","bl",enemyclip.getNextHighestDepth());
		}
		tmp.point.SetPos(x,y);
		balls.push(tmp);
	}
	
	public function AddEnemy(x,y,type) {
		if (!type) type = 1;
		var tmp;
		switch (type) {
			case 1:
				tmp = enemyclip.attachMovie("enemy_alien","enemy",enemyclip.getNextHighestDepth());
			break;
			case 2:
				tmp = enemyclip.attachMovie("enemy_adv","enemy",enemyclip.getNextHighestDepth());	
			break;
			case 3:
				tmp = enemyclip.attachMovie("enemy_last","enemy",enemyclip.getNextHighestDepth());	
			break;			
		}
		tmp.SetPos(x,y);
		enemies.push(tmp);
	}	
	
	public function HandleControl() {
		if (Key.isDown(Key.LEFT)) {
			rope.Left();
		}
		if (Key.isDown(Key.RIGHT)) {
			rope.Right();
		}
		if (Key.isDown(Key.DOWN)) {
			rope.Down();
		}
		if (Key.isDown(Key.UP)) {
			rope.Up();
		}
	}
	
	public function Update() {
		if (!Ready || gpause) return;
		
		GameProcess();
		
		var i : Number;		
		HandleControl();
		
		CloudMan.Update();
	
		for(i=balls.length-1; i>=0; i--) { // Удаляем мертвые шары
			if (balls[i].Die) {
				UpdScore();
				balls[i].removeMovieClip();
				delete balls[i];
				balls[i]=balls[balls.length-1];
				balls.pop();
				if (!balls.length) {
					lives--;
					UpdScore();
				}
			}
		}
		
		for(i=enemies.length-1; i>=0; i--) { // Удаляем мертвых врагов
			if (enemies[i].Die) {
				enemies[i].removeMovieClip();
				delete enemies[i];
				enemies[i]=enemies[enemies.length-1];
				enemies.pop();
			}
		}
		
		for(i=bonuses.length-1; i>=0; i--) { // Удаляем мертвые бонусы
			if (bonuses[i].Die) {
				bonuses[i].removeMovieClip();
				delete bonuses[i];
				bonuses[i]=bonuses[enemies.length-1];
				bonuses.pop();
			}
		}				
		
		if (balls.length) {
			for (i=0; i<balls.length; i++) {
				balls[i].Update();
			}
		}
		
		if (enemies.length) {
			for (i=0; i<enemies.length; i++) {
				enemies[i].Update();
			}
		}
		
		if (bonuses.length) {
			for (i=0; i<bonuses.length; i++) {
				bonuses[i].Update();
			}
		}		
		
		rope.Update();				
	}
	
}