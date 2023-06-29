package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import openfl.utils.Assets as OpenFlAssets;
#if MODS_ALLOWED
import sys.FileSystem;
#end
import flixel.addons.display.FlxBackdrop;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxCamera;
import flixel.addons.effects.FlxSkewedSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import openfl.Lib;
import flixel.util.FlxTimer;
import lime.app.Application;
import lime.ui.Window;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = '';

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	var fartPants:FlxTypedGroup<FreeplayItem>;
	var gaygrp:FlxTypedGroup<Alphabet>;
	
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public var camZooming:Bool = false;
	public var defaultCamZoom:Float = 1.05;

	var bg:FlxSprite;
	var bg1:FlxSprite;
	var bg2:FlxSprite;
	var ass:FlxBackdrop;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var idiot:Int = 0;
	var songSecret:Int = 0;

	var secretBrobgonal:FlxSprite;
	var finger:FlxSprite;
	var remakeThing:FlxSprite;

	override function create()
	{
		FlxG.mouse.visible = true;

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.pathToCheck = 'weeks';
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("freeplay menu", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}

		}
		WeekData.loadTheFirstEnabledMod();

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

	    //if(FlxG.save.data.shopSong1){
			//addSong('shopSong1');
		//}

		FreeplaySaves.loadShit();

		if(FlxG.save.data.golden){
			addSong('Golden Core', 0 , '', 0xFFFF823A);
		}
		if(FreeplaySaves.glitcher == 'unlocked'){
            addSong('glitcher', 0, 'bomb', 0xFFFF8800);
        }
		if(FreeplaySaves.awesome == 'unlocked'){
            addSong('awesome', 0, 'RED', 0xFFFF0000);
        }
		if(FreeplaySaves.anomaly == 'unlocked'){
            addSong('anomaly', 0, 'Gilbert' , 0xFFFF5E00);
        }
		if(FreeplaySaves.malware == 'unlocked'){
            addSong('malware', 0, 'idiot', 0xFFFFFFFF);
        }
		if(FreeplaySaves.curse == 'unlocked'){
            addSong('curse', 0, 'GOD', 0xFFFF0000);
        }
		if(FreeplaySaves.elections == 'unlocked'){
            addSong('elections', 0, '...', 0xFFFFFFFF);
        }
		if(FreeplaySaves.pixelated == 'unlocked'){
            addSong('pixelated', 0, '', 0xFF5CD1FF);
        }
		if(FreeplaySaves.systemError == 'unlocked'){
			addSong('system-error', 0, '', 0xFF1A2FA8);
		}

		/*		//KIND OF BROKEN NOW AND ALSO PRETTY USELESS//

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			if(initSonglist[i] != null && initSonglist[i].length > 0) {
				var songArray:Array<String> = initSonglist[i].split(":");
				addSong(songArray[0], 0, songArray[1], Std.parseInt(songArray[2]));
			}
		}*/

		var ui_tex = Paths.getSparrowAtlas('ArrowsShit lol');

		bg = new FlxSprite().loadGraphic(Paths.image('bgsStuff/amongusBG'));
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

		bg = new FlxSprite().loadGraphic(Paths.image('bgsStuff/amongusBG'));
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

		remakeThing = new FlxSprite();
		remakeThing.loadGraphic(Paths.image('Remake Thing'));
		remakeThing.screenCenter(X);
		remakeThing.visible = false;

		ass = new FlxBackdrop(Paths.image('bgShit'),0,0,true,false,0,0);
		ass.antialiasing = true;
		ass.screenCenter(Y);
		ass.velocity.x = -30;
		add(ass);

        bg1 = new FlxSprite().loadGraphic(Paths.image('bgsStuff/bords'));
        bg1.updateHitbox();
        bg1.antialiasing = ClientPrefs.globalAntialiasing;

		bg2 = new FlxSprite(0,0).loadGraphic(Paths.image('bgsStuff/upbords'));
		bg2.setGraphicSize(1286,800);
		bg2.screenCenter();
		bg2.scrollFactor.set();

		leftArrow = new FlxSprite(91, 505);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;

		rightArrow = new FlxSprite(965, 505);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		fartPants = new FlxTypedGroup<FreeplayItem>();
		add(fartPants);

		add(remakeThing);

		gaygrp = new FlxTypedGroup<Alphabet>();
		add(gaygrp);

		add(rightArrow);
		add(leftArrow);

		secretBrobgonal = new FlxSprite(87, 14).loadGraphic(Paths.image('Secret BrogBonal'));
		secretBrobgonal.updateHitbox();
		secretBrobgonal.antialiasing = ClientPrefs.globalAntialiasing;
		if(FlxG.save.data.brobGonal){
			add(secretBrobgonal);
		}

		Lib.application.window.title = "Friday Night Funkin': VS OTHER BOB V2";

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItemCenter = true;
			songText.targetY = i;
			//grpSongs.add(songText);

			var songsShit:FreeplayItem = new FreeplayItem();
			songsShit.loadGraphic(Paths.image('FpStuff/songs/' + songs[i].songName));
			songsShit.targetX = i;
			songsShit.screenCenter();
			fartPants.add(songsShit);

			var gayAlphabet:Alphabet = new Alphabet(0, 0, songs[i].songName, true, false);
			gayAlphabet.isShitMenuItem = true;
			gayAlphabet.targetX = i;
			gayAlphabet.screenCenter();
			gaygrp.add(gayAlphabet);

			if (songText.width > 980)
			{
				var textScale:Float = 980 / songText.width;
				songText.scale.x = textScale;
				for (letter in songText.lettersArray)
				{
					letter.x *= textScale;
					letter.offset.x *= textScale;
				}
			}
	
			Paths.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
	
			iconArray.push(icon);
			//add(icon);
		}

		add(bg1);
		add(bg2);

		FlxTween.tween(FlxG.camera, {zoom:1.03}, 0.5, {ease: FlxEase.quadOut, type: BACKWARD});

		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("PhantomMuff.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.5;
		add(scoreBG);
		
		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);
		add(scoreText);

		if(curSelected >= songs.length) curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if(lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));
		
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		//add(textBG);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		//add(text);
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	/*public function addWeek(songs:Array<String>, weekNum:Int, weekColor:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);
			this.songs[this.songs.length-1].color = weekColor;

			if (songCharacters.length != 1)
				num++;
		}
	}*/

	var instPlaying:Int = 1;
	private static var vocals:FlxSound = null;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if(FlxG.save.data.brobGonal){
			
			if (FlxG.mouse.overlaps(secretBrobgonal)) {
				FlxTween.tween(secretBrobgonal.scale,{x:0.7, y: 0.7}, 0.1);
	
				if (FlxG.mouse.justPressed) 
				{
					MusicBeatState.switchState(new ClickerGame());
					FlxG.mouse.visible = true;
				}
			}
			else{
				FlxTween.tween(secretBrobgonal.scale,{x:0.4, y: 0.4}, 0.1);
			}
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		Application.current.window.borderless = false;

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		var upP = controls.UI_LEFT_P;
		var downP = controls.UI_RIGHT_P;
		var accepted = controls.ACCEPT;
		var ctrl = FlxG.keys.justPressed.CONTROL;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if(songs.length > 1)
		{
			if(FlxG.mouse.wheel != 0)
			{
				changeSelection(0 - FlxG.mouse.wheel);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (upP)
			{
				changeSelection(-shiftMult);
				holdTime = 1;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			if (downP)
			{
				changeSelection(shiftMult);
				holdTime = 1;
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_RIGHT)
				rightArrow.animation.play('press');
			else
				rightArrow.animation.play('idle');

			if (controls.UI_LEFT)
				leftArrow.animation.play('press');
			else
				leftArrow.animation.play('idle');
		
			if (controls.UI_DOWN_P)
				changeDiff(-1);
			else if (controls.UI_UP_P)
				changeDiff(1);
			else if (upP || downP) changeDiff();

			if (songs[curSelected].songName == 'Golden Core')
			{    
				remakeThing.visible = true;
			}
			else{
				remakeThing.visible = false;
			}

			if (songs[curSelected].songName == 'slow')
			{    
				var fakeSlow:FreeplayItem = new FreeplayItem();
				fakeSlow.loadGraphic(Paths.image('FpStuff/songs/slowFAKE'));
				fakeSlow.screenCenter();
				fartPants.add(fakeSlow);
				FlxG.sound.music.volume = 0;

				if(FreeplaySaves.trueSlow == 'unlocked'){
					FlxG.sound.music.volume = 0.8;
					fakeSlow.destroy();
				}		
			}else{
				FlxG.sound.music.volume = 0.8;
			}

			if (songs[curSelected].songName == 'midnight snack')
			{    
				secretBrobgonal.visible = false;
				FlxG.sound.music.volume = 0;
			}
			else{
				secretBrobgonal.visible = true;
				FlxG.sound.music.volume = 0.8;
			}
		}

		/*if (FlxG.mouse.overlaps(rightArrow))
		{
			rightArrow.animation.play('press');
		
			if (FlxG.mouse.justPressed) 
			{
				trace('click LOL');
				FlxG.mouse.visible = true;
				changeSelection(shiftMult);
			}
	
		}else {
			rightArrow.animation.play('idle');
		}
		if (FlxG.mouse.overlaps(leftArrow)) {
			leftArrow.animation.play('press');
	
			if (FlxG.mouse.justPressed) 
			{
				trace('click LOL');
				FlxG.mouse.visible = true;
				changeSelection(-shiftMult);
			}
	
		}else{
			leftArrow.animation.play('idle');
		}*/

		if (controls.BACK)
		{
			persistentUpdate = false;
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxTween.tween(FlxG.camera, {zoom: 5}, 0.8, {ease: FlxEase.expoIn});
			FlxTween.tween(bg, {angle: 45}, 0.8, {ease: FlxEase.expoIn});
			FlxTween.tween(bg, {alpha: 0}, 0.8, {ease: FlxEase.expoIn});
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new SuperMenuState());
		}

		if(ctrl)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if (accepted)
		{
			FlxG.sound.play(Paths.sound('secretSound'), 0.8);
			FlxTween.tween(FlxG.camera, {zoom:5}, 0.8, {ease: FlxEase.elasticInOut});

			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
			if(colorTween != null) {
				colorTween.cancel();
			}
			
			if (FlxG.keys.pressed.SHIFT){
				LoadingState.loadAndSwitchState(new ChartingState());
			}else{
				LoadingState.loadAndSwitchState(new PlayState());
			}

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		
		// malware Shit
		if (FlxG.keys.justPressed.I)
			if(idiot == 0) idiot = 1;

		if (FlxG.keys.justPressed.M)
			if(idiot == 1) idiot = 2;

		if (FlxG.keys.justPressed.S)
			if(idiot == 2) idiot = 3;

		if (FlxG.keys.justPressed.T)
			if(idiot == 3) idiot = 4;

		if (FlxG.keys.justPressed.U)
			if(idiot == 4) idiot = 5;

		if (FlxG.keys.justPressed.P)
			if(idiot == 5)idiot = 6;

		if (FlxG.keys.justPressed.I)
			if(idiot == 6) idiot = 7;
	
		if (FlxG.keys.justPressed.D)
			if(idiot == 7) idiot = 8;

		if(idiot == 8){
			FlxG.sound.music.volume = 0;
			destroyFreeplayVocals();
			FlxG.sound.play(Paths.sound('YIPPE'));

			new FlxTimer().start(0.5, function(tmr:FlxTimer){
				MusicBeatState.switchState(new IDIOT());
			});
		}

		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length-1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = 'v ' + CoolUtil.difficultyString() + ' ^';
		positionHighscore();
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		curSelected += change;
		
		if (curSelected < 0)
			curSelected = songs.length - 1;

		if (curSelected >= songs.length)
			curSelected = 0;

		if (curDifficulty < 0)
			curDifficulty = 2;

		if (curDifficulty > 2)
			curDifficulty = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		/*#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end*/

		var bullShit:Int = 0;
		var fuck:Int = 0;
		var fucked:Int = 0;

		var targetX:Float = 0;
		var targetSkew:Float = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		for(item in gaygrp.members){
			item.targetX = fucked - curSelected;
			fucked++;

			item.alpha = 0.40;

			if(item.targetX == 0){
				item.alpha = 1;
			}
		}

		for(item in fartPants.members){
			item.targetX = fuck - curSelected;
			fuck++;

			item.alpha = 0.20;

			if(item.targetX == 0){
				item.alpha = 1;
			}
		}
		
		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if(diffStr != null) diffStr = diffStr.trim(); //Fuck you HTML5

		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}
		
		if(CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		//trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if(newPos > -1)
		{
			curDifficulty = newPos;
		}

		songSecret++;
		switch(songSecret)
		{
			case 67:
				Application.current.window.alert('STOP', 'VS OTHER BOB.error');
				FlxG.camera.shake();

			case 97:
				Application.current.window.alert('I SAID STOP', 'ERROR Says');
				FlxG.camera.shake();

			case 142:
				Application.current.window.alert('you don\'t understand if you continue you will destroy this mod', 'ERROR Says');
				FlxG.camera.shake();
			
			case 160:
				Application.current.window.alert('please, if you continue I will be forced to stop you, ' + CoolUtil.getUsername(), 'ERROR Says');
				FlxG.camera.shake();

			case 170:
				Application.current.window.alert('this will be your last warning', 'ERROR Says');
				FlxG.camera.shake();

			case 190:
				FlxG.camera.shake(0.3, 0.5);
				Application.current.window.alert('satisfied?', 'I CAN SEE YOU ' + CoolUtil.getUsername());
				FlxG.sound.music.fadeIn(0.01, 0.7, 0);
	
				new FlxTimer().start(0.2, function(tmr:FlxTimer) {
					FlxG.sound.music.fadeIn(0.01, 0.7, 0);
		
					LoadingState.loadAndSwitchState(new PlayState());
					PlayState.isStoryMode = false;
					PlayState.SONG = Song.loadFromJson('system-error', 'system-error');
					LoadingState.loadAndSwitchState(new PlayState());
				});
		}
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}