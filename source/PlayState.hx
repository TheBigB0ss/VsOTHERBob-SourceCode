package;

import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSave;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import openfl.filters.ShaderFilter;
import lime.app.Application;
import lime.ui.Window;
import flixel.addons.display.FlxBackdrop;
import openfl.geom.Rectangle;
import openfl.display.Sprite;
import flixel.math.FlxRandom;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup;
import flixel.ui.FlxButton;
import flixel.addons.display.FlxTiledSprite;
import flixel.addons.ui.FlxUIInputText;
#if sys
import sys.FileSystem;
#end
import flixel.util.FlxSpriteUtil;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2],
		['Shit', 0.4],
		['Bad', 0.5],
		['Bruh', 0.6],
		['Meh', 0.69],
		['Nice', 0.7],
		['Good', 0.8],
		['Great', 0.9],
		['Sick!', 1],
		['Perfect!!', 1]
	];

	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	public var newDadMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var newDadMap:Map<String, Character> = new Map<String, Character>();
	#end

	// Cursor Sprite
	var finger:FlxSprite;

	// sup matheus
	public var status:FlxText;
	
	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public static var firstStart:Bool = true;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;
	
	// cool groups
	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public var newDadGroup:FlxSpriteGroup;

	// cool shit B)
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	// cool characters
	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;
	public var newDad:Character;

	var twoOpponents:Bool = false;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	// Starved Bob things
	public var medo:Float = 0;
    public var barraMedo:FlxBar;
	public var barraMedoBG:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	private var curSong:String = "";

	// gameplay shit
	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	private var healthBarBOB:AttachedSprite;
	private var heltfbarOV:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;
	
	// rating
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	
	// song shit
	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings 
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	// dialog... seriously this is a fnf mod who cares about history 
	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	// pysch engine gay bgs
	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite;
	var blammedLightsBlack:ModchartSprite;
	var blammedLightsBlackTween:FlxTween;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var trainSound:FlxSound;

	var limoKillingState:Int = 0;
	var limo:BGSprite;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var bgGirls:BackgroundGirls;
	var wiggleEffect:WiggleEffect;
	var bgGhouls:BGSprite;

	// SPIN !!!!!!!1!1!!111!!!!!!!!!1
	var spin:Bool = false;

	// hi 4rrthhhh
	var christmasBambi:FlxSprite;

	// song bars 
	var janelaSong:FlxSprite;
	var trollBar:FlxSprite;
	var songBar3D:FlxSprite;
    var idiotBar:FlxSprite;
	var black:FlxSprite;
	var plate:FlxSprite;
	var pixelBar:FlxSprite;
	var ourpleBar:FlxSprite;

	// text
	var janelaSongTxt:FlxText;
	var trollTxt:FlxText;
	var songBar3DTxt:FlxText;
	var idiotTxt:FlxText;
	var blackTxt:FlxText;
	var pixelText:FlxText;
	var ourpleTxt:FlxText;

	// hud shit 
	var watermark:FlxText;
	var engine:FlxText;
	var counter:FlxText;
	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var timeTween:FlxTween;
	var scoreTxtTween:FlxTween;
	public var inScreenText:FlxText;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;
	
	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	// icon bouncy
	var beatChange:Int = 1;

	// roberto
	var robertoShit:Bool = false;

	// sanic song cool mechanic
	var rubys:Int = 0;
	var rubyText:FlxText;
	//var morshu:FlxSprite;

	// extraBgs
	var frontPoopers:BobCustomBg;
	var frontGuy:FlxSprite;
	var frontGuy1:FlxSprite;
	var fucker:BobCustomBg;
	var oldTimes:BobCustomBg;
	var fumante:BobCustomBg;
	var fumante1:BobCustomBg;
	var helloBoy:BobCustomBg;
	var garcelloDead:RobertoBg;
	var chocolate:BobCustomBg;
	var hooks:BobCustomBg;
	var school:BobCustomBg;
	var clouds:FlxTiledSprite;

	// emitters
	var emitterShit:FlxEmitter;
	var emitterShit1:FlxEmitter;
	var emitterShit2:FlxEmitter;
	var fuckOut:FlxTypedGroup<FlxEmitter>;

	// space shit
	var youCanPressSpace:Bool;
	var youDontHitSpace:Bool;
	var spaceHit:Bool;
	//var youCanHitSpace:Bool = false;
	//var hitted:Int;

	//
	var maxShit:Float = 0.02;

	// composer
	var songComposer:String;

	//
	var tweenShit:FlxTween;

	// faz coins
	var coinText:FlxText;
	var fiveCoins:Int;
	var youPaid:Bool;
	//var timer:Int;

	// the SUS
	var sus:BadAmongusGRRR;

	// FUN TEST :)
	//var testBar:FlxBar;
	//var gayTest:Float;

	// puppet stuff
	var puppet:FlxSprite;
    var puppetBar:FlxBar;
	var puppetCountdown:Float = 18;
	var musicBox:FlxSprite;
	var haveMusicBox:Bool;

	// TEST
	var gaySex:FlxTypedGroup<FlxSprite>;

	override public function create()
	{
		FlxG.mouse.visible = false;

		Paths.clearStoredMemory();

		// for lua
		instance = this;

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = PlayState.SONG.stage;
		//trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				case 'spookeez' | 'south' | 'monster':
					curStage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					curStage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,
			
				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,
			
				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];
		
		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);
		newDadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);

		switch(SONG.song.toLowerCase())
		{
			case 'slow' | 'showtime' | 'insanity' | 'system-error' | 'rivals' | 'intercept' | 'abandoned' | 'crusher' | 'give-up' | 'pogs' | 'bitcrusher' | 'overtime' | 'overdrive' | 'Monobob' | 'elections' | 'placeholder' | 'gore' | 'pixelated' | 'boobs' | 'dingle' | 'ourple':
				songComposer = 'M4ccros';

			case 'mortimer' | 'supernova' | 'glitcher' | 'unhappy' | 'drugs-and-rap' | 'blood-bath':
				songComposer = 'hectork, M4ccros';

			case 'alt' | 'malware':
				songComposer = 'Sar, M4ccros';
	
			case 'goffy-funkin':
				songComposer = 'doctor of music';
	
			case 't-song':
				songComposer = 'Synth Mints';
	
			case 'golden-core':
				songComposer = 'Sanco';

			case 'suffering':
				songComposer = 'Prince Fizz';

			case 'misery':
				songComposer = 'Sar';
	
			case 'party' | 'curse' | 'anomaly' | 'rumble' | 'salvation' | 'fatass' | 'beast' | 'bite' | 'education':
				songComposer = 'la Zer0';
	
			case 'tutorial' | 'help-me':
				songComposer = 'GOD';

			case 'gummy-bambi':
				songComposer = 'idk';

			// Funny :)
			default:
				songComposer = CoolUtil.getUsername();
		}

		switch (curStage)
		{
			case 'stage': //Week 1
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}

			case 'spooky': //Week 2
				if(!ClientPrefs.lowQuality) {
					halloweenBG = new BGSprite('halloween_bg', -200, -100, ['halloweem bg0', 'halloweem bg lightning strike']);
				} else {
					halloweenBG = new BGSprite('halloween_bg_low', -200, -100);
				}
				add(halloweenBG);

				halloweenWhite = new BGSprite(null, -FlxG.width, -FlxG.height, 0, 0);
				halloweenWhite.makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.WHITE);
				halloweenWhite.alpha = 0;
				halloweenWhite.blend = ADD;

				//PRECACHE SOUNDS
				CoolUtil.precacheSound('thunder_1');
				CoolUtil.precacheSound('thunder_2');

			case 'philly': //Week 3
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('philly/sky', -100, 0, 0.1, 0.1);
					add(bg);
				}
				
				var city:BGSprite = new BGSprite('philly/city', -10, 0, 0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				phillyCityLights = new FlxTypedGroup<BGSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:BGSprite = new BGSprite('philly/win' + i, city.x, city.y, 0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					phillyCityLights.add(light);
				}

				if(!ClientPrefs.lowQuality) {
					var streetBehind:BGSprite = new BGSprite('philly/behindTrain', -40, 50);
					add(streetBehind);
				}

				phillyTrain = new BGSprite('philly/train', 2000, 360);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				CoolUtil.precacheSound('train_passes');
				FlxG.sound.list.add(trainSound);

				var street:BGSprite = new BGSprite('philly/street', -40, 50);
				add(street);

			case 'limo': //Week 4
				var skyBG:BGSprite = new BGSprite('limo/limoSunset', -120, -50, 0.1, 0.1);
				add(skyBG);

				if(!ClientPrefs.lowQuality) {
					limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
					add(limoMetalPole);

					bgLimo = new BGSprite('limo/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
					add(bgLimo);

					limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
					add(limoCorpse);

					limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
					add(limoCorpseTwo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						grpLimoDancers.add(dancer);
					}

					limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
					add(limoLight);

					grpLimoParticles = new FlxTypedGroup<BGSprite>();
					add(grpLimoParticles);

					//PRECACHE BLOOD
					var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
					particle.alpha = 0.01;
					grpLimoParticles.add(particle);
					resetLimoKill();

					//PRECACHE SOUND
					CoolUtil.precacheSound('dancerdeath');
				}

				limo = new BGSprite('limo/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);

				fastCar = new BGSprite('limo/fastCarLol', -300, 160);
				fastCar.active = true;
				limoKillingState = 0;

			case 'mall': //Week 5 - Cocoa, Eggnog
				var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				if(!ClientPrefs.lowQuality) {
					upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					add(upperBoppers);

					var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);
				}

				var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
				add(tree);

				bottomBoppers = new BGSprite('christmas/bottomBop', -300, 140, 0.9, 0.9, ['Bottom Level Boppers Idle']);
				bottomBoppers.animation.addByPrefix('hey', 'Bottom Level Boppers HEY', 24, false);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
				add(fgSnow);

				santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
				add(santa);
				CoolUtil.precacheSound('Lights_Shut_off');

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

			case 'school': //Week 6 - Senpai, Roses
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				var bgSky:BGSprite = new BGSprite('weeb/weebSky', 0, 0, 0.1, 0.1);
				add(bgSky);
				bgSky.antialiasing = false;

				var repositionShit = -200;

				var bgSchool:BGSprite = new BGSprite('weeb/weebSchool', repositionShit, 0, 0.6, 0.90);
				add(bgSchool);
				bgSchool.antialiasing = false;

				var bgStreet:BGSprite = new BGSprite('weeb/weebStreet', repositionShit, 0, 0.95, 0.95);
				add(bgStreet);
				bgStreet.antialiasing = false;

				var widShit = Std.int(bgSky.width * 6);
				if(!ClientPrefs.lowQuality) {
					var fgTrees:BGSprite = new BGSprite('weeb/weebTreesBack', repositionShit + 170, 130, 0.9, 0.9);
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					fgTrees.updateHitbox();
					add(fgTrees);
					fgTrees.antialiasing = false;
				}

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				bgTrees.frames = Paths.getPackerAtlas('weeb/weebTrees');
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);
				bgTrees.antialiasing = false;

				if(!ClientPrefs.lowQuality) {
					var treeLeaves:BGSprite = new BGSprite('weeb/petals', repositionShit, -40, 0.85, 0.85, ['PETALS ALL'], true);
					treeLeaves.setGraphicSize(widShit);
					treeLeaves.updateHitbox();
					add(treeLeaves);
					treeLeaves.antialiasing = false;
				}

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));

				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();

				if(!ClientPrefs.lowQuality) {
					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					add(bgGirls);
				}

			case 'schoolEvil': //Week 6 - Thorns
				GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
				GameOverSubstate.loopSoundName = 'gameOver-pixel';
				GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
				GameOverSubstate.characterName = 'bf-pixel-dead';

				/*if(!ClientPrefs.lowQuality) { //Does this even do something?
					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
				}*/
				var posX = 400;
				var posY = 200;
				if(!ClientPrefs.lowQuality) {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);

					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch instance'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					add(bgGhouls);
				} else {
					var bg:BGSprite = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);
					bg.scale.set(6, 6);
					bg.antialiasing = false;
					add(bg);
				}

			// Bgs
			case 'haha BG': // malware
			    curStage = 'haha BG';

				var bg:BobCustomBg = new BobCustomBg('bgs/idiot/haha BG');
				bg.screenCenter();
                add(bg);

			case 'Starved': // midnight Snack
		    	curStage = 'Starved';

				var sky:BobCustomBg = new BobCustomBg('bgs/starved/Sky');
				sky.scrollFactor.set(1.2, 1.2);
				sky.screenCenter();
				add(sky);

				var bg:BobCustomBg = new BobCustomBg('bgs/starved/Bg');
				bg.screenCenter();
                add(bg);

				var ripbozo:BobCustomBg = new BobCustomBg('bgs/starved/#RipBozo');
				ripbozo.screenCenter();
				add(ripbozo);

				if(!ClientPrefs.lowQuality)
				{
			    	hooks = new BobCustomBg('bgs/starved/hooks');
			     	hooks.screenCenter();
			    	hooks.scrollFactor.set(1.3, 1.3);
				}

			case 'candy': // Golden Core
				curStage = 'candy';
		
				var candy:BobCustomBg = new BobCustomBg('bgs/candy land/candy');
				candy.screenCenter();
			    add(candy);

				wiggleEffect = new WiggleEffect();
				wiggleEffect.effectType = WiggleEffectType.DREAMY;
				wiggleEffect.waveAmplitude = 0.1;
				wiggleEffect.waveFrequency = 5;
				wiggleEffect.waveSpeed = 1;
				candy.shader = wiggleEffect.shader;

			case 'laugh':
				curStage = 'laugh';
		
				var bg:BobCustomBg = new BobCustomBg('bgs/extras/laugh');
				add(bg);

				wiggleEffect = new WiggleEffect();
				wiggleEffect.effectType = WiggleEffectType.DREAMY;
				wiggleEffect.waveAmplitude = 0.1;
				wiggleEffect.waveFrequency = 5;
				wiggleEffect.waveSpeed = 1;
				bg.shader = wiggleEffect.shader;
				
			case 'drakeBG': // glitcher
				curStage = 'drakeBG';

				var bg:BobCustomBg = new BobCustomBg('bgs/glitch/drakeBG');
				add(bg);

				wiggleEffect = new WiggleEffect();
				wiggleEffect.effectType = WiggleEffectType.DREAMY;
				wiggleEffect.waveAmplitude = 0.1;
				wiggleEffect.waveFrequency = 5;
				wiggleEffect.waveSpeed = 1;
				bg.shader = wiggleEffect.shader;

			case 'dont_use_drugs': // drugs and rap
				curStage = 'dont_use_drugs';

				var space:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bgs/drugs/space'));
				space.screenCenter();
				add(space);

				var bg1:FlxSprite = new FlxSprite();
				bg1.loadGraphic(Paths.image('bgs/drugs/moon'));
				bg1.scrollFactor.set(1.3, 1.3);
				bg1.screenCenter();
				add(bg1);

				var bg2:FlxSprite = new FlxSprite();
				bg2.loadGraphic(Paths.image('bgs/drugs/front'));
				bg2.scrollFactor.set(0.9, 0.9);
				bg2.screenCenter();
				add(bg2);

				wiggleEffect = new WiggleEffect();
				wiggleEffect.effectType = WiggleEffectType.DREAMY;
				wiggleEffect.waveAmplitude = 0.1;
				wiggleEffect.waveFrequency = 5;
				wiggleEffect.waveSpeed = 1;
				space.shader = wiggleEffect.shader;

				fuckOut = new FlxTypedGroup<FlxEmitter>();

				if(!ClientPrefs.lowQuality)
				{
					for(i in 0...15)
					{
						emitterShit1 = new FlxEmitter(-1300, 1800).loadParticles(Paths.image('particles/drugs'), 500, 16, true);
						emitterShit1.launchMode = FlxEmitterMode.SQUARE;
						emitterShit1.velocity.set(-50, -150, 50, -750, -100, 0, 100, -100);
						emitterShit1.scale.set(3.95, 3.95, 3.95 , 3.95, 3.95, 3.95, 3.95, 3.95);
						emitterShit1.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
						emitterShit1.width = 4500;
						emitterShit1.alpha.set(1, 1);
						emitterShit1.lifespan.set(3, 5);
						emitterShit1.start(false, FlxG.random.float(0.1, 0.2), 100000);
						emitterShit1.emitting = false;
					}
				}

			case 'MOGAS_BG': // intercept
				curStage = 'MOGAS_BG';

				var bg:FlxSprite = new FlxSprite();
				bg.frames = Paths.getSparrowAtlas('bgs/intercept/fundo_among');
				bg.animation.addByPrefix('idle', "fundo", 17);
				bg.animation.play('idle');
				add(bg);

				var sussy:FlxSprite = new FlxSprite(340, 630);
				sussy.frames = Paths.getSparrowAtlas('bgs/intercept/sus');
				sussy.animation.addByPrefix('idle', "todos", 14);
				sussy.scale.set(0.7, 0.7);
				sussy.animation.play('idle');
				add(sussy);

				if(!ClientPrefs.lowQuality)
				{
					var snow:FlxSprite = new FlxSprite();
					snow.frames = Paths.getSparrowAtlas('bgs/intercept/neve');
					snow.animation.addByPrefix('idle', "neve", 15);
					snow.animation.play('idle');
					snow.cameras = [camHUD];
					add(snow);
	
					frontGuy = new FlxSprite(545, 1180);
					frontGuy.frames = Paths.getSparrowAtlas('bgs/intercept/front guys/vermelho');
					frontGuy.animation.addByPrefix('idle', "vermleho", 14);
					frontGuy.scrollFactor.set(1.2, 1.2);
					frontGuy.scale.set(0.7, 0.7);
					frontGuy.animation.play('idle');
	
					frontGuy1 = new FlxSprite(1995, 1180);
					frontGuy1.frames = Paths.getSparrowAtlas('bgs/intercept/front guys/preto');
					frontGuy1.animation.addByPrefix('idle', "preto", 14);
					frontGuy1.scrollFactor.set(1.2, 1.2);
					frontGuy1.scale.set(0.7, 0.7);
					frontGuy1.animation.play('idle');

					fuckOut = new FlxTypedGroup<FlxEmitter>();
				
					for(i in 0...15)
					{
						emitterShit = new FlxEmitter(-1300, 1800).loadParticles(Paths.image('particles/Little Snow'), 500, 16, true);
						emitterShit.launchMode = FlxEmitterMode.SQUARE;
						emitterShit.velocity.set(-50, -150, 50, -750, -100, 0, 100, -100);
						emitterShit.scale.set(3.95, 3.95, 3.95 , 3.95, 3.95, 3.95, 3.95, 3.95);
						emitterShit.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
						emitterShit.width = 4500;
						emitterShit.alpha.set(1, 1);
						emitterShit.lifespan.set(3, 5);
						emitterShit.start(false, FlxG.random.float(0.1, 0.2), 100000);
						emitterShit.emitting = false;
					}
				}

			case 'other_booba': // pixelated
				curStage = 'other_booba';

				var bg:FlxSprite = new FlxSprite();
				bg.loadGraphic(Paths.image('bgs/pixel/other_booba'));
				add(bg);

				isPixelStage = true;

			case 'squid': // beast
				curStage = 'squid';

				var bg:BobCustomBg = new BobCustomBg('bgs/squid game/squid');
				add(bg);

			case 'ourpleBg': // ourple
				curStage = 'ourpleBg';
	
				var bg:FlxSprite = new FlxSprite();
				bg.loadGraphic(Paths.image('bgs/ourple/ourpleBg'));
				add(bg);

			case 'Security': // salvation
				curStage = 'Security';

				var bg:BobCustomBg = new BobCustomBg('bgs/security/Security');
				add(bg);

				var animatronics:BobCustomBg = new BobCustomBg(570, 750, 'bgs/security/plateia', "geral", 22);
				animatronics.scrollFactor.set(1.2, 1.2);
				add(animatronics);

			case 'peterHouse': // rumble
				curStage = 'peterHouse';

				var bg:BobCustomBg = new BobCustomBg('bgs/peter/peterHouse');
				add(bg);

			case 'TrollBG': // abandoned
				curStage = 'TrollBG';
				
				var bg:BobCustomBg = new BobCustomBg('bgs/TrollFace/TrollBG');
				add(bg);

				oldTimes = new BobCustomBg('bgs/TrollFace/the good old days', 'comic ', 10);
				oldTimes.alpha = 0;

			case 'politic': // elections
				curStage = 'politic';

				var bg:BobCustomBg = new BobCustomBg('bgs/brasilia/politic');
				add(bg);

			case 'mokey':
				curStage = 'mokey';

				var bg:BobCustomBg = new BobCustomBg('bgs/nothing/mokey');
				add(bg);

			case 'mokey1':
			    curStage = 'mokey1';
						
				var bg:BobCustomBg = new BobCustomBg(345, 'bgs/nothing/mokey1');
				add(bg);

			case 'suicide': // suffering
				curStage = 'suicide';

				var bg:BobCustomBg = new BobCustomBg('bgs/sad/city');
				add(bg);

				var hill:BobCustomBg = new BobCustomBg('bgs/sad/hill');
				add(hill);

			case 'florest': // awesome
				curStage = 'florest';

				var bg:BobCustomBg = new BobCustomBg('bgs/top 10/florest');
				add(bg);
			
			case 'BOB SCENE WEEK $': // bob Week 3 shit
				curStage = 'BOB SCENE WEEK $';
									
				var bg:FlxSprite = new FlxSprite();
				bg.loadGraphic(Paths.image('bgs/bob bob bob/week 2/hills'));
				add(bg);

				var ground:FlxSprite = new FlxSprite();
				ground.loadGraphic(Paths.image('bgs/bob bob bob/week 2/ground'));
				add(ground);

				var shit:FlxSprite = new FlxSprite();
				shit.loadGraphic(Paths.image('bgs/bob bob bob/week 2/bruh'));
				add(shit);

			case 'BOB SCENE WEEK 2': // bob Week 1
				curStage = 'BOB SCENE WEEK 2';

				var bg:BobCustomBg = new BobCustomBg('bgs/bob bob bob/week 1/city');
				add(bg);

				var ground:BobCustomBg = new BobCustomBg('bgs/bob bob bob/week 1/hill');
				add(ground);

				chocolate = new BobCustomBg(115, 1060, 'bgs/bob bob bob/week 1/barra_v2', "bob's chocolat", 21);
				chocolate.scale.set(0.5, 0.5);
				add(chocolate);

				if(!ClientPrefs.lowQuality)
				{
					helloBoy = new BobCustomBg('bgs/extras/Clubhouse-old');
					helloBoy.alpha = 0;
					add(helloBoy);
	
					fumante = new BobCustomBg('bgs/extras/back');
					fumante.scrollFactor.set(1, 1);
					fumante.alpha = 0;
					add(fumante);
	
					fumante1 = new BobCustomBg('bgs/extras/front');
					fumante1.scrollFactor.set(1, 1);
					fumante1.alpha = 0;
					add(fumante1);
	
					garcelloDead = new RobertoBg(430, 870);
				}

			case 'BOB SCENE WEEK 3': // evil bob stage
				curStage = 'BOB SCENE WEEK 3';
										
				var bg:FlxSprite = new FlxSprite();
				bg.loadGraphic(Paths.image('bgs/bob bob bob/week 1/evil/evil bg'));
				add(bg);

				var ground:FlxSprite = new FlxSprite();
				ground.loadGraphic(Paths.image('bgs/bob bob bob/week 1/evil/evil ground'));
				add(ground);

				wiggleEffect = new WiggleEffect();
				wiggleEffect.effectType = WiggleEffectType.DREAMY;
				wiggleEffect.waveAmplitude = 0.05;
				wiggleEffect.waveFrequency = 3;
				wiggleEffect.waveSpeed = 3;
				bg.shader = wiggleEffect.shader;

			case 'BOB SCENE WEEK 3D': // for 3D bob songs
				curStage = 'BOB SCENE WEEK 3D';
										
				var bg:FlxSprite = new FlxSprite();
				bg.loadGraphic(Paths.image('bgs/3D Bg/city'));
				add(bg);

				var clouds:FlxSprite = new FlxSprite();
				clouds.loadGraphic(Paths.image('bgs/3D Bg/clouds'));
				add(clouds);

				var ground:FlxSprite = new FlxSprite();
				ground.loadGraphic(Paths.image('bgs/3D Bg/ground'));
				add(ground);

			case 'BOB SCENE WEEK 69': // for second song in week 2
				curStage = 'BOB SCENE WEEK 69';
										
				var bg:FlxSprite = new FlxSprite();
				bg.loadGraphic(Paths.image('bgs/bob bob bob/week 2/evil/backGround'));
				add(bg);

				var ground:FlxSprite = new FlxSprite();
				ground.loadGraphic(Paths.image('bgs/bob bob bob/week 2/evil/ground'));
				add(ground);

				var shit:FlxSprite = new FlxSprite();
				shit.loadGraphic(Paths.image('bgs/bob bob bob/week 2/evil/shit'));
				add(shit);

			case 'BOB SCENE WEEK NO': // for quandale dingle songs
				curStage = 'BOB SCENE WEEK NO';

				var bg:BobCustomBg = new BobCustomBg('bgs/goffy/BOB SCENE WEEK NO');
				add(bg);

			case 'Jonh House': // anomaly
				curStage = 'Jonh House';				

				var bg:BobCustomBg = new BobCustomBg('bgs/Jonh House/bg');
				add(bg);

				var bed:BobCustomBg = new BobCustomBg(60, 260, 'bgs/Jonh House/Bed');
				bed.scrollFactor.set(1.1, 1.1);
				add(bed);

				var oddie:BobCustomBg = new BobCustomBg(930, 540, 'bgs/Jonh House/oddie');
				//oddie.scrollFactor.set(0.3, 0.3);
				add(oddie);

			case 'sherek': // boobs
				curStage = 'sherek';

				var bg:BobCustomBg = new BobCustomBg('bgs/goffy/sherek');
				add(bg);

			case 'Bus Stop':
		    	curStage = 'Bus Stop';

				var bg:BobCustomBg = new BobCustomBg('bgs/south Park/mountains');
				add(bg);

				var back:BobCustomBg = new BobCustomBg('bgs/south Park/back');
				back.scrollFactor.set(1.1, 1.1);
				add(back);

				var front:BobCustomBg = new BobCustomBg('bgs/south Park/front');
				add(front);

				var logo:BobCustomBg = new BobCustomBg(1025, 575, 'bgs/south Park/Comedy Central Logo');
				logo.cameras = [camHUD];
				logo.scale.set(0.5, 0.5);
				add(logo);

			case 'House':
				curStage = 'House';

				var bg:BobCustomBg = new BobCustomBg('bgs/House/House');
				add(bg);

				var killers:BobCustomBg = new BobCustomBg(690, 570, 'bgs/House/dance', 'dance', 24);
				killers.scrollFactor.set(1.1, 1.1);
				killers.scale.set(1.2, 1.2);
				add(killers);

				fuckOut = new FlxTypedGroup<FlxEmitter>();

				if(!ClientPrefs.lowQuality)
				{
					for(i in 0...7)
					{
						emitterShit2 = new FlxEmitter(-1300, 1800).loadParticles(Paths.image('particles/Blood'), 500, 16, true);
						emitterShit2.launchMode = FlxEmitterMode.SQUARE;
						emitterShit2.velocity.set(-50, -150, 50, -750, -100, 0, 100, -100);
						emitterShit2.scale.set(3.95, 3.95, 3.95 , 3.95, 3.95, 3.95, 3.95, 3.95);
						emitterShit2.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
						emitterShit2.width = 4500;
						emitterShit2.alpha.set(1, 1);
						emitterShit2.lifespan.set(1, 3);
						emitterShit2.start(false, FlxG.random.float(0.1, 0.2), 100000);
					}
				}

			case 'Glitch Stage':
				curStage = 'Glitch Stage';

				var bg:BobCustomBg = new BobCustomBg(123,'bgs/Glitch Zone/sky');
				add(bg);

				clouds = new FlxTiledSprite(Paths.image('bgs/Glitch Zone/clouds'), FlxG.width * 2, FlxG.height * 2, true, true);
				clouds.x = 565;
				clouds.y = 1440;
				add(clouds);

				if(!ClientPrefs.lowQuality)
				{
					var overlay:BobCustomBg = new BobCustomBg(123,'bgs/Glitch Zone/blend_overlay');
					add(overlay);

					var buildings:BobCustomBg = new BobCustomBg(325, 1740, 'bgs/Glitch Zone/bg_buildings');
					add(buildings);

					var rocks:BobCustomBg = new BobCustomBg(435, 1410,'bgs/Glitch Zone/pedras');
					FlxTween.tween(rocks, {y: rocks.y + 50}, 1.5, {ease: FlxEase.quadInOut, type: PINGPONG});
					add(rocks);
				}

				//var coolClouds:BobCustomBg = new BobCustomBg(435, 1440, 'bgs/Glitch Zone/clouds');
				//coolClouds.scrollFactor.set(1.1, 1.1);
				//add(coolClouds);

				var piso:BobCustomBg = new BobCustomBg(325, 1780,'bgs/Glitch Zone/chao');
				add(piso);
			
			case 'Baldi School':
				school = new BobCustomBg('bgs/school/school');
				school.screenCenter();
				add(school);

			case 'Sanic Stage':
				curStage = 'Sanic Stage';

				var bg:BobCustomBg = new BobCustomBg('bgs/Sanic Stage/sanic_bg_v3');
				add(bg);

				if(!ClientPrefs.lowQuality)
				{
					var youtubePoopers:BobCustomBg = new BobCustomBg(710, 630, 'bgs/Sanic Stage/back_sanoci', 'back', 15);
					youtubePoopers.scale.set(1.4, 1.4);
					youtubePoopers.scrollFactor.set(1.1, 1.1);
					add(youtubePoopers);
	
					frontPoopers = new BobCustomBg(430, 770, 'bgs/Sanic Stage/sanic_frenteback', 'frente', 16);
					frontPoopers.scale.set(1.4, 1.4);
					frontPoopers.scrollFactor.set(1.1, 1.1);
				}

				// the funny 
				fucker = new BobCustomBg(690, 570, 'bgs/fucker');
				fucker.scale.set(1.2, 1.2);
				//add(fucker);
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		switch(curStage)
		{
			case 'florest':
				introSoundsSuffix = '-awesome';

			case 'ourpleBg':
				introSoundsSuffix = '-ourple';
		}

		add(gfGroup); //Needed for blammed lights

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(newDadGroup);
		add(dadGroup);
		add(boyfriendGroup);
		
		if(curStage == 'spooky') {
			add(halloweenWhite);
		}

		if(!ClientPrefs.lowQuality)
		{
			switch(curStage){

				case 'TrollBG':
					add(oldTimes);
					
				case 'MOGAS_BG':
					add(fuckOut);
					fuckOut.add(emitterShit);
					add(frontGuy);
					add(frontGuy1);
					
				case 'dont_use_drugs':
					add(fuckOut);
					fuckOut.add(emitterShit1);
					
				case 'House':
					add(fuckOut);
					fuckOut.add(emitterShit2);
	
				case 'Starved':
					add(hooks);
				
				case 'Sanic Stage':
					add(frontPoopers);
			}
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		if(curStage == 'philly') {
			phillyCityLightsEvent = new FlxTypedGroup<BGSprite>();
			for (i in 0...5)
			{
				var light:BGSprite = new BGSprite('philly/win' + i, -10, 0, 0.3, 0.3);
				light.visible = false;
				light.setGraphicSize(Std.int(light.width * 0.85));
				light.updateHitbox();
				phillyCityLightsEvent.add(light);
			}
		}

		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end

		if(!modchartSprites.exists('blammedLightsBlack')) { //Creates blammed light black fade in case you didn't make your own
			blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
			blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			var position:Int = members.indexOf(gfGroup);
			if(members.indexOf(boyfriendGroup) < position) {
				position = members.indexOf(boyfriendGroup);
			} else if(members.indexOf(dadGroup) < position) {
				position = members.indexOf(dadGroup);
			}else if (members.indexOf(newDadGroup) < position)
			{
				position = members.indexOf(newDadGroup);
			}
			insert(position, blammedLightsBlack);

			blammedLightsBlack.wasAdded = true;
			modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
		}
		if(curStage == 'philly') insert(members.indexOf(blammedLightsBlack) + 1, phillyCityLightsEvent);
		blammedLightsBlack = modchartSprites.get('blammedLightsBlack');
		blammedLightsBlack.alpha = 0.0;

		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				insert(members.indexOf(gfGroup) - 1, fastCar);
			
			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

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

		var showTime:Bool = true;
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		//timeTxt.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.BLACK, 4);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;
		switch(curStage)
		{
			case 'florest':
				timeTxt.visible = false;

			case 'other_booba':
				timeTxt.setFormat(Paths.font("pixel.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		add(timeBarBG);

		//testBar = new FlxBar(-110, 310, LEFT_TO_RIGHT, 465, 50, this, 'gayTest', 0, 2);
		//testBar.createFilledBar(0xFFBE7F7F, 0xFF000000);
		//testBar.cameras = [camHUD];
        //testBar.scrollFactor.set();
        //testBar.angle = 90;
		//add(testBar);

		barraMedo = new FlxBar(-110, 310, LEFT_TO_RIGHT, 465, 50, this, 'medo', 0, 2);
        barraMedo.createFilledBar(0xFFFF0000, 0xFF000000);
		barraMedo.cameras = [camHUD];
        barraMedo.scrollFactor.set();
        barraMedo.angle = 90;
		// code by Matheus Ahhh thanks https://twitter.com/MatheusAhhh

		barraMedoBG = new FlxSprite(-200, 420).loadGraphic(Paths.image('bgs/starved/scary bar'));
		barraMedoBG.scrollFactor.set();
		barraMedoBG.cameras = [camHUD];
		barraMedoBG.screenCenter();
		barraMedoBG.x += -530;
		barraMedoBG.y -= 30;

		gaySex = new FlxTypedGroup<FlxSprite>();

	    timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'songPercent', 0, 1);
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.scrollFactor.set();
		//timeBar.createGradientFilledBar([FlxColor.WHITE, FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2])]);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		puppetBar = new FlxBar(460, 540, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this, 'puppetCountdown', 0, 17);
	    puppetBar.scrollFactor.set();
		puppetBar.createGradientFilledBar([FlxColor.BLACK, FlxColor.WHITE]);
		puppetBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		puppetBar.cameras = [camHUD];

		musicBox = new FlxSprite();
		musicBox.loadGraphic(Paths.image('puppet/windUpMusicBox'));
		musicBox.cameras = [camHUD];
		musicBox.x = puppetBar.x + 150;
		musicBox.y = puppetBar.y + -50;

		rubyText = new FlxText(945, 855);
		rubyText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('PhantomMuff.ttf'), 32);
		levelDifficulty.updateHitbox();

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		//add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width + 10), Std.int(healthBarBG.height + 10), this,
		'health', 0, 2);
	    healthBar.scrollFactor.set();
	    add(healthBar);
	    healthBarBG.sprTracker = healthBar;

		heltfbarOV = new AttachedSprite('heltf_barOV');
		heltfbarOV.y = FlxG.height * 0.89;
		heltfbarOV.screenCenter(X);
		heltfbarOV.scrollFactor.set();
		heltfbarOV.xAdd = -4;
		heltfbarOV.yAdd = -4;
		add(heltfbarOV);
		if(ClientPrefs.downScroll) heltfbarOV.y = 0.11 * FlxG.height;

		healthBarBOB = new AttachedSprite('heltf_bar');
		healthBarBOB.y = FlxG.height * 0.89;
		healthBarBOB.screenCenter(X);
		healthBarBOB.scrollFactor.set();
		healthBarBOB.xAdd = -4;
		healthBarBOB.yAdd = 7;
		add(healthBarBOB);
		if(ClientPrefs.downScroll) healthBarBOB.y = 0.11 * FlxG.height;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		switch(curStage){
			case 'florest':
				iconP1.changeIcon('BLUE');
				iconP2.changeIcon('RED');
		}

		reloadHealthBarColors();

		watermark = new FlxText(5, FlxG.height - 35, 0);
        watermark.setFormat(Paths.font("vcr.ttf"), 21, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		watermark.text = '- ' + SONG.song + ' [' + CoolUtil.difficultyString() + ']' +' -';
        watermark.borderSize = 1.7;
		watermark.cameras = [camHUD];
		watermark.scrollFactor.set();
		switch(curStage)
		{
			case 'mokey':
				watermark.text = '- ' + SONG.song + ' [' + "you will not escape" + ']' +' -';
			
			case 'florest':
				watermark.visible = false;
			
			case 'Starved':
				watermark.visible = false;
		}
		if (curSong == "party")
		{
			watermark.visible = false;
		}

		engine = new FlxText(1100, FlxG.height - 35, 0);
        engine.setFormat(Paths.font("vcr.ttf"), 21, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engine.text = 'Bob Engine V2';
		engine.borderSize = 1.7;
		engine.cameras = [camHUD];
		engine.scrollFactor.set();
		switch(curStage)
		{
			case 'squid':
				if(ClientPrefs.eastereggs){
					engine.text = 'press 7';
				}
			
			case  'mokey':
				engine.text = 'hello ' + CoolUtil.getUsername();

			case 'florest':
				engine.visible = false;

			case 'Starved':
				engine.visible = false;

			case 'Bus Stop':
				engine.visible = false;
		}
		if (curSong == "party")
		{
			engine.visible = false;
		}
	
		counter = new FlxText(20, 0, 0, "", 20);
        counter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		counter.borderSize = 2;
        counter.borderQuality = 2;
        counter.scrollFactor.set();
        counter.cameras = [camHUD];
		//counter.visible = !ClientPrefs.hideHud;
        counter.screenCenter(Y);
        add(counter);
		switch(curStage)
		{
			case 'florest':
				counter.visible = false;

			case 'Starved':
				counter.visible = false;

			case 'other_booba':
				counter.setFormat(Paths.font("pixel.otf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		janelaSong = new FlxSprite(-463, 236).loadGraphic(Paths.image('Bars/songbar', 'preload'));
        janelaSong.scrollFactor.set();
        janelaSong.antialiasing = true;
        add(janelaSong);

		janelaSongTxt = new FlxText(-463, 233, 600);
        janelaSongTxt.setFormat(Paths.font("PhantomMuff.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        janelaSongTxt.text = SONG.song + '\n' + songComposer;
        janelaSongTxt.scrollFactor.set();
        janelaSongTxt.borderSize = 1.35;
        janelaSongTxt.antialiasing = false;
        add(janelaSongTxt);
		switch(curStage)
		{
			case 'florest':
				janelaSongTxt.visible = false;
				janelaSong.visible = false;
		}

		ourpleBar = new FlxSprite(-463, 236).loadGraphic(Paths.image('Bars/songSign', 'preload'));
		ourpleBar.scrollFactor.set();
        ourpleBar.antialiasing = true;
		ourpleBar.cameras = [camHUD];

		ourpleTxt = new FlxText(-463, 233, 600);
		ourpleTxt.setFormat(Paths.font("ourple.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		ourpleTxt.text = SONG.song + '\n' + songComposer;
        ourpleTxt.scrollFactor.set();
        ourpleTxt.borderSize = 1.35;
		ourpleTxt.cameras = [camHUD];

		pixelBar = new FlxSprite(-463, 236).loadGraphic(Paths.image('Bars/pixelBar', 'preload'));
		pixelBar.scrollFactor.set();

		pixelText = new FlxText(-463, 233, 600);
		pixelText.setFormat(Paths.font("pixelShit.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		pixelText.text = SONG.song + '\n' + songComposer;
        pixelText.scrollFactor.set();
        pixelText.borderSize = 1.35;

		plate = new FlxSprite(320,785).loadGraphic(Paths.image('Bars/Plate', 'preload'));
        plate.scrollFactor.set();

		trollBar = new FlxSprite(-463, 236).loadGraphic(Paths.image('Bars/Troll Bar', 'preload'));
        trollBar.scrollFactor.set();

		trollTxt = new FlxText(-463, 233, 600);
        trollTxt.setFormat(Paths.font("PhantomMuff.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		trollTxt.text = SONG.song + '\n' + songComposer;
        trollTxt.scrollFactor.set();
		trollTxt.borderSize = 1.35;

	    songBar3D = new FlxSprite(-463, 236).loadGraphic(Paths.image('Bars/3D songbar', 'preload'));
        songBar3D.scrollFactor.set();

		songBar3DTxt = new FlxText(-463, 233, 600);
        songBar3DTxt.setFormat(Paths.font("PhantomMuff.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		songBar3DTxt.text = SONG.song + '\n' + songComposer;
        songBar3DTxt.scrollFactor.set();
        songBar3DTxt.borderSize = 1.35;

		black = new FlxSprite(-463, 236).loadGraphic(Paths.image('Bars/blackWindow', 'preload'));
		black.scrollFactor.set();

		blackTxt = new FlxText(-463, 233, 600);
		blackTxt.setFormat(Paths.font("VCR OSD Mono.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        blackTxt.text = SONG.song + '\n' + songComposer;
        blackTxt.scrollFactor.set();
        blackTxt.borderSize = 1.35;

		idiotBar = new FlxSprite(-463, 236).loadGraphic(Paths.image('Bars/Idiot Bar', 'preload'));
		idiotBar.scrollFactor.set();

		idiotTxt = new FlxText(-463, 233, 600);
        idiotTxt.setFormat(Paths.font("PhantomMuff.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        idiotTxt.text = SONG.song + '\n' + songComposer;
        idiotTxt.scrollFactor.set();
        idiotTxt.borderSize = 1.35;

		christmasBambi = new FlxSprite(870, 780);
		christmasBambi.frames = Paths.getSparrowAtlas('christmasBambi/Bambi/bnamb');
		christmasBambi.animation.addByPrefix('idle', "idle", 80); // too fast
		christmasBambi.visible = false;
		christmasBambi.scrollFactor.set(1.2, 1.2);
		christmasBambi.animation.play('idle');
		add(christmasBambi);

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if(curStage != 'florest'){
			scoreTxt.color = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		}else{
			scoreTxt.color = FlxColor.WHITE;
		}
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);
		if(isPixelStage)
		{
			scoreTxt.setFormat(Paths.font("pixelShit.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}

		add(watermark);
		add(engine);

		coinText = new FlxText(550, 100);
		coinText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		coinText.cameras = [camHUD];
		coinText.alpha = 1;

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "Cheater", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 70;
		}

		inScreenText = new FlxText(0, healthBarBG.y - 110, FlxG.width, "", 20);
        inScreenText.setFormat(Paths.font("vcr.ttf"), 34, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        inScreenText.scrollFactor.set();
        inScreenText.borderSize = 2.5;
        inScreenText.cameras = [camHUD];
        inScreenText.text = '';
        add(inScreenText);

		status = new FlxText(5, FlxG.height - 80, 0);
        status.setFormat(Paths.font("PhantomMuff.ttf"), 19, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		status.text = 'MatheusAhhh passou aqui :troll:';
		status.scrollFactor.set();
        status.borderSize = 1.3;
		status.cameras = [camHUD];
		status.alpha = 0;
		add(status);

		sus = new BadAmongusGRRR(280, 530);
		sus.cameras = [camHUD];

		puppet = new FlxSprite(750, 685);
		puppet.frames = Paths.getSparrowAtlas('puppet/PUPPET');
		puppet.animation.addByPrefix('idle', "jumpscare", 10);
		puppet.scale.set(3.8, 3.8);

		//morshu = new FlxSprite();
		//morshu.frames = Paths.getSparrowAtlas('bgs/Sanic Stage/morshu');
		//morshu.animation.addByPrefix('idle', "morshu-zelda_", 92);
		//morshu.animation.play('idle');
		//morshu.x = rubyText.x;
		//morshu.y = rubyText.y;

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBOB.cameras = [camHUD];
		heltfbarOV.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					if(gf != null) gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								startCountdown();
							}
						});
					});

				case 'senpai' | 'roses' | 'thorns':
					if(daSong == 'roses') FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				
				case 'showtime' | 'insanity' | 'rivals' | 'blood-bath':
					if(daSong == 'showtime')
					startVideo('CutsceneWeek1');
	
					if(daSong == 'insanity')
					startDialogue(dialogueJson);
	
					if(daSong == 'rivals')
					startDialogue(dialogueJson);
	
					if(daSong == 'blood-bath')
					startDialogue(dialogueJson);
	
				case 'mortimer' | 'unhappy' | 'gore':
					if(daSong == 'mortimer')
					startVideo('CutsceneWeek2');
	
					if(daSong == 'unhappy')
					startDialogue(dialogueJson);
	
					if(daSong == 'gore')
					startDialogue(dialogueJson);
	
				case 'placeholder' | 'give-up' | 'crusher':
					if(daSong == 'placeholder')
					startDialogue(dialogueJson);
	
					if(daSong == 'give-up')
					startDialogue(dialogueJson);
	
					if(daSong == 'crusher')
					startDialogue(dialogueJson);

				default:
					startCountdown();
			}
			seenCutscene = true;
		}
		else
		{
			startCountdown();
		}

		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) CoolUtil.precacheSound('hitsound');
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');

		if (PauseSubState.songName != null) {
			CoolUtil.precacheMusic(PauseSubState.songName);
		} else if(ClientPrefs.pauseMusic != 'None') {
			CoolUtil.precacheMusic(Paths.formatToSongPath(ClientPrefs.pauseMusic));
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);
		
		super.create();

		Paths.clearUnusedMemory();
		CustomFadeTransition.nextCamera = camOther;
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		if(curStage == 'florest'){
			healthBar.createFilledBar(0xFFFF0000, 0xFF0004FF);
			healthBar.updateBar();
		}
		
		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}
		
		if(doPush)
		{
			for (lua in luaArray)
			{
				if(lua.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}
	
	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				startAndEnd();
			}
			return;
		}
		else
		{
			FlxG.log.warn('Couldnt find video file: ' + fileName);
			startAndEnd();
		}
		#end
		startAndEnd();
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	function coolCutsceneTEST():Void
	{
		inCutscene = true;
		camHUD.visible = false;

		new FlxTimer().start(2.0, function(tmr:FlxTimer){
			boyfriend.playAnim('hey');
	
			new FlxTimer().start(1.0, function(tmr:FlxTimer){
				dad.playAnim('singUP');
	
				new FlxTimer().start(1.0, function(tmr:FlxTimer){
					camHUD.visible = true;
					startCountdown();
				});
			});
		});
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'roses' || songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	// window Stuff
	var gameWindowX:Int = Lib.application.window.x;
	var gameWindowY:Int = Lib.application.window.y;

	function evilWindow()
	{
		Lib.application.window.move(gameWindowX + FlxG.random.int(-180, 220), gameWindowY + FlxG.random.int(-180, 220));
	}

	function goodWindow()
	{
		Lib.application.window.move(gameWindowX + 0, gameWindowY + 0);
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownfuckyeah:FlxSprite;
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;

	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if(curSong == 'salvation'){
			haveMusicBox = true;
			add(puppetBar);
			add(musicBox);
		}

		switch(curSong){
			case 'malware' | 'Suffering' | 'gore' | 'blood-bath':
				canPause = false;
		}

		if (ClientPrefs.shaders)
		{
			switch(curSong)
			{
				case 'curse':
					var shaders:ShaderFilter = new ShaderFilter(new Scanline());
					camHUD.setFilters([shaders]);
					camGame.setFilters([shaders]);
	
				case 'anomaly' | 'midnight-snack' | 'bite':
					var shaders:ShaderFilter = new ShaderFilter(new VhsShader());
					camGame.setFilters([shaders]);
			}
		}

		switch(curSong)
		{
			case 'mortimer':
				FlxTween.tween(gf, {alpha: 0}, 0.2, {onComplete: function(tween:FlxTween){
					gf.alpha = 0;
				}});

			case 'ourple':
				camGame.alpha = 0;
				add(ourpleBar);
				add(ourpleTxt);
		}

		switch(curSong){

			case "rumble":
				twoOpponents = true;
				newDad = new Character(75, 0, 'maer');
				startCharacterPos(newDad, true);
				newDadGroup.add(newDad);

			case 'education':
				twoOpponents = true;
				newDad = new Character(105, 0, 'play bitch');
				startCharacterPos(newDad, true);
				newDad.alpha = 0;
				newDadGroup.add(newDad);

			default:
				twoOpponents = false;
		}

		if(ClientPrefs.eastereggs)
		{
			if(FlxG.random.bool(2))
			{ 
				christmasBambi.visible = true;

				dad.alpha = 0;
				gf.alpha = 0;
				boyfriend.alpha = 0;
			}
			if(FlxG.random.bool(98))
			{
				christmasBambi.visible = false;

				dad.alpha = 1;
				gf.alpha = 1;
				boyfriend.alpha = 1;
			}
		}

		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {

			// cool Time Bar colors :)
			switch(curSong)
			{
				case 'ourple':
					timeBar.createGradientFilledBar([FlxColor.WHITE, FlxColor.PURPLE]);

				case 'intercept' | 'curse' | 'fatass':
					timeBar.createGradientFilledBar([FlxColor.WHITE, FlxColor.RED]);

				case 'malware':
					timeBar.createGradientFilledBar([FlxColor.BLACK, FlxColor.WHITE]);

				case 'anomaly' | 'glitcher' | 'golden-core':
					timeBar.createGradientFilledBar([FlxColor.WHITE, FlxColor.ORANGE]);

				case 'rumble' | 'salvation' | 'gummy-bambi' | 'education':
					timeBar.createGradientFilledBar([FlxColor.WHITE, FlxColor.GREEN]);

				case 'beast':
					timeBar.createGradientFilledBar([FlxColor.WHITE, FlxColor.YELLOW]);

				case 'drugs-and-rap':
					timeBar.createGradientFilledBar([FlxColor.GREEN, FlxColor.RED]);

				case 'gore' | 'blood-bath' | 'abandoned' | 'misery' | 'suffering' | 'bite':
					timeBar.createGradientFilledBar([FlxColor.WHITE, FlxColor.BLACK]);

				case 'goffy-funkin' | 'dingle' | 't-song':
					timeBar.createGradientFilledBar([FlxColor.WHITE, FlxColor.BROWN]);

				case 'elections':
					timeBar.createGradientFilledBar([FlxColor.RED, FlxColor.GREEN]);

				case 'pixelated':
					timeBar.createGradientFilledBar([FlxColor.WHITE, FlxColor.CYAN]);

				default:
					timeBar.createGradientFilledBar([FlxColor.WHITE, FlxColor.BLUE]);
			}

	    	switch(curStage){
		    	case 'Starved' | 'suicide' | 'other_booba' | 'florest':
			    	remove(timeBarBG);
			    	remove(timeBar);
	    	}

			switch(curStage)
			{
				case 'Starved':
					/*healthBar.angle = 90;
					healthBar.x += 508;
					healthBar.y -= 290;
			
					healthBarBOB.angle = 90;
					healthBarBOB.x += 500;
					healthBarBOB.y -= 300;
						
					heltfbarOV.angle = 90;
					heltfbarOV.x += 500;
					heltfbarOV.y -= 300;
					
					iconP1.x += 1050;
					iconP2.x += 1050;*/

					skipCountdown = true;

				case 'other_booba' | 'haha BG' | 'Jonh House' | 'TrollBG' | 'suicide' | 'mokey' | 'mokey1' | 'Glitch Stage' | 'Sanic Stage':
					skipCountdown = true;
			}

			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (skipCountdown || startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 500);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
				}

				var isAnimatedCountdown:Bool = true;

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['animated intro/ready', 'animated intro/set', 'animated intro/fuckyeah', 'animated intro/go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/fuckyeah-pixel', 'pixelUI/date-pixel']);
				introAssets.set('3D', ['3DUI/ready-3D', '3DUI/set-3D', '3DUI/fuckyeah-3D', '3DUI/go-3D']);
				introAssets.set('awesome', ['awesomeUI/ready-awesome', 'awesomeUI/set-awesome',  'awesomeUI/fuckyeah-awesome', 'awesomeUI/go-awesome']);
				introAssets.set('ourple', ['Ourple/onyourmarks', 'Ourple/ready-ourple',  'Ourple/set-ourple', 'Ourple/go-ourple']);
				introAssets.set('fucked', ['FUCKED HUD/ready-fucked', 'FUCKED HUD/set-fucked',  'FUCKED HUD/fuckyeah-fucked', 'FUCKED HUD/go-fucked']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage){
					isAnimatedCountdown = false;
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				switch(curStage)
				{
					case 'BOB SCENE WEEK 3D':
						isAnimatedCountdown = false;
						introAlts = introAssets.get('3D');
						antialias = false;

					case 'florest':
						isAnimatedCountdown = false;
						introAlts = introAssets.get('awesome');
						antialias = false;

					case 'sherek' | 'Sanic Stage' | 'Baldi School':
						isAnimatedCountdown = false;
						introAlts = introAssets.get('fucked');
						antialias = false;

					case 'ourpleBg':
						isAnimatedCountdown = false;
						introAlts = introAssets.get('ourple');
						antialias = false;
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);
	
					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					// new animated intro :)
					case 0:
						countdownReady = new FlxSprite();
						if(isAnimatedCountdown){
							countdownReady.frames = Paths.getSparrowAtlas((introAlts[0]));
							countdownReady.animation.addByPrefix('idle', "3", 24);
							countdownReady.animation.play('idle');
						}else{
							countdownReady.loadGraphic(Paths.image(introAlts[0]));
						}
						countdownReady.scale.set(1.1, 1.1);
						countdownReady.scrollFactor.set();
						countdownReady.updateHitbox();

						if (PlayState.isPixelStage)
							countdownReady.setGraphicSize(Std.int(countdownReady.width * daPixelZoom));

						countdownReady.screenCenter();
						countdownReady.antialiasing = antialias;
						add(countdownReady);
						FlxTween.tween(countdownReady, {/*y: countdownReady.y + -100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownReady);
								countdownReady.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);

					case 1:
						countdownSet = new FlxSprite();
						if(isAnimatedCountdown){
							countdownSet.frames = Paths.getSparrowAtlas((introAlts[1]));
							countdownSet.animation.addByPrefix('idle', "2", 24);
							countdownSet.animation.play('idle');
						}else{
							countdownSet.loadGraphic(Paths.image(introAlts[1]));
						}
						countdownSet.scale.set(1.1, 1.1);
						countdownSet.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownSet.setGraphicSize(Std.int(countdownSet.width * daPixelZoom));

						countdownSet.screenCenter();
						countdownSet.antialiasing = antialias;
						add(countdownSet);
						FlxTween.tween(countdownSet, {/*y: countdownSet.y + -100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownSet);
								countdownSet.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);

					case 2:
						countdownfuckyeah = new FlxSprite();
						if(isAnimatedCountdown){
							countdownfuckyeah.frames = Paths.getSparrowAtlas((introAlts[2]));
							countdownfuckyeah.animation.addByPrefix('idle', "1", 24);
							countdownfuckyeah.animation.play('idle');
						}else{
							countdownfuckyeah.loadGraphic(Paths.image(introAlts[2]));
						}
						countdownfuckyeah.scale.set(1.1, 1.1);
						countdownfuckyeah.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));

						countdownfuckyeah.updateHitbox();

						countdownfuckyeah.screenCenter();
						countdownfuckyeah.antialiasing = antialias;
						add(countdownfuckyeah);
						FlxTween.tween(countdownfuckyeah, {/*y: countdownfuckyeah.y + -100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownfuckyeah);
								countdownfuckyeah.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);

					case 3:
						countdownGo = new FlxSprite();
						if(isAnimatedCountdown){
							countdownGo.frames = Paths.getSparrowAtlas((introAlts[3]));
							countdownGo.animation.addByPrefix('idle', "go", 19);
							countdownGo.animation.play('idle');
						}else{
							countdownGo.loadGraphic(Paths.image(introAlts[3]));
						}
						countdownGo.scale.set(1.1, 1.1);
						countdownGo.scrollFactor.set();

						if (PlayState.isPixelStage)
							countdownGo.setGraphicSize(Std.int(countdownGo.width * daPixelZoom));
	
						countdownGo.updateHitbox();

						countdownGo.screenCenter();
						countdownGo.antialiasing = antialias;
						add(countdownGo);
						FlxTween.tween(countdownGo, {/*y: countdownGo.y + -100,*/ alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								remove(countdownGo);
								countdownGo.destroy();
							}
						});
						//countdownGo.angularVelocity = 500;
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);

					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = note.multAlpha;
					if(ClientPrefs.middleScroll && !note.mustPress) {
						note.alpha *= 0.5;
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		switch(SONG.song.toLowerCase()) 
		{
			case 'slow':
				FreeplaySaves.trueSlow = 'unlocked';
		}
		FreeplaySaves.saveShit();

		if(ClientPrefs.eastereggs)
		{
			if(FlxG.random.bool(10))
			{ 
				spin = true;
		
				if (spin == true)
				{
					boyfriend.angularVelocity = 100;
					dad.angularVelocity = 100;
					gf.angularVelocity = 100;
				}
			}
		
			if(FlxG.random.bool(90))
			{ 
				spin = false;
		
				if (spin == false)
				{ 
					boyfriend.angularVelocity = 0;
					dad.angularVelocity = 0;
					gf.angularVelocity = 0;
				}
			}
		}

		// this leaves the arrows in the middle lol
		switch(curSong)
		{
			case 'midnight-snack' | 'malware':
				playerStrums.forEach(function(spr:FlxSprite)
				{
		    		FlxTween.tween(spr, {x: (spr.x - 320)}, 0.2, {ease: FlxEase.quadOut});
				});

			case 'curse':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {x: (spr.x - 320)}, 0.2, {ease: FlxEase.quadOut});
				});
		
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.scale.set(0.030, 0.030);
				    FlxTween.tween(spr, {x: (spr.x - -320)}, 0.2, {ease: FlxEase.quadOut});
					spr.alpha = 0.30;
				});	
		}
		
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();
	
		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		
		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}
		
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1 && ClientPrefs.middleScroll) targetAlpha = 0.35;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;

				FlxTween.tween(babyArrow, {y: babyArrow.y - -475});
				//FlxTween.angle(babyArrow, 0, 490, 1.5);
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

				// just a little test lol
				//FlxTween.tween(babyArrow, {y: babyArrow.y - 80});
				//FlxTween.tween(babyArrow, {y: babyArrow.y + 80, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				//FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

				//FlxTween.tween(babyArrow, {y: babyArrow.y - -475});
				//FlxTween.tween(babyArrow, {y: babyArrow.y - 475});
				//FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.alpha = targetAlpha;
			}

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}
			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = false;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;
			
			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	var coisa:Float = 0;
	var fucked:Bool = false;
	var onetime:Bool = true;

	override public function update(elapsed:Float)
	{
		if(curStage == 'Glitch Stage'){
			clouds.scrollX -= 30 * elapsed;
		}
	
		if (youCanPressSpace && FlxG.keys.justPressed.SPACE)
		{
			spaceHit = true;
		}else{
			youDontHitSpace = true;
		}

		/*if(youCanHitSpace && FlxG.keys.justPressed.SPACE)
		{
			hitted -= 1;
		}*/

		if (ClientPrefs.shaders)
		{
			switch(curStage)
			{
				case "candy" | "drakeBG" | "dont_use_drugs" | "laugh" | "BOB SCENE WEEK 3":
					wiggleEffect.update(elapsed);
			}
		}

		switch(curSong){

			case 'party'| 'Monobob' | 'gore' | 'midnight-snack' | 'malware':
				opponentStrums.forEach(function(spr:FlxSprite)
				{
					spr.x += 5000;
				});
		}

		if (curSong == "midnight-snack")
		{
			timeTxt.x = 945;
			timeTxt.y = 575;

			add(barraMedo);
			add(barraMedoBG);
		}

		if (robertoShit == true)
		{
			if (curStage == 'BOB SCENE WEEK 2')
			{
				FlxMouseEventManager.add(garcelloDead,function onMouseDown(garcelloDead:RobertoBg) {
					vocals.stop();
					MusicBeatState.switchState(new Roberto());
				}); 
			}
		}

		if (curStage == 'BOB SCENE WEEK 2')
		{
			if (FlxG.random.bool(20)){
				FlxG.mouse.visible = true;
			}

			FlxMouseEventManager.add(chocolate,function onMouseDown(chocolate:BobCustomBg) {
				if(FlxG.save.data.brobGonal != true){
					FlxG.save.data.brobGonal = true;
				}
			});
	    }

		switch(curSong){
			
			case 'fatass' | 'pixelated' | 'bitcrusher' | 'overtime' | 'overdrive' | 'Suffering' | 'midnight-snack' | 'curse' | 'florest' | 'malware' | 'abandoned':
				remove(janelaSong);
				remove(janelaSongTxt);

			case 'anomaly':
				remove(janelaSong);
		}

		switch(curSong)
		{
			case 'fatass':
				add(plate);

			case 'malware':
				add(idiotBar);
				add(idiotTxt);

			case 'pixelated':
		
				add(pixelBar);
				add(pixelText);

			case 'bitcrusher' | 'overtime' | 'overdrive':
				add(songBar3D);
				add(songBar3DTxt);

			case 'Suffering':
				add(black);
				add(blackTxt);

			case 'curse':
				add(black);
				add(blackTxt);

			case 'abandoned':
				add(trollBar);
				add(trollTxt);
		}

		rubyText.text = 'rubys: $rubys';
		counter.text = 'Total Hits: ' + songHits + '\n' + 'Sicks: ' + sicks + '\n' + 'Goods: ' + goods + '\n' + 'Bads: ' + bads + '\n' + 'Shits: ' + shits + '\n';
		coinText.text = 'Coins: ' + Std.string(fiveCoins) + '/5';

		puppetCountdown -= 0.001;

		if(haveMusicBox)
		{
			FlxG.mouse.visible = true;

			FlxMouseEventManager.add(musicBox,function onMouseDown(musicBox:FlxSprite)
			{
				if (puppetBar.percent < 100){
					puppetCountdown += 0.25;
				} else if (puppetBar.percent > 100){
					puppetCountdown += 0;
				} 
			});

			if(puppetCountdown <= 0)
			{
				inCutscene = true;
				canPause = false;
				FlxG.sound.play(Paths.sound('freddySpoopy'), 30);

				puppet.animation.play('idle');
				add(puppet);
	
				camHUD.visible = false;
				FlxG.sound.music.volume = 0;
				instance.vocals.volume = 0;
				FlxG.sound.music.stop();
				FlxG.sound.music.pause();
				vocals.pause();
	
				new FlxTimer().start(0.5, function(tmr:FlxTimer){
					health = 0;
				});
			}
		}

		// test
		/*if (FlxG.keys.justReleased.SPACE && !onetime)
		{
			boyfriend.animation.play('boyfriend attack');
			
			onetime = true;
			coisa = 40;
			health += 2;
			
			if (coisa > 0)
			{
				coisa -= elapsed;
				fucked = true;
			} else {
				fucked = false;
			}
		}*/
		
		switch(curSong)
		{
			case 'party' | 'curse' | 'malware' | 'Monobob':
				boyfriend.alpha = 0;

			default:
				boyfriend.alpha = 1;
		}

		if (FlxG.keys.justPressed.F10)
		{
			status.alpha = 1;
	
			new FlxTimer().start(2.0, function(tmr:FlxTimer) {
				FlxTween.tween(status, {alpha:0}, 0.6, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
					status.alpha = 0;
				}});
			});
		}

		switch(curSong){

			case 'glitcher':
				Lib.application.window.title = "CHEATER";

			case 'boobs':
				Lib.application.window.title = "I Like Boobs LOL";

			case 'curse':
				Lib.application.window.title = "DONT RUN FROM ME";
			
			case 'malware':
				Lib.application.window.title = "YOU ARE AN IDIOT HAHAHAHAHA";
		}

		callOnLuas('onUpdate', [elapsed]);

		if (medo > 2) medo = 2;
        if (medo < 0) medo = 0;

		if (barraMedo.percent == 100 && medo == 2) {
			health = 0;
		}

		//if(testBar.percent == 100 && gayTest == 5){
			//health = 0;
		//}

		switch (curStage)
		{
			case 'schoolEvil':
				if(!ClientPrefs.lowQuality && bgGhouls.animation.curAnim.finished) {
					bgGhouls.visible = false;
				}
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoParticles.forEach(function(spr:BGSprite) {
						if(spr.animation.curAnim.finished) {
							spr.kill();
							grpLimoParticles.remove(spr, true);
							spr.destroy();
						}
					});

					switch(limoKillingState) {
						case 1:
							limoMetalPole.x += 5000 * elapsed;
							limoLight.x = limoMetalPole.x - 180;
							limoCorpse.x = limoLight.x - 50;
							limoCorpseTwo.x = limoLight.x + 35;

							var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
							for (i in 0...dancers.length) {
								if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 130) {
									switch(i) {
										case 0 | 3:
											if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

											var diffStr:String = i == 3 ? ' 2 ' : ' ';
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);
											var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
											grpLimoParticles.add(particle);

											var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
											particle.flipX = true;
											particle.angle = -57.5;
											grpLimoParticles.add(particle);
										case 1:
											limoCorpse.visible = true;
										case 2:
											limoCorpseTwo.visible = true;
									} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
									dancers[i].x += FlxG.width * 2;
								}
							}

							if(limoMetalPole.x > FlxG.width * 2) {
								resetLimoKill();
								limoSpeed = 800;
								limoKillingState = 2;
							}

						case 2:
							limoSpeed -= 4000 * elapsed;
							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x > FlxG.width * 1.5) {
								limoSpeed = 3000;
								limoKillingState = 3;
							}

						case 3:
							limoSpeed -= 2000 * elapsed;
							if(limoSpeed < 1000) limoSpeed = 1000;

							bgLimo.x -= limoSpeed * elapsed;
							if(bgLimo.x < -275) {
								limoKillingState = 4;
								limoSpeed = 800;
							}

						case 4:
							bgLimo.x = FlxMath.lerp(bgLimo.x, -150, CoolUtil.boundTo(elapsed * 9, 0, 1));
							if(Math.round(bgLimo.x) == -150) {
								bgLimo.x = -150;
								limoKillingState = 0;
							}
					}

					if(limoKillingState > 2) {
						var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
						for (i in 0...dancers.length) {
							dancers[i].x = (370 * i) + bgLimo.x + 280;
						}
					}
				}
			case 'mall':
				if(heyTimer > 0) {
					heyTimer -= elapsed;
					if(heyTimer <= 0) {
						bottomBoppers.dance(true);
						heyTimer = 0;
					}
				}
		}

		gaySex.forEach(function(spr:FlxSprite)
		{
			if(FlxCollision.pixelPerfectCheck(spr, boyfriend)){
				health -= 0.5;
				spr.kill();
				gaySex.remove(spr, true);
				spr.destroy();
				boyfriend.playAnim('hurt', true);
		
				new FlxTimer().start(0.2, function(tmr:FlxTimer) {
					health += 0;
				});
			}else{
				health += 0;
			}

			FlxMouseEventManager.add(spr,function onMouseDown(spr:FlxSprite) 
			{
				spr.kill();
				gaySex.remove(spr, true);
				spr.destroy();
			});
		});

		// death screens 
		switch(boyfriend.curCharacter)
		{
			case 'Mongus BF':
				GameOverSubstate.characterName = 'Mongus BF Die';

			case 'bf_sp':
				GameOverSubstate.characterName = 'bfSP Death';

			case 'Mark':
				GameOverSubstate.characterName = 'mark death';

			case 'bolsa o naro':
				GameOverSubstate.characterName = 'bolos_dead';

			case 'friendBoy':
				GameOverSubstate.characterName = 'friendBoy dead';

			case 'gf invisible1':
				GameOverSubstate.characterName = 'hillaryDead';

			case 'security bob':
				GameOverSubstate.characterName = 'sponge dead';
				GameOverSubstate.deathSoundName = 'random/audio-' + FlxG.random.int(1,5);

			case 'BF3D':
				GameOverSubstate.characterName = 'Bf 3D dead';

			case 'ourpleplay':
				GameOverSubstate.characterName = 'ourpleplay';
				GameOverSubstate.deathSoundName = 'ourple_death';
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		super.update(elapsed);

		if (curStage != 'other_booba' && curStage != 'florest' && curStage != 'Starved'){

			if(ratingName == '???') {
				scoreTxt.text = 'Score: ' + songScore + ' / Combo Breaks : ' + songMisses + ' / Rating : ' + ratingName;
			} else {
				scoreTxt.text = 'Score: ' + songScore + ' / Combo Breaks : ' + songMisses + ' /  Rating : ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;
			}
		}else{
			scoreTxt.text = 'Score: ' + songScore + ' / Misses: ' + songMisses;
		}

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
			    {
					// gitaroo man easter egg
					FlxG.switchState(new GitarooPause());
				}
				else
					if(FlxG.sound.music != null) 
					{
						FlxG.sound.music.pause();
						vocals.pause();
					}
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		//FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
        //FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;
		
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		switch(ClientPrefs.icons)
		{
			case 'Kade icon bouncy':
				iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
				iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));
		
				iconP1.updateHitbox();
				iconP2.updateHitbox();
		
				var iconOffset:Int = 26;
		
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

			case 'Psych old icon bouncy':
				iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
				iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
				
				iconP1.updateHitbox();
				iconP2.updateHitbox();
		
				var iconOffset:Int = 26;
	
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		}
		
        if (health > 2) health = 2;

        if (healthBar.percent > 20 && healthBar.percent < 80) {
            iconP1.animation.play("idle");
            iconP2.animation.play("idle");

			switch(dad.curCharacter)
			{
				case 'starved' | 'Gilbert':
					iconP2.angle = 1;

				case 'Mad bob':
					iconP2.angle = FlxG.random.int(1,12);
			}

        } else if (healthBar.percent > 80) {
            iconP1.animation.play("win");
            iconP2.animation.play("lose");

			switch(dad.curCharacter)
			{
				case 'starved' | 'Gilbert':
					iconP2.angle = FlxG.random.int(1,20);

				case 'Mad bob':
					iconP2.angle = FlxG.random.int(1,43);
			}

        } else if (healthBar.percent < 20) {
            iconP1.animation.play("lose");
            iconP2.animation.play("win");

			switch(dad.curCharacter)
			{
				case 'Mad bob':
					iconP2.angle = FlxG.random.int(1,4);
			}
        }

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) 
				{
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					var songElapsed:Float = Math.floor(songLength / 1000);
					
					switch (ClientPrefs.timeBarType)
					{
						case 'Time Left':
							songCalc = curTime;
							timeTxt.text = FlxStringUtil.formatTime(Math.floor(songElapsed - secondsTotal), false) + ' / ' + FlxStringUtil.formatTime(Math.floor(songLength / 1000), false);
							//timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);

						case 'Time Elapsed':
							songCalc = curTime;
							timeTxt.text = FlxStringUtil.formatTime(Math.floor(songElapsed - secondsTotal), false) + ' / ' + FlxStringUtil.formatTime(Math.floor(songLength / 1000), false);
					
						case 'Song Name':
							timeTxt.text = SONG.song;
							timeTxt.size = 24;
							timeTxt.y += 3;
					}
				}
			}
		}

		if (camZooming)
		{
		    FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;//shit be werid on 4:3
			if(songSpeed < 1) time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene) {
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) //Downscroll
				{
					//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}
				else //Upscroll
				{
					//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;
				
				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if(PlayState.isPixelStage) {
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
							} else {
								daNote.y -= 19;
							}
						} 
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote && !fucked)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}
				
				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
					(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();
		
		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	// TEST, TEST, TEST, TEST
	/*function bullShitSPACE(){
		youCanHitSpace = true;

		var spaceTEXT:FlxText = new FlxText(945, 855);
		spaceTEXT.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		spaceTEXT.text = '' + hitted + 'X';
        spaceTEXT.borderSize = 1.35;
		add(spaceTEXT);

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			if(hitted <= 0){
				health += 0;
				youCanHitSpace = false;
			}
			if(hitted >= 0)
			{
				new FlxTimer().start(0.1, function(tmr:FlxTimer){
					if(health > 0.05)
					{
						health -= 0.0090;
					}
				});	
			}
		});
	}*/

	function hitSpaceBar()
	{
		canPause = false;
		youCanPressSpace = true;

		var spaceBar:FlxSprite = new FlxSprite(945, 855);
		spaceBar.frames = Paths.getSparrowAtlas('spaceBar/botao');
		spaceBar.animation.addByPrefix('idle', "click", 24);
		spaceBar.animation.play('idle');
		add(spaceBar);

		var warning:FlxSprite = new FlxSprite();
		warning.frames = Paths.getSparrowAtlas('spaceBar/warning');
		warning.animation.addByPrefix('idle', "animação", 24);
		warning.animation.play('idle');
		warning.x = spaceBar.x;
		warning.y = spaceBar.y + -56;
		add(warning);

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			if(youCanPressSpace)
			{
				if(spaceHit)
				{
					health += 0.10;
				}
				if(youDontHitSpace && !spaceHit)
				{
					health -= 0.70;
				}
			}

			FlxTween.tween(spaceBar, {alpha:0}, 0.6, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween)
			{
				warning.destroy();
				spaceBar.destroy();
			}});

			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				canPause = true;
				spaceHit = false;
				youDontHitSpace = true;
				youCanPressSpace = false;
			});
		});
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end

		switch(SONG.song.toLowerCase()){
			case 'beast':
				if(ClientPrefs.eastereggs)
				{
					FlxG.sound.music.volume = 0;
			
					chartingMode = false;
					MusicBeatState.switchState(new BEAST());
				}
	
			case 'glitcher' | 'curse':
				Sys.exit(1);

			case 'anomaly':
				FlxG.sound.music.volume = 0;

				chartingMode = false;
				MusicBeatState.switchState(new GilbertGarfieldJumpscare());
		}
		//FlxTransitionableState.skipNextTransIn = true;
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	// intercept cool countdown
	function fakeCountdown(shit:Int){

		switch(shit){

			case 1:
				var countdown:FlxSprite = new FlxSprite();
				countdown.loadGraphic(Paths.image("fakeCountdown/ready"));
				countdown.screenCenter();
				countdown.cameras = [camHUD];
				add(countdown);
				FlxTween.tween(countdown, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
					{
						countdown.destroy();
					}
				});

			case 2:
				var countdown:FlxSprite = new FlxSprite();
				countdown.loadGraphic(Paths.image("fakeCountdown/set"));
				countdown.screenCenter();
				countdown.cameras = [camHUD];
				add(countdown);
				FlxTween.tween(countdown, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
					{
						countdown.destroy();
					}
				});

			case 3:
				var countdown:FlxSprite = new FlxSprite();
				countdown.loadGraphic(Paths.image("fakeCountdown/go"));
				countdown.screenCenter();
				countdown.cameras = [camHUD];
				add(countdown);
				FlxTween.tween(countdown, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
					{
						countdown.destroy();
					}
				});
		}
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Blammed Lights':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;

				var chars:Array<Character> = [boyfriend, gf, dad];
				if(lightId > 0 && curLightEvent != lightId) {
					if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

					var color:Int = 0xffffffff;
					switch(lightId) {
						case 1: //Blue
							color = 0xff31a2fd;
						case 2: //Green
							color = 0xff31fd8c;
						case 3: //Pink
							color = 0xfff794f7;
						case 4: //Red
							color = 0xfff96d63;
						case 5: //Orange
							color = 0xfffba633;
					}
					curLightEvent = lightId;

					if(blammedLightsBlack.alpha == 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});

						for (char in chars) {
							if(char.colorTween != null) {
								char.colorTween.cancel();
							}
							char.colorTween = FlxTween.color(char, 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
								char.colorTween = null;
							}, ease: FlxEase.quadInOut});
						}
					} else {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = null;
						blammedLightsBlack.alpha = 1;

						for (char in chars) {
							if(char.colorTween != null) {
								char.colorTween.cancel();
							}
							char.colorTween = null;
						}
						dad.color = color;
						boyfriend.color = color;
						if (gf != null)
							gf.color = color;
					}
					
					if(curStage == 'philly') {
						if(phillyCityLightsEvent != null) {
							phillyCityLightsEvent.forEach(function(spr:BGSprite) {
								spr.visible = false;
							});
							phillyCityLightsEvent.members[lightId - 1].visible = true;
							phillyCityLightsEvent.members[lightId - 1].alpha = 1;
						}
					}
				} else {
					if(blammedLightsBlack.alpha != 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});
					}

					if(curStage == 'philly') {
						phillyCityLights.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});
						phillyCityLightsEvent.forEach(function(spr:BGSprite) {
							spr.visible = false;
						});

						var memb:FlxSprite = phillyCityLightsEvent.members[curLightEvent - 1];
						if(memb != null) {
							memb.visible = true;
							memb.alpha = 1;
							if(phillyCityLightsEventTween != null)
								phillyCityLightsEventTween.cancel();

							phillyCityLightsEventTween = FlxTween.tween(memb, {alpha: 0}, 1, {onComplete: function(twn:FlxTween) {
								phillyCityLightsEventTween = null;
							}, ease: FlxEase.quadInOut});
						}
					}

					for (char in chars) {
						if(char.colorTween != null) {
							char.colorTween.cancel();
						}
						char.colorTween = FlxTween.color(char, 1, char.color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
							char.colorTween = null;
						}, ease: FlxEase.quadInOut});
					}

					curLight = 0;
					curLightEvent = 0;
				}

			case 'Kill Henchmen':
				killHenchmen();

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}

			case 'Trigger BG Ghouls':
				if(curStage == 'schoolEvil' && !ClientPrefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();
			
			case 'BG Freaks Expression':
				if(bgGirls != null) bgGirls.swapDanceType();
			
			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}

			case 'Alter Text':
				inScreenText.text = value1;

				var iconName:String;
				iconName = Std.string(value2);
				
			case 'spin':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.angle(spr, 0, 360, 0.1);
				});

			case 'Fake Countdown':
				var fuck:Int;
				fuck = Std.parseInt(value1);

				switch(fuck){
					case 1:
						fakeCountdown(1);

					case 2:
						fakeCountdown(2);

					case 3:
						fakeCountdown(3);
				}			

			case 'Spin Shit':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					spr.angularVelocity = 100;

					new FlxTimer().start(6.8, function(tmr:FlxTimer){
						spr.angularVelocity = 0;
					});
				});

			case 'Pop Ups':
				var popUpsShit:FlxSprite = new FlxSprite();
				popUpsShit.loadGraphic(Paths.image('popUps/Normal/popUp-' + FlxG.random.int(1,20)));
				popUpsShit.x = FlxG.random.float(125.3, 425.68);
				popUpsShit.y = FlxG.random.float(116.3, 568.68);
				popUpsShit.cameras = [camHUD];
				add(popUpsShit);

				new FlxTimer().start(5.8, function(tmr:FlxTimer){
					FlxTween.tween(popUpsShit, {alpha:0}, 0.8, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
						popUpsShit.destroy();
					}});
				});

				if (FlxG.random.bool(2)){
					var secretPopUp:FlxSprite = new FlxSprite();
					secretPopUp.loadGraphic(Paths.image('popUps/secret/Essence/exe'));
					secretPopUp.x = FlxG.random.float(125.3, 425.68);
					secretPopUp.y = FlxG.random.float(116.3, 568.68);
					secretPopUp.cameras = [camHUD];
					add(secretPopUp);
	
					new FlxTimer().start(5.8, function(tmr:FlxTimer){
						FlxTween.tween(secretPopUp, {alpha:0}, 0.8, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
							secretPopUp.destroy();
						}});
					});
				}

			case 'Idiot Pop Up':
				FlxG.mouse.visible = true;

				var idiotPopUp:FlxSprite = new FlxSprite();
				idiotPopUp.loadGraphic(Paths.image('popUps/IdiotPopUps/popUp-' + FlxG.random.int(1,11)));
				idiotPopUp.x = FlxG.random.float(125.3, 425.68);
				idiotPopUp.y = FlxG.random.float(116.3, 568.68);
				idiotPopUp.updateHitbox();
				idiotPopUp.cameras = [camHUD];
				add(idiotPopUp);

				var xBotton:FlxSprite = new FlxSprite();
				xBotton.loadGraphic(Paths.image('popUps/IdiotPopUps/x'));
				xBotton.x = idiotPopUp.x +573;
				xBotton.y = idiotPopUp.y +1;
				xBotton.updateHitbox();
				xBotton.cameras = [camHUD];
				add(xBotton);

				FlxMouseEventManager.add(xBotton,function onMouseDown(xBotton:FlxSprite) {

					/*FlxTween.tween(xBotton.scale,{x:0.1, y: 0.1}, 0.3, {
						onComplete: function(twn:FlxTween) {
							remove(xBotton);
						}
					});

					FlxTween.tween(idiotPopUp.scale,{x:0.1, y: 0.1}, 0.3, {
						onComplete: function(twn:FlxTween) {
							remove(idiotPopUp);
						}
					});*/

					FlxTween.tween(idiotPopUp, {alpha:0}, 0.8, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
						remove(idiotPopUp);
					}});

					FlxTween.tween(xBotton, {alpha:0}, 0.8, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
						remove(xBotton);
					}});
				});

			case 'Black':
				camGame.alpha = 0;
	
			case 'Black1':
			    camGame.alpha = 1;
			
			case 'flash':
				var flashs:Int = 0;
				flashs = Std.parseInt(value1);

				switch(flashs)
				{
					case 0:
						camGame.flash(FlxColor.RED, 0.75);

					case 1:
						camGame.flash(FlxColor.WHITE, 0.75);

					case 2:
						camGame.flash(FlxColor.BLACK, 0.75);

					case 3:
						camGame.flash(FlxColor.BLUE, 0.75);
					
					case 4:
						camGame.flash(FlxColor.PURPLE, 0.75);

					case 5:
						camGame.flash(FlxColor.CYAN, 0.75);

					case 6:
						camGame.flash(FlxColor.PINK, 0.75);

					case 7:
						camGame.flash(FlxColor.GREEN, 0.75);
				}

			case 'bad amongus':
				sus.anim('idle');
				sus.alpha = 1;
				add(sus);

				var glass:BobCustomBg = new BobCustomBg('bgs/intercept/punch/glass.png 2023');
				glass.cameras = [camHUD];

				FlxTween.tween(sus, {y: 45}, 1, {ease: FlxEase.quadOut});

				new FlxTimer().start(2.5, function(tmr:FlxTimer){
					FlxG.sound.play(Paths.sound('punch'), 60);
					sus.anim('punch');
				});

				new FlxTimer().start(2.5, function(tmr:FlxTimer){
					add(glass);
					FlxTween.tween(sus, {y: 780}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
					{
						sus.alpha = 0;
					}});
				});

				new FlxTimer().start(22.5, function(tmr:FlxTimer){
					FlxTween.tween(glass, {alpha: 0}, 0.2, {onComplete: function(tween:FlxTween){
						glass.destroy();
					}});
				});
				
			case 'rubys':
				var rubysShit:Int = 0;
				rubysShit = Std.parseInt(value1);

				var time:Int = 0;
				time = Std.parseInt(value2);

			    //morshu.alpha = 0.43;
				//add(morshu);

				var totalRubys:FlxText = new FlxText();
				totalRubys.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				totalRubys.x = rubyText.x + 141;
				totalRubys.y = rubyText.y;
				totalRubys.visible = true;
				totalRubys.text = '/' + rubysShit;
				add(totalRubys);

				rubyText.visible = true;
				add(rubyText);

				new FlxTimer().start(time, function(tmr:FlxTimer){
					if(rubys >= rubysShit)
					{
						//morshu.alpha = 0;.
						totalRubys.visible = false;
						rubyText.visible = false;
						health -= 0;
						rubys -= 0;
					}else{
						health -= 500;
					}
					rubys -= rubys;
				});

			case 'note Shit':
				playerStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {x: (spr.x + -630)}, 4, {ease: FlxEase.quadIn, type: PINGPONG});
				});

				opponentStrums.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {x: (spr.x + 630)}, 4, {ease: FlxEase.quadIn, type: PINGPONG});
				});

			case 'Funny :clown:':
			    FlxTween.tween(boyfriend, {y: (boyfriend.y + -630)}, 4, {ease: FlxEase.quadIn, type: PINGPONG});
			    FlxTween.tween(gf, {y: (boyfriend.y + -630)}, 4, {ease: FlxEase.quadIn, type: PINGPONG});
			    FlxTween.tween(dad, {y: (dad.y + -630)}, 4, {ease: FlxEase.quadIn, type: PINGPONG});	
			
			case 'Space Shit':
				hitSpaceBar();

			case 'random window position':
				evilWindow();

			case 'normal window position':
				goodWindow();

			case 'five coins':
				//var gayTimer:Int = 0;
				//gayTimer = Std.parseInt(value1);

				//timer = gayTimer;

				coinText.alpha = 1;
				coinsShit();

			case 'add coin':
				addCoin();

			case 'shadows':
				var shadows:Int = 0;
				shadows = Std.parseInt(value1);
	
				switch(shadows)
				{
					case 0:
						boyfriend.color = FlxColor.GREEN;
						dad.color = FlxColor.GREEN;
						gf.color = FlxColor.GREEN;
	
					case 1:
						boyfriend.color = FlxColor.RED;
						dad.color = FlxColor.RED;
						gf.color = FlxColor.RED;
	
					case 2:
						boyfriend.color = FlxColor.ORANGE;
						dad.color = FlxColor.ORANGE;
						gf.color = FlxColor.ORANGE;
	
					case 3:
						boyfriend.color = FlxColor.YELLOW;
						dad.color = FlxColor.YELLOW;
						gf.color = FlxColor.YELLOW;
					
					case 4:
						boyfriend.color = FlxColor.PURPLE;
						dad.color = FlxColor.PURPLE;
						gf.color = FlxColor.PURPLE;

					case 5:
						boyfriend.color = FlxColor.BROWN;
						dad.color = FlxColor.BROWN;
						gf.color = FlxColor.BROWN;
	
					case 6:
						boyfriend.color = FlxColor.BLACK;
						dad.color = FlxColor.BLACK;
						gf.color = FlxColor.BLACK;
						
					case 7:
						boyfriend.color = FlxColor.CYAN;
						dad.color = FlxColor.CYAN;
						gf.color = FlxColor.CYAN;
	
					case 8:
						boyfriend.color = FlxColor.BLUE;
						dad.color = FlxColor.BLUE;
						gf.color = FlxColor.BLUE;
				}

			case 'Back to the normal':
				boyfriend.color = FlxColor.WHITE;
				dad.color = FlxColor.WHITE;
				gf.color = FlxColor.WHITE;

			case '>:)':
				camHUD.angle = 180;
				camGame.angle = 180;
				new FlxTimer().start(10.8, function(tmr:FlxTimer){
					camHUD.angle = 360;
					camGame.angle = 360;
				});

			case 'Cam Hud Angle':
				var coolCam:Float;
				coolCam = Std.parseFloat(value1);

				var time:Int;
				time = Std.parseInt(value2);

				tweenShit = FlxTween.tween(camHUD, {angle: coolCam}, 0.5, {ease: FlxEase.quadOut, type: PINGPONG});

				new FlxTimer().start(time, function(tmr:FlxTimer){
					tweenShit.active = false;
				});

				new FlxTimer().start(0.1, function(tmr:FlxTimer){
					tweenShit.active = true;
				});

			case 'windows pop up':
				var text:String;
				text = Std.string(value1);

				var windowName:String;
				windowName = Std.string(value2);

				Application.current.window.alert(text, windowName);

			// TEST SHIT LOL
			case 'TEST':				
				camHUD.angle = FlxG.random.int(1, 50);
		    	new FlxTimer().start(0.8, function(tmr:FlxTimer){
			    	camHUD.angle = 360;
		    	});

			case 'new window':
				var text:String;
				text = Std.string(value1);
		
				var image:String;
				image = Std.string(value2);
	
				var windowBg = new Sprite();
		
				var newWindow = Lib.application.createWindow({
					allowHighDPI: false,
					alwaysOnTop: false,
					borderless: false,
					element: null,
					frameRate: 60,
					fullscreen: false,
					height: 500,
					hidden: false,
					maximized: false,
					minimized: false,
					parameters: {},
					resizable: true,
					title: text,
					width: 500,
					x: FlxG.random.int(90, 330),
					y: FlxG.random.int(90, 300),
				});
		
				var image:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
				add(image);
		
				var rect = new Rectangle(image.x, image.y, image.width, image.height);
	
				windowBg.scrollRect = rect;
				windowBg.graphics.beginBitmapFill(image.pixels);
				windowBg.graphics.drawRect(0, 0, image.pixels.width, image.pixels.height);
				windowBg.graphics.endFill();
				newWindow.stage.addChild(windowBg);

			case 'test shit':
				FlxG.mouse.visible = true;

				add(gaySex);

				var bullshit:FlxSprite = new FlxSprite();
				bullshit.frames = Paths.getSparrowAtlas('happy/Hi There');
				bullshit.animation.addByPrefix('idle', 'idle', 22);
				bullshit.animation.play('idle');
				bullshit.scale.set(1.7, 1.7);
				bullshit.angularVelocity = 100;
				bullshit.velocity.x = 100;
				bullshit.x = dad.x + 30;
				bullshit.y = dad.y + 369;
				gaySex.add(bullshit);

				FlxTween.tween(bullshit, {y: (bullshit.y + -230)}, 4, {ease: FlxEase.quadIn, type: PINGPONG});	
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function addCoin()
	{
		var coinsShited:FlxSprite = new FlxSprite();
		coinsShited.loadGraphic(Paths.image('freddy/coin'));
		coinsShited.x = FlxG.random.float(125.3, 425.68);
		coinsShited.y = FlxG.random.float(116.3, 568.68);
		coinsShited.cameras = [camHUD];
		coinsShited.alpha = 0.56;
		add(coinsShited);

		FlxMouseEventManager.add(coinsShited,function onMouseDown(coinsShited:FlxSprite) 
		{
			coinsShited.destroy();
			fiveCoins++;
		});
	}

	function coinsShit()
	{
		canPause = false;
		FlxG.mouse.visible = true;

		if(FlxG.random.bool(97)){
			FlxG.sound.play(Paths.sound('five coins'), 60);

			var rockStarFreddy:FlxSprite = new FlxSprite(935, 236);
			rockStarFreddy.frames = Paths.getSparrowAtlas('freddy/rockstar freddy');
			rockStarFreddy.animation.addByPrefix('idle', 'idle', 12);
			rockStarFreddy.animation.addByPrefix('angry', 'mad', 12);	
			rockStarFreddy.animation.play('idle');
			rockStarFreddy.scale.set(2.7, 2.7);
			rockStarFreddy.cameras = [camHUD];
			add(rockStarFreddy);
	
			var freddyJumpscare:FlxSprite = new FlxSprite(845, 630);
			freddyJumpscare.frames = Paths.getSparrowAtlas('freddy/scariest_jumpscar_from_2017');
			freddyJumpscare.animation.addByPrefix('jumpscare', 'vish', 43);
			freddyJumpscare.animation.play('jumpscare');
			freddyJumpscare.scale.set(4.7, 4.7);
	
			var payButton:FlxSprite = new FlxSprite(895, 326);
			payButton.loadGraphic(Paths.image('freddy/button'));
			payButton.cameras = [camHUD];
			add(payButton);

			FlxTween.tween(rockStarFreddy, {y: (rockStarFreddy.y + -30)}, 1, {ease: FlxEase.quadIn});

			add(coinText);
	
			FlxMouseEventManager.add(payButton,function onMouseDown(payButton:FlxSprite) 
			{
				if(fiveCoins >= 5)
				{
					youPaid = true;
					fiveCoins -= 5;
					FlxG.sound.play(Paths.sound('buy'));
					FlxTween.tween(rockStarFreddy, {y: 1090}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween){
						coinText.alpha = 0;
						rockStarFreddy.destroy();
					}});
	
					FlxTween.tween(payButton, {y: 1090}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween){
						payButton.destroy();
					}});
					
					canPause = true;
				}else{
					coinText.alpha = 1;
					fiveCoins -= 0;
				}
			});
	
			new FlxTimer().start(10.0 /*timer*/, function(tmr:FlxTimer)
			{
				if(youPaid)
				{
					health += 0;
				}else{
					canPause = false;
					freddyJumpscare.animation.play('jumpscare');
					add(freddyJumpscare);
	
					FlxG.sound.play(Paths.sound('freddySpoopy'), 20);
	
					camHUD.visible = false;
					FlxG.sound.music.volume = 0;
					instance.vocals.volume = 0;
					FlxG.sound.music.stop();
					FlxG.sound.music.pause();
					vocals.pause();
	
					new FlxTimer().start(0.5, function(tmr:FlxTimer){
						health -= 999;
					});
				}
	
				new FlxTimer().start(0.1, function(tmr:FlxTimer){
					youPaid = false;
				});
			});
		}

		// Pouko Easter Egg :)
		if(FlxG.random.bool(3))
		{
			var bear5:FlxSprite = new FlxSprite(935, 236);
			bear5.loadGraphic(Paths.image('freddy/easterEgg/BEAR5'));
			bear5.scale.set(2.7, 2.7);
			bear5.cameras = [camHUD];
			add(bear5);

			FlxTween.tween(bear5, {y: (bear5.y + -30)}, 1, {ease: FlxEase.quadIn});

			// Hi Pouko :)
			var hiPouko:FlxSprite = new FlxSprite(895, 326);
			hiPouko.loadGraphic(Paths.image('freddy/easterEgg/hi pouko'));
			hiPouko.cameras = [camHUD];
			add(hiPouko);

			youPaid = true;
			new FlxTimer().start(10.0 /*timer*/, function(tmr:FlxTimer)
			{
				FlxTween.tween(bear5, {y: 1080}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween){
					bear5.destroy();
				}});
	
				FlxTween.tween(hiPouko, {y: 1080}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween){
					hiPouko.destroy();
				}});

				new FlxTimer().start(0.1, function(tmr:FlxTimer){
					youPaid = false;
				});
			});
		}
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (gf != null && SONG.notes[id].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];
	
			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}

	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.03 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.03 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
		
		timeBarBG.visible = true;
		timeBar.visible = true;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['Week_bob_1', 'Week_bob_2', 'Week_bob_3', 'cheater', 'idiot', 'awesome', 'elections', 'anomaly',
		    'cannibal', 'god', 'party', 'ourple','you are a shit', 'fnf god']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end
		
		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;
	
				storyPlaylist.remove(storyPlaylist[0]);
	
				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}
	
						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();
	
					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);
	
					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;
	
						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}
	
					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
	
					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;
	
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();
	
					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
		    	switch(SONG.song.toLowerCase()) 
		    	{
				    case 'elections':
			     	  	FreeplaySaves.elections = 'unlocked';
	
			    	case 'malware':
			     		FreeplaySaves.malware = 'unlocked';

			    	case 'glitcher':
			      		FreeplaySaves.glitcher = 'unlocked';
	
			    	case 'awesome':
				    	FreeplaySaves.awesome = 'unlocked';
	
			      	case 'anomaly':
				    	FreeplaySaves.anomaly = 'unlocked';
	
			    	case 'curse':
			     		FreeplaySaves.curse = 'unlocked';
	
			    	case 'pixelated':
				    	FreeplaySaves.pixelated = 'unlocked';

			    	case 'system-error':
				    	FreeplaySaves.systemError = 'unlocked';
		     	}
		     	FreeplaySaves.saveShit();
			  
		    	if(Paths.formatToSongPath(SONG.song) == "golden-core")
			    	if(FlxG.save.data.golden != true)
				    	FlxG.save.data.golden = true;

				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}

				switch(curSong){

					/*case 'salvation':
						if(songMisses < 5)
						{
							camHUD.visible = false;
							FlxG.sound.playMusic(Paths.music('gayEnding song'));

							var gayEnding:FlxSprite = new FlxSprite();
							gayEnding.loadGraphic(Paths.image('gay ending'));
							add(gayEnding);

							var gayText:FlxText = new FlxText();
							gayText.text = 'KILL YOURSELF LOLOLOLOLOLOLOLOLOLOLOLOLOL\n\n"""""GOOD ENDING""""';
							gayText.setFormat(Paths.font("vcr.ttf"), 21, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
							add(gayText);

							new FlxTimer().start(11.0, function(tmr:FlxTimer) {
								FlxG.sound.playMusic(Paths.music('freakyMenu'));
								MusicBeatState.switchState(new FreeplayState());
							});
						}else{
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
							MusicBeatState.switchState(new FreeplayState());
						}*/

					case 'system-error':
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						MusicBeatState.switchState(new FreeplayState());
						Application.current.window.borderless = false;

					default:
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						MusicBeatState.switchState(new FreeplayState());
				}

				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showRating:Bool = true;

	//var noMoreGoldenRating:Bool = false;
	var isAnimatedRating:Bool = true;

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;

		var rating:FlxSprite = new FlxSprite();
		var comboSpr:FlxSprite = new FlxSprite();

		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff);

		switch (daRating)
		{
			case "shit": // shit
		    	totalNotesHit += 0;
		    	note.ratingMod = 0;
		    	score = 50;
		    	if(!note.ratingDisabled) shits++;
    		case "bad": // bad
	    		totalNotesHit += 0.5;
		    	note.ratingMod = 0.5;
		    	score = 100;
		    	if(!note.ratingDisabled) bads++;
	    	case "good": // good
		    	totalNotesHit += 0.75;
		 	    note.ratingMod = 0.75;
		    	score = 200;
		    	if(!note.ratingDisabled) goods++;
	    	case "sick": // sick
	 	    	totalNotesHit += 1;
		    	note.ratingMod = 1;
		    	if(!note.ratingDisabled) sicks++;
		}
		note.rating = daRating;

		if(daRating == 'sick' && !note.noteSplashDisabled && !cpuControlled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled)
		{
			songScore += score;
			RecalculateRating();

			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.075;
			scoreTxt.scale.y = 1.075;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
	
			if(timeTween != null) {
				timeTween.cancel();
			}
			timeTxt.scale.x = 1.075;
			timeTxt.scale.y = 1.075;
			timeTween = FlxTween.tween(timeTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					timeTween = null;
				}
			});
		}

		if(!note.ratingDisabled)
		{
			songHits++;
			totalPlayed++;
		}

		/*  if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		*/
		
		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			//noMoreGoldenRating = true;
			isAnimatedRating = false;
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		switch(curStage)
		{
			case 'BOB SCENE WEEK 3D':
				//noMoreGoldenRating = true;
				isAnimatedRating = false;
				pixelShitPart1 = '3DUI/';
				pixelShitPart2 = '-3D';

			case 'florest' | 'politic' | 'Glitch Stage' | 'Baldi School':
				//noMoreGoldenRating = true;
				isAnimatedRating = false;
				pixelShitPart1 = 'awesomeUI/';
				pixelShitPart2 = '-awesome';

			case 'sherek' | 'Sanic Stage':
				//noMoreGoldenRating = true;
				isAnimatedRating = false;
				pixelShitPart1 = 'FUCKED HUD/';
				pixelShitPart2 = '-fucked';

			case 'ourpleBg':
				//noMoreGoldenRating = true;
				isAnimatedRating = false;
				pixelShitPart1 = 'Ourple/';
				pixelShitPart2 = '-ourple';
		}

		if(isAnimatedRating)
		{
			rating.frames = Paths.getSparrowAtlas('animated Rating/rating');
			rating.animation.addByPrefix('idle', daRating, 12);	
			rating.animation.play('idle');

			comboSpr.frames = Paths.getSparrowAtlas('animated Rating/combo');
			comboSpr.animation.addByPrefix('idle', 'combo', 12);
			comboSpr.animation.play('idle');
		}else{
			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			comboSpr.loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		}

		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		//rating.angle = FlxG.random.float(-8.5, 15.3);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		if(isAnimatedRating){
			comboSpr.x += ClientPrefs.comboOffset[0] + -51;
			comboSpr.y -= ClientPrefs.comboOffset[1] + -32;
		}else{
			comboSpr.x += ClientPrefs.comboOffset[0];
			comboSpr.y -= ClientPrefs.comboOffset[1];
		}

		if (combo >= 15 || combo == 0)
			
			add(comboSpr);

		FlxTween.tween(comboSpr.scale,{x:0.1, y: 0.1}, 0.1, {
			onComplete: function(tween:FlxTween){
				comboSpr.destroy();
		    },
			startDelay: Conductor.crochet * 0.001
    	});

		/*switch(curStage){
			case 'ourpleBg' | 'florest' | 'Glitch Stage' | 'sherek' | 'BOB SCENE WEEK 3D' | 'politic':
				rating.angle = FlxG.random.float(1.0, 1.0);
				comboSpr.angle = FlxG.random.float(1.0, 1.0);
		}*/

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if(isAnimatedRating)
		{
			switch(daRating)
			{
				case 'sick':
					rating.setGraphicSize(Std.int(rating.width * 0.98));
	
				case 'good':
					rating.setGraphicSize(Std.int(rating.width * 0.86));
	
				case 'bad' | 'shit':
					rating.setGraphicSize(Std.int(rating.width * 0.65));
			}
	
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.6));
		}else{ 
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		}

		if (PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		if(combo >= 100) {
			seperatedScore.push(Math.floor(combo / 100) % 10);
		}
		if(combo >= 10) {
			seperatedScore.push(Math.floor(combo / 10) % 10);
		}
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			if(isAnimatedRating){
				numScore.frames = Paths.getSparrowAtlas('numbers');
				numScore.animation.addByPrefix('idle', 'num' + Std.int(i), 32);	
				numScore.animation.play('idle');
			}
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			//if (combo >= 15 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween){
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			switch(curStage)
		    {
				case 'haha BG' | 'mokey' | 'mokey1' | 'suicide' | 'Starved' | 'Bus Stop' | 'Jonh House':
					rating.visible = false;
					comboSpr.visible = false;
					numScore.visible = false;

				case 'ourpleBg':
					comboSpr.visible = false;
			}

			if(!ClientPrefs.lowQuality)
			{
				if(curSong == 'system-error') 
				{
					rating.acceleration.y = -130;
					numScore.acceleration.x = -130;
					comboSpr.acceleration.x = 930;
				}
			}

			/*if(noMoreGoldenRating){
				numScore.color = FlxColor.WHITE;
			}else{
				numScore.color = 0xFFFFD000;
			}*/

			daLoop++;
		}

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		/*if(noMoreGoldenRating){
			rating.color = FlxColor.WHITE;
		}else{
			rating.color = 0xFFFFD000;
		}*/

		FlxTween.tween(rating.scale,{x:0.1, y: 0.1}, 0.1, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr.scale,{x:0.1, y: 0.1}, 0.1, {
			onComplete: function(tween:FlxTween){
				coolText.destroy();
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}
							
						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss) {
					noteMissPress(key);
					callOnLuas('noteMissPress', [key]);
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}
	
	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];
		
		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		
		medo += daNote.missHealth * healthGain;

		//gayTest += 0.3;

		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;
		//noMoreGoldenRating = true;

		health -= daNote.missHealth * healthLoss;
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;
		
		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		if(char != null && char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))];
		if(!boyfriend.animation.curAnim.name.endsWith('miss'))
		{
			boyfriend.playAnim(animToPlay, true);
			boyfriend.color = 0xFF4A00D3;

			new FlxTimer().start(0.2, function(tmr:FlxTimer){
				boyfriend.color = FlxColor.WHITE;
			});
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.03 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if(ClientPrefs.ghostTapping) return;

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong) {
				songMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			vocals.volume = 0;
		    // FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
		    }
		
			if(twoOpponents){
				if (note.noteType == "secondOpponent"){
					var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
					newDad.playAnim(animToPlay, true);
					char = newDad;
				}
			}else {
				if (note.noteType == "secondOpponent"){
					char = gf;
				}
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;

		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		if (curStage != 'florest' && curSong != 'system-error') {
			StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		}

		note.hitByOpponent = true;

		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			//gayTest += 0.1;

			switch(curSong)
			{
				// health drain lol
				case 'gore' | 'blood-bath' | 'rivals' | 'alt' | 'system-error' | 'curse' | 'midnight-snack' | 'malware':
					if(health > 0.05)
					{
						health -= maxShit;
					}	
			}

			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			/*if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}*/

			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note); 
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
				if(combo > 9999) combo = 9999;
			}

			health += note.hitHealth * healthGain;

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';
	
				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote) 
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				// all new stuff
				switch(note.noteType)
				{
					case 'invisible':
						playerStrums.forEach(function(spr:FlxSprite)
						{
							spr.visible = false;
							new FlxTimer().start(17.8, function(tmr:FlxTimer) {
								spr.visible = true;
							});
						});

					case 'random notes position':
						playerStrums.forEach(function(spr:FlxSprite)
						{
							spr.y = FlxG.random.float(430.50, 510.80);
							spr.x = FlxG.random.int(110, 375);
						});	
						opponentStrums.forEach(function(spr:FlxSprite)
						{
							spr.x += 5000;
						});	

					case 'palooce notes':
						playerStrums.forEach(function(spr:FlxSprite)
						{
							spr.y += 15;
						});

					case 'ruby Notes':
						rubys++;

					case 'BaldiNotes':
						dad.playAnim('attack', true);
						boyfriend.playAnim('dodge', true);
						FlxG.sound.play(Paths.sound('slap'));

					case 'Lean Notes':
						playerStrums.forEach(function(spr:FlxSprite)
						{
							spr.color = 0xFF7700FF;
						});
						boyfriend.color = 0xFF7322CF;
						gf.color = 0xFF7322CF;
						iconP1.color = 0xFF7322CF;
	
						new FlxTimer().start(0.1, function(tmr:FlxTimer){
							if(health > 0.05)
							{
								health -= 0.0060;
							}
						}, 140);	
		
						new FlxTimer().start(14.8, function(tmr:FlxTimer){
							boyfriend.color = FlxColor.WHITE;
							iconP1.color = FlxColor.WHITE;
							gf.color = FlxColor.WHITE;
		
							playerStrums.forEach(function(spr:FlxSprite){
								spr.color = FlxColor.WHITE;
							});
						});
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}
	
					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}
			
			if(cpuControlled) {
				var time:Float = 0.15;

				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}

				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				//gayTest -= 0.1;
				// just a test lmao
				/*FlxTween.tween(playerStrums.members[0], {x: (playerStrums.members[0].x + 10)}, 0.2, {ease: FlxEase.quadOut});
				FlxTween.tween(playerStrums.members[0], {x: (playerStrums.members[0].x - 10)}, 0.2, {ease: FlxEase.quadOut});

				FlxTween.tween(playerStrums.members[1], {y: (playerStrums.members[1].y - 10)}, 0.2, {ease: FlxEase.quadOut});
				FlxTween.tween(playerStrums.members[1], {y: (playerStrums.members[1].y + 10)}, 0.2, {ease: FlxEase.quadOut});

				FlxTween.tween(playerStrums.members[2], {y: (playerStrums.members[2].y + 10)}, 0.2, {ease: FlxEase.quadOut});
				FlxTween.tween(playerStrums.members[2], {y: (playerStrums.members[2].y - 10)}, 0.2, {ease: FlxEase.quadOut});

				FlxTween.tween(playerStrums.members[3], {y: (playerStrums.members[3].x - 10)}, 0.2, {ease: FlxEase.quadOut});
				FlxTween.tween(playerStrums.members[3], {y: (playerStrums.members[3].x + 10)}, 0.2, {ease: FlxEase.quadOut});*/

				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {

				if(curStage != 'florest') 
				{
                    spawnNoteSplash(strum.x, strum.y, note.noteData, note);
				}
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}
	
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			if (gf != null)
			{
				gf.playAnim('hairBlow');
				gf.specialAnim = true;
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		if(gf != null)
		{
			gf.danced = false; //Sets head to the correct position once the animation ends
			gf.playAnim('hairFall');
			gf.specialAnim = true;
		}
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
			    FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.lowQuality && ClientPrefs.violence && curStage == 'limo') {
			if(limoKillingState < 1) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = 1;

				#if ACHIEVEMENTS_ALLOWED
				Achievements.henchmenDeath++;
				FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;
				var achieve:String = checkForAchievement(['roadkill_enthusiast']);
				if (achieve != null) {
					startAchievement(achieve);
				} else {
					FlxG.save.flush();
				}
				FlxG.log.add('Deaths: ' + Achievements.henchmenDeath);
				#end
			}
		}
	}

	function resetLimoKill():Void
	{
		if(curStage == 'limo') {
			limoMetalPole.x = -500;
			limoMetalPole.visible = false;
			limoLight.x = -500;
			limoLight.visible = false;
			limoCorpse.x = -500;
			limoCorpse.visible = false;
			limoCorpseTwo.x = -500;
			limoCorpseTwo.visible = false;
		}
	}

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) {
			return;
		}

		switch(curSong)
		{
			case 'malware':
				switch(curBeat)
				{
					case 310:
						if (ClientPrefs.links){
							CoolUtil.browserLoad('https://sites.google.com/view/you-are-an-idiot-haha/início?authuser=0');
						}
				}
			
			case 'intercept':
				switch(curBeat)
				{
					case 355:
						camHUD.alpha = 0;
					case 359:
						if(!ClientPrefs.lowQuality){
							emitterShit.emitting = true;
						}
						camHUD.alpha = 1;
				}

			case 'abandoned':
				if(!ClientPrefs.lowQuality)
				{
					switch(curBeat)
					{
						case 145:
							FlxTween.tween(iconP2, {alpha: 0}, 0.2, {onComplete: function(tween:FlxTween){
								iconP2.alpha = 0;
							}});
			
						case 146:
							opponentStrums.forEach(function(spr:FlxSprite)
							{
								FlxTween.tween(spr, {alpha: 0}, 0.2, {onComplete: function(tween:FlxTween){
									spr.alpha = 0;
								}});
							});
			
						case 169:
							FlxTween.tween(iconP2, {alpha: 1}, 0.2, {onComplete: function(tween:FlxTween){
								iconP2.alpha = 1;
							}});
							opponentStrums.forEach(function(spr:FlxSprite)
							{
								FlxTween.tween(spr, {alpha: 0.33}, 0.2, {onComplete: function(tween:FlxTween){
									spr.alpha = 0.33;
								}});
							});
							oldTimes.alpha = 0.47;
					}
				}

			case 'drugs-and-rap':
				switch(curBeat)
				{
					case 207:
						camGame.flash(FlxColor.WHITE, 1);
						camHUD.flash(FlxColor.WHITE, 1);
	
						if(!ClientPrefs.lowQuality)
						{
							emitterShit1.emitting = true;

							FlxTween.tween(playerStrums.members[0], {y: (playerStrums.members[0].y + 190)}, 1.5, {type: PINGPONG});
                            FlxTween.tween(playerStrums.members[1], {y: (playerStrums.members[1].y + 160)}, 1.5, {type: PINGPONG});
                            FlxTween.tween(playerStrums.members[2], {y: (playerStrums.members[2].y + 130)}, 1.5, {type: PINGPONG});
                            FlxTween.tween(playerStrums.members[3], {y: (playerStrums.members[3].y + 100)}, 1.5, {type: PINGPONG});
						}
				}
	
				// boring code blah, blah, blah
				//FlxTween.tween(playerStrums.members[0], {y: FlxG.height - playerStrums.members[0].height - 30}, 0.3, {type: PINGPONG, ease: FlxEase.quadOut});
				//FlxTween.tween(playerStrums.members[1], {y: FlxG.height - playerStrums.members[1].height - 30}, 0.3, {type: PINGPONG, ease: FlxEase.quadOut});
				//FlxTween.tween(playerStrums.members[2], {y: FlxG.height - playerStrums.members[2].height - 30}, 0.3, {type: PINGPONG, ease: FlxEase.quadOut});
				//FlxTween.tween(playerStrums.members[3], {y: FlxG.height - playerStrums.members[3].height - 30}, 0.3, {type: PINGPONG, ease: FlxEase.quadOut});

			case 'system-error':
				switch(curBeat)
				{
					case 315:
						Application.current.window.borderless = true;
	
					case 484:
						Application.current.window.borderless = false;
						goodWindow();
				}

			case 'rivals':
				if(!ClientPrefs.lowQuality)
				{
					switch(curBeat)
					{
						case 226:
							helloBoy.alpha = 1;
			
						case 255:
							helloBoy.destroy();
			
						case 388:
							FlxG.mouse.visible = true;
							fumante.alpha = 1;
							fumante1.alpha = 1;
								
							dad.alpha = 0;
							gf.alpha = 0;
							add(garcelloDead);
							robertoShit = true;
			
						case 426:
							FlxG.mouse.visible = false;
							fumante.destroy();
							fumante1.destroy();
								
							dad.alpha = 1;
							gf.alpha = 1;
							garcelloDead.destroy();
							robertoShit = false;
					}
				}

			case 'mortimer':
				switch(curBeat){

					case 45:
						FlxG.sound.play(Paths.sound('sus room'));
						//FlxTween.color(gf, 1, FlxColor.WHITE, FlxColor.WHITE);
						FlxTween.tween(gf, {alpha: 1}, 0.2, {onComplete: function(tween:FlxTween){
							gf.alpha = 1;
						}});
				}

			case 'rumble':
				if(!ClientPrefs.lowQuality)
				{
					switch(curBeat){
		
						case 282:
							iconP2.changeIcon('quagmire');
							healthBar.createFilledBar(0xffff0000, 0xFF31b0d1);
							healthBar.updateBar();
			
						case 345:
					    	iconP2.changeIcon('pet');
							healthBar.createFilledBar(0xff11550e, 0xFF31b0d1);
							healthBar.updateBar();
			
						case 408:
							iconP2.changeIcon('quagmire');
							healthBar.createFilledBar(0xffff0000, 0xFF31b0d1);
							healthBar.updateBar();
			
						case 439:
							iconP2.changeIcon('pet');
							healthBar.createFilledBar(0xff11550e, 0xFF31b0d1);
							healthBar.updateBar();
					}
				}

			case 'education':
				switch(curBeat){

					case 224:
						FlxTween.tween(newDad, {alpha: 1}, 1.0, {onComplete: function(tween:FlxTween){
							newDad.alpha = 1;
						}});

					case 396:
						school.color = FlxColor.RED;
						dad.color = FlxColor.RED;
						newDad.color = FlxColor.RED;
						boyfriend.color = FlxColor.RED;
				}

			case 'slow':
				switch(curBeat){

					case 0:
						FlxTween.tween(iconP2, {alpha: 0}, 0.2, {onComplete: function(tween:FlxTween){
							iconP2.alpha = 0;
						}});

					case 34:
						FlxTween.tween(iconP2, {alpha: 1}, 0.2, {onComplete: function(tween:FlxTween){
							iconP2.alpha = 1;
						}});
				}
		}

		// the duration of the on-screen song bars
		switch(curStep)
		{
			case 1:
				FlxTween.tween(janelaSong, {x: 33}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(janelaSongTxt, {x: 40}, 1, {ease: FlxEase.quadOut});

				FlxTween.tween(ourpleBar, {x: 33}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(ourpleTxt, {x: 40}, 1, {ease: FlxEase.quadOut});

				FlxTween.tween(pixelBar, {x: 33}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(pixelText, {x: 40}, 1, {ease: FlxEase.quadOut});

				FlxTween.tween(idiotBar, {x: 33}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(idiotTxt, {x: 40}, 1, {ease: FlxEase.quadOut});

				FlxTween.tween(black, {x: 33}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(blackTxt, {x: 40}, 1, {ease: FlxEase.quadOut});

				FlxTween.tween(songBar3D, {x: 33}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(songBar3DTxt, {x: 40}, 1, {ease: FlxEase.quadOut});

				FlxTween.tween(trollBar, {x: 33}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(trollTxt, {x: 40}, 1, {ease: FlxEase.quadOut});

			case 3:
				FlxTween.tween(plate, {y: 65}, 1, {ease: FlxEase.quadOut});

			case 28:
				FlxTween.tween(janelaSong, {x: 75}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(janelaSongTxt, {x: 80}, 1, {ease: FlxEase.quadOut});

				FlxTween.tween(idiotBar, {x: 75}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(idiotTxt, {x: 80}, 1, {ease: FlxEase.quadOut});

				FlxTween.tween(songBar3D, {x: 75}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(songBar3DTxt, {x: 80}, 1, {ease: FlxEase.quadOut});

				FlxTween.tween(trollBar, {x: 75}, 1, {ease: FlxEase.quadOut});
				FlxTween.tween(trollTxt, {x: 80}, 1, {ease: FlxEase.quadOut});

			case 35:
				FlxTween.tween(janelaSong, {x: -500}, 1.5, {ease: FlxEase.quadIn});
				FlxTween.tween(janelaSongTxt, {x: -490}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
				{
					janelaSong.alpha = 0;
					janelaSongTxt.alpha = 0;
				}});

				FlxTween.tween(ourpleBar, {x: -500}, 1.5, {ease: FlxEase.quadIn});
				FlxTween.tween(ourpleTxt, {x: -490}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
				{
					ourpleBar.alpha = 0;
					ourpleTxt.alpha = 0;
				}});

				FlxTween.tween(pixelBar, {x: -500}, 1.5, {ease: FlxEase.quadIn});
				FlxTween.tween(pixelText, {x: -490}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
				{
					pixelBar.alpha = 0;
					pixelText.alpha = 0;
				}});

				FlxTween.tween(idiotBar, {x: -400}, 1.5, {ease: FlxEase.quadIn});
				FlxTween.tween(idiotTxt, {x: -390}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
				{
					idiotBar.alpha = 0;
					idiotTxt.alpha = 0;
				}});

				FlxTween.tween(black, {x: -400}, 1.5, {ease: FlxEase.quadIn});
				FlxTween.tween(blackTxt, {x: -390}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
				{
					black.alpha = 0;
					blackTxt.alpha = 0;
				}});

				FlxTween.tween(songBar3D, {x: -500}, 1.5, {ease: FlxEase.quadIn});
				FlxTween.tween(songBar3DTxt, {x: -490}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
				{
					songBar3D.alpha = 0;
					songBar3DTxt.alpha = 0;
				}});

				FlxTween.tween(trollBar, {x: -500}, 1.5, {ease: FlxEase.quadIn});
				FlxTween.tween(trollTxt, {x: -490}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween)
				{
					trollBar.alpha = 0;
					trollTxt.alpha = 0;
				}});

			case 40:
				FlxTween.tween(plate, {y: 755}, 1.5, {ease: FlxEase.quadIn, onComplete: function(twn:FlxTween){
					plate.alpha = 0;
				}});
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	
	var seven = FlxG.keys.justPressed.SEVEN;
	
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			setOnLuas('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);
			setOnLuas('gfSection', SONG.notes[Math.floor(curStep / 16)].gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		switch(ClientPrefs.icons)
		{
			case 'Kade icon bouncy':
				if (curStage != 'florest' && curStage != 'ourpleBg' && curStage != 'Starved')
				{
					iconP1.setGraphicSize(Std.int(iconP1.width + 30));
					iconP2.setGraphicSize(Std.int(iconP2.width + 30));
	
					iconP1.updateHitbox();
					iconP2.updateHitbox();
				} else {
		
					iconP1.setGraphicSize(Std.int(iconP1.width + 1));
					iconP2.setGraphicSize(Std.int(iconP2.width + 1));
	
					iconP1.updateHitbox();
					iconP2.updateHitbox();
				}

			case 'Psych icon bouncy':
				if (curStage != 'florest' && curStage != 'Starved')
				{
					iconP1.scale.set(1.2, 1.2);
					iconP2.scale.set(1.2, 1.2);
				
					iconP1.updateHitbox();
					iconP2.updateHitbox();
		
				} else {
	
					iconP1.scale.set(1.0, 1.0);
					iconP2.scale.set(1.0, 1.0);
		
					iconP1.updateHitbox();
					iconP2.updateHitbox();
				}
			
			case 'Psych old icon bouncy':
				if (curStage != 'florest' && curStage != 'ourpleBg' && curStage != 'Starved') 
				{
					iconP1.setGraphicSize(Std.int(iconP1.width + 30));
					iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		
					iconP1.updateHitbox();
					iconP2.updateHitbox();
				} else { 
					iconP1.setGraphicSize(Std.int(iconP1.width + 1));
					iconP2.setGraphicSize(Std.int(iconP2.width + 1));
		
					iconP1.updateHitbox();
					iconP2.updateHitbox();
				}

			case 'new icon bouncy':
				iconP1.scale.set(1.2, 2);
				iconP2.scale.set(1.2, 2);
		
			    if (curStage != 'florest' && curStage != 'Starved' && curStage != 'ourpleBg') 
				{ 
					if (beatChange == 1)
					{
						beatChange = 2;
						iconP1.angle -= 10; iconP1.y = iconP1.y - -10;
						iconP2.angle -= 10; iconP2.y = iconP2.y - -10;
				
						FlxTween.tween(iconP1, {angle: 0}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(iconP2, {angle: 0}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(iconP1, {y: (iconP1.y - 10)}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(iconP2, {y: (iconP2.y - 10)}, 0.2, {ease: FlxEase.quadOut});
					
					} else if (beatChange == 2) 
					{
						beatChange = 1;
						iconP1.angle = 10; iconP1.y = iconP1.y - 10;
						iconP2.angle = 10; iconP2.y = iconP2.y - 10;
				
						FlxTween.tween(iconP1, {angle: 0}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(iconP2, {angle: 0}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(iconP1, {y: (iconP1.y - -10)}, 0.2, {ease: FlxEase.quadOut});
						FlxTween.tween(iconP2, {y: (iconP2.y - -10)}, 0.2, {ease: FlxEase.quadOut});
					}
	
				} else {
					iconP1.scale.set(1.0, 1.0);
					iconP2.scale.set(1.0, 1.0);
		     	}
		
			iconP1.updateHitbox();
			iconP2.updateHitbox();

			case 'disabled':
				iconP1.scale.set(1.0, 1.0);
				iconP2.scale.set(1.0, 1.0);
				
				iconP1.updateHitbox();
				iconP2.updateHitbox();
		}
	
		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dad.dance();
		}
		if(twoOpponents){
			if (curBeat % newDad.danceEveryNumBeats == 0 && newDad.animation.curAnim != null && !newDad.animation.curAnim.name.startsWith('sing') && !newDad.stunned)
			{
				newDad.dance();
			}
		}
		
		switch (curStage)
		{
			case 'school':
				if(!ClientPrefs.lowQuality) {
					bgGirls.dance();
				}

			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if(!ClientPrefs.lowQuality) {
					grpLimoDancers.forEach(function(dancer:BackgroundDancer)
					{
						dancer.dance();
					});
				}

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:BGSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}

			case 'Sanic Stage':
				if (curBeat % 2 == 4){
					fucker.scale.set(3.6, 1.2);
				}else{
					fucker.scale.set(1.2, 1.2);
				}
		}

		/*if(boyfriend.curCharacter == 'ourpleplay' && boyfriend.animation.curAnim.name.endsWith('idle')){
			if (curBeat % 2 == 0){
				boyfriend.flipX = true;
				iconP1.flipX = true;
			}else{
				boyfriend.flipX = false;
				iconP1.flipX = false;
			}
		}else if(boyfriend.animation.curAnim.name.endsWith('singDOWN') && boyfriend.animation.curAnim.name.endsWith('singUP') && boyfriend.animation.curAnim.name.endsWith('singRIGHT') && boyfriend.animation.curAnim.name.endsWith('singLEFT') && boyfriend.animation.curAnim.name.endsWith('miss')){
			boyfriend.flipX = false;
		}*/

		/*if (curBeat % 2 == 0){
			FlxTween.tween(timeTxt.scale,{x:1.1, y: 1.1}, 0.1);
		}else{
			FlxTween.tween(timeTxt.scale,{x:1.0, y: 1.0}, 0.1);
		}*/

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length) {
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '???';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'Week_bob_1' | 'Week_bob_2' | 'Week_bob_3':
						if(isStoryMode && storyPlaylist.length <= 1)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName)
							{
								case 'Week_bob_1':
									if(achievementName == 'Week_bob_1') unlock = true;
								case 'Week_bob_2':
									if(achievementName == 'Week_bob_2') unlock = true;
								case 'Week_bob_3':
									if(achievementName == 'Week_bob_3') unlock = true;
							}
						}

					case 'cheater':
						if(Paths.formatToSongPath(SONG.song) == 'glitcher' && !usedPractice) {
							unlock = true;
						}

					case 'idiot':
						if(Paths.formatToSongPath(SONG.song) == 'malware' && !usedPractice) {
							unlock = true;
						}

					case 'awesome':
						if(Paths.formatToSongPath(SONG.song) == 'awesome' && !usedPractice) {
							unlock = true;
						}

					case 'elections':
						if(Paths.formatToSongPath(SONG.song) == 'elections' && !usedPractice) {
							unlock = true;
						}

					case 'anomaly':
						if(Paths.formatToSongPath(SONG.song) == 'anomaly' && !usedPractice) {
							unlock = true;
						}

					case 'cannibal':
						if(Paths.formatToSongPath(SONG.song) == 'midnight-snack' && medo == 0) {
							unlock = true;
						}

					case 'party':
						if(Paths.formatToSongPath(SONG.song) == 'party' && !usedPractice) {
							unlock = true;
						}

					case 'god':
						if(Paths.formatToSongPath(SONG.song) == 'curse' && !usedPractice) {
							unlock = true;
						}

					case 'ourple':
						if(Paths.formatToSongPath(SONG.song) == 'ourple' && !usedPractice) {
							unlock = true;
						}

					case 'you are a shit':
						if(songMisses >= 100) {
							unlock = true;
						}

					case 'fnf god':
						if(songMisses < 1 && ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}