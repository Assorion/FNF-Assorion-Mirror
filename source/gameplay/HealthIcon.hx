package gameplay;

import flixel.FlxSprite;
import lime.utils.Assets;
import misc.Alphabet;

class HealthIcon extends FlxSprite
{
	public var hook:Alphabet;

	public function new(char:String = 'bf', isPlayer:Bool = false, hook:Alphabet = null)
	{
		super();
		changeIcon(char, isPlayer);
		if(hook != null)
			this.hook = hook;
	}
	public function changeIcon(char:String, isPlayer:Bool){
		var path = Paths.lImage('icons/$char');
		loadGraphic(Paths.lImage('icons/face'), true, 150, 150);

		if(Assets.exists(path))
			loadGraphic(path, true, 150, 150);

		antialiasing = Settings.pr.antialiasing;
		animation.add('neutral', [0], 0, false, isPlayer);
		animation.add('losing',  [1], 0, false, isPlayer);
		animation.play('neutral');

		scrollFactor.set();
		updateHitbox();

		centerOffsets();
		centerOrigin ();
	}
	override function update(elapsed:Float){
		super.update(elapsed);

		if(hook == null) return;

		x = hook.futurePos + hook.members[0].x;
		y = hook.members[0].y;
		y += (hook.members[0].height / 2) - height / 2;
		alpha = hook.members[0].alpha;
	}
}
