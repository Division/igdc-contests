package game.states {
	
	import fl.controls.Button;
	import fl.controls.Label;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import game.general.Const;
	import game.general.Game;
	import game.general.UI.MyButton;
	import resourcemanager.ResManager;
	import states.BasicState;
	import states.StateManager;
	
	/**
	 * @author Division
	 */
	public class StateAbout extends BasicState {
		
		private static var _instance : StateAbout = null;
		private var btn : Sprite;
		
		private var _startBtn : MyButton;
		private var _editorBtn : MyButton;
		private var _aboutBtn : MyButton;
		
		private var _imageDefault:String = "common/graphics/ui/main_menu.png";
		
		private var _back : Button;
		
		public function StateAbout() {
			if (_instance != null) {
				throw new Error("Нельзя создать более одного экземпляра StateAbout");
			}
		}
		
		override protected function initialize() : void {
			var parts : Array = ["Программирование", "Дизайн"];
			var names : Array = [["Division", "Александр Кучеренко (TiTanium)"], ["Александр Кучеренко (TiTanium)", "Александр Грудко (m0rte)"]];
			
			var dx : int = 0, dy:int = 100;
			
			var i :int, j:int;
			for (i = 0; i < parts.length; i++ ) {
				var lbl : Label = new Label();
				lbl.autoSize = TextFieldAutoSize.LEFT;
				lbl.text = parts[i];
				lbl.x = 200 + dx;
				lbl.y = i * 100 + dy;
				
				addChild(lbl);
				for (j = 0; j < names[i].length; j++ ) {
					lbl = new Label();
					lbl.autoSize = TextFieldAutoSize.LEFT;
					lbl.text = names[i][j];
					lbl.x = 220 + dx;
					lbl.y = i * 100 + j * 30 + 30 + dy;
					addChild(lbl);
				}
			}
			
			_back = new Button();
			_back.label = "Назад";
			_back.x = Const.SCREEN_WIDTH / 2 - _back.width / 2;
			_back.y = Const.SCREEN_HEIGHT - 75;
			_back.addEventListener(MouseEvent.CLICK, clickHandler);
			addChild(_back);
		}
		
		private function clickHandler(e:MouseEvent):void {
			StateManager.instance.setState(StateMenu.instance);
		}

		public static function get instance() : StateAbout {
			if (_instance == null) {
				_instance = new StateAbout();
			}
			return _instance;
		}
		
	}

}