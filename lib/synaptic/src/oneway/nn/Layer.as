package oneway.nn {
	
	/**
	 * ...
	 * @author ww
	 */
	public class Layer {
		
		/**
		 * 大小
		 */
		public var size:int;
		/**
		 * Neuron List
		 */
		public var list:Array;
		/**
		 * 连接的列表
		 */
		public var connectedTo:Array;
		
		public function Layer(size:int=0) {
			this.size = size | 0;
			this.list = [];
			
			this.connectedTo = [];
			
			while (size--) {
				var neuron:Neuron = new Neuron();
				this.list.push(neuron);
			}
		}
		
		public function activate(input:Array=null):Array {
			
			var activations:Array = [];
			
			if (input) {
				if (input.length != this.size)
					throw new Error('INPUT size and LAYER size must be the same to activate!');
				
				for (var id:String in this.list) {
					var neuron:Neuron = this.list[id];
					var activation:Number = neuron.activate(input[id]);
					activations.push(activation);
				}
			}
			else {
				for (id in this.list) {
					neuron = this.list[id];
					activation = neuron.activate();
					activations.push(activation);
				}
			}
			return activations;
		}
		
		public function propagate(rate:Number, target:Array=null):void {
			
			if (target) {
				if (target.length != this.size)
					throw new Error('TARGET size and LAYER size must be the same to propagate!');
				
				for (var id:int = this.list.length - 1; id >= 0; id--) {
					var neuron:Neuron = this.list[id];
					neuron.propagate(rate, target[id]);
				}
			}
			else {
				for (id = this.list.length - 1; id >= 0; id--) {
					neuron = this.list[id];
					neuron.propagate(rate);
				}
			}
		}
		
		public function project(layer:*, type:String=null, weights:Array=null):LayerConnection {
			
			if (layer is NetWork)
				layer = layer.layers.input;
			
			if (layer is Layer) {
				if (!this.connected(layer))
					return new LayerConnection(this, layer, type, weights);
			}
			else
				throw new Error('Invalid argument, you can only project connections to LAYERS and NETWORKS!');
			return null;
		
		}
		
		public function gate(connection:LayerConnection, type:String):void {
			
			if (type == GateType.INPUT) {
				if (connection.to.size != this.size)
					throw new Error('GATER layer and CONNECTION.TO layer must be the same size in order to gate!');
				
				for (var id:String in connection.to.list) {
					var neuron:Neuron = connection.to.list[id];
					var gater:* = this.list[id];
					for (var input:String in neuron.connections.inputs) {
						var gated:Object = neuron.connections.inputs[input];
						if (gated.ID in connection.connections)
							gater.gate(gated);
					}
				}
			}
			else if (type == GateType.OUTPUT) {
				if (connection.from.size != this.size)
					throw new Error('GATER layer and CONNECTION.FROM layer must be the same size in order to gate!');
				
				for (id in connection.from.list) {
					neuron = connection.from.list[id];
					gater = this.list[id];
					for (var projected:String in neuron.connections.projected) {
						gated = neuron.connections.projected[projected];
						if (gated.ID in connection.connections)
							gater.gate(gated);
					}
				}
			}
			else if (type == GateType.ONE_TO_ONE) {
				if (connection.size != this.size)
					throw new Error('The number of GATER UNITS must be the same as the number of CONNECTIONS to gate!');
				
				for (id in connection.list) {
					gater = this.list[id];
					gated = connection.list[id];
					gater.gate(gated);
				}
			}
			connection.gatedfrom.push({layer: this, type: type});
		}
		
		public function selfconnected():Boolean {
			
			for (var id:String in this.list) {
				var neuron:Neuron = this.list[id];
				if (!neuron.selfconnected())
					return false;
			}
			return true;
		}
		
		public function connected(layer:Layer):* {
			// Check if ALL to ALL connection
			var connections:int = 0;
			for (var here:String in this.list) {
				for (var there:String in layer.list) {
					var from:Neuron = this.list[here];
					var to :Neuron= layer.list[there];
					var connected:Object = from.connected(to);
					if (connected.type == 'projected')
						connections++;
				}
			}
			if (connections == this.size * layer.size)
				return ConnectionType.ALL_TO_ALL;
			
			// Check if ONE to ONE connection
			connections = 0;
			for (var neuron:String in this.list) {
				from = this.list[neuron];
				to = layer.list[neuron];
				connected = from.connected(to);
				if (connected.type == 'projected')
					connections++;
			}
			if (connections == this.size)
				return ConnectionType.ONE_TO_ONE;
		}
		
		public function clear():void {
			for (var id:String in this.list) {
				var neuron:Neuron = this.list[id];
				neuron.clear();
			}
		}
		
		public function reset():void {
			for (var id:String in this.list) {
				var neuron:Neuron = this.list[id];
				neuron.reset();
			}
		}
		
		public function neurons():Array {
			return this.list;
		}
		
		public function add(neuron:Neuron=null):void {
			neuron = neuron || new Neuron();
			this.list.push(neuron);
			this.size++;
		}
		
		public function set(options:Object = null):Layer {
			options = options || {};
			
			for (var i:String in this.list) {
				var neuron:Neuron = this.list[i];
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