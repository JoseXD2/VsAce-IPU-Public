package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = "ogg";

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, ?library:String, type:AssetType = TEXT)
	{
		return getPath(file, type, library);
	}

	inline static public function lua(key:String,?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String, ?swap:Bool)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();

		if (swap)
			return 'songs:assets/songs/${songLowercase}/Voices_Swapped.$SOUND_EXT';
		else
			return 'songs:assets/songs/${songLowercase}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		return 'songs:assets/songs/${songLowercase}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}

	//inline static public function video(key:String, ?library:String)
	//{
	//	return getPath('videos/$key.webm', IMAGE, library);
	//}

	
	inline static public function getSparrowAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		if (isCharacter) {
			#if cpp
			var usecahce = FlxG.save.data.cacheImages;

			if(!FileCache.instance.cachedGraphics.exists(key)) {
				usecahce = false;
			}

			if (usecahce)
				return FlxAtlasFrames.fromSparrow(imageCached(key), file('images/characters/$key.xml', library));
			else
			#end
				return FlxAtlasFrames.fromSparrow(image('characters/$key', library), file('images/characters/$key.xml', library));
		}
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	#if cpp
	inline static public function imageCached(key:String):FlxGraphic
	{
		var data = FileCache.instance.cachedGraphics.get(key);
		return data;
	}
	#end
}
