package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import options.GraphicsSettingsSubState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import openfl.Assets;
import sys.FileSystem;
using StringTools;
import flixel.util.FlxTimer;

class GodState extends MusicBeatState
{
    var ESCAPE = FlxG.keys.justPressed.ESCAPE;

    // parts
    var godFace:FlxSprite;
    var godFace1:FlxSprite;
    var godFace2:FlxSprite;
    var godFace3:FlxSprite;

    // clicks
    var shitclick:Bool = false;
    var shitclick1:Bool = false;
    var shitclick2:Bool = false;
    var shitclick3:Bool = false;
 
    // thing
    var shit:Int = 0;

    // bg
    var bg:FlxSprite;

	override function create()
    {
        super.create();
		FlxG.mouse.visible = true;

        bg = new FlxSprite().loadGraphic(Paths.image('bgsStuff/blackBG'));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);
		
        godFace = new FlxSprite(900, 400).loadGraphic(Paths.image('god/1'));
		godFace.updateHitbox();
		godFace.antialiasing = ClientPrefs.globalAntialiasing;
		add(godFace);

        godFace1 = new FlxSprite(187, 125).loadGraphic(Paths.image('god/2'));
		godFace1.updateHitbox();
		godFace1.antialiasing = ClientPrefs.globalAntialiasing;
		add(godFace1);

        godFace2 = new FlxSprite(187, 400).loadGraphic(Paths.image('god/3'));
		godFace2.updateHitbox();
		godFace2.antialiasing = ClientPrefs.globalAntialiasing;
		add(godFace2);

        godFace3 = new FlxSprite(730, 305).loadGraphic(Paths.image('god/4'));
		godFace3.updateHitbox();
		godFace3.antialiasing = ClientPrefs.globalAntialiasing;
		add(godFace3);
    }

    override function update(elapsed:Float) {

        //test.text = 'X' + FlxG.mouse.screenX;
        //test1.text = 'Y' + FlxG.mouse.screenY;

		if (FlxG.keys.justPressed.ESCAPE) {	
            MusicBeatState.switchState(new SuperMenuState());
        }

        if (FlxG.mouse.overlaps(godFace)) {

            if (!shitclick && FlxG.mouse.justPressed) {
                //godFace.screenCenter();
                godFace.x = 530;
                godFace.y = 199;
                shitclick = true;
                shit++;
            }
        }

        if (FlxG.mouse.overlaps(godFace1)) {

            if (!shitclick1 && FlxG.mouse.justPressed) {
                //godFace1.screenCenter();
                godFace1.x = 686;
                godFace1.y = 291;
                shitclick1 = true;
                shit++;
            }
        }

        if (FlxG.mouse.overlaps(godFace2)) {

            if (!shitclick2 && FlxG.mouse.justPressed) {
                godFace2.screenCenter();
                //godFace2.x = 749;
                //godFace2.y = 382;
                shitclick2 = true;
                shit++;
            }
        }

        if (FlxG.mouse.overlaps(godFace3)) {

            if (!shitclick3 && FlxG.mouse.justPressed) {
                //godFace3.screenCenter();
                godFace3.x = 525;
                godFace3.y = 291;
                shitclick3 = true;
                shit++;
            }
        }

        if(shit == 4){
            LoadingState.loadAndSwitchState(new PlayState());
	
            PlayState.isStoryMode = false;
            PlayState.SONG = Song.loadFromJson('curse', 'curse');
            LoadingState.loadAndSwitchState(new PlayState());
            trace('do you wanna play with me ' + CoolUtil.getUsername());
        }

        super.update(elapsed);
    }
}