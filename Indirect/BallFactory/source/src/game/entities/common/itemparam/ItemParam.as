package game.entities.common.itemparam {
	import decorator.Decorator;
	import game.entities.common.gameobject.GameObject;
	import game.events.GetItemDataEvent;
	import game.events.LevelXmlEvent;
	import game.events.StateEvent;
	
	/**
	 * Декоратор который получает основные параметры объекта (координаты, ориентация, isStatic)
	 * По совместительству сериализует объект
	 * @author Division
	 */
	public class ItemParam extends Decorator{
		
		public static const NAME : String = "ItemParam";
		
		private var _go : GameObject;
		
		public function ItemParam() {
			super(NAME);
		}
		
		override public function init() : void {
			addCallback(GetItemDataEvent.GET_ITEM_PARAMS, getParamsHandler);
			addCallback(StateEvent.INIT, initHandler);
			addCallback(LevelXmlEvent.GET_LEVEL_XML, getXmlHandler);
		}
		
		private function initHandler(e : StateEvent):void{
			_go = owner.searchDecorator(GameObject.NAME) as GameObject;
		}
		
		private function getParamsHandler(e : GetItemDataEvent):void {
			if (!_go) return;
			var ev : GetItemDataEvent = new GetItemDataEvent(GetItemDataEvent.GET_IS_STATIC);
			owner.sendEvent(ev);
			e.itemParams.isStatic = Number(ev.isStatic);
			e.itemParams.x = _go.x;
			e.itemParams.y = _go.y;
			e.itemParams.rotation = _go.rotation;
		}
		
		private function getXmlHandler(e : LevelXmlEvent):void{
			var xml : XML = LevelXmlEvent.levelXml;
			var params : Object;
			var ev : GetItemDataEvent = new GetItemDataEvent(GetItemDataEvent.GET_ITEM_PARAMS);
			owner.sendEvent(ev);
			params = ev.itemParams;
			var cxml : XML = <entity/>;
			var ccxml : XML;
			cxml.appendChild(ccxml = new XML("<"+params.creatorName+">" + "</"+params.creatorName+">"));
			for (var param : String in params) {
				if (param == "creatorName") continue;
				ccxml.appendChild(new XML("<" + param + ">" + params[param] + "</" + param + ">"));
			}
			xml.appendChild(cxml);
		}
		
	}

}