package;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;
import openfl.events.KeyboardEvent;
import backend.NewTransition;

typedef DelayedEvent = {
	var endTime:Float;
	var exeFunc:Void->Void;
}

#if !debug @:noDebug #end
class MusicBeatState extends FlxUIState
{
	private var events:Array<DelayedEvent> = [];
	public static inline function curTime()
		#if desktop return Sys.time();
		#else       return Date.now().getTime() * 0.001;
		#end

	override function create()
	{
		Song.clearHooks();
		openSubState(new NewTransition(null, false));

		FlxG.camera.bgColor.alpha = 0;
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP  , keyRel);

		persistentUpdate = true;

		super.create();
	}

	// # Input code

	public function keyHit(ev:KeyboardEvent){}
	public function keyRel(ev:KeyboardEvent){}

	override function destroy(){
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.destroy();
	}

	private inline function postEvent(forward:Float, func:Void->Void)
	events.push({
		endTime: curTime() + forward,
		exeFunc: func
	});

	override function update(elapsed:Float)
	{
		// # Check if event needs to be executed.

		var i = -1;
		var cTime = curTime();
		while(++i < events.length){
			if(cTime < events[i].endTime)
				continue;

			events[i].exeFunc();
			events.splice(i--, 1);
		}

		super.update(elapsed);
	}

	private inline function execEvents()
		for(i in 0...events.length)
			events[i].exeFunc();

	public static function changeState(target:FlxState){
        NewTransition.activeTransition = new NewTransition(target, true);

        FlxG.state.openSubState(NewTransition.activeTransition);
        FlxG.state.persistentUpdate = false;
    }
}
