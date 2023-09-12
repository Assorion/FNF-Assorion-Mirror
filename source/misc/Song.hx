package misc;

import haxe.Json;
import lime.utils.Assets;
import misc.CoolUtil;

using StringTools;

#if !debug @:noDebug #end
class Song
{
	public static function loadFromJson(song:String, diff:Int):SwagSong
	{
		song = song.toLowerCase();
		if(Settings.pr.cache_text && CoolUtil.cachedLines.exists(song))
			return parseJSON(CoolUtil.cachedLines.get(song)[0]);

		var rawJson = Assets.getText('assets/songs-data/$song/$song${CoolUtil.diffString(diff, 0)}.json').trim();
		if(Settings.pr.cache_text)
			CoolUtil.cachedLines.set(song, [rawJson]);

		return parseJSON(rawJson);
	}

	public static inline function parseJSON(rawJson:String):SwagSong
	{
		return cast Json.parse(rawJson).song;
	}
}
