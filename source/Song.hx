package;

import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
}

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var sections:Int;
	var sectionLengths:Array<Dynamic>;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var player3:String;
	var validScore:Bool;
	var stage:String;
	var beginTime:Float;
}

class Song
{
	/*public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var sections:Int;
	public var sectionLengths:Array<Dynamic> = [];
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var 

	public function new(song, notes, bpm, sections)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
		this.sections = sections;

		for (i in 0...notes.length)
		{
			this.sectionLengths.push(notes[i]);
		}
	}*/

	public static function loadFromJson(song:String, diff:Int):SwagSong
	{
		song = song.toLowerCase();
		var rawJson = Assets.getText('assets/songs&data/$song/$song${CoolUtil.diffString(diff, 0)}.json').trim();

		/*while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}*/

		return parseJSON(rawJson);
	}

	public static inline function parseJSON(rawJson:String):SwagSong
	{
		var bruh:SwagSong = cast Json.parse(rawJson).song;
		bruh.validScore = true;
		return bruh;
	}
}
