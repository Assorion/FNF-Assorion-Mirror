package ui;

import flixel.graphics.FlxGraphic;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxG;

#if !debug @:noDebug #end
class NewTransition extends FlxSubState {
    public  static var activeTransition:NewTransition = null;
    private static var skippedLast:Bool;
    private static var existingGraphic:FlxGraphic;

    public var whiteSpr:FlxSprite;
    //public var mainCamera:FlxCamera;
    public var trIn:Bool;

    var pState:FlxState;

    public function new(pendingState:FlxState, transIn:Bool){
        super();

        trIn = transIn;
        pState = pendingState;
        activeTransition = transIn ? this : null;

        var mainCamera = FlxG.cameras.list[FlxG.cameras.list.length - 1];
        var z:Float = 1 / mainCamera.zoom;

        whiteSpr = new StaticSprite(0,0);
        if(existingGraphic == null){
            whiteSpr.makeGraphic(1280, 720, 0xFFFFFFFF);
            whiteSpr.graphic.persist = true;
            whiteSpr.graphic.destroyOnNoUse = false;

            existingGraphic = whiteSpr.graphic;
        }

        whiteSpr.scale.set(z, z);
        whiteSpr.loadGraphic(existingGraphic);
		whiteSpr.alpha = trIn ? 0 : 1;
        whiteSpr.camera = mainCamera;
        whiteSpr.scrollFactor.set();
		add(whiteSpr);

        if(!skippedLast) return;

        skip();
        whiteSpr.alpha = 0;
        skippedLast = false;
    }
    public function skip(){
        if(activeTransition == null) 
            return;

        skippedLast = true;
        whiteSpr.alpha = trIn ? 1 : 0;
        
        update(0);
    }

    override function update(elapsed:Float){
        whiteSpr.alpha += elapsed * (trIn ? 4 : -2);

        if(whiteSpr.alpha != (trIn ? 1 : 0)) return;

        close();
        activeTransition = null;

        if(trIn)
            FlxG.switchState(pState);
    }
}