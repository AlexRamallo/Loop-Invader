package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;

using StringTools;

import openfl.events.KeyboardEvent;

class PlayState extends FlxState{

	public var TitleBg:FlxSprite;
	public var TitleTxt:FlxText;
	public var EndMessage:FlxSprite;

	public var BugIcons:Array<FlxSprite>;

	var grid:Grid;
	var quitButton:SFButton;
	
	public static function IW(value:Float):Float return (value / 800) * FlxG.width;
	public static function IH(value:Float):Float return (value / 600) * FlxG.height;
	public static inline function IWi(value:Float):Int return Std.int(IW(value));
	public static inline function IHi(value:Float):Int return Std.int(IH(value));

	public var blockFocus:CodeBlock = null;

	var num_ball:Int;
	var num_virus:Int;
	var num_if:Int;
	var num_while:Int;
	var level:Int;

	override public function new(level:Int, num_ball:Int, num_virus:Int, num_if:Int, num_while:Int){
		super();
		this.level = level;
		this.num_ball = num_ball;
		this.num_virus = num_virus;
		this.num_if = num_if;
		this.num_while = num_while;
	}

	override public function create(){
		super.create();
		trace('PlayState::create');
		initUI();
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}

	public function onKeyDown(e:KeyboardEvent):Void{
		if(blockFocus != null){
			blockFocus.onKeyDown(e);
		}
	}

	public function onVictory(){
		trace('You win :)');
		EndMessage.visible = true;
		EndMessage.animation.frameIndex = 1;
		EndMessage.y = FlxG.height;
		Progress.getInstance().wins[level] = true;
	}

	public function onLoss(){
		trace('You Lose :(');
		EndMessage.visible = true;
		EndMessage.y = FlxG.height;
		EndMessage.animation.frameIndex = 0;
	}

	public function initUI():Void {
		this.bgColor = FlxColor.fromRGB(22, 45, 80, 255);
		TitleBg = new FlxSprite();
		TitleBg.makeGraphic(FlxG.width, IHi(50), FlxColor.fromRGB(170, 0, 0, 255));
		TitleTxt = new FlxText(22, 0, 0, "LD47.hx");
		TitleTxt.setFormat("assets/fonts/UbuntuMono-Italic.ttf", IHi(28), FlxColor.WHITE);
		add(TitleBg);
		add(TitleTxt);

		var gh = (FlxG.height - TitleBg.height) * 0.8;
		var gw = FlxG.width * 0.875;

		grid = new Grid(
			(FlxG.width - gw) / 2,
			(FlxG.height - gh) / 2,
			20, 20
		);

		grid.max_if = num_if;
		grid.max_while = num_while;


		quitButton = new SFButton("abort();");
		quitButton.label.size -= 12;
		quitButton.onClick = function(){ FlxG.switchState(new MenuState()); }
		quitButton.scale.y = (TitleBg.height * 0.8) / quitButton.height;
		quitButton.scale.x = quitButton.scale.y;
		quitButton.updateHitbox();

		quitButton.y = TitleBg.height * 0.1;
		quitButton.x = FlxG.width - (quitButton.width + quitButton.y);
		quitButton.doAdd(this);

		grid.initUI(this, gw, gh, num_ball, num_virus);

		BugIcons = [];
		var xx = grid.x;
		var yy = grid.y + grid.disp_h;
		for(i in 0...10){
			var bug = new FlxSprite();
			bug.loadGraphic(AssetPaths.bugico__png, false);
			bug.scale.y = ((FlxG.height - yy) * 0.6) / bug.height;
			bug.scale.x = bug.scale.y;
			bug.updateHitbox();
			bug.x = xx + (i * bug.width * 1.25);
			bug.y = yy + (((FlxG.height - yy) - bug.height) * 0.5);
			bug.visible = false;
			add(bug);
			BugIcons.push(bug);
		}

		EndMessage = new FlxSprite();
		EndMessage.loadGraphic(AssetPaths.end_messages__png, true, 580, 316);
		EndMessage.x = (FlxG.width - EndMessage.width) / 2;
		EndMessage.y = (FlxG.height - EndMessage.height) / 2;
		EndMessage.visible = false;
		add(EndMessage);
	}

	override public function update(elapsed:Float){
		super.update(elapsed);
		grid.update();

		var ey = (FlxG.height - EndMessage.height) / 2;
		if(EndMessage.visible){
			EndMessage.y += (ey - EndMessage.y) * 0.2;
		}
	}
}

