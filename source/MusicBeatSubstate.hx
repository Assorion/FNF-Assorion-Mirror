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

		var cTime = MusicBeatState.curTime();
		var i = -1;
		while(++i < events.length){
			var e = events[i];

			if(cTime < e.endTime)
				return;

			e.exeFunc();
			events.splice(i--, 1);
		}
	}

	public function stepHit():Void
	{
		var tBeat:Int = curStep >> 2;

		if (curStep - (tBeat << 2) == 0){
			curBeat = tBeat;
			beatHit();
		}
	}

	public function beatHit():Void {}
}
