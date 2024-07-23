package backend;

using StringTools;

#if !debug @:noDebug #end
class Highscore
{
	private static var songScores:Map<String, Int>;

	public static inline function loadScores()
		songScores = SettingsManager.gSave.data.songScores != null ? SettingsManager.gSave.data.songScores : new Map<String, Int>();

	// just to make this look cleaner.
	public static inline function scoreExists(s:String):Int
	{
		s = s.toLowerCase().trim();
		return songScores.exists(s) ? songScores.get(s) : 0;
	}

	public static function saveScore(song:String, score:Int, diff:Int){
		var songNaem:String = song.toLowerCase().trim() + CoolUtil.diffString(diff, 0);

		if(scoreExists(songNaem) >= score) 
			return;

		songScores.set(songNaem, score);
		SettingsManager.gSave.data.songScores = songScores;
		SettingsManager.flush();
	}

	public static function getScore(song:String, diff:Int):Int
		return scoreExists(song + CoolUtil.diffString(diff, 0));
}
