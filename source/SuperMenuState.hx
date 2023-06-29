package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import editors.MasterEditorMenu;
import flixel.addons.display.FlxBackdrop;
import openfl.Lib;
import flixel.group.FlxGroup.FlxTypedGroup;
import lime.app.Application;

using StringTools;

class SuperMenuState extends MusicBeatState
{
    // options
    var coolOptions:Array<String> = [
        'storyMode',  // case 0
        'freeplay',   // case 1
        'credits',    // case 2
        'options',    // case 3
        'extras',     // case 4
        'fart'        // case 5
	];

    // bgs
	var bord1:FlxSprite;
	var bord2:FlxSprite;
	var bg:FlxSprite;
	var ass:FlxBackdrop;

    //
    var curSelected:Int = 0;

    // fart fart fart 
	var farttext:FlxText;
	var superfart:Int = 0;
	var fartTween:FlxTween;

    //I made this group for the options
    var group:FlxTypedGroup<FlxSprite>;

    var shited:FlxSprite;
    var finger:FlxSprite;

    public static var version:String = 'Vs OTHER Bob V.2';
    var versionTxt:FlxText;

	override function create(){

		super.create();
		FlxG.mouse.visible = true;
        FlxG.sound.music.volume = 0.8;
        
        switch(ClientPrefs.mouse)
		{
			case 'finger':
				finger = new FlxSprite();
				finger.makeGraphic(15, 15, FlxColor.TRANSPARENT);
				finger.loadGraphic(Paths.image('cursor/finger'));
				FlxG.mouse.load(finger.pixels);
	
			case 'pointer':
				finger = new FlxSprite();
				finger.makeGraphic(15, 15, FlxColor.TRANSPARENT);
				finger.loadGraphic(Paths.image('cursor/newcursor'));
				FlxG.mouse.load(finger.pixels);

			case 'mario':
				finger = new FlxSprite();
				finger.makeGraphic(15, 15, FlxColor.TRANSPARENT);
				finger.loadGraphic(Paths.image('cursor/Mario'));
				FlxG.mouse.load(finger.pixels);
		}

        bg = new FlxSprite();
		bg.loadGraphic(Paths.image('bgsStuff/new Bg/bg'));
		bg.screenCenter();
		add(bg);

        ass = new FlxBackdrop(Paths.image('bgShit'),0,0,true,false,0,0);
		ass.antialiasing = true;
		ass.screenCenter(Y);
		ass.velocity.x = -30;
		add(ass);

        group = new FlxTypedGroup<FlxSprite>();
		add(group);

        // options sprites etc
        for (i in 0...coolOptions.length){
			var optionsSprites:FlxSprite = new FlxSprite();
            optionsSprites.loadGraphic(Paths.image('mainMenuStuff/base/' + coolOptions[i]));
            // options position
			switch(i){

				case 0:
					optionsSprites.x = 187;
					optionsSprites.y = 125;
				case 1:
					optionsSprites.x = 900;
					optionsSprites.y = 125;
				case 2:
					optionsSprites.x = 187;
					optionsSprites.y = 400;
				case 3:
					optionsSprites.x = 900;
					optionsSprites.y = 400;
				case 4:
					optionsSprites.x = 550;
					optionsSprites.y = 400;
				case 5:
					optionsSprites.x = 550;
					optionsSprites.y = 100;
                    // up and down, up and down
                    FlxTween.tween(optionsSprites, {y: optionsSprites.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
			}

            //this server to know which option and which
            optionsSprites.ID = i;
            optionsSprites.updateHitbox();
			group.add(optionsSprites);
		}

        shited = new FlxSprite(187, 125);
        shited.loadGraphic(Paths.image('mainMenuStuff/base/selection'));
        add(shited);

		bord1 = new FlxSprite();
		bord1.loadGraphic(Paths.image('bgsStuff/new Bg/bord'));
		add(bord1);

		bord2 = new FlxSprite();
		bord2.loadGraphic(Paths.image('bgsStuff/new Bg/upBord'));
		add(bord2);

        versionTxt = new FlxText(12, FlxG.height - 44, 0, "" + version, 12);
        versionTxt.setFormat(Paths.font("bullshit.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(versionTxt);

		farttext = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		farttext.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        farttext.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 4);
        farttext.alpha = 0;
		add(farttext);

        Lib.application.window.title = "Friday Night Funkin': VS OTHER BOB V2";
	}

	override function update(elapsed:Float){

		farttext.text = 'farts = ' + superfart + ' / 500';

        if (FlxG.keys.justPressed.FIVE) {
            MusicBeatState.switchState(new MasterEditorMenu());
        }

        if (FlxG.keys.justPressed.ONE) {
            MusicBeatState.switchState(new ShopState());
        }

        group.forEach(function(spr:FlxSprite)
        {
            if (FlxG.mouse.overlaps(spr)){
                FlxTween.tween(spr.scale,{x:1.1, y: 1.1}, 0.1);
                FlxTween.tween(shited.scale,{x:1.3, y: 1.3}, 0.1);

                shited.x = spr.x;
                shited.y = spr.y;
                
                curSelected = spr.ID;

                var shitChoice:String = coolOptions[curSelected];
    
                if (FlxG.mouse.justPressed){

                    switch(shitChoice){

                        case 'storyMode':
                            MusicBeatState.switchState(new StoryMenuState());
                            FlxG.mouse.visible = true;
                            trace('Story Mode');
    
                        case 'freeplay':
                            MusicBeatState.switchState(new FreeplayState());
                            FlxG.mouse.visible = true;
                            trace('Freeplay');
    
                        case 'credits':
                            MusicBeatState.switchState(new credits.CreditsState());
                            FlxG.mouse.visible = true;
                            trace('Credits');
    
                        case 'options':
                            MusicBeatState.switchState(new options.OptionsState());
                            FlxG.mouse.visible = true;
                            trace('Options');
    
                        case 'extras':
                            MusicBeatState.switchState(new ExtraMenuState());
                            FlxG.mouse.visible = true;
                            trace('extras lol');
    
                        case 'fart':
                            FlxG.sound.play(Paths.sound('fart'), 20);
                            trace('FART FART POO POO');
                            superfart++;
            
                            if(fartTween != null) {
                                fartTween.cancel();
                            }
                            farttext.scale.x = 1.075;
                            farttext.scale.y = 1.075;
                            fartTween = FlxTween.tween(farttext.scale, {x: 1, y: 1}, 0.2, {
                                onComplete: function(twn:FlxTween) {
                                    fartTween = null;
                                }
                            });
                    }
                }
            }else{
                FlxTween.tween(spr.scale,{x:1.0, y: 1.0}, 0.1);
            }
        });

		if (ClientPrefs.eastereggs){
            
            switch(superfart)
            {
                case 15:
                    farttext.alpha = 1;
    
                case 100:
                    farttext.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.CYAN, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                    farttext.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 4);
    
                case 200:
                    farttext.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.GREEN, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                    farttext.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 4);
    
                case 300:
                    farttext.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                    farttext.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 4);
                
                case 400:
                    farttext.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
                    farttext.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 4);
                    
                case 500: 
                    Application.current.window.alert('seriously man\nyou need a girlfriend\n', 'VS OTHER BOB.error');
                    Application.current.window.close();
            }
        }

        if (controls.BACK) {
            MusicBeatState.switchState(new TitleState());
        }

        super.update(elapsed);
	}
}