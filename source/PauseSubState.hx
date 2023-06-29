package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxTimer;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;
	
	var pooper:FlxTypedGroup<FlxSprite>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Toggle Botplay', 'Exit to menu', 'fart', 'bambi'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var bg1:FlxSprite;
	var bambi:FlxSprite;
	var ass:FlxBackdrop;

	var levelInfo:FlxText;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	//var botplayText:FlxText;

	public static var songName:String = '';

	var selected:FlxSprite;

	public function new(x:Float, y:Float)
	{
		super();
		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove('Change Difficulty'); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(6, 'Leave Charting Mode');
			
			/*var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(7, 'Skip Time');
			}*/
			//menuItemsOG.insert(3 + num, 'End Song');
			//menuItemsOG.insert(4 + num, 'Toggle Practice Mode');
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound();
		if(songName != null) {
			pauseMusic.loadEmbedded(Paths.music(songName), true, true);
		} else if (songName != 'None') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

        ass = new FlxBackdrop(Paths.image('ass BG'), 0.2, 0, true, true);
		ass.velocity.set(-30, -30);
		ass.updateHitbox();
		ass.alpha = 0.5;
		ass.screenCenter(X);
		add(ass);

		var image:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pauseStuff/images/PauseImages-' + FlxG.random.int(1, 7)));
		image.scale.set(1.3, 1.3);
		image.screenCenter();
        add(image);

		bg1 = new FlxSprite().loadGraphic(Paths.image('bullshit2'));

		levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.screenCenter();
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();

		var levelDifficulty:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		//add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(27, 15 + 64, 0, "", 32);
		blueballedTxt.text = "deaths: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		levelInfo.screenCenter();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		//add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		pooper = new FlxTypedGroup<FlxSprite>();
		add(pooper);

		for(i in 0...menuItems.length){
			var spritesShit:FlxSprite = new FlxSprite();
			spritesShit.loadGraphic(Paths.image('pauseStuff/base/' + menuItems[i]));
			spritesShit.ID = i;
			pooper.add(spritesShit);
			switch(i){
				case 0:
					spritesShit.x = 80;
					spritesShit.y = 64;
				case 1:
					spritesShit.x = 80;
					spritesShit.y = 143;
				case 2:
					spritesShit.x = 80;
					spritesShit.y = 213;
				case 3:
					spritesShit.x = 80;
					spritesShit.y = 286;
				case 4:
					spritesShit.x = 80;
					spritesShit.y = 364;
				case 5:
					spritesShit.x = 80;
					spritesShit.y = 420;

				case 6:
					spritesShit.x = 750;
					spritesShit.y = 364;
			}
			
			switch(PlayState.curStage){

				case 'BOB SCENE WEEK 3D':
					spritesShit.loadGraphic(Paths.image('pauseStuff/3D/' + menuItems[i]));

				case 'ourpleBg':
					spritesShit.loadGraphic(Paths.image('pauseStuff/ourple/' + menuItems[i]));

				case 'MOGAS_BG':
					spritesShit.loadGraphic(Paths.image('pauseStuff/SUS/' + menuItems[i]));
			}
	
			if(PlayState.isPixelStage){
				spritesShit.loadGraphic(Paths.image('pauseStuff/pixel/' + menuItems[i]));
			}

			add(bg1);
			add(levelInfo);
		}

		selected = new FlxSprite();
		selected.loadGraphic(Paths.image('pauseStuff/base/selected'));
		add(selected);

		switch(PlayState.curStage){

			case 'BOB SCENE WEEK 3D':
				selected.loadGraphic(Paths.image('pauseStuff/3D/selected'));

			case 'MOGAS_BG':
				selected.loadGraphic(Paths.image('pauseStuff/SUS/selected'));
		}

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT)
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * (controls.UI_LEFT ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted)
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song.toLowerCase();
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.chartingMode = false;
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					close();

				case 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();

				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;

				case "Restart Song":
					restartSong();

				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;

				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}

				case "End Song":
					close();
					PlayState.instance.finishSong(true);

				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;

				case "fart":
					FlxG.sound.play(Paths.sound('fart'), 65.7);

				case "bambi":
					var bambi:FlxSprite = new FlxSprite();
					bambi.loadGraphic(Paths.image('pauseStuff/funny/bambi love you'));
					bambi.screenCenter();
					add(bambi);

					FlxG.sound.play(Paths.sound('boom'),23.7);

					if(PlayState.curStage == 'ourpleBg'){
						bambi.loadGraphic(Paths.image('pauseStuff/funny/Ourple Guy'));
					}
					if(PlayState.curStage == 'MOGAS_BG'){
						bambi.loadGraphic(Paths.image('pauseStuff/funny/sus'));
					}
					if(PlayState.isPixelStage){
						bambi.loadGraphic(Paths.image('pauseStuff/funny/pixel'));
					}

					FlxTween.tween(bambi, {alpha: 0}, 1.0, {onComplete: function(tween:FlxTween){
						bambi.destroy();
					}});

				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenuState());
					} else {
						MusicBeatState.switchState(new FreeplayState());
					}
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
			}
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		pooper.forEach(function(spr:FlxSprite){

			if (spr.ID == curSelected){
				selected.x = spr.x;
				selected.y = spr.y;

				FlxTween.tween(selected.scale,{x:1.2, y: 1.2}, 0.1);
				FlxTween.tween(spr.scale,{x:1.1, y: 1.1}, 0.1);
			}else{
				FlxTween.tween(spr.scale,{x:1.0, y: 1.0}, 0.1);
			}
		});

		for (item in grpMenuShit.members)
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
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			//item.isMenuItem = true;
			item.isMenuItemCenter = true;
			item.targetY = i;
			//grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
