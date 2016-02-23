package states {
	
	import flash.display.Sprite;

	/**
	 * Базовый класс для состояний игры
	 * @author Division
	 */
	public class BasicState extends Sprite implements IBasicState {
		
		/**
		 * Добавлять/удалять из дисплей листа автоматически при активации/деактивации
		 */
		protected var _autoManage : Boolean = true;
		
		/**
		 * В конструкторе вызываем инициализацию
		 */
		public function BasicState() {
			initialize();
		}
		
		/**
		 * Инициализация
		 * переопределять в потомках
		 */
		protected function initialize() : void {
			
		}
		
		public function update() : void{
			
		}
		
		public function onDeactivate() : void{
			
		}
		
		public function onActivate() : void{
			
		}
		
		public function get autoManage():Boolean {
			return _autoManage; 
		}
		
	}

}