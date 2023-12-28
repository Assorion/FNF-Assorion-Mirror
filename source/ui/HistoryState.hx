package ui;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import misc.Alphabet;
import gameplay.PauseSubState;

using StringTools;

#if !debug @:noDebug #end
class HistoryState extends MenuTemplate {
    public var dontUpdate:Bool = false;

    var lines:Array<String> = [];
    var contents:Array<String> = [];

    override function create()
    {
        super.create();
        background.color = CoolUtil.cfArray([145, 113, 255]);
        //adds = [0];
        splitNumb = 2;

        var currentContent:Int = -1;

        // coolutil textfile lines would've worked if I could use "../../" in the path.
        for(item in Paths.lText('CHANGELOG.md', '').split('\n')){
            if(item.startsWith("# ")) continue;
            if(item == "" || item == " ") continue;

            item = item.replace("**", "");

            if(!item.startsWith("## ")) {
                contents[currentContent] += item + '\n';
                continue;
            } else currentContent++;

            item = item.replace("## ", "");
            item = item.replace(" - ", "");
            item = item.replace(".", " ");

            var tmpSpr:StaticSprite = new StaticSprite(0,0).makeGraphic(1,1,0x00000000);

            pushObject(tmpSpr);
            pushObject(new Alphabet(0, (60 * 1) + 30, item, true));
        }

        // literally stolen from freeplay.
        var bottomBlack:StaticSprite = new StaticSprite(0, FlxG.height - 30).makeGraphic(1280, 30, 0xFF000000);
        var str='Press ${misc.InputString.getKeyNameFromString(Binds.UI_ACCEPT[0], true, false)} to see the entry. / ${misc.InputString.getKeyNameFromString(Binds.UI_BACK[0], true, false)} to go back.';
		var descText = new FlxText(5, FlxG.height - 25, 0, str, 20);

		descText.setFormat('assets/fonts/vcr.ttf', 20, 0xFFFFFF, LEFT);
		bottomBlack.alpha = 0.6;

        sAdd(bottomBlack);
		sAdd(descText);
    }
    override function keyHit(ev:KeyboardEvent){
        if(dontUpdate) return;

        super.keyHit(ev);

        if(!key.hardCheck(Binds.UI_ACCEPT)) return;

        openSubState(new HistorySubstate(contents[curSel], this));
    }

    override public function exitFunc(){
		if(skipCheck()) 
            return;

        MusicBeatState.changeState(new OptionsState());
	}

    override public function update(elapsed:Float)
        if(!dontUpdate)
            super.update(elapsed);
}
class HistorySubstate extends MusicBeatSubstate {
    var bgSpr:FlxSprite;
    var awesomeText:FlxText;
    var parent:HistoryState;

    public function new(text:String, parent:HistoryState){
        parent.dontUpdate = true;
        this.parent = parent;
        super();

        var tmpBg:BitmapData = new BitmapData(1180, 620, true);
        tmpBg.fillRect(new Rectangle(0,0, 1180, 620), 0xFFFFFFFF);
        tmpBg.fillRect(new Rectangle(4,4, 1172, 612), 0xFF000000);

        bgSpr = new StaticSprite(50, 50).loadGraphic(tmpBg);
        bgSpr.alpha = 0;
        bgSpr.scrollFactor.set(0,0);

        // without the substring, it will always start with 'null', so I just skip the first 4 characters.
        awesomeText = new FlxText(0, 0, 0, text.substring(4, text.length), 22);
		awesomeText.setFormat('assets/fonts/vcr.ttf', 22, 0xFFFFFF, LEFT);
        awesomeText.scrollFactor.set(0,0);
        awesomeText.alpha = 0;
        awesomeText.screenCenter();

        add(bgSpr);
        add(awesomeText);
    }
    override public function update(elapsed:Float){
        super.update(elapsed);

        if(bgSpr.alpha < 0.7)
            bgSpr.alpha += elapsed * 2;

        if(awesomeText.alpha < 1)
            awesomeText.alpha += elapsed * 1.5;
    }

    override public function keyHit(ev:KeyboardEvent){
        super.keyHit(ev);

        if(!key.hardCheck(Binds.UI_BACK)) return;

        parent.dontUpdate = false;
        close();
    }
}