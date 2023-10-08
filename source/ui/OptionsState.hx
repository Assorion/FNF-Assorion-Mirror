package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import misc.Alphabet;
import gameplay.HealthIcon;
import flixel.text.FlxText;
import flixel.FlxObject;

/**
	Looks messy so lemme give you a quick write-up on how this works.

	You have option sub categories. They are visual and do not effect how the options are applied.
	If you press escape when optionSub is not 0 then you exit back to option sub 0.
**/

#if !debug @:noDebug #end
class OptionsState extends MenuTemplate
{
	static var optionSub:Array<Array<String>> = [
		['basic', 'gameplay', 'visuals', 'controls'],
		['start_fullscreen', 'start_volume', 'skip_logo', 'default_persist','launch_sprites','cache_text'],
		['audio_offset', 'input_offset', 'downscroll', 'ghost_tapping', 'botplay', 'miss_health'],
		['antialiasing', 'framerate', 'show_hud', 'useful_info', 'light_bot_strums']
	];

	static var descriptions:Array<Array<String>> = [
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
			'Load assets at startup. Uses even more RAM and increases startup time. Doesn\'t work in web browser.',
			'Cache text files when they are loaded. Disable if you are trying to mod.'
		],
		[
			'Change your audio offset in MS (leave this as-is if you don\'t know yours)',
			'Change your keyboard offset in MS. This only changes ratings, not the actual timing window.',
			'Change the scroll direction',
			'Allows pressing notes if there is no notes to hit',
			'Let the game handle your notes for you (does not count scores or health)',
			'Changes the amount of health you lose from missing'
		],
		[
			'If you don\'t know what this does, Google it.',
			'Changes how fast the game CAN run. I recommend setting it to 300, not the max',
			'Shows your health, stats, and other stuff in gameplay',
			'Shows FPS and memory counter',
			'Enemy notes glow like the players'
		]
	];

	public var curSub:Int = 0;
	public var descText:FlxText;
	var bottomBlack:FlxSprite;

	override function create()
	{
		super.create();
		background.color = 0xFFea71fd;

		bottomBlack = new FlxSprite(0, FlxG.height - 30).makeGraphic(1280, 30, FlxColor.BLACK);
		bottomBlack.alpha = 0.6;

		descText = new FlxText(5, FlxG.height - 25, 0, "", 20);
		descText.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, LEFT);
		adds = [400];
		
		sAdd(bottomBlack);
		sAdd(descText);

		createNewList();
	}
	
	public function createNewList(?appendOption:Bool = false){
		clearEverything();

		splitNumb = appendOption ? 2 : 1;

		for(i in 0...optionSub[curSub].length){
			pushObject(new Alphabet(0, (60 * i), optionSub[curSub][i], true));
			if(!appendOption){
				var ican:HealthIcon = new HealthIcon(['settings1','settings2'][Math.floor(i / 2)], false);

				if(ican.curChar == 'face')
					continue;
				if(i % 2 == 1) 
					ican.animation.play('losing');

				pushIcon(ican);
				continue;
			}

			// reflection. it's slow and not good. But I need it to get a variable from a string name.
			var optionStr:String = '';
			var val:Dynamic = Reflect.field(Settings.pr, optionSub[curSub][i]);

			optionStr = Std.string(val);
			if(Std.is(val, Bool))
				optionStr = val ? 'yes' : 'no';

			pushObject(new Alphabet(0, (60 * i), optionStr, true));
		}
		changeSelection();
	}

	override public function exitFunc(){
		if(curSub > 0){
			curSub = 0;
			curSel = 0;
			createNewList(false);

			return;
		}

		Settings.flush();
		super.exitFunc();
	}

	override function changeSelection(change:Int = 0){
		super.changeSelection(change);
		descText.text = descriptions[curSub][curSel];
	}

	// this is where you add your integer or slidable(?) options
	override function altChange(ch:Int = 0){
		var atg:Alphabet = cast objGroup.members[(curSel * 2) + 1];
		switch(optionSub[curSub][curSel]){
			case 'start_volume':
				Settings.pr.start_volume = CoolUtil.boundTo(Settings.pr.start_volume + (ch * 10), 0, 100, true);
				atg.text = Std.string(Settings.pr.start_volume);

			// gameplay.
			case 'audio_offset':
				Settings.pr.audio_offset = CoolUtil.boundTo(Settings.pr.audio_offset + ch, 0, 300, true);
				atg.text = Std.string(Settings.pr.audio_offset);
			case 'input_offset':
				Settings.pr.input_offset = CoolUtil.boundTo(Settings.pr.input_offset + ch, 0, 300, true);
				atg.text = Std.string(Settings.pr.input_offset);
			case 'miss_health':
				Settings.pr.miss_health = CoolUtil.boundTo(Settings.pr.miss_health + ch, 10, 50, true);
				atg.text = Std.string(Settings.pr.miss_health);

			// visuals
			case 'framerate':
				Settings.pr.framerate = CoolUtil.boundTo(Settings.pr.framerate + (ch * 10), 10, 500, true);
				atg.text = Std.string(Settings.pr.framerate);
				Settings.apply();
		}
		changeSelection(0);
	}

	// this is where you add your boolean or toggleable options
	override public function keyHit(ev:KeyboardEvent){
		super.keyHit(ev);

		if(!key.hardCheck(NewControls.UI_ACCEPT)) return;

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
				if(Settings.pr.default_persist) gameplay.PauseSubState.newCanvas(true);
			case 'launch_sprites':
				Settings.pr.launch_sprites = !Settings.pr.launch_sprites;
			case 'cache_text':
				Settings.pr.cache_text = !Settings.pr.cache_text;

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
	}
}
