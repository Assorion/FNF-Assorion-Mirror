package misc;

import haxe.Json;
import lime.utils.Assets;
import misc.CoolUtil;

using StringTools;

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
		return cast Json.parse(rawJson).song;
	}
}
