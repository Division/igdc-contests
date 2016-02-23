package game.general {
	
	/**
	 * Игровые константы
	 * @author Division
	 */
	public class Const {
		
		/**
		 * Основной локатор ресурсов
		 */
		public static const MAIN_LOCATOR : String = "default";
		
		/**
		 * Локатор текстур
		 */
		public static const TEXTURE_LOCATOR : String = "default";
		
		public static const SCREEN_WIDTH : Number = 640;
		
		public static const SCREEN_HEIGHT : Number = 480;
		
		/**
		 * Индексы слоев
		 */
		public static const LAYER_BACKGROUND : int = -4;
		public static const LAYER_ITEMS_BOTTOM : int = -1;
		public static const LAYER_ITEMS : int = 0;
		public static const LAYER_ITEMS_TOP : int = 1;
		
		// Может когда-то пригодится, но пока гуй внутри сцены не планируется
		public static const LAYER_GUI : int = 3;
		public static const LAYER_ALERT : int = 5;
	}

}