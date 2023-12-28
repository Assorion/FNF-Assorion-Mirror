package;

import flixel.FlxG;
import flixel.FlxSubState;
import MusicBeatState.DelayedEvent;

#if !debug @:noDebug #end
class MusicBeatSubstate extends FlxSubState
{
	public function new()
		super();

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var events:Array<DelayedEvent> = [];

	override function create()
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.create();
	}

	private inline function postEvent(forward:Float, func:Void->Void){
		events.push({
			endTime: MusicBeatState.curTime() + forward,
			exeFunc: func
		});
	}

	// # new input thing.

	public var key = 0;
	public function keyHit(ev:KeyboardEvent){
		key = ev.keyCode;
	}
	public function keyRel(ev:KeyboardEvent){
		key = ev.keyCode;
	}

	override function destroy(){
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.destroy();
	}

	//////////////////////////////////////

	private var oldStep:Int = 0;
	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time - Settings.pr.audio_offset;

		curStep = Math.floor(Conductor.songPosition * Conductor.songDiv);
		
		if(oldStep != curStep && curStep > 0){
			oldStep = curStep;
			stepHit();
		}

		super.update(elapsed);

		var i = -1;
		while(++i < events.length){
			var e = events[i];

			if(MusicBeatState.curTime() < e.endTime)
				return;

			e.exeFunc();
			events.splice(i--, 1);
		}
	}

	public function stepHit():Void
	if (curStep % 4 == 0){
		curBeat = Math.floor(curStep * 0.25);
		beatHit();
	}

	public function beatHit():Void {
		//if(alignCamera)
		//	FlxG.camera.followLerp = (1 - Math.pow(0.5, FlxG.elapsed * 2)) * (60 / Settings.pr.framerate);
	}
}
