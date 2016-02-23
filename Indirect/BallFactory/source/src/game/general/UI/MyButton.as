package game.general.UI {
	import fl.controls.Label;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import resourcemanager.ResManager;
	
	/**
	 * ...
	 * @author D
	 */
	public class MyButton extends Sprite{
				
		private var _imageDefault: String;
		private var _imageOver: String;
		private var _imageClick: String;
		private var _imageDisable: String;
		
		private var _name:String;
		
		private var _state: Boolean = true;
		
		private var _btm: DisplayObject;
		
		private var _label: TextField;
		
		public function create():MyButton {

			this.buttonMode = true;
			this.useHandCursor = true;
		    this.mouseChildren = false;
			if (!_imageDefault) { throw new Error("You must set default image"); }
			setImage(_imageDefault);
			setLiseners();
			
			return this;
		}
		
		public function disable(): void {
		  if (_state == true) {
		    cleareLiseners();
		    setImage(_imageDisable);
		    _state = false;
		  }
		}
		
		public function enable(): void {
		  if(_state==false){
		    setLiseners();
		    setImage(_imageDefault);
		    _state = true;
		  }
		}
		
		private function setLiseners():void {
			if(_imageOver){  this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler); }
		    if(_imageOver){  this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler); }
			if(_imageClick){ this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler); }
			if(_imageOver && _imageClick){ this.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler); }
		}
		
		private function cleareLiseners():void {
			if(_imageOver){  this.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler); }
		    if(_imageOver){  this.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler); }
			if(_imageClick){ this.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler); }
			if(_imageOver && _imageClick){ this.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler); }
		}
		
		private function mouseUpHandler(e:MouseEvent):void {
			setImage(_imageOver);
		}
		
		private function mouseDownHandler(e:MouseEvent):void {
			setImage(_imageClick);
		}
		
		private function mouseOutHandler(e:MouseEvent):void {
			setImage(_imageDefault);
		}
		
		private function mouseOverHandler(e:MouseEvent):void {
			setImage(_imageOver);
		}
		
		private function setImage(image:String):void {
			if (this._btm && this.contains(this._btm)) { this.removeChild(this._btm); }
			this._btm = this.addChild(new Bitmap(ResManager.getTexture(image)));
			if (_label) { this.addChild(_label); }
		}
				
		public function imageDefault(value:String):MyButton {
			_imageDefault = value;
			return this;
		}
		
		public function imageOver(value:String):MyButton {
			_imageOver = value;
			return this;
		}
		
		public function imageClick(value:String):MyButton {
			_imageClick = value;
			return this;
		}
		
		public function imageDisable(value:String):MyButton {
			_imageDisable = value;
			return this;
		}
		
		public function positionX(value:Number):MyButton {
			this.x = value;
			return this;
		}
		
		public function postionY(value:Number):MyButton {
			this.y = value;
			return this;
		}
		
		public function state(value:Boolean):MyButton {
			_state = value;
			return this;
		}
				
		public function setName(value:String):MyButton {
			_name = value;
			return this;
		}
		
		public function getName():String {
			return _name;
		}
		
		public function setLabel(value:TextField):MyButton {
			this.addChild(value);
			_label = value;
			return this;
		}
		
	}

}