package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.Lib;

class BEAST extends MusicBeatState
{
    var text:FlxText;

	override function create()
    {
        text = new FlxText();
		text.setFormat(Paths.font("bullshit.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.screenCenter();
		add(text);

        var beast:FlxSprite = new FlxSprite().loadGraphic(Paths.image('Mrbeast/evil-' + FlxG.random.int(1, 13)));
        beast.updateHitbox();
        beast.screenCenter();
        //add(beast);

        new FlxTimer().start(1.0, function(tmr:FlxTimer) {
            text.text = 'so';
            Lib.application.window.title = "CHEATER";

            new FlxTimer().start(3.0, function(tmr:FlxTimer)  {
                text.text = 'you think you\'re smart?';
                Lib.application.window.title = "I HATE CHEATERS";
    
                new FlxTimer().start(3.0, function(tmr:FlxTimer) {
                    text.text = 'LMAO';
                    Lib.application.window.title = "947.370.834.433";
    
                    new FlxTimer().start(2.0, function(tmr:FlxTimer) {
                        text.text = 'you forgot something';
                        Lib.application.window.title = "I HATE YOU " + CoolUtil.getUsername();
    
                        new FlxTimer().start(3.0, function(tmr:FlxTimer)  {
                            text.text = 'this is MY game';
                            Lib.application.window.title = "Jumpscare in 3";
    
                            new FlxTimer().start(3.0,function(tmr:FlxTimer) {
                                text.text = 'here I AM GOD';
                                Lib.application.window.title = "2";
    
                                new FlxTimer().start(3.0, function(tmr:FlxTimer) {
                                    text.text = 'BOO';
                                    Lib.application.window.title = "1";
    
                                    new FlxTimer().start(0.32, function(tmr:FlxTimer) {
                                        text.text = '';
                                        FlxG.sound.play(Paths.sound('jumpscare'));
                                        Lib.application.window.title = "BOOOOOOOOOOOOO";
                                        add(beast);
                                        FlxG.camera.shake();
        
                                        new FlxTimer().start(1.0, function(tmr:FlxTimer) {
                                            Sys.exit(1);
                                        });
                                    });
                                });
                            });
                        });
                    });
                });
            });
        });
    }
}