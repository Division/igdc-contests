package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;

	[SWF(width="640", height="480")]
	/**
	 * @author Division
	 */
	public class Main extends Sprite {
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			Security.allowDomain("*");
			initEngine(this);
		}
		
	}
	
}