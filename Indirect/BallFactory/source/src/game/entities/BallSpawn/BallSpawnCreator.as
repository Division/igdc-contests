package game.entities.BallSpawn {
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import decorator.Decorator;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import game.entities.common.creator.BaseCreator;
	import game.entities.common.drag.ItemDrag;
	import game.entities.common.follow.Follow;
	import game.entities.common.gameobject.GameObject;
	import game.entities.common.itemparam.ItemParam;
	import game.entities.common.itemview.ItemView;
	import game.entities.common.paramholder.ParamHolder;
	import game.general.Const;
	import physics.PhysBody;
	import physics.Physics;
	import resourcemanager.ResManager;
	
	/**
	 * @author Division
	 */
	public class BallSpawnCreator extends BaseCreator{
		
		public static const NAME : String = "BallSpawnCreator";
		
		public function BallSpawnCreator() {
			super(NAME, BallSpawn.NAME);
		}
		
		override public function deserialize(data : * ) : void {
			super.deserialize(data);
			
			var btm : Bitmap;
			var bd : BitmapData = ResManager.getTexture(BallSpawn.IMAGE_NAME);
			if (bd) {
				btm = new Bitmap(bd);
				var view : ItemView = new ItemView();
				view.setDisplayObject(btm);
				view.x = BallSpawn.PILE_WIDTH / 2 * Physics.KOEF;
				view.layer = Const.LAYER_ITEMS_TOP;
				owner.addDecorator(view);
			}
			
			bd = ResManager.getTexture(BallSpawn.HOLE_IMAGE_NAME);
			if (bd) {
				btm = new Bitmap(bd);
				view = new ItemView();
				view.setDisplayObject(btm);
				view.x = view.visual.width / 2 - 9;
				view.layer = Const.LAYER_ITEMS_BOTTOM;
				owner.addDecorator(view);
			}
			
			bd = ResManager.getTexture(BallSpawn.BOARD_IMAGE_NAME);
			if (bd) {
				btm = new Bitmap(bd);
				view = new ItemView();
				view.setDisplayObject(btm);
				view.x = BallSpawn.PILE_WIDTH / 2 * Physics.KOEF;
				view.y = BallSpawn.PILE_HEIGHT * Physics.KOEF + 8;
				view.layer = Const.LAYER_ITEMS_BOTTOM;
				owner.addDecorator(view);
			}
			
			var b : PhysBody = new PhysBody();
			var addX : Number = 0;
			var addY : Number = 0;
			
			var sh : b2PolygonShape = new b2PolygonShape();
			sh.SetAsEdge(new b2Vec2(0, -BallSpawn.PILE_HEIGHT / 2), new b2Vec2(0, BallSpawn.PILE_HEIGHT / 2));
			b.addShape(addX, addY, sh);

			sh = new b2PolygonShape();
			sh.SetAsEdge(new b2Vec2(0, -BallSpawn.PILE_HEIGHT / 2), new b2Vec2(BallSpawn.PILE_WIDTH, -BallSpawn.PILE_HEIGHT / 2));
			b.addShape(addX, addY, sh);

			sh = new b2PolygonShape();
			sh.SetAsEdge(new b2Vec2(0, BallSpawn.PILE_HEIGHT / 2), new b2Vec2(BallSpawn.PILE_WIDTH, BallSpawn.PILE_HEIGHT / 2));
			b.addShape(addX, addY, sh);
			
			b.body.SetType(b2Body.b2_staticBody);
			owner.addDecorator(b);
		}
		
	}

}