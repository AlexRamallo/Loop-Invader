package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;

using StringTools;

class SFButton extends FlxSprite {
	public var label:FlxText;
	override public function new(str:String){
		super();
		loadGraphic(AssetPaths.button__png, true, 215, 72);
		
		label = new FlxText();
		label.setFormat("assets/fonts/UbuntuMono-Regular.ttf", 38, FlxColor.LIME, CENTER);
		label.text = str;
		label.fieldWidth = width;
	}

	public function doAdd(st:FlxState){
		st.add(this);
		st.add(label);
	}

	override public function update(elapsed:Float){
		super.update(elapsed);
		updateHitbox();
		
		label.x = x;
		label.y = y;
		label.fieldWidth = width;

		animation.frameIndex = 0;
		if(FlxG.mouse.x > x && FlxG.mouse.x < x + width){
			if(FlxG.mouse.y > y && FlxG.mouse.y < y + height){
				animation.frameIndex = 1;

				if(FlxG.mouse.pressed){
					animation.frameIndex = 0;
				}

				if(FlxG.mouse.justReleased){
					onClick();
				}
			}
		}
	}

	public dynamic function onClick():Void{
		trace('pressed!');
	}
}