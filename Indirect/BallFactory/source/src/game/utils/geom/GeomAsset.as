package game.utils.geom {
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * Набор геометрий.
	 * Геометрии сами по себе не храняться и бывают только в наборах.
	 * @author Division
	 */
	public class GeomAsset {
		
		private var _geoms : Array/*Geometry*/;
		
		private var _geomCount : int;
		
		public function GeomAsset() {
			_geoms = new Array();
		}
		
		public function load(data : ByteArray) : Boolean {
			_geoms = new Array();
			data.endian = Endian.LITTLE_ENDIAN;
			_geomCount = data.readInt();

			for (var i:int = 0; i < _geomCount; i++) {
				var geom : Geometry = new Geometry;
				if (!geom.load(data)) {
					reset();
					return false;
				} else {
					_geoms.push(geom);
				}
			}

			return true;
		}
		
		public function reset() : void {
			for (var i:int = 0; i < _geomCount; i++) {
				if (_geoms[i]) {
					_geoms[i].reset();
				}
			}
			_geomCount = 0;
			_geoms = new Array();
		}
		
		public function get geoms():/*Geometry*/Array { return _geoms; }
		
	}

}