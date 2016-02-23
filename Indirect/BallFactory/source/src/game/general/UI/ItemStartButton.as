package game.general.UI {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import resourcemanager.ResManager;
	
	/**
	 * Кнопка управлениястратом симуляции
	 * @author D
	 */
	public class ItemStartButton extends Sprite{
		
		private static const _IMAGE_OFF : String = "common/graphics/ui/start_button_off.png";
		private static const _IMAGE_ON : String = "common/graphics/ui/start_button_on.png";
		
		public static const PANEL_WIDTH : int = 116;
		public static const PANEL_HEIGHT : int = 142;
		
		// Ссылка на битмап
		private var _btm: DisplayObject;
        
		public function ItemStartButton() {
		   	this.graphics.beginFill(0x0000FF);
			this.graphics.drawRect(0, 0, PANEL_WIDTH, PANEL_HEIGHT);
			this.graphics.endFill();
			this.buttonMode = true;
			this.useHandCursor = true;
			setImage(_IMAGE_OFF);
		}
		
		public function setState(state:Boolean):void {
		  	if (state) {
			  this.setImage(_IMAGE_ON);
			}else {
			  this.setImage(_IMAGE_OFF);
			}
		}
		
		private function setImage(image:String):void {
			if (this._btm && this.contains(this._btm)) { this.removeChild(this._btm); }
			this._btm = this.addChild(new Bitmap(ResManager.getTexture(image)));
		}
	}

}