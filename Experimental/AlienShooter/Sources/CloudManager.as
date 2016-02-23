import flash.display.BitmapData;

class CloudManager {
	public var CloudCount = 6;
	public var cont;
	public var Clouds : Array;
	public var b = false;
	
	public function AddCloud(type) {
		switch (type) {
			case 1:
				var bd = BitmapData.loadBitmap("cloud1");
			break;
			case 2:
				var bd = BitmapData.loadBitmap("cloud2");
			break;
			case 3:
				var bd = BitmapData.loadBitmap("cloud3");						
			break;			
		}
		var mc = cont.createEmptyMovieClip("cloud", cont.getNextHighestDepth());
		mc.attachBitmap(bd,mc.getNextHighestDepth());
		Clouds.push(mc);
		return mc;
	}
	
	public function UpdateCloud(cloud) {
		with(cloud) {
			_x+=1;
		}
	}
	
	public function CloudManager() {
		Clouds = new Array();
		cont = _root.createEmptyMovieClip("skycont",_root.getNextHighestDepth());
		var v = getV(0);
		with (AddCloud(3)) {
			_x = 0;
			_y = v;
		}
		v = getV(1);
		with (AddCloud(2)) {
			_y = v;
			_x=-300;
		}
		v = getV(0);
		with (AddCloud(1)) {
			_y = v;
			_x=-400;
		}
		v = getV(1);
		with (AddCloud(3)) {
			_y = v;
			_x=-800;
		}				
	}
	
	public function getV(lev) {
		if (lev==1) {
			return 220 + Math.random()*80;
		} else {
			return 2 + Math.random()*80;
		}
	}
	
	public function Update() {
		for (var i=0; i<Clouds.length; i++) {
			UpdateCloud(Clouds[i]);
			if (Clouds[i]._x > 640) {
				Clouds[i].removeMovieClip();
				Clouds[i] = Clouds[Clouds.length-1];
				Clouds.pop();
				var tmp = AddCloud(Math.floor(Math.random()*4));
				tmp._x = -500- Math.random()*300+150;
				tmp._y = getV(!b);

				b=!b;
			}
		}
	}
}