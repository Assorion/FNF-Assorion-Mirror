package misc;

import flixel.graphics.frames.FlxAtlasFrames;

// HECK YEA WE RE-DOIN THIS

#if !debug @:noDebug #end
class Paths {
    public static inline var sndExt:String = #if desktop 'ogg' #else 'mp3' #end;

    public static inline var menuMusic:String = 'freakyMenu';
	public static inline var menuTempo:Int = 102;

    // btw the 'l' in every single function was meant to stand for "load".
    public static inline function lSparrow(path:String):FlxAtlasFrames
    {
        return FlxAtlasFrames.fromSparrow('assets/images/$path.png', 'assets/images/$path.xml');
    }
    public static inline function lImage(path:String):String
    {
        return 'assets/images/$path.png';
    }
    public static inline function lMusic(path:String):String
    {
        return 'assets/music/$path.$sndExt';
    }
    public static inline function lSound(path:String):String
    {
        return 'assets/sounds/$path.$sndExt';
    }
    public static inline function playableSong(path:String, retVoices:Bool = false):String
    {
        var endingStr:String = retVoices ? 'Voices.$sndExt' : 'Inst.$sndExt';
        return 'assets/songs-data/${path.toLowerCase()}/$endingStr';
    }

}