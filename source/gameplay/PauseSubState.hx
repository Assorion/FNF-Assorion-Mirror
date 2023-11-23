package gameplay;

import flixel.FlxG;
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
import flixel.text.FlxText;
import ui.MenuTemplate.MenuObject;

#if !debug @:noDebug #end
class PauseSubState extends MusicBeatSubstate
{
	public static var bdat:BitmapData;
	public static var optionList:Array<String> = ['Resume Game', 'Restart Song', 'Toggle Botplay', 'Exit To Menu'];
	
	public var curSelected:Int = 0;
	public var pauseText:FlxText;
	var colour:Float = 255;
	var gameSpr:StaticSprite;
	var pauseMusic:FlxSound;
	var ps:PlayState;

	var alphaTexts:FlxTypedGroup<Alphabet>;
	var trackThings:Array<MenuObject> = [];

	// quick helper function.
	public static function exitToProperMenu(){
		PlayState.seenCutscene = false;
		if(PlayState.storyWeek >= 0){
			MusicBeatState.changeState(new ui.StoryMenuState());
		} else
			MusicBeatState.changeState(new ui.FreeplayState());
	}
	
	// # create new empty background sprite
	public static function newCanvas(f:Bool = false){
		if(bdat == null || !Settings.pr.default_persist || f)
			bdat = new BitmapData(1280, 720, true, 0);
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

		gameSpr = new StaticSprite(0,0).loadGraphic(bdat);
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
		var bottomBlack:StaticSprite = new StaticSprite(0, camera.height - 30).makeGraphic(1280, 30, FlxColor.BLACK);
		bottomBlack.alpha = 0.6;
		pauseText = new FlxText(5, camera.height - 25, 0, '', 20);
		pauseText.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, LEFT);
		pauseText.alpha = 0;
		add(bottomBlack);
		add(pauseText);

		changeSelection(0);
		cameras = [camera];
		updatePauseText();
	}
	private inline function updatePauseText(){
		var coolString:String = 
		'SONG: ${PlayState.curSong.toUpperCase()}' +
		' | WEEK: ${PlayState.storyWeek >= 0 ? Std.string(PlayState.storyWeek + 1) : "FREEPLAY"}' +
		' | BOTPLAY: ${Settings.pr.botplay ? "YES" : "NO"}' +
		' | DIFFICULTY: ${CoolUtil.diffString(PlayState.curDifficulty, 1).toUpperCase()}' +
		' | ';
		pauseText.text = '$coolString$coolString$coolString';
	}

	override public function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		// ui movements.
		var t:Int = key.deepCheck([Binds.UI_U, Binds.UI_D]);
		if (t != -1){
			changeSelection((t * 2) - 1);
			return;
		}

		if(!key.hardCheck(Binds.UI_ACCEPT)) return;

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
				pauseText.alpha = 0;
				updatePauseText();
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

		pauseText.x += elapsed * 70;
		if(pauseText.x >= 5) 
			pauseText.x = pauseText.x - (pauseText.width / 3);

		/* shouldn't be needed but if you leave the pause menu
		   while the music is fading in (using the fadeIn function) -
		   then the game will crash */

		if(pauseText.alpha < 1)
			pauseText.alpha += elapsed * 2;
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
