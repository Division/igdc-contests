package game.events {
	import decorator.DecorEvent;
	
	/**
	 * @author Division
	 */
	public class ItemDragEvent extends DecorEvent{
		
		public static const MOVED: String = "ItemMoved";
		
		public var x:Number;
		public var y:Number;
		
		public function ItemDragEvent(type : String, x : Number, y : Number) {
			super(type);
			this.x = x;
			this.y = y;
		}
		
	}

}