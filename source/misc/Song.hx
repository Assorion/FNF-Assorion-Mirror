package misc;

import haxe.Json;
import lime.utils.Assets;
import misc.CoolUtil;

using StringTools;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var cameraFacing:Int;
}

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var playLength:Int;
	var characters:Array<String>;
	var activePlayer:Int;
	var stage:String;
	var beginTime:Float;
}

#if !debug @:noDebug #end
class Song
{
	public static function loadFromJson(song:String, diff:Int):SwagSong
	{
		song = song.toLowerCase();
		
		return parseJSON(Paths.lText('$song/$song${CoolUtil.diffString(diff, 0)}.json'));
	}

	public static inline function parseJSON(rawJson:String):SwagSong
	{
		var tmpCast:SwagSong = cast Json.parse(rawJson).song;

		/* most stupid thing haxe ever does.
		   my assumption is when you use JSON, e.g: an integer is actually Null<Int>, instead of Int.
		   It's annoying cause haxe will NOT let you check if the value is null when that happens.
		   So here I have to cast the value to what it should have already been, just to have this work.
		   (I guess casting a null value will assume 0)
		*/

		if (cast(tmpCast.playLength, Int) < 1) 
			tmpCast.playLength = 2;

		return tmpCast;
	}
}
