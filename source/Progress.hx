class Progress {
	public var wins:Array<Bool>;

	public function new(){
		wins = [false, false, false, false, false, false, false, false, false, false];
	}

	private static var inst:Progress = null;
	public static function getInstance():Progress {
		if(inst == null){
			inst = new Progress();
		}
		return inst;
	}
}