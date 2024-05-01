package misc;

import haxe.macro.Expr.TypePath;
import haxe.Json;
import lime.utils.Assets;
import misc.CoolUtil;

using StringTools;

// Song now also acts as a Conductor Replacement.

typedef SectionData =
{
	var sectionNotes:Array<Dynamic>;
	var cameraFacing:Int;
}

typedef SongData =
{
	var song:String;
	var notes:Array<SectionData>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var playLength:Int;
	var characters:Array<String>;
	var activePlayer:Int;
	var renderBackwards:Bool;

	var stage:String;
	var beginTime:Float;
}

#if !debug @:noDebug #end
class Song
{
	public static var BPM        :Float;
	public static var Crochet    :Float;
	public static var StepCrochet:Float;
	public static var Position   :Float;
	public static var Division   :Float;

	public static inline function musicSet(tempo:Float)
	{
		var newCrochet = (60 / tempo) * 250;

		BPM         = tempo;
		Crochet     = newCrochet * 4;
		StepCrochet = newCrochet;
		Position    = -Settings.pr.audio_offset;
		Division    = 1 / newCrochet;
	}

	public static function loadFromJson(songStr:String, diff:Int):SongData
	{
		songStr = songStr.toLowerCase();
		
		var tmpCast:SongData = cast Json.parse(Paths.lText('$songStr/${CoolUtil.diffString(diff, 0)}.json')).song;

		if (cast(tmpCast.playLength, Int) <= 0) 
			tmpCast.playLength = 2;

		return tmpCast;
	}
}
