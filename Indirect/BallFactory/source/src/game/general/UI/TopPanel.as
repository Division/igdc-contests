package game.general.UI {
	import fl.controls.Button;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import game.general.Const;
	import game.general.GameView;
	import game.states.StateMenu;
	import game.states.StateSelectLevel;
	import resourcemanager.ResManager;
	import states.StateManager;
	
	/**
	 * Верхняя панелька
	 * @author Division
	 */
	public class TopPanel extends Sprite{
		
		private var _editButton : Button;
		private var _menuButton : Button;
		private var _selectLevelButton : Button;
		private var _levelLabel: TextField;
		
		public static const WIDTH : Number = Const.SCREEN_WIDTH - GameView.PANEL_WIDTH;
		public static const HEIGHT : Number = 34;
		public static const BACKGROUND_TEXTURE : String = "common/graphics/entities/topPanelGradient.png";
		public function TopPanel() {
		
			_menuButton = new Button();
			_menuButton.label = "Меню";
			_menuButton.x = WIDTH - _menuButton.width - 10;
			_menuButton.y = HEIGHT / 2 - _menuButton.height / 2;
			_menuButton.buttonMode = true;
			_menuButton.useHandCursor = true;
			_menuButton.addEventListener(MouseEvent.MOUSE_DOWN, menuHandler);
			addChild(_menuButton);
			
			_selectLevelButton = new Button();
			_selectLevelButton.label = "Выбор уровня";
			_selectLevelButton.x = WIDTH - _selectLevelButton.width - 120;
			_selectLevelButton.y = HEIGHT / 2 - _selectLevelButton.height / 2;
			_selectLevelButton.buttonMode = true;
			_selectLevelButton.useHandCursor = true;
			_selectLevelButton.addEventListener(MouseEvent.MOUSE_DOWN, selectLevelHandler);
			addChild(_selectLevelButton);
			
			_editButton = new Button();
			_editButton.label = "Get Level XML";
			_editButton.x = WIDTH - _editButton.width - 230;
			_editButton.y = HEIGHT / 2 - _editButton.height / 2;
			_selectLevelButton.buttonMode = true;
			_selectLevelButton.useHandCursor = true;
			addChild(_editButton);
			
			var bd : BitmapData = ResManager.getTexture(BACKGROUND_TEXTURE);
			if (!bd) return;

			graphics.beginBitmapFill(bd);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();
		}
		
		private function selectLevelHandler(e:MouseEvent):void 
		{
			StateManager.instance.setState(StateSelectLevel.instance);
		}
		
		private function menuHandler(e:MouseEvent):void 
		{
			StateManager.instance.setState(StateMenu.instance);
		}
		
		public function setLevel(level:Number):void {
			
			if (_levelLabel && this.contains(_levelLabel)) { this.removeChild(_levelLabel); }
		   	_levelLabel = new TextField();
			_levelLabel.autoSize = TextFieldAutoSize.LEFT;

			_levelLabel.text = "Уровень "+level.toString();
				
		    _levelLabel.x = 5;
		    _levelLabel.y = 1;
				
				
			var format:TextFormat = new TextFormat();
            format.font = "Arial";
            format.color = 0xFFFFFF;
            format.size = 24;

			_levelLabel.setTextFormat(format);
			_levelLabel.filters = [new DropShadowFilter(3, 90, 0, 1, 4, 4, 1, 1, false, false)];
			
			addChild(_levelLabel);
		}
		
		public function get editButton():Button { return _editButton; }
		
	}

}