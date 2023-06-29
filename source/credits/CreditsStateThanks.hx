package credits;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class CreditsStateThanks extends MusicBeatState
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
		text.text = 'special thanks';
		text.borderSize = 1.25;
		add(text);

		var icon1:Credits = new Credits(160, 125, 'reddudexd', '-reddude-\nwe are doing a collab OH SHIT AAAAAA,\n and he made the poster for 1.5');
        add(icon1);

		var icon2:Credits = new Credits(290, 125, 'nati', '-Nati-\nagoagoagoagoagoagoagoagoaog');
        add(icon2);

		var icon3:Credits = new Credits(455, 125, 'Jacc', '-Jacc Pinger-\ncool friend');
        add(icon3);

		var icon4:Credits = new Credits(595, 125, 'abc', '-Mythical Funk-\ncool team that\n vs OTHER Bob is a part of');
        add(icon4);

		var icon5:Credits = new Credits(730, 125, 'BiellDF', '-BiellDF-\nfnf');
        add(icon5);
	}
}