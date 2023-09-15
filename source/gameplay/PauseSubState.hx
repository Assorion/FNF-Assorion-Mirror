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
import misc.CoolUtil;
import openfl.display.BitmapData;
import flixel.math.FlxMath;

#if !debug @:noDebug #end
class PauseSubState extends MusicBeatSubstate
{
	public static var bdat:BitmapData;
	public static var optionList:Array<String> = ['Resume Game', 'Restart Song', 'Toggle Botplay', 'Exit To Menu'];
	
	var curSelected:Int = 0;
	var colour:Float = 255;
	var gameSpr:FlxSprite;
	var pauseMusic:FlxSound;
	var ps:PlayState;

	var alphaTexts:FlxTypedGroup<Alphabet>;
	var trackThings:Array<MenuObject> = [];

	// quick helper function.
	public static function exitToProperMenu(){
		PlayState.seenCutscene = false;
		if(PlayState.isStoryMode){
			FlxG.switchState(new ui.StoryMenuState());
		} else
			FlxG.switchState(new ui.FreeplayState());
	}

	public function new(camera:FlxCamera, ps:PlayState)
	{
		super(false);

		// music
		pauseMusic = new FlxSound().loadEmbedded(Paths.lMusic('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play();
		FlxG.sound.list.add(pauseMusic);

		/*  instead of rendering the playstate every frame.
			we create a fake sprite, effectively a screenshot of playstate.
			and we work with that instead.
		*/

		newCanvas();
		for(gcam in FlxG.cameras.list)
			CoolUtil.copyCameraToData(bdat, gcam);

		gameSpr = new FlxSprite(0,0).loadGraphic(bdat);
		gameSpr.scrollFactor.set();
		gameSpr.antialiasing = Settings.pr.antialiasing;

		this.ps = ps;
		ps.persistentDraw = false;

		// text stuff
		alphaTexts = new FlxTypedGroup<Alphabet>();
		add(gameSpr);
		add(alphaTexts);

		for (i in 0...optionList.length)
		{
			var option:Alphabet = new Alphabet(0, (60 * i) + 30, optionList[i], true);
			option.alpha = 0;
			alphaTexts.add(option);

			trackThings.push({
				obj: null,
				targetX: 0,
				targetY: 0,
				targetA: 1
			});
		}

		changeSelection(0);
		cameras = [camera];
	}

	// # create new empty background sprite
	public static function newCanvas(f:Bool = false){
		if(bdat == null || !Settings.pr.default_persist || f)
			bdat = new BitmapData(1280, 720, true, 0);
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

		ps.persistentDraw = true;
		switch(curSelected){
			case 0:
				pauseMusic.stop();
				pauseMusic.destroy();
				close();
			case 1:
				FlxG.resetState();
			case 2:
				ps.persistentDraw = false;
				Settings.pr.botplay = !Settings.pr.botplay;
				alphaTexts.members[curSelected].alpha = 0;
			case 3:
				exitToProperMenu();
		}
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		// yeah sorry

		var lerpVal = 1 - Math.pow(0.5, elapsed * 15);
        for(i in 0...alphaTexts.length){
			var alT = alphaTexts.members[i];
			var pos = trackThings[i];
			alT.alpha = FlxMath.lerp(alT.alpha, pos.targetA, lerpVal);
			alT.y     = FlxMath.lerp(alT.y    , pos.targetY, lerpVal);
			alT.x     = FlxMath.lerp(alT.x    , pos.targetX, lerpVal);
        }

		/* shouldn't be needed but if you leave the pause menu
		   while the music is fading in (using the fadeIn function) -
		   then the game will crash */

		if(pauseMusic.volume < 0.5) 
			pauseMusic.volume += elapsed * 0.01;
		if(colour > 120){
			colour -= elapsed * 250;

			var tCol:Int = Math.floor(colour);
			gameSpr.color = FlxColor.fromRGB(tCol, tCol, tCol);
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.lSound('menu/scrollMenu'), 0.4);

		curSelected = (curSelected + change + optionList.length) % optionList.length;

		for(i in 0...trackThings.length){
			var item = trackThings[i];
			item.targetA = i != curSelected ? 0.4 : 1;

			item.targetY = (i - curSelected) * 110;
			item.targetX = (i - curSelected) * 20;
			item.targetY += 110;
			item.targetX += 60;
		}
	}
}
