package oneway.nn.networks {
	import oneway.nn.Layer;
	import oneway.nn.NetWork;
	import oneway.nn.Trainer;
	
	/**
	 * ...
	 * @author ww
	 */
	public class HopField extends NetWork {
		
		public function HopField(size:int) {
			var inputLayer = new Layer(size);
			var outputLayer = new Layer(size);
			
			inputLayer.project(outputLayer, Layer.connectionType.ALL_TO_ALL);
			
			this.set({input: inputLayer, hidden: [], output: outputLayer});
			
			this.trainer = new Trainer(this);
		
		}
		
		public function learn(patterns) {
			var set = [];
			for (var p in patterns)
				set.push({input: patterns[p], output: patterns[p]});
			
			return this.trainer.train(set, {iterations: 500000, error: .00005, rate: 1});
		}
		
		public function feed(pattern) {
			var output = this.activate(pattern);
			
			var pattern = [];
			for (var i in output)
				pattern[i] = output[i] > .5 ? 1 : 0;
			
			return pattern;
		}
	}

}