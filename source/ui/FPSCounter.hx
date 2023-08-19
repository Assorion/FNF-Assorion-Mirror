package ui;

import flixel.FlxG;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Lib;
import openfl.system.System;

// this is a modified FPS class for SPEED!

class FPSCounter extends TextField {
    public var currentTime:Float = 0;
    public var framerate:Int = 0;

    public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFF){
        super();

        this.x = x;
        this.y = y;
        this.width = 100;
        this.maxChars = 10;

        selectable   = false;
        mouseEnabled = false;
        defaultTextFormat = new TextFormat("_sans", 13, color, null, null, null, text);
    }

    private override function __enterFrame(deltaTime:Float):Void
    {
        currentTime += deltaTime;
        framerate++;

        if(currentTime < 500) return;

        text = 'FPS: ${framerate * 2}';

        framerate = 0;
        currentTime = 0;
    }
}