package ui;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import ui.ChartingState;
import openfl.geom.Rectangle;
import flixel.text.FlxText;
import gameplay.Note;

using StringTools;

class ChartUI_Grid extends StaticSprite {
    public function new(cWidth:Int, cHeight:Int, columns:Int, rows:Int, division:Int = 4)
    {
        var emptySprite:BitmapData = new BitmapData(cWidth * columns, cHeight * rows, true);
        var colOffset:Int = 0;

        for(i in 0...columns)
            for(j in 0...rows){
                var grCol = CoolUtil.cfArray(ChartingState.gridColours[j % division][(i + colOffset) % 2]);

                emptySprite.fillRect(new Rectangle(i * cWidth, j * cHeight, cWidth, cHeight), grCol);
                colOffset++;
            }

        // blackline down the middle.
        for(i in 1...Math.floor(columns / Note.keyCount))
            emptySprite.fillRect(new Rectangle((cWidth * Note.keyCount * i) - 2, 0, 4, cHeight * rows), FlxColor.BLACK);

        super(0,0);
        
        loadGraphic(emptySprite);
    }
}

// Extenders or whatever.

class ChartUI_Generic extends FlxSprite {
    var canvas:BitmapData;

    // # drawing
    public inline function drawSquare(dx:Int, dy:Int, w:Int, h:Int, ?indent:Bool = false){
        var col1:Int = indent ? 0 : 2;
        var col2:Int = indent ? 2 : 0;

        canvas.fillRect(new Rectangle(dx,  dy,   w,   h)  , CoolUtil.cfArray(ChartingState.uiColours[col1 ]));
        canvas.fillRect(new Rectangle(dx+3,dy+3, w-3, h-3), CoolUtil.cfArray(ChartingState.uiColours[col2 ]));
        canvas.fillRect(new Rectangle(dx+3,dy+3, w-6, h-6), CoolUtil.cfArray(ChartingState.uiColours[1    ]));
    }
    public inline function makeText(w:Int, h:Int, ?indent:Bool = false, ?txt:String = '', ?dx:Int = 0, ?dy:Int = 0){
        drawSquare(dx,dy, w,h, indent);

        if(txt == null || txt == '') return;

        var text:FlxText = new FlxText(0,0,0,txt,16);
        stamp(text, dx + Std.int((w - text.width) / 2), dy + Std.int((h - text.height) / 2));
    }

    // # Mouse movements

    public function mouseOverlaps(){}
    public function mouseClicked(){}

    /////////////////////////////

    public function new(x:Float, y:Float, w:Int, h:Int, i:Bool, t:String){
        super(x,y);

        canvas = new BitmapData(w, h, true);
        loadGraphic(canvas);
        makeText(w,h,i,t);
    }
}
class ChartUI_Persistent extends ChartUI_Generic {
    public function insertChar(k:Int):Void {}
    public function clickedOff():Void {
        ChartingState.inputBlock = null;
    }
    override public function mouseClicked(){
        ChartingState.inputBlock = this;
    }
}

// # Easy stuff

class ChartUI_CheckBox extends ChartUI_Generic{
    public var changeFunc:Bool->Void;
    public var checked:Bool = false;

    public function new(x:Float, y:Float, ?w:Int = 30, ?h:Int = 30, startChecked:Bool = false, onChange:Bool->Void){
        super(x,y,w,h,true,'');

        changeFunc = onChange;
        checked = startChecked;
        if(checked)
            drawSquare(6,6, w - 12, h - 12, false);
    }
    override public function mouseClicked(){
        checked = !checked;

        var w = Math.floor(width);
        var h = Math.floor(height);

        drawSquare(0,0,w,h,true);
        if(checked)
            drawSquare(6,6, w - 12, h - 12, false);

        changeFunc(checked);
    }
}

class ChartUI_Button extends ChartUI_Generic {
    public var clickFunc:Void->Void;
    public var txt:String = '';
    public var dropDownButton:Bool = false;

    public var popupCounter:Float = 0;
    private static inline var clickTime:Float = 0.08;

    public function new(x:Float, y:Float, ?w:Int = 90, ?h:Int = 30, onClick:Void->Void, ?text:String){
        super(x,y,w,h,false,text);

        clickFunc = onClick;
        txt = text;
    }

