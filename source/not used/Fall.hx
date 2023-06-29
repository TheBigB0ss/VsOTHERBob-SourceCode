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

class Fall extends MusicBeatState
{
	var falha:FlxSprite;
	var botao:FlxSprite;
	var botao1:FlxSprite;

	override function create()
	{
		FlxG.mouse.visible = true;

		super.create();

		falha = new FlxSprite(0,0).loadGraphic(Paths.image('geniusStuff/IN/fall'));
		falha.setGraphicSize(1286,800);
		falha.scrollFactor.set();
		falha.screenCenter();
		add(falha);

		botao = new FlxSprite(187,400).loadGraphic(Paths.image('geniusStuff/IN/fall shit1'));
		botao.scrollFactor.set();
		botao.updateHitbox();
		add(botao);

		botao1 = new FlxSprite(187,400).loadGraphic(Paths.image('geniusStuff/IN/fall shit'));
		botao1.scrollFactor.set();
		botao1.updateHitbox();
		add(botao1);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.mouse.overlaps(botao)) {
			botao.visible = true;
			botao1.visible = false;

            if (FlxG.mouse.pressed)
            MusicBeatState.switchState(new Genius());

            if (FlxG.mouse.justPressed) 
            {
                FlxG.mouse.visible = false;
            }

        } else {
			botao.visible = false;
			botao1.visible = true;
        }

		super.update(elapsed);
	}
}
