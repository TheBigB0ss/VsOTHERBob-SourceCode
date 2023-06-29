package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = ['Controls', 'Adjust Delay and Combo', 'Graphics', 'Visuals and UI', 'Gameplay', 'Others', 'exit'];

	var newGroup:FlxTypedGroup<OptionsItem>;
	//var textGroup:FlxTypedGroup<OptionsItemText>;

	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	var finger:FlxSprite;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Others':
				openSubState(new options.Others());
			case 'exit':
				Sys.exit(1);
			case 'Adjust Delay and Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	var bg:FlxSprite;
	var bg1:FlxSprite;
	var bg2:FlxSprite;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

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

		bg = new FlxSprite().loadGraphic(Paths.image('bgsStuff/new Bg/bg'));
        bg.updateHitbox();
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

		bg1 = new FlxSprite().loadGraphic(Paths.image('bgsStuff/new Bg/bord'));
		bg2 = new FlxSprite(0,0).loadGraphic(Paths.image('bgsStuff/new Bg/upBord'));

		newGroup = new FlxTypedGroup<OptionsItem>();
		add(newGroup); 

		//textGroup = new FlxTypedGroup<OptionsItemText>();
		//add(textGroup);

		for (i in 0...options.length)
		{
			var optionsSprite:OptionsItem = new OptionsItem();
			optionsSprite.loadGraphic(Paths.image('optionsStuff/options/' + options[i]));
			optionsSprite.screenCenter();
			//optionsSprite.x = 550;
			//optionsSprite.y = 100;
			newGroup.add(optionsSprite);

			//var optionText:OptionsItemText = new OptionsItemText();
			//optionText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLACK, CENTER);
			//optionText.text = options[i];
			//optionText.x = optionsSprite.x;
			//optionText.y = optionsSprite.y;
			//textGroup.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true, false);
		//add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true, false);
		//add(selectorRight);

		add(bg1);
		add(bg2);

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
			FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
			FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new SuperMenuState());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		//for (item in textGroup.members)
		//{
			//FlxTween.angle(item, -5, 5, Conductor.crochet / 300, {ease: FlxEase.sineInOut, type: PINGPONG});
			//item.targetY = bullShit - curSelected;
			//bullShit++;
		//}

		for (item in newGroup.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}