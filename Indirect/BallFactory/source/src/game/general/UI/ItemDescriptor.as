package game.general.UI {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import resourcemanager.ResManager;
	
	/**
	 * Класс описания детали, отображаемой в UI
	 * @author Division
	 */
	public class ItemDescriptor extends Sprite {
		
		/**
		 * Доступна ли деталь только в режме редактирования
		 */
		private var _editorOnly : Boolean = false;
		
		/**
		 * Параметры, передаваемые объекту при создании
		 */
		private var _parameters : Object;
		
		/**
		 * Имя декоратора, который производит создание детали
		 */
		private var _decoratorName : String;
		
		/**
		 * Имя изображения, которое отображается в панеле
		 */
		private var _imageName : String;
		
		/**
		 * Само изображение
		 */
		private var _image : Bitmap;
		
		/**
		 * Порядок сортировки
		 */
		private var _sortOrder : int = 0;
		
		private static var _instanceCount : int = 0;
		
		/**
		 * Сколько их еще доступно для создания
		 */
		private var _available : int = 0;
		
		public function ItemDescriptor(decorName : String, imageName : String, editorOnly : Boolean, parameters : Object) {
			_editorOnly = editorOnly;
			_decoratorName = decorName;
			_parameters = parameters;
			_imageName = imageName;
			
			this.buttonMode = true;
			this.useHandCursor = true;
			
			var bd : BitmapData = ResManager.getTexture(_imageName);
			if (bd) {
				_image = new Bitmap(bd);
				addChild(_image);
			} else {
				trace("Invalid image name for item descriptor: " + _imageName);
			}
			
			_sortOrder = _instanceCount++;
		}
		
		public function get editorOnly():Boolean { return _editorOnly; }
		
		public function get parameters():Object { return _parameters; }
		
		public function get decoratorName():String { return _decoratorName; }
		
		public function get image():String { return _imageName; }
		
		public function get sortOrder() : int{ return _sortOrder; }
		
		public function get available():int { return _available; }
		
		public function set available(value:int):void {
			_available = value;
		}
		
	}

}