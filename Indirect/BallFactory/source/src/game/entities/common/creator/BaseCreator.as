package game.entities.common.creator {
	import decorator.Decorator;
	import decorator.DecorFactory;
	import game.entities.common.detail.Detail;
	import game.entities.common.drag.ItemDrag;
	import game.entities.common.follow.Follow;
	import game.entities.common.gameobject.GameObject;
	import game.entities.common.itemparam.ItemParam;
	import game.entities.common.paramholder.ParamHolder;
	import game.events.GetItemDataEvent;
	import game.events.StateEvent;
	import game.general.GameController;
	
	/**
	 * @author Division
	 */
	public class BaseCreator extends Decorator {
		
		private var _isStatic : int = 1;
		private var _putInPanel : int = 0;
		private var _entName : String;
		
		private var _data : * = { };
		
		private var _dontDelete : int = 0;
		
		public function BaseCreator(name : String, entName : String) {
			super(name);
			_entName = entName;
		}
		
		override public function init() : void {
			addCallback(GetItemDataEvent.GET_ITEM_PARAMS, getItemParamsHandler);
			addCallback(GetItemDataEvent.GET_ITEM_CREATOR, getItemParamsHandler);
			addCallback(StateEvent.INIT, initHandler);
		}
		
		private function initHandler(e : StateEvent):void {
			if (!int(_data.dontLoad)) {
				var ev : GetItemDataEvent = new GetItemDataEvent(GetItemDataEvent.ITEM_PARAMS_LOADED);
				ev.loadedParams = _data;
				owner.sendEvent(ev);
				_data = null;
				var ent : Detail = owner.searchDecorator(_entName) as Detail;
				ent.isStatic = _isStatic;
				ent.putInPanel = _putInPanel;
			}
			
			if (!GameController.instance.isEditor && !_dontDelete && _putInPanel) {
				GameController.instance.addItemToPanel(this, _id);
				owner.die();
			}
		}
		
		private function getItemParamsHandler(e : GetItemDataEvent):void{
			e.itemParams.creatorName = _id;
			e.creatorName = _id;
		}
		
		override public function deserialize(data : * ) : void {
			_data = data;
			
			var x : Number, y : Number, rotation : Number;
			
			_dontDelete = data.dontDelete;
			
			x = Number(data.x);
			y = Number(data.y);
			rotation = Number(data.rotation);
			if (isNaN(rotation)) rotation = 0;
			if (isNaN(x)) x = 0;
			if (isNaN(y)) y = 0;
			
			_putInPanel = int(data.putInPanel);
			_isStatic = int(data.isStatic);
			
			owner.addDecorator(DecorFactory.instance.getDecorator(_entName));
			owner.addDecorator(new ParamHolder());
			owner.addDecorator(new ItemParam());
			owner.addDecorator(new ItemDrag());
			owner.addDecorator(new GameObject(x, y, data.name(), rotation));
			owner.addDecorator(new Follow());
		}
		
	}

}