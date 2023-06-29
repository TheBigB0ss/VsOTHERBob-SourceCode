package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;

class Roberto extends MusicBeatState
{
	var roberto:FlxSprite;
	var robertoSadText:FlxText;
	var thisIsRoberto:FlxSprite;

	override function create()
	{
		FlxG.sound.music.volume = 0;

		roberto = new FlxSprite().loadGraphic(Paths.image('Roberto is Dead NOOO'));
		roberto.screenCenter();
		add(roberto);
		FlxG.sound.play(Paths.sound('roberto sad sound'));

		thisIsRoberto = new FlxSprite().loadGraphic(Paths.image('this is Roberto'));
		add(thisIsRoberto);

		robertoSadText = new FlxText(50, FlxG.height - 140, 1180);
		robertoSadText.text = 'Roberto Is Dead :((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((';
		robertoSadText.setFormat(Paths.font("PhantomMuff.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(robertoSadText);
	}

	override function update(elapsed:Float)
	{
		new FlxTimer().start(7.0, function(tmr:FlxTimer) {
			MusicBeatState.switchState(new SuperMenuState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		});
	}
}
