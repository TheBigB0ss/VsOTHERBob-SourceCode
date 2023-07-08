package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import lime.utils.Assets;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
using StringTools;

class GalleryState extends MusicBeatState
{
	var bg:FlxSprite;
	var bg1:FlxSprite;

	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	private static var curSelected:Int = 0;
	
	var image:FlxSprite;
	var creditsText:FlxText;

	var lmao:String = 'press enter to see that person\'s twitter';
	var text:FlxText;

	var thing:Array<String> = [
		'TheAnotherBobFLA',
		'7quid Bob',
		'cool ass',
		'outro_bob_2',
		'3D Bob',
		'Alternate',
		'another paper bob',
		'Big Bob',
		'bob bob bob',
		'Confronting the other one',
		'cool B)',
		'cool bob',
		'Sad Bob remake',
		'pogs Bob',
		'name',
		'i fucking hate you Skyy',
		'Starveds',
		'LOGO OST',
		'Aniversario',
		'Crime',
		'ip',
		'KRIMA',
		'LEGACY',
		'shadow',
		'LOGO OST OURPLE EDITION',
		'ohhh my god another bob',
		'UwU',
		'TV',
		'super cool poster',
		'Paper Bob',
		'nice fan bob',
		'top',
		'just bob',
		'Drake',
		'face',
		'YOU!!!!!!!!!!!!!!!!!!!',
		'Terraria Bob',
		'south park',
		'ourple Bob',
		'digital thing',
		'smile',
		'BiteOSTPortrait',
		'trolled',
		'[insert bob fanart name here]',
		'oh no',
		'Fun Fact'
	];

	var credits:Array<Dynamic> = [
		['art by: Tekaruki', 'https://twitter.com/Takaruki_008'],
		['art by: 4rrthhhhh', 'https://twitter.com/4rrthhhhh'],
		['art by: ApolloX3', 'https://twitter.com/Apollo_X3'],
		['art by: Yester', 'https://twitter.com/omgYester'],
		['art by: Maxximus', 'https://twitter.com/MAXXIMUS235'],
		['art by: Maxximus', 'https://twitter.com/MAXXIMUS235'],
		['art by: Luluoao34', 'https://twitter.com/Luluoao34'],
		['art by: YuBiNhu', 'https://twitter.com/_YuBiNhu'],
		['art by: FaoN84945', 'https://twitter.com/FaoN84945'],
		['art by: M4ccros', 'https://twitter.com/CauaMattoslol'],
		['art by: JackGD9', 'https://twitter.com/JackGD9'],
		['art by: IPPONdarY', 'https://twitter.com/IPPONdarY'],
		['art by: Smwaart', 'https://twitter.com/smwaart'],
		['art by: YuBiNhu', 'https://twitter.com/_YuBiNhu'],
		['art by: QuietWater', 'https://twitter.com/QuietWatn'], 
		['i fucking hate you Skyy', 'https://twitter.com/LiliceXD_'],
		['art by: Octavio', 'https://twitter.com/octavio12n'],
		['art by: Maxximus', 'https://twitter.com/MAXXIMUS235'],
		['art by: Matheus ahhh', 'https://twitter.com/MatheusAhhh'],
		['art by: Maxximus', 'https://twitter.com/MAXXIMUS235'],
		['art by: M4ccros', 'https://twitter.com/CauaMattoslol'],
		['art by: JackGD9', 'https://twitter.com/JackGD9'],
		['art by: Maxximus', 'https://twitter.com/MAXXIMUS235'],
		['art by: YuBiNhu', 'https://twitter.com/_YuBiNhu '],
		['art by: Maxximus', 'https://twitter.com/MAXXIMUS235'],
		['art by: Octavio', 'https://twitter.com/octavio12n'],
		['art by: Maxximus', 'https://twitter.com/MAXXIMUS235'],
		['art by: Maxximus', 'https://twitter.com/MAXXIMUS235'],
		['art by: Maxximus', 'https://twitter.com/MAXXIMUS235'],
		['art by: Matheus ahhh', 'https://twitter.com/MatheusAhhh'],
		['art by: Skyy', 'https://twitter.com/LiliceXD_'],
		['art by: NDC', 'https://twitter.com/ndcpalitin13'],
		['art by: its an Dani', 'https://twitter.com/its_a_deimos'],
		['art by: its an Dani', 'https://twitter.com/its_a_deimos'],
		['art by: NDC', 'https://twitter.com/ndcpalitin13'],
		['art by: NDC', 'https://twitter.com/ndcpalitin13'],
		['art by: babakolol', 'https://twitter.com/Babakaaaaa'],
		['art by: JakeFreeBird', 'https://twitter.com/jakefree_bird'],
		['art by: BiellDF', 'https://twitter.com/df_biell'],
		['art by: Luluoao34', 'https://twitter.com/Luluoao34'],
		['art by: CamomilaXD', 'https://twitter.com/CamomilaXD'],
		['art by: Octavio', 'https://twitter.com/octavio12n'],
		['art by: Smwaart', 'https://twitter.com/smwaart'],
		['art by: Skyy', 'https://twitter.com/LiliceXD_'],
		[':|', 'https://twitter.com/smwaart'],
		[':)', '']
	];

	override function create()
    {
		bg = new FlxSprite();
		bg.loadGraphic(Paths.image('bgsStuff/cool bg aaa'));
		add(bg);

		image = new FlxSprite();
		add(image);

		bg1 = new FlxSprite();
		bg1.loadGraphic(Paths.image('bgsStuff/bord'));
		add(bg1);

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

		creditsText = new FlxText();
		creditsText.setFormat(Paths.font("bullshit.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(creditsText);

		text = new FlxText(12, FlxG.height - 44, 0, "" + lmao, 12);
		text.setFormat(Paths.font("bullshit.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(text);

		changeImage();
    }

	override function update(elapsed:Float){

		if(thing.length > 1)
		{
			if (controls.UI_RIGHT){
				rightArrow.animation.play('press');
			}else{
				rightArrow.animation.play('idle');
			}

			if (controls.UI_LEFT){
				leftArrow.animation.play('press');
			}else{
			    leftArrow.animation.play('idle');
			}
			
			if (FlxG.mouse.wheel != 0)
			{
				changeImage(0 - FlxG.mouse.wheel);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			
			if (controls.UI_RIGHT_P)
			{
				changeImage(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		
			if (controls.UI_LEFT_P)
			{
				changeImage(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		if (controls.BACK) {
            MusicBeatState.switchState(new ExtraMenuState());
        }

		if(controls.ACCEPT) {
			CoolUtil.browserLoad(credits[curSelected][1]);
			trace('open link' + credits[curSelected][1]);
		}
	}

	function changeImage(change:Int = 0)
	{ 
		curSelected += change;

		if (curSelected < 0)
			curSelected = thing.length - 1;

		if (curSelected >= thing.length)
			curSelected = 0;

		if (curSelected < 0)
			curSelected = credits.length - 1;

		if (curSelected >= credits.length)
			curSelected = 0;

		image.loadGraphic(Paths.image('gallery/arts/' + thing[curSelected]));
		image.screenCenter();

		creditsText.text = (credits[curSelected][0]);
		creditsText.screenCenter(X);
	}
}