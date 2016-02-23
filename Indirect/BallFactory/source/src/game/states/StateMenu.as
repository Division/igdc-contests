package game.states {
	
	import fl.controls.Button;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import game.general.Const;
	import game.general.Game;
	import game.general.UI.MyButton;
	import resourcemanager.ResManager;
	import states.BasicState;
	import states.StateManager;
	
	/**
	 * Класс состояние меню
	 * @author Division
	 */
	public class StateMenu extends BasicState {
		
		private static var _instance : StateMenu = null;
		private var btn : Sprite;
		
		private var _startBtn : MyButton;
		private var _editorBtn : MyButton;
		private var _aboutBtn : MyButton;
		
		private var _imageDefault:String = "common/graphics/ui/main_menu.png";
		
		public function StateMenu() {
			if (_instance != null) {
				throw new Error("Нельзя создать более одного экземпляра StateMenu");
			}
		}
		
		/**
		 * Инициализация
		 */
		override protected function initialize() : void {
			this.addChild(new Bitmap(ResManager.getTexture(_imageDefault)));
			
			_startBtn = new MyButton();
			_startBtn
			    .imageDefault("common/graphics/ui/main_menu_startGame_default.png")
				.imageOver("common/graphics/ui/main_menu_startGame_over.png")
				.imageClick("common/graphics/ui/main_menu_startGame_click.png")
				.imageDisable("common/graphics/ui/main_menu_startGame_disable.png");	
            _startBtn.create();
			_startBtn.positionX(Const.SCREEN_WIDTH / 2 - _startBtn.width / 2).postionY(150);
			
			_editorBtn = new MyButton();
			_editorBtn
			    .imageDefault("common/graphics/ui/main_menu_editor_default.png")
				.imageOver("common/graphics/ui/main_menu_editor_over.png")
				.imageClick("common/graphics/ui/main_menu_editor_click.png")
				.imageDisable("common/graphics/ui/main_menu_editor_disable.png");	
            _editorBtn.create();
			_editorBtn.positionX(Const.SCREEN_WIDTH / 2 - _editorBtn.width / 2).postionY(230);
			
			_aboutBtn = new MyButton();
			_aboutBtn
			    .imageDefault("common/graphics/ui/main_menu_about_default.png")
				.imageOver("common/graphics/ui/main_menu_about_over.png")
				.imageClick("common/graphics/ui/main_menu_about_click.png")
				.imageDisable("common/graphics/ui/main_menu_about_disable.png");	
            _aboutBtn.create();
			_aboutBtn.positionX(Const.SCREEN_WIDTH / 2 - _aboutBtn.width / 2).postionY(310);
			
			addChild(_startBtn);
			addChild(_editorBtn);
			addChild(_aboutBtn);
		
			_startBtn.addEventListener(MouseEvent.CLICK, startBtnHandler);
			_editorBtn.addEventListener(MouseEvent.CLICK, editorBtnHandler);
			_aboutBtn.addEventListener(MouseEvent.CLICK, aboutBtnHandler);
		}
		
		private function editorBtnHandler(e:MouseEvent):void {
			StateSelectLevel.instance.isEditor = true;
			StateManager.instance.setState(StateSelectLevel.instance);
		}
		
		private function aboutBtnHandler(e:MouseEvent):void {
			StateManager.instance.setState(StateAbout.instance);
		}
		
		private function startBtnHandler(e:MouseEvent):void {
			StateSelectLevel.instance.isEditor = false;
			StateManager.instance.setState(StateSelectLevel.instance);
		}
		
		private function btnClickHandler(e:MouseEvent):void {
			StateManager.instance.setState(StateSelectLevel.instance);
		}
		
		public static function get instance() : StateMenu {
			if (_instance == null) {
				_instance = new StateMenu();
			}
			return _instance;
		}
		
	}

}