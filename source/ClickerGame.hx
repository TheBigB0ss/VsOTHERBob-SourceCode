package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import sys.FileSystem;
using StringTools;
import openfl.Lib;
import WiggleEffect.WiggleEffectType;

class ClickerGame extends MusicBeatState
{
    // bgs
    var bg:FlxSprite;
    var bg1:FlxSprite;
    var brobgonal:FlxSprite;

    // mouse sprite
    var finger:FlxSprite;

    // coins thing
    var coinThing:Int = 0;
    var moeda:Int = 1;
    var coins:FlxText;
    var coinsTween:FlxTween;

    // click
    var click:Bool = false;
    var click1:Bool = false;
    var click2:Bool = false;

    // secret clicks
    var secretClick:Bool = false;
    var secretClick1:Bool = false;
    var secretClick2:Bool = false;

    // itens lol
    var item:FlxSprite;
    var item1:FlxSprite;
    var item2:FlxSprite;
    var item3:FlxSprite;

    // ????
    var secret:Int = 0;

    // shader
    var wiggleEffect:WiggleEffect = new WiggleEffect();

    override function create()
    {
        super.create();      
        FlxG.mouse.visible = true;

        bg = new FlxSprite().loadGraphic(Paths.image('ClickerStuff/bgs/PerfectBG'));
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        if (ClientPrefs.shaders){
            wiggleEffect.effectType = WiggleEffectType.FLAG;
            wiggleEffect.waveAmplitude = 0.1;
            wiggleEffect.waveFrequency = 2;
            wiggleEffect.waveSpeed = 1;
            bg.shader = wiggleEffect.shader;
        }
        add(bg);

        coins = new FlxText();
		coins.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
        coins.screenCenter(X);
        coins.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 4);
		add(coins);

        brobgonal = new FlxSprite().loadGraphic(Paths.image('ClickerStuff/bgs/Brobgonal'));
        brobgonal.screenCenter();
        brobgonal.angularVelocity = 100;
		add(brobgonal);

        bg1 = new FlxSprite().loadGraphic(Paths.image('ClickerStuff/bgs/thing BG'));
        bg1.updateHitbox();
        add(bg1);

        item = new FlxSprite(100, 125).loadGraphic(Paths.image('ClickerStuff/itens/brobgonal'));
        item.updateHitbox();
        add(item);

        item1 = new FlxSprite(100, 325).loadGraphic(Paths.image('ClickerStuff/itens/bandu'));
        item1.updateHitbox();
        add(item1);

        item2 = new FlxSprite(100, 515).loadGraphic(Paths.image('ClickerStuff/itens/bambi'));
        item2.updateHitbox();
        add(item2);

        item3 = new FlxSprite(100, 125).loadGraphic(Paths.image('ClickerStuff/itens/secret'));
        item3.updateHitbox();
        item3.visible = false;

        Lib.application.window.title = "Brobgonal's Clicker Simulator";

        if (FlxG.save.data.moeda == null)
            FlxG.save.data.moeda = 1;
    }

    override public function update(elapsed:Float):Void
    {
        wiggleEffect.update(elapsed);

        super.update(elapsed);

        coins.text = 'Coins = ' + moeda;

        if (FlxG.mouse.overlaps(brobgonal)) {

            if (FlxG.mouse.justPressed) 
            {
                FlxG.sound.play(Paths.sound('fart'), 20);
                moeda += coinThing;
                moeda++;

                coins.scale.x = 1.075;
				coins.scale.y = 1.075;
                
                if(coinsTween != null) coinsTween.cancel();
				coinsTween = FlxTween.tween(coins.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						coinsTween = null;
					}
				});
            }
        }

        if (FlxG.mouse.overlaps(item)) {

            if (FlxG.mouse.justPressed && !click && !secretClick) 
            {
                FlxG.sound.play(Paths.sound('cancelMenu'), 20);

                if (moeda >= 50){
                    moeda -= 50;
                    item.visible = false;
                    click = true;
                    secret++;
                    secretClick = true;
                    coinThing += 6;
                    FlxG.sound.play(Paths.sound('fart'), 0);
                }
                else{
                    moeda -= 0;
                }
            }
        }

        if (FlxG.mouse.overlaps(item1)) {

            if (FlxG.mouse.justPressed && !click1 && !secretClick1) 
            {
                FlxG.sound.play(Paths.sound('cancelMenu'), 20);

                if (moeda >= 100){
                    moeda -= 100;
                    item1.visible = false;
                    click1 = true;
                    secret++;
                    secretClick1 = true;
                    coinThing += 12;
                    FlxG.sound.play(Paths.sound('fart'), 0);
                }
                else{
                    moeda -= 0;
                }
            }
        }

        if (FlxG.mouse.overlaps(item2)) {

            if (FlxG.mouse.justPressed && !click2 && !secretClick2) 
            {
                FlxG.sound.play(Paths.sound('cancelMenu'), 20);

                if (moeda >= 1000){
                    moeda -= 1000;
                    item2.visible = false;
                    click2 = true;
                    secret++;
                    secretClick2 = true;
                    coinThing += 19;
                    FlxG.sound.play(Paths.sound('fart'), 0);
                }
                else{
                    moeda -= 0;
                }
            }
        }

        if (FlxG.mouse.overlaps(item3)) {

            if (FlxG.mouse.justPressed) 
            {
                if (moeda >= 3000){
                    moeda -= 3000;
                    FlxG.sound.play(Paths.sound('fart'), 0);
			
                    PlayState.isStoryMode = false;
                    PlayState.SONG = Song.loadFromJson('golden-core', 'golden-core');
                    LoadingState.loadAndSwitchState(new PlayState());
                }
                else{
                    moeda -= 0;
                }
            }
        }

        if (secret == 3){
            item3.visible = true;
            add(item3);
        }

        if (controls.BACK) {
            MusicBeatState.switchState(new SuperMenuState());
        }
    }
}