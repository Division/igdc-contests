package states {
	
	/**
	 * Интерфейс базового состояния
	 * @author Division
	 */
	public interface IBasicState {
		
		function update() : void;
		function onDeactivate() : void;
		function onActivate() : void;
		
	}
	
}