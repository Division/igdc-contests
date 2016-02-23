package game.general.UI 
{
	import fl.controls.Button;
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.controls.Label;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import game.events.GetItemDataEvent;
	import game.general.GameController;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ItemConfigMenu extends Sprite
	{
		private var _itemsParams: Object; 
		private var _itemsParamsValues: Object;
		private var _controllElements: Array = new Array();
		private var _label:String = 'Label';
		
		private const WIDTH_PANEL:Number = 150;
		
		public function ItemConfigMenu(x:Number,y:Number) 
		{
		    this.x = x;
			this.y = y;
		}
		
		public function setItems(params: Object): void {
		   	this._itemsParams = params;
		}
		
		public function setItemsValue(param: Object): void {
		    this._itemsParamsValues = param;
		}
		
		public function update():void {
			
			for (var i:int = 0; i < this._controllElements.length; i++) {
				this.removeChild(this._controllElements[i]);
			}
			/*
			var menuLabel: Label = new Label();
			menuLabel.text = this._label;
			menuLabel.x = (WIDTH_PANEL - saveBtn.width) / 2;
			var menuTextField: TextField = new TextField();
			menuTextField.textHeight = 10;
			menuTextField.textWidth = 20;
			menuLabel.textField = menuTextField;
			*/
			this._controllElements = new Array();
			
			this.addControllCheckBox('putInPanel','Put in panel');
			this.addControllCheckBox('isStatic','Is static');
			this.addControllComboBox('ballType','Ball type', [1]);
			this.addControllComboBox('ballCount', 'Ball count', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
			this.addControllComboBox('power', 'Power', [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
			
			var arr : Array = [];
			for (i = 1; i < 20; i++ ) {
				arr.push(i * 2 / 10);
			}
			
			this.addControllComboBox('shootDelay', 'Shoot delay', arr);
				
			// save button
			var saveBtn : Button = new Button();
			saveBtn.name = "saveBtn";
			saveBtn.label = "Save";
			saveBtn.x = (WIDTH_PANEL - saveBtn.width) / 2;			
			// set event
			saveBtn.addEventListener(MouseEvent.MOUSE_DOWN, saveParmsHandler,false, 0, true);
			
			// Объясни мне зачем это делать? (: Чтоб потом в цикле делать if (this._controllElements[i].name == "saveBtn") { continue; }?
			this._controllElements.push(saveBtn); // Если это только для позиционирования, то ИМХО лучше было после всех элементов вручную ставить
			
			var height_panel: Number = 0;
			
			for (var j:int = 0; j < this._controllElements.length; j++) {
				if (j != 0) { 
					height_panel = this._controllElements[j].y = this._controllElements[j-1].y + this._controllElements[j-1].height + 6;
				}
				this.addChild(this._controllElements[j]);
			}
		
			this.graphics.clear();
			this.graphics.beginFill(0x55A4DF);
			this.filters = [new DropShadowFilter(4,45,10,5,10,10,2,2,false,false)];
			this.graphics.drawRoundRect(0, 0, WIDTH_PANEL, height_panel+saveBtn.height+10, 10, 10);
			this.graphics.endFill();
		
		}
		
		private function saveParmsHandler(e:MouseEvent):void 
		{
			var params : Object = new Object();
			var value:*;
			for (var i:int = 0; i < this._controllElements.length; i++) {
				if (this._controllElements[i].name == "saveBtn") { continue; } // да, да, зачем это было добавлять в _controllElements?
				
				switch(getQualifiedClassName(this._controllElements[i])) {
				  case 'fl.controls::CheckBox': value = this._controllElements[i].selected; break;
				  case 'fl.controls::ComboBox': value = this._controllElements[i].selectedLabel; break; 	
				}
				params[this._controllElements[i].name] = value;
			}
	        this.visible = false;
			if (!GameController.instance.selectedItem) return;
			var ev : GetItemDataEvent = new GetItemDataEvent(GetItemDataEvent.ITEM_PARAMS_UPDATE);
			ev.newItemParams = params;
			GameController.instance.selectedItem.sendEvent(ev);
		}
		
		private function addControllCheckBox(name:String, label:String):void {
			if (!this._itemsParams[name]) { return; }
			var checkBox: CheckBox = new CheckBox();
			if (this._itemsParamsValues[name]) { checkBox.selected = true; }
			checkBox.name = name;
			checkBox.label = label;
			this._controllElements.push(checkBox);
		}
		
		private function addControllComboBox(name:String, label:String, items:Array):void {
			if (!this._itemsParams[name]) { return; }
			var comboBox: ComboBox = new ComboBox();
			comboBox.setSize(50, 20);
			comboBox.x = WIDTH_PANEL-comboBox.width-4;
			
			var _label:Label = new Label();
			_label.text = label;
			_label.width = WIDTH_PANEL-comboBox.width;
			comboBox.addChild(_label).x = ((WIDTH_PANEL+comboBox.width-10)/2)*-1;
			
			for (var i:int = 0; i < items.length; i++) {
              comboBox.addItem( { label:items[i] } );
            }
			
			if (this._itemsParamsValues[name]) { 
				
				var indexElement:int = 0;
				for (i = 0; i < items.length; i++) {
                  if (this._itemsParamsValues[name] == items[i]) { indexElement = i; break; }
                }
				comboBox.selectedIndex = indexElement; 
			}
			comboBox.name = name;
			this._controllElements.push(comboBox);
		}
	}

}