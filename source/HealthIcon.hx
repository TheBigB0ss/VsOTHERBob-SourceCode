package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	public function iconChange(icon:String){
		changeIcon(icon);
	}

	private var iconOffsets:Array<Float> = [0, 0];

	public function changeIcon(char:String) 
	{
		if(this.char != char) 
		{
			switch (char) {
				case 'ourple bob':
					frames = Paths.getSparrowAtlas('icons/animated/icon-ourplelol', 'preload');
					animation.addByPrefix("idle", "icon idle", 17, false);
					animation.addByPrefix("win", "icon win", 18, false);
					animation.addByPrefix("lose", "icon lose", 15, false);
					animation.play("idle");
					this.char = char;
				default:
					var name:String = 'icons/' + char;
			
					if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; 
					if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face';
		
					var file:Dynamic = Paths.image(name);
		
					loadGraphic(file, true, 150, 150);
		
					animation.add("idle", [0], 0, false, isPlayer);
					animation.add("lose", [1], 0, false, isPlayer);
					animation.add("win", [2], 0, false, isPlayer);
					animation.play("idle");
		
					antialiasing = ClientPrefs.globalAntialiasing;
					if(char.endsWith('-pixel')) antialiasing = false;
		
					this.char = char;
			}
		}
	}

	override function updateHitbox() {
		
		super.updateHitbox();

		switch (char) {
			case 'ourple bob':
				scale.set(0.8, 0.8);
		}
	}

	public function getCharacter():String {
		return char;
	}
}