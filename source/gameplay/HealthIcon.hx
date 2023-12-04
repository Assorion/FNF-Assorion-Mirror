package gameplay;

import lime.utils.Assets;
import misc.Alphabet;

#if !debug @:noDebug #end
class HealthIcon extends StaticSprite
{
	public var curChar:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		changeIcon(char, isPlayer);
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

		curChar = char;
	}

	public inline function changeState(losing:Bool)
		animation.play(losing ? 'losing' : 'neutral');
}
