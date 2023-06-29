package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class OptionsItem extends FlxSprite
{
	public var targetY:Float = 0;

	public function new(){
		super();
	}
	override function update(elapsed:Float){
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 650) - -87, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
	}
}