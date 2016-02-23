package game.general {
	import Box2D.Common.Math.b2Transform;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	
	import decorator.DecorFactory;
	import decorator.Decoratable;
	import decorator.Decorator;
	import decorator.Scene;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.media.Video;
	import flash.utils.getTimer;
	
	import game.entities.BallReceiver.BallReceiver;
	import game.entities.BallReceiver.BallReceiverCreator;
	import game.entities.BallSpawn.BallSpawn;
	import game.entities.BallSpawn.BallSpawnCreator;
	import game.entities.common.creator.BaseCreator;
	import game.entities.common.follow.FollowEvent;
	import game.entities.common.gameobject.GameObject;
	import game.entities.crate.Crate;
	import game.entities.crate.CrateCreator;
	import game.entities.lumber.Lumber;
	import game.entities.lumber.LumberCreator;
	import game.entities.plank.Plank;
	import game.entities.plank.PlankCreator;
	import game.entities.triangle.Triangle;
	import game.entities.triangle.TriangleCreator;
	import game.events.GetItemDataEvent;
	import game.events.ItemDragEvent;
	import game.events.LevelXmlEvent;
	import game.events.SimulationEvent;
	import game.events.StateEvent;
	import game.general.UI.ItemConfigMenu;
	import game.general.UI.ItemDescriptor;
	import game.general.UI.MyButton;
	import game.general.UI.TopPanel;
	import game.states.StateMenu;
	import game.states.StateSelectLevel;
	import game.utils.Input;
	
	import physics.PhysBody;
	import physics.Physics;
	
	import resourcemanager.ResManager;
	
	import states.StateManager;
	/**
	 * Большой и толстый класс контроллера игры и редактора
	 * @author Division
	 */
	public class GameController{
		
		public static const DRAG_NONE 	: int = 0;
		public static const DRAG_THUMB 	: int = 1;
		public static const DRAG_ITEM 	: int = 2;
		public static const DRAG_ROTATE : int = 3;
		
		public static const RA_NONE : int = 0;
		public static const RA_LEFT : int = 1;
		public static const RA_RIGHT : int = 2;
		
		public static var instance : GameController;
		
		/**
		 * Происходит ли симуляция
		 */
		private var _simulationStarted : Boolean = false;

		private var _view : GameView;
		
		private var _dragStatus : int;
		
		private var _currentDrag : ItemDescriptor = null;
		
		private var _currentDragItem : Decoratable = null;
		private var _selectedItem : Decoratable = null;
		
		private var _collided : Boolean = false;
		private var _currentCheckingBody : b2Body;
		
		/**
		 * Находимся ли в режиме редактора уровней
		 */
		private var _isEditor : Boolean = false;
		
		private var _availableItems : Array/*ItemDescriptor*/;
		
		private var _ddx : Number = 0;
		private var _ddy : Number = 0;
		
		private var _lastSuccesX : Number = 0;
		private var _lastSuccesY : Number = 0;
		private var _lastSuccesAngle : Number = 0;
		private var _lastSuccess : Boolean = false;
		
		private var _prevMX : Number = 0;
		private var _prevMY : Number = 0;
		
		private var _startAngle : Number = 0;
		private var _curAngle : Number = 0;
		
		private var _allItems : Array/*ItemDescriptor*/ = [];
		
		private var _ballsReceived : int;
		private var _ballsToReceive : int;
		
		public static const VICTORY_CHECK_DELAY : int = 1500;
		
		private var _lastTime : int;
		
		private var _haveWin: Boolean = false;
		
		private var _winMessage:Sprite;
		
		private var _started : Boolean = false;
		
		private var _rAction : int = RA_NONE;
		
		public function GameController() {
			instance = this;
			_view = new GameView();
			Game.instance.addChild(_view);
			initItems();
			Input.instance.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			Input.instance.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			_view.itemActions.rotateLBtn.addEventListener(MouseEvent.MOUSE_DOWN, rotateLeftDownHandler);
			_view.itemActions.rotateRBtn.addEventListener(MouseEvent.MOUSE_DOWN, rotateRightDownHandler);
			_view.itemActions.deleteBtn.addEventListener(MouseEvent.MOUSE_DOWN, deleteBtnHandler);
			
			// меню с настройкамиы
			_view.itemActions.configBtn.addEventListener(MouseEvent.MOUSE_DOWN, configBtnHandler);
		
			// Изменение сотояния кнопки
			_view.startButton.addEventListener(MouseEvent.MOUSE_DOWN, startSimulationHandler);
			
			_view.topPanel.editButton.addEventListener(MouseEvent.CLICK, getLevelXml);
			
			_dragStatus = DRAG_NONE;
			
			_allItems.push(new ItemDescriptor(BallSpawnCreator.NAME, BallSpawn.IMAGE_NAME, true, { dontLoad: true, name : function() : String { return BallSpawn.NAME; } } ));
			_allItems.push(new ItemDescriptor(BallReceiverCreator.NAME, BallReceiver.IMAGE_NAME, true, { dontLoad: true, name : function() : String { return BallReceiver.NAME; } } ));
			_allItems.push(new ItemDescriptor(CrateCreator.NAME, Crate.IMAGE_NAME, false, { dontLoad: true, name : function() : String { return Crate.NAME; } } ));
			_allItems.push(new ItemDescriptor(PlankCreator.NAME, Plank.IMAGE_NAME, false, { dontLoad: true, name : function() : String { return Plank.NAME; } } ));
			_allItems.push(new ItemDescriptor(TriangleCreator.NAME, Triangle.IMAGE_NAME, false, { dontLoad: true, name : function() : String { return TriangleCreator.NAME; } } ));
			_allItems.push(new ItemDescriptor(LumberCreator.NAME, Lumber.IMAGE_NAME, false, { dontLoad: true, name : function() : String { return LumberCreator.NAME; } } ));
			
			for (var i:int = 0; i < _allItems.length; i++) {
				_allItems[i].addEventListener(MouseEvent.MOUSE_DOWN, thumbItemDownHandler);
			}
		}
		
		public function onDeactivate() : void {
			if (_simulationStarted) {
				startSimulationHandler(null);
			}
		}
		
		private function processRotate() : void {
			
			if (!_selectedItem || _dragStatus != DRAG_ROTATE || _rAction == RA_NONE) return;
			
			var da : Number = 5 * Math.PI / 180;
			
			switch (_rAction) {
				case RA_LEFT:
						da = -da;
					break;
				
				case RA_RIGHT:
						//da = da;
					break;
			}
			
			var pb : PhysBody = _selectedItem.searchDecorator(PhysBody.NAME) as PhysBody;
			if (pb) {
				pb.body.SetAngle(pb.body.GetAngle() + da);
				pb.updateFollow();
			}
		}
		
		public function update() : void {
			
			if (!_simulationStarted) {
				processRotate();
				return;
			}
			
			
			var time : int = getTimer();
			if (time - _lastTime >=  VICTORY_CHECK_DELAY) {
				_lastTime = time;
				if (checkForVictory()) processVictory();
			}
		}
		
		private function processVictory():void {
			if (_haveWin) { return;  }
			
			_haveWin = true;
			
			var win: Sprite = new Sprite();
			win.addChild(new Bitmap(ResManager.getTexture("common/graphics/ui/win.png")));
			
			var next:MyButton = new MyButton();
			next.imageDefault("common/graphics/ui/win_next_default.png")
				.imageOver("common/graphics/ui/win_next_over.png");
			next.positionX(380).postionY(275);
			next.create();
			next.addEventListener(MouseEvent.MOUSE_DOWN, nextLevelHandler);
			
			if (StateSelectLevel.instance.getNextLevel() != "") {
				win.addChild(next);
			}
			
			var selectLevel:MyButton = new MyButton();
			selectLevel.imageDefault("common/graphics/ui/win_selectLevel_default.png")
				.imageOver("common/graphics/ui/win_selectLevel_over.png");
			selectLevel.positionX(225).postionY(275);
			selectLevel.create();
			selectLevel.addEventListener(MouseEvent.MOUSE_DOWN, selectLevelHandler);
			win.addChild(selectLevel);
			
			var menu:MyButton = new MyButton();
			menu.imageDefault("common/graphics/ui/win_menu_default.png")
				.imageOver("common/graphics/ui/win_menu_over.png");
			menu.positionX(72).postionY(275);
			menu.create();
			menu.addEventListener(MouseEvent.MOUSE_DOWN, menuWinHandler);
			win.addChild(menu);
			
			_winMessage = win;
			_view.addChild(_winMessage);
			
		}
		

		private function nextLevelHandler(e:MouseEvent):void 
		{
			_view.removeChild(_winMessage);
			
			var nextLevel:String = StateSelectLevel.instance.getNextLevel();
			StateSelectLevel.instance.currentLevel += 1;
			
			if (_simulationStarted) startSimulationHandler(null);
			Game.instance.loadLevel(nextLevel, false);
		}
		
		private function menuWinHandler(e:MouseEvent):void 
		{   
			//_haveWin = false;
			_view.removeChild(_winMessage);
			StateManager.instance.setState(StateMenu.instance);
		}
		
		private function selectLevelHandler(e:MouseEvent):void 
		{   //_haveWin = false;
		    _view.removeChild(_winMessage);
			StateSelectLevel.instance.isEditor = false;
			StateManager.instance.setState(StateSelectLevel.instance);
		}
		
		private function checkForVictory():Boolean{
			return ballsReceived >= _ballsToReceive && ballsToReceive && _started && !isEditor;
		}
		
		/**
		 * меню с настройкаим
		 * @param	e
		 */
		private function configBtnHandler(e:MouseEvent):void 
		{
			var ev : GetItemDataEvent = new GetItemDataEvent(GetItemDataEvent.GET_ITEM_PARAMS);
			_selectedItem.sendEvent(ev);
			
			var obj : Object = {};
			for (var i : int = 0; i < ev.itemParamList.length; i++) {
				obj[ev.itemParamList[i]] = true;
			}
			
           _view.configMenu.setItems( obj );
		   _view.configMenu.setItemsValue(ev.itemParams);
		   _view.configMenu.update();
		   _view.configMenu.visible = true;
		}
		
		/**
		 * Запуск симуляции
		 */
		private function startSimulationHandler(e:MouseEvent):void {
			if (this._simulationStarted) {
			   _view.selectBar.unLock();
			   this._view.startButton.setState(false);
			   this._simulationStarted = false;
			}else {
			   _view.selectBar.setLock(_ballsToReceive);
			   this._view.startButton.setState(true);
			   this._simulationStarted = true;
			}
			
			if (_simulationStarted) {
				_ballsReceived = 0;
				Scene.instance.sendEvent(new SimulationEvent(SimulationEvent.SIM_START));
				setDetailSelected(null);
				_started = true;
			} else {
				Scene.instance.sendEvent(new SimulationEvent(SimulationEvent.SIM_END));
			}
		}
		
		private function initItems() : void {
			_availableItems = new Array();
			if (_isEditor) {
				_availableItems = _allItems;
			}
			
			/*for (var i:int = 0; i < _availableItems.length; i++) {
				_availableItems[i].addEventListener(MouseEvent.MOUSE_DOWN, thumbItemDownHandler);
			}*/
		}
		
		public function initLevel(isEditor : Boolean) : void {
			_started = false;
			_view.topPanel.editButton.visible = isEditor;
			_view.levelData.visible = false;
			_isEditor = isEditor;
			_ballsToReceive = 0;
			_view.itemActions.configBtn.visible = isEditor;
			
			Scene.instance.clear();
			_view.selectBar.clear();
			var i : int;
			
			_availableItems = [];
			
			if (_isEditor) {
				_availableItems = _allItems;
			} else {
				/*for (var i:int = 0; i < _availableItems.length; i++) {
					_availableItems[i].addEventListener(MouseEvent.MOUSE_DOWN, thumbItemDownHandler, false, 0, true);
				}*/
			}
			
			for (i = 0; i < _availableItems.length; i++ ) {
				if (_isEditor || !_availableItems[i].editorOnly) {
					_view.selectBar.addItem(_availableItems[i]);
				}
			}
			
			_view.itemActions.visible = false;
			Physics.instance.world.SetGravity(new b2Vec2(0, 5));
			_haveWin = false;
			
			_view.topPanel.setLevel(StateSelectLevel.instance.currentLevel);
		}
		
		public function mergeObj(o1 : Object, o2 : Object) : Object {
			var res : Object = new Object();
			var ind : String;
			for (ind in o1) {
				res[ind] = o1[ind];
			}
			for (ind in o2) {
				res[ind] = o2[ind];
			}
			return res;
		}
		
		public function addItemToPanel(item : BaseCreator, name : String) : void {
			var i : int;
			for (i = 0; i < _allItems.length; i++ ) {
				if (_allItems[i].decoratorName == name) {
					var descr : ItemDescriptor;
					var params : Object;
					var ev : GetItemDataEvent = new GetItemDataEvent(GetItemDataEvent.GET_ITEM_PARAMS);
					item.owner.sendEvent(ev);
					params = ev.itemParams;
					
					params = mergeObj(params, _allItems[i].parameters);
					params.dontDelete = true;
					params.dontLoad = false;
					
					descr = new ItemDescriptor(name, _allItems[i].image, _allItems[i].editorOnly, params);
					_view.selectBar.addItem(descr);
					
					descr.addEventListener(MouseEvent.MOUSE_DOWN, thumbItemDownHandler, false, 0, true);
					
					break;
				}
			}
		}
		
		public function setDragStatus(ds : int) : void {
			_dragStatus = ds;
		}
		
		private function collisionCallback(fixture:b2Fixture):Boolean {
			if (fixture.GetBody() == _currentCheckingBody) {
				_collided = false;
				return true;
			}
			_collided = true;
			return false;
		}
		
		/**
		 * Сталкивается ли тело декоратора PhysBody с каким-либо другим телом
		 */
		public function bodyCollides(item : Decoratable) : Boolean {
			if (!item) return false;
			var pb : PhysBody = item.searchDecorator(PhysBody.NAME) as PhysBody;
			if (!pb) return false;
			var b : b2Body = pb.body;
			_currentCheckingBody = b;
			var fix : b2Fixture = b.GetFixtureList();
			_collided = false;
			while (fix) { // Пройдем по всем шейпам. Вдруг их больше одного.
				Physics.instance.world.QueryShape(collisionCallback, fix.GetShape(), b.GetTransform());
				if (_collided) break;
				fix = fix.GetNext();
			}
			return _collided;
		}
		
		/**
		 * Добавление детали из панели на сцену
		 */
		public function addDetailToScene(item : ItemDescriptor, x : Number, y : Number) : void {
			if (!_isEditor) {
				item.available--;
				if (item.available <= 0) {
					_view.selectBar.removeItem(item);
				}
			}
			
			var detail : Decoratable = new Decoratable();
			var d : Decorator = DecorFactory.instance.getDecorator(item.decoratorName);
			if (d) {
				item.parameters.x = x;
				item.parameters.y = y;
				detail.addDecorator(d);
				
				d.deserialize(item.parameters);
				detail.sendEvent(new StateEvent(StateEvent.INIT));
				Scene.instance.addEntity(detail);
				_currentDragItem = detail;
				detail.sendEvent(new FollowEvent(FollowEvent.UPDATE_FOLLOW));
				
				setDetailSelected(_currentDragItem);
			}
			
		}
		
		/**
		 * Выбор детали.
		 * Отобразим доступные для детали действия
		 */
		private function setDetailSelected(item : Decoratable) : void {
			_currentDragItem = item;
			if (!item) {
				_view.itemActions.visible = false;
				return;
			}
			var go : GameObject = item.searchDecorator(GameObject.NAME) as GameObject;
			if (!go) return;
			_view.itemActions.setPos(go.x * Physics.KOEF, go.y * Physics.KOEF);			
			_view.itemActions.visible = true;
			var ev : GetItemDataEvent = new GetItemDataEvent(GetItemDataEvent.GET_MENU_RADIUS);
			item.sendEvent(ev);
			_view.itemActions.radius = ev.menuRadius;
			_selectedItem = item;
		}
		
		/**
		 * Обработка движения мыши
		 */
		private function mouseMoveHandler(e:MouseEvent):void {
			switch (_dragStatus) {
				case DRAG_ITEM:
					if (!_currentDragItem) return;
					var dx : Number, dy : Number;
					var mx : int = Input.instance.mousePos.x;
					var my : int = Input.instance.mousePos.y;
					if (mx < 10) mx = 10;
					if (my < TopPanel.HEIGHT + 10) my = TopPanel.HEIGHT + 10;
					if (mx > Const.SCREEN_WIDTH - GameView.PANEL_WIDTH - 10) mx = Const.SCREEN_WIDTH - GameView.PANEL_WIDTH - 10;
					if (my > Const.SCREEN_HEIGHT - 10) my = Const.SCREEN_HEIGHT - 10;
					
					
					dx = (mx - _ddx) / Physics.KOEF;
					dy = (my - _ddy) / Physics.KOEF;
					// Крутость декораторов в том что многое реализуется событиями
					// К примеру у каждой детали есть декоратор ItemDrag который слушает событие ItemDragEvent и перемещает детальку
					// Не производится никаких приведений типов, ненужные события просто игнорируются
					_currentDragItem.sendEvent(new ItemDragEvent(ItemDragEvent.MOVED, dx, dy));
					
					_view.itemActions.setPos(mx - _ddx, my - _ddy);
					
					if (!bodyCollides(_currentDragItem)) {
						
					} else {
						// TODO:  подсвечивание объекта красным
					}
					
				break;
				
				case DRAG_THUMB:
					// Перетянули деталь с панели на игровое поле
					if (Input.instance.mousePos.x < Const.SCREEN_WIDTH - GameView.PANEL_WIDTH) {
						// Добавим ее на поле и начнем тягать уже добавленную
						if (_currentDrag) {
							addDetailToScene(_currentDrag, Input.instance.mousePos.x / Physics.KOEF, Input.instance.mousePos.y / Physics.KOEF);
							_currentDrag.stopDrag();
							_view.selectBar.arrangeItems();
						}
						// Теперь таскаем саму деталь
						setDragStatus(DRAG_ITEM);
					}
				break;
				
				case DRAG_ROTATE:
					
					/*
					if (!_selectedItem) return;
					var pb : PhysBody = _selectedItem.searchDecorator(PhysBody.NAME) as PhysBody;
					_curAngle += (Input.instance.mousePos.x - _prevMX) / 25;
					if (pb) {
						pb.body.SetAngle(_curAngle + _startAngle);
						pb.updateFollow();
					}
					//_view.itemActions.rotation = _curAngle * 180 / Math.PI;*/
				break;
			}
			
			_prevMX = Input.instance.mousePos.x;
			_prevMY = Input.instance.mousePos.y;
		}
		
		/**
		 * Юзер отпустил мышку
		 */
		private function mouseUpHandler(e:MouseEvent):void {
			switch (_dragStatus) {
				case DRAG_ITEM: // Двигали игровую деталь
					if (bodyCollides(_currentDragItem)) {
						if (_lastSuccess) {
							_currentDragItem.sendEvent(new ItemDragEvent(ItemDragEvent.MOVED, _lastSuccesX, _lastSuccesY));
							_view.itemActions.setPos(_lastSuccesX * Physics.KOEF, _lastSuccesY * Physics.KOEF);
						} else {
							// Удалить созданный элемент
							deleteItem(_currentDragItem);

						}
					}
					
					//setDetailSelected(_currentDragItem);
					_currentDragItem = null;
				break;
				
				case DRAG_THUMB: // Двигали деталь в панельке
					if (_currentDrag) {
						_currentDrag.stopDrag();
						_currentDrag = null;
					}
					_view.selectBar.arrangeItems();
				break;
				
				case DRAG_ROTATE:
					if (bodyCollides(_selectedItem)) {
						if (_lastSuccess) {
							if (!_selectedItem) break;
							var pb : PhysBody = _selectedItem.searchDecorator(PhysBody.NAME) as PhysBody;
							pb.body.SetAngle(_lastSuccesAngle);
							pb.updateFollow();
						}
					}
					_view.itemActions.rotation = 0;
				break;
			}
			setDragStatus(DRAG_NONE);
			_rAction = RA_NONE;
		}

		/** 
		 * Нажали на деталь в панеле. Начинаем её тягать
		 */
		private function thumbItemDownHandler(e:MouseEvent):void {
			if (_simulationStarted) return;
			var item:ItemDescriptor = ItemDescriptor(e.target);
			item.startDrag();
			_view.selectBar.moveToFront(item);
			_currentDrag = item;
			_ddx = 0;
			_ddy = 0;
			setDragStatus(DRAG_THUMB);
			_lastSuccess = false;
		}

		/**
		 * Нажали мышкой по детале на сцене. Выделяем её и при движении курсора будем перемещать.
		 */
		public function itemMouseDown(item : Decoratable) : void {
			if (_simulationStarted) return;
			
			var ev : GetItemDataEvent = new GetItemDataEvent(GetItemDataEvent.GET_ITEM_PARAMS);
			item.sendEvent(ev);
			if (!isEditor && !ev.itemParams.putInPanel) {
				return;
			}
			
			setDetailSelected(item);
			if (!item) return;
			var obj : GameObject = item.searchDecorator(GameObject.NAME) as GameObject;
			if (!obj) return;
			_ddx = -obj.x * Physics.KOEF + Input.instance.mousePos.x;
			_ddy = -obj.y * Physics.KOEF + Input.instance.mousePos.y;
			setDragStatus(DRAG_ITEM);
			_lastSuccess = true;
			_lastSuccesX = obj.x;
			_lastSuccesY = obj.y;
		}

		private function rotateLeftDownHandler(e : MouseEvent) : void {
			_rAction = RA_LEFT;
			startRotate();
		}
		
		private function rotateRightDownHandler(e : MouseEvent) : void {
			_rAction = RA_RIGHT;
			startRotate();
		}
		
		private function startRotate() : void {
			if (_simulationStarted) return;
			setDragStatus(DRAG_ROTATE);
			_prevMX = Input.instance.mousePos.x;
			_prevMY = Input.instance.mousePos.y;
			_curAngle = 0;
			if (_selectedItem) {
				var go : GameObject = _selectedItem.searchDecorator(GameObject.NAME) as GameObject;
				if (go) {
					_startAngle = go.rotation;
					_lastSuccesAngle = _startAngle;
				}
			}
			_lastSuccess = true;
		}
		
		/**
		 * Нажали мышкой на кнопку поворота
		 */
		private function rotateDownHandler(e:MouseEvent):void {
			if (_simulationStarted) return;
			setDragStatus(DRAG_ROTATE);
			_prevMX = Input.instance.mousePos.x;
			_prevMY = Input.instance.mousePos.y;
			_curAngle = 0;
			if (_selectedItem) {
				var go : GameObject = _selectedItem.searchDecorator(GameObject.NAME) as GameObject;
				if (go) {
					_startAngle = go.rotation;
					_lastSuccesAngle = _startAngle;
				}
			}
			_lastSuccess = true;
		}

		public function backDownHandler(e : MouseEvent) : void {
			if (_simulationStarted) return;
			_view.configMenu.visible = false;
			setDetailSelected(null);
			
		}
		
		/**
		 * Удаление
		 */
		private function deleteBtnHandler(e:MouseEvent):void {
			if (_simulationStarted) return;
			if (!_selectedItem) return;
			deleteItem(_selectedItem);
			
		}

		public function deleteItem(item : Decoratable) : void {
			if (!isEditor) {
				
				var cr : BaseCreator;
				var ev : GetItemDataEvent = new GetItemDataEvent(GetItemDataEvent.GET_ITEM_CREATOR);
				item.sendEvent(ev);
				cr = item.searchDecorator(ev.creatorName) as BaseCreator;
				addItemToPanel(cr, ev.creatorName);
			}
			
			if (!item) return;
			item.die();
			setDetailSelected(null);
			_view.configMenu.visible = false;
			
		}
		
		/**
		 * Сериализация уровня
		 */
		public function getLevelXml(e : MouseEvent = null) : * {
			if (_simulationStarted) return "";
			LevelXmlEvent.levelXml = <entities></entities>;
			Scene.instance.sendEvent(new LevelXmlEvent(LevelXmlEvent.GET_LEVEL_XML));
			
			var result : XML = new XML('<level></level>').appendChild(LevelXmlEvent.levelXml);
			var resString : String = '<?xml version="1.0" encoding="utf-8"?>' + "\n" + result.toXMLString();
			
			_view.levelData.visible = true;
			_view.levelData.textArea.text = resString;
		}
		
		public function get simulationStarted():Boolean { return _simulationStarted; }
		
		public function get selectedItem():Decoratable { return _selectedItem; }
		
		public function get isEditor():Boolean { return _isEditor; }
		
		public function get ballsReceived():int { return _ballsReceived; }
		
		public function get ballsToReceive():int { return _ballsToReceive; }
		
		public function set ballsToReceive(value:int):void {
			_ballsToReceive = value;
		}
		
		public function set ballsReceived(value:int):void {
			_ballsReceived = value;
			_view.selectBar.cachedBalls.text = _ballsReceived.toString();
			_lastTime = getTimer();
		}
	}

}