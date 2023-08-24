package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import misc.Alphabet;
import gameplay.HealthIcon;
import flixel.text.FlxText;

/**
	Looks messy so lemme give you a quick write-up on how this works.

	You have option sub categories. They are visual and do not effect how the options are applied.
	If you press escape when optionSUb is not 0 then you exit back to option sub 0.

	The text group well be of multiples of 2 as you have the option text, and the option value.
	option value is kinda handled separately and is centered, then pushed off to the right.

	to add an option. Add it to the Settings (and if the default is not correct add it to the JSON file).
	Then add it in either one of the Subs, or add your own set menu. (just add a new item to the array).
	If it's an integer, search for the # handles integer part of the code.
	If it's togglable, then just add it to the other switch statement.
**/

class OptionsState extends MusicBeatState
{
	var optionSub:Array<Array<String>> = [
		['basic', 'gameplay', 'visuals', 'controls'],
		['start_fullscreen', 'start_volume', 'skip_logo', 'default_persist','launch_sprites'],
		['downscroll', 'offset', 'botplay', 'ghost_tapping', 'miss_health'],
		['useful_info', 'antialiasing', 'show_hud', 'framerate', 'light_bot_strums']
	];

	var descriptions:Array<Array<String>> = [
		[
			'Basic options for the game Window', 
			'Options for the gameplay itself', 
			'Options for visuals and effects', 
			'Change the key bindings',
		],
		[
			'Start the game in fullscreen mode',
			'Change the games starting volume',
			'Skip the haxeflixel intro logo',
			'Makes all loaded sprites stay in RAM. Uses tons more memory but will decrease load times.',
			'Load songs and sprites at startup. Uses even more RAM and increases startup time.'
		],
		[
			'Change the scroll direction',
			'Change your audio offset (leave this as-is if you don\'t know yours)',
			'Let the game handle your notes for you (does not count scores or health)',
			'Allows pressing notes if there is no notes to hit',
			'Changes the amount of health you lose from missing'
		],
		[
			'Shows FPS and memory counter',
			'If you don\'t know what this does, Google it.',
			'Shows your health, stats, and other stuff in gameplay',
			'Changes how fast the game runs',
			'Enemy notes glow like the players'
		]
	];

	var activeTextGroup:FlxTypedGroup<Alphabet>;
	var activeIcons:FlxTypedGroup<HealthIcon>;
	public static var curSel:Int = 0;
	public var curSub:Int = 0;
	public var descText:FlxText;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.lImage('ui/menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.antialiasing = Settings.pr.antialiasing;
		add(menuBG);

		activeTextGroup = new FlxTypedGroup<Alphabet>();
		activeIcons     = new FlxTypedGroup<HealthIcon>();
		add(activeTextGroup);
		add(activeIcons);

		var bottomBlack:FlxSprite = new FlxSprite(0, FlxG.height - 30).makeGraphic(1280, 30, FlxColor.BLACK);
		bottomBlack.alpha = 0.6;

		descText = new FlxText(5, FlxG.height - 25, 0, "", 20);
		descText.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, LEFT);
		add(bottomBlack);
		add(descText);

		createNewList();

