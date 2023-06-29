package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Json;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import options.GraphicsSettingsSubState;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;
typedef TitleData =
{
	
	titlex:Float,
	titley:Float,
	startx:Float,
	starty:Float,
	gfx:Float,
	gfy:Float,
	backgroundSprite:String,
	bpm:Int
}
class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var backgroundTitle:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var version:FlxSprite;
	var bob:FlxSprite;
	var random:FlxSprite;
	var shit:FlxSprite;

	var text:FlxText;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var mustUpdate:Bool = false;
	
	var titleJSON:TitleData;

	var balls:Int = 0;

	var finger:FlxSprite;
	
	public static var updateVersion:String = '';

	override public function create():Void
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		WeekData.loadTheFirstEnabledMod();
		
		//trace(path, FileSystem.exists(path));

		/*#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}
		#end*/

		if(ClientPrefs.mouse == 'finger')
		{
			finger = new FlxSprite();
			finger.makeGraphic(15, 15, FlxColor.TRANSPARENT);
			finger.loadGraphic(Paths.image('cursor/finger'));
			FlxG.mouse.load(finger.pixels);
		}
		
		if(ClientPrefs.mouse == 'pointer')
		{
			finger = new FlxSprite();
			finger.makeGraphic(15, 15, FlxColor.TRANSPARENT);
			finger.loadGraphic(Paths.image('cursor/newcursor'));
			FlxG.mouse.load(finger.pixels);
		}
		
		if(ClientPrefs.mouse == 'mario')
		{
			finger = new FlxSprite();
			finger.makeGraphic(15, 15, FlxColor.TRANSPARENT);
			finger.loadGraphic(Paths.image('cursor/Mario'));
			FlxG.mouse.load(finger.pixels);
		}
		
		#if CHECK_FOR_UPDATES
		if(!closedState) {
			trace('checking for update');
			var http = new haxe.Http("https://raw.githubusercontent.com/ShadowMario/FNF-PsychEngine/main/gitVersion.txt");
			
			http.onData = function (data:String)
			{
				updateVersion = data.split('\n')[0].trim();
				var curVersion:String = MainMenuState.psychEngineVersion.trim();
				trace('version online: ' + updateVersion + ', your version: ' + curVersion);
				if(updateVersion != curVersion) {
					trace('versions arent matching!');
					mustUpdate = true;
				}
			}
			
			http.onError = function (error) {
				trace('error: $error');
			}
			
			http.request();
		}
		#end

		FlxG.mouse.visible = true;
		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		FlxG.save.bind('funkin', 'ninjamuffin99');
		
		ClientPrefs.loadPrefs();
		
		Highscore.load();

		// IGNORE THIS!!!
		titleJSON = Json.parse(Paths.getTextFromFile('images/gfDanceTitle.json'));

		if(!initialized && FlxG.save.data != null && FlxG.save.data.fullscreen) {
			FlxG.fullscreen = FlxG.save.data.fullscreen;
			//trace('LOADED FULLSCREEN SETTING!!');
		}

		if (FlxG.save.data.weekCompleted != null) {
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == true && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			if (!DiscordClient.isInitialized)
			{
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end

			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
				
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

				FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
		}

		Conductor.changeBPM(titleJSON.bpm);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite();
		
		if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.length > 0 && titleJSON.backgroundSprite != "none"){
			bg.loadGraphic(Paths.image(titleJSON.backgroundSprite));
		}else{
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		}
		
		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		logoBl = new FlxSprite(titleJSON.titlex, titleJSON.titley);
		logoBl.frames = Paths.getSparrowAtlas('TitleThings/logov2');
		
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'bop', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
	    logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		version = new FlxSprite(570, 370).loadGraphic(Paths.image('TitleThings/v2_animation_new')); 
		version.frames = Paths.getSparrowAtlas('TitleThings/v2_animation_new');
		version.animation.addByPrefix('idle', "logo bumpin", 24);
		version.animation.play('idle');
		version.antialiasing = ClientPrefs.globalAntialiasing;
		version.scale.set(3.1, 3.1);
		version.setGraphicSize(Std.int(version.width * 0.4));

		backgroundTitle = new FlxSprite().loadGraphic(Paths.image('bgsStuff/titleBG'));
        backgroundTitle.screenCenter();
        backgroundTitle.antialiasing = ClientPrefs.globalAntialiasing;

		swagShader = new ColorSwap();
		gfDance = new FlxSprite(titleJSON.gfx, titleJSON.gfy);

		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;

		add(backgroundTitle);
		
		//add(gfDance);
		gfDance.shader = swagShader.shader;
		add(logoBl);
		//add(version);
		// logo things
		FlxTween.angle(logoBl, -5, 5, Conductor.crochet / 300, {ease: FlxEase.sineInOut, type: PINGPONG});
		FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// version things 
		FlxTween.angle(version, 5, -5, Conductor.crochet / 300, {ease: FlxEase.sineInOut, type: PINGPONG});
		FlxTween.tween(version, {y: version.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});

		logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(titleJSON.startx, titleJSON.starty);
		#if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/titleEnter.png";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "mods/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)){
			path = "assets/images/titleEnter.png";
		}
		//trace(path, FileSystem.exists(path));
		titleText.frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile(path),File.getContent(StringTools.replace(path,".png",".xml")));
		#else
		
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		#end
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		text = new FlxText(480, FlxG.height - 58, 0);
		text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.scrollFactor.set();
		text.text = 'press ENTER';
        text.scale.set(1.4, 1.4);
		//add(text);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite(0, 0).loadGraphic(Paths.image('bgsStuff/titleBG'));
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		shit = new FlxSprite(0, FlxG.height * 0.55).loadGraphic(Paths.image('TitleThings/logoBumpinforbob')); 
		shit.frames = Paths.getSparrowAtlas('TitleThings/logoBumpinforbob');
		shit.animation.addByPrefix('idle', "logo bumpin", 24);
		shit.animation.play('idle');
		shit.antialiasing = ClientPrefs.globalAntialiasing;
		shit.setGraphicSize(Std.int(shit.width * 0.8));
		shit.updateHitbox();
		shit.screenCenter(X);
		shit.visible = false;
		add(shit);

		bob = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('TitleThings/bob_logo'));
		add(bob);
		bob.visible = false;
		bob.setGraphicSize(Std.int(bob.width * 0.8));
		bob.updateHitbox();
		bob.screenCenter(X);
		bob.antialiasing = ClientPrefs.globalAntialiasing;

		random = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('TitleThings/random/RandomShit-' + FlxG.random.int(1, 11)));
		add(random);
		random.visible = false;
		random.setGraphicSize(Std.int(bob.width * 0.8));
		random.updateHitbox();
		random.screenCenter(X);
		random.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;

	var onetime:Bool = false;

	override function update(elapsed:Float)
    {
		if (FlxG.keys.justPressed.B)
			if (balls == 0)
				balls = 1;
		if (FlxG.keys.justPressed.A)
			if (balls == 1)
				balls = 2;
		if (FlxG.keys.justPressed.L)
			if (balls == 2)
				balls = 3;
		if (FlxG.keys.justPressed.L)
			if (balls == 3)
				balls = 4;
		if (FlxG.keys.justPressed.S)
			if (balls == 4)
				balls = 5;
	
		if(balls == 5 && !onetime){
			onetime = true;
			CoolUtil.browserLoad('https://www.youtube.com/watch?v=G4KkJ0Q8VgI');
		}
        
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (initialized && !transitioning && skippedIntro)
		{
			if(pressedEnter)
			{
				text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.YELLOW, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('Quandale'), 0.7);

				transitioning = true;

				FlxTween.tween(titleText, {y: FlxG.height + titleText.height}, 0.5);

				new FlxTimer().start(1, function(tmr:FlxTimer) {
					// MusicBeatState.switchState(new ShopState());
				    MusicBeatState.switchState(new SuperMenuState());
					// MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
			}
		}

		if (FlxG.mouse.wheel != 0)
		{
			FlxG.camera.zoom += (FlxG.mouse.wheel / 6);
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null) {
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}

			/*var money:FlxText = new FlxText(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			moeny.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}*/
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);

			/*var coolText:FlxText = new FlxText(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);*/
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0;
	public static var closedState:Bool = false;

	override function beatHit()
	{
		super.beatHit();

		FlxTween.tween(FlxG.camera, {zoom:1.05}, 0.5, {ease: FlxEase.quadOut, type: BACKWARD});

		if(logoBl != null) 
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			danceLeft = !danceLeft;
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					#if PSYCH_WATERMARKS
					createCoolText(['VS OTHER BOB TEAM'], 15);
					#end
				case 3:
					#if PSYCH_WATERMARKS
					addMoreText('PRESENTS', 15);
					#else
					addMoreText('PRESENTS');
					#end
				case 4:
					deleteCoolText();
				case 5:
					#if PSYCH_WATERMARKS
					createCoolText(['ASSOCIATION', 'WITH'], -40);
					#else
					createCoolText(['WITH', ''], -40);
					#end
				case 7:
					addMoreText('BOB', -40);
					bob.visible = true;
				case 8:
					deleteCoolText();
					bob.visible = false;
				case 9:
					/*if (!skippedIntro)
					{
						FlxG.sound.music.fadeIn(0.01, 0.7, 0);
					}*/
					addMoreText('LITERALLY EVERY', -40);
				case 10:
					addMoreText('COPY CAT MOD EVER');
				case 11:
					random.visible = true;
				case 12:
					//FlxG.sound.music.fadeIn(0.01, 0, 0.7);
					deleteCoolText();
					random.visible = false;
				case 13:
					createCoolText([curWacky[0]]);
				case 14:
					addMoreText(curWacky[1]);
				case 15:
					deleteCoolText();
				case 16:
					addMoreText('VS');
				case 17:
					addMoreText('OTHER');
				case 18:
					addMoreText('BOB');
				case 19:
					shit.visible = true;
				case 20:
					deleteCoolText();
					shit.visible = false;
				case 21:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;

	function skipIntro():Void {
		if (!skippedIntro)
		{
			remove(credGroup);

			bob.destroy();
			shit.destroy();
			random.destroy();

			FlxG.camera.flash(FlxColor.WHITE, 4);

			skippedIntro = true;
		}
	}
}
