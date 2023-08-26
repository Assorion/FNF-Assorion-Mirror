package misc;

import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

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

class Song
{
	public static function loadFromJson(song:String, diff:Int):SwagSong
	{
		song = song.toLowerCase();
		var rawJson = Assets.getText('assets/songs-data/$song/$song${CoolUtil.diffString(diff, 0)}.json').trim();

		return parseJSON(rawJson);
	}

	public static inline function parseJSON(rawJson:String):SwagSong
	{
		return cast Json.parse(rawJson).song;
	}
}
