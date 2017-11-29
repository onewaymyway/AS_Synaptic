package oneway.nn.networks {
	import oneway.nn.Connection;
	import oneway.nn.Layer;
	import oneway.nn.NetWork;
	
	/**
	 * ...
	 * @author ww
	 */
	public class Liquid extends NetWork {
		
		public function Liquid(inputs:int, hidden:int, outputs:int, connections:int, gates:int) {
			super();
			// create layers
			var inputLayer:Layer = new Layer(inputs);
			var hiddenLayer:Layer = new Layer(hidden);
			var outputLayer:Layer = new Layer(outputs);
			
			// make connections and gates randomly among the neurons
			var neurons:Array  = hiddenLayer.neurons();
			var connectionList:Array = [];
			
			for (var i:int = 0; i < connections; i++) {
				// connect two random neurons
				var from:int = Math.random() * neurons.length | 0;
				var to:int = Math.random() * neurons.length | 0;
				var connection:* = neurons[from].project(neurons[to]);
				connectionList.push(connection);
			}
			
			for (var j:int = 0; j < gates; j++) {
				// pick a random gater neuron
				var gater:int = Math.random() * neurons.length | 0;
				// pick a random connection to gate
				connection = Math.random() * connectionList.length | 0;
				// let the gater gate the connection
				neurons[gater].gate(connectionList[connection]);
			}
			
			// connect the layers
			inputLayer.project(hiddenLayer);
			hiddenLayer.project(outputLayer);
			
			// set the layers of the network
			this.set({input: inputLayer, hidden: [hiddenLayer], output: outputLayer});
		}
	
	}

}