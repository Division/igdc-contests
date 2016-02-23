package {
	import actionqueue.Actions;
	import actions.init.InitGameAction;
	import actions.init.InitResourcesAction;
	/**
	 * Инициализация движка
	 * @author Division
	 */
	public function initEngine(main : Main) : void {
		Actions.instance.start();
		Actions.instance.beginBlock();
		Actions.instance.addAction(new InitResourcesAction());
		Actions.instance.addAction(new InitGameAction(main));
		Actions.instance.endBlock();
	}
		
}