package misc;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import lime.utils.Assets;

// HECK YEA WE RE-DOIN THIS

#if !debug @:noDebug #end
class Paths {
    public static inline var sndExt:String = #if desktop 'ogg' #else 'mp3' #end;

    public static inline var menuMusic:String = 'freakyMenu';
	public static inline var menuTempo:Int = 102;

    // btw the 'l' in every single function was meant to stand for "load".

    public static var lSparrow:String->FlxFramesCollection = ncLS;
    public static var lText:String->?String->String = ncLT;

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

    /*
        It's cachin' time!
    */

    public static inline function clearCache(){
        if(Settings.pr.default_persist || Settings.pr.launch_sprites || Settings.pr.cache_misc) return;

		Assets.cache.clear();
        CoolUtil.cachedFrames.clear();
        CoolUtil.cachedLines.clear();

    }

    public static function cLS(path:String):FlxFramesCollection
    {
        var tmp:FlxFramesCollection = CoolUtil.cachedFrames.get(path);

        if(tmp != null) return tmp;

        var fStr = 'assets/images/$path';

        tmp = FlxAtlasFrames.fromSparrow('$fStr.png', '$fStr.xml');
        CoolUtil.cachedFrames.set(path, tmp);

        return tmp;
    }
    public static function cLT(path:String, ?prePath:String = 'assets/songs-data/'):String
    {
        var tmp:Array<String> = CoolUtil.cachedLines.get(path);

        if(tmp != null) return tmp[0];

        tmp = [Assets.getText(prePath + path)];
        CoolUtil.cachedLines.set(path, tmp);

        return tmp[0];
    }

    public static function ncLS(path:String):FlxFramesCollection
        return FlxAtlasFrames.fromSparrow('assets/images/$path.png', 'assets/images/$path.xml');

    public static function ncLT(path:String, ?prePath:String = 'assets/songs-data/'):String
        return Assets.getText(prePath + path);
}