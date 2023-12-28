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
class StoryMenuState extends MenuTemplate
{
	public static var curDif:Int = 1;

	static var weekData:Array<StoryData> = [
		{
			graphic: 'storymenu/storyportrait',
			// btw the 'week' var is used for loading the selected image.
			// It doesn't have to be a number or even in order.
			week: '1',
			songs: ['tutorial', 'fresh', 'test'],
			topText: 'THIS IS A TEST'
		}
	];

	var trackList:FlxText;
	public var weekBG:FlxSprite;
	public var topText:FlxText;

	var arrowSpr1:StaticSprite;
	var arrowSpr2:StaticSprite;
	var diffImage:StaticSprite;

	public static inline var selectColour:Int = 0xFF00FFFF;
	public static inline var whiteColour:Int  = 0xFFFFFFFF;

	override function create(){
		super.create();
		MusicBeatState.correctMusic();
		background.color = 0xFF000000;

		remove(background);

		for(i in 0...weekData.length){
			var weekGraphic:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.lImage('storymenu/week-' + weekData[i].week));
			weekGraphic.updateHitbox();
			weekGraphic.centerOrigin();
			weekGraphic.scale.set(0.7, 0.7);
			weekGraphic.antialiasing = Settings.pr.antialiasing;
			weekGraphic.offset.x += 75;

			pushObject(weekGraphic);
		}

		var topBlack:StaticSprite = new StaticSprite(0,0).makeGraphic(640, 20, FlxColor.fromRGB(25,25,25));
		topText = new FlxText(0, 2, 0, "1234567890ABCDEFG", 18);
		topText.setFormat('assets/fonts/vcr.ttf', 18, FlxColor.GRAY, CENTER);
		topText.screenCenter(X);
		topText.x -= 320;
		sAdd(topBlack);
		sAdd(topText);

		// bruh
		arrowSpr1 = new StaticSprite(640 - 50, 30).loadGraphic(Paths.lImage('storymenu/arrow'));
		arrowSpr1.antialiasing = Settings.pr.antialiasing;
		arrowSpr1.updateHitbox();
		arrowSpr1.centerOrigin();
		arrowSpr1.scale.set(0.7,0.7);
		arrowSpr2 = new StaticSprite(640 - 330, 30).loadGraphic(Paths.lImage('storymenu/arrow'));
		arrowSpr2.antialiasing = Settings.pr.antialiasing;
		arrowSpr2.flipX = true;
		arrowSpr2.updateHitbox();
		arrowSpr2.centerOrigin();
		arrowSpr2.scale.set(0.7, 0.7);

		diffImage = new StaticSprite(640, 45);
		diffImage.antialiasing = Settings.pr.antialiasing;
		diffImage.scale.set(0.7, 0.7);

		trackList = new FlxText(0, 110, 0, "Tracks", 32);
		trackList.setFormat('assets/fonts/vcr.ttf', 32, CENTER);
		trackList.color = 0xFFE55777;
		trackList.screenCenter(X);
		trackList.x -= 167.5;
		sAdd(arrowSpr1);
		sAdd(arrowSpr2);
		sAdd(diffImage);
		sAdd(trackList);
	}

	var leaving:Bool = false;
	override function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		if(!key.hardCheck(Binds.UI_ACCEPT)) return;

		if(leaving){
			skipTrans();
			return;
		}
		leaving = true;

		// can't just use the songs array outright.
		// otherwise it will end up deleting them.
		var nSongs:Array<String> = [];
		for(s in weekData[curSel].songs)
			nSongs.push(s);

		FlxG.sound.play(Paths.lSound('menu/confirmMenu'));
		var tP:PlayState = new PlayState(nSongs, curDif, curSel);

		for(i in 0...8)
			postEvent(i / 8, function(){
				arrGroup[curSel].obj.color = i % 2 == 0 ? whiteColour : selectColour;
			});
		// SWITCH!
		postEvent(1, function(){
			MusicBeatState.changeState(tP);
			if (FlxG.sound.music.playing)
				FlxG.sound.music.stop();
		});
	}

	public function changeDiff(to:Int, showArr:Bool){
		curDif = ((curDif + to) + CoolUtil.diffNumb) % CoolUtil.diffNumb;

		diffImage.loadGraphic(Paths.lImage('storymenu/' + CoolUtil.diffString(curDif, 1).toLowerCase()));
		diffImage.centerOrigin();
		diffImage.updateHitbox();
		diffImage.screenCenter(X);
		diffImage.x -= 167.5;

		topText.text = weekData[curSel].topText + ' - ${Highscore.getScore('week-$curSel', curDif)}';
		topText.screenCenter(X);
		topText.x -= 320;

		if(!showArr) return;

		var arrow = [arrowSpr2, arrowSpr1][to >= 0 ? 1 : 0];
		arrow.color = selectColour;
		arrow.scale.set(0.6, 0.6);
		postEvent(0.08, function(){
			arrow.color = whiteColour;
			arrow.scale.set(0.7, 0.7);
		});
	}
	override function changeSelection(to:Int = 0){
		arrGroup[curSel].obj.color = whiteColour;

		super.changeSelection(to);
		changeDiff(0, false);

		arrGroup[curSel].obj.color = selectColour;

		trackList.text = 'Tracks:\n';
		for(i in 0...weekData[curSel].songs.length)
			trackList.text += weekData[curSel].songs[i].toUpperCase() + '\n';

		trackList.screenCenter(X);
		trackList.x -= 167.5;

		// handle fades

		var oldRef:FlxSprite = weekBG;
		weekBG = new FlxSprite(640, 0).loadGraphic(Paths.lImage(weekData[curSel].graphic));
		weekBG.antialiasing = Settings.pr.antialiasing;
		sAdd(weekBG);

		if(oldRef == null) return;

		weekBG.alpha = 0;
		FlxTween.tween(weekBG, {alpha: 1}, 0.2);
		postEvent(0.21, function(){
			if(oldRef == null) return;

			oldRef.destroy();
			oldRef = null;
			remove(oldRef);
		});
	}
	override function altChange(to:Int = 0)
		changeDiff(to, true);
}