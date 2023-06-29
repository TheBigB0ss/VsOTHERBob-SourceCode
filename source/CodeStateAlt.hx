// i just did it for fun lmao

package;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class CodeStateAlt extends MusicBeatState
{
    var finger:FlxSprite;
    var codes:FlxText;

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
        FlxG.mouse.visible = true;

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

        itens = new FlxTypedGroup<FlxSprite>();
		add(itens);

        for (i in 0...botonsShit.length)
        {
            var botons:FlxSprite = new FlxSprite();
            botons.loadGraphic(Paths.image('botons/' + botonsShit[i]));
            botons.antialiasing = ClientPrefs.globalAntialiasing;

            switch(i)
            {
                case 0:
                    botons.x = 955;
                    botons.y = 84;

                case 1:
                    botons.x = 1054;
                    botons.y = 84;
                
                case 2:
                    botons.x = 1152;
                    botons.y = 84;
                
                case 3:
                    botons.x = 955;
                    botons.y = 273;

                case 4:
                    botons.x = 1054;
                    botons.y = 273;

                case 5:
                    botons.x = 1152;
                    botons.y = 273;
                
                case 6:
                    botons.x = 955;
                    botons.y = 430;

                case 7:
                    botons.x = 1054;
                    botons.y = 430;
                
                case 8:
                    botons.x = 1152;
                    botons.y = 430;

                case 9:
                    botons.x = 1054;
                    botons.y = 570;
            }

            botons.ID = i;
            botons.updateHitbox();
            itens.add(botons);
        }

        codes = new FlxText();
        codes.setFormat(Paths.font("vcr.ttf"), 80, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        codes.screenCenter();
        add(codes);

        super.create();
    }

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		itens.forEachAlive(function(spr:FlxSprite){
				
            spr.animation.play('idle');

    		if (FlxG.mouse.overlaps(spr))
			{
				if(FlxG.mouse.justPressed)
				{
					if(codes.text.length < 6)
					codes.text += spr.ID;
				}

                if(controls.ACCEPT)
                {
                    switch(codes.text)
                    {
                        case '6969':
                            MusicBeatState.switchState(new MainMenuState());
                                    
                        default:
                            codes.text = '';
                    }
                }
			}
		});
	} 
}