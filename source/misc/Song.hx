package misc;

import haxe.macro.Expr.TypePath;
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
	var bpm:Float;
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
	public static function loadFromJson(songStr:String, diff:Int):SwagSong
	{
		songStr = songStr.toLowerCase();
		
		var tmpCast:SwagSong = cast Json.parse(Paths.lText('$songStr/$songStr${CoolUtil.diffString(diff, 0)}.json')).song;

		if (cast(tmpCast.playLength, Int) <= 0) 
			tmpCast.playLength = 2;

		return tmpCast;
	}
}
