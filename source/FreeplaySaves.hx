package;

import flixel.FlxG;
import flixel.math.FlxMath;
import lime.utils.Assets;
import flixel.util.FlxSave;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplaySaves
{
    public static var elections:String = 'locked';
    public static var malware:String = 'locked';
    public static var glitcher:String = 'locked';
    public static var awesome:String = 'locked';
    public static var anomaly:String = 'locked';
    public static var curse:String = 'locked';
    public static var pixelated:String = 'locked';
    public static var systemError:String = 'locked';
    public static var trueSlow:String = 'locked';

    public static function fuckinSet() {
        if (FlxG.save.data.elections == null) FlxG.save.data.elections = 'locked';

        FlxG.save.flush();

        if (FlxG.save.data.malware == null) FlxG.save.data.malware = 'locked';

        FlxG.save.flush();

        if (FlxG.save.data.glitcher == null) FlxG.save.data.glitcher = 'locked';

        FlxG.save.flush();

        if (FlxG.save.data.awesome == null) FlxG.save.data.awesome = 'locked';
        
        FlxG.save.flush();

        if (FlxG.save.data.anomaly == null) FlxG.save.data.anomaly = 'locked';

        FlxG.save.flush();

        if (FlxG.save.data.curse == null) FlxG.save.data.curse = 'locked';

        FlxG.save.flush();

        if (FlxG.save.data.pixelated == null) FlxG.save.data.pixelated = 'locked';

        FlxG.save.flush();

        if (FlxG.save.data.systemError == null) FlxG.save.data.systemError = 'locked';

        FlxG.save.flush();

        if (FlxG.save.data.trueSlow == null) FlxG.save.data.trueSlow = 'locked';

        FlxG.save.flush();
    }

    public static function saveShit() {
        FlxG.save.data.elections = elections;

        FlxG.save.flush();

        FlxG.save.data.malware = malware;

        FlxG.save.flush();

        FlxG.save.data.glitcher = glitcher;

        FlxG.save.flush();

        FlxG.save.data.awesome = awesome;

        FlxG.save.flush();

        FlxG.save.data.anomaly = anomaly;

        FlxG.save.flush();

        FlxG.save.data.curse = curse;

        FlxG.save.flush();

        FlxG.save.data.pixelated = pixelated;

        FlxG.save.flush();

        FlxG.save.data.systemError = systemError;

        FlxG.save.flush();

        FlxG.save.data.trueSlow = trueSlow;

        FlxG.save.flush();
    }

    public static function loadShit() {
        elections = FlxG.save.data.elections;

        FlxG.save.flush();

        malware = FlxG.save.data.malware;

        FlxG.save.flush();

        glitcher = FlxG.save.data.glitcher;

        FlxG.save.flush();

        awesome = FlxG.save.data.awesome;

        FlxG.save.flush();

        anomaly = FlxG.save.data.anomaly;

        FlxG.save.flush();

        curse = FlxG.save.data.curse;

        FlxG.save.flush();

        pixelated = FlxG.save.data.pixelated;

        FlxG.save.flush();

        systemError = FlxG.save.data.systemError;

        FlxG.save.flush();

        trueSlow = FlxG.save.data.trueSlow;

        FlxG.save.flush();
    }
}