package backend;

import flixel.input.keyboard.FlxKey;

/*
    A simple helper class for storing binds and checking them.
*/

#if !debug @:noDebug #end
class Binds {
    // To be clear this is just for storing binds.
    // The checks HAVE to be implemented by the state itself.

    public static var NOTE_LEFT :Array<Int> = [FlxKey.A, FlxKey.LEFT];
    public static var NOTE_DOWN :Array<Int> = [FlxKey.S, FlxKey.DOWN];
    public static var NOTE_UP   :Array<Int> = [FlxKey.W, FlxKey.UP];
    public static var NOTE_RIGHT:Array<Int> = [FlxKey.D, FlxKey.RIGHT];

    public static var UI_LEFT :Array<Int> = [FlxKey.A, FlxKey.LEFT];
    public static var UI_RIGHT:Array<Int> = [FlxKey.D, FlxKey.RIGHT];
    public static var UI_UP   :Array<Int> = [FlxKey.W, FlxKey.UP];
    public static var UI_DOWN :Array<Int> = [FlxKey.S, FlxKey.DOWN];

    public static var UI_ACCEPT:Array<Int> = [FlxKey.ENTER, FlxKey.SPACE];
    public static var UI_BACK:Array<Int>   = [FlxKey.ESCAPE, FlxKey.BACKSPACE];

    // # Load all the binds from settings

    public inline static function loadControls(map:Map<String, Dynamic>){
        var bindsItems:Array<String> = Type.getClassFields(Binds);

        for(key in map.keys())
            if(bindsItems.contains(key))
                Reflect.setField(Binds, key, map.get(key));
    }

    // # for checking only 2 binds.
    
    public static function hardCheck(key:Int, array:Array<Int>):Bool
    {
        if(key == array[0] || key == array[1])
            return true;

        return false;
    }

    // # checks multiple binds, and returns the bind index.

    public static function deepCheck(key:Int, array:Array<Array<Int>>):Int
    {
        for(i in 0...array.length)
            if(key == array[i][0] || key == array[i][1])
                return i;

        return -1;
    }
}
