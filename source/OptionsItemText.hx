package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.math.FlxMath;

class OptionsItemText extends FlxText
{
	public var targetY:Float = 0;

	public function new(){
		super();
	}
	override function update(elapsed:Float){
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 850) - 350, CoolUtil.boundTo(elapsed * 10.2, 0, 1));
	}
}