		super.create();
	}

	// # add group text.
	private function quicklyAddText(str:String, p:Int):Alphabet
	{
		var opT:Alphabet = new Alphabet(0, (60 * p) + 30, str, true);
			opT.alpMult = 0.4;
			opT.alpha = 0;
			opT.lerpPos = true;
			activeTextGroup.add(opT);
		return opT;
	}
	
	public function createNewList(?appendOption:Bool = false){
		activeTextGroup.clear();
		activeIcons.clear();
		for(i in 0...optionSub[curSub].length){
			var alp = quicklyAddText(optionSub[curSub][i], i);

			var str:String = '';
			if(appendOption){
				// reflection. it's slow and not good. But I need it to get a variable from a string name.
				var val:Dynamic = Reflect.field(Settings.pr, optionSub[curSub][i]);
				str = Std.string(val);
				if(Std.is(val, Bool))
					str = val ? 'yes' : 'no';
			}
			quicklyAddText(str, i);

			// sorry for the hard code.
			if(curSub != 0) continue;

			var ican = new HealthIcon(i < 2 ? 'settings1' : 'settings2', false, alp);
			ican.scale.set(0.85,0.85);
			activeIcons.add(ican);

			if(i % 2 == 1) ican.animation.play('losing');
		}

		changeSel();
	}

	override public function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		var t = key.deepCheck([NewControls.UI_U,NewControls.UI_D]);
		if(t != -1){
			changeSel((t * 2) - 1);
			return;
		}

		// # Handle toggle options

		if(key.hardCheck(NewControls.UI_ACCEPT)){
			// this is where the magic happens

			switch(optionSub[curSub][curSel]){
				case 'basic':
					curSel = 0;
					curSub = 1;
				case 'gameplay':
					curSel = 0;
					curSub = 2;
				case 'visuals':
					curSel = 0;
					curSub = 3;
				case 'controls':
					FlxG.switchState(new ControlsState());
					return;

				// basic
				case 'start_fullscreen':
					Settings.pr.start_fullscreen = !Settings.pr.start_fullscreen;
				case 'skip_logo':
					Settings.pr.skip_logo = !Settings.pr.skip_logo;
				case 'default_persist':
					Settings.pr.default_persist = !Settings.pr.default_persist;
				case 'launch_sprites':
					Settings.pr.launch_sprites = !Settings.pr.launch_sprites;

				// gameplay
				case 'downscroll':
					Settings.pr.downscroll = !Settings.pr.downscroll;
				case 'botplay':
					Settings.pr.botplay = !Settings.pr.botplay;
				case 'ghost_tapping':
					Settings.pr.ghost_tapping = !Settings.pr.ghost_tapping;

				// visuals
				case 'useful_info':
					Settings.pr.useful_info = !Settings.pr.useful_info;
					Settings.apply();
				case 'antialiasing':
					Settings.pr.antialiasing = !Settings.pr.antialiasing;
				case 'show_hud':
					Settings.pr.show_hud = !Settings.pr.show_hud;
				case 'light_bot_strums':
					Settings.pr.light_bot_strums = !Settings.pr.light_bot_strums;
			}
			createNewList(true);

			return;
		}

		// # Handle integer options.

		t = key.deepCheck([NewControls.UI_L, NewControls.UI_R]);
		if(t != -1){
			var ch:Int = (t * 2) - 1;
			var atg = activeTextGroup.members[(curSel * 2) + 1];

			switch(optionSub[curSub][curSel]){
				case 'start_volume':
					Settings.pr.start_volume = CoolUtil.boundTo(Settings.pr.start_volume + (ch * 10), 0, 100, true);
					atg.text = Std.string(Settings.pr.start_volume);

				// gameplay.
				case 'offset':
					Settings.pr.offset = CoolUtil.boundTo(Settings.pr.offset + ch, -100, 300, true);
					atg.text = Std.string(Settings.pr.offset);
				case 'miss_health':
					Settings.pr.miss_health = CoolUtil.boundTo(Settings.pr.miss_health + ch, 0, 50, true);
					atg.text = Std.string(Settings.pr.miss_health);

				// visuals
				case 'framerate':
					Settings.pr.framerate = CoolUtil.boundTo(Settings.pr.framerate + (ch * 10), 10, 500, true);
					atg.text = Std.string(Settings.pr.framerate);
					Settings.apply();
			}
			recenterOption(atg);

			return;
		}

		// escapes

		if(key.hardCheck(NewControls.UI_BACK)){
			if(curSub != 0){
				curSel = 0;
				curSub = 0;
				createNewList();

				return;
			}

			Settings.apply();
			Settings.flush();
			FlxG.sound.play(Paths.lSound('menu/cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}
	}

	private inline function recenterOption(grp:Alphabet){
		grp.screenCenter(X);
		grp.x += 400;
		grp.targetX = grp.x;
	}

	function changeSel(to:Int = 0)
	{
		FlxG.sound.play(Paths.lSound('menu/scrollMenu'), 0.4);

		curSel += to;
		curSel %= optionSub[curSub].length;
		if(curSel < 0) curSel = optionSub[curSub].length - 1;

		descText.text = descriptions[curSub][curSel];

		for(i in 0...Math.floor(activeTextGroup.length / 2)){
			var item = activeTextGroup.members[i * 2];
			var it2m = activeTextGroup.members[(i * 2) + 1];

			it2m.alpMult = item.alpMult = 1;
			if(i != curSel) it2m.alpMult = item.alpMult = 0.4;

			it2m.targetY = item.targetY = (i - curSel) * 90;
			it2m.targetY = item.targetY = item.targetY + 160;
			item.targetX = (i - curSel) * 15;
			item.targetX += 30;

			recenterOption(it2m);
		}
	}
}
