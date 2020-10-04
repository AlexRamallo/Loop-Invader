package;

import flixel.FlxGame;
import openfl.display.Sprite;
import openfl.Assets;
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

		Assets.getSound('assets/sounds/bgm.ogg').play(0.0, 1000000);

		#if js
		untyped {
			document.oncontextmenu = document.body.oncontextmenu = function() {return false;}
		}
		#end

	}
}
