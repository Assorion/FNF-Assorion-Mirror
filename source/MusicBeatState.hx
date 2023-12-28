package;

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
	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var events:Array<DelayedEvent> = [];

	//private var correctMusic:Bool = true;
	//private var alignCamera:Bool = false;

	public static inline function curTime()
		#if desktop
		return Sys.time();
		#else
		return Date.now().getTicks();
		#end

	public static inline function correctMusic()
	if(FlxG.sound.music == null || !FlxG.sound.music.playing) {
		Conductor.changeBPM(Paths.menuTempo);
		FlxG.sound.playMusic(Paths.lMusic(Paths.menuMusic));
	}

	override function create()
	{
		// Don't worry the skipping is handled in the transition itself.
		openSubState(new NewTransition(null, false));

		Paths.clearCache();

		persistentUpdate = true;
		FlxG.camera.bgColor.alpha = 0;
		Conductor.songPosition = -Settings.pr.audio_offset;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.create();

		/*if((FlxG.sound.music != null && FlxG.sound.music.playing) || !correctMusic) return;

		Conductor.changeBPM(Paths.menuTempo);
		FlxG.sound.playMusic(Paths.lMusic(Paths.menuMusic));*/
	}

	// # new input thing.

	public var key = 0;
	public function keyHit(ev:KeyboardEvent)
		key = ev.keyCode;
	public function keyRel(ev:KeyboardEvent)
		key = ev.keyCode;

	override function destroy(){
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.destroy();
	}

	// # handle a delayed event system.

	private inline function postEvent(forward:Float, func:Void->Void){
		events.push({
			endTime: curTime() + forward,
			exeFunc: func
		});
	}

	//////////////////////////////////////

	private var oldStep:Int = 0;
	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time - Settings.pr.audio_offset;

		curStep = Math.floor(Conductor.songPosition * Conductor.songDiv);
		
		if(oldStep != curStep && curStep >= 0){
			oldStep = curStep;
			stepHit();
		}

		super.update(elapsed);

		var i = -1;
		while(++i < events.length){
			var e = events[i];

			if(curTime() < e.endTime) continue;

			e.exeFunc();
			events.splice(i--, 1);
		}
	}

	public function stepHit():Void
	//{
		//if(alignCamera)
		//	FlxG.camera.followLerp = (1 - Math.pow(0.5, FlxG.elapsed * 2)) * (60 / Settings.pr.framerate);

		if (curStep % 4 == 0){
			curBeat = Math.floor(curStep * 0.25);
			beatHit();
		}
	//}
	public function beatHit():Void {}

	private inline function skipTrans(){
		for(i in 0...events.length)
			events[i].exeFunc();

		if (NewTransition.activeTransition != null)
			NewTransition.activeTransition.skip();
	}

	// # Meant to handle transitions.

	public static function changeState(target:FlxState){
		new NewTransition(target, true);

		FlxG.state.openSubState(NewTransition.activeTransition);
		FlxG.state.persistentUpdate = false;
	}
}
