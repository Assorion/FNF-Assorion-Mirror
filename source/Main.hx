package;

import openfl.Lib;
import openfl.display.Sprite;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxG;
import misc.FPSCounter;
import misc.MemCounter;

#if !debug
@:noDebug
#end
class Main extends Sprite
{
	public static var framerateDivision:Float = 1;

	private static var fpsC:FPSCounter;
	private static var memC:MemCounter;

	public static inline var initState:Class<FlxState> = ui.TitleState;
	public static inline var gameWidth:Int  = 1280;
	public static inline var gameHeight:Int = 720;

	public static function changeUsefulInfo(on:Bool)
		fpsC.visible = memC.visible = on;

	public function new()
	{
		super();
		
		Settings.openSettings();

		// # add the game

		var ldState:Class<FlxState> = 
		#if desktop 
		Settings.pr.launch_sprites ? ui.LoadingState : initState;
		#else 
		initState;
		#end

		fpsC = new FPSCounter(10, 3, 0xFFFFFF);
		memC = new MemCounter(10, 18, 0xFFFFFF);

		addChild(new FlxGame(
			gameWidth, 
			gameHeight, 
			ldState, 
			#if (flixel < "5.0.0") 1, #end 
			Settings.pr.framerate, 
			Settings.pr.framerate, 
			Settings.pr.skip_logo, 
			Settings.pr.start_fullscreen
		));

		addChild(fpsC);
		addChild(memC);

		#if (!desktop)
		// web browser keyboard fix. Keys like the spacebar won't work in a browser without this.
		FlxG.keys.preventDefaultKeys = [];
		Settings.pr.framerate = 60;
		#end
		
		// I have to give credit to Psych Engine here.
		// Wouldn't have cared enough to fix this on my own.
		#if linux
		Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("assets/images/icon.png"));
		#end
		
		Settings.apply();
		FlxG.mouse.visible = false;
	}
}