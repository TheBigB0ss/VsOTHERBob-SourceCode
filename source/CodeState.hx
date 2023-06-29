package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class CodeState extends MusicBeatState
{
    var bg:FlxSprite;
    var finger:FlxSprite;

    var secretText:FlxUIInputText;
    var text:FlxText;

    var oneTime1:Bool = false;
    var oneTime2:Bool = false;
    var oneTime3:Bool = false;
    var oneTime4:Bool = false;

    var escape = FlxG.keys.justPressed.ESCAPE;
    var enter = FlxG.keys.justPressed.ENTER;
     
	override function create()
    {
        super.create();

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

        bg = new FlxSprite().loadGraphic(Paths.image('bgsStuff/White BG lol'));
        bg.screenCenter();
        add(bg);

        text = new FlxText();
        text.text = "- put the codes here -\n for more information check \n the txt called \"data/codes.txt.\" \n";
        text.setFormat(Paths.font("pixelShit.ttf"), 32, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
        text.screenCenter(X);
        add(text);

        secretText = new FlxUIInputText();
        //secretText.resize(400, 45);
        secretText.screenCenter();
        //secretText.setGraphicSize(310, 47);
        add(secretText);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ENTER){

            switch(secretText.text){
                case 'Faraone productions':
                    FlxG.sound.play(Paths.sound('confirmMenu'), 20);
                    
                	new FlxTimer().start(0.2, function(tmr:FlxTimer){      
                        PlayState.isStoryMode = false;
                        PlayState.SONG = Song.loadFromJson('anomaly', 'anomaly');
                        LoadingState.loadAndSwitchState(new PlayState());
			    	});
                    
                case 'don\'t run from me':
                    FlxG.sound.play(Paths.sound('confirmMenu'), 20);

                    new FlxTimer().start(0.2, function(tmr:FlxTimer){
                        MusicBeatState.switchState(new/*spoopy state*/ GodState()); 
                        FlxG.sound.music.volume = 0;
			    	});
    
                case 'calango':  
                    FlxG.sound.play(Paths.sound('confirmMenu'), 20);

                    new FlxTimer().start(0.2, function(tmr:FlxTimer){
                        PlayState.isStoryMode = false;
                        PlayState.SONG = Song.loadFromJson('elections', 'elections');
                        LoadingState.loadAndSwitchState(new PlayState());
			    	});
                    
                case 'i cheated':
                    FlxG.sound.play(Paths.sound('confirmMenu'), 20);
  
                    new FlxTimer().start(0.2, function(tmr:FlxTimer){
                        LoadingState.loadAndSwitchState(new PlayState());                          
                        PlayState.isStoryMode = false;
                        PlayState.SONG = Song.loadFromJson('glitcher', 'glitcher');
                        LoadingState.loadAndSwitchState(new PlayState());
                    });
                    
                case 'chucklenuts':

                    if (ClientPrefs.eastereggs)
                    {
                        if(!oneTime1){
                            oneTime1 = true;
                            // ippon se tu tive vendo isso 
                            // saiba que eu te odeio MUITO
                            FlxG.sound.play(Paths.sound('thing fast'));
                        }
                    }
    
                case 'sus':

                    if (ClientPrefs.eastereggs)
                    {
                        if(!oneTime2){
                            oneTime2 = true;
    
                            var sus:FlxSprite = new FlxSprite().loadGraphic(Paths.image('SUS'));
                            sus.screenCenter();
                            add(sus);
                            FlxG.sound.play(Paths.sound('boom'));
                                    
                            new FlxTimer().start(1.0, function(tmr:FlxTimer) {
                                FlxTween.tween(sus, {alpha:0}, 0.6, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
                                    sus.destroy();
                                }});
                            });
                        }
                    }
                
                case 'Hi There':
                    
                    if (ClientPrefs.eastereggs)
                    {
                        if(!oneTime3){
                            oneTime3 = true;
    
                            var happyFace:FlxSprite = new FlxSprite();
                            happyFace.frames = Paths.getSparrowAtlas('happy/Hi There');
                            happyFace.animation.addByPrefix('idle', "idle", 25);
                            happyFace.animation.play('idle');
                            happyFace.scale.set(2.6, 2.6);
                            happyFace.screenCenter();
                            add(happyFace);
                                    
                            new FlxTimer().start(1.0, function(tmr:FlxTimer) {
                                FlxTween.tween(happyFace, {alpha:0}, 0.6, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
                                    happyFace.destroy(); //:( 
                                }});
                            });
                        }
                    }

                case 'Freebird':
                    CoolUtil.browserLoad('https://pbs.twimg.com/media/FvNhpLbXoAA-noT?format=jpg&name=360x360');

                case 'SUSSY DOG':
                    if (ClientPrefs.eastereggs)
                    {
                        if(!oneTime4){
                            oneTime4 = true;

                            var susDog:FlxSprite = new FlxSprite().loadGraphic(Paths.image('DOG'));
                            susDog.screenCenter();
                            add(susDog);

                            new FlxTimer().start(1.0, function(tmr:FlxTimer) {
                                FlxTween.tween(susDog, {alpha:0}, 0.6, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
                                    susDog.destroy();
                                }});
                            });
                        }
                    }

                default:
                    // STUPID
                    FlxG.sound.play(Paths.sound('cancelMenu'), 20);

                    var error:FlxText = new FlxText(50, FlxG.height - 140, 1180);
                    error.setFormat(Paths.font("pixelShit.ttf"), 32, FlxColor.BLACK, CENTER);
                    error.text = '\n unrecognized code\n'; 
                    error.visible = true;
                    add(error);
    
                    new FlxTimer().start(4.0, function(tmr:FlxTimer) {
                        FlxTween.tween(error, {alpha:0}, 0.6, {ease: FlxEase.expoInOut, onComplete: function(twn:FlxTween) {
                            error.visible = false;
                        }});
                    });
                    
            }
        }

        if (FlxG.keys.justPressed.ESCAPE) {
            MusicBeatState.switchState(new ExtraMenuState());
        }
    }
}