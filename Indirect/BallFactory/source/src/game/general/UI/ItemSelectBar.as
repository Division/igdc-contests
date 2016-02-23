package game.general.UI {
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import game.general.Const;
	import game.general.GameView;
	import game.utils.Input;
	import resourcemanager.ResManager;
	
	/**
	 * @author Division
	 */
	public class ItemSelectBar extends Sprite{
		
		private var _items : Array /*ItemDescriptor*/;
		
		private static const _IMAGE_BG : String = "common/graphics/ui/select_bar.png";
		private static const _IMAGE_LOCK : String = "common/graphics/ui/top.png";
		
		public static const PANEL_WIDTH : int = 116;
		public static const PANEL_HEIGHT : int = 338;
		
		public var scroll_up : MyButton = new MyButton();
		public var scroll_down : MyButton = new MyButton();
		
		private var _container : Sprite;
		
		public var scrollOffset: Number = 20;
		public var scrollDefaultOffset: Number = 20;
		
		private var _intervalDuration:Number = 10; // duration between intervals, in milliseconds
        private var _intervalId:uint;
		
		public static const A_NONE : int = 0;
		public static const A_UP : int = 1;
		public static const A_DOWN : int = 2;
		
		private var _action : int = 0;
		
		private var _lock: Sprite;
		
		public var totalBalls:TextField;
		public var cachedBalls:TextField;
		
		public function ItemSelectBar() {
			_items = new Array();
			_container = this;
			
			var mask: Sprite = new Sprite();
            mask.graphics.beginFill(0x000000);
			mask.graphics.drawRect(ItemStartButton.PANEL_HEIGHT, 0, Const.SCREEN_WIDTH - PANEL_WIDTH, PANEL_HEIGHT+ItemStartButton.PANEL_HEIGHT);
			mask.graphics.endFill();
			
			var btm : Bitmap = new Bitmap(ResManager.getTexture(_IMAGE_BG));
			btm.height = PANEL_HEIGHT;
			_container.addChild(btm);
			_container.mask = mask;
			
			scroll_up.positionX(95).postionY(7);
			scroll_up
			        .imageDefault("common/graphics/ui/scroll/scroll_up.png")
					.imageOver("common/graphics/ui/scroll/scroll_up_over.png")
					.imageClick("common/graphics/ui/scroll/scroll_up_click.png")
					.imageDisable("common/graphics/ui/scroll/scroll_up_disable.png");
			
			this.addChild(scroll_up.create());
			
			scroll_down.positionX(95).postionY(PANEL_HEIGHT-(19+7));
			scroll_down
			        .imageDefault("common/graphics/ui/scroll/scroll_down.png")
					.imageOver("common/graphics/ui/scroll/scroll_down_over.png")
					.imageClick("common/graphics/ui/scroll/scroll_down_click.png")
					.imageDisable("common/graphics/ui/scroll/scroll_down_disable.png");
			
			this.addChild(scroll_down.create());
			
			// Скролю инструменты вниз
			scroll_down.addEventListener(MouseEvent.MOUSE_DOWN, scrollDownMouseDownHandler);
			Input.instance.addEventListener(MouseEvent.MOUSE_UP,   scrollDownMouseUpHandler);
			
			// Скролю инструменты ВВЕРХ
			scroll_up.addEventListener(MouseEvent.MOUSE_DOWN,   scrollUpMouseDownHandler);
			Input.instance.addEventListener(MouseEvent.MOUSE_UP,     scrollUpMouseUpHandler);
			
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		public function setLock(totalBallsCount:Number = 0):void {
			
			if (_lock && this.contains(_lock)) { this.removeChild(_lock); }
			var btm : Bitmap = new Bitmap(ResManager.getTexture(_IMAGE_LOCK));
			_lock = new Sprite();
			
			_lock.addChild(btm);
			
			var format:TextFormat = new TextFormat();
            format.font = "Arial";
            format.color = 0xFFFFFF;
            format.size = 26;
			
			totalBalls = new TextField();      
			cachedBalls = new TextField();
			
			totalBalls.autoSize = TextFieldAutoSize.CENTER;
			totalBalls.text = totalBallsCount.toString();
			
			cachedBalls.autoSize = TextFieldAutoSize.CENTER;
			cachedBalls.text = "0";

			totalBalls.setTextFormat(format);
			totalBalls.defaultTextFormat = format;
			totalBalls.filters = [new DropShadowFilter(2, 90, 0, 1, 4, 4, 1, 1, false, false)];
            
			cachedBalls.setTextFormat(format);
			cachedBalls.defaultTextFormat = format;
			cachedBalls.filters = [new DropShadowFilter(2, 90, 0, 1, 4, 4, 1, 1, false, false)];
			
		    totalBalls.x = PANEL_WIDTH / 2 - totalBalls.width/2;
		    totalBalls.y = PANEL_HEIGHT-60;
		    cachedBalls.x = PANEL_WIDTH / 2 - cachedBalls.width/2;
		    cachedBalls.y = PANEL_HEIGHT - 123;

			_lock.addChild(totalBalls);
			_lock.addChild(cachedBalls);
			
			addChild(_lock);
		  
		}
		
		public function unLock():void {
			if (_lock && this.contains(_lock)) { this.removeChild(_lock); }
		}
		
		private function enterFrameHandler(e:Event):void {
			switch(_action) {
				case A_DOWN:
					scrollDown();
				break;
				
				case A_UP:
					scrollUp();
				break;
			}
		}
		
		private function scrollUpMouseUpHandler(e:MouseEvent):void 
		{
			_action = A_NONE;
		}
		
		private function scrollUpMouseDownHandler(e:MouseEvent):void 
		{
			_action = A_UP;
		}
		
		private function scrollDownMouseUpHandler(e:MouseEvent):void 
		{
			_action = A_NONE;
		}
		
		private function scrollDownMouseDownHandler(e:MouseEvent):void 
		{
			_action = A_DOWN;
		}
		
		/**
		 * Скрол предметов вверх
		 */
		private function scrollUp():void {
		  	scrollOffset += 7;
			arrangeItems();	
		}
		
		/**
		 * Скрол предметов вниз
		 */
		private function scrollDown():void {
			scrollOffset -= 7;
			arrangeItems();
		}
		
		public function addItem(item : ItemDescriptor) : void {
			if (_items.indexOf(item) >= 0) return;
			_items.push(item);
			_items.sortOn("sortOrder", Array.NUMERIC);
			_container.addChild(item);
			arrangeItems();
		}
		
		public function removeItem(item : ItemDescriptor) : void {
			var ind : int = _items.indexOf(item);
			if (ind < 0) return;
			_container.removeChild(_items[ind]);
			_items[ind] = _items[_items.length - 1];
			_items.pop();
			_items.sortOn("sortOrder", Array.NUMERIC);
			arrangeItems();
		}
		
		public function clear() : void {
			for (var i:int = 0; i < _items.length; i++) {
				if (_container.contains(_items[i])) {
					_container.removeChild(_items[i]);
				}
			}
			_items = new Array();
		}
		
		public function moveToFront(item : ItemDescriptor) : void {
			if (_container.contains(item)) {
				_container.addChild(item);
			}
		}
		
        public function arrangeItems() : void { 
			
			if (!_items.length) return;
			
		   // Узнаем высоту всей этой параши
		   var scrollMaxOffset: Number = 0;
		   for (var j:int = 0; j < _items.length; j++) {
             scrollMaxOffset += _items[j].height+20;
           }
		   // Минусем выслту панели чтоб получить чистое значения свободного хода скрола
		   scrollMaxOffset -= PANEL_HEIGHT;
		   
		   // Дохлячему первому элементу внушаем что он походу посредине панели
		   _items[0].x = GameView.PANEL_WIDTH / 2 - _items[0].width / 2;
		   
		   // Существует ситуация при какой скролы нафик не нада например когда scrollMaxOffset отрицательное или равно 0
		   if (scrollMaxOffset <= 0) {
		       this.scroll_up.disable();
			   this.scroll_down.disable();
			   _items[0].y = scrollDefaultOffset;
		   }else {
			   
		       // Исправил фичу
			   this.scroll_up.enable();
			   this.scroll_down.enable();
			   
			   //Вот же ж хуйня, scrollMaxOffset положительное, а scrollOffset отрицательное!! сука!! мне надо их сравнивать но как их привести ? нормальный человек при сравнении взял бы модуль scrollOffset но я пхп говнокодер потому домножу на -1
			   scrollMaxOffset *= -1;
			   // Я очень надеюсь дивижн перепишет весь говнокод выше 
			   
			   // При условии что позиция верхнего елемента досточно отрицательна и не больше отступа по умолчанию 
			   if (scrollOffset >= scrollDefaultOffset) { 
				 
				  _items[0].y = scrollDefaultOffset;
				  scrollOffset = scrollDefaultOffset;
				  this.scroll_up.disable();
				  
			   // есть куда стремится мотаем дальше 
			   }else {
				  // если мотать большше не нужно
				  if (scrollMaxOffset >= scrollOffset) { 
					  
					  _items[0].y = scrollMaxOffset; 
					  scrollOffset = scrollMaxOffset; 
					  this.scroll_down.disable();
				  
				  // Или нужно?
				  }else {
					_items[0].y = scrollOffset;
					this.scroll_up.enable();
					this.scroll_down.enable();
				  }
			   }
		   }
		   
		   // Нонсенс дивижина
           for (var i:int = 1; i < _items.length; i++) {
             _items[i].y = _items[i-1].y + _items[i-1].height + 20;
             _items[i].x = GameView.PANEL_WIDTH / 2 - _items[i].width / 2;
           }
        }         
		
	}

}