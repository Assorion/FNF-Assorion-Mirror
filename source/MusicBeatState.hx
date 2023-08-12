package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import openfl.events.KeyboardEvent;

typedef DelayedEvent = {
	var curTime:Float;
	var endTime:Float;
	var exeFunc:Void->Void;
}

class MusicBeatState extends FlxUIState
{

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var events:Array<DelayedEvent> = [];

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		Conductor.songPosition = -Settings.pr.offset;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.create();
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

	// # handle a forward event system.

	private inline function postEvent(forward:Float, func:Void->Void){
		events.push({
			curTime: 0,
			endTime: forward,
			exeFunc: func
		});
	}
	private function handleEvents(elapsed:Float){
		if(events.length == 0) return;

		var i = 0;
		while(i < events.length){
			var e = events[i];
			e.curTime += elapsed;
			if(e.curTime > e.endTime){
				e.exeFunc();
				events.splice(i, 1);
				i--;
			}

			i++;
		}
	}

	//////////////////////////////////////

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time - Settings.pr.offset;

		var oldStep:Int = curStep;
		updateCurStep();
		
		if(oldStep != curStep && curStep > 0)
			stepHit();

		handleEvents(elapsed);
		super.update(elapsed);
	}

	private inline function updateCurStep():Void
		curStep = Math.floor(Conductor.songPosition / Conductor.stepCrochet);

	public function stepHit():Void
	{
		if (curStep % 4 == 0){
			curBeat = Math.floor(curStep * 0.25);
			beatHit();
		}
	}

	public function beatHit():Void {}
}
