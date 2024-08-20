package frontend;

import flixel.FlxG;
import flixel.util.FlxColor;

class OffsetWizard extends MusicBeatState {
    public var curOffset:Float = 0;
    public var prevOffset:Int = 0;
    public var offsetsArray:Array<Float> = [];

    var beatText:FormattedText;
    var offsetText:FormattedText;

    var songTime:Float = 0;
    var rootBeat:Int = 0;

    override public function create(){
        super.create();

        prevOffset = Settings.audio_offset;
        Settings.audio_offset = 0;

        FlxG.sound.playMusic('assets/sounds/offset.${Paths.sndExt}');
        Song.musicSet(100);
        Song.beatHooks.push(beatHit);

        var bg:StaticSprite = new StaticSprite(0,0).loadGraphic('assets/images/ui/menuDesat.png');
		bg.scrollFactor.set(0,0);
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = FlxColor.fromRGB(110, 120, 255);

        add(bg);

        var infoText:FormattedText  = new FormattedText(0, 0, 0, 'Tap any key to the AUDIO beat.\nNOT the visual beat!\nAny key will work.', null, 30, 0xFFFFFFFF, CENTER, OUTLINE);
	infoText.screenCenter(X);
        infoText.y = (720 / 4) - (infoText.height / 2);
        add(infoText);

        offsetText = new FormattedText(0, 0, 0, 'Current Offset: 0 Milliseconds', null, 30, 0xFFFFFFFF, CENTER, OUTLINE);
	offsetText.screenCenter(X);
        offsetText.y = 540 - (offsetText.height / 2);
        add(offsetText);

        beatText = new FormattedText(0, 0, 0, 'BEAT HIT!', null, 80, 0xFFFFFFFF, CENTER, OUTLINE);
        beatText.borderSize = 4;
	beatText.screenCenter();
        beatText.alpha = 0;
        add(beatText);
    }

    public static var fakeBeat:Int = 0;
    override public function update(elapsed:Float){
        Song.update(FlxG.sound.music.time);

        if(beatText.alpha > 0)
            beatText.alpha -= elapsed * 2;

        songTime += elapsed * 1000 * Song.division;

        var pfb:Int = fakeBeat;
        fakeBeat = Math.floor((FlxG.sound.music.time - curOffset - 10) / Song.crochet);

        if(fakeBeat > pfb && fakeBeat & 0x01 == 0)
            beatText.alpha = 1;

        super.update(elapsed);
    }

    public function beatHit(){
        if(Song.currentBeat & 0x01 == 0)
            songTime = Song.currentStep;

        rootBeat = Math.round(Song.currentBeat * 0.5);
    }

    override public function keyHit(ev:KeyboardEvent){
        if(ev.keyCode.deepCheck([ Binds.UI_ACCEPT, Binds.UI_BACK ]) != -1){
            FlxG.sound.music.stop();
            MusicBeatState.changeState(new OptionsState());

            Settings.audio_offset = prevOffset;
            if(!ev.keyCode.hardCheck(Binds.UI_ACCEPT)) 
                return;

            Settings.audio_offset = Math.round(curOffset);
            SettingsManager.flush();
            return;
        }

        offsetsArray.push(((songTime / 8) - rootBeat) * Song.crochet * 2);
        curOffset = 0;
        for(i in 0...offsetsArray.length)
            curOffset += offsetsArray[i];

        curOffset = Math.floor(Math.abs(curOffset / offsetsArray.length));

        offsetText.text = 'Current Offset: $curOffset Milliseconds';
        offsetText.screenCenter(X);
    }
}
