package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import misc.Alphabet;
import ui.ChartingState;
import misc.Highscore;
import gameplay.PlayState;
import gameplay.Song;

using StringTools;

typedef StoryData = {
	var graphic:String;
	var week:String;
	var songs:Array<String>;
	var topText:String;
}

class StoryMenuState extends MusicBeatState
{
	public static var curSel:Int = 0;
	public static var curDif:Int = 2;

	var weekData:Array<StoryData> = [
		{
			graphic: 'storymenu/storyportrait',
			week: '1',
			songs: ['tutorial', 'fresh'],
			topText: 'DADDY DEAREST'
		},
		{
			graphic: 'storymenu/test',
			week: '1',
			songs: ['dadbattle', 'tutorial', 'fresh'],
			topText: 'Massive Test Crash Gam'
		}
	];

	var scoreText:FlxText;
	var trackList:FlxText;
	public var wSprites:FlxTypedGroup<FlxSprite>;
	public var weekBG:FlxSprite;
	public var topText:FlxText;

	var arrSpr1:FlxSprite;
	var arrSpr2:FlxSprite;
	var diffSpr:FlxSprite;

	public static var selectColour:Int = 0;
	public static var whiteColour:Int = 0;

	override function create(){
		if(selectColour == 0){
			selectColour = ChartingState.colorFromRGBArray([0,255,255]);
			whiteColour  = ChartingState.colorFromRGBArray([255,255,255]);
		}

		var blackBG:FlxSprite = new FlxSprite(0,0).makeGraphic(1280, 720, FlxColor.BLACK);
		wSprites = new FlxTypedGroup<FlxSprite>();
		add(blackBG);
		add(wSprites);

		for(i in 0...weekData.length){
			var weekGraphic:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.lImage('storymenu/week-' + weekData[i].week));
			weekGraphic.updateHitbox();
			weekGraphic.centerOrigin();
			weekGraphic.alpha = 0.4;
			weekGraphic.scale.set(0.7, 0.7);
			weekGraphic.antialiasing = Settings.pr.antialiasing;
			wSprites.add(weekGraphic);

			if(i == curSel)
				weekGraphic.alpha = 1;
		}

		var topBlack:FlxSprite = new FlxSprite(0,0).makeGraphic(640, 20, ChartingState.colorFromRGBArray([25,25,25]));
		topText = new FlxText(0, 2, 0, "1234567890ABCDEFG", 18);
		topText.setFormat('assets/fonts/vcr.ttf', 18, FlxColor.GRAY, CENTER);
		topText.screenCenter(X);
		topText.x -= 320;
		add(topBlack);
		add(topText);

		// bruh
		arrSpr1 = new FlxSprite(640 - 50, 30).loadGraphic(Paths.lImage('storymenu/arrow'));
		arrSpr1.antialiasing = Settings.pr.antialiasing;
		arrSpr1.updateHitbox();
		arrSpr1.centerOrigin();
		arrSpr1.scale.set(0.7,0.7);
		arrSpr2 = new FlxSprite(640 - 330, 30).loadGraphic(Paths.lImage('storymenu/arrow'));
		arrSpr2.antialiasing = Settings.pr.antialiasing;
		arrSpr2.flipX = true;
		arrSpr2.updateHitbox();
		arrSpr2.centerOrigin();
		arrSpr2.scale.set(0.7, 0.7);
		diffSpr = new FlxSprite(640, 45).loadGraphic(Paths.lImage('storymenu/hard'));
		diffSpr.antialiasing = Settings.pr.antialiasing;
		diffSpr.scale.set(0.7, 0.7);
		add(arrSpr1);
		add(arrSpr2);
		add(diffSpr);

		trackList = new FlxText(0, 110, 0, "Tracks", 32);
		trackList.setFormat('assets/fonts/vcr.ttf', 32, CENTER);
		trackList.color = 0xFFE55777;
		trackList.screenCenter(X);
		trackList.x -= 167.5;
		add(trackList);

		changeSelection(0);

