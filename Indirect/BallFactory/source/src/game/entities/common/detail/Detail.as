package game.entities.common.detail {
	import Box2D.Dynamics.b2Body;
	import decorator.Decorator;
	import game.events.GetItemDataEvent;
	import game.events.StateEvent;
	import physics.PhysBody;
	
	/**
	 * Базовый класс для декораторов деталей
	 * @author Division
	 */
	public class Detail extends Decorator{
		
		protected var _paramList : Array/*String*/ = [];
		
		protected var _isStatic : int = 1;
		protected var _putInPanel : int = 0;
		
		public function Detail(name:String, unique:Boolean = true) {
			super(name, unique);
		}
		
		protected function addParameterList(list : Array) : void {
			for (var i : int = 0; i < list.length; i++ ) {
				_paramList.push(list[i]);
			}
		}
		
		override public function init() : void {
			addCallback(StateEvent.INIT, initHandler);
			addCallback(GetItemDataEvent.GET_ITEM_PARAMS, getParamListHandler);
			addCallback(GetItemDataEvent.ITEM_PARAMS_UPDATE, itemParamsUpdateHandler);
			addCallback(GetItemDataEvent.GET_IS_STATIC, isStaticHandler);
		}
		
		private function itemParamsUpdateHandler(e : GetItemDataEvent):void{
			_isStatic = e.newItemParams["isStatic"];
			_putInPanel = e.newItemParams["putInPanel"];
		}
		
		private function initHandler(e : StateEvent):void{
			addParameterList(["isStatic", "putInPanel"]);
		}
		
		private function isStaticHandler(e : GetItemDataEvent):void {
			e.isStatic = _isStatic;
		}
		
		private function getParamListHandler(e : GetItemDataEvent):void {
			e.itemParamList = _paramList.slice();
			e.itemParams["isStatic"]  = _isStatic;
			e.itemParams["putInPanel"] = _putInPanel
		}
		
		public function get isStatic():int { return _isStatic; }
		
		public function set isStatic(value:int):void {
			_isStatic = int(value);
		}
		
		public function get putInPanel():int { return _putInPanel; }
		
		public function set putInPanel(value:int):void {
			_putInPanel = int(value);
		}
		
	}

}