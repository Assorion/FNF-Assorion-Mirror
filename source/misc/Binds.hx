package misc;

#if !debug @:noDebug #end
class Binds {
    // to be clear this is just for storing binds.
    // the checks HAVE to be implemented in the state itself.

    public static var NOTE_LEFT :Array<Int> = [];
    public static var NOTE_DOWN :Array<Int> = [];
    public static var NOTE_UP   :Array<Int> = [];
    public static var NOTE_RIGHT:Array<Int> = [];

    public static var UI_L:Array<Int> = [];
    public static var UI_R:Array<Int> = [];
    public static var UI_U:Array<Int> = [];
    public static var UI_D:Array<Int> = [];

    public static var UI_ACCEPT:Array<Int> = [];
    public static var UI_BACK:Array<Int>   = [];

    // # Used in settings.

    public inline static function updateControls(){
        NOTE_LEFT  = Settings.pr.note_left;
        NOTE_DOWN  = Settings.pr.note_down;
        NOTE_UP    = Settings.pr.note_up;
        NOTE_RIGHT = Settings.pr.note_right;
        UI_L       = Settings.pr.ui_left;
        UI_D       = Settings.pr.ui_down;
        UI_U       = Settings.pr.ui_up;
        UI_R       = Settings.pr.ui_right;
        UI_ACCEPT  = Settings.pr.ui_accept;
        UI_BACK    = Settings.pr.ui_back;
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
        for(i in 0...array.length){
            if(key == array[i][0] || key == array[i][1])
                return i;
        }

        return -1;
    }
}