package gameplay;

import flixel.FlxSprite;
import haxe.Json;

using StringTools;

typedef AnimationData = {
	var animationName:String;
	var xmlName:String;
	var framerate:Int;
	var loop:Bool;
	var offsetX:Int;
	var offsetY:Int;
}
typedef CharacterData = {
	var name:String;
	var leftRightIdle:Bool;
	var flipX:Bool;
	var cameraOffsetX:Int;
	var cameraOffsetY:Int;
	var animations:Array<AnimationData>;
}

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
		super(x, y);

		Song.beatHooks.push(dance);

		antialiasing  = Settings.antialiasing;
		animOffsets   = new Map<String, Array<Int>>();
		curCharacter  = character;
		this.isPlayer = isPlayer;

		frames = Paths.lSparrow('characters/$character');
		addAnimationJSONFile();
		
		playAnim(leftRightIdle ? 'danceLeft' : 'idle');
		if(isPlayer) 
			flipX = !flipX;
	}

	// You will have to write the JSON by hand, if this change is not well recieved (make an issue about it or smth) then I will undo the change.

	public function addAnimationJSONFile(){
		var charArray:Array<CharacterData> = cast Json.parse(Paths.lText('characterLoader.json')).characters;

		for(charData in charArray){
			if(charData.name.trim() != curCharacter) 
				continue;

			leftRightIdle = charData.leftRightIdle;
			flipX         = charData.flipX;
			camOffset     = [charData.cameraOffsetX, charData.cameraOffsetY ];

			for(anim in charData.animations){
				animation.addByPrefix(anim.animationName.trim(), anim.xmlName.trim(), anim.framerate, anim.loop);
				animation.play(anim.animationName.trim());

				addOffset(anim.animationName.trim(), anim.offsetX, anim.offsetY);
			}
		}
	}

	private var danced:Bool = false;
	public function dance()
	{
		if(Song.currentBeat % (Math.floor(Song.BPM / PlayState.beatHalfingTime) + 1) != 0)
			return;

		if(!idleNextBeat) {
			idleNextBeat = true;
			return;
		}

		if(!leftRightIdle){
			playAnim('idle', true);
			return;
		}

		danced = !danced;
		playAnim('dance' + (danced ? 'Right' : 'Left'), true);
	}

	public function playAnim(AnimName:String, ?INB:Bool = false):Void
	{
		idleNextBeat = INB;
		
		// this is so the game hopefully doesn't crash if an animation
		// isn't added. By checking if the offset exists.
		var curOffset:Array<Int> = animOffsets.get(AnimName);
		if (curOffset == null || curOffset.length != 2) 
			return;

		animation.play(AnimName, true);
		offset.set(curOffset[0], curOffset[1]);
	}

	public inline function addOffset(name:String, x:Int = 0, y:Int = 0)
	{
		animOffsets.set(name, [x, y]);
	}
}
