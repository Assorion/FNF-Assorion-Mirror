package backend;

import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.FlxG;
import backend.Highscore;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSave;

using StringTools;

class Settings {
    public static var start_fullscreen:Bool = false;
    public static var start_volume:Int      = 100;
    public static var skip_splash:Bool      = false;
    public static var default_persist:Bool  = false;
    public static var pre_caching:Bool      = false;

    public static var downscroll:Bool       = true;
    public static var audio_offset:Int      = 75;
    public static var input_offset:Int      = 0;
    public static var botplay:Bool          = false;
    public static var ghost_tapping:Bool    = true;

    public static var useful_info:Bool      = true;
    public static var antialiasing:Bool     = true;
    public static var show_hud:Bool         = true;
    public static var framerate:Int         = 120;
}

#if !debug @:noDebug #end
class SettingsManager {
    public static var gSave:FlxSave;

    public static function openSettings(){
        gSave = new FlxSave();
        gSave.bind('funkin', 'candicejoe');

        var settingsMap:Map<String, Dynamic> = gSave.data.settingsMap == null ? new Map<String, Dynamic>() : gSave.data.settingsMap;
        var settingsItems:Array<String> = Type.getClassFields(Settings);

        for(key in settingsMap.keys())
            if(settingsItems.contains(key))
                Reflect.setField(Settings, key, settingsMap.get(key));

        Binds.loadControls(settingsMap);
        Highscore.loadScores();
    }
    
    public static function apply(){
        FlxGraphic.defaultPersist = Settings.default_persist;
	FlxSprite.defaultAntialiasing = Settings.antialiasing;
        FlxG.updateFramerate = FlxG.drawFramerate = framerateClamp(Settings.framerate);

        Main.changeUsefulInfo(Settings.useful_info);
        Paths.switchCacheOptions(Settings.default_persist);
    }

    public inline static function flush(){
        var settingsMap = new Map<String, Dynamic>();
        var settingsItems:Array<String> = Type.getClassFields(Settings);
        var bindsItems:Array<String>    = Type.getClassFields(Binds);

        for(settingItem in settingsItems)
            settingsMap.set(settingItem, Reflect.field(Settings, settingItem));

        for(bindItem in bindsItems){
            var item = Reflect.field(Binds, bindItem);

            if(Std.is(item, Array))
                settingsMap.set(bindItem, item);
        }

        /////////////////////////////////////

        gSave.data.settingsMap = settingsMap;
        gSave.flush();
    }

    // Though we clamp it as 340, the game will still update up to 500 FPS anyway.
    public static inline function framerateClamp(ch:Int):Int
        return CoolUtil.intBoundTo(ch, 10, 340);
}
