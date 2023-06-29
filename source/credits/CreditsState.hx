package credits;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class CreditsState extends MusicBeatState
{
	var ESCAPE = FlxG.keys.justPressed.ESCAPE;

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
		text.text = 'Vs OTHER Bob Team';
		text.borderSize = 1.25;
		add(text);

		var icon1:Credits = new Credits(130, 125, 'big_boss', '-The Big Boss-\ndirector, mod creator and main coder');
        add(icon1);

		var icon2:Credits = new Credits(285, 125, 'smwaart', '-smwaart-\nco-director of the mod and artist\n of backgrounds and notes');
        add(icon2);

		var icon3:Credits = new Credits(415, 125, 'cool', '-Max-\nmods lead artist and animator');
        add(icon3);

		var icon4:Credits = new Credits(543, 125, 'Sanco', '-Sanco-\n3D artist and artist in general\nand composer of Golden Core');
        add(icon4);

		var icon5:Credits = new Credits(690, 125, 'Axel', '-Axel-\ncool artist :)\n and pixel artist');
        add(icon5);

		var icon6:Credits = new Credits(844, 125, 'M4ccros', '-M4ccros-\nmain composer');
        add(icon6);

		var icon7:Credits = new Credits(984, 125, 'la Zer0', '-Zero-\ncomposer');
        add(icon7);

		var icon8:Credits = new Credits(1125, 125, 'lol', '-hectork-\ncomposer');
        add(icon8);

		var icon9:Credits = new Credits(160, 250, 'Mint', '-Synth Mints-\ncomposer of T song');
        add(icon9);

		var icon10:Credits = new Credits(285, 250, 'abc', '-Doctor of Music-\nmade the song Goffy Funkin');
        add(icon10);

		var icon11:Credits = new Credits(421, 250, 'matheusahhh', '-Matheus Ahh-\nhelped me with the code');
        add(icon11);

		var icon12:Credits = new Credits(572, 250, 'oc2', '-Octavio-\nmain Charter');
        add(icon12);

		var icon13:Credits = new Credits(712, 250, 'Coolte', '-coolte-\ndid the pixel bob and\ncutscene animator');
        add(icon13);

		var icon14:Credits = new Credits(874, 250, 'dani', '-Its An Dani-\nmade the new Drake sprites');
        add(icon14);

		var icon15:Credits = new Credits(1065, 250, 'Fao', '-Fao-\nartist');
        add(icon15);

		var icon16:Credits = new Credits(160, 390, '4rrthhhh', '-4rrthhhh-\nartist');
        add(icon16);
	}
}