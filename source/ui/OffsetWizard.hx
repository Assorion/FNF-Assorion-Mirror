package ui;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;

class OffsetWizard extends MusicBeatState {
    public var curOffset:Float = 0;
    public var prevOffset:Int = 0;
    public var offsetsArray:Array<Float> = [];

    var beatText:FlxText;
    var offsetText:FlxText;

    var songTime:Float = 0;
    var rootBeat:Int = 0;

    override public function create(){
        prevOffset = Settings.pr.audio_offset;
        Settings.pr.audio_offset = 0;

        FlxG.sound.playMusic('assets/sounds/offset.${Paths.sndExt}');
        Song.musicSet(100);

        var bg:StaticSprite = new StaticSprite(0,0).loadGraphic('assets/images/ui/menuDesat.png');
		bg.scrollFactor.set(0,0);
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = FlxColor.fromRGB(110, 120, 255);

        add(bg);

        var infoText:FlxText = new FlxText(0, 0, 0, 'Tap any key to the AUDIO beat.\nNOT the visual beat!\nAny key will work.', 30);
		infoText.setFormat("assets/fonts/vcr.ttf", 30, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		infoText.screenCenter(X);
        infoText.y = (720 / 4) - (infoText.height / 2);
        add(infoText);

        offsetText = new FlxText(0, 0, 0, 'Current Offset: 0 Milliseconds', 30);
		offsetText.setFormat("assets/fonts/vcr.ttf", 30, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
		offsetText.screenCenter(X);
        offsetText.y = 540 - (offsetText.height / 2);
        add(offsetText);

        beatText = new FlxText(0, 0, 0, 'BEAT HIT!', 80);
		beatText.setFormat("assets/fonts/vcr.ttf", 80, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
        beatText.borderSize = 4;
		beatText.screenCenter();
        beatText.alpha = 0;
        add(beatText);

        super.create();
    }

    public static var fakeBeat:Int = 0;
    override public function update(elapsed:Float){
        if(beatText.alpha > 0)
            beatText.alpha -= elapsed * 2;

        songTime += elapsed * 1000 * Song.Division;

        var pfb:Int = fakeBeat;
        fakeBeat = Math.floor((FlxG.sound.music.time - curOffset - 10) / Song.Crochet);

        if(fakeBeat > pfb && fakeBeat & 0x01 == 0)
            beatText.alpha = 1;

        super.update(elapsed);
    }
    override public function beatHit(){
        if(curBeat & 0x01 == 0)
            songTime = curStep;

        rootBeat = Math.round(curBeat * 0.5);
    }

    override public function keyHit(ev:KeyboardEvent){
        if(ev.keyCode.deepCheck([ Binds.UI_ACCEPT, Binds.UI_BACK ]) != -1){
            FlxG.sound.music.stop();
            MusicBeatState.changeState(new OptionsState());

            Settings.pr.audio_offset = prevOffset;
            if(!ev.keyCode.hardCheck(Binds.UI_ACCEPT)) 
                return;

            Settings.pr.audio_offset = Math.round(curOffset);
            Settings.flush();

            return;
        }

        offsetsArray.push(((songTime / 8) - rootBeat) * Song.Crochet * 2);
        curOffset = 0;
        for(i in 0...offsetsArray.length)
            curOffset += offsetsArray[i];

        curOffset = Math.floor(Math.abs(curOffset / offsetsArray.length));

        offsetText.text = 'Current Offset: $curOffset Milliseconds';
        offsetText.screenCenter(X);
    }
}