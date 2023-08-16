package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.events.KeyboardEvent;
import lime.utils.Assets;
import misc.Alphabet;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	// the game engine will handle this for you.
	var textSequence:Array<Array<String>> = [
		['hi'],
		['Original game by','ninjamuffin'],
		['MKG engine by', 'me'],
		['This took ages', 'bruh', 'cmon'],
		['RANDOM'],
		['Well any way', 'have fun']
	];

	override public function create():Void
	{
		// # Set the random text
		// yes this means you can have multiple random text too.

		for(i in 0...textSequence.length) 
			if(textSequence[i][0] == 'RANDOM') 
				textSequence[i] = getIntroText();

		super.create();

		persistentUpdate = false;
		persistentDraw   = true;
		FlxG.mouse.visible = false;

		startIntro();
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var textGroup:FlxGroup;

	inline function startIntro()
	{
		// # create fade transition

		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.WHITE, 0.7, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.WHITE, 0.4, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			FlxG.sound.playMusic(Paths.lMusic('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);

			if(Settings.pr.start_fullscreen)
				FlxG.fullscreen = true;
			
			FlxG.sound.volume = Settings.pr.start_volume / 100;
		}

		//////////////////////////

		Conductor.changeBPM(102);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		// # create logo

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.lSparrow('ui/logoBumpin');
		logoBl.antialiasing = Settings.pr.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.lSparrow('ui/gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = Settings.pr.antialiasing;

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.lSparrow('ui/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = Settings.pr.antialiasing;
		titleText.updateHitbox();

		// # alphabet text.

		textGroup = new FlxGroup();
		add(textGroup);

		if (initialized)
			skipIntro();

		initialized = true;
	}

	// # get text
	// now supports multiple lines.

	public function getIntroText():Array<String>
	{
		var textLines:Array<String> = CoolUtil.textFileLines('introText');
		var bruh:Int = Math.round(Math.random() * (textLines.length - 1));

		return textLines[bruh].trim().split('--');
	}

	// # Input code

	private var leaving:Bool = false;
	override public function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		if(!key.hardCheck(NewControls.UI_ACCEPT) || leaving) return;

		if(skippedIntro){
			titleText.animation.play('press');
			leaving = true;
			FlxG.sound.play(Paths.lSound('menu/confirmMenu'));
			postEvent(
				(Conductor.crochet * 4) / 1000, 
				() -> { FlxG.switchState(new MainMenuState()); 
			});
		}
		skipIntro();
	}

	function createCoolText(pos:Int, amount:Int, text:String){
		var txt:Alphabet = new Alphabet(0,0, text, true);
		txt.screenCenter();
		txt.y += (pos - Math.floor(amount / 2) + (amount % 2 == 0 ? 0.5 : 0)) * 75;

		textGroup.add(txt);
	}

	var beatLeft:Int = 1;
	var textStep:Int = -1;
	var tsubStep:Int = 0;

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');

		danceLeft = !danceLeft;
		gfDance.animation.play('dance' + (danceLeft ? 'Left' : 'Right'));

		if(curBeat <= 0 || skippedIntro) return;

		beatLeft--;

		// reset crap
		if(beatLeft == 0) {
			textStep++;

			// would like to make this look better.
			if(textStep == textSequence.length){
				skipIntro();
				return;
			}

			tsubStep = 0;
			beatLeft = textSequence[textStep].length * 2;
		}

		// add more crap.
		if(beatLeft % 2 == 0){
			createCoolText(tsubStep, textSequence[textStep].length, textSequence[textStep][tsubStep]);
			tsubStep++;

			return;
		}

		if(beatLeft == 1) textGroup.clear();
	}

	// # show enter screen code.

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if(skippedIntro) return;

		FlxG.camera.flash(FlxColor.WHITE, 4);

		remove(textGroup);

		add(logoBl);
		add(gfDance);
		add(titleText);

		titleText.animation.play('idle');
		skippedIntro = true;
	}
}
