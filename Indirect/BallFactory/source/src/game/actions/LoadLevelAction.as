package game.actions {
	import Box2D.Common.Math.b2Vec2;
	import decorator.Decoratable;
	import decorator.Decorator;
	import decorator.DecorFactory;
	import decorator.Scene;
	import game.events.StateEvent;
	import game.actions.base.LoadLevelBaseAction;
	import game.general.GameController;
	import physics.Physics;
	import resourcemanager.ResManager;
	
	/**
	 * Загрузка уровня
	 * Оформлено в виде Action, следовательно можно делать асинхронную загрузку уровней из интернета без изменений в остальном коде
	 * @author Division
	 */
	public class LoadLevelAction extends LoadLevelBaseAction {
		
		public function LoadLevelAction(level : String, inEditor : Boolean = false) {
			super(level, inEditor);
		}
		
		override protected function processAction(params : Object) : void {
			GameController.instance.initLevel(_inEditor);
			
			var ld : * = ResManager.instance.GetResource("levels/" + _level + ".xml");
			if (ld == null) {
				trace("Ошибка загрузки уровня " + _level);
				finish();
				return;
			}
			var xml : XML = new XML(String(ld));
			
			setResult("success", true);
			parseLevelXML(xml);			
			
			finish();
		}
		
		private function parseLevelXML(data : XML) : void {
			handleEntity(data.entities);
			// TODO: остальные параметры уровня
		}
		
		private function handleEntity(xml : * ) : void {
			for each(var ent : * in xml.*) {
				if (ent.name() == "entity") {
					var d : Decoratable = new Decoratable();
					for each(var decorData : * in ent.*) {
						var decor : Decorator = DecorFactory.instance.getDecorator(decorData.name());
						if (decor != null) {
							d.addDecorator(decor);
							if (decor.owner) { // Загрузка только если декоратор был успешно добавлен
								decor.deserialize(decorData);
							}
						} else {
							trace("Декоратора не существует: '"+decorData.name()+"'");
						}
					}
					d.sendEvent(new StateEvent(StateEvent.INIT));
					Scene.instance.addEntity(d);
				}
			}
		}
		
	}

}