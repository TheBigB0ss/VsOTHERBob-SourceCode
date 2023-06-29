package;

import flixel.FlxSprite;
using StringTools;

class BobCustomBg extends FlxSprite
{
	public function new(?x:Float, ?y:Float, name:String, ?animationName:String, ?velocity:Int){ 
		super(x, y);

		loadGraphic(Paths.image(name));
		
		if(animationName != null){
			frames = Paths.getSparrowAtlas(name);
			animation.addByPrefix(animationName, animationName, velocity);	
			animation.play(animationName);
		}
	}
	override function update(elapsed:Float){ 
		super.update(elapsed);
	}
}