		super.create();
	}

	private var leaving:Bool = false;
	override function update(elapsed:Float){
		super.update(elapsed);
		if(leaving) return;

		var lerpVal = 1 - Math.pow(0.5, elapsed * 20);
		for(i in 0...wSprites.length){
			var wSpr:FlxSprite = wSprites.members[i];

			wSpr.x = FlxMath.lerp(wSpr.x, ((i - curSel) * 20) - 30, lerpVal);
			wSpr.y = FlxMath.lerp(wSpr.y, ((i - curSel) * 90) + 80, lerpVal);
		}
	}
	override function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		if(leaving) return;

		var t = key.deepCheck([NewControls.UI_U, NewControls.UI_D]);
		if(t != -1){
			changeSelection((t * 2) - 1);
			return;
		}
		t = key.deepCheck([NewControls.UI_L, NewControls.UI_R]);
		if(t != -1){
			changeDiff((t * 2) - 1, true);
			return;
		}

		if(key.hardCheck(NewControls.UI_BACK)){
			FlxG.sound.play(Paths.lSound('menu/cancelMenu'));
			FlxG.switchState(new MainMenuState());
			return;
		}

		if(!key.hardCheck(NewControls.UI_ACCEPT)) return;

		FlxG.sound.play(Paths.lSound('menu/confirmMenu'));
		leaving = true;

		PlayState.storyPlaylist = weekData[curSel].songs;
		PlayState.storyWeek = curSel;
		PlayState.SONG = Song.loadFromJson(weekData[curSel].songs[0], curDif);
		PlayState.isStoryMode = true;
		PlayState.storyDifficulty = curDif;
		PlayState.campaignScore = 0;

		for(i in 0...8)
			postEvent(i / 8, ()->{
				wSprites.members[curSel].color = (i % 2 == 0 ? whiteColour : selectColour);
			});
		postEvent(1, ()->{
			FlxG.switchState(new PlayState());
			if( FlxG.sound.music.playing)
				FlxG.sound.music.stop();
		});
	}

	private function changeDiff(to:Int, showArr:Bool){
		curDif = ((curDif + to) + CoolUtil.diffNumb) % CoolUtil.diffNumb;

		diffSpr.loadGraphic(Paths.lImage('storymenu/' + CoolUtil.diffString(curDif, 1).toLowerCase()));
		diffSpr.updateHitbox();
		diffSpr.centerOrigin();
		diffSpr.screenCenter(X);
		diffSpr.x -= 167.5;

		topText.text = weekData[curSel].topText + ' - ${Highscore.getScore('week-$curSel', curDif)}';
		topText.screenCenter(X);
		topText.x -= 320;

		if(!showArr) return;

		var arrow = [arrSpr2, arrSpr1][to >= 0 ? 1 : 0];
		arrow.color = selectColour;
		arrow.scale.set(0.6, 0.6);
		postEvent(0.08, ()->{
			arrow.color = whiteColour;
			arrow.scale.set(0.7, 0.7);
		});
	}

	private function changeSelection(to:Int){
		FlxG.sound.play(Paths.lSound('menu/scrollMenu'), 0.4);

		var oldSpr:FlxSprite = wSprites.members[curSel];
		curSel = ((curSel + to) + weekData.length) % weekData.length;

		var newSpr:FlxSprite = wSprites.members[curSel];

		oldSpr.alpha = 0.4;
		newSpr.alpha = 1;
		oldSpr.color = whiteColour;
		newSpr.color = selectColour;

		var oldRef:FlxSprite = weekBG;
		weekBG = new FlxSprite(640, 0).loadGraphic(Paths.lImage(weekData[curSel].graphic));
		weekBG.antialiasing = Settings.pr.antialiasing;
		add(weekBG);

		trackList.text = 'Tracks:\n';
		for(i in 0...weekData[curSel].songs.length)
			trackList.text += weekData[curSel].songs[i].trim().toUpperCase() + '\n';

		trackList.screenCenter(X);
		trackList.x -= 167.5;

		changeDiff(0, false);

		// fade between them
		if(oldRef == null) return;

		weekBG.alpha = 0;
		FlxTween.tween(weekBG, {alpha: 1}, 0.2);
		postEvent(0.21, ()->{
			if(oldRef == null) return;
			oldRef.destroy();
			oldRef = null;
		});
	}

	/*var scoreText:FlxText;

	var weekData:Array<Dynamic> = [
		['Tutorial'],
		['Bopeebo', 'Fresh', 'Dadbattle'],
		['Spookeez', 'South'],
		['Pico', 'Philly', "Blammed"],
		['Satin-Panties', "High", "Milf"],
		['Cocoa', 'Eggnog', 'Winter-Horrorland']
	];
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Int = 1;

	var weekCharacters:Array<Dynamic> = [
		['dad', 'bf', 'gf'],
		['dad', 'bf', 'gf'],
		['spooky', 'bf', 'gf'],
		['pico', 'bf', 'gf'],
		['mom', 'bf', 'gf'],
		['parents-christmas', 'bf', 'gf']
	];
	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat("assets/fonts/vcr.ttf", 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = FlxAtlasFrames.fromSparrow('assets/images/campaign_menu_UI_assets.png', 'assets/images/campaign_menu_UI_assets.xml');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, weekCharacters[curWeek][char]);
			weekCharacterThing.y += 70;
			weekCharacterThing.antialiasing = true;
			switch (weekCharacterThing.character)
			{
				case 'dad':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();

				case 'bf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
					weekCharacterThing.x -= 80;
				case 'gf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
				case 'pico':
					weekCharacterThing.y += 170;
					weekCharacterThing.flipX = true;
					weekCharacterThing.x -= 40;
				case 'parents-christmas':
					weekCharacterThing.x -= 600;
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
			}

			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);

		updateText();

		trace("Line 165");

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;
		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play('assets/sounds/cancelMenu' + TitleState.soundExt);
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play('assets/sounds/confirmMenu' + TitleState.soundExt);

				grpWeekText.members[curWeek].week.animation.resume();
				grpWeekCharacters.members[1].animation.play('bfConfirm');
				stopspamming = true;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
				FlxG.switchState(new PlayState());
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt);

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].animation.play(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].animation.play(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].animation.play(weekCharacters[curWeek][2]);
		txtTracklist.text = "Tracks\n";

		switch (grpWeekCharacters.members[0].animation.curAnim.name)
		{
			case 'parents-christmas':
				grpWeekCharacters.members[0].offset.x = 250;
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 0.97));

			default:
				grpWeekCharacters.members[0].offset.x = 100;
				grpWeekCharacters.members[0].setGraphicSize(Std.int(grpWeekCharacters.members[0].width * 1));
				// grpWeekCharacters.members[0].updateHitbox();
		}

		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}*/
}
