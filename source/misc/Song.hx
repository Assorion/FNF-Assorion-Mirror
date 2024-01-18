package misc;

import haxe.macro.Expr.TypePath;
import haxe.Json;
import lime.utils.Assets;
import misc.CoolUtil;

using StringTools;

// Song now also acts as a Conductor Replacement.

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var cameraFacing:Int;
}

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var playLength:Int;
	var characters:Array<String>;
	var activePlayer:Int;
	var stage:String;
	var beginTime:Float;
}

typedef MusicProperties = {
	var bpm         :Float; // How fast the music is.
	var crochet     :Float; // BPM but in miliseconds.
	var stepCrochet :Float; // BPM Divided in 4
	var songPosition:Float; // Milisecond point in the song.
	var songDiv     :Float; // A multiplier from stepCrochet.
}

#if !debug @:noDebug #end
class Song
{
	public static var curMus:MusicProperties;

	public static function musicSet(BPM:Float)
	{
		var nsCrochet = (60 / BPM) * 250;

		curMus = {
			bpm: BPM,
			crochet:     nsCrochet * 4,
			stepCrochet: nsCrochet,
			songPosition: -Settings.pr.audio_offset,
			songDiv: 1 / nsCrochet
		};
	}

	public static function loadFromJson(songStr:String, diff:Int):SwagSong
	{
		songStr = songStr.toLowerCase();
		
		var tmpCast:SwagSong = cast Json.parse(Paths.lText('$songStr/$songStr${CoolUtil.diffString(diff, 0)}.json')).song;

		if (cast(tmpCast.playLength, Int) <= 0) 
			tmpCast.playLength = 2;

		return tmpCast;
	}
}
