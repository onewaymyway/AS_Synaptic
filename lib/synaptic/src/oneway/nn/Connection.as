package oneway.nn {
	
	/**
	 * ...
	 * @author ww
	 */
	public class Connection {
		public static var connections:int = 0;
		
		public static function uid():int {
			return connections++;
		}
		public var ID:int;
		public var from:Neuron;
		public var to:Neuron;
		public var weight:Number;
		public var gain:int = 1;
		public var gater:* = null;
		
		public function Connection(from:Neuron, to:Neuron, weight:Number = -1) {
			this.ID = Connection.uid();
			this.from = from;
			this.to = to;
			this.weight = weight < 0 ? Math.random() * .2 - .1 : weight;
			this.gain = 1;
			this.gater = null;
		}
	
	}

}