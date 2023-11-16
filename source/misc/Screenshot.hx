package misc;

import lime.graphics.Image;
import lime.ui.FileDialog;
import openfl.display.BitmapData;
import openfl.utils.ByteArray;
import openfl.geom.Rectangle;
#if desktop
import sys.io.File;
import sys.FileSystem;
#end
import haxe.io.Bytes;
import flixel.FlxG;
import gameplay.PauseSubState;

#if !debug @:noDebug #end
class Screenshot {
    public static inline function takeScreenshot(){
        #if desktop
        PauseSubState.newCanvas();
		for(gcam in FlxG.cameras.list)
		    CoolUtil.copyCameraToData(PauseSubState.bdat, gcam);

        var byteArray:ByteArray = new ByteArray();
        PauseSubState.bdat.encode(new Rectangle(0,0,1280,720), new openfl.display.PNGEncoderOptions(false), byteArray);
        byteArray.position = 0;

        var haxeBytes:Bytes = Bytes.alloc(byteArray.length);
        for(i in 0...byteArray.length){
            haxeBytes.set(i, byteArray.readUnsignedByte());
            byteArray.position--;

            // error checking
            var b1:Int = haxeBytes.get(i);
            var b2:Int = byteArray.readUnsignedByte();
            if(b1 != b2){
                trace('ERROR');
                trace('$b1 != $b2');
            }
        }

        var nDate:Date = Date.now();
        var dateStr:String = ''+ nDate.getFullYear();
        var formatLoop:Array<Int> = [
            nDate.getMonth(),
            nDate.getDay(),
            nDate.getHours(),
            nDate.getMinutes(),
            nDate.getSeconds()
        ];

        for(thing in formatLoop)
            dateStr += '-' + (thing < 10 ? '0$thing' : '$thing');

        FileSystem.createDirectory("screenshots");
        File.saveBytes('screenshots/$dateStr.png', haxeBytes);
        #end
    }
}