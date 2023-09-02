package gameplay;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import misc.Alphabet;

#if !debug @:noDebug #end
class PauseSubState extends MusicBeatSubstate
{
	public static var curSelected:Int = 0;
	var optionList:Array<String> = ['Resume Game', 'Restart Song', 'Toggle Botplay', 'Exit To Menu'];
	var alphaTexts:FlxTypedGroup<Alphabet>;
	var pauseMusic:FlxSound;
	var bg:FlxSprite;

	// quick helper function.
	public static function exitToProperMenu(){
		PlayState.seenCutscene = false;
		FlxG.sound.playMusic(Paths.lMusic('freakyMenu'));
		if(PlayState.isStoryMode){
			FlxG.switchState(new ui.StoryMenuState());
		} else
			FlxG.switchState(new ui.FreeplayState());
	}

	public function new(camera:FlxCamera)
	{
		super();

		// music
		pauseMusic = new FlxSound().loadEmbedded(Paths.lMusic('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play();
		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		// text stuff
		alphaTexts = new FlxTypedGroup<Alphabet>();
		add(alphaTexts);

		for (i in 0...optionList.length)
		{
			var option:Alphabet = new Alphabet(0, (60 * i) + 30, optionList[i], true);
			option.alpMult = 1;
			option.alpha = 0;
			option.lerpPos = true;
			alphaTexts.add(option);

			if(i != curSelected)
				option.alpMult = 0.4;
		}

		var o:Int = curSelected;
		curSelected = 0;
		changeSelection(o);

		cameras = [camera];
	}

	override public function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		// ui movements.
		var t:Int = key.deepCheck([NewControls.UI_U, NewControls.UI_D]);
		if (t != -1){
			changeSelection((t * 2) - 1);
			return;
		}

		if(!key.hardCheck(NewControls.UI_ACCEPT)) return;

		switch(curSelected){
			case 0:
				pauseMusic.stop();
				pauseMusic.destroy();
				close();
			case 1:
				FlxG.resetState();
			case 2:
				Settings.pr.botplay = !Settings.pr.botplay;
				alphaTexts.members[curSelected].alpha = 0;
			case 3:
				exitToProperMenu();
		}
	}

	// shouldn't be needed but if you leave the pause menu
	// while the music is fading in (using the fadeIn function) -
	//  then the game will crash
	override function update(elapsed:Float){
		super.update(elapsed);
		if(pauseMusic.volume < 0.5) 
			pauseMusic.volume += elapsed * 0.01;
		if(bg.alpha < 0.6)
			bg.alpha += elapsed * 2;
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.lSound('menu/scrollMenu'), 0.4);

		curSelected = (curSelected + change + optionList.length) % optionList.length;

		for(i in 0...alphaTexts.length){
			var item = alphaTexts.members[i];
			item.alpMult = 1;

			if(i != curSelected) item.alpMult = 0.4;
			item.targetY = (i - curSelected) * 90;
			item.targetX = (i - curSelected) * 15;
			item.targetY += 80;
			item.targetX += 40;
		}
	}
}
