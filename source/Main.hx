package;

import flixel.FlxGame;
import openfl.display.Sprite;
import flixel.FlxG;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, MenuState));
		FlxG.sound.muteKeys = [S];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.volumeUpKeys = [];

		FlxG.sound.playMusic(AssetPaths.bgm__ogg, 0.7, true);
	}
}