enum Condition {
	EQUAL;
	NEQUAL;
	LESSTHAN;
	GREATERTHAN;
	LEQUAL;
	GEQUAL;
}
enum CodeType {
	NONE;
	WHILE(val:Int, condition:Condition);
	IF(val:Int, condition:Condition);
}

class CodeBlock{
	public static var uid_ct = 0;
	public var uid:Int;

	public var dead = false;
	public var grid:Grid;
	public var type:CodeType;
	public var loc:{tl:Int, br:Int};
	public var src:String;
	public var label:FlxText;
	public var rect:FlxSprite;

	public var valid:Bool = true;

	public var x(get, null):Int;
	public var y(get, null):Int;
	public var width(get, null):Int;
	public var height(get, null):Int;

	public var alpha_target:Float = 0.6;

	public function get_width():Int {
		var cpos_tl = grid.getCellPos(loc.tl);
		var cpos_br = grid.getCellPos(loc.br);
		return Std.int((cpos_br.x + grid.cell_w) - cpos_tl.x);
	}

	public function get_height():Int {
		var cpos_tl = grid.getCellPos(loc.tl);
		var cpos_br = grid.getCellPos(loc.br);
		return Std.int((cpos_br.y + grid.cell_h) - cpos_tl.y);
	}

	public function get_x():Int {
		var cpos_tl = grid.getCellPos(loc.tl);
		return cpos_tl.x;
	}

	public function get_y():Int {
		var cpos_tl = grid.getCellPos(loc.tl);
		return cpos_tl.y;
	}

	public function new(grid:Grid, cell:Int){
		uid = uid_ct++;
		this.grid = grid;
		loc = {tl: cell, br: cell};
		init();
		src = "";
		type = NONE;
	}

	public function init(){
		label = new FlxText();
		label.setFormat("assets/fonts/UbuntuMono-Regular.ttf", PlayState.IHi(28), FlxColor.WHITE);
		rect = new FlxSprite();
		rect.makeGraphic(1, 1, FlxColor.WHITE);
		grid.flxstate.add(rect);
		grid.flxstate.add(label);
	}

	public function remove(){
		dead = true;
		grid.flxstate.remove(rect);
		grid.flxstate.remove(label);
		grid.blocks.remove(this);
	}

	public function doesOverlap(other:CodeBlock):Bool {
		var fuzz = grid.cell_w * 0.25;
		if(x + fuzz > other.x + other.width) return false;
		if(x + width - fuzz < other.x) return false;
		if(y + fuzz > other.y + other.height) return false;
		if(y + height - fuzz < other.y) return false;
		return true;
	}

	public function doesOverlapPoint(px:Int, py:Int):Bool {
		var cpos = grid.getCellPos(loc.tl);
		return (
			px >= cpos.x && px <= cpos.x + width &&
			py >= cpos.y && py <= cpos.y + height
		);
	}

	public function update():Void{
		label.text = src;

		var coltype = type;
		if(!valid){
			coltype = NONE;
		}

		switch(coltype){
			case NONE:
				label.color = Grid.valueToColor(-1);
				rect.color = label.color;
			case WHILE(val, condition):
				label.color = Grid.valueToColor(val);

				if(condition == NEQUAL){
					rect.color = FlxColor.subtract(label.color, FlxColor.fromRGB(40, 40, 40));
				}else{
					rect.color = label.color;
				}
			case IF(val, condition):
				label.color = Grid.valueToColor(val);
				if(condition == NEQUAL){
					rect.color = FlxColor.subtract(label.color, FlxColor.fromRGB(40, 40, 40));
				}else{
					rect.color = label.color;
				}
		}

		rect.alpha += (alpha_target - rect.alpha) * 0.3;

		var cpos = grid.getCellPos(loc.tl);
		label.x = cpos.x;
		label.y = cpos.y;// - label.height;

		rect.x = cpos.x + (width/2);
		rect.y = cpos.y + (height/2);
		rect.scale.x = width;
		rect.scale.y = height;

		if(doesOverlapPoint(FlxG.mouse.x, FlxG.mouse.y)){
			alpha_target = 0.2;
		}else{
			alpha_target = 0.6;
		}
	}

	public function onKeyDown(e:KeyboardEvent):Void{
		if(e.charCode >= 32 && e.charCode <= 126){
			src += String.fromCharCode(e.charCode);
		}else if(e.charCode == 8 && src.length > 0){
			src = src.substr(0, src.length - 1);
		}

		update();
		rect.alpha = 0.35;
	}

