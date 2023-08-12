package;

import flixel.FlxG;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Lib;
import openfl.system.System;

class MemCounter extends TextField {
    // public var text:String = '';

	public function new(x:Float = 10, y:Float = 10, color:Int = 0xFFFFFF){
		//super(x,y,color,'',false);
        super();

        this.x = x;
        this.y = y;
        this.width = 100;
        this.maxChars = 20;

        selectable   = false;
        mouseEnabled = false;
        defaultTextFormat = new TextFormat("_sans", 13, color, null, null, null, text);
	}

	private override function __enterFrame(deltaTime:Float):Void
	{
		text = 'MEM: ${Math.round(System.totalMemory / 1024 / 1024)} (MB)';
	}
}