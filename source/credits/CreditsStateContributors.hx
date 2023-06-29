package credits;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class CreditsStateContributors extends MusicBeatState
{
	var bg:FlxSprite;
	var text:FlxText;

	override function create()
	{
		FlxG.mouse.visible = true;

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('bgsStuff/cool bg aaa'));
		bg.screenCenter();
		add(bg);

		text = new FlxText(15, FlxG.height - 74, 0);
		text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.scrollFactor.set();
		text.text = 'Contributors';
		text.borderSize = 1.25;
		add(text);

		var icon1:Credits = new Credits(160, 125, 'Jabirugo', '-Jabirugo-\nmade the Ourple BG and V2 logo');
        add(icon1);

		var icon2:Credits = new Credits(315, 125, 'tanuki', '-tanuki-\nmade the System error Bg');
        add(icon2);

		var icon3:Credits = new Credits(510, 125, 'SAR', '-sar-\nmade the Inst of "malware" and "alt"');
        add(icon3);

		var icon4:Credits = new Credits(676, 125, 'Prince Fizz', '-Prince Fizz-\nmade the inst of the\n song Suffering');
        add(icon4);

		var icon5:Credits = new Credits(160, 295, 'babakolol', '-babakolol-\nmade pixel bob icon');
        add(icon5);

		var icon6:Credits = new Credits(320, 295, 'puddinha', '-puddinha-\nicon artist');
        add(icon6);
	}
}