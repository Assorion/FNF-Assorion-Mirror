package misc;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;

using StringTools;

class Alphabet extends FlxSpriteGroup
{
	// for menus.
	public var targetY:Float = 0;
	public var targetX:Float = 0;
	public var lerpPos:Bool  = false;
	public var alpMult:Float = 1;

	public var text(default, set):String = "";

	var futurePos:Float = 0;
	public var isBold:Bool = false;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false)
	{
		super(x, y);

		isBold = bold;
		this.text = text.toLowerCase();
	}

	public function addText()
		for (character in text.split(''))
		{
			if(' -_'.contains(character)) {
				futurePos += 40;
				continue;
			}

			if (!AlphaCharacter.completeList.contains(character)) continue;

			// # add text

			var letter:AlphaCharacter = new AlphaCharacter(futurePos, 0);

			if (isBold)
				letter.createBold(character);
			else
				letter.createLetter(character);

			add(letter);

			futurePos += letter.width;
		}

	private function set_text(value:String){
		text = value.toLowerCase();
		clear();
		futurePos = 0;

		if(value != '')
			addText();

		return value;
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		if(!lerpPos) return;

		var lerpVal = 1 - Math.pow(0.5, elapsed * 20);
		x = FlxMath.lerp(x, targetX, lerpVal);
		y = FlxMath.lerp(y, targetY, lerpVal);

		alpha = FlxMath.lerp(alpha, alpMult, lerpVal);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var numbers:String = "1234567890";
	public static var symbols:String = "|~#$%()*+-:;<=>@[]^_.,'!?";
	public static var completeList:String = "abcdefghijklmnopqrstuvwxyz1234567890|~#$%()*+-:;<=>@[]^.,'!?";

	public function new(x:Float, y:Float)
	{
		super(x, y);
		var tex = Paths.lSparrow('ui/alphabet');
		frames = tex;

		antialiasing = Settings.pr.antialiasing;
	}

	public function createBold(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);
		animation.play(letter);
		updateHitbox();
	}

	public function createLetter(letter:String):Void
	{
		var suffix = ' capital';

		if(numbers.contains(letter)) suffix = '';
		if(symbols.contains(letter)) {
			replaceWithSymbol(letter);
			return;
		}

		animation.addByPrefix(letter, '$letter$suffix', 24);
		animation.play(letter);
		updateHitbox();

		y = (110 - height);
	}

	var replacementArray:Array<Dynamic> = [
		'.', "'", '?', '!',
		'period', 'apostraphie', 'question mark', 'exclamation point',
		50, -5, 0, 0
	];

	// # handle symbols.

	public function replaceWithSymbol(letter:String)
	{
		var magicNumb:Int = Math.floor(replacementArray.length / 3);
		for(i in 0...magicNumb)
			if(letter == replacementArray[i]){
				letter = replacementArray[i + magicNumb];
				y += replacementArray[i + (magicNumb * 2)];
				break;
			}

		animation.play(letter);
		updateHitbox();
	}
}