	public function start_writer(){
		rect.alpha = 0.35;
		grid.flxstate.blockFocus = this;
	}

	public function update_writer(){
		rect.color = FlxColor.WHITE;
		label.color = FlxColor.RED;
		rect.alpha = 0.8;
		//--
	}

	//parse src
	public function end_writer(){
		grid.flxstate.blockFocus = null;

		if(!parseSrc()){
			trace('SYNTAX ERROR!');
			type = NONE;
		}
		update();
	}

	function parseSrc():Bool{
		src.trim();

		var start_idx = 0;
		if(src.startsWith("while")){
			start_idx = 5;
		}else if(src.startsWith("if")){
			start_idx = 2;
		}else{
			return false; //unrecognized control type
		}

		var p_1:Int = -1;
		var p_2:Int = -1;
		var condition:Condition = EQUAL;

		if(src.charAt(start_idx) == '('){
			p_1 = start_idx;
		}else if(src.charAt(start_idx) != ' '){
			return false; //garbage characters after control type
		}

		for(i in (start_idx + 1)...src.length){
			if(p_1 == -1){
				if(src.charAt(i) == '('){
					p_1 = i;
					continue;
				}
			}else if(p_2 == -1){
				if(src.charAt(i) == ')'){
					p_2 = i;
					continue;
				}else{
					if(condition == EQUAL){
						switch(src.charAt(i)){
							case '!':
								p_1 = i;
								condition = NEQUAL;

							case '<':
								if(src.length <= i + 1) return false;
								if(src.charAt(i + 1) == '='){
									condition = LEQUAL;
									p_1 = i + 1;
								}else{
									condition = LESSTHAN;
									p_1 = i;
								}

							case '>':
								if(src.length <= i + 1) return false;
								if(src.charAt(i + 1) == '='){
									condition = GEQUAL;
									p_1 = i + 1;
								}else{
									condition = GREATERTHAN;
									p_1 = i;
								}
							
							case ' ':
								continue;

							default:
								var code = src.fastCodeAt(i);
								if(code < '0'.code || code > '9'.code){
									return false; //invalid character in conditional body
								}
						}
					}else if(src.charAt(i) != ' '){
						var code = src.fastCodeAt(i);
						if(code < '0'.code || code > '9'.code){
							if(code == '='.code && (condition == GEQUAL || condition == LEQUAL)){
								continue;
							}
							return false; //invalid character in conditional body
						}
					}
				}
			}else if(src.charAt(i) != ' '){
				return false; //garbage trailing characters
			}
		}

		var valstr = src.substr(p_1 + 1, p_2);
		var value = Std.parseInt(valstr);

		switch(start_idx){
			default: return false; //impossible
			case 5: type = WHILE(value, condition);
			case 2: type = IF(value, condition);
		}

		return true;
	}
}

enum GridState {
	Idle;
	Zapping;
	CreatingBlock;
	ValidatingNewBlock;
	WriteBlock;
	Ended;
}

class Grid {
	public var flxstate:PlayState;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var cell_w:Float;
	public var cell_h:Float;
	public var disp_w:Float;
	public var disp_h:Float;
	public var cells:Array<FlxSprite>;

	public var balls:Array<GridBall>;

	public var blocks:Array<CodeBlock>;
	private var edit_block:CodeBlock;

	public var cell_color:FlxColor;

	public var ctlState:GridState;

	public var zapper:FlxSprite;

	public var total_viruses:Int = 0;
	public var live_viruses:Int = 0;
	public var bad_zaps:Int = 0;

	public var max_while:Int = 2;
	public var max_if:Int = 5;
	
	public var num_while:Int = 0;
	public var num_if:Int = 0;

	var timer_1:Float = 0.0;


	public static function valueToColor(val:Int):FlxColor {
		switch(val){
			default:
				return FlxColor.RED;
			case 1:
				return FlxColor.fromRGB(120, 208, 25, 255);
			case 2:
				return FlxColor.fromRGB(14, 191, 255, 255);
			case 3:
				return FlxColor.fromRGB(255, 151, 25, 255);
		}
	}

	public function getCellLoc(cellIdx:Int):{x:Int, y:Int}{
		return {
			x: Std.int(cellIdx % width),
			y: Std.int(Math.floor(cellIdx / height))
		};
	}

