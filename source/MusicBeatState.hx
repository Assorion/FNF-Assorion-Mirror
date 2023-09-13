package;

import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import openfl.events.KeyboardEvent;

#if !debug @:noDebug #end
class MusicBeatState extends FlxUIState
{

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var events:Array<DelayedEvent> = [];
	private var correctMusic:Bool = true;

	override function create()
	{
		if(!Settings.pr.default_persist && !Settings.pr.launch_sprites){
			openfl.Assets.cache.clear();
			lime.utils.Assets.cache.clear();
		}
		// please put persistent update on for ui states.
		// because it will make the navigation faster.
		persistentUpdate = true;
		Conductor.songPosition = -Settings.pr.offset;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHit);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP  , keyRel);

		super.create();

		if((FlxG.sound.music != null && FlxG.sound.music.playing) || !correctMusic) return;

		Conductor.changeBPM(Paths.menuTempo);
		FlxG.sound.playMusic(Paths.lMusic(Paths.menuMusic));
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

	// # handle a delayed event system.

	private inline function postEvent(forward:Float, func:Void->Void){
		events.push({
			curTime: 0,
			endTime: forward,
			exeFunc: func
		});
	}
	private inline function handleEvents(elapsed:Float){
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

	//////////////////////////////////////

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time - Settings.pr.offset;

		var oldStep:Int = curStep;
		updateCurStep();
		
		if(oldStep != curStep && curStep >= 0)
			stepHit();

		handleEvents(elapsed);
		super.update(elapsed);
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

	private inline function skipTrans(){
		FlxTransitionableState.skipNextTransIn  = true;
		FlxTransitionableState.skipNextTransOut = true;
		for(i in 0...events.length)
			events[i].exeFunc();
	}

	public function beatHit():Void {}
}
