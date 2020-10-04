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
	var levelButtons:Array<SFButton>;
	var btn_tut_next:SFButton;
	var btn_tut_prev:SFButton;
	var tutIndex:Int;

	override public function create(){
		super.create();


		tutIndex = -1;

		title = new FlxSprite();
		title.loadGraphic(AssetPaths.menu__png, false);
		title.setGraphicSize(FlxG.width, FlxG.height);
		add(title);

		levelButtons = [];

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
		addButton("Tutorial", 570, 398, -1);

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
			btn.visible = false;
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
			btn.visible = false;
			btn_tut_prev = btn;
		}

		//social
		#if js
		{
			var btn = new SFButton('Twitter');
			btn.onClick = function(){
				untyped {
					window.open('https://twitter.com/alexramallo');
				}
			}
			btn.x = 570;
			btn.y = 478;
			btn.visible = true;
			btn.doAdd(this);
			levelButtons.push(btn);
		}
		#end
	}

	function onTutNext(){
		tutIndex++;
		if(tutIndex >= tutorials.length){
			tutIndex = -1;
		}
	}

	function onTutPrev(){
		tutIndex--;
		if(tutIndex < -1){
			tutIndex = -1;
		}
	}

	function addButton(str:String, x:Int, y:Int, level:Int){
		var btn = new SFButton(str);
		btn.x = x;
		btn.y = y;
		btn.doAdd(this);

		if(level >= 0){
			btn.onClick = function(){ startLevel(level); }
			if(Progress.getInstance().wins[level - 1]){
				var star = new FlxSprite();
				star.loadGraphic(AssetPaths.starico__png, false);
				star.scale.y = (btn.height * 0.8) / star.height;
				star.scale.x = star.scale.y;
				star.updateHitbox();
				star.x = btn.x + btn.width;
				star.y = btn.y + ((btn.height - star.height) / 2);
				add(star);
			}
		}else{
			btn.onClick = function(){
				tutIndex = 0;
			}
		}

		levelButtons.push(btn);

		return btn;
	}

	override public function update(elapsed:Float){
		super.update(elapsed);

		if(tutIndex >= 0){
			for(btn in levelButtons){
				btn.visible = false;
			}

			btn_tut_next.visible = true;
			btn_tut_prev.visible = true;

			for(i in 0...tutorials.length){
				tutorials[i].visible = i == tutIndex;
			}
		}else{
			for(btn in levelButtons){
				btn.visible = true;
			}

			btn_tut_next.visible = false;
			btn_tut_prev.visible = false;

			for(i in 0...tutorials.length){
				tutorials[i].visible = false;
			}
		}
	}

	function startLevel(level:Int):Void{
		switch(level){
			default: 	FlxG.switchState(new PlayState(level, 5, 	1, 3, 1));
			case 2: 	FlxG.switchState(new PlayState(level, 10, 	1, 3, 1));
			case 3: 	FlxG.switchState(new PlayState(level, 30, 	1, 5, 2));
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
