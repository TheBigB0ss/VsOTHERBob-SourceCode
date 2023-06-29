package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;

class FlashingState2 extends MusicBeatState
{
	public static var leftState:Bool = false;

	var tvBg:FlxSprite;
	var tvbords:FlxSprite;

	var nine = FlxG.keys.justPressed.NINE;

	var warnText:FlxText;

	var somethinglol:FlxSprite;

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		tvBg = new FlxSprite(0, 0).loadGraphic(Paths.image('bgsStuff/TV Bg'));
		add(tvBg);

		somethinglol = new FlxSprite(550, 500).loadGraphic(Paths.image('IDK')); 
		somethinglol.frames = Paths.getSparrowAtlas('IDK');
		somethinglol.screenCenter();
		somethinglol.animation.addByPrefix('idle', "idk", 24);
		somethinglol.animation.play('idle');
		somethinglol.scale.set(10.9, 10.9);
		somethinglol.setGraphicSize(Std.int(somethinglol.width * 0.4));
		//add(somethinglol);

		tvbords = new FlxSprite(0, 0).loadGraphic(Paths.image('bgsStuff/TV Bords'));
		add(tvbords);

		warnText = new FlxText(0, 0, FlxG.width,
			"just one more thing.\n 
			In the midnight Snack song has flashing lights,\n
			you can't turn them off so be careful",
			32);
		warnText.setFormat("Comic Sans MS Bold", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		warnText.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 4);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT) {

				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxTween.tween(tvBg, {alpha:0}, 1, {ease: FlxEase.sineIn});
				if(!back) {
					ClientPrefs.flashing = true;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('award'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new FlashingState3());
						});
					});
				}
			}
		}

		if (FlxG.keys.justPressed.NINE){ 
			{ 
				Sys.command('start ' + Paths.txt('JACK'));
				CoolUtil.browserLoad('https://www.youtube.com/watch?v=mOw9syNduxk');
				Sys.exit(1);
			}
		}

		super.update(elapsed);
	}
}