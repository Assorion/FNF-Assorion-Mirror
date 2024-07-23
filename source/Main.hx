package;

import openfl.Lib;
import openfl.display.Sprite;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxG;
import frontend.FPSCounter;
import frontend.MemCounter;
import backend.Settings;

#if !debug
@:noDebug
#end
class Main extends Sprite
{
	private static var fpsC:FPSCounter;
	private static var memC:MemCounter;

	public static inline var initState:Class<FlxState> = frontend.TitleState;
	public static inline var gameWidth:Int  = 1280;
	public static inline var gameHeight:Int = 720;

	public static function changeUsefulInfo(on:Bool)
		fpsC.visible = memC.visible = on;

	public function new()
	{
		super();
		
		SettingsManager.openSettings();

		// # add the game

		var ldState:Class<FlxState> = Settings.pre_caching #if (!desktop) && false #end ? frontend.LoadingState : initState;

		addChild(new FlxGame(
			gameWidth, 
			gameHeight, 
			ldState, 
			#if (flixel < "5.0.0") 1, #end 
			Settings.framerate, 
			Settings.framerate, 
		    Settings.skip_splash, 
			Settings.start_fullscreen
		));

		fpsC = new FPSCounter(10, 3, 0xFFFFFF);
		memC = new MemCounter(10, 18, 0xFFFFFF);

		addChild(fpsC);
		addChild(memC);

		#if (!desktop)
		// web browser keyboard fix. Keys like the spacebar won't work in a browser without this.
		FlxG.keys.preventDefaultKeys = [];
		Settings.framerate = 60;
		#end
		
		// I have to give credit to Psych Engine here.
		// Wouldn't have cared enough to fix this on my own.
		#if linux
		Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("assets/images/icon.png"));
		#end
		
		SettingsManager.apply();
		FlxG.mouse.visible = false;
	}
}