    override public function mouseClicked(){
        clickFunc();
        if(dropDownButton) return;

        makeText(Math.floor(width), Math.floor(height), true, txt);
        popupCounter = 0;
    }
    override public function update(elapsed:Float){
        if(popupCounter < clickTime){
            popupCounter += elapsed;
            return;
        }
        if(popupCounter == 100) return;

        popupCounter = 100;
        makeText(Math.floor(width), Math.floor(height), false, txt);
    }
}

// # Persistent stuff

class ChartUI_DropDown extends ChartUI_Persistent {
    public var changeFunc:Int->String->Void;
    public var buttonList:Array<ChartUI_Button> = [];
    public var items:Array<String>;
    public var expanded:Bool = false;
    public var parentGroup:FlxTypedSpriteGroup<ChartUI_Generic>;
    
    public var curText:String = '';

    public inline function dotButton(){
        var w:Int = Math.floor(width) - 30;
        var h:Int = Math.floor(height);

        makeText(w,  h, expanded, curText, 0, 0);
        makeText(30, h, expanded, '.'    , w, 0);
    }

    public function new(x:Float, y:Float, ?w:Int = 90, ?h:Int = 30, items:Array<String>, text:String = '', onChange:Int->String->Void, parent:FlxTypedSpriteGroup<ChartUI_Generic>){
        super(x,y,w + 30,h,false,'');

        changeFunc = onChange;
        parentGroup = parent;
        this.items = items;

        curText = text;
        dotButton();
    }

    override public function clickedOff(){
        super.clickedOff();

        expanded = false;
        dotButton();

        for(i in 0...buttonList.length){
            parentGroup.remove(buttonList[i]);

            buttonList[i].destroy();
            buttonList[i] = null;
        }
    }
    public override function mouseClicked(){
        expanded = !expanded;
        if(!expanded){
            clickedOff();
            return;
        }

        dotButton();
        super.mouseClicked();

        var w:Int = Math.floor(width);
        var h:Int = Math.floor(height);

        for(i in 0...items.length){
            buttonList[i] = new ChartUI_Button(x - parentGroup.x,(y - parentGroup.y) + (h * (i + 1)), w, h, function(){
                curText = items[i];

                changeFunc(i, items[i]);
                clickedOff();
            }, items[i]);
            buttonList[i].dropDownButton = true;
            parentGroup.add(buttonList[i]);
        }
    }
}
class ChartUI_InputBox extends ChartUI_Persistent {
    public var curText:String = '';
    public var changeFunc:String->Void;
    public var uneditedText:String = '';
    public static inline var allowedCharacters:String = "abcdefghijklmnopqrstuvwxyz1234567890-+=_!@#$%^&*(){}[]\\;'\":,.<>/? ";

    private var tickingCounter:Float = 0;
    private var suffix:String = ' _';

    public inline function redoText(){
        curText = uneditedText;
        if(ChartingState.inputBlock == this)
            curText += suffix;

        makeText(Math.floor(width), Math.floor(height), true, curText, 0,0);
    }
    public function new(x:Float, y:Float, ?w:Int = 90, ?h:Int = 30, startText:String = '', onChange:String->Void){
        super(x,y,w,h,true,startText);

        changeFunc = onChange;
        uneditedText = startText;
    }
    
    //////////////////////////////////

    public override function clickedOff(){
        super.clickedOff();

        changeFunc(uneditedText);
        redoText();
    }

    public override function mouseClicked(){
        super.mouseClicked();

        pSuffix = '';
        suffix  = ' _';
        tickingCounter = 0;
        redoText();
    }
    public override function insertChar(char:Int){
        if(char == flixel.input.keyboard.FlxKey.BACKSPACE){
            uneditedText = uneditedText.substring(0, uneditedText.length - 1);
            redoText();
            return;
        }

        var tmpChar:String = misc.InputString.getKeyNameFromString( char, true, true ).toLowerCase();
        if(!allowedCharacters.contains(tmpChar)) return;

        uneditedText += tmpChar;
        redoText();
    }

    //////////////////////////////////

    private var pSuffix:String = '';
    override function update(elapsed:Float){
        if(ChartingState.inputBlock != this) return;

        tickingCounter += elapsed;
        if(tickingCounter >= 1) 
            tickingCounter -= 1;

        pSuffix = tickingCounter < 0.5 ? ' _' : '   ';

        if(pSuffix != suffix){
            suffix = pSuffix;
            redoText();
        }
    }
}