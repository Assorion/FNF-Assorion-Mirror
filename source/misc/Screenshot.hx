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

/*
    TODO:
    Rework this a little to work in a Web-Browser.
    Also I need to fix colour and transparency.
*/

#if !debug @:noDebug #end
class Screenshot {
    public static inline function takeScreenshot(){
        #if desktop

        // Capture Gameplay.
        CoolUtil.newCanvas();
		for(gcam in FlxG.cameras.list)
		    CoolUtil.copyCameraToData(CoolUtil.canvas, gcam);

        // Encode it to raw bytes.
        var byteArray:ByteArray = new ByteArray();
        CoolUtil.canvas.encode(new Rectangle(0,0,1280,720), new openfl.display.PNGEncoderOptions(false), byteArray);
        byteArray.position = 0;

        // Convert OpenFLs byte array to Haxe's version which we can save.
        var haxeBytes:Bytes = Bytes.alloc(byteArray.length);
        for(i in 0...byteArray.length)
            haxeBytes.set(i, byteArray.readUnsignedByte());

        // Get the date, down to the second.
        var nDate:Date = Date.now();
        var dateStr:String = '' + nDate.getFullYear();
        var formatLoop:Array<Int> = [
            nDate.getMonth(),
            nDate.getDay(),
            nDate.getHours(),
            nDate.getMinutes(),
            nDate.getSeconds()
        ];

        // Format date.
        for(thing in formatLoop)
            dateStr += '-' + (thing < 10 ? '0$thing' : '$thing');

        // Save it.
        FileSystem.createDirectory("screenshots");
        File.saveBytes('screenshots/$dateStr.png', haxeBytes);

        #end
    }
}