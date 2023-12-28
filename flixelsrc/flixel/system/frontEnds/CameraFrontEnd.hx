package flixel.system.frontEnds;

import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;

using flixel.util.FlxArrayUtil;

#if !debug @:noDebug #end
class CameraFrontEnd
{
	#if !desktop
	public var useBufferLocking:Bool = false;
	#end

	public var list(default, null):Array<FlxCamera> = [];
	var defaults:Array<FlxCamera> = [];

	public var bgColor(get, set):FlxColor;

	public var cameraAdded(default, null):FlxTypedSignal<FlxCamera->Void> = new FlxTypedSignal<FlxCamera->Void>();
	public var cameraRemoved(default, null):FlxTypedSignal<FlxCamera->Void> = new FlxTypedSignal<FlxCamera->Void>();
	public var cameraResized(default, null):FlxTypedSignal<FlxCamera->Void> = new FlxTypedSignal<FlxCamera->Void>();
	
	var _cameraRect:Rectangle = new Rectangle();

	/*
		Tiny helper functions.
	*/

	public function findCameraIndex(camera:FlxCamera):Int
	{
		if(camera == null) return -1;

		for(i in 0...list.length)
			if(list[i] == camera) return i;

		return -1;
	}
	public inline function cameraUseCheck(camera:FlxCamera):Bool
		return camera == null || !camera.exists || !camera.visible;

	public function add<T:FlxCamera>(NewCamera:T, DefaultDrawTarget:Bool = true):T
	{
		FlxG.game.addChildAt(NewCamera.flashSprite, FlxG.game.getChildIndex(FlxG.game._inputContainer));
		NewCamera.ID = list.length;

		if (DefaultDrawTarget)
			defaults.push(NewCamera);
		
		list.push(NewCamera);
		cameraAdded.dispatch(NewCamera);

		return NewCamera;
	}

	public function remove(Camera:FlxCamera, Destroy:Bool = true):Void
	{
		var index = findCameraIndex(Camera);
		if(index == -1) return;

		FlxG.game.removeChild(Camera.flashSprite);

		list.splice(index, 1);
		defaults.remove(Camera);

		for (i in index...list.length)
			list[i].ID = i;

		if (Destroy)
			Camera.destroy();

		cameraRemoved.dispatch(Camera);
	}
	
	public function setDefaultDrawTarget(camera:FlxCamera, value:Bool)
	{
		var index = findCameraIndex(camera);
		if(index == -1) return;
		
		if (value){
			defaults.push(camera);
			return;
		}
		defaults.splice(index, 1);
	}

	public function reset(?NewCamera:FlxCamera):Void
	{
		for(i in 0...list.length)
			remove(list[0]);

		if (NewCamera == null)
			NewCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);

		FlxG.camera = add(NewCamera);
		FlxCamera._defaultCameras = defaults;

		NewCamera.ID = 0;
	}

	//////////////////////////

	public inline function flash(Color:FlxColor = FlxColor.WHITE, Duration:Float = 1, ?OnComplete:Void->Void, Force:Bool = false):Void
		for (i in 0...list.length)
			list[i].flash(Color, Duration, OnComplete, Force);

	public inline function fade(Color:FlxColor = FlxColor.BLACK, Duration:Float = 1, FadeIn:Bool = false, ?OnComplete:Void->Void, Force:Bool = false):Void
		for (i in 0...list.length)
			list[i].fade(Color, Duration, FadeIn, OnComplete, Force);

	public inline function shake(Intensity:Float = 0.05, Duration:Float = 0.5, ?OnComplete:Void->Void, Force:Bool = true, ?Axes:FlxAxes):Void
		for (i in 0...list.length)
			list[i].shake(Intensity, Duration, OnComplete, Force, Axes);

	///////////////////////////

	@:allow(flixel.FlxG)
	function new()
	{
		FlxCamera._defaultCameras = defaults;
	}

	/**
	 * Called by the game object to lock all the camera buffers and clear them for the next draw pass.
	 */
	@:allow(flixel.FlxGame)
	inline function lock():Void
	for (i in 0...list.length)
	{
		var camera = list[i];

		if (cameraUseCheck(camera)) continue;

		#if !desktop
		camera.checkResize();

		if (useBufferLocking)
			camera.buffer.lock();

		camera.fill(camera.bgColor, camera.useBgAlphaBlending);
		camera.screen.dirty = true;

		#else
		// Tile rendering

		camera.clearDrawStack();
		camera.canvas.graphics.clear();
		if(camera.bgColor.alpha > 0)
			camera.fill(camera.bgColor.to24Bit(), camera.useBgAlphaBlending, camera.bgColor.alphaFloat);

		// Clearing camera's debug sprite
		#if FLX_DEBUG
		camera.debugLayer.graphics.clear();
		#end
		#end
	}

	@:allow(flixel.FlxGame)
	inline function render():Void
	{
		#if desktop
		for (i in 0...list.length){
			if (cameraUseCheck(list[i])) 
				continue;

			list[i].render();
		}
		#end
	}

	/**
	 * Called by the game object to draw the special FX and unlock all the camera buffers.
	 */
	@:allow(flixel.FlxGame)
	inline function unlock():Void
	for (i in 0...list.length)
	{
		var camera = list[i];

		if (cameraUseCheck(camera)) continue;

		camera.drawFX();

		#if !desktop
		if (useBufferLocking)
			camera.buffer.unlock();

		camera.screen.dirty = true;
		#end
	}

	/**
	 * Called by the game object to update the cameras and their tracking/special effects logic.
	 */
	@:allow(flixel.FlxGame)
	inline function update(elapsed:Float):Void
	for (i in 0...list.length)
	{
		if(cameraUseCheck(list[i])) continue;

		list[i].update(elapsed);
	}

	/**
	 * Resizes and moves cameras when the game resizes (onResize signal).
	 */
	@:allow(flixel.FlxGame)
	inline function resize():Void
	for (i in 0...list.length)
		list[i].onResize();

	function get_bgColor():FlxColor
	{
		return (FlxG.camera == null) ? FlxColor.BLACK : FlxG.camera.bgColor;
	}

	function set_bgColor(Color:FlxColor):FlxColor
	{
		for (i in 0...list.length)
			list[i].bgColor = Color;

		return Color;
	}
}
