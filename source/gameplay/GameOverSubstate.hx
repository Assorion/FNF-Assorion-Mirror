package gameplay;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;

#if !debug @:noDebug #end
class GameOverSubstate extends MusicBeatSubstate
{
	var camFollow:FlxObject;
	var charRef:Character;
	var blackFadeIn:StaticSprite;
	var fadeCam:FlxCamera;
	var playstateRef:PlayState;

	public function new(deadChar:Character, fadeOutCam:FlxCamera, pState:PlayState)
	{
		super();

		playstateRef = pState;

		var z:Float = 1 / FlxG.camera.zoom;
		blackFadeIn = new StaticSprite(0,0).makeGraphic(Math.round(FlxG.width * z), Math.round(FlxG.height * z), FlxColor.BLACK);
		blackFadeIn.scrollFactor.set();
		blackFadeIn.screenCenter();
		blackFadeIn.alpha = 0;
		add(blackFadeIn);

		/*
			The game over state doesn't create a new character, instead it pulls the
			current playing character out of PlayState and tells it to play the death animation.

			If instead your character uses a different sprite for it's death animations, you'll
			need to write some extra logic here to accommodate for that.
		*/
		deadChar.playAnim('firstDeath');
		charRef = deadChar;
		camFollow = new FlxObject(deadChar.getGraphicMidpoint().x, deadChar.getGraphicMidpoint().y, 1, 1);
		fadeCam = fadeOutCam;
		add(deadChar);

		FlxG.sound.music.time = 0;
		FlxG.sound.play(Paths.lSound('gameplay/fnf_loss_sfx'));
		FlxG.camera.follow(camFollow, LOCKON, 0.023);

		Song.musicSet(100);

		FlxTween.tween(fadeCam,     {alpha: 0}, 3);
		FlxTween.tween(blackFadeIn, {alpha: 1}, 3, {onComplete: function(t:FlxTween){
			playstateRef.persistentDraw = false;

			remove(blackFadeIn);
			blackFadeIn.destroy();
			blackFadeIn = null;
		}});

		postEvent(2.5, function() {
			if(!leaving)
				FlxG.sound.playMusic(Paths.lMusic('gameOver'));
		});
	}

	private var notLoop:Bool = true;
	override function update(elapsed:Float)
	{
		// in case you're using a character which doesn't have the animation set.
		if(notLoop && charRef.animation.curAnim.finished){
			charRef.animation.play('deathLoop');
			notLoop = false;
		}

		#if (flixel < "5.4.0")
		FlxG.camera.followLerp = (1 - Math.pow(0.5, FlxG.elapsed * 2)) * (60 / Settings.framerate);
		#end

		super.update(elapsed);
	}

	private var leaving:Bool = false;
	override function keyHit(ev:KeyboardEvent){
		if(leaving) {
			for(i in 0...events.length)
				events[i].exeFunc();
			
			return;
		}

		if(ev.keyCode.hardCheck(Binds.UI_BACK)){
			leaving = true;
			FlxG.sound.music.stop();
			CoolUtil.exitPlaystate();
			return;
		}

		if(!ev.keyCode.hardCheck(Binds.UI_ACCEPT)) return;

		leaving = true;
		charRef.playAnim('deathConfirm');
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.lSound('gameplay/gameOverEnd'));
		
		postEvent(0.7, function(){ FlxG.camera.fade(FlxColor.BLACK, 2, false); });
		postEvent(2.7, function(){
			FlxG.resetState();
		});
	}
}
