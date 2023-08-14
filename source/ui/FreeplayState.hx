package ui;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.system.FlxSound;
import misc.Alphabet;
import misc.Highscore;
import gameplay.PlayState;
import gameplay.Song;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<String> = [];

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var vocals  :FlxSound;

	override function create()
	{
		songs = CoolUtil.textFileLines('freeplaySonglist');

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.lImage('ui/menuDesat'));
		bg.color = FlxColor.fromRGB(145, 113, 255);
		bg.antialiasing = Settings.pr.antialiasing;
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(bg);
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (60 * i) + 30, songs[i], true);
			songText.alpMult = 1;
			songText.alpha = 0;
			songText.lerpPos = true;
			grpSongs.add(songText);

			if(i != curSelected)
				songText.alpMult = 0.4;
		}

		var scoreBG:FlxSprite = new FlxSprite((FlxG.width * 0.7) - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;

		scoreText = new FlxText(scoreBG.x + 6, 5, 0, "", 32);
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "< NORMAL >", 24);
		diffText.font = scoreText.font;

		add(scoreBG);
		add(diffText);
		add(scoreText);

		changeSelection();
		changeDiff();

		vocals = new FlxSound();

		super.create();
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;
		curDifficulty %= CoolUtil.diffNumb;
		if(curDifficulty < 0) curDifficulty = CoolUtil.diffNumb - 1;

		trace(curDifficulty);

		intendedScore = Highscore.getScore(songs[curSelected], curDifficulty);
		scoreText.text = "PERSONAL BEST:" + intendedScore;
		diffText .text = '< ' + CoolUtil.diffString(curDifficulty, 1).toUpperCase() + ' >';

	}
	
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.lSound('menu/scrollMenu'), 0.4);

		curSelected += change;
		curSelected %= songs.length;
		if(curSelected < 0) curSelected = songs.length - 1;

		intendedScore = Highscore.getScore(songs[curSelected], curDifficulty);
		scoreText.text = "PERSONAL BEST:" + intendedScore;

		for(i in 0...grpSongs.members.length){
			var item = grpSongs.members[i];

			item.alpMult = 1;
			if(i != curSelected) item.alpMult = 0.4;

			item.targetY = (i - curSelected) * 90;
			item.targetY += 50;
			item.targetX = (i - curSelected) * 15;
			item.targetX += 30;
		}
	}
	
	private var prevTime:Float = 0;

	// # input code.

	override public function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		// ui movements.
		var t:Int = key.deepCheck([NewControls.UI_U, NewControls.UI_D]);
		if (t != -1){
			changeSelection((t * 2) - 1);
			return;
		}

		t = key.deepCheck([NewControls.UI_L, NewControls.UI_R]);
		if(t != -1){
			changeDiff((t * 2) - 1);
			return;
		}

		// space code.
		if(key == FlxKey.SPACE){
			if(vocals != null && vocals.playing){
				vocals.stop();
				vocals.destroy();
				vocals = new FlxSound();
				
				FlxG.sound.playMusic(Paths.lMusic('freakyMenu'));
				FlxG.sound.music.time = prevTime;

				return;
			}

			prevTime = FlxG.sound.music.time;
			vocals.loadEmbedded (Paths.playableSong(songs[curSelected], true));
			FlxG.sound.playMusic(Paths.playableSong(songs[curSelected]));
			vocals.play();
			FlxG.sound.list.add(vocals);

			return;
		}

		// escape code.
		if(key.hardCheck(NewControls.UI_BACK)){
			FlxG.sound.play(Paths.lSound('menu/cancelMenu'));
			FlxG.switchState(new MainMenuState());
			return;
		}

		// enter
		if(key.hardCheck(NewControls.UI_ACCEPT)){
			PlayState.SONG = Song.loadFromJson(songs[curSelected], curDifficulty);
			PlayState.isStoryMode     = false;
			PlayState.storyDifficulty = curDifficulty;

			FlxG.switchState(new PlayState());
			if( FlxG.sound.music.playing)
				FlxG.sound.music.stop();
		}
	}
}
