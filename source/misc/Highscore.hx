package misc;

using StringTools;

#if !debug @:noDebug #end
class Highscore
{
	#if (haxe >= "4.0.0")
	public static var songScores:Map<String, Int> = new Map();
	#else
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	#end

	// just to make this look cleaner.
	public static inline function scoreExists(s:String):Int
	{
		s = s.toLowerCase().trim();
		return songScores.exists(s) ? songScores.get(s) : 0;
	}

	public static function saveScore(song:String, score:Int, diff:Int){
		var songNaem:String = song.toLowerCase().trim() + CoolUtil.diffString(diff, 0);

		trace(songNaem);

		if(scoreExists(songNaem) >= score) return;

		songScores.set(songNaem, score);
		Settings.gSave.data.songScores = songScores;
		Settings.flush();
	}

	public static function getScore(song:String, diff:Int):Int
	{
		return scoreExists(song + CoolUtil.diffString(diff, 0));
	}
}
