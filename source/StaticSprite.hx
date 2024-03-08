package;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

// No this probably doesn't help with performance much, but it is still helpful as Antialiasing is set properly.

class StaticSprite extends FlxSprite {
    public function new(?x:Float = 0, ?y:Float = 0 ){
        super(x,y,null);

        active = false;
        antialiasing = Settings.pr.antialiasing;
    }
    override public function update(elasped){

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