	public function getCellPos(cellIdx:Int):{x:Int, y:Int}{
		var loc = getCellLoc(cellIdx);
		return {
			x: Math.round(this.x + (loc.x * cell_w)),
			y: Math.round(this.y + (loc.y * cell_h))
		}
	}

	public function getCellIdx(dx:Int, dy:Int):Int{
		var cell_x:Int = Math.floor(((dx - x) / disp_w) * width);
		var cell_y:Int = Math.floor(((dy - y) / disp_h) * height);
		return Std.int((cell_y * width) + (cell_x % width));
	}

	public function new(x:Float, y:Float, w:Float, h:Float){
		ctlState = Idle;
		this.x = Std.int(x);
		this.y = Std.int(y);
		width = Std.int(w);
		height = Std.int(h);
		cell_color = FlxColor.fromRGB(180, 180, 180, 255);
		blocks = [];
		balls = [];
	}

	public function onGoodZap(){
		//play sound
		live_viruses--;
		if(live_viruses <= 0){
			flxstate.onVictory();
			ctlState = Ended;

			for(block in blocks){
				block.remove();
			}
		}
	}

	public function onBadZap(){
		//play sound
		bad_zaps++;
		if(bad_zaps >= 3){
			flxstate.onLoss();
			ctlState = Ended;
			
			for(block in blocks){
				block.remove();
			}
		}
	}

	public function addBall(value:Int, ?x:Null<Int>, ?y:Null<Int>):GridBall{
		var ball = new GridBall(this, value);

		if(x != null){
			ball.x = x;
		}else{
			ball.x = Std.int((this.x + ball.radius) + (Math.random() * (disp_w - ball.radius)));
		}
		if(y != null){
			ball.y = y;
		}else{
			ball.y = Std.int((this.y + ball.radius) + (Math.random() * (disp_h - ball.radius)));
		}

		ball.xspd = 0.2 + Math.random() * 0.3;
		ball.yspd = 0.2 + Math.random() * 0.3;

		balls.push(ball);
		return ball;
	}

	public function initUI(state:PlayState, display_width:Float, display_height:Float, num_ball:Int, num_virus:Int){
		flxstate = state;
		cells = [];

		disp_w = display_width;
		disp_h = display_height;

		cell_w = display_width / width;
		cell_h = display_height / height;

		var cell_g_w:Int = 4;
		var cell_g_h:Int = 4;

		for(y in 0...height){
			for(x in 0...width){
				var cell = new FlxSprite();
				cell.makeGraphic(
					cell_g_w,
					cell_g_h,
					cell_color
				);
				cell.x = this.x + (x * cell_w) + (cell_w / 2);
				cell.y = this.y + (y * cell_h) + (cell_h / 2);

				state.add(cell);
				cells.push(cell);
			}
		}

		total_viruses = num_virus;
		live_viruses = num_virus;

		for(i in 0...num_ball){
			var ball = addBall(1 + Math.round(Math.random() * 2));
			if(num_virus > 0){
				num_virus--;
				ball.virus = true;
			}
		}

		zapper = new FlxSprite();
		zapper.loadGraphic(AssetPaths.zapper__png, false);
		flxstate.add(zapper);
	}

	public function update_balls(){
		for(ball in balls){
			ball.update();
		}
	}

