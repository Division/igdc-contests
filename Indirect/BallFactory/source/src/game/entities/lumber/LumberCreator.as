﻿package game.entities.lumber {
	import Box2D.Collision.Shapes.b2PolygonShape;
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
	import resourcemanager.ResManager;
	
	/**
	 * @author Division
	 */
	public class LumberCreator extends BaseCreator{
		
		public static const NAME : String = "LumberCreator";
		
		public function LumberCreator() {
			super(NAME, Lumber.NAME);
		}
		
		override public function deserialize(data : * ) : void {
			super.deserialize(data);
			
			var btm : Bitmap;
			var bd : BitmapData = ResManager.getTexture(Lumber.IMAGE_NAME);
			if (bd) {
				btm = new Bitmap(bd);
				var view : ItemView = new ItemView();
				view.setDisplayObject(btm);
				view.layer = Const.LAYER_ITEMS;
				owner.addDecorator(view);
			}
			var b : PhysBody = new PhysBody();
			
			b.addCircle(0, 0, Lumber.RADIUS, 1, null);
			
			b.body.SetType(b2Body.b2_staticBody);
			owner.addDecorator(b);
		}
		
	}

}