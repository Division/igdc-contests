package game.entities.common.util {
	import decorator.Decorator;
	
	/**
	 * Декоратор, который удаляет заданные декораторы
	 * @author Division
	 */
	public class RemoveDecorators extends Decorator{
		public static const NAME : String = "RemoveDecorators";
		
		public function RemoveDecorators() {
			super(NAME);
		}
		
		override public function deserialize(data : *) : void {
			for each(var decor : * in data.*) {
				owner.removeDecorator(decor.name());
			}
		}
		
	}

}