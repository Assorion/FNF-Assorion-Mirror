package misc;

import misc.Settings;
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.FlxSprite;
#if desktop
import sys.FileSystem;
#end
import flixel.addons.ui.FlxUIState;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;

using StringTools;

// YAY IT NO LONGER SUCKS!!!

#if !debug @:noDebug #end
class AssetCacher {
    public static var objects:Array<String> = [];

    private static function cacheDir(path:String){
        var keepDirectories:Array<String> = [];
        var itemsInDir:Array<String> = FileSystem.readDirectory(path);

        for(i in 0...itemsInDir.length){
            var curItem:String = path + itemsInDir[i];

            if(FileSystem.isDirectory(curItem)){
                keepDirectories.push(curItem + '/');
                continue;
            }
            if(!Assets.exists(curItem)) continue;

            objects.push(curItem);
        }
        for(i in 0...keepDirectories.length)
            cacheDir(keepDirectories[i]);
    }

    private static inline function addAsset(objectPath:String, objFormat:String, parent:FlxUIState)
        switch(objFormat){
            case 'png':
                var tmpImg:FlxSprite = new FlxSprite(0,0).loadGraphic(objectPath);
                    tmpImg.graphic.persist = true;
                    tmpImg.graphic.destroyOnNoUse = false;
                parent.add(tmpImg);
                parent.remove(tmpImg);
            case 'xml':
                var tmpImg:FlxSprite = new FlxSprite(0,0);
                    tmpImg.frames = Paths.lSparrow(objectPath.substring(0, objectPath.length - 4), '');
                    tmpImg.graphic.persist = true;
                    tmpImg.graphic.destroyOnNoUse = false;
                parent.add(tmpImg);
                parent.remove(tmpImg);
            
            // since web browser doesn't work, we can just use this
            case 'ogg':
                var sound:FlxSound = new FlxSound().loadEmbedded(objectPath);
                    sound.play();
                    sound.stop();
            case 'txt', 'json':
                Paths.cLT(objectPath, '');
        }

    public static function loadAssets(parent:FlxUIState){
        cacheDir('assets/');

        for(obj in objects){
            trace('Caching: $obj');

            // in case somehow it has multiple dots
            var tmp = obj.split('.');
            var ending:String = tmp[tmp.length - 1];

            addAsset(obj, ending, parent);
        }
        objects = null;
    }
}