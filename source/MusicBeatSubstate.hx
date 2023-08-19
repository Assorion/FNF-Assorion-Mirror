package;

import flixel.FlxG;
import flixel.FlxSubState;
import MusicBeatState.DelayedEvent;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

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
			curTime: 0,
			endTime: forward,
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

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time - Settings.pr.offset;

		var oldStep:Int = curStep;
		updateCurStep();
		
		if(oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);

		if(events.length == 0) return;

		var i = 0;
		while(i < events.length){
			var e = events[i];
			e.curTime += elapsed;
			if(e.curTime >= e.endTime){
				e.exeFunc();
				events.splice(i, 1);
				i--;
			}

			i++;
		}
	}

	private inline function updateCurStep():Void
		curStep = Math.floor(Conductor.songPosition * Conductor.songDiv);

	public function stepHit():Void
	{
		if (curStep % 4 == 0){
			curBeat = Math.floor(curStep * 0.25);
			beatHit();
		}
	}

	public function beatHit():Void {}
}
