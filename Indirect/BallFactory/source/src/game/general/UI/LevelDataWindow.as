package game.general.UI {
	import fl.controls.Button;
	import fl.controls.TextArea;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Division
	 */
	public class LevelDataWindow extends Sprite{
		
		private var _textArea : TextArea;
		
		private var _closeBtn : Button;
		
		public static const WIDTH : Number = 500;
		public static const HEIGHT : Number = 400;
		
		public function LevelDataWindow() {
			_textArea = new TextArea();
			
			var g : Graphics = graphics;
			g.beginFill(0x55A4DF);
			g.drawRect(0, 0, WIDTH , HEIGHT);
			g.endFill();
			
			_textArea.width = WIDTH - 50;
			_textArea.height = HEIGHT - 70;
			_textArea.x = 25;
			_textArea.y = 35;
			_textArea.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			addChild(_textArea);
			
			_closeBtn = new Button();
			_closeBtn.label = "Закрыть";
			_closeBtn.x = WIDTH / 2 - _closeBtn.width / 2;
			_closeBtn.y = HEIGHT - 30;
			_closeBtn.addEventListener(MouseEvent.CLICK, closeHandler);
			addChild(_closeBtn);
		}
		
		private function closeHandler(e:Event):void {
			visible = false;
		}
		
		private function mouseUpHandler(e:MouseEvent):void {
			_textArea.setSelection(0, _textArea.text.length);
		}
		
		public function get textArea():TextArea { return _textArea; }
		
	}

}