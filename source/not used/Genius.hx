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

class Genius extends MusicBeatState
{
	var option5:FlxSprite;
    var option6:FlxSprite;
	var option7:FlxSprite;
	var option8:FlxSprite;

	var option5green:FlxSprite;
	var option6green:FlxSprite;
	var option7green:FlxSprite;
	var option8green:FlxSprite;

	var question:FlxSprite;

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

		question = new FlxSprite(0,0).loadGraphic(Paths.image('geniusStuff/IN/question'));
		question.scrollFactor.set();
		question.screenCenter();
		add(question);

		option5 = new FlxSprite(380,180).loadGraphic(Paths.image('geniusStuff/IN/option5green'));
		option5.scrollFactor.set();
		option5.updateHitbox();
		option5.scale.set(1.4, 1.4);
		add(option5);

		option6 = new FlxSprite(750,180).loadGraphic(Paths.image('geniusStuff/IN/option6green'));
		option6.scrollFactor.set();
		option6.updateHitbox();
		option6.scale.set(1.4, 1.4);
		add(option6);

		option7 = new FlxSprite(380,400).loadGraphic(Paths.image('geniusStuff/IN/option7green'));
		option7.scrollFactor.set();
		option7.updateHitbox();
		option7.scale.set(1.4, 1.4);
		add(option7);

		option8 = new FlxSprite(750,400).loadGraphic(Paths.image('geniusStuff/IN/option8green'));
		option8.scrollFactor.set();
		option8.updateHitbox();
		option8.scale.set(1.4, 1.4);
		add(option8);

		option5green = new FlxSprite(380,180).loadGraphic(Paths.image('geniusStuff/IN/option5'));
		option5green.scrollFactor.set();
		option5green.updateHitbox();
		option5green.scale.set(1.4, 1.4);
		add(option5green);

		option6green = new FlxSprite(750,180).loadGraphic(Paths.image('geniusStuff/IN/option6'));
		option6green.scrollFactor.set();
		option6green.updateHitbox();
		option6green.scale.set(1.4, 1.4);
		add(option6green);

		option7green = new FlxSprite(380,400).loadGraphic(Paths.image('geniusStuff/IN/option7'));
		option7green.scrollFactor.set();
		option7green.updateHitbox();
		option7green.scale.set(1.4, 1.4);
		add(option7green);

		option8green = new FlxSprite(750,400).loadGraphic(Paths.image('geniusStuff/IN/option8'));
		option8green.scrollFactor.set();
		option8green.updateHitbox();
		option8green.scale.set(1.4, 1.4);
		add(option8green);
	}

	override function update(elapsed:Float)
	{
		FlxG.sound.music.volume = 0;

		if (FlxG.keys.justPressed.ESCAPE)
        {	
            MusicBeatState.switchState(new FreeplayState());
			FlxG.mouse.visible = false;
        }


		if (FlxG.mouse.overlaps(option5)) {
			option5.scale.set(1.4, 1.4);
            option5.visible = true;
			option5green.visible = false;

            if (FlxG.mouse.justPressed) 
            {
				LoadingState.loadAndSwitchState(new PlayState());
				PlayState.isStoryMode = false;
				PlayState.SONG = Song.loadFromJson('elections', 'elections');
				LoadingState.loadAndSwitchState(new PlayState());

                FlxG.mouse.visible = false;
            }

        } else {
			option5.scale.set(1.4, 1.4);
			option5.visible = false;
			option5green.visible = true;
        }

		if (FlxG.mouse.overlaps(option6)) {
			option6.scale.set(1.4, 1.4);
			option6.visible = true;
			option6green.visible = false;

            if (FlxG.mouse.pressed)
			MusicBeatState.switchState(new Fall());

            if (FlxG.mouse.justPressed) 
            {
                FlxG.mouse.visible = false;
            }

        } else {
			option6.scale.set(1.4, 1.4);
			option6.visible = false;
			option6green.visible = true;
        }

		if (FlxG.mouse.overlaps(option7)) {
			option7.scale.set(1.4, 1.4);
			option7.visible = true;
			option7green.visible = false;

            if (FlxG.mouse.pressed)
			MusicBeatState.switchState(new Fall());

            if (FlxG.mouse.justPressed) 
			{  
                FlxG.mouse.visible = false;
            }

        } else {
			option7.scale.set(1.4, 1.4);
			option7.visible = false;
			option7green.visible = true;
        }

		if (FlxG.mouse.overlaps(option8)) {
			option8.scale.set(1.4, 1.4);
			option8.visible = true;
			option8green.visible = false;

            if (FlxG.mouse.pressed)
			MusicBeatState.switchState(new Fall());

            if (FlxG.mouse.justPressed) 
            {
                FlxG.mouse.visible = false;
            }

        } else {
			option8.scale.set(1.4, 1.4);
			option8.visible = false;
			option8green.visible = true;
        }

		super.update(elapsed);
	}
}