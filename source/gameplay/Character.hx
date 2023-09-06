package gameplay;

import flixel.FlxSprite;

using StringTools;

#if !debug @:noDebug #end
class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Int>>;
	public var camOffset:Array<Int> = [0,0];

	public var isPlayer:Bool = false;
	public var idleNextBeat :Bool = true;

	public var curCharacter:String = 'bf';
	public var leftRightIdle:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		animOffsets = new Map<String, Array<Int>>();
		super(x, y);

		curCharacter  = character;
		this.isPlayer = isPlayer;

		/*
			LOOK AT CHARACTER LOADER TXT PLEASE!!!
		*/

		frames = Paths.lSparrow('characters/$character');
		addAnimationTextFile();

		antialiasing = Settings.pr.antialiasing;

		playAnim('idle');
		if(isPlayer) flipX = !flipX;
	}

	public function addAnimationTextFile(){
		var lines:Array<String> = CoolUtil.textFileLines('characterLoader');

		for(i in 0...lines.length){
			if(lines[i].trim().startsWith('#')) continue;

			var splitLn:Array<String> = lines[i].split(':');
			// this allows spacing within the file.
			for(i in 0...splitLn.length) splitLn[i] = splitLn[i].trim();
			if(splitLn[0] != curCharacter) continue;

			animation.addByPrefix(
				splitLn[1], 
				splitLn[2], 
				Std.parseInt(splitLn[3]), 
				splitLn[4] == 't'
			);
			addOffset(splitLn[1], Std.parseInt(splitLn[5]), Std.parseInt(splitLn[6]));
			// hopefully caches
			animation.play(splitLn[1]);

			// haxe will automatically add this element to the array if it doesn't exist.
			leftRightIdle = (splitLn[7] == 't');
			flipX         = (splitLn[8] == 't');

			if(splitLn[10] != ''){
				camOffset[0]  = Std.parseInt(splitLn[9]);
				camOffset[1]  = Std.parseInt(splitLn[10]);
			}
		}
	}

	private var danced:Bool = false;
	public function dance()
	{
		if(!idleNextBeat) {
			idleNextBeat = true;
			return;
		}
		if(leftRightIdle){
			danced = !danced;

			playAnim('dance' + (danced ? 'Right' : 'Left'), true);
			return;
		}

		playAnim('idle', true);
	}

	public function playAnim(AnimName:String, INB:Bool = false):Void
	{
		idleNextBeat = INB;
		// this is so the game hopefully doesn't crash if an animation
		// isn't added. By checking if the offset exists.
		var curOffset:Array<Int> = animOffsets.get(AnimName);
		if (curOffset == null || curOffset.length != 2) return;

		animation.play(AnimName, true);
		offset.set(curOffset[0], curOffset[1]);
	}

	public function addOffset(name:String, x:Int = 0, y:Int = 0)
	{
		animOffsets.set(name, [x, y]);
	}
}
