package;

import flixel.FlxGame;
import flixel.FlxState;
import flixel.FlxG;
import openfl.Lib;
import openfl.display.Sprite;
import misc.FPSCounter;
import misc.MemCounter;

// tells haxe not to generate debugging info in the release build
// ofc if you compile it with debugging enabled it will still work
// but since this isn't very useful for release builds, we're gonna add this flag.

#if !debug
@:noDebug
#end
class Main extends Sprite
{
	public static var fpsC:FPSCounter;
	public static var memC:MemCounter;

	// inlined. Which means these variables cannot be changed later.
	public static inline var initState:Class<FlxState> = ui.TitleState;
	public static inline var gameWidth:Int  = 1280;
	public static inline var gameHeight:Int = 720;
	public static inline var initFPS:Int = 60;

	public static function changeUsefulInfo(yes:Bool){
		fpsC.visible =
		memC.visible = yes;
	}

	public function new()
	{
		super();

		var zoom = ((Lib.current.stage.stageWidth / gameWidth) + (Lib.current.stage.stageHeight / gameHeight)) / 2;

		Settings.openSettings();

		// # add the game

		var ldState:Class<FlxState> = initState;
		if(Settings.pr.launch_sprites)
			#if desktop 
			ldState = ui.LoadingState; 
			#else 
			trace('CACHING DOES NOT WORK IN BROWSER!'); 
			#end

		fpsC = new FPSCounter(10, 3, 0xFFFFFF);
		memC = new MemCounter(10, 18, 0xFFFFFF);
		addChild(new FlxGame(gameWidth, gameHeight, ldState, 
			#if (flixel < "5.0.0") zoom, #end 
			initFPS, initFPS, Settings.pr.skip_logo, Settings.pr.start_fullscreen));

		addChild(fpsC);
		addChild(memC);

		#if (!desktop)
		// web browser keyboard fix. Keys like the spacebar won't work in a browser without this.
		FlxG.keys.preventDefaultKeys = [];
		Settings.pr.framerate = 60;
		#end
		
		// have to give credit for psych engine here.
		// Wouldn't have cared enough to fix this on my own.
		#if linux
		Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile("assets/images/icon.png"));
		#end
		
		Settings.apply();
	}
}