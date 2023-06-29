package;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;

class MathState extends MusicBeatState
{
    var black:FlxSprite;
    var greenBlock:FlxSprite;
    var finger:FlxSprite;
    var ok:FlxSprite;

    var codes:FlxText;
    var question:FlxText;

    var correct:Bool;

    public static var number1:Int = 1;
    //static var number2:Int = 1;

    var itens:FlxTypedGroup<FlxSprite>;
    var botonsShit:Array<String> = [
        '0',
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9'
    ];

    override function create()
    {
        super.create();

        FlxG.mouse.visible = true;

        finger = new FlxSprite();
        finger.makeGraphic(15, 15, FlxColor.TRANSPARENT);
        finger.loadGraphic(Paths.image('cursor/finger'));
        FlxG.mouse.load(finger.pixels);

        black = new FlxSprite().loadGraphic(Paths.image('bgsStuff/blackBG'));
        add(black);

        greenBlock = new FlxSprite().loadGraphic(Paths.image('Math/pad'));
        greenBlock.screenCenter();
        add(greenBlock);

        ok = new FlxSprite().loadGraphic(Paths.image(''));
        ok.screenCenter();
        add(ok);

        itens = new FlxTypedGroup<FlxSprite>();
		add(itens);

        codes = new FlxText();
        codes.setFormat(Paths.font("vcr.ttf"), 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        codes.screenCenter();
        add(codes);

        question = new FlxText();
        question.setFormat(Paths.font("vcr.ttf"), 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(question);

        for (i in 0...botonsShit.length)
        {
            var botons:FlxSprite = new FlxSprite();
            botons.frames = Paths.getSparrowAtlas('botons/botons_' + botonsShit[i]);

            switch(i)
            {
                case 0:
                    botons.x = 617;
                    botons.y = 617;

                case 1:
                    botons.x = 542;
                    botons.y = 555;
                
                case 2:
                    botons.x = 617;
                    botons.y = 570;
                
                case 3:
                    botons.x = 693;
                    botons.y = 557;

                case 4:
                    botons.x = 540;
                    botons.y = 512;

                case 5:
                    botons.x = 617;
                    botons.y = 525;
                
                case 6:
                    botons.x = 697;
                    botons.y = 511;

                case 7:
                    botons.x = 536;
                    botons.y = 463;
                
                case 8:
                    botons.x = 616;
                    botons.y = 476;

                case 9:
                    botons.x = 699;
                    botons.y = 463;
            }

            botons.ID = i;
            itens.add(botons);
        }
    }

    function change()
    {
        number1 = FlxRandom.int(2,726);
        //number2 = FlxRandom.int(2,424);

        //var number3:Bool;
        //var number4:Int;

       // if (number3 == true)
       // {
         //   number4 = number1 + number2;
        //}
        //if (number3 == false)
       // {
           // number4 = number1 - number2;
        //}
    
        //question.text = number1;

        //if(botonsShit += number4)
        //{
          //  correct = true;
       // }
        
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        itens.forEachAlive(function(spr:FlxSprite){
            
            if (FlxG.mouse.overlaps(spr))
            {
                if(FlxG.mouse.justPressed)
                {
                    if(codes.text.length < 7)
                    codes.text += spr.ID;
                }
            }

            if (FlxG.mouse.overlaps(ok))
            {
                if(FlxG.mouse.justPressed)
                { 
                    if(correct == true)
                    {
                        change();
                    }
                }
            }
        });
    } 
}