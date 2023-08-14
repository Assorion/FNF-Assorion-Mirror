package;

import flixel.FlxG;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

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

	//////////////////////////////////////

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time - Settings.pr.offset;

		var oldStep:Int = curStep;
		updateCurStep();
		
		if(oldStep != curStep && curStep > 0)
			stepHit();

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
