package game.utils.geom.visual {
	import flash.display.Sprite;
	import game.utils.geom.GeomAsset;
	
	/**
	 * Визуальное представление набора геометрий
	 * @author Division
	 */
	public class GeomAssetSprite extends Sprite{
		
		protected var _geoms : Array/*GeomSprite*/ = null;
		
		public function setGeomAsset(geom : GeomAsset) : void {
			_geoms = new Array();
			var len : int = geom.geoms.length;
			for (var i:int = 0; i < len; i++) {
				_geoms[i] = new GeomSprite();
				_geoms[i].setGeometry(geom.geoms[i]);
				addChild(_geoms[i]);
			}
		}
		
		public function setTextureArray(textures : Array/*BitmapData*/) : void {
			var i : int = 0;
			if (!_geoms) return;
			var glen : int = _geoms.length;
			var tlen : int = textures.length;
			while (i < tlen && i < glen) {
				_geoms[i].setTexture(textures[i]);
				i++;
			}
		}
		
		public function setColorArray(colors : Array/*int*/) : void {
			if (!_geoms) return;
			var i : int = 0;
			var glen : int = _geoms.length;
			var clen : int = colors.length;
			while (i < clen && i < glen) {
				_geoms[i].setColor(colors[i]);
				i++;
			}
		}
		
		public function redraw() : void {
			if (!_geoms) return;
			var len : int = _geoms.length;
			for (var i:int = 0; i < len; i++) {
				_geoms[i].redraw();
			}
		}
		
		public function reset() : void {
			while (numChildren) {
				removeChildAt(0);
			}
			if (!_geoms) return;
			var len : int = _geoms.length;
			for (var i:int = 0; i < len; i++) {
				_geoms[i].reset();
			}
			_geoms = null;
		}
		
	}

}