package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import ui.ChartingState;
import misc.Highscore;
import misc.Alphabet;
import misc.Song;
import gameplay.PlayState;

using StringTools;

typedef StoryData = {
	var graphic:String;
	var week:String;
	var songs:Array<String>;
	var topText:String;
}

#if !debug @:noDebug #end
class StoryMenuState extends MusicBeatState
{
	public static var curSel:Int = 0;
	public static var curDif:Int = 2;

	var weekData:Array<StoryData> = [
		{
			graphic: 'storymenu/storyportrait',
			week: '1',
			songs: ['tutorial', 'fresh', 'test'],
			topText: 'THIS IS A TEST'
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
}
