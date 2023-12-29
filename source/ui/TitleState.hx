package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
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

#if !debug @:noDebug #end
class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	// The game engine will handle this for you.
	public static var textSequence:Array<Array<String>> = [
		['hi'],
		['Original game by','ninjamuffin'],
		['assorion engine by', 'candice joe'],
		['This took ages', 'but it payed off', 'probably'],
		['%'],
		['Well any way', 'have fun']
	];

	override public function create():Void
	{
		// # Set the random text

		for(i in 0...textSequence.length) 
			if(textSequence[i][0] == '%') 
				textSequence[i] = getIntroText();

		super.create();
		MusicBeatState.correctMusic();

		startIntro();
	}

	// # Pick random intro text

	public inline function getIntroText():Array<String>
	{
		var textLines:Array<String> = CoolUtil.textFileLines('introText');
		var bruh:Int = Math.round(Math.random() * (textLines.length - 1));

		return textLines[bruh].trim().split('--');
	}

	public var logoBl:FlxSprite;
	public var gfDance:FlxSprite;
	public var danceLeft:Bool = false;
	public var titleText:FlxSprite;

	var textGroup:FlxGroup;
	var afterFlash:FlxTypedGroup<FlxSprite>;

	var sndTween:FlxTween;

	inline function startIntro()
	{
		if (!initialized)
		{
			FlxG.sound.volume = Settings.pr.start_volume / 100;
			FlxG.sound.music.volume = 0;
			sndTween = FlxTween.tween(FlxG.sound.music, {volume: 1}, 3);
		}

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

		// # for the ending card

		afterFlash = new FlxTypedGroup<FlxSprite>();
		afterFlash.add(logoBl);
		afterFlash.add(gfDance);
		afterFlash.add(titleText);

		// # alphabet text.

		textGroup = new FlxGroup();
		add(textGroup);

		if (initialized)
			skipIntro();

		initialized = true;
	}

	// # Input code

	private var leaving:Bool = false;
	override public function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		if(!key.hardCheck(Binds.UI_ACCEPT)) return;

		if(leaving) {
			skipTrans();
			if(sndTween == null) return;

			sndTween.cancel();
			FlxG.sound.music.volume = 1;

			return;
		}

		if(skippedIntro){
			titleText.animation.play('press');
			leaving = true;
			FlxG.sound.play(Paths.lSound('menu/confirmMenu'));
			postEvent(1, function() { 
				MusicBeatState.changeState(new MainMenuState()); 
			});
		}
		skipIntro();
	}

	override function update(elapsed:Float){
		FlxG.camera.zoom = CoolUtil.boundTo(FlxG.camera.zoom - elapsed, 1, 2);
		super.update(elapsed);
	}

	private var textStep:Int = 0;
	private var tsubStep:Int = 0;

	function createCoolText(pos:Int, amount:Int, text:String){
		var txt:Alphabet = new Alphabet(0,0, text, true);
		txt.screenCenter();
		txt.y += (pos - Math.floor(amount / 2) + (amount % 2 == 0 ? 0.5 : 0)) * 75;

		textGroup.add(txt);
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');

		danceLeft = !danceLeft;
		gfDance.animation.play('dance' + (danceLeft ? 'Left' : 'Right'));

		/////////////////////////////////////////

		if(curBeat <= 0 || skippedIntro) return;

		FlxG.camera.zoom = 1.1;
		
		if (tsubStep < 0){
			tsubStep = 0;

			if(++textStep == textSequence.length){
				skipIntro();
				return;
			}
		}

		if(tsubStep == textSequence[textStep].length){
			textGroup.clear();
			tsubStep = -1;
			
			return;
		}

		// Using fancy bit crap to figure out if the number is odd or not. Modulo exists but y'know, this is better.
		if(((curBeat & 0xFFFFFFFF) << 31) >>> 31 == 0)
			createCoolText(tsubStep, textSequence[textStep].length, textSequence[textStep][tsubStep++]);
	}

	// # show enter screen code.

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if(skippedIntro) return;

		FlxG.camera.flash(FlxColor.WHITE, 4);

		textGroup.clear();
		remove(textGroup);
		add(afterFlash);

		titleText.animation.play('idle');
		skippedIntro = true;
	}
}
