package gameplay;

import flixel.FlxSprite;
import flixel.util.FlxColor;

#if !debug @:noDebug #end
class Note extends FlxSprite
{
	public static var colArr:Array<String> = ['purple', 'blue', 'green', 'red'];
	public static var possibleTypes:Array<NoteType> = [
		{
			assets: 'NOTE_assets',
			mustHit: true,
			rangeMul: 1,
			onHit: null, 
			onMiss: null
		}
	];

	public var strumTime:Float = 0;
	public var curColor:String = 'purple';
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;

	public var player  :Int = 0;
	public var noteData:Int = 0;

	public var chartRef:Array<Dynamic> = [];
	public var isSustainNote:Bool = false;
	public var curType:NoteType;

	// this is inlined, you can't change this variable later.
	public static inline var swagWidth:Float = 160 * 0.7;

	public function new(strumTime:Float, data:Int, type:Int, ?sustainNote:Bool = false, ?isEnd:Bool = false)
	{
		super();

		y = -2000;

		isSustainNote  = sustainNote;
		this.strumTime = strumTime;
		this.noteData  = data % 4;
		this.curType   = possibleTypes[type];

		curColor = colArr[noteData];

		frames = Paths.lSparrow('gameplay/${curType.assets}');

		animation.addByPrefix('scroll' , curColor + '0');
		if(isSustainNote){
			animation.addByPrefix('holdend', '$curColor hold end');
			animation.addByPrefix('hold'   , '$curColor hold piece');
		} 

		setGraphicSize(Std.int(width * 0.7));
		antialiasing = Settings.pr.antialiasing;

		animation.play('scroll');
		updateHitbox();
		centerOffsets();
		centerOrigin ();

		if (!isSustainNote) return;

		alpha = 0.6;
		flipY = Settings.pr.downscroll;
		offsetX += width / 2;
		var defaultOffset = (Settings.pr.downscroll ? -7 : 7) * PlayState.SONG.speed;

		animation.play('holdend');
		animation.remove('scroll');

		var calc:Float = Conductor.stepCrochet / 100 * ((Conductor.bpm / 100) * (44 / 140)) * PlayState.SONG.speed;
		var holdScale = scale.y = (scale.y * calc);

		if(Settings.pr.downscroll)
			offsetY += height * (calc * 0.5);

		updateHitbox();
		offsetX -= width / 2;
		offsetY += defaultOffset;

		if (isEnd) return;

		animation.play('hold');
		animation.remove('holdend');
		scale.y = holdScale * (140 / 44);
		offsetY = defaultOffset;
		updateHitbox();
	}

	// helper function
	public function typeAction(action:Int){
		var curAct:Void->Void = [curType.onHit, curType.onMiss][action];
		if(curAct != null) curAct();
	}
}