package;

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
		/*animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('bf-car', [0, 1], 0, false, isPlayer);
		animation.add('bf-christmas', [0, 1], 0, false, isPlayer);
		animation.add('spooky', [2, 3], 0, false, isPlayer);
		animation.add('pico', [4, 5], 0, false, isPlayer);
		animation.add('mom', [6, 7], 0, false, isPlayer);
		animation.add('mom-car', [6, 7], 0, false, isPlayer);
		animation.add('tankman', [8, 9], 0, false, isPlayer);
		animation.add('face', [10, 11], 0, false, isPlayer);
		animation.add('dad', [12, 13], 0, false, isPlayer);
		animation.add('bf-old', [14, 15], 0, false, isPlayer);
		animation.add('gf', [16], 0, false, isPlayer);
		animation.add('parents-christmas', [17], 0, false, isPlayer);
		animation.add('monster', [19, 20], 0, false, isPlayer);
		animation.add('monster-christmas', [19, 20], 0, false, isPlayer);*/
		animation.play('neutral');
		scrollFactor.set();
	}
}