	public function update(){
		var mx = FlxG.mouse.x;
		var my = FlxG.mouse.y;
		var ingrid = (mx >= x && mx <= x + disp_w) && (my >= y && my <= y + disp_h);

		var cell_loc = {x: 0, y: 0};
		var cell_id:Int = 0;

		if(ingrid){
			//cell_x:Int = Math.floor(((mx - x) / disp_w) * width);
			//cell_y:Int = Math.floor(((my - y) / disp_h) * height);
			//cell_id:Int = (cell_y * width) + (cell_x % width);

			cell_id = getCellIdx(mx, my);
			cell_loc = getCellLoc(cell_id);
		}

		var hp = 3 - bad_zaps;
		flxstate.TitleTxt.text = 'HP: $hp   IF: $num_if / $max_if   WHILE: $num_while / $max_while';
		for(i in 0...total_viruses){
			var bug = flxstate.BugIcons[i];
			bug.visible = true;
			if(i > live_viruses-1){
				bug.alpha = 0.3;
			}else{
				bug.alpha = 1.0;
			}
		}

		switch(ctlState){
			case Ended:
				//do nothing

			case Zapping:
				zapper.visible = true;

				zapper.x = FlxG.mouse.x - (zapper.width/2);
				zapper.y = FlxG.mouse.y - (zapper.height/2);
				zapper.alpha = 0.5;

				var overlap = null;
				for(ball in balls){
					if(ball.doesOverlapPoint(FlxG.mouse.x, FlxG.mouse.y)){
						ball.bg.alpha = 0.8;
						ball.grow_target = 0.2;
						overlap = ball;
					}else{
						ball.grow_target = 0.0;
						ball.bg.alpha = 1.0;
					}
					ball.update_animation();
				}

				if(FlxG.mouse.justPressed && overlap != null){
					if(overlap.virus){
						onGoodZap();
					}else{
						onBadZap();
					}
					overlap.remove();
				}

				if(FlxG.keys.justPressed.SPACE){
					ctlState = Idle;
					return;
				}


			case Idle:
				zapper.visible = false;

				if(FlxG.keys.justPressed.SPACE){
					ctlState = Zapping;
					return;
				}

				update_balls();
				if(ingrid){
					for(i in 0...cells.length){
						if(i == cell_id){
							cells[i].color = FlxColor.YELLOW;
							cells[i].scale.x = 2.0;
							cells[i].scale.y = 2.0;
						}else{
							cells[i].color = cell_color;
							cells[i].scale.x = 1.0;
							cells[i].scale.y = 1.0;
						}
					}

					var overlapped:CodeBlock = null;
					for(block in blocks){
						if(block.doesOverlapPoint(FlxG.mouse.x, FlxG.mouse.y)){
							overlapped = block;
							break;
						}
					}

					if(FlxG.mouse.justReleasedRight){
						if(overlapped != null){
							do_discard_block(overlapped);
							return;
						}
					}

					if(FlxG.mouse.justPressed){
						if(overlapped == null){
							edit_block = new CodeBlock(this, cell_id);
							blocks.push(edit_block);
							ctlState = CreatingBlock;
						}else{
							ctlState = WriteBlock;
							edit_block = overlapped;
							edit_block.start_writer();
						}
					}

				}
				for(block in blocks){
					block.update();
				}

			case CreatingBlock:
				edit_block.loc.br = cell_id;
				if(edit_block.width < 0 || edit_block.height < 0){
					edit_block.loc.br = edit_block.loc.tl;
				}

				edit_block.update();

				if(FlxG.mouse.justReleased){
					ctlState = ValidatingNewBlock;
					timer_1 = 0.0;
				}

			case WriteBlock:
				edit_block.update_writer();
				if(FlxG.keys.pressed.ESCAPE || FlxG.keys.pressed.ENTER || FlxG.mouse.justPressedRight){
					edit_block.end_writer();
					update_block_counts();
					ctlState = Idle;
				}

			case ValidatingNewBlock:
				timer_1 += FlxG.elapsed;

				if(edit_block.width == 0 || edit_block.height == 0){
					do_discard_block(edit_block);
					edit_block = null;
					ctlState = Idle;
					trace('discarding 0-size block');
					return;
				}

				var doesOverlap = false;
				for(block in blocks){
					if(block == edit_block) continue;

					if(block.doesOverlap(edit_block)){
						block.alpha_target = 1.0;
						doesOverlap = true;
					}

					block.update();
				}

				if(doesOverlap){
					if(timer_1 >= 1.0){
						do_discard_block(edit_block);
						edit_block = null;
						ctlState = Idle;
						trace('discarding due to overlap');
					}
					return;
				}

				trace('created new block of size(${edit_block.width}, ${edit_block.height})');
				ctlState = WriteBlock;
				edit_block.start_writer();
				//edit_block = null;
		}
	}

	public function update_block_counts(){
		num_while = 0;
		num_if = 0;

		for(block in blocks){
			switch(block.type){
				case IF(_, _):
					num_if++;
					if(num_if>max_if){
						block.valid = false;
					}else{
						block.valid = true;
					}
				case WHILE(_, _):
					num_while++;
					
					if(num_while>max_while){
						block.valid = false;
					}else{
						block.valid = true;
					}

				default:
					block.valid = true;
					continue;
			}			
		}
	}

	public function do_discard_block(block:CodeBlock){
		block.remove();
		update_block_counts();
	}
}

enum GridBallType {
	Ball;
	Square;
}

