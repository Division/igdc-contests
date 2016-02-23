package game.entities.BallReceiver {
	import Box2D.Dynamics.b2FixtureDef;
	import decorator.Decorator;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import decorator.Decorator;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import game.entities.BallSpawn.BallSpawn;
	import game.entities.common.creator.BaseCreator;
	import game.entities.common.drag.ItemDrag;
	import game.entities.common.follow.Follow;
	import game.entities.common.gameobject.GameObject;
	import game.entities.common.itemparam.ItemParam;
	import game.entities.common.itemview.ItemView;
	import game.events.GetItemDataEvent;
	import game.events.LevelXmlEvent;
	import game.general.Const;
	import physics.PhysBody;
	import physics.Physics;
	import resourcemanager.ResManager;
	
	/**
	 * @author Division
	 */
	public class BallReceiverCreator extends BaseCreator{
		
		public static const NAME : String = "BallReceiverCreator";
		
		public function BallReceiverCreator() {
			super(NAME, BallReceiver.NAME);
		}
		
		override public function deserialize(data : * ) : void {
			super.deserialize(data);
			
			var btm : Bitmap;
			var bd : BitmapData = ResManager.getTexture(BallReceiver.IMAGE_NAME);
			if (bd) {
				btm = new Bitmap(bd);
				var view : ItemView = new ItemView();
				view.setDisplayObject(btm);
				view.x = (BallReceiver.SMALL_WIDTH - (BallReceiver.BIG_WIDTH - BallReceiver.SMALL_WIDTH) ) * Physics.KOEF + 7;
				view.y = -1;
				view.layer = Const.LAYER_ITEMS_TOP;
				owner.addDecorator(view);
			}
			
			bd = ResManager.getTexture(BallReceiver.HOLE_IMAGE_NAME);
			if (bd) {
				btm = new Bitmap(bd);
				view = new ItemView();
				view.setDisplayObject(btm);
				view.x = view.visual.width / 2 - 9;
				view.layer = Const.LAYER_ITEMS_BOTTOM;
				owner.addDecorator(view);
			}
			
			bd = ResManager.getTexture(BallReceiver.BOARD_IMAGE_NAME);
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
			sh.SetAsEdge(new b2Vec2(0, -BallReceiver.SMALL_HEIGHT / 2), new b2Vec2(0, BallReceiver.SMALL_HEIGHT / 2));
			b.addShape(addX, addY, sh);

			sh = new b2PolygonShape();
			sh.SetAsEdge(new b2Vec2(0, -BallReceiver.SMALL_HEIGHT / 2), new b2Vec2(BallReceiver.SMALL_WIDTH, -BallReceiver.SMALL_HEIGHT / 2));
			b.addShape(addX, addY, sh);

			sh = new b2PolygonShape();
			sh.SetAsEdge(new b2Vec2(0, BallReceiver.SMALL_HEIGHT / 2), new b2Vec2(BallReceiver.SMALL_WIDTH, BallReceiver.SMALL_HEIGHT / 2));
			b.addShape(addX, addY, sh);

			sh = new b2PolygonShape();
			sh.SetAsEdge(new b2Vec2(BallReceiver.SMALL_WIDTH, BallReceiver.SMALL_HEIGHT / 2), new b2Vec2(BallReceiver.BIG_WIDTH, BallReceiver.BIG_HEIGHT / 2));
			b.addShape(addX, addY, sh);

			sh = new b2PolygonShape();
			sh.SetAsEdge(new b2Vec2(BallReceiver.SMALL_WIDTH, -BallReceiver.SMALL_HEIGHT / 2), new b2Vec2(BallReceiver.BIG_WIDTH, -BallReceiver.BIG_HEIGHT / 2));
			b.addShape(addX, addY, sh);
			
			sh = new b2PolygonShape();
			var fix : b2FixtureDef = new b2FixtureDef();
			fix.density = 1;
			fix.isSensor = true;
			
			sh.SetAsOrientedBox(BallReceiver.SMALL_WIDTH / 9, BallReceiver.SMALL_HEIGHT / 7, new b2Vec2(BallReceiver.SMALL_WIDTH / 3 , 0));
			b.addShape(0,0, sh, 0, 1 , fix);
			
			b.body.SetType(b2Body.b2_staticBody);
			owner.addDecorator(b);
		}

		
	}

}