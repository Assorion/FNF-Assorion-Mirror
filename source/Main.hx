package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import Settings;

class Main extends Sprite
{
	public static var fpsC:FPS;
	public static var memC:MemCounter;

	// inlined. Which means these variables cannot be changed later.
	public static inline var gameWidth:Int  = 1280;
	public static inline var gameHeight:Int = 720;
	public static inline var initState:Class<FlxState> = TitleState;
	public static inline var initFPS:Int = 60;

	public static function changeUsefulInfo(yes:Bool){
		fpsC.visible = yes;
		memC.visible = yes;
	}

	public function new()
	{
		super();

		var zoom = ((Lib.current.stage.stageWidth / gameWidth) + (Lib.current.stage.stageHeight / gameHeight)) / 2;
	
		Settings.openSettings();

		// # add the game

		addChild(new FlxGame(gameWidth, gameHeight, initState, 
			#if (flixel < "5.0.0") zoom, #end 
			initFPS, initFPS, Settings.pr.skip_logo, false));
		
		fpsC = new FPS(10, 3, 0xFFFFFF);
		memC = new MemCounter(10, 18, 0xFFFFFF);
		addChild(fpsC);
		addChild(memC);

		Settings.apply();
	}
}
