package gameplay;

import flixel.FlxG;
import ui.NewTransition;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import ui.Alphabet;
import misc.CoolUtil;
import openfl.display.BitmapData;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import misc.MenuTemplate;

#if !debug @:noDebug #end
class PauseSubState extends MusicBeatSubstate
{
	public static var optionList:Array<String> = ['Resume Game', 'Restart Song', 'Toggle Botplay', 'Exit To Menu'];
	
	public var curSelected:Int = 0;
	public var pauseText:FlxText;
	public var alphaTexts:Array<MenuObject> = [];
	public var bottomBlack:StaticSprite;

	var gameSpr:StaticSprite;
	var pauseMusic:FlxSound;
	var pState:PlayState;

	public var activeTweens:Array<FlxTween> = [];

	public function new(camera:FlxCamera, ps:PlayState)
	{
		super();

		pState = ps;
		pState.persistentDraw = false;

		pauseMusic = new FlxSound().loadEmbedded(Paths.lMusic('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play();
		FlxG.sound.list.add(pauseMusic);

		/*  instead of rendering the playstate every frame.
			we create a fake sprite, effectively a screenshot of playstate.
			and we work with that instead.
		*/

		CoolUtil.newCanvas();
		
		for(gcam in FlxG.cameras.list)
			CoolUtil.copyCameraToData(CoolUtil.canvas, gcam);

		gameSpr = new StaticSprite(0,0).loadGraphic(CoolUtil.canvas);
		gameSpr.scrollFactor.set();
		add(gameSpr);

		for (i in 0...optionList.length)
		{
			var option:Alphabet = new Alphabet(0, MenuTemplate.yDiffer * i, optionList[i], true);
			option.alpha = 0;
			add(option);

			alphaTexts.push({
				obj: cast option,
				targetX: 0,
				targetY: 0,
				targetA: 1
			});
		}

		bottomBlack = new StaticSprite(0, camera.height - 30).makeGraphic(1280, 30, FlxColor.BLACK);
		bottomBlack.alpha = 0;

		pauseText = new FlxText(5, camera.height - 25, 0, '', 20);
		pauseText.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, LEFT);
		pauseText.alpha = 0;

		add(bottomBlack);
		add(pauseText);

		changeSelection(0);
		cameras = [camera];
		updatePauseText();

		/////////////////////

		activeTweens.push(FlxTween.tween( bottomBlack, {alpha: 0.6  }, 0.2 ));
		activeTweens.push(FlxTween.tween( pauseText  , {alpha: 1    }, 0.2 ));
		activeTweens.push(FlxTween.tween( pauseMusic , {volume: 0.5 },  4  ));
		activeTweens.push(FlxTween.tween( this       , {colour: 120 }, 0.45));
	}
	private inline function updatePauseText(){
		var coolString:String = 
		'SONG: ${PlayState.songName.toUpperCase()}' +
		' | WEEK: ${PlayState.storyWeek >= 0 ? Std.string(PlayState.storyWeek + 1) : "FREEPLAY"}' +
		' | BOTPLAY: ${Settings.pr.botplay ? "YES" : "NO"}' +
		' | DIFFICULTY: ${CoolUtil.diffString(PlayState.curDifficulty, 1).toUpperCase()}' +
		' | ';
		pauseText.text = '$coolString$coolString$coolString';
	}

	public inline function leave(){
		for(i in 0...activeTweens.length)
			if (activeTweens[i] != null)
				activeTweens[i].cancel();

		for(i in 0...alphaTexts.length)
			alphaTexts[i].targetA = 0;

		pState.persistentDraw = true;

		FlxTween.tween(pauseText,  { alpha:  0 }, 0.3);
		FlxTween.tween(bottomBlack,{ alpha:  0 }, 0.3);
		FlxTween.tween(pauseMusic, { volume: 0 }, 0.3);
		FlxTween.tween(gameSpr,    { alpha:  0 }, 0.3, {onComplete: 

		// Closing
		function(t:FlxTween){
			pauseMusic.stop();
			pauseMusic.destroy();
			pState.paused = false;
			close();

			if(FlxG.sound.music.time > 0){
				pState.vocals.play();
				FlxG.sound.music.play();
				FlxG.sound.music.time = pState.vocals.time = Song.Position + Settings.pr.audio_offset;
			}
		}});
	}

	private var leaving:Bool = false;
	override public function keyHit(ev:KeyboardEvent){
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
				leave();
			case 1:
				NewTransition.skippedLast = true;
				FlxG.resetState();
			case 2:
				Settings.pr.botplay = !Settings.pr.botplay;
				alphaTexts[curSelected].obj.alpha = 0;
				updatePauseText();

				pauseText.alpha = 0;
				activeTweens.push(FlxTween.tween(pauseText, {alpha: 1}, 0.3));

				pState.updateHealth(0);
			case 3:
				pState.persistentDraw = true;
				CoolUtil.exitPlaystate();
		}
	}

	var colour:Float = 255;
	override function update(elapsed:Float){
		super.update(elapsed);

		var lerpVal = Math.pow(0.5, elapsed * 15);
        for(i in 0...alphaTexts.length){
			var alT = alphaTexts[i];
			alT.obj.alpha = FlxMath.lerp(alT.targetA, alT.obj.alpha, lerpVal);
			alT.obj.y     = FlxMath.lerp(alT.targetY, alT.obj.y    , lerpVal);
			alT.obj.x     = FlxMath.lerp(alT.targetX, alT.obj.x    , lerpVal);
        }

		pauseText.x += elapsed * 70;
		if (pauseText.x >= 5) 
			pauseText.x = pauseText.x - (pauseText.width / 3);

		// Handle background dimming
		var tCol:Int = CoolUtil.intBoundTo(colour, 120, 255);
		gameSpr.color = FlxColor.fromRGB(tCol, tCol, tCol);
	}

	function changeSelection(change:Int = 0)
	{
		if(leaving)
			return;

		FlxG.sound.play(Paths.lSound('ui/scrollMenu'), 0.4);
		curSelected = (curSelected + change + optionList.length) % optionList.length;

		for(i in 0...alphaTexts.length){
			var item = alphaTexts[i];
			item.targetA = i != curSelected ? 0.4 : 1;

			item.targetY = (i - curSelected) * MenuTemplate.yDiffer;
			item.targetX = (i - curSelected) * MenuTemplate.xDiffer;
			item.targetY += MenuTemplate.yOffset;
			item.targetX += MenuTemplate.xOffset;
		}
	}
}
