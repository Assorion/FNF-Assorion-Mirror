package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import lime.utils.Assets;

using StringTools;

#if !debug @:noDebug #end
class Paths {
	public static inline var sndExt:String = #if desktop 'ogg' #else 'mp3' #end;
	public static inline var menuMusic:String = 'freakyMenu';
	public static inline var menuTempo:Int = 102;

    	private static var cachedLines:Map<String, Array<String>>        = new Map<String, Array<String>>();
		private static var cachedFrames:Map<String, FlxFramesCollection> = new Map<String, FlxFramesCollection>();

    	// btw the 'l' in every single function was meant to stand for "load".
    
    	public static var lSparrow:String->?String->FlxFramesCollection = nonCachedLSparrow;
    	public static var lText   :String->?String->String              = nonCachedLText;
    	public static var lLines  :String->?String->Array<String>       = nonCachedLLines;

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
        	var endingStr:String = retVoices ? 'voices.$sndExt' : 'inst.$sndExt';
        	return 'assets/songs-data/${path.toLowerCase()}/$endingStr';
    	}

    	/*
        	It's cachin' time!
    	*/

    	public static inline function clearCache(){
        	if(Settings.default_persist || Settings.pre_caching) 
            	return;
	
			Assets.cache.clear();
        	openfl.utils.Assets.cache.clear();
        	cachedFrames.clear();
        	cachedLines.clear();
    	}

    	public static function switchCacheOptions(on:Bool)
		if(on){
        		lSparrow = cachedLSparrow;
        		lText    = cachedLText;
        		lLines   = cachedLLines;
		} else {
        		lSparrow = nonCachedLSparrow;
        		lText    = nonCachedLText;
        		lLines   = nonCachedLLines;
    		}

    	// Removes MS Window's crappy "newline" system. This only effects txt files, Json files don't require this.
    	private static inline function removeBlackSpace(input:Array<String>):Array<String> {
        	var i:Int = 0;
	
        	while(i < input.length)
            		if (input[i++] == '')
                		input.splice(--i, 1);
	
        	return input;
    	}

    	// These functions should NOT be called directly. Everything below here is not supposed to be called by a reference at the top.

    	private static function cachedLSparrow(path:String, ?prePath:String = 'assets/images/'):FlxFramesCollection
    	{
        	var tmp:FlxFramesCollection = cachedFrames.get(path);
	
        	if(tmp != null) 
            		return tmp;
	
        	var fStr = '$prePath$path';
	
        	tmp = FlxAtlasFrames.fromSparrow('$fStr.png', '$fStr.xml');
        	cachedFrames.set(path, tmp);
	
        	return tmp;
    	}
    	private static function cachedLText(path:String, ?prePath:String = 'assets/songs-data/'):String
    	{
        	var tmp:Array<String> = cachedLines.get(path);
	
        	if(tmp != null) 
            		return tmp[0];
	
        	tmp = [Assets.getText(prePath + path).replace('\r', '')];
        	cachedLines.set(path, tmp);
	
        	return tmp[0];
    	}
    	private static function cachedLLines(path:String, ?ext:String = 'txt'):Array<String>
    	{
        	var tmp:Array<String> = cachedLines.get(path);
	
        	if(tmp != null) 
            		return tmp;
	
        	tmp = removeBlackSpace(Paths.lText('$path.$ext').replace('\r', '').split('\n'));
        	cachedLines.set(path, tmp);
	
        	return tmp;
    	}
	
    	private static function nonCachedLLines(path:String, ?ext:String = 'txt'):Array<String>
        	return removeBlackSpace(Paths.lText('$path.$ext').replace('\r', '').split('\n'));
	
    	private static function nonCachedLSparrow(path:String, ?prePath:String = 'assets/images/'):FlxFramesCollection
        	return FlxAtlasFrames.fromSparrow('$prePath$path.png', '$prePath$path.xml');
	
    	private static function nonCachedLText(path:String, ?prePath:String = 'assets/songs-data/'):String
        	return Assets.getText(prePath + path).replace('\r', '');

    	/////////////////////////////////////////////////////////////
}
