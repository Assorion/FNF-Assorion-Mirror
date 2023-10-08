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

/**
    This kinda sucks.
**/

#if !debug @:noDebug #end
class AssetCacher {
    public static function loadAssets(parent:FlxUIState){
        #if desktop
        var paths:Array<String> = [];
        var curDepth:String = 'assets/';
        var curPaths:Array<String> = FileSystem.readDirectory(curDepth);
        var ignoreDirectories:Array<String> = [];
        var i:Int = 0;
        // loop through every singe file / direcotry
        while(i < curPaths.length){
            if(!ignoreDirectories.contains(curDepth + curPaths[i] + '/'))
                if(FileSystem.isDirectory(curDepth + curPaths[i])){
                    curDepth = curDepth + curPaths[i] + '/';
                    curPaths = FileSystem.readDirectory(curDepth);
                    i = -1;
                } else 
                    paths.push(curDepth + curPaths[i]);
    
            if(i == curPaths.length - 1){
                ignoreDirectories.push(curDepth);
                var depthCrap:Array<String> = curDepth.split('/');
                curDepth = '';
                for(i in 0...depthCrap.length-2)
                    curDepth += depthCrap[i] + '/';
                if(curDepth == '')
                    break;
                curPaths = FileSystem.readDirectory(curDepth);
                i = -1;
            }
            i++;
        }
        // for each file cache them.
        for(i in 0...paths.length){
            var tidalWave:Bool = false;
            if(!Assets.exists(paths[i])) continue;

            if (paths[i].endsWith('png')){
                var tmpImg:FlxSprite = new FlxSprite(0,0).loadGraphic(paths[i]);
                tmpImg.graphic.persist = true;
                tmpImg.graphic.destroyOnNoUse = false;
                parent.add(tmpImg);
                parent.remove(tmpImg);
                tidalWave = true;
            }
            if (paths[i].endsWith('xml')){
                var rawName:String = paths[i].split('.')[0];
                var tmpImg:FlxSprite = new FlxSprite(0,0);
                tmpImg.frames = FlxAtlasFrames.fromSparrow(rawName + '.png', rawName + '.xml');
                tmpImg.graphic.persist = true;
                tmpImg.graphic.destroyOnNoUse = false;
                parent.add(tmpImg);
                parent.remove(tmpImg);
                tidalWave = true;
            }
            if(paths[i].endsWith(Paths.sndExt)){
                var sound:FlxSound = new FlxSound().loadEmbedded(paths[i]);
                sound.play();
                sound.stop();
                tidalWave = true;
            }
            if(paths[i].endsWith('txt')){
                var fullText = Assets.getText(paths[i]).split('\n');
                var storePath:String = '';
                var splitPath:Array<String> = paths[i].split('/');
                for(i in 0...splitPath.length)
                    if(i > 1) storePath += splitPath[i] + '/';

                storePath = storePath.split('.')[0];
                misc.CoolUtil.cachedLines.set(storePath, fullText);
                tidalWave = true;
            }
            if(paths[i].endsWith('json')){
                var rawJson = Assets.getText(paths[i]);
                misc.CoolUtil.cachedLines.set(paths[i].split('/')[2].toLowerCase(), [rawJson]);
                tidalWave = true;
            }
            if(tidalWave)
                trace(paths[i]);
        }
        #end
    }
}