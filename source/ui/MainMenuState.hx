package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;

using StringTools;

#if !debug @:noDebug #end
class MainMenuState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;

	// too lazy to separate out these assets.
	// so instead you can define your own asset path.
	static var optionList:Array<String> = ['story mode', 'freeplay', 'github',   'options'];
	static var optionPath:Array<String> = ['FNF_main'  , 'FNF_main', 'FNF_main', 'FNF_main'];
	var selectedSomethin:Bool = false;

	override function create()
	{
		Paths.clearCache();

		var bg:StaticSprite = new StaticSprite(-80).loadGraphic('assets/images/ui/menuDesat.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18 * (3 / optionList.length);
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = Settings.pr.antialiasing;
		bg.color  = FlxColor.fromRGB(255, 232, 110);
		menuItems = new FlxTypedGroup<FlxSprite>();

		camFollow = new FlxObject(0, 0, 1, 1);

		add(bg);
		add(menuItems);

		for (i in 0...optionList.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 0);
			menuItem.frames = Paths.lSparrow('ui/${optionPath[i]}');

			menuItem.animation.addByPrefix('idle',     optionList[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionList[i] + " white", 24);
			menuItem.animation.play('idle');

			menuItem.screenCenter();
			menuItem.scrollFactor.set();
			menuItem.y += (i - Math.floor(optionList.length / 2) + (optionList.length & 0x01 == 0 ? 0.5 : 0)) * 160;
			menuItem.antialiasing = Settings.pr.antialiasing;

			menuItems.add(menuItem);
		}

		FlxG.camera.follow(camFollow, null, 0.023);

		var versionNumber:FlxText = new FlxText(5, FlxG.height - 18, 0, "Assorion Engine v" + Application.current.meta.get('version'), 12);
			versionNumber.scrollFactor.set();
			versionNumber.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionNumber);

		var o:Int = curSelected;
		curSelected = 0;
		changeItem(o);

		super.create();
	}

	// Camera fix across framerates (Not needed for newer flixel versions!)

	#if (flixel < "5.4.0")
	override public function stepHit(){
		super.stepHit();
		FlxG.camera.followLerp = (1 - Math.pow(0.5, FlxG.elapsed * 2)) * Main.framerateDivision;
	}
	#end

	var twns:Array<FlxTween> = [];
	var leaving:Bool = false;
	override public function keyHit(ev:KeyboardEvent){
		var k = ev.keyCode.deepCheck([Binds.UI_U, Binds.UI_D, Binds.UI_ACCEPT, Binds.UI_BACK ]);

		switch(k){
			case 0, 1:
				changeItem((k * 2) - 1);
			case 2:
				changeState();
			case 3:
				if(selectedSomethin){
					for(i in 0...optionList.length){
						if(twns[i] != null) twns[i].cancel();
						menuItems.members[i].alpha = 1;
					}
					events = [];
					selectedSomethin = false;
					twns = [];

					return;
				}
				if(leaving){
					NewTransition.skip();
					return;
				}

				FlxG.sound.play(Paths.lSound('menu/cancelMenu'));
				MusicBeatState.changeState(new TitleState());
				leaving = true;
		}
	}

	private inline function changeState(){
		if(selectedSomethin){
			execEvents();
			NewTransition.skip();
			return;
		}
		
		FlxG.sound.play(Paths.lSound('menu/confirmMenu'));
		selectedSomethin = true;

		for(i in 0...optionList.length)
			if(i != curSelected)
				twns.push(FlxTween.tween(menuItems.members[i], {alpha:0}, 0.8));
		for(i in 0...8)
			postEvent(i / 8, function(){
				menuItems.members[curSelected].alpha = (i & 0x01 == 0 ? 0 : 1);
			});

		postEvent(1, function() {
			switch (curSelected){
				case 0:
					MusicBeatState.changeState(new StoryMenuState());
				case 1:
					MusicBeatState.changeState(new FreeplayState());
				case 2:
					var site = 'https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine/';

					#if linux Sys.command('/usr/bin/xdg-open', [site]);
					#else FlxG.openURL(site); #end
					
					FlxG.resetState();
				case 3:
					MusicBeatState.changeState(new OptionsState());
			}
		});
	}

	function changeItem(to:Int = 0)
	{
		if(selectedSomethin) return;

		FlxG.sound.play(Paths.lSound('menu/scrollMenu'));

		var oldSel = curSelected;
		curSelected += to;

		curSelected %= menuItems.length;
		if(curSelected < 0) curSelected = menuItems.length-1;

		// # selection code.

		var newItem = menuItems.members[curSelected];
		var oldItem = menuItems.members[oldSel];

		oldItem.animation.play('idle');
		newItem.animation.play('selected');

		camFollow.y = newItem.getGraphicMidpoint().y;

		oldItem.updateHitbox();
		oldItem.screenCenter(X);
		newItem.updateHitbox();
		newItem.screenCenter(X);
	}
}
