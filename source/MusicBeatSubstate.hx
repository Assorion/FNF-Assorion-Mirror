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

	private inline function postEvent(forward:Float, func:Void->Void)
	events.push({
		endTime: MusicBeatState.curTime() + forward,
		exeFunc: func
	});

	// # new input thing.

	public function keyHit(ev:KeyboardEvent){}
	public function keyRel(ev:KeyboardEvent){}

	override function destroy(){
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.destroy();
	}

	//////////////////////////////////////

	override function update(elapsed:Float)
	{
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
}
