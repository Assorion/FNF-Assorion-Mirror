package gameplay;

import flixel.FlxSprite;
import flixel.FlxG;

class StrumNote extends FlxSprite {
    var isPlayer:Bool = false;
    public var pressTime:Float = 0;

    public function new(xb:Float, yb:Float, data:Int, player:Int){
        super(xb,yb);
        
        frames = Paths.lSparrow('gameplay/NOTE_assets');
        setGraphicSize(Math.round(width * 0.7));
        updateHitbox();

        antialiasing = Settings.pr.antialiasing;
        animation.addByPrefix('static', 'arrow' + PlayState.sDir[data]);
        animation.addByPrefix('pressed', Note.colArr[data] + ' press'  , 24, false);
        animation.addByPrefix('confirm', Note.colArr[data] + ' confirm', 24, false);

        // hopefully caches the animation.
        animation.play('confirm');
        animation.play('pressed');
        playAnim('static');

        // 98 so it is screen centered.
        x += Note.swagWidth * data;
        x += 98;
        x += (FlxG.width / 2) * player;

        isPlayer = PlayState.SONG.activePlayer == player;
    }

    override function update(elapsed:Float){
        super.update(elapsed);

        if(pressTime > 0){
            pressTime -= elapsed;
            return;
        }
        if(pressTime == 0) return;

        pressTime = 0;
        if(!isPlayer || Settings.pr.botplay)
            playAnim();
    }

    public function playAnim(animName:String = 'static'){
        animation.play(animName, true);
		centerOffsets();
		centerOrigin ();
    }  
}