package ui;

import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.system.FlxSound;
import misc.Alphabet;
import misc.Highscore;
import misc.Song;
import gameplay.PlayState;

using StringTools;

#if !debug @:noDebug #end
class FreeplayState extends MenuTemplate
{
	public static var curDifficulty:Int = 1;
	public var songs:Array<String> = [];

	var scoreText:FlxText;
	var diffText:FlxText;
	var intendedScore:Int = 0;

	private var vocals:FlxSound;

	private inline function readAndParseTextFile(){
		var lines:Array<String> = Paths.lLines('freeplaySonglist');

		for(i in 0...lines.length){
			var strArr = lines[i].split(':');
			songs.push(strArr[0]);

			pushObject(new Alphabet(0, (60 * i) + 30, strArr[0], true));
			pushIcon(new gameplay.HealthIcon(strArr[1], false));
		}
	}

	override function create()
	{
		addBG(FlxColor.fromRGB(145, 113, 255));
		correctMusic();
		super.create();

		readAndParseTextFile();

		var scoreBG:StaticSprite = new StaticSprite((FlxG.width * 0.7) - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;

		scoreText = new FlxText(scoreBG.x + 6, 5, 0, "", 32);
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "< NORMAL >", 24);
		diffText.font = scoreText.font;

		var bottomBlack:StaticSprite = new StaticSprite(0, FlxG.height - 30).makeGraphic(1280, 30, FlxColor.BLACK);
		var descText = new FlxText(5, FlxG.height - 25, 0, "Press Space to preview song / stop song. Left or Right to change the difficulty.", 20);
		descText.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, LEFT);
		bottomBlack.alpha = 0.6;

		sAdd(scoreBG);
		sAdd(diffText);
		sAdd(scoreText);
		sAdd(bottomBlack);
		sAdd(descText);

		changeSelection();
		altChange();

		vocals = new FlxSound();
	}

	// cause menutemplate has this functions originally, we can override and make them do different things.
	override function altChange(change:Int = 0){
		curDifficulty += change + CoolUtil.diffNumb;
		curDifficulty %= CoolUtil.diffNumb;

		diffText.text = '< ${CoolUtil.diffString(curDifficulty, 1).toUpperCase()} >';
		scoreText.text = 'PERSONAL BEST: ${Highscore.getScore(songs[curSel], curDifficulty)}';
	}
	override function changeSelection(chng:Int = 0){
		super.changeSelection(chng);
		scoreText.text = 'PERSONAL BEST: ${Highscore.getScore(songs[curSel], curDifficulty)}';
	}

	// # input code.

	private var prevTime:Float = 0;
	private var playing:Bool = true;
	override public function keyHit(ev:KeyboardEvent){
		var k = ev.keyCode.deepCheck([Binds.UI_ACCEPT, [FlxKey.SPACE]]);
		switch(k){
			case 0: // Enter
				if(NewTransition.skip()) 
					return;

				MusicBeatState.changeState(new PlayState([ songs[curSel] ], curDifficulty, -1));
				FlxG.sound.music.stop();

				if (vocals.playing)
					vocals.stop();
				
			case 1: // SpaceUK
				playing = !playing;

				if(playing){
					FlxG.sound.playMusic(Paths.lMusic('freakyMenu'));
					FlxG.sound.music.time = prevTime;

					if(vocals == null) 
						return;
					
					vocals.stop();
					vocals.destroy();
					vocals = new FlxSound();

					return;
				}

				prevTime = FlxG.sound.music.time;
				
				vocals.loadEmbedded (Paths.playableSong(songs[curSel], true));
				FlxG.sound.playMusic(Paths.playableSong(songs[curSel]));
				vocals.play();
				FlxG.sound.list.add(vocals);
		}
	}
}
