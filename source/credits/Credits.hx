package credits;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseEventManager;

class Credits extends FlxTypedGroup<FlxBasic>
{
    var icon:FlxSprite;

    var back:FlxSprite;
    var arrow:FlxSprite;
    var arrow1:FlxSprite;
    var arrow2:FlxSprite;

    var text:FlxText;

    public function new(x:Float, y:Float, iconName:String, role:String)
    {
        super();

        arrow = new FlxSprite().loadGraphic(Paths.image('creditsStuff/arrows/arrowShit'));
		add(arrow);
		arrow.screenCenter(X);

        arrow1 = new FlxSprite(900, 525).loadGraphic(Paths.image('creditsStuff/arrows/arrowShit1'));
		add(arrow1);
        arrow1.scale.set(0.5, 0.5);

        arrow2 = new FlxSprite(187, 500).loadGraphic(Paths.image('creditsStuff/arrows/arrowShit2'));
		add(arrow2);
        arrow2.scale.set(0.5, 0.5);

        back = new FlxSprite(187, 780).loadGraphic(Paths.image('creditsStuff/arrows/back button'));
        add(back);

        icon = new FlxSprite(x, y).loadGraphic(Paths.image('creditsStuff/icons/' + iconName));
        icon.updateHitbox();
        icon.antialiasing = ClientPrefs.globalAntialiasing;
        add(icon);

        text = new FlxText(50, FlxG.height - 140, 1180, role, - 140);
		text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLACK, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.WHITE);
		text.scrollFactor.set();
        text.visible = false;
    	add(text);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.mouse.justPressed)
        {
            if (FlxG.mouse.overlaps(icon))
            {
                text.visible = true;
            }else{
                text.visible = false;
            }
        }

        if (FlxG.mouse.overlaps(arrow)){
            if (FlxG.mouse.pressed){
                MusicBeatState.switchState(new CreditsStateContributors());
            }
        } 

        if (FlxG.mouse.overlaps(arrow1)){
            if (FlxG.mouse.pressed){
                MusicBeatState.switchState(new CreditsStateThanks());
            }
        } 

        if (FlxG.mouse.overlaps(arrow2)){
            if (FlxG.mouse.pressed){
                MusicBeatState.switchState(new CreditsState());
            }
        } 

        if (FlxG.mouse.overlaps(back)){
            if (FlxG.mouse.pressed){
                MusicBeatState.switchState(new SuperMenuState());
            }
        } 
        if (FlxG.keys.justPressed.ESCAPE) {
            MusicBeatState.switchState(new SuperMenuState());
        }
    }
}