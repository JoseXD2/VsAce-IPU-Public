package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;
	public var startedDeath:Bool = false;

	public function new(x:Float, y:Float, ?char:String = 'bf')
	{
		super(x, y, char);
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null)
		{
			if (isSinging)
				holdTimer += elapsed;
			else
				holdTimer = 0;

			if (animation.curAnim.finished && animation.curAnim.name.endsWith('miss'))
			{
				playAnim('idle', true, false, 10);
			}

			if (startedDeath && animation.curAnim.finished && animation.curAnim.name == 'firstDeath')
			{
				playAnim('deathLoop');
			}
		}

		super.update(elapsed);
	}
}
