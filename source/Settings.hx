package;

import haxe.Json;
import lime.utils.Assets;
import sys.io.File;
import flixel.FlxG;
import Highscore;

using StringTools;

typedef Options = {
    var start_fullscreen:Bool;
    var start_volume:Int;
    var skip_logo:Bool;

    var downscroll:Bool;
    var offset:Int;
    var botplay:Bool;
    var ghost_tapping:Bool;
    var miss_health:Int;

    var useful_info:Bool;
    var antialiasing:Bool;
    var show_hud:Bool;
    var framerate:Int;
    var light_bot_strums:Bool;
}

class Settings {
    /*
        This won't work in a web browser since a web browser can't save files.
        The best it will do is simply forget your settings each time.

        The scores will be handles by FlxG save so it won't forget those.
        I don't wan't to write terrible, repeating code.
        So this is the best I will do.
    */

    public static var pr:Options;
    public static function openSettings(){
        var text = Assets.getText('assets/songs&data/savedata.json').trim();
        pr = cast Json.parse(text);
    }
    public static function apply(){
        FlxG.save.bind('funkin', 'candicejoe');

        FlxG.updateFramerate = Settings.pr.framerate;
		FlxG.drawFramerate   = Settings.pr.framerate;

        Main.changeUsefulInfo(Settings.pr.useful_info);

        if(FlxG.save.data.songScores != null)
            Highscore.songScores = FlxG.save.data.songScores;
    }

    public static function flush(){
        var data:String = Json.stringify(pr);

        // # TODO actually make this run in a web browser.
        File.saveContent('assets/songs&data/savedata.json', data);
    }
}