class GridBall {
	public static var uid_ct = 0;
	public var uid:Int;

	public var virus:Bool = false;

	public var cur_block:CodeBlock = null;

	public var radius:Float = 30;

	public var grid:Grid;
	public var bg:FlxSprite;
	public var value:Int = 1;
	public var init_value:Int = 1;

	public var type:GridBallType = Ball;

	public var xvel:Float = 0.0;
	public var yvel:Float = 0.0;

	public var xspd:Float = 0.0;
	public var yspd:Float = 0.0;

	public var max_vel:Float = 2.0;
	public var damping:Float = 0.5;

	public var grow_target:Float = 0.0;
	private var grow_amount:Float = 0.0;

	public var change_cooldown:Float = 2.0;
	var change_cooldown_timer:Float = 0.0;

	public var incr_timer:Float = 0.0;

	public var x(get, set):Float;
	public var y(get, set):Float;

	public inline function get_x():Float return bg.x;
	public inline function get_y():Float return bg.y;
	public inline function set_x(set:Float):Float return bg.x = set;
	public inline function set_y(set:Float):Float return bg.y = set;

	public function new(grid:Grid, value:Int){
		this.grid = grid;
		uid = uid_ct++;

		this.value = value;
		this.init_value = value;

		bg = new FlxSprite();
		bg.loadGraphic(AssetPaths.gridball__png, true, 128, 128);

		type = Ball;

		grid.flxstate.add(bg);

		bg.scale.x = radius / 128;
		bg.scale.y = radius / 128;
		bg.updateHitbox();

		virus = false;
	}

	public function remove(){
		grid.flxstate.remove(bg);
		grid.balls.remove(this);
	}

	public function update():Void{
		change_cooldown_timer -= FlxG.elapsed;

		if(incr_timer > 0){
			incr_timer -= FlxG.elapsed;
			if(incr_timer <= 0){
				value++;
				if(value > 9){
					value = 9;
				}
			}
		}

		xvel += xspd;
		yvel += yspd;

		if(xvel > max_vel) xvel = max_vel;
		if(xvel < -max_vel) xvel = -max_vel;
		if(yvel > max_vel) yvel = max_vel;
		if(yvel < -max_vel) yvel = -max_vel;

		x += xvel;
		y += yvel;

		collide_balls();
		collide_blocks();
		collide_bounds(grid.x, grid.y, grid.disp_w, grid.disp_h);

		bg.animation.frameIndex = value - 1;

		bg.color = Grid.valueToColor(value);

		update_animation();
	}

	public function update_animation(){
		grow_amount += (grow_target - grow_amount * 0.3);
		bg.scale.x = (radius * (1.0 + grow_amount)) / 128;
		bg.scale.y = (radius * (1.0 + grow_amount)) / 128;
	}

	public function doesOverlapPoint(px:Int, py:Int):Bool {
		if(px < x) return false;
		if(px > x + radius) return false;
		if(py < y) return false;
		if(py > y + radius) return false;
		return true;
	}

	function bounce_wall(xx:Float, yy:Float, ww:Float, hh:Float){

		if(x > xx + ww) return;
		if(x + radius < xx) return;
		if(y > yy + hh) return;
		if(y + radius < yy) return;

		var dt_l = (x + radius) - (xx);
		var dt_r = (xx + ww) - (x);
		
		var dt_t = (y + radius) - (yy);
		var dt_b = (yy + hh) - (y);

		var dt_h = Math.min(dt_l, dt_r);
		var dt_v = Math.min(dt_t, dt_b);

		if(dt_h < dt_v){
			if(x + radius > xx && x < xx){
				x = xx - radius;
				xvel = Math.abs(xvel) * -damping;
				xspd = Math.abs(xspd) * -1.0;
				hit_wall();
			}else{
				x = xx + ww;
				xvel = Math.abs(xvel) * damping;
				xspd = Math.abs(xspd);
				hit_wall();
			}
		}else{
			if(y + radius > yy && y < yy){
				y = yy - radius;
				yvel = Math.abs(yvel) * -damping;
				yspd = Math.abs(yspd) * -1.0;
				hit_wall();
			}else{
				y = yy + hh;
				yvel = Math.abs(yvel) * damping;
				yspd = Math.abs(yspd);
				hit_wall();
			}
		}
	}

