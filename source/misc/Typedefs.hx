package misc;

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
	var missIfHit:Bool;
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

// used for delayed events
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