package misc;

#if !debug @:noDebug #end
class Conductor
{
	public static var bpm:Int = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var songDiv:Float;
	// ^^^ using this as a multiplier since division is the DEVIL!!!!
	
	public static function changeBPM(newBpm:Int)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
		songDiv = 1 / Conductor.stepCrochet;
	}
}