	function collide_bounds(xx:Float, yy:Float, ww:Float, hh:Float){
		/*
		bounce_wall(xx - 10000, yy, 10000, hh);
		bounce_wall(xx + ww, yy, 10000, hh);
		bounce_wall(xx, yy - 10000, ww, 10000);
		bounce_wall(xx, yy + hh, ww, 10000);
		*/
		//*
		if(x + radius > xx + ww){
			x = xx + ww - radius;
			xvel = Math.abs(xvel) * -damping;
			xspd = Math.abs(xspd) * -1.0;
			hit_wall();
		}

		if(x < xx){
			x = xx;
			xvel = Math.abs(xvel) * damping;
			xspd = Math.abs(xspd);
			hit_wall();
		}

		if(y + radius > yy + hh){
			y = yy + hh - radius;
			yvel = Math.abs(yvel) * -damping;
			yspd = Math.abs(yspd) * -1.0;
			hit_wall();
		}

		if(y < yy){
			y = yy;
			yvel = Math.abs(yvel) * damping;
			yspd = Math.abs(yspd);
			hit_wall();
		}
		//*/
	}

	function collide_balls(){
		for(ball in grid.balls){
			if(ball == this) continue;
			var dt_x = ball.x-x;
			var dt_y = ball.y-y;
			var dist = Math.sqrt((dt_x*dt_x) + (dt_y*dt_y));
			var dt = dist - radius;
			if(dt < 0){
				if(xvel > yvel){
					xvel *= -damping;
				}else{
					yvel *= -damping;
				}

				if(Math.abs(dt_x) > Math.abs(dt_y)){
					if(x < ball.x){
						xspd = Math.abs(xspd) * -1;
						x += dt * damping;
						ball.x -= dt * damping;
					}else{
						xspd = Math.abs(xspd);
						x -= dt * damping;
						ball.x += dt * damping;
					}

					var r = Math.random();
					yspd += r - 0.5;
					ball.yspd += (1.0 - r) - 0.5;

				}else{
					if(y < ball.y){
						yspd = Math.abs(yspd) * -1;
						y += dt * damping;
						ball.y -= dt * damping;
					}else{
						yspd = Math.abs(yspd);
						y -= dt * damping;
						ball.y += dt * damping;
					}
					
					var r = Math.random();
					xspd += r - 0.5;
					ball.xspd += (1.0 - r) - 0.5;
				}

				hit_ball(ball);
			}
		}
	}

	var breakout_ct = 0;
	function collide_blocks(){
		//cur_block = null;

		var overlapped = null;
		for(block in grid.blocks){
			if(
				x + radius > block.x && x < block.x + block.width &&
				y + radius > block.y && y < block.y + block.height
			){
				overlapped = block;
				break;
			}
		}
		if(overlapped != null){
			cur_block = overlapped;
		}else{
			breakout_ct++;
			if(breakout_ct >= 1){
				breakout_ct = 0;
				cur_block = null;
			}
		}


		if(cur_block == null) return;
		if(cur_block.dead || !cur_block.valid){
			cur_block = null;
			return;
		}
		
		switch (cur_block.type) {
			default:
				//nothing

			case WHILE(val, condition):
				var pass = false;
				switch(condition){
					case EQUAL:
						pass = value == val;
					case NEQUAL:
						pass = value != val;
					case LEQUAL:
						pass = value <= val;
					case GEQUAL:
						pass = value >= val;
					case LESSTHAN:
						pass = value < val;
					case GREATERTHAN:
						pass = value > val;
				}
				if(pass){
					collide_bounds(
						cur_block.x,
						cur_block.y,
						cur_block.width,
						cur_block.height
					);
				}

			case IF(val, condition):
				var pass = false;
				switch(condition){
					case EQUAL:
						pass = value == val;
					case NEQUAL:
						pass = value != val;
					case LEQUAL:
						pass = value <= val;
					case GEQUAL:
						pass = value >= val;
					case LESSTHAN:
						pass = value < val;
					case GREATERTHAN:
						pass = value > val;
				}
				if(pass){
					bounce_wall(
						cur_block.x,
						cur_block.y,
						cur_block.width,
						cur_block.height
					);
				}
		}
		
	}

	function hit_wall(){
		//play sound
	}

	function hit_ball(other:GridBall){
		if(virus && !other.virus){
			if(other.incr_timer <= 0){
				//other.incr_timer = 0.2 + Math.random();
				other.incr_timer = 1.0;
			}
		}else if(value > init_value && !other.virus){
			value--;
		}
	}
}