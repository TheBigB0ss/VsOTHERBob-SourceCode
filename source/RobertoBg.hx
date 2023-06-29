package;

import flixel.FlxSprite;

using StringTools;

class RobertoBg extends FlxSprite
{
	public function new(x:Float, y:Float){ 
		super(x, y);
		loadGraphic(Paths.image('Roberto is Dead NOOO'));
	}
	override function update(elapsed:Float){
		super.update(elapsed);
	}
}

// super cool class BG B)