package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class FreeplayItem extends FlxSprite
{
	public var targetX:Float = 0;

	public function new(){
		super();
	}
	override function update(elapsed:Float){
		super.update(elapsed);
		x = FlxMath.lerp(x, (targetX * 1230) - -370, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
	}
}