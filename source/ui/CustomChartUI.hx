package ui;

import flixel.FlxSprite;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import ui.ChartingState;
import openfl.geom.Rectangle;
import flixel.text.FlxText;

using StringTools;

/*
    This is just a mess. Sorry.
    My only solice is that this terrible code,
    only has to be ran while charting.
*/

// # chart ui elements
class ChartUI_Button extends FlxSprite {
    public var clickFunc:Void->Void;

    public function new(x:Float, y:Float, useBright:Bool = false, onClick:Void->Void, text:String = '', twidth:Int = 90){
        super(x,y);

        var emptySprite:BitmapData = new BitmapData(twidth, 30, true);
        emptySprite.fillRect(new Rectangle(0,0, twidth  , 30), ChartingState.colorFromRGBArray(ChartingState.uiColours[0]));
        emptySprite.fillRect(new Rectangle(4,4, twidth-8, 22), ChartingState.colorFromRGBArray(ChartingState.uiColours[ useBright ? 2 : 1 ]));

        loadGraphic(emptySprite);
        updateHitbox();

        var text:FlxText = new FlxText(0,0,0,text,16);
        stamp(text, Std.int((width / 2) - (text.width / 2)), Std.int((height / 2) - (text.height / 2)));
        clickFunc = onClick;
    }

    override public function update(elapsed:Float){
        if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(this) && ChartingState.activeUIElement == null)
            clickFunc();
    }
}
class ChartUI_DropDown extends FlxSprite {
    public var itemList:Array<String> = [];
    public var selectedItem:String = '';
    public var buttonWidth:Int = 200;
    private var dropped:Bool = false;
    private var changeFunc:String->Void;

    public function createButton(items:Array<String>)
    {
        var emptySprite:BitmapData = new BitmapData(buttonWidth, 30 * items.length, true);
        emptySprite.fillRect(new Rectangle(0,0, buttonWidth  ,   30 * items.length),    ChartingState.colorFromRGBArray(ChartingState.uiColours[0]));
        emptySprite.fillRect(new Rectangle(4,4, buttonWidth-8,  (30 * items.length)-8), ChartingState.colorFromRGBArray(ChartingState.uiColours[2]));

        loadGraphic(emptySprite);
        updateHitbox();

        for(i in 0...items.length){
            var text = new FlxText(0,0,0, items[i], 16);
            stamp(text, Std.int((width / 2) - (text.width / 2)), Std.int((30 * (i+1) - 15) - (text.height / 2)));
        }
        ChartingState.blockInput = dropped = false;
        ChartingState.activeUIElement = null;
    }

    public function new(x:Float, y:Float, twidth:Int = 200, items:Array<String>, startSelect:String = '', onChange:String->Void){
        super(x,y);
        
        itemList = items;
        selectedItem = items[0];
        buttonWidth = twidth;
        changeFunc = onChange;
        if(startSelect != '') selectedItem = startSelect;

        createButton([selectedItem]);
    }

    override public function update(elapsed:Float){
        if(!FlxG.mouse.justPressed || (ChartingState.activeUIElement != this && ChartingState.activeUIElement != null) ) return;

        
        if(!FlxG.mouse.overlaps(this)){
            if(dropped) createButton([selectedItem]);
            return;
        }

        if(!dropped){
            createButton(itemList);
            dropped = true;
            ChartingState.blockInput = true;
            ChartingState.activeUIElement = this;
            return;
        } 
        //var fX = FlxG.mouse.x - x;
        var fY = FlxG.mouse.y - y;
        var sel = CoolUtil.boundTo(Math.floor(fY / 30), 0, itemList.length - 1, true);
        createButton([ itemList[sel] ]);
        changeFunc(itemList[sel]);
    }
}
class ChartUI_InputBox extends FlxSprite {
    public var curText:String = '';
    public var changeFunc:String->Void;
    public var boxWidth:Int = 200;
    public static var allowedCharacters:String = "abcdefghijklmnopqrstuvwxyz1234567890-+=_!@#$%^&*(){}[]\\;'\":,.<>/? ";
    public var typing:Bool = false;

    public function updateEverything(){
        var emptySprite:BitmapData = new BitmapData(boxWidth, 30, true);
        emptySprite.fillRect(new Rectangle(0,0, boxWidth  ,30), ChartingState.colorFromRGBArray(ChartingState.uiColours[0]));
        emptySprite.fillRect(new Rectangle(4,4, boxWidth-8,22), ChartingState.colorFromRGBArray(ChartingState.uiColours[2]));

        loadGraphic(emptySprite);
        updateHitbox();

        var text = new FlxText(0,0,0, curText, 16);
        text.color = typing ? FlxColor.BLACK : FlxColor.WHITE;
        stamp(text, Std.int((width / 2) - (text.width / 2)), Std.int(15 - (text.height / 2)));
        changeFunc(curText);
    }

    public function new(x:Float, y:Float, twidth:Int = 200, startText:String = '', onChange:String->Void){
        super(x,y);
        
        curText = startText;
        boxWidth = twidth;
        changeFunc = onChange;

        updateEverything();
        //createButton([selectedItem]);
    }

    override public function update(elapsed:Float){
        if(ChartingState.activeUIElement != this && ChartingState.activeUIElement != null) return;

        if(FlxG.mouse.justPressed || FlxG.keys.justPressed.ENTER){
            if(typing){
                typing = ChartingState.blockInput = false;
                ChartingState.activeUIElement = null;
            }

            if(FlxG.mouse.overlaps(this)){
                typing = ChartingState.blockInput = true;
                ChartingState.activeUIElement = this;
            }

            updateEverything();
            return;
        }

        if(!typing || !FlxG.keys.justPressed.ANY) return;
        if (FlxG.keys.justPressed.SHIFT) return;

        if(FlxG.keys.justPressed.BACKSPACE)
            curText = curText.substring(0, curText.length - 1);
        else {
            var char = misc.InputString.getKeyNameFromString( FlxG.keys.firstJustPressed(), true, true ).toLowerCase();
            
            if(allowedCharacters.contains(char))
                curText += char;
        }
        updateEverything();
    }
}

class ChartUI_CheckBox extends FlxSprite{
    public var changeFunc:Bool->Void;
    public var checked:Bool = false;

    public function swap(makeChanges:Bool = true){
        if(makeChanges){
            checked = !checked;
            changeFunc(checked);
        }

        var emptySprite:BitmapData = new BitmapData(30, 30, true);
        emptySprite.fillRect(new Rectangle(0,0, 30, 30), ChartingState.colorFromRGBArray(ChartingState.uiColours[0]));
        emptySprite.fillRect(new Rectangle(4,4, 22, 22), ChartingState.colorFromRGBArray(ChartingState.uiColours[2]));

        if(checked)
            emptySprite.fillRect(new Rectangle(8,8, 14, 14), ChartingState.colorFromRGBArray(ChartingState.uiColours[0]));

        loadGraphic(emptySprite);
        updateHitbox();
    }

    public function new(x:Float, y:Float, checked:Bool = false, onChange:Bool->Void){
        super(x,y);

        this.checked = checked;
        changeFunc   = onChange;
        swap(false);
    }

    override public function update(elapsed:Float){
        if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(this) && ChartingState.activeUIElement == null)
            swap();
    }
}