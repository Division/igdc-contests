package game.entities.common.visualgeom {
	
	import decorator.Decorator;
	import flash.display.Sprite;
	import game.general.Const;
	import game.utils.geom.GeomAsset;
	import game.utils.geom.visual.GeomAssetSprite;
	import resourcemanager.ResManager;
	
	/**
	 * Отрисовка визуальной геометрии
	 * @author Division
	 */
	public class VisualGeom extends Decorator {
		
		public static const NAME : String = "VisualGeom";
		
		protected var _ga : GeomAsset;
		
		private var _gas : GeomAssetSprite;
		
		public function VisualGeom() {
			super(NAME, false);
		}
		
		override public function init() : void {
			_gas = new GeomAssetSprite();
			owner.addChild(_gas);
		}
		
		override public function deserialize(data : * ) : void {
			if (data.src.length()) {
				// Получаем геометрию
				_ga = ResManager.getGeomAsset(data.src);
				if (_ga) {
					// Инициазилируем рендер геометрией
					_gas.setGeomAsset(_ga);
					// Вдруг требуются текстуры
					if (data.textures.length()) {
						setTexturesFromXml(data.textures);
					} else if (data.textureDescr.length()) {
						var xmlData : * = ResManager.getResource(data.textureDescr);
						if (xmlData) {
							var xml : XML = new XML(xmlData);
							setTexturesFromXml(xml);
						}
					}
				}
			}
			draw();
		}
		
		public function setTexturesFromXml(data : * ) : void {
			var arr : Array = new Array();
			for each(var texture : * in data.*) {
				arr.push(String(texture));
			}
			setTexturesFromArray(arr);
		}
		
		public function setTexturesFromArray(textures : Array) : void {
			var arr : Array = new Array();
			for (var i:int = 0; i < textures.length; i++) {
				arr.push(ResManager.getTexture(textures[i], Const.TEXTURE_LOCATOR));
			}
			_gas.setTextureArray(arr);
		}
		
		public function draw() : void {
			_gas.redraw();
		}
		
		override protected function destroy() : void {
			_ga = null;
			if (_gas) {
				owner.removeChild(_gas);
			}
			_gas = null;
		}
		
	}

}