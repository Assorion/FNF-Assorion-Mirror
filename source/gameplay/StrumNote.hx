package gameplay;

import flixel.FlxSprite;
import flixel.FlxG;

#if !debug @:noDebug #end
class StrumNote extends FlxSprite {
    var isPlayer:Bool = false;
    public var pressTime:Float = 0;
    public var curState:Int = 0;

    public function new(xb:Float, yb:Float, data:Int, player:Int){
        super(xb,yb);
        
        frames = Paths.lSparrow('gameplay/NOTE_assets');
        setGraphicSize(Math.round(width * 0.7));
        updateHitbox();

        antialiasing = Settings.antialiasing;
        animation.addByPrefix('static', 'arrow' + PlayState.sDir[data]);
        animation.addByPrefix('pressed', Note.colArr[data] + ' press'  , 24, false);
        animation.addByPrefix('confirm', Note.colArr[data] + ' confirm', 24, false);

        // hopefully caches the animation.
        playAnim(2);
        playAnim(1);
        playAnim(0);

        // 98 so it is screen centered.
        x += Note.swagWidth * data;
        x += 98;
        x += (FlxG.width / 2) * player;

        isPlayer = PlayState.SONG.activePlayer == player;
    }

    override function update(elapsed:Float){
        super.update(elapsed);

        if(pressTime < 0) 
            return;

        pressTime -= elapsed;
        if(pressTime <= 0 && (!isPlayer || Settings.botplay))
            playAnim();
    }

    // This 'state' variable is used simply cause string checks are more expensive than integer checks.
    public function playAnim(state:Int = 0){
        var str = ['static', 'pressed', 'confirm'][state];

        animation.play(str, true);
		centerOffsets();
		centerOrigin ();
        
        curState = state;
    }  
}