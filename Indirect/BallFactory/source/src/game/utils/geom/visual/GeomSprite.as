package game.utils.geom.visual {
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import game.utils.geom.Geometry;
	
	/**
	 * Визуальное представление геометрии
	 * @author Division
	 */
	public class GeomSprite extends Sprite {
		
		protected var _geom 	: Geometry = null;
		protected var _texture 	: BitmapData = null;
		protected var _color	: int = 0x00FF00;
		
		public function reset() : void {
			graphics.clear();
			_geom = null;
		}
		
		public function setGeometry(g : Geometry) : void {
			_geom = g;
		}
		
		public function setTexture(tex : BitmapData) : void {
			_texture = tex;
		}
		
		public function setColor(color : int) : void {
			_color = color;
		}
		
		public function redraw() : void {
			graphics.clear();
			if (_geom) {
				_geom.render(graphics, _texture, _color);
			}
		}
		
	}

}