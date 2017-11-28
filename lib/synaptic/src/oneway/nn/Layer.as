package oneway.nn {
	
	/**
	 * ...
	 * @author ww
	 */
	public class Layer {
		public static var connectionType:Object = {ALL_TO_ALL: "ALL TO ALL", ONE_TO_ONE: "ONE TO ONE", ALL_TO_ELSE: "ALL TO ELSE"};
		public static var gateType:Object = {INPUT: "INPUT", OUTPUT: "OUTPUT", ONE_TO_ONE: "ONE TO ONE"};
		
		public var size:int;
		public var list:Array;
		public var connectedTo:Array;
		
		public function Layer(size:int) {
			this.size = size | 0;
			this.list = [];
			
			this.connectedTo = [];
			
			while (size--) {
				var neuron:Neuron = new Neuron();
				this.list.push(neuron);
			}
		}
		
		public function activate(input:Array=null):Array {
			
			var activations = [];
			
			if (input) {
				if (input.length != this.size)
					throw new Error('INPUT size and LAYER size must be the same to activate!');
				
				for (var id in this.list) {
					var neuron = this.list[id];
					var activation = neuron.activate(input[id]);
					activations.push(activation);
				}
			}
			else {
				for (var id in this.list) {
					var neuron = this.list[id];
					var activation = neuron.activate();
					activations.push(activation);
				}
			}
			return activations;
		}
		
		public function propagate(rate, target):void {
			
			if (typeof target != 'undefined') {
				if (target.length != this.size)
					throw new Error('TARGET size and LAYER size must be the same to propagate!');
				
				for (var id = this.list.length - 1; id >= 0; id--) {
					var neuron = this.list[id];
					neuron.propagate(rate, target[id]);
				}
			}
			else {
				for (var id = this.list.length - 1; id >= 0; id--) {
					var neuron = this.list[id];
					neuron.propagate(rate);
				}
			}
		}
		
		public function project(layer, type, weights):LayerConnection {
			
			if (layer instanceof NetWork)
				layer = layer.layers.input;
			
			if (layer instanceof Layer) {
				if (!this.connected(layer))
					return new LayerConnection(this, layer, type, weights);
			}
			else
				throw new Error('Invalid argument, you can only project connections to LAYERS and NETWORKS!');
		
		}
		
		public function gate(connection, type):void {
			
			if (type == Layer.gateType.INPUT) {
				if (connection.to.size != this.size)
					throw new Error('GATER layer and CONNECTION.TO layer must be the same size in order to gate!');
				
				for (var id in connection.to.list) {
					var neuron = connection.to.list[id];
					var gater = this.list[id];
					for (var input in neuron.connections.inputs) {
						var gated = neuron.connections.inputs[input];
						if (gated.ID in connection.connections)
							gater.gate(gated);
					}
				}
			}
			else if (type == Layer.gateType.OUTPUT) {
				if (connection.from.size != this.size)
					throw new Error('GATER layer and CONNECTION.FROM layer must be the same size in order to gate!');
				
				for (var id in connection.from.list) {
					var neuron = connection.from.list[id];
					var gater = this.list[id];
					for (var projected in neuron.connections.projected) {
						var gated = neuron.connections.projected[projected];
						if (gated.ID in connection.connections)
							gater.gate(gated);
					}
				}
			}
			else if (type == Layer.gateType.ONE_TO_ONE) {
				if (connection.size != this.size)
					throw new Error('The number of GATER UNITS must be the same as the number of CONNECTIONS to gate!');
				
				for (var id in connection.list) {
					var gater = this.list[id];
					var gated = connection.list[id];
					gater.gate(gated);
				}
			}
			connection.gatedfrom.push({layer: this, type: type});
		}
		
		public function selfconnected():Boolean {
			
			for (var id in this.list) {
				var neuron = this.list[id];
				if (!neuron.selfconnected())
					return false;
			}
			return true;
		}
		
		public function connected(layer):Boolean {
			// Check if ALL to ALL connection
			var connections = 0;
			for (var here in this.list) {
				for (var there in layer.list) {
					var from = this.list[here];
					var to = layer.list[there];
					var connected = from.connected(to);
					if (connected.type == 'projected')
						connections++;
				}
			}
			if (connections == this.size * layer.size)
				return Layer.connectionType.ALL_TO_ALL;
			
			// Check if ONE to ONE connection
			connections = 0;
			for (var neuron in this.list) {
				var from = this.list[neuron];
				var to = layer.list[neuron];
				var connected = from.connected(to);
				if (connected.type == 'projected')
					connections++;
			}
			if (connections == this.size)
				return Layer.connectionType.ONE_TO_ONE;
		}
		
		public function clear():void {
			for (var id in this.list) {
				var neuron = this.list[id];
				neuron.clear();
			}
		}
		
		public function reset():void {
			for (var id in this.list) {
				var neuron = this.list[id];
				neuron.reset();
			}
		}
		
		public function neurons():Array {
			return this.list;
		}
		
		public function add(neuron):void {
			neuron = neuron || new Neuron();
			this.list.push(neuron);
			this.size++;
		}
		
		public function set(options:Object = null):Layer {
			options = options || {};
			
			for (var i in this.list) {
				var neuron = this.list[i];
				if (options.label)
					neuron.label = options.label + '_' + neuron.ID;
				if (options.squash)
					neuron.squash = options.squash;
				if (options.bias)
					neuron.bias = options.bias;
			}
			return this;
		}
	
	}

}