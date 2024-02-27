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

        if(!skippedLast) 
            return;

        skippedLast = false;
        whiteSpr.alpha = 0;
    }

    // # Two helper functions, you can change these if needed.

    public inline function transInComplete(){
        close();
        activeTransition = null;
        FlxG.switchState(pState);
    }
    public inline function transOutComplete()
        close();

    override function update(elapsed:Float){
        whiteSpr.alpha += elapsed * (trIn ? 4 : -2);

        if(whiteSpr.alpha != (trIn ? 1 : 0)) 
            return;

        trIn ? transInComplete() : transOutComplete();
    }

    /////////////////////////////////

    public static function skip():Bool
    {
        if(activeTransition == null) 
            return false;

        skippedLast = true;
        activeTransition.transInComplete();
        return true;
    }

    public static function switchState(target:FlxState){
        activeTransition = new NewTransition(target, true);

        FlxG.state.openSubState(activeTransition);
        FlxG.state.persistentUpdate = false;
    }
}