package game.general {
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import game.general.UI.ItemActons;
	import game.general.UI.ItemConfigMenu;
	import game.general.UI.ItemSelectBar;
	import game.general.UI.ItemStartButton;
	import game.general.UI.LevelDataWindow;
	import game.general.UI.TopPanel;
	
	/**
	 * @author Division
	 */
	public class GameView extends Sprite{
		
		public static const PANEL_WIDTH : int = 116;
		
		public var panel : Sprite;
		public var selectBar : ItemSelectBar;
		public var itemActions : ItemActons;
		public var startButton : ItemStartButton;
		public var topPanel : TopPanel;
		public var configMenu: ItemConfigMenu;
		public var levelData : LevelDataWindow;
		
		public function GameView() {
			panel = new Sprite();
			panel.graphics.beginFill(0x9effb0);
			panel.graphics.drawRect(0, ItemStartButton.PANEL_HEIGHT, PANEL_WIDTH, Const.SCREEN_HEIGHT);
			panel.graphics.endFill();
			panel.x = Const.SCREEN_WIDTH - PANEL_WIDTH;
			panel.filters = [new DropShadowFilter(4,45,10,5,10,10,2,2,false,false)];
			
			selectBar = new ItemSelectBar();
			selectBar.y = ItemStartButton.PANEL_HEIGHT;
			panel.addChild(selectBar);
			
			itemActions = new ItemActons();
			
			addChild(itemActions);
			
			this.startButton = new ItemStartButton();
			startButton.filters = [new DropShadowFilter(1,45,0,1,1,7,2,2,false,false)];
			panel.addChild(this.startButton);
			
			topPanel = new TopPanel();
			addChild(topPanel);
			
			addChild(panel);
			
			levelData = new LevelDataWindow();
			
			addChild(levelData);
			levelData.visible = false;
			levelData.x = Const.SCREEN_WIDTH / 2 - LevelDataWindow.WIDTH / 2;
			levelData.y = Const.SCREEN_HEIGHT / 2 - LevelDataWindow.HEIGHT / 2;
			
			this.configMenu = new ItemConfigMenu(5, 35);
			configMenu.visible = false;
			this.addChild(this.configMenu);
			
		}
		
	}

}