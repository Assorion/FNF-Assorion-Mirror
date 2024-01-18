package;

import ui.CustomChartUI.ChartUI_Generic;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;
import openfl.events.KeyboardEvent;

import ui.NewTransition;

typedef DelayedEvent = {
	var endTime:Float;
	var exeFunc:Void->Void;
}

#if !debug @:noDebug #end
class MusicBeatState extends FlxUIState
{
	public static inline function curTime()
		#if desktop
		return Sys.time();
		#else
		return Date.now().getTime() * 0.001;
		#end

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var events:Array<DelayedEvent> = [];

	public function correctMusic()
	if(FlxG.sound.music == null || !FlxG.sound.music.playing) {
		Song.musicSet(Paths.menuTempo);
		FlxG.sound.playMusic(Paths.lMusic(Paths.menuMusic));
	}

	override function create()
	{
		// Don't worry the skipping is handled in the transition itself.
		openSubState(new NewTransition(null, false));

		persistentUpdate = true;
		FlxG.camera.bgColor.alpha = 0;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.create();
	}

	// # new input thing.

	public function keyHit(ev:KeyboardEvent){}
	public function keyRel(ev:KeyboardEvent){}

	override function destroy(){
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.destroy();
	}

	// # handle a delayed event system.

	private inline function postEvent(forward:Float, func:Void->Void)
	events.push({
		endTime: curTime() + forward,
		exeFunc: func
	});

	//////////////////////////////////////

	private var oldStep:Int = 0;
	override function update(elapsed:Float)
	{
		Song.curMus.songPosition = FlxG.sound.music.time - Settings.pr.audio_offset;

		curStep = Math.floor(Song.curMus.songPosition * Song.curMus.songDiv);
		
		if (oldStep != curStep && curStep >= -1){
			oldStep = curStep;
			stepHit();
		}

		super.update(elapsed);

		var cTime = curTime();
		var i = -1;
		while(++i < events.length){
			var e = events[i];

			if(cTime < e.endTime) continue;

			e.exeFunc();
			events.splice(i--, 1);
		}
	}

	// This should be documented in the Wiki. That will happen eventually.
	public function beatHit():Void {}
	public function stepHit():Void
	{
		var tBeat:Int = curStep >> 2;

		if (curStep - (tBeat << 2) == 0){
			curBeat =  tBeat;
			beatHit();
		}
	}

	private inline function execEvents()
	for(i in 0...events.length)
		events[i].exeFunc();

	public static var changeState:FlxState->Void = NewTransition.switchState;
}
