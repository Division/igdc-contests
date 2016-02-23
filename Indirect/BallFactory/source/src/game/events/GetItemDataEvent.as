package game.events {
	import decorator.DecorEvent;
	import game.entities.common.itemparam.ItemParam;
	
	/**
	 * @author Division
	 */
	public class GetItemDataEvent extends DecorEvent{
		
		public static const GET_MENU_RADIUS : String = "GetMenuRadius";
		public static const GET_IS_STATIC : String = "GetIsStatic";
		public static const GET_ITEM_PARAMS : String = "GetItemParams";
		public static const GET_ITEM_CREATOR : String = "GetItemCreator";
		
		public static const ITEM_PARAMS_UPDATE : String = "ItemParamsUpdate";
		public static const ITEM_PARAMS_LOADED : String = "ItemParamsLoaded";
		
		public var menuRadius : Number = 60;
		public var isStatic : int = 1;
		public var itemParams : Object = { };
		public var itemParamList : Array/*String*/ = [];
		public var creatorName : String = "";
		
		public var newItemParams : Object = { };
		
		public var loadedParams : * = { };
		
		public function GetItemDataEvent(type : String) {
			super(type);
		}
		
	}

}