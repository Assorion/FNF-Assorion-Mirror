package ui;

import flixel.FlxG;
import flixel.FlxSprite;
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
		var lines:Array<String> = CoolUtil.textFileLines('freeplaySonglist');

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.lImage('ui/menuDesat'));
		bg.color = FlxColor.fromRGB(145, 113, 255);
		bg.antialiasing = Settings.pr.antialiasing;
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(bg);
		add(grpSongs);

		for(i in 0...lines.length)
			songs.push(lines[i].split(':')[0]);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (60 * i) + 30, songs[i], true);
			songText.alpMult = 1;
			songText.alpha = 0;
			songText.lerpPos = true;
			grpSongs.add(songText);

			if(i != curSelected)
				songText.alpMult = 0.4;

			var ican = new gameplay.HealthIcon(lines[i].split(':')[1], false, songText);
			ican.scale.set(0.85,0.85);
			add(ican);
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

		var bottomBlack:FlxSprite = new FlxSprite(0, FlxG.height - 30).makeGraphic(1280, 30, FlxColor.BLACK);
		var descText = new FlxText(5, FlxG.height - 25, 0, "Press Space to preview song / stop song. Left or Right to change the difficulty.", 20);
		bottomBlack.alpha = 0.6;
		descText.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, LEFT);
		add(bottomBlack);
		add(descText);

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

		intendedScore = Highscore.getScore(songs[curSelected], curDifficulty);
		scoreText.text = 'PERSONAL BEST:$intendedScore';
		diffText .text = '< ' + CoolUtil.diffString(curDifficulty, 1).toUpperCase() + ' >';

	}
	
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.lSound('menu/scrollMenu'), 0.4);

		curSelected += change;
		curSelected %= songs.length;
		if(curSelected < 0) curSelected = songs.length - 1;

		intendedScore = Highscore.getScore(songs[curSelected], curDifficulty);
		scoreText.text = 'PERSONAL BEST:$intendedScore';

		for(i in 0...grpSongs.members.length){
			var item = grpSongs.members[i];

			item.alpMult = 1;
			if(i != curSelected) item.alpMult = 0.4;

			item.targetY = (i - curSelected) * 100;
			item.targetY += 50;
			item.targetX = (i - curSelected) * 15;
			item.targetX += 30;
		}
	}
	
	private var prevTime:Float = 0;
	private var playing:Bool = true;

	// # input code.

	private var leaving:Bool = false;
	override public function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		var k = key.deepCheck([NewControls.UI_U, NewControls.UI_D, NewControls.UI_L, NewControls.UI_R, 
			NewControls.UI_ACCEPT, [FlxKey.SPACE], NewControls.UI_BACK]);
		switch(k){
			case 0, 1:
				changeSelection((k * 2) - 1);
				return;
			case 2, 3:
				changeDiff(((k - 2) * 2) - 1);
				return;
			case 4: // Enter
				PlayState.SONG = Song.loadFromJson(songs[curSelected], curDifficulty);
				PlayState.isStoryMode     = false;
				PlayState.storyDifficulty = curDifficulty;

				FlxG.switchState(new PlayState());
				if( FlxG.sound.music.playing)
					FlxG.sound.music.stop();
				return;
			case 5: // SpaceUK
				playing = !playing;

				if(playing){
					FlxG.sound.playMusic(Paths.lMusic('freakyMenu'));
					FlxG.sound.music.time = prevTime;

					if(vocals == null) return;
					
					vocals.stop();
					vocals.destroy();
					vocals = new FlxSound();

					return;
				}

				prevTime = FlxG.sound.music.time;
				vocals.loadEmbedded (Paths.playableSong(songs[curSelected], true));
				FlxG.sound.playMusic(Paths.playableSong(songs[curSelected]));
				vocals.play();
				FlxG.sound.list.add(vocals);
				return;
			case 6: // Escape
				if(leaving){
					skipTrans();
					return;
				}
				FlxG.sound.play(Paths.lSound('menu/cancelMenu'));
				FlxG.switchState(new MainMenuState());
				leaving = true;

				return;
		}
	}
}
