package misc;

import flixel.FlxSprite;

/*
    Putting all of these here for simplicity sake.
    Not that I expect this to be much easier to work with but y'know.
*/

typedef MenuObject = {
	var obj:FlxSprite;
	var targetX:Int;
	var targetY:Int;
	var targetA:Float;
}

// used for charts
typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var mustHitSection:Bool;
}

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var characters:Array<String>;
	var activePlayer:Int;
	var stage:String;
	var beginTime:Float;
}

// used for dialogue
typedef SlideShowPoint = {
    var portrait:String;
    var side:Int;
    var flipX:Bool;
    var text:String;
}

// used for note tpyes.
typedef NoteType = {
	var assets:String;
	var mustHit:Bool;
	var rangeMul:Float;
	var onHit:Void->Void;
	var onMiss:Void->Void;
}

// used for playstate ratings
typedef RatingThing = {
	var score:Int;
	var threshold:Float;
	var name:String;
	var value:Int;
}

// used for event system in musicbeatstate
typedef DelayedEvent = {
	var curTime:Float;
	var endTime:Float;
	var exeFunc:Void->Void;
}

// used for storymenu
typedef StoryData = {
	var graphic:String;
	var week:String;
	var songs:Array<String>;
	var topText:String;
}