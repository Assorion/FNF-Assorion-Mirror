package misc;

import lime.utils.Assets;

using StringTools;

class CoolUtil
{
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
		return diffArr[diff + (3 * mode)];
	}

	public static function textFileLines(path:String, ?ext:String = 'txt'):Array<String>
	{
		var fullText:String = Assets.getText('assets/songs&data/$path.$ext');

		return fullText.split('\n');
	}

	public static function boundTo(val:Float, min:Float, max:Float, retInt:Bool = false):Dynamic
	{
		if(val < min) val = min;
		if(val > max) val = max;
		if(retInt) return Math.round(val);

		return val;
	}
}
