package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;

using StringTools;

class MenuState extends FlxState{

	var title:FlxSprite;

	var tutorials:Array<FlxSprite>;
	var btn_tut_next:SFButton;
	var btn_tut_prev:SFButton;

	override public function create(){
		super.create();

		title = new FlxSprite();
		title.loadGraphic(AssetPaths.menu__png, false);
		title.setGraphicSize(FlxG.width, FlxG.height);
		add(title);

		addButton("Level 1", 44, 178, 1);
		addButton("Level 2", 44, 258, 2);
		addButton("Level 3", 44, 338, 3);
		addButton("Level 4", 44, 418, 4);
		addButton("Level 5", 44, 498, 5);
		
		addButton("Level 6", 344, 178, 6);
		addButton("Level 7", 344, 258, 7);
		addButton("Level 8", 344, 338, 8);
		addButton("Level 9", 344, 418, 9);
		addButton("Level 10", 344, 498, 10);

		tutorials = [];

		{
			var tut = new FlxSprite();
			tut.loadGraphic(AssetPaths.tut1__png, false);
			tut.x = 0;
			tut.y = 0;
			add(tut);
			tutorials.push(tut);
		}
		{
			var tut = new FlxSprite();
			tut.loadGraphic(AssetPaths.tut2__png, false);
			tut.x = 0;
			tut.y = 0;
			add(tut);
			tutorials.push(tut);
		}
		{
			var tut = new FlxSprite();
			tut.loadGraphic(AssetPaths.tut3__png, false);
			tut.x = 0;
			tut.y = 0;
			add(tut);
			tutorials.push(tut);
		}
		{
			var tut = new FlxSprite();
			tut.loadGraphic(AssetPaths.tut4__png, false);
			tut.x = 0;
			tut.y = 0;
			add(tut);
			tutorials.push(tut);
		}
		{
			var tut = new FlxSprite();
			tut.loadGraphic(AssetPaths.tut5__png, false);
			tut.x = 0;
			tut.y = 0;
			add(tut);
			tutorials.push(tut);
		}

		for(tut in tutorials){
			tut.visible = false;
		}

		{
			var btn = new SFButton('>');
			btn.onClick = function(){ onTutNext(); }
			btn.scale.x = (40 / btn.width);
			btn.scale.y = (40 / btn.height);
			btn.updateHitbox();
			btn.x = FlxG.width - 50;
			btn.y = FlxG.height - 50;
			btn.doAdd(this);
			btn_tut_next = btn;
		}
		{
			var btn = new SFButton('<');
			btn.onClick = function(){ onTutPrev(); }
			btn.scale.x = (40 / btn.width);
			btn.scale.y = (40 / btn.height);
			btn.updateHitbox();
			btn.x = btn_tut_next.x - (btn.width + 10);
			btn.y = FlxG.height - 50;
			btn.doAdd(this);
			btn_tut_prev = btn;
		}
	}

	function onTutNext(){
		//--
	}

	function onTutPrev(){
		//--
	}

	function addButton(str:String, x:Int, y:Int, level:Int){
		var btn = new SFButton(str);
		btn.onClick = function(){ startLevel(level); }
		btn.x = x;
		btn.y = y;
		btn.doAdd(this);

		if(Progress.getInstance().wins[level]){
			var star = new FlxSprite();
			star.loadGraphic(AssetPaths.starico__png, false);
			star.scale.y = (btn.height * 0.8) / star.height;
			star.scale.x = star.scale.y;
			star.updateHitbox();
			star.x = btn.x + btn.width;
			star.y = btn.y + ((btn.height - star.height) / 2);
			add(star);
		}
		return btn;
	}

	override public function update(elapsed:Float){
		super.update(elapsed);
	}

	function startLevel(level:Int):Void{
		switch(level){
			default: 	FlxG.switchState(new PlayState(level, 5, 	1, 30, 10));
			case 2: 	FlxG.switchState(new PlayState(level, 10, 	1, 3, 1));
			case 3: 	FlxG.switchState(new PlayState(level, 30, 	1, 5, 1));
			case 4: 	FlxG.switchState(new PlayState(level, 30, 	2, 5, 2));
			case 5: 	FlxG.switchState(new PlayState(level, 40, 	2, 5, 2));
			case 6: 	FlxG.switchState(new PlayState(level, 27, 	3, 5, 3));
			case 7: 	FlxG.switchState(new PlayState(level, 34, 	4, 10, 3));
			case 8: 	FlxG.switchState(new PlayState(level, 40, 	5, 10, 3));
			case 9: 	FlxG.switchState(new PlayState(level, 45, 	6, 10, 4));
			case 10: 	FlxG.switchState(new PlayState(level, 45, 	7, 10, 4));
		}
	}
}
