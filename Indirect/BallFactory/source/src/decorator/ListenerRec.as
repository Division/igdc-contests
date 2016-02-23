package decorator {
	/**
	 * @author Division
	 */
	public class ListenerRec{
		
		public var type : String;
		public var listener : Function;
		
		public function ListenerRec(type : String, listener : Function) {
			this.type = type;
			this.listener = listener;
		}
		
		public function clear() : void {
			type = "";
			listener = null;
		}
		
	}

}