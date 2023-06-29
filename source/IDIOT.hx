package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
using StringTools;

class IDIOT extends MusicBeatState
{
    var idiot:FlxSprite;
    var bg:FlxSprite;

	override function create()
    {
        super.create();
		FlxG.mouse.visible = true;

        bg = new FlxSprite().loadGraphic(Paths.image('idiotStuff/idiot BG1'));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

        idiot = new FlxSprite(550, 310).loadGraphic(Paths.image('idiotStuff/IDIOT'));
		idiot.updateHitbox();
		idiot.antialiasing = ClientPrefs.globalAntialiasing;
		add(idiot);
    }

    override function update(elapsed:Float) {

		if (FlxG.keys.justPressed.ESCAPE)
        {	
            var ESCAPE:FlxSprite = new FlxSprite().loadGraphic(Paths.image('idiotStuff/PAUSE'));
            ESCAPE.updateHitbox();
            ESCAPE.screenCenter();
            ESCAPE.antialiasing = ClientPrefs.globalAntialiasing;
            add(ESCAPE);
            FlxG.sound.play(Paths.sound('STATIC'));
        
            new FlxTimer().start(1.8, function(tmr:FlxTimer) {
                FlxTween.tween(ESCAPE, {alpha:0}, 0.6, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
                    ESCAPE.destroy();
                }});
            });
        }

        if (FlxG.mouse.overlaps(idiot)) {

            if (FlxG.mouse.justPressed) 
            {
                FlxG.mouse.visible = false;

                PlayState.isStoryMode = false;
                PlayState.SONG = Song.loadFromJson('malware', 'malware');
                LoadingState.loadAndSwitchState(new PlayState());
            }
        }

        super.update(elapsed);
    }
}