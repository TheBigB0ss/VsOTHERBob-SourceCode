package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.Assets;
import sys.FileSystem;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;

using StringTools;

class ExtraMenuState extends MusicBeatState
{
    var extraOptions:Array<String> = ['PC', 'Gallery', 'awards', 'game'];

    var bord1:FlxSprite;
	var bord2:FlxSprite;
	var bg:FlxSprite;
	var ass:FlxBackdrop;

    var shited:FlxSprite;

    var curSelected:Int = 0;

    var group:FlxTypedGroup<FlxSprite>;

    override function create(){

		super.create();
		FlxG.mouse.visible = true;
        FlxG.sound.music.volume = 0.8;

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

        for(i in 0...extraOptions.length){
            var extraSprites:FlxSprite = new FlxSprite();
            extraSprites.loadGraphic(Paths.image('mainMenuStuff/extras/' + extraOptions[i]));
            switch(i){

                case 0:
                    extraSprites.x = 187;
                    extraSprites.y = 125;

                case 1:
                    extraSprites.x = 550;
					extraSprites.y = 125;

                case 2:
                    extraSprites.x = 900;
					extraSprites.y = 125;

                case 3:
                    extraSprites.x = 550;
					extraSprites.y = 400;

                //case 4:
                    //extraSprites.x = 187;
					//extraSprites.y = 400;
            }
        
            extraSprites.ID = i;
            group.add(extraSprites);
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
    }

    override function update(elapsed:Float){

        group.forEach(function(spr:FlxSprite)
        {
            if (FlxG.mouse.overlaps(spr)){
                FlxTween.tween(spr.scale,{x:1.1, y: 1.1}, 0.1);
                FlxTween.tween(shited.scale,{x:1.3, y: 1.3}, 0.1);

                shited.x = spr.x;
                shited.y = spr.y;

                curSelected = spr.ID;

                var shitChoice:String = extraOptions[curSelected];
    
                if (FlxG.mouse.justPressed){
    
                    switch(shitChoice){
    
                        case 'PC':
                            MusicBeatState.switchState(new CodeState());
                            FlxG.mouse.visible = true;
                            trace('SUSSY CODES');
        
                        case 'Gallery':
                            MusicBeatState.switchState(new GalleryState());
                            FlxG.mouse.visible = true;
                            trace('thank so much for all the fan art :)');
        
                        case 'awards':
                            MusicBeatState.switchState(new AchievementsMenuState());
                            FlxG.mouse.visible = true;
                            trace('Achievements');
       
                        case 'game':
                            MusicBeatState.switchState(new MenuShit());
                            FlxG.mouse.visible = true;
                            trace('let\'s play: Super Bob World');

                        //case 'House':
                            //MusicBeatState.switchState(new SOOTH());
                            ///FlxG.mouse.visible = true;
                    }
                }
            }else{
                FlxTween.tween(spr.scale,{x:1.0, y: 1.0}, 0.1);
            }
        });
        // YES I USED THE SAME CODE AS IN THE SUPER MENU STATE, WHAT WILL YOU DO?!

        if (controls.BACK) {
            MusicBeatState.switchState(new SuperMenuState());
        }

        super.update(elapsed);
    }
}