package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

class GilbertGarfieldJumpscare extends MusicBeatState
{
	var gilbert1:FlxSprite;

	override function create()
	{
		gilbert1 = new FlxSprite().loadGraphic(Paths.image('Gilbert Jumpscare'));
		gilbert1.updateHitbox();
		gilbert1.screenCenter();
		gilbert1.antialiasing = ClientPrefs.globalAntialiasing;
		add(gilbert1);
		FlxG.sound.play(Paths.sound('jumpscare'));
		FlxG.camera.shake();
	}

	override function update(elapsed:Float)
	{
		new FlxTimer().start(1.0, function(tmr:FlxTimer) {
			FlxTween.tween(gilbert1, {alpha:0}, 0.6, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
				Sys.exit(1);
			}});
		});
	}
}
