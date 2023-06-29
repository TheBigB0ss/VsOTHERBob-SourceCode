package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class JENIO extends MusicBeatState
{

	var option1:FlxSprite;
    var option2:FlxSprite;
	var option3:FlxSprite;
	var option4:FlxSprite;

	var option1green:FlxSprite;
	var option2green:FlxSprite;
	var option3green:FlxSprite;
	var option4green:FlxSprite;

	var pergunta:FlxSprite;

	var bg:FlxSprite;

	var ESCAPE = FlxG.keys.justPressed.ESCAPE;

	override function create()
	{
		FlxG.mouse.visible = true;

		super.create();

		bg = new FlxSprite(0,0).loadGraphic(Paths.image('geniusStuff/white'));
		bg.scrollFactor.set();
		bg.screenCenter();
		add(bg);

		pergunta = new FlxSprite(0,0).loadGraphic(Paths.image('geniusStuff/PT-BR/pergunta'));
		pergunta.scrollFactor.set();
		pergunta.screenCenter();
		add(pergunta);

		option1 = new FlxSprite(380,180).loadGraphic(Paths.image('geniusStuff/PT-BR/option1green'));
		option1.scrollFactor.set();
		option1.updateHitbox();
		option1.scale.set(1.4, 1.4);
		add(option1);

		option2 = new FlxSprite(750,180).loadGraphic(Paths.image('geniusStuff/PT-BR/option2green'));
		option2.scrollFactor.set();
		option2.updateHitbox();
		option2.scale.set(1.4, 1.4);
		add(option2);

		option3 = new FlxSprite(380,400).loadGraphic(Paths.image('geniusStuff/PT-BR/option3green'));
		option3.scrollFactor.set();
		option3.updateHitbox();
		option3.scale.set(1.4, 1.4);
		add(option3);

		option4 = new FlxSprite(750,400).loadGraphic(Paths.image('geniusStuff/PT-BR/option4green'));
		option4.scrollFactor.set();
		option4.updateHitbox();
		option4.scale.set(1.4, 1.4);
		add(option4);

		option1green = new FlxSprite(380,180).loadGraphic(Paths.image('geniusStuff/PT-BR/option1'));
		option1green.scrollFactor.set();
		option1green.updateHitbox();
		option1green.scale.set(1.4, 1.4);
		add(option1green);

		option2green = new FlxSprite(750,180).loadGraphic(Paths.image('geniusStuff/PT-BR/option2'));
		option2green.scrollFactor.set();
		option2green.updateHitbox();
		option2green.scale.set(1.4, 1.4);
		add(option2green);

		option3green = new FlxSprite(380,400).loadGraphic(Paths.image('geniusStuff/PT-BR/option3'));
		option3green.scrollFactor.set();
		option3green.updateHitbox();
		option3green.scale.set(1.4, 1.4);
		add(option3green);

		option4green = new FlxSprite(750,400).loadGraphic(Paths.image('geniusStuff/PT-BR/option4'));
		option4green.scrollFactor.set();
		option4green.updateHitbox();
		option4green.scale.set(1.4, 1.4);
		add(option4green);
	}

	override function update(elapsed:Float)
	{
		FlxG.sound.music.volume = 0;

		if (FlxG.keys.justPressed.ESCAPE)
        {	
            MusicBeatState.switchState(new FreeplayState());
			FlxG.mouse.visible = false;
        }


		if (FlxG.mouse.overlaps(option1)) {
			option1.scale.set(1.4, 1.4);
            option1.visible = true;
			option1green.visible = false;

            if (FlxG.mouse.justPressed) 
            {
				LoadingState.loadAndSwitchState(new PlayState());
				PlayState.isStoryMode = false;
				PlayState.SONG = Song.loadFromJson('elections', 'elections');
				LoadingState.loadAndSwitchState(new PlayState());

                FlxG.mouse.visible = false;
            }

        } else {
			option1.scale.set(1.4, 1.4);
			option1.visible = false;
			option1green.visible = true;
        }

		if (FlxG.mouse.overlaps(option2)) {
			option2.scale.set(1.4, 1.4);
            option2.visible = true;
			option2green.visible = false;

            if (FlxG.mouse.pressed)
			MusicBeatState.switchState(new Falha());

            if (FlxG.mouse.justPressed) 
            {
                FlxG.mouse.visible = false;
            }

        } else {
			option2.scale.set(1.4, 1.4);
            option2.visible = false;
			option2green.visible = true;
        }

		if (FlxG.mouse.overlaps(option3)) {
			option3.scale.set(1.4, 1.4);
            option3.visible = true;
			option3green.visible = false;

            if (FlxG.mouse.pressed)
			MusicBeatState.switchState(new Falha());

            if (FlxG.mouse.justPressed) 
            {
                FlxG.mouse.visible = false;
            }

        } else {
			option3.scale.set(1.4, 1.4);
			option3.visible = false;
			option3green.visible = true;
        }

		if (FlxG.mouse.overlaps(option4)) {
			option4.scale.set(1.4, 1.4);
            option4.visible = true;
			option4green.visible = false;

            if (FlxG.mouse.pressed)
			MusicBeatState.switchState(new Falha());

            if (FlxG.mouse.justPressed) 
            {
                FlxG.mouse.visible = false;
            }

        } else {
			option4.scale.set(1.4, 1.4);
            option4.visible = false;
			option4green.visible = true;
        }

		super.update(elapsed);
	}
}