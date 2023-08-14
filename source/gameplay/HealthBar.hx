package gameplay;

import flixel.ui.FlxBar;

class HealthBar extends FlxBar
{
    public function new(x:Float = 0, y:Float = 0, direction:FlxBarFillDirection = RIGHT_TO_LEFT, width:Int = 100, height:Int = 10, min:Float = 0, max:Float = 100){
        super(x,y,direction,width,height,null,'',min,max,false);
    }

    override public function update(elasped:Float){
        // do nothing.
        // why?

        // Beacuse ususally this will use Reflect every single frame.
        //trace('s');
    }

    override function updateValueFromParent()
    {
        trace('NO!');
    }
}