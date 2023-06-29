package;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

using StringTools;

class SOOTH extends MusicBeatState
{
	var options:Array<String> = [
		'start',
		'quit'
	];

	var bg:FlxSprite;
	var logo:FlxSprite;

	var arrow:FlxText;
	var arrowShit:FlxTypedGroup<FlxText>;

	var curSelected:Int = 0;

	override function create(){

		arrowShit = new FlxTypedGroup<FlxText>();
		add(arrowShit);

		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('SOOTH/bg'));
		bg.screenCenter();
		add(bg);

		logo = new FlxSprite();
		logo.loadGraphic(Paths.image('SOOTH/logo'));
		logo.screenCenter(X);
		add(logo);

		arrow = new FlxText();
		arrow.setFormat(Paths.font("VCR OSD Mono.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		arrow.text = '>';
		add(arrow);

		for(i in 0...options.length){
			var shit:FlxText = new FlxText();
			shit.setFormat(Paths.font("VCR OSD Mono.ttf"), 21, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			shit.text = options[curSelected];
			arrowShit.add(shit);

			switch(i){
				case 0:
					shit.x = 550;
					shit.y = 125;

				case 1:
					shit.x = 550;
					shit.y = 400;
			}
		}
	}

	override function update(elapsed:Float){

		if (controls.UI_UP_P)
		{
			changeShit(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeShit(1);
		}

		if(controls.ACCEPT){
			var choiceShit:String = options[curSelected];

			switch(choiceShit){

				case 'start':
					LoadingState.loadAndSwitchState(new PlayState());
                                    
					PlayState.isStoryMode = false;
					PlayState.SONG = Song.loadFromJson('bite', 'bite');
					LoadingState.loadAndSwitchState(new PlayState());

				case 'quit':
					MusicBeatState.switchState(new ExtraMenuState());
			}
		}
	}

	function changeShit(change:Int = 0){
		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;

		if (curSelected >= options.length)
			curSelected = 0;

		for (item in arrowShit.members){
			arrow.x = item.x - 63;
			arrow.y = item.y;
		}
	}
}
