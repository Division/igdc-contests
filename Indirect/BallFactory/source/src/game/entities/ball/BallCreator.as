package game.entities.ball {
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2Fixture;
	import Box2D.Dynamics.b2FixtureDef;
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
	import resourcemanager.ResManager;
	
	/**
	 * @author Division
	 */
	public class BallCreator extends BaseCreator{
		
		public static const NAME : String = "BallCreator";
		
		private var _radius : Number = 1;
		
		protected var _type : int = Ball.BALL_BOWLING;
		
		public function BallCreator() {
			super(NAME, Ball.NAME);
		}
		
		override public function deserialize(data : * ) : void {
			var x : Number, y : Number, rotation : Number;
			
			x = Number(data.x);
			y = Number(data.y);
			rotation = Number(data.rotation);
			if (isNaN(rotation)) rotation = 0;
			if (isNaN(x)) x = 0;
			if (isNaN(y)) y = 0;
			
			owner.addDecorator(new Ball());
			owner.addDecorator(new ItemParam());
			owner.addDecorator(new ItemDrag());
			owner.addDecorator(new GameObject(x, y, Ball.NAME, rotation));
			owner.addDecorator(new Follow());
			var ph : ParamHolder = new ParamHolder();
			ph.deleteAfterSimEnd = true;
			owner.addDecorator(ph);
			
			var imgName : String;
			var fixtureDef : b2FixtureDef = new b2FixtureDef;
			var restitution : Number = 0.1;
			var density : Number = 1;
			
			switch (_type) {
				case Ball.BALL_BOWLING:
					imgName = Ball.BOWLING_IMAGE_NAME;
					radius = Ball.BOWLING_RADIUS;
					restitution = 0.15;
					density = 1;
				break;
			}
			
			var btm : Bitmap;
			var bd : BitmapData = ResManager.getTexture(imgName);
			if (bd) {
				btm = new Bitmap(bd);
				var view : ItemView = new ItemView();
				view.layer = Const.LAYER_ITEMS_BOTTOM;
				view.setDisplayObject(btm);
				owner.addDecorator(view);
			}
			var b : PhysBody = new PhysBody();
			
			fixtureDef = new b2FixtureDef();
			fixtureDef.density = density;
			fixtureDef.restitution = restitution;
			b.addCircle(0, 0, radius, 1, fixtureDef);
			b.body.SetType(b2Body.b2_dynamicBody);
			b.body.SetPosition(new b2Vec2(x, y));
			b.body.SetBullet(true);
			owner.addDecorator(b);
		}
		
		public function get type():int { return _type; }
		
		public function set type(value:int):void {
			_type = value;
		}
		
		public function get radius():Number { return _radius; }
		
		public function set radius(value:Number):void {
			_radius = value;
		}
		
	}

}