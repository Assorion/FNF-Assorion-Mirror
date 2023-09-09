package gameplay;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxCamera;
import openfl.display.BitmapData;

#if !debug @:noDebug #end
class GameOverSubstate extends MusicBeatSubstate
{
	var camFollow:FlxObject;
	var charRef:Character;
	var blackFadeIn:FlxSprite;
	var fadeCam:FlxCamera;

	public function new(deadChar:Character, fadeOutCam:FlxCamera, pState:PlayState)
	{
		super();

		var z:Float = 1 / FlxG.camera.zoom;
		blackFadeIn = new FlxSprite(0,0).makeGraphic(Math.round(FlxG.width * z), Math.round(FlxG.height * z), FlxColor.BLACK);
		blackFadeIn.scrollFactor.set();
		blackFadeIn.screenCenter();
		blackFadeIn.alpha = 0;
		add(blackFadeIn);

		Conductor.songPosition = 0;
		Conductor.changeBPM(100);

		deadChar.playAnim('firstDeath');
		charRef = deadChar;
		camFollow = new FlxObject(deadChar.getGraphicMidpoint().x, deadChar.getGraphicMidpoint().y, 1, 1);
		fadeCam = fadeOutCam;
		add(deadChar);

		FlxG.sound.music.time = 0;
		FlxG.sound.play(Paths.lSound('gameplay/fnf_loss_sfx'));
		FlxG.camera.follow(camFollow, LOCKON, 0.04);

		postEvent(2.5, () -> {
			if(!leaving)
				FlxG.sound.playMusic(Paths.lMusic('gameOver'));
		});
		postEvent(0, ()->{
			pState.persistentDraw = true;
		});
	}

	// in case you're using a character which doesn't have the animation set.
	private var notLoop:Bool = true;
	override function update(elapsed:Float)
	{
		FlxG.camera.followLerp = (1 - Math.pow(0.5, elapsed * 2)) * (60 / Settings.pr.framerate);

		if(notLoop && charRef.animation.curAnim.finished){
			charRef.animation.play('deathLoop');
			notLoop = false;
		}
		if(blackFadeIn.alpha < 1){
			blackFadeIn.alpha += elapsed * 0.5;
			fadeCam.alpha     -= elapsed * 0.5;
		}

		super.update(elapsed);
	}

	private var leaving:Bool = false;
	override function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		if(leaving) return;

		if(key.hardCheck(NewControls.UI_BACK)){
			leaving = true;
			FlxG.sound.music.stop();
			PauseSubState.exitToProperMenu();
			return;
		}

		if(!key.hardCheck(NewControls.UI_ACCEPT)) return;

		leaving = true;
		charRef.playAnim('deathConfirm');
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.lSound('gameplay/gameOverEnd'));
		
		postEvent(0.7, ()->{ FlxG.camera.fade(FlxColor.BLACK, 2, false); });
		postEvent(2.7, ()->{
			FlxG.resetState();
		});
	}
}
