package game.states {
	
	import Box2D.Collision.IBroadPhase;
	import decorator.Decoratable;
	import decorator.Scene;
	import fl.controls.Label;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import game.entities.background.Background;
	import game.events.StateEvent;
	import game.general.Const;
	import game.general.Game;
	import game.general.GameController;
	import game.general.UI.MyButton;
	import resourcemanager.ResManager;
	import states.BasicState;
	import states.StateManager;
	
	/**
	 * Класс 
	 * @author Division и я
	 */
	public class StateSelectLevel extends BasicState {
		
		private static var _instance : StateSelectLevel = null;
		private var _imageDefault: String = "common/graphics/ui/select_level_state.png";
		private var _totallLevels:Number = 16;
		private var _levelsComplite:Number = 16;
		
		public var currentLevel:Number;
	
		private var _buttonsArray: Array = new Array();

		private var _isEditor : Boolean;
		
		private var _closeButton : MyButton;
		private var _addLevelButton : MyButton;
		
		public function StateSelectLevel() {
			if (_instance != null) {
				throw new Error("Нельзя создать более одного экземпляра StateSelectLevel");
			}
		}
		
		/**
		 * Инициализация
		 */
		override protected function initialize() : void {
           this.addChild(new Bitmap(ResManager.getTexture(_imageDefault)));
		    
		    var btnClose:MyButton = new MyButton();
				
			btnClose.imageDefault("common/graphics/ui/select_level_state_close_default.png")
			.imageOver("common/graphics/ui/select_level_state_close_over.png")
			.imageClick("common/graphics/ui/select_level_state_close_click.png");
		
			btnClose.create();		
			
			btnClose.addEventListener(MouseEvent.MOUSE_DOWN, closeBtnHandler);
			
		    btnClose.positionX(Const.SCREEN_WIDTH - btnClose.width - 33 ).postionY(26);
			this.addChild(btnClose);
		    this._closeButton = btnClose;
			
		    // Static
		    var xDefault:int = 23;
			var yDefault:int = 98;
			var levelsOnLine:int = 6;
			var padding:Number = 8;
		    
			// Dinamic
			var x:int = xDefault;
			var y:int = yDefault;
			var onLine:int = 0;
		
		    for (var i:int = 0; i < this._totallLevels; i++ ) {
                
			    var btnLevel:MyButton = new MyButton();
				
			    btnLevel.imageDefault("common/graphics/ui/select_level_state_default.png")
				.imageOver("common/graphics/ui/select_level_state_over.png")
				.imageDisable("common/graphics/ui/select_level_state_disable.png")
				.imageClick("common/graphics/ui/select_level_state_over.png");
			    
				btnLevel.create();				
				
				if (i != 0) {
				  x += btnLevel.x + btnLevel.width + padding;	
				  onLine += 1;
				  if (levelsOnLine <= onLine) { y += btnLevel.height; onLine = 0; x = xDefault }
				}
				
				btnLevel.positionX(x).postionY(y);
			
				if (this._levelsComplite <= i) { btnLevel.disable(); } else { 
					btnLevel.enable();
					btnLevel.addEventListener(MouseEvent.MOUSE_DOWN, levelSelectHandler);
				}
			    
				// Label
				var btnTextField:TextField = new TextField();
				var levelNum:Number = i + 1;
				
                btnLevel.setName(levelNum.toString());
				btnTextField.autoSize = TextFieldAutoSize.CENTER;

				btnTextField.text = levelNum.toString();
				
				var format:TextFormat = new TextFormat();
                format.font = "Arial";
                format.color = 0x000000;
                format.size = 33;

				btnTextField.setTextFormat(format);
				btnTextField.filters = [new DropShadowFilter(3, 90, 0, 1, 4, 4, 1, 1, false, false)];
				
				btnTextField.x = btnLevel.width / 2 - btnTextField.width / 2;
				btnTextField.y = btnLevel.height / 2 - btnTextField.height / 2;
				
				btnLevel.setLabel(btnTextField);
				
				this._buttonsArray.push(btnLevel);
			}
				
			for (i = 0; i < this._buttonsArray.length; i++) {
				this.addChild(this._buttonsArray[i]);
			}			
			
			var addLevel:MyButton = new MyButton();
			  addLevel.imageDefault("common/graphics/ui/select_level_state_add_default.png")
				.imageOver("common/graphics/ui/select_level_state_add_over.png")
				.imageClick("common/graphics/ui/select_level_state_add_click.png");
			addLevel.create();
			
			addLevel.addEventListener(MouseEvent.MOUSE_DOWN, addLevelBtnHandler);
			
			x +=  addLevel.width + 34 + padding;	
			onLine += 1;
			if (levelsOnLine <= onLine) { y += addLevel.height + 25; onLine = 0; x = xDefault+10; }

			addLevel.positionX(x).postionY(y+8);
			
			this.addChild(addLevel);
			_addLevelButton = addLevel;
		}
		
		private function addLevelBtnHandler(e:MouseEvent):void 
		{
			StateManager.instance.setState(StateGame.instance);
			GameController.instance.initLevel(true);
			var b : Background = new Background();
			var decor : Decoratable = new Decoratable();
			b.deserialize({image: "common/graphics/background/background_1.jpg"});
			decor.addDecorator(b);
			Scene.instance.addEntity(decor);
			decor.sendEvent(new StateEvent(StateEvent.INIT));
		}
		
		override public function onActivate() : void {
			_addLevelButton.visible = isEditor;
		}
		
		public function get isEditor():Boolean { return _isEditor; }
		
		public function set isEditor(value:Boolean):void {
			_isEditor = value;
		}
		
		private function closeBtnHandler(e:MouseEvent):void 
		{
			StateManager.instance.setState(StateMenu.instance);
		}
		
		private function levelSelectHandler(e:MouseEvent):void 
		{
			var levelNum:String = e.target.getName();
			currentLevel = Number(levelNum);
			levelNum = Number(levelNum) >= 10 ? levelNum : "0" + levelNum;
			//trace(levelNum);
			StateManager.instance.setState(StateGame.instance);
			var levelString:String = "level" + levelNum;
			Game.instance.loadLevel(levelString, isEditor);
		}
		
		public function getNextLevel():String 
		{   
			var tmpCurr: Number = currentLevel + 1;
			if (_totallLevels < tmpCurr) { return ""; }
			
			var levelNum:String = tmpCurr.toString();
			levelNum = Number(levelNum) >= 10 ? levelNum : "0" + levelNum;
			
			var levelString:String = "level" + levelNum;
			
			//trace(levelString);
			
			return levelString;
		}
		
		public static function get instance() : StateSelectLevel {
			if (_instance == null) {
				_instance = new StateSelectLevel();
			}
			return _instance;
		}
		
	    public function setTotalLevels(countLevels: Number):void {
			this._totallLevels = countLevels;
		}
		
		public function setComplitedLevels(levels:Number):void {
			this._levelsComplite = levels;
		}
	}

}