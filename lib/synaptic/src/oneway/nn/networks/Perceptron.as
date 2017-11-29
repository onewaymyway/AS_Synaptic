package oneway.nn.networks {
	import oneway.nn.Layer;
	import oneway.nn.NetWork;
	import oneway.nn.Trainer;
	
	/**
	 * ...
	 * @author ww
	 */
	public class Perceptron extends NetWork {
		
		public function Perceptron(...argList) {
			super();
			var args:Array = Array.prototype.slice.call(argList); // convert arguments to Array
			if (args.length < 3)
				throw new Error('not enough layers (minimum 3) !!');
			
			var inputs:int = args.shift(); // first argument
			var outputs:int = args.pop(); // last argument
			var layers:Array = args; // all the arguments in the middle
			
			var input:Layer = new Layer(inputs);
			var hidden:Array = [];
			var output:Layer = new Layer(outputs);
			
			var previous:Layer = input;
			
			// generate hidden layers
			for (var i:int = 0; i < layers.length; i++) {
				var size:int = layers[i];
				var layer:Layer = new Layer(size);
				hidden.push(layer);
				previous.project(layer);
				previous = layer;
			}
			previous.project(output);
			
			// set layers of the neural network
			this.set( { input: input, hidden: hidden, output: output } );
			this.trainer = new Trainer(this);
		}
	
	}

}