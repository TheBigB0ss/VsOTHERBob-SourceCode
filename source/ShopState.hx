package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import WiggleEffect.WiggleEffectType;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;

using StringTools;

class ShopState extends MusicBeatState{

	var itens:Array<String> = [
		'item1',
		'item2',
		'item3'
	];

	var bg:FlxSprite;
	var group:FlxTypedGroup<FlxSprite>;

	public static var money:Int = 10;	

	var counter:FlxText;
	var text:FlxText;

	var curSelected:Int = 0;

	override function create()
	{
		super.create();

		if (FlxG.save.data.buyItens1 == null)
			FlxG.save.data.buyItens1 = false;

		if (FlxG.save.data.buyItens2 == null)
			FlxG.save.data.buyItens2 = false;

		if (FlxG.save.data.buyItens3 == null)
			FlxG.save.data.buyItens3 = false;

		if (FlxG.save.data.money == null)
			FlxG.save.data.money = 10;

		bg = new FlxSprite().loadGraphic(Paths.image('shopTEST/bg'));
        bg.screenCenter();
        bg.antialiasing = ClientPrefs.globalAntialiasing;
        add(bg);

		counter = new FlxText();
		counter.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLACK, CENTER);
		counter.screenCenter(X);
		add(counter);

		text = new FlxText();
	    text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.BLACK, CENTER);
		text.screenCenter();
		add(text);

		group = new FlxTypedGroup<FlxSprite>();
		add(group);

		for(i in 0...itens.length){
			var spritesShit:FlxSprite = new FlxSprite();
			spritesShit.loadGraphic(Paths.image('shopTEST/' + itens[i]));
			spritesShit.ID = i;
		    group.add(spritesShit);
			curSelected = spritesShit.ID;
			//curSelected = spr.ID;
			switch(i){

				case 0:
					spritesShit.x = 100;
					spritesShit.y = 125;

				case 1:
					spritesShit.x = 100;
					spritesShit.y = 325;

				case 2:
					spritesShit.x = 100;
					spritesShit.y = 515;
			}
		}

		changeShit();
	}

	// I LOVE LEAN
	function buyItens(){
		var fuck:String = itens[curSelected];

		switch(fuck){

			case 'item1':
				if (FlxG.save.data.buyItens1 == false){
	
					if (money >= 50)
					{
						money -= 50;
						FlxG.save.data.buyItens1 = true;
						FlxG.sound.play(Paths.sound('buy'));
						FreeplaySaves.elections = 'unlocked';
					}else{
						money -= 0;
					}
				}
	
			case 'item2':
				if (FlxG.save.data.buyItens2 == false){
	
					if (money >= 170)
					{
						money -= 170;
						FlxG.save.data.buyItens2 = true;
						FlxG.sound.play(Paths.sound('buy'));
						FreeplaySaves.curse = 'unlocked';
					}else{
						money -= 0;
					}
				}
	
			case 'item3':
				if (FlxG.save.data.buyItens3 == false){
	
					if (money >= 210)
					{
						money -= 210;
						FlxG.save.data.buyItens3 = true;
						FlxG.sound.play(Paths.sound('buy'));
						FreeplaySaves.anomaly = 'unlocked';
					}else{
						money -= 0;
					}
				}
		}

		changeShit();
	}

	override function update(elapsed:Float){
		super.update(elapsed);

		counter.text = 'Money = ' + money;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{ 
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeShit(-1);
		}
		if (downP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeShit(1);
		}

		if(controls.ACCEPT)
		{
			group.forEach(function(spr:FlxSprite){
				buyItens();
			});
		}

		if (controls.BACK){
            MusicBeatState.switchState(new SuperMenuState());
        }
	}

	function changeShit(sus:Int = 0)
	{
		curSelected += sus;
		
		if (curSelected < 0)
			curSelected = group.length - 1;

		if (curSelected >= group.length)
			curSelected = 0;

		group.forEach(function(spr:FlxSprite){
			if (spr.ID == curSelected){

				var fuck:String = itens[curSelected];
				text.text = Std.string(fuck);

				if (FlxG.save.data.buyItens1 == true){
					text.text = 'buyed ' + Std.string(fuck);
				}
				if (FlxG.save.data.buyItens2 == true){
					text.text = 'buyed ' + Std.string(fuck);
				}
				if (FlxG.save.data.buyItens3 == true){
					text.text = 'buyed ' + Std.string(fuck);
				}

				FlxTween.tween(spr.scale,{x:1.1, y: 1.1}, 0.1);
				//if (FlxG.save.data.buyItens1 == true && curSelected == 0 || FlxG.save.data.buyItens2 == true && curSelected == 1 || FlxG.save.data.buyItens3 == true && curSelected == 2)
			}else{
				FlxTween.tween(spr.scale,{x:1.0, y: 1.0}, 0.1);
			}
		});
	}
}