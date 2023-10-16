package gameplay;

import flixel.ui.FlxBar;

#if !debug @:noDebug #end
class HealthBar extends FlxBar
{
    public function new(x:Float = 0, y:Float = 0, direction:FlxBarFillDirection = RIGHT_TO_LEFT, width:Int = 100, height:Int = 10, min:Float = 0, max:Float = 100){
        super(x,y,direction,width,height,null,'',min,max,false);
        active = false;
    }

    override public function update(elasped:Float){
        /*
            Reflection is used to get literal values from string names.
            However it is very ineffecient and should only be used when necessary.

            And the issue with FlxBar is that it uses this every frame.

            Thus, this class does nothing more than remove that. The percentage needs -
            to be updated manually. Which is how it should've been.
        */
    }

    override function updateValueFromParent() {}
}