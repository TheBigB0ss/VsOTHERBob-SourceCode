package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import openfl.Lib;
using StringTools;
import flixel.util.FlxSpriteUtil;
import flixel.FlxObject;

class OverWorld extends MusicBeatState
{
    var spriteshit:FlxSprite;
    var bob:FlxSprite;

    var bg:FlxSprite;
    var bord:FlxSprite;

    var text:FlxText;

    var velocity:Float = 0.25;

	override public function create():Void
    {
        super.create();
        FlxG.mouse.visible = false;
        FlxG.sound.playMusic(Paths.music('RAP'), 0.8, true);

        bg = new FlxSprite();
        bg.loadGraphic(Paths.image('OverWorld/bg/BG/BG_OVERWORLD_GRASS'));
        add(bg);

        bob = new FlxSprite();
        bob.loadGraphic(Paths.image('OverWorld/characters/openworld guys/bob'), true, 50, 50);
        bob.animation.add("idle", [0, 1, 2, 3, 4, 5, 6, 7], 10);
        bob.animation.play("idle");
        bob.scale.set(2.2, 2.2);
        bob.screenCenter();
        add(bob);

        spriteshit = new FlxSprite(312, 392);
        spriteshit.loadGraphic(Paths.image('OverWorld/characters/openworld guys/BF remake'), true, 50, 50);
        spriteshit.animation.add("idle", [0], 0);
        spriteshit.animation.add("walk_down", [1, 2, 3, 4, 5, 6], 9);
        spriteshit.animation.add("walk_up",  [7, 8, 9, 10, 11, 12, 13], 11);
        spriteshit.animation.add("walk_right", [21, 22, 23, 24, 25, 26, 27], 12);
        spriteshit.animation.add("walk_left", [14, 15, 16, 17, 18, 19, 20], 12);
        spriteshit.animation.play('idle');
        spriteshit.scale.set(2.2, 2.2);
        add(spriteshit);

        bord = new FlxSprite();
        bord.loadGraphic(Paths.image('OverWorld/bg/bord/BG_OVERWORLD_FENCE'));
        add(bord);

        text = new FlxText();
        text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.text = 'Press ENTER :D';
        text.borderSize = 1.25;
        text.scale.set(0.9, 0.9);
        text.screenCenter(X);
        add(text);

        Lib.application.window.title = "SUPER BOB WORLD";
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        FlxSpriteUtil.screenWrap(spriteshit);
        if(FlxCollision.pixelPerfectCheck(spriteshit, bob))
        {
            text.visible = true;
            if (controls.ACCEPT)
            {
                LoadingState.loadAndSwitchState(new PlayState());
                
                PlayState.isStoryMode = false;
                PlayState.SONG = Song.loadFromJson('pixelated', 'pixelated');
                LoadingState.loadAndSwitchState(new PlayState());
                Lib.application.window.title = "Friday Night Funkin': VS OTHER BOB V2";
            }	
        }else{
            text.visible = false;
        }

        var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;

        if(up)
        {
            spriteshit.y -= velocity;
            spriteshit.animation.play('walk_up');
        }

        if(down)
        {
            spriteshit.y += velocity;
            spriteshit.animation.play('walk_down');
        }

        if(right)
        {
            spriteshit.x += velocity;
            spriteshit.animation.play('walk_right');
        }

        if(left) 
        {
            spriteshit.x -= velocity;
            spriteshit.animation.play('walk_left');
        }

        if (controls.BACK){
            MusicBeatState.switchState(new SuperMenuState());
        }
    }
}