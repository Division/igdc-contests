package game.entities.background {
	import decorator.Decorator;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import game.entities.common.itemparam.ItemParam;
	import game.events.BackgroundEvent;
	import game.events.GetItemDataEvent;
	import game.events.StateEvent;
	import game.general.Const;
	import game.general.GameController;
	import game.general.UI.TopPanel;
	import resourcemanager.ResManager;
	
	/**
	 * @author Division
	 */
	public class Background extends Decorator{
		
		public static const NAME : String = "Background";
		
		private var _backName : String;
		
		private var _view : Sprite;
		
		public function Background() {
			super(NAME);
		}
		
		override public function init() : void {
			addCallback(StateEvent.INIT, initHandler);
			addCallback(BackgroundEvent.SET, setBackgroundHandler);
			addCallback(GetItemDataEvent.GET_ITEM_PARAMS, getParamsHandler);
			addCallback(GetItemDataEvent.GET_ITEM_CREATOR, getParamsHandler);
		}
		
		private function getParamsHandler(e : GetItemDataEvent):void{
			e.itemParams["image"] = _backName;
			e.itemParams["creatorName"] = _id;
			e.creatorName = _id;
		}
		
		private function setBackgroundHandler(e : BackgroundEvent):void{
			_backName = e.backName;
			while (_view.numChildren) {
				_view.removeChildAt(0);
			}
			
			var bd : BitmapData = ResManager.getTexture(_backName);
			if (bd) {
				_view.addChild(new Bitmap(bd));
			}
		}
		
		private function initHandler(e : StateEvent):void{
			_view = new Sprite();
			_view.y = TopPanel.HEIGHT;
			_view.addEventListener(MouseEvent.MOUSE_DOWN, backDownHandler, false, 0, true);
			owner.addChildToLayer(_view, Const.LAYER_BACKGROUND);
			if (_backName) {
				var ev : BackgroundEvent = new BackgroundEvent(BackgroundEvent.SET, _backName);
				owner.sendEvent(ev);
			}
			
			owner.addDecorator(new ItemParam());
		}
		
		private function backDownHandler(e:MouseEvent):void {
			GameController.instance.backDownHandler(e);
		}
		
		override public function deserialize(data : * ) : void {
			_backName = String(data.image);
		}
		
	}

}