package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flash.media.Sound;

using StringTools;

class Selected extends MusicBeatState
{
	var bfsSprite:Array<String> = ['boyfriend', 'boyfriend amongus', 'boyfriend south park', 'bf3D'];
	var bfs:Array<String> = ['bf', 'Mongus BF', 'bf_sp', 'BF3D'];

	var bg:FlxSprite;

	var images:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	private static var curSelected:Int = 0;

	public static var ricardoMilos:String;

	override function create()
	{
		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('bgsStuff/cool bg aaa'));
		add(bg);

		images = new FlxSprite();
		add(images);

		var ui_tex = Paths.getSparrowAtlas('ArrowsShit lol');

		leftArrow = new FlxSprite(91, 505);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(leftArrow);

		rightArrow = new FlxSprite(965, 505);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		add(rightArrow);

		change();
	}

	override function update(elapsed:Float){

		if(bfsSprite.length > 1)
		{
			if (controls.UI_RIGHT)
				rightArrow.animation.play('press');
			else
				rightArrow.animation.play('idle');
	
			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');	
			
			if (controls.UI_RIGHT_P)
			{
				change(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		
			if (controls.UI_LEFT_P)
			{
				change(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		if (controls.BACK) {
            MusicBeatState.switchState(new ExtraMenuState());
        }

		if(controls.ACCEPT)
		{
			ricardoMilos = bfs[curSelected];
			MusicBeatState.switchState(new FreeplayState());
		}
	}

	function change(changeShit:Int = 0){

		curSelected += changeShit;

		if (curSelected < 0)
			curSelected = bfsSprite.length - 1;

		if (curSelected >= bfsSprite.length)
			curSelected = 0;

		if (curSelected < 0)
			curSelected = bfs.length - 1;

		if (curSelected >= bfs.length)
			curSelected = 0;

		images.loadGraphic(Paths.image('bfs/' + bfsSprite[curSelected]));
		images.screenCenter();
	}
}