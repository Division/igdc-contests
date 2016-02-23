package game.utils.geom {
	import Box2D.Common.Math.b2Vec2;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import math.Vector2;
	import physics.Physics;
	
	/**
	 * Класс, представляющий геометрию чего-либо
	 * Геометрия нужна как для физики, так и для графики
	 * Может иметь либо не иметь текстурных координат
	 * @author Division
	 */
	public class Geometry {
		
		private var _hasTexCoords : Boolean;
		
		private var _vertexes : Array/*b2Vec2*/;
		private var _texCoords : Array/*b2Vec2*/;
		
		private var _renderVertexes 	: Vector.<Number>;
		private var _renderTexCoords 	: Vector.<Number>;
		private var _indices 			: Vector.<int>;
		
		private var _vertexCount : int;
		
		public function load(data : ByteArray) : Boolean {
			try {
				_renderVertexes = new Vector.<Number>;
				_renderTexCoords = new Vector.<Number>;
				_indices = new Vector.<int>;
				_vertexes = new Array();
				_texCoords = new Array();
				
				data.endian = Endian.LITTLE_ENDIAN;
				
				var faceCount 	: int = data.readInt();
				var vertexCount : int = data.readInt();
				var texCoordCount 	: int = data.readInt();
				
				_hasTexCoords = texCoordCount > 0;
				
				_vertexCount = vertexCount;
				_renderVertexes.length = vertexCount * 2;
				if (hasTexCoords) {
					_renderTexCoords.length = vertexCount * 2;
					_texCoords.length = vertexCount;
				} else {
					_texCoords = null;
					_renderTexCoords = null;
				}
				_vertexes.length = vertexCount;
				_indices.length = faceCount * 3;
				
				var x : Number;
				var y : Number;
				var ind : int;
				
				// Чтение вершин
				for (var i:int = 0; i < vertexCount; i++) {
					x = data.readFloat();
					y = data.readFloat();
					
					_vertexes[i] = new b2Vec2(x, y);
					_renderVertexes[i * 2] = x * Physics.KOEF;
					_renderVertexes[i * 2 + 1] = y * Physics.KOEF;
				}
				
				_vertexes.reverse(); // Для физики меняем порядок вершин
				
				// Чтение индексов
				for (i = 0; i < faceCount * 3; i++) {
					_indices[i] = data.readInt();
				}
				// Текстурные координаты
				if (hasTexCoords) {
					for (i = 0; i < vertexCount; i++) {
						x = data.readFloat();
						y = data.readFloat();
						_texCoords[i] = new b2Vec2(x, y);
						_renderTexCoords[i * 2] = x;
						_renderTexCoords[i * 2 + 1] = y;
					}
				}
			} catch (e : Error) {
				trace("Ошибка загрузки геометрии");
				return false;
			}
			return true;
		}
		
		public function reset() : void {
			_renderTexCoords = null;
			_renderVertexes = null;
			_vertexes = null;
			_indices = null;
			_texCoords = null;
			_vertexCount = 0;
		}
		
		/**
		 * Рендеринг геометрии на объекте Graphics
		 */
		public function render(g : Graphics, texture : BitmapData = null, color : int = 0x00FF00) : void {
			var rTexCoords : Vector.<Number> = null;
			if (texture) {
				g.beginBitmapFill(texture);
				rTexCoords = _renderTexCoords;
			} else {
				g.beginFill(color);
			}
			
			g.drawTriangles(_renderVertexes, _indices, rTexCoords);
			g.endFill();
		}
		
		public function get hasTexCoords():Boolean { return _hasTexCoords; }
		
		public function get vertexes():/*b2Vec2*/Array { return _vertexes; }
		
		public function get vertexCount():int { return _vertexCount; }
		
	}

}