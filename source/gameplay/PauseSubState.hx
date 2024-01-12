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
	public static var canvas:BitmapData;
	public static var optionList:Array<String> = ['Resume Game', 'Restart Song', 'Toggle Botplay', 'Exit To Menu'];
	
	public var curSelected:Int = 0;
	public var pauseText:FlxText;
	public var alphaTexts:Array<MenuObject> = [];

	var gameSpr:StaticSprite;
	var pauseMusic:FlxSound;
	var pState:PlayState;

	public var activeTweens:Array<FlxTween> = [];

	// quick helper function.
	public static function exitToProperMenu(){
		PlayState.seenCutscene = false;
		MusicBeatState.changeState(PlayState.storyWeek >= 0 ? new ui.StoryMenuState() : new ui.FreeplayState());
	}
	
	// # create new empty background sprite
	public static function newCanvas(force:Bool = false){
		if (canvas == null || !Settings.pr.default_persist || force)
			canvas = new BitmapData(1280, 720, true, 0);
	}

	public function new(camera:FlxCamera, ps:PlayState)
	{
		super();

		pState = ps;
		pState.persistentDraw = false;

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
			CoolUtil.copyCameraToData(canvas, gcam);

		gameSpr = new StaticSprite(0,0).loadGraphic(canvas);
		gameSpr.scrollFactor.set();
		gameSpr.antialiasing = Settings.pr.antialiasing;
		add(gameSpr);

		// option stuff

		for (i in 0...optionList.length)
		{
			var option:Alphabet = new Alphabet(0, (60 * i) + 30, optionList[i], true);
			option.alpha = 0;

			alphaTexts.push({
				obj: null,
				targetX: 0,
				targetY: 0,
				targetA: 1
			});
		}

		////////////////////////////
	
		var bottomBlack:StaticSprite = new StaticSprite(0, camera.height - 30).makeGraphic(1280, 30, FlxColor.BLACK);
		bottomBlack.alpha = 0;

		pauseText = new FlxText(5, camera.height - 25, 0, '', 20);
		pauseText.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, LEFT);
		pauseText.alpha = 0;
		add(bottomBlack);
		add(pauseText);

		changeSelection(0);
		cameras = [camera];
		updatePauseText();

		// Tweens

		activeTweens.push(FlxTween.tween( bottomBlack, {alpha: 0.6  }, 0.3));
		activeTweens.push(FlxTween.tween( pauseText  , {alpha: 1    }, 0.3));
		activeTweens.push(FlxTween.tween( pauseMusic , {volume: 0.5 },  4 ));
		activeTweens.push(FlxTween.tween( this       , {colour: 120 }, 0.6));
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

	private var leaving:Bool = false;
	override public function keyHit(ev:KeyboardEvent){
		// ui movements.
		var t:Int = ev.keyCode.deepCheck([Binds.UI_U, Binds.UI_D]);
		if (t != -1){
			changeSelection((t * 2) - 1);
			return;
		}

		if(!ev.keyCode.hardCheck(Binds.UI_ACCEPT) || leaving) 
			return;

		switch(curSelected){
			case 0:
				leaving = true;

				// Cancel active tweens if there are any.
				for(i in 0...activeTweens.length)
					if (activeTweens[i] != null)
						activeTweens[i].cancel();
				
				// Animations.
				for(i in 0...alphaTexts.length)
					alphaTexts[i].targetA = 0;

				FlxTween.tween(pauseText,  { alpha:  0   }, 0.15);
				FlxTween.tween(pauseMusic, { volume: 0   }, 0.15);
				FlxTween.tween(this,       { colour: 255 }, 0.15, {onComplete: 
				// Closing
				function(t:FlxTween){
					pState.persistentDraw = true;
					pauseMusic.stop();
					pauseMusic.destroy();
					close();
				}});

			case 1:
				FlxG.resetState();
			case 2:
				Settings.pr.botplay = !Settings.pr.botplay;
				alphaTexts[curSelected].obj.alpha = 0;
				updatePauseText();

				pauseText.alpha = 0;
				activeTweens.push(FlxTween.tween(pauseText, {alpha: 1}, 0.3));
			case 3:
				exitToProperMenu();
		}
	}

	var colour:Float = 255;
	override function update(elapsed:Float){
		super.update(elapsed);

		// Move options.

		var lerpVal = 1 - Math.pow(0.5, elapsed * 15);
        for(i in 0...alphaTexts.length){
			var alT = alphaTexts[i];
			alT.obj.alpha = FlxMath.lerp(alT.obj.alpha, alT.targetA, lerpVal);
			alT.obj.y     = FlxMath.lerp(alT.obj.y    , alT.targetY, lerpVal);
			alT.obj.x     = FlxMath.lerp(alT.obj.x    , alT.targetX, lerpVal);
        }

		// Move text

		pauseText.x += elapsed * 70;
		if (pauseText.x >= 5) 
			pauseText.x = pauseText.x - (pauseText.width / 3);

		// Colour animation.

		var tCol:Int = CoolUtil.intBoundTo(colour, 120, 255);
		gameSpr.color = FlxColor.fromRGB(tCol, tCol, tCol);
	}

	function changeSelection(change:Int = 0)
	{
		if(leaving)
			return;

		FlxG.sound.play(Paths.lSound('menu/scrollMenu'), 0.4);
		curSelected = (curSelected + change + optionList.length) % optionList.length;

		for(i in 0...alphaTexts.length){
			var item = alphaTexts[i];
			item.targetA = i != curSelected ? 0.4 : 1;

			item.targetY = (i - curSelected) * 110;
			item.targetX = (i - curSelected) * 20;
			item.targetY += 110;
			item.targetX += 60;
		}
	}
}
