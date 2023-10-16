package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/*
    Honestly the performance impact is minimal.
    But I want the engine's logic to be compact.

    And most sprites don't need updates.
*/

class StaticSprite extends FlxSprite {
    public function new(?x:Float = 0, ?y:Float = 0 ){
        super(x,y,null);

        active = false;
    }
    override public function update(elasped){
        /*
            Most sprites are static and don't
            Need update functions.

            As Such I am creating this class to help with that.
        */
    }
    override public function loadGraphic(graphic:FlxGraphicAsset, animated = false, frameWidth = 0, frameHeight = 0, unique = false, ?key:String):StaticSprite
    {
        super.loadGraphic(graphic, animated, frameWidth, frameHeight, unique, key);
        return this;
    }
    override public function makeGraphic(Width:Int, Height:Int, Color:Int = 0xFFFFFFFF, Unique:Bool = false, ?Key:String):StaticSprite
    {
        super.makeGraphic(Width, Height, Color, Unique, Key);
        return this;
    }
}