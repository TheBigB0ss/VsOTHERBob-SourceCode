package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;

class GENIUSALERT extends MusicBeatState
{
	var option:FlxSprite;
	var option1:FlxSprite;

	var asshole:FlxBackdrop;

	var texto:FlxText;
	var texto1:FlxText;

	var ESCAPE = FlxG.keys.justPressed.ESCAPE;
    
	override function create()
	{
		FlxG.mouse.visible = true;

		super.create();

		asshole = new FlxBackdrop(Paths.image('geniusStuff/asshole BG'), 0.2, 0, true, true);
		asshole.velocity.set(-40, -40);
	    asshole.updateHitbox();
		asshole.alpha = 0.5;
		asshole.screenCenter(X);
		add(asshole);

		texto = new FlxText(840, 125);
		texto.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		texto.scrollFactor.set();
		texto.text = 'select a language';
		texto.borderSize = 1.25;
		add(texto);

		texto1 = new FlxText(110, 125);
		texto1.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		texto1.scrollFactor.set();
		texto1.text = 'selecione uma lingua';
		texto1.borderSize = 1.25;
		add(texto1);

		option = new FlxSprite(900, 400).loadGraphic(Paths.image('geniusStuff/languages/ingles'));
		option.updateHitbox();
		option.antialiasing = ClientPrefs.globalAntialiasing;
		add(option);

		option1 = new FlxSprite(187, 400).loadGraphic(Paths.image('geniusStuff/languages/BRASIL'));
		option1.updateHitbox();
		option1.antialiasing = ClientPrefs.globalAntialiasing;
		add(option1);
	}

	override function update(elapsed:Float)
	{

		if (FlxG.keys.justPressed.ESCAPE)
		{	
			MusicBeatState.switchState(new FreeplayState());
			FlxG.mouse.visible = false;
		}

		if (FlxG.mouse.overlaps(option)) {
            option.scale.set(1.3, 1.3);

            if (FlxG.mouse.pressed)
			MusicBeatState.switchState(new Genius());

            if (FlxG.mouse.justPressed) 
            {
                FlxG.mouse.visible = false;
            }

        } else {
            option.scale.set(1.4, 1.4);
        }

		if (FlxG.mouse.overlaps(option1)) {
            option1.scale.set(1.3, 1.3);

            if (FlxG.mouse.pressed)
			MusicBeatState.switchState(new JENIO());

            if (FlxG.mouse.justPressed) 
            {
                FlxG.mouse.visible = false;
            }

        } else {
            option1.scale.set(1.4, 1.4);
        }

		super.update(elapsed);
	}
}
