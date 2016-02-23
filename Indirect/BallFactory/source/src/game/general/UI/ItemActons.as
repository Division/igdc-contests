package game.general.UI {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import resourcemanager.ResManager;
	
	/**
	 * @author Division
	 */
	public class ItemActons extends Sprite{
		
		public var deleteBtn : Sprite;
		public var rotateRBtn : Sprite;
		public var rotateLBtn : Sprite;
		public var configBtn : Sprite;
		
		private var _radius : Number;
		public var needRadius : Number;
		
		public function ItemActons() {
			
			deleteBtn = new Sprite();
			deleteBtn.buttonMode = true;
			deleteBtn.useHandCursor = true;
			
			rotateLBtn = new Sprite();
			rotateLBtn.buttonMode = true;
			rotateLBtn.useHandCursor = true;
			
			rotateRBtn = new Sprite();
			rotateRBtn.buttonMode = true;
			rotateRBtn.useHandCursor = true;
			
			configBtn = new Sprite();
			configBtn.buttonMode = true;
			configBtn.useHandCursor = true;
			
			addChild(deleteBtn);
			addChild(rotateLBtn);
			addChild(rotateRBtn);
			addChild(configBtn);
			
			var bd : BitmapData = ResManager.getTexture('common/graphics/ui/item_delete_btn.png');
			var bitmap : Bitmap = new Bitmap(bd);
			bitmap.x = - bitmap.width / 2;
			bitmap.y = - bitmap.height / 2;
			deleteBtn.addChild(bitmap);
			
			bd = ResManager.getTexture('common/graphics/ui/item_params_btn.png');
			bitmap = new Bitmap(bd);
			bitmap.x = - bitmap.width / 2;
			bitmap.y = - bitmap.height / 2;
			configBtn.addChild(bitmap);
			
			bd = ResManager.getTexture('common/graphics/ui/item_rotate_btn.png');
			bitmap = new Bitmap(bd);
			bitmap.x = - bitmap.width / 2;
			bitmap.y = - bitmap.height / 2;
			rotateRBtn.addChild(bitmap);

			bitmap = new Bitmap(bd);
			bitmap.x = - bitmap.width / 2;
			bitmap.y = - bitmap.height / 2;
			bitmap.scaleX = -1;
			rotateLBtn.addChild(bitmap);
		}
		
		public function redraw() : void {
			var g : Graphics = graphics;
			g.clear();
		    //g.beginFill(0xFFFFFF);
			//g.lineStyle(0);
			g.drawCircle(0, 0, radius);
			
			//g.endFill();
	        
			//setChildIndex();
			
			configBtn.x = 0;
			configBtn.y = -radius;
			deleteBtn.x = 0;
			deleteBtn.y = radius;
			rotateLBtn.x = Math.cos(-Math.PI / 6 - Math.PI / 2) * radius + rotateLBtn.width/2;
			rotateLBtn.y = Math.sin(-Math.PI / 6 - Math.PI / 2) * radius + rotateLBtn.height/2;
			rotateRBtn.x = Math.cos( Math.PI / 6 - Math.PI / 2) * radius + rotateRBtn.width/2;
			rotateRBtn.y = Math.sin( Math.PI / 6 - Math.PI / 2) * radius + rotateRBtn.height/2;
		}
		
		public function set radius(value:Number):void {
			_radius = value;
			redraw();
		}
		
		public function setPos(x : Number, y : Number) : void {
			this.x = int(x);
			this.y = int(y);
		}
		
		public function get radius():Number { return _radius; }
		
	}

}