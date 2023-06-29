package;

import flixel.FlxG;
import flixel.FlxSprite;
using StringTools;
import flixel.addons.display.FlxBackdrop;
import flixel.ui.FlxButton;
import openfl.Lib;

class MenuShit extends MusicBeatState
{
    var bg1:FlxSprite;
    var bg2:FlxSprite;
    var bg:FlxSprite;

    var ass:FlxBackdrop;
    var ass1:FlxBackdrop;

	override function create()
    {
        super.create();
		FlxG.mouse.visible = true;

        FlxG.sound.playMusic(Paths.music('RAP'), 0.8, true);

        bg1 = new FlxSprite().loadGraphic(Paths.image('bgsStuff/OverWorldBG'));
        bg1.updateHitbox();
        bg1.screenCenter();
        bg1.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg1);

        ass1 = new FlxBackdrop(Paths.image('bgsStuff/clound'),0,0,true,false,0,0);
		ass1.antialiasing = true;
		ass1.screenCenter(Y);
		ass1.velocity.x = -10;
		add(ass1);

        ass = new FlxBackdrop(Paths.image('bgsStuff/OverWorld'),0,0,true,false,0,0);
		ass.antialiasing = true;
		ass.screenCenter(Y);
		ass.velocity.x = -50;
		add(ass);

        bg2 = new FlxSprite().loadGraphic(Paths.image('OverWorld/bg/fuck'));
        bg2.antialiasing = ClientPrefs.globalAntialiasing;
        bg2.screenCenter();
        add(bg2);

        bg = new FlxSprite().loadGraphic(Paths.image('bgsStuff/bord'));
        bg.updateHitbox();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

        var coolButton:FlxButton = new FlxButton(0, 650, "Start this shit", function() {
            MusicBeatState.switchState(new OverWorld());
		});
		coolButton.screenCenter(X);
        coolButton.scale.set(1.6, 1.6);
		add(coolButton);

        Lib.application.window.title = "SUPER BOB WORLD";
    }

    override function update(elapsed:Float) {

		if (FlxG.keys.justPressed.ESCAPE)
        {	
            MusicBeatState.switchState(new SuperMenuState());
        }

        super.update(elapsed);
    }
}