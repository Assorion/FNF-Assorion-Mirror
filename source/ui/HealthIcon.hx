package ui;

import flixel.FlxSprite;
import lime.utils.Assets;

class HealthIcon extends FlxSprite
{
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		//loadGraphic('assets/images/iconGrid.png', true, 150, 150);
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
}
