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
import flixel.addons.transition.FlxTransitionableState;

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
		// # bg stuff.

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/ui/menuDesat.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18 * (3 / optionList.length);
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = Settings.pr.antialiasing;
		bg.color = FlxColor.fromRGB(255, 232, 110);

		camFollow = new FlxObject(0, 0, 1, 1);
		menuItems = new FlxTypedGroup<FlxSprite>();

		add(bg);
		add(camFollow);
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
			menuItem.y += (i - Math.floor(optionList.length / 2) + (optionList.length % 2 == 0 ? 0.5 : 0)) * 160;
			menuItem.antialiasing = Settings.pr.antialiasing;

			menuItems.add(menuItem);
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionNumber:FlxText = new FlxText(5, FlxG.height - 18, 0, "Assorion Engine v" + Application.current.meta.get('version'), 12);
			versionNumber.scrollFactor.set();
			versionNumber.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionNumber);

		var o:Int = curSelected;
		curSelected = 0;
		changeItem(o);

		super.create();
	}

	override function stepHit(){
		FlxG.camera.followLerp = (1 - Math.pow(0.5, FlxG.elapsed * 6)) * (60 / Settings.pr.framerate);
		super.stepHit();
	}

	// # Input code

	var twns:Array<FlxTween> = [];
	override public function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		var k = key.deepCheck([NewControls.UI_U, NewControls.UI_D, NewControls.UI_ACCEPT, NewControls.UI_BACK, [FlxKey.B] ]);
		switch(k){
			case 0, 1:
				changeItem((k * 2) - 1);
				return;
			case 2:
				changeState();
				return;
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
				FlxG.sound.play(Paths.lSound('menu/cancelMenu'));
				FlxG.switchState(new TitleState());
	
				return;
			case 4:
				FlxG.switchState(new TestMenu());
				return;
		}
	}

	// # switches states

	private inline function changeState(){
		if(selectedSomethin){
			skipTrans();
			return;
		}
		FlxG.sound.play(Paths.lSound('menu/confirmMenu'));
		selectedSomethin = true;

		for(i in 0...optionList.length)
			if(i != curSelected)
				twns.push(FlxTween.tween(menuItems.members[i], {alpha:0}, 0.8));
		for(i in 0...8)
			postEvent(i / 8, ()->{
				menuItems.members[curSelected].alpha = (i % 2 == 0 ? 0 : 1);
			});

		postEvent(1, () -> {
			switch (curSelected){
				case 0:
					FlxG.switchState(new StoryMenuState());
				case 1:
					FlxG.switchState(new FreeplayState());
				case 2:
					CoolUtil.browserLoad('https://github.com/Legendary-Candice-Joe/FNF-Assorion-Engine/');
					FlxG.resetState();
				case 3:
					FlxG.switchState(new OptionsState());
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
