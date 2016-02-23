package game.actions {
	import actionqueue.ActionBase;
	import decorator.DecorFactory;
	import game.entities.background.Background;
	import game.entities.ball.Ball;
	import game.entities.ball.BallCreator;
	import game.entities.BallReceiver.BallReceiver;
	import game.entities.BallReceiver.BallReceiverCreator;
	import game.entities.BallSpawn.BallSpawn;
	import game.entities.BallSpawn.BallSpawnCreator;
	import game.entities.common.drag.ItemDrag;
	import game.entities.common.follow.Follow;
	import game.entities.common.gameobject.GameObject;
	import game.entities.common.itemview.ItemView;
	import game.entities.common.paramholder.ParamHolder;
	import game.entities.common.util.RemoveDecorators;
	import game.entities.common.visualgeom.VisualGeom;
	import game.entities.crate.Crate;
	import game.entities.crate.CrateCreator;
	import game.entities.lumber.Lumber;
	import game.entities.lumber.LumberCreator;
	import game.entities.plank.Plank;
	import game.entities.plank.PlankCreator;
	import game.entities.triangle.Triangle;
	import game.entities.triangle.TriangleCreator;
	import physics.PhysBody;
	
	/**
	 * Регистрация всех декораторов в фабрике
	 * @author Division
	 */
	public class RegDecoratorsAction extends ActionBase{
		
		override protected function processAction(params : Object) : void {
			DecorFactory.instance.registerDecorator(RemoveDecorators.NAME, RemoveDecorators);
			DecorFactory.instance.registerDecorator(VisualGeom.NAME, VisualGeom);
			DecorFactory.instance.registerDecorator(GameObject.NAME, GameObject);
			DecorFactory.instance.registerDecorator(PhysBody.NAME, PhysBody);
			DecorFactory.instance.registerDecorator(Follow.NAME, Follow);
		
			DecorFactory.instance.registerDecorator(Background.NAME, Background);
			
			DecorFactory.instance.registerDecorator(ItemDrag.NAME, ItemDrag);
			
			DecorFactory.instance.registerDecorator(ItemView.NAME, ItemView);

			DecorFactory.instance.registerDecorator(Crate.NAME, Crate);
			DecorFactory.instance.registerDecorator(CrateCreator.NAME, CrateCreator);
			
			DecorFactory.instance.registerDecorator(Plank.NAME, Plank);
			DecorFactory.instance.registerDecorator(PlankCreator.NAME, PlankCreator);
			
			DecorFactory.instance.registerDecorator(Triangle.NAME, Triangle);
			DecorFactory.instance.registerDecorator(TriangleCreator.NAME, TriangleCreator);
			
			DecorFactory.instance.registerDecorator(Lumber.NAME, Lumber);
			DecorFactory.instance.registerDecorator(LumberCreator.NAME, LumberCreator);
			
			DecorFactory.instance.registerDecorator(BallSpawn.NAME, BallSpawn);
			DecorFactory.instance.registerDecorator(BallSpawnCreator.NAME, BallSpawnCreator);

			DecorFactory.instance.registerDecorator(Ball.NAME, Ball);
			DecorFactory.instance.registerDecorator(BallCreator.NAME, BallCreator);
			
			DecorFactory.instance.registerDecorator(BallReceiver.NAME, BallReceiver);
			DecorFactory.instance.registerDecorator(BallReceiverCreator.NAME, BallReceiverCreator);
			
			DecorFactory.instance.registerDecorator(ParamHolder.NAME, ParamHolder);
			
		}
		
	}

}