package;

import flixel.FlxG;
import flixel.FlxSubState;
import MusicBeatState.DelayedEvent;

#if !debug @:noDebug #end
class MusicBeatSubstate extends FlxSubState
{
	public function new()
		super();

	private var events:Array<DelayedEvent> = [];

	private inline function postEvent(forward:Float, func:Void->Void)
	events.push({
		endTime: MusicBeatState.curTime() + forward,
		exeFunc: func
	});

	// # new input thing.

	public function keyHit(ev:KeyboardEvent){}
	public function keyRel(ev:KeyboardEvent){}

	override function create()
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.create();
	}

	override function destroy(){
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.destroy();
	}

	//////////////////////////////////////

	override function update(elapsed:Float)
	{
		var cTime = MusicBeatState.curTime();
		var i = -1;
		while(++i < events.length){
			var e = events[i];

			if(cTime < e.endTime)
				continue;

			e.exeFunc();
			events.splice(i--, 1);
		}

		super.update(elapsed);
	}
}
