package options;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using StringTools;

class Others extends BaseOptionsMenu
{

	public function new()
	{
		title = 'others';

		var option:Option = new Option('Shaders',
			"self explanatory",
			'shaders',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('open links',
	    	"open links during songs",
	    	'links',
		    'bool',
	    	true);
	    addOption(option);

		var option:Option = new Option('Icon Bouncy:',
		    "choose the bouncy icon of your choice",
	    	'icons',
			'string',
			'new icon bouncy',
     		['new icon bouncy', 'Psych old icon bouncy', 'Psych icon bouncy', 'Kade icon bouncy', 'disabled']);
	    addOption(option);

		var option:Option = new Option('mouse:',
	    	"choose the mouse of your choice",
	    	'mouse',
		    'string',
	    	'finger',
	    	['finger', 'pointer', 'mario']);
	    addOption(option);

		var option:Option = new Option('easter eggs',
	    	"activate easter eggs ?",
	    	'eastereggs',
	    	'bool',
	    	true);
	    addOption(option);

		super();
	}
}