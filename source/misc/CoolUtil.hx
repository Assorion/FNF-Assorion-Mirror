package misc;

import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxCamera;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;

using StringTools;

#if !debug @:noDebug #end
class CoolUtil
{
	public static var cachedLines:Map<String, Array<String>> = new Map<String, Array<String>>();

	// should be the diffArray divided by 2.
	// don't change this unless you're adding a custom difficulty. (or removing.)
	public static inline var diffNumb:Int = 3;
	public static var diffArr:Array<String> = [
		// file names
		'-easy',
		'',
		'-hard',
		// formatted names.
		'Easy',
		'Normal',
		'Hard'
	];

	public static function diffString(diff:Int, mode:Int):String
	{
		return diffArr[diff + (diffNumb * mode)];
	}

	public static function textFileLines(path:String, ?ext:String = 'txt'):Array<String>
	{
		if(Settings.pr.cache_text && cachedLines.exists(path))
			return cachedLines.get(path);

		var fullText = Assets.getText('assets/songs-data/$path.$ext').split('\n');
		if(Settings.pr.cache_text)
			cachedLines.set(path, fullText);

		return fullText;
	}

	public static function boundTo(val:Float, min:Float, max:Float, retInt:Bool = false):Dynamic
	{
		if(val < min) val = min;
		if(val > max) val = max;
		if(retInt) return Math.round(val);

		return val;
	}

	// TODO: Make this support web browsers. Web build handles rendering differently.
	// # Copy camera to bitmap data keeping rotation and zoom.
	public static function copyCameraToData(bitmapDat:BitmapData, camera:FlxCamera){
		var matr:Matrix = new Matrix(camera.zoom, 0, 0, camera.zoom, 0, 0);
			matr.translate(-(camera.width * 0.5), -(camera.height * 0.5));
			matr.rotate   (( camera.angle * Math.PI) / 180);
			matr.translate(  camera.width * 0.5, camera.height * 0.5);
			matr.translate(((camera.width * camera.zoom) - camera.width) * -0.5, ((camera.height * camera.zoom) - camera.height) * -0.5);

		bitmapDat.draw(camera.canvas, matr, null, null, null, true);
	}

	public inline static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
}
