package;

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
import Achievements;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;

using StringTools;

class AchievementsMenuState extends MusicBeatState
{
	#if ACHIEVEMENTS_ALLOWED
	var options:Array<String> = [];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	private var achievementArray:Array<AttachedAchievement> = [];
	private var achievementIndex:Array<Int> = [];
	private var descText:FlxText;

	// bg things lol
	var bg1:FlxSprite;
	var bg2:FlxSprite;
	var cat:FlxSprite;
	var ass:FlxBackdrop;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Achievements Menu", null);
		#end

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bgsStuff/new Bg/bg'));
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = ClientPrefs.globalAntialiasing;
		add(menuBG);

		ass = new FlxBackdrop(Paths.image('ass BG'), 0.2, 0, true, true);
		ass.velocity.set(-10, -10);
		ass.updateHitbox();
		ass.alpha = 0.5;
		ass.screenCenter(X);
		add(ass);

		cat = new FlxSprite(780, 125).loadGraphic(Paths.image('AwardsStuff/SPIN CAT')); 
		cat.frames = Paths.getSparrowAtlas('AwardsStuff/SPIN CAT');
		cat.animation.addByPrefix('idle', "spin-kitty-cat_", 24);
		cat.animation.play('idle');
		cat.antialiasing = ClientPrefs.globalAntialiasing;
		cat.setGraphicSize(Std.int(cat.width * 0.4));
		cat.scale.set(1.3, 1.3);
		add(cat);
		FlxTween.tween(cat, {y: cat.y - 50}, 1, {ease: FlxEase.quadInOut, type: PINGPONG});

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		Achievements.loadAchievements();
		for (i in 0...Achievements.achievementsStuff.length) {
			if(!Achievements.achievementsStuff[i][4] || Achievements.achievementsMap.exists(Achievements.achievementsStuff[i][2])) {
				options.push(Achievements.achievementsStuff[i]);
				achievementIndex.push(i);
			}
		}

		for (i in 0...options.length) {
			var achieveName:String = Achievements.achievementsStuff[achievementIndex[i]][2];
			var optionText:Alphabet = new Alphabet(0, (100 * i) + 210, Achievements.isAchievementUnlocked(achieveName) ? Achievements.achievementsStuff[achievementIndex[i]][0] : '????????', false, false);
			optionText.isMenuItem = true;
			optionText.x += 280;
			optionText.xAdd = 200;
			optionText.targetY = i;

			grpOptions.add(optionText);

			var icon:AttachedAchievement = new AttachedAchievement(optionText.x - 105, optionText.y, achieveName);
			icon.sprTracker = optionText;
			achievementArray.push(icon);
			add(icon);
			FlxTween.angle(icon, -5, 5, Conductor.crochet / 300, {ease: FlxEase.sineInOut, type: PINGPONG});
		}

		descText = new FlxText(150, 600, 980, "", 32);
		descText.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);
		FlxTween.angle(descText, -5, 5, Conductor.crochet / 300, {ease: FlxEase.sineInOut, type: PINGPONG});
		changeSelection();

		bg1 = new FlxSprite().loadGraphic(Paths.image('bgsStuff/new Bg/bord'));
		bg1.updateHitbox();
		bg1.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg1);

		bg2 = new FlxSprite().loadGraphic(Paths.image('bgsStuff/new Bg/upBord'));
		bg2.updateHitbox();
		bg2.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg2);

		super.create();
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
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new SuperMenuState());
		}
	}

	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
			}
		}

		for (i in 0...achievementArray.length) {
			achievementArray[i].alpha = 0.6;
			if(i == curSelected) {
				achievementArray[i].alpha = 1;
			}
		}
		descText.text = Achievements.achievementsStuff[achievementIndex[curSelected]][1];
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}
	#end
}