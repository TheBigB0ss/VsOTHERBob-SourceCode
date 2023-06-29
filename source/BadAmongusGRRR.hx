package;

import flixel.util.FlxTimer;
import flixel.FlxSprite;
using StringTools;

class BadAmongusGRRR extends FlxSprite
{
	public function new(?x:Float, ?y:Float)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas(('bgs/intercept/punch/punch_mongus_new'));
		animation.addByPrefix('idle', "idle new", 24, true);
		animation.addByPrefix('punch', "punch new", 24, false);
	}

	public function anim(animName:String)
	{
		animation.play(animName);

		new FlxTimer().start(0.3, function(tmr:FlxTimer) {
			animation.play('idle', true);
		});

		/*if(animation.name == animName && animation.finished)
		{
			animation.play('idle', true);
		}*/
	}
}
