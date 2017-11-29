package oneway.nn {
	
	/**
	 * ...
	 * @author ww
	 */
	public class Neuron {
		public static var neurons:int = 0;
		public static var squash:Object = Squash;
		public static function uid():int {
			return neurons++;
		}
		
		public static function quantity():Object {
			return {"neurons": neurons, "connections": Connection.connections}
		}
		
		public var ID:int;
		public var connections:Object;
		public var error:Object;
		public var trace:Object;
		public var state:int;
		public var old:Number;
		public var activation:Number;
		public var selfconnection:Connection;
		public var squash:Function;
		public var neighboors:Object;
		public var bias:Number;
		public var derivative:Number;
		public var label:String;
		
		public function Neuron() {
			this.ID = Neuron.uid();
			
			this.connections = {"inputs": {}, "projected": {}, "gated": {}};
			this.error = {"responsibility": 0, "projected": 0, "gated": 0};
			this.trace = {"elegibility": {}, "extended": {}, "influences": {}};
			this.state = 0;
			this.old = 0;
			this.activation = 0;
			this.selfconnection = new Connection(this, this, 0); // weight = 0 -> not connected
			this.squash = Neuron.squash.LOGISTIC;
			this.neighboors = {};
			this.bias = Math.random() * .2 - .1;
		}
		
		public function activate(input:* = null):Number {
			if (input != null) {
				this.activation = input as Number;
				this.derivative = 0;
				this.bias = 0;
				return this.activation;
			}
			
			// old state
			this.old = this.state;
			
// eq. 15
			this.state = this.selfconnection.gain * this.selfconnection.weight * this.state + this.bias;
			var i:String;
			
			for (i in this.connections.inputs) {
				var input:Object = this.connections.inputs[i];
				this.state += input.from.activation * input.weight * input.gain;
			}
			
			// eq. 16
			this.activation = this.squash(this.state);
			
			// f'(s)
			this.derivative = this.squash(this.state, true);
			
			// update traces
			var influences:Array = [];
			var id:String;
			for (id in this.trace.extended) {
				// extended elegibility trace
				var neuron:Neuron = this.neighboors[id];
				
				// if gated neuron's selfconnection is gated by this unit, the influence keeps track of the neuron's old state
				var influence:Number = neuron.selfconnection.gater == this ? neuron.old : 0;
				
				// index runs over all the incoming connections to the gated neuron that are gated by this unit
				for (var incoming:String in this.trace.influences[neuron.ID]) { // captures the effect that has an input connection to this unit, on a neuron that is gated by this unit
					influence += this.trace.influences[neuron.ID][incoming].weight * this.trace.influences[neuron.ID][incoming].from.activation;
				}
				influences[neuron.ID] = influence;
			}
			
			for (i in this.connections.inputs) {
				input = this.connections.inputs[i];
				
				// elegibility trace - Eq. 17
				this.trace.elegibility[input.ID] = this.selfconnection.gain * this.selfconnection.weight * this.trace.elegibility[input.ID] + input.gain * input.from.activation;
				
				for (id in this.trace.extended) {
					// extended elegibility trace
					var xtrace:Object = this.trace.extended[id];
					neuron = this.neighboors[id];
					influence = influences[neuron.ID];
					
					// eq. 18
					xtrace[input.ID] = neuron.selfconnection.gain * neuron.selfconnection.weight * xtrace[input.ID] + this.derivative * this.trace.elegibility[input.ID] * influence;
				}
			}
			
			//  update gated connection's gains
			for (var connection:String in this.connections.gated) {
				this.connections.gated[connection].gain = this.activation;
			}
			
			return this.activation;
		}
		
		public function propagate(rate:Number, target:* = null):void {
			// error accumulator
			var error:int = 0;
			
			// whether or not this neuron is in the output layer
			var isOutput:Boolean = !(target === null);
			
			var id:String;
			var input:*;
			var connection:Connection;
			var neuron:Neuron;
			// output neurons get their error from the enviroment
			if (isOutput) {
				this.error.responsibility = this.error.projected = target - this.activation; // Eq. 10
			}
			else // the rest of the neuron compute their error responsibilities by backpropagation
			{
				// error responsibilities from all the connections projected from this neuron
				for (id in this.connections.projected) {
					connection = this.connections.projected[id];
					neuron = connection.to;
					// Eq. 21
					error += neuron.error.responsibility * connection.gain * connection.weight;
				}
				
				// projected error responsibility
				this.error.projected = this.derivative * error;
				
				error = 0;
				// error responsibilities from all the connections gated by this neuron
				for (id in this.trace.extended) {
					neuron = this.neighboors[id]; // gated neuron
					var influence:Number = neuron.selfconnection.gater == this ? neuron.old : 0; // if gated neuron's selfconnection is gated by this neuron
					
					// index runs over all the connections to the gated neuron that are gated by this neuron
					for (input in this.trace.influences[id]) { // captures the effect that the input connection of this neuron have, on a neuron which its input/s is/are gated by this neuron
						influence += this.trace.influences[id][input].weight * this.trace.influences[neuron.ID][input].from.activation;
					}
					// eq. 22
					error += neuron.error.responsibility * influence;
				}
				
				// gated error responsibility
				this.error.gated = this.derivative * error;
				
				// error responsibility - Eq. 23
				this.error.responsibility = this.error.projected + this.error.gated;
			}
			
			// learning rate
			rate = rate || 0.1;
			
			// adjust all the neuron's incoming connections
			for (id in this.connections.inputs) {
				input = this.connections.inputs[id];
				
				// Eq. 24
				var gradient:Number = this.error.projected * this.trace.elegibility[input.ID];
				for (id in this.trace.extended) {
					neuron = this.neighboors[id];
					gradient += neuron.error.responsibility * this.trace.extended[neuron.ID][input.ID];
				}
				input.weight += rate * gradient; // adjust weights - aka learn
			}
			
			// adjust bias
			this.bias += rate * this.error.responsibility;
		}
		
		public function project(neuron:Neuron, weight:Number):Connection {
			// self-connection
			if (neuron == this) {
				this.selfconnection.weight = 1;
				return this.selfconnection;
			}
			
			// check if connection already exists
			var connected:Object = this.connected(neuron);
			if (connected && connected.type == 'projected') {
				// update connection
				if (typeof weight != 'undefined')
					connected.connection.weight = weight;
				// return existing connection
				return connected.connection;
			}
			else {
				// create a new connection
				var connection:Connection = new Connection(this, neuron, weight);
			}
			
			// reference all the connections and traces
			this.connections.projected[connection.ID] = connection;
			this.neighboors[neuron.ID] = neuron;
			neuron.connections.inputs[connection.ID] = connection;
			neuron.trace.elegibility[connection.ID] = 0;
			
			for (var id:String in neuron.trace.extended) {
				var ttrace:Object = neuron.trace.extended[id];
				ttrace[connection.ID] = 0;
			}
			
			return connection;
		}
		
		public function gate(connection:Connection):void {
			// add connection to gated list
			this.connections.gated[connection.ID] = connection;
			
			var neuron:Neuron = connection.to;
			if (!(neuron.ID in this.trace.extended)) {
				// extended trace
				this.neighboors[neuron.ID] = neuron;
				var xtrace:Object = this.trace.extended[neuron.ID] = {};
				for (var id:String in this.connections.inputs) {
					var input:Object = this.connections.inputs[id];
					xtrace[input.ID] = 0;
				}
			}
			// keep track
			if (neuron.ID in this.trace.influences)
				this.trace.influences[neuron.ID].push(connection);
			else
				this.trace.influences[neuron.ID] = [connection];
			
			// set gater
			connection.gater = this;
		}
		
		public function selfconnected():Boolean {
			return this.selfconnection.weight !== 0;
		}
		
		public function connected(neuron:Neuron):* {
			var result:Object = {type: null, connection: false};
			
			if (this == neuron) {
				if (this.selfconnected()) {
					result.type = 'selfconnection';
					result.connection = this.selfconnection;
					return result;
				}
				else
					return false;
			}
			
			for (var type:String in this.connections) {
				for (var connection:String in this.connections[type]) {
					var tconnection:Object = this.connections[type][connection];
					if (tconnection.to == neuron) {
						result.type = type;
						result.connection = tconnection;
						return result;
					}
					else if (tconnection.from == neuron) {
						result.type = type;
						result.connection = tconnection;
						return result;
					}
				}
			}
			
			return false;
		}
		
		public function clear():void {
			for (var ttrace:String in this.trace.elegibility) {
				this.trace.elegibility[ttrace] = 0;
			}
			
			for (ttrace in this.trace.extended) {
				for (var extended:String in this.trace.extended[ttrace]) {
					this.trace.extended[ttrace][extended] = 0;
				}
			}
			
			this.error.responsibility = this.error.projected = this.error.gated = 0;
		}
		
		public function reset():void {
			this.clear();
			
			for (var type:String in this.connections) {
				for (var connection:String in this.connections[type]) {
					this.connections[type][connection].weight = Math.random() * .2 - .1;
				}
			}
			
			this.bias = Math.random() * .2 - .1;
			this.old = this.state = this.activation = 0;
		}
		
		public function optimize(optimized:Object, layer:String):Object {
			
			optimized = optimized || {};
			var store_activation:Array = [];
			var store_trace:Array = [];
			var store_propagation:Array = [];
			var varID:int = optimized.memory || 0;
			var neurons:int = optimized.neurons || 1;
			var inputs:Array = optimized.inputs || [];
			var targets:Array = optimized.targets || [];
			var outputs:Array = optimized.outputs || [];
			var variables:Object = optimized.variables || {};
			var activation_sentences:Array = optimized.activation_sentences || [];
			var trace_sentences:Array = optimized.trace_sentences || [];
			var propagation_sentences:Array = optimized.propagation_sentences || [];
			var layers:Object = optimized.layers || {__count: 0, __neuron: 0};
			
			// allocate sentences
			var allocate:Function = function(store:Object):void {
				var allocated:Boolean = layer in layers && store[layers.__count];
				if (!allocated) {
					layers.__count = store.push([]) - 1;
					layers[layer] = layers.__count;
				}
			};
			allocate(activation_sentences);
			allocate(trace_sentences);
			allocate(propagation_sentences);
			var currentLayer:int = layers.__count;
			
			// get/reserve space in memory by creating a unique ID for a variablel
			var getVar:Function = function(...argList):Object {
				var args:Array = Array.prototype.slice.call(argList);
				
				if (args.length == 1) {
					if (args[0] == 'target') {
						var id:String = 'target_' + targets.length;
						targets.push(varID);
					}
					else
						id = args[0];
					if (id in variables)
						return variables[id];
					return variables[id] = {value: 0, id: varID++};
				}
				else {
					var extended:Boolean = args.length > 2;
					if (extended)
						var value:* = args.pop();
					
					var unit:Object = args.shift();
					var prop:String = args.pop();
					
					if (!extended)
						value = unit[prop];
					
					id = prop + '_';
					for (var i:int = 0; i < args.length; i++)
						id += args[i] + '_';
					id += unit.ID;
					if (id in variables)
						return variables[id];
					
					return variables[id] = {value: value, id: varID++};
				}
			};
			
			// build sentence
			var buildSentence:Function = function(...argList):void {
				var args:Array = Array.prototype.slice.call(argList);
				var store:Object = args.pop();
				var sentence:String = '';
				for (var i:int = 0; i < args.length; i++)
					if (typeof args[i] == 'string')
						sentence += args[i];
					else
						sentence += 'F[' + args[i].id + ']';
				
				store.push(sentence + ';');
			};
			
			// helper to check if an object is empty
			var isEmpty:Function = function(obj:Object):Boolean {
				for (var prop:String in obj) {
					if (obj.hasOwnProperty(prop))
						return false;
				}
				return true;
			};
			
			// characteristics of the neuron
			var noProjections:Boolean = isEmpty(this.connections.projected);
			var noGates:Boolean = isEmpty(this.connections.gated);
			var isInput:Boolean = layer == 'input' ? true : isEmpty(this.connections.inputs);
			var isOutput:Boolean = layer == 'output' ? true : noProjections && noGates;
			
			// optimize neuron's behaviour
			var rate:* = getVar('rate');
			var activation:* = getVar(this, 'activation');
			if (isInput)
				inputs.push(activation.id);
			else {
				activation_sentences[currentLayer].push(store_activation);
				trace_sentences[currentLayer].push(store_trace);
				propagation_sentences[currentLayer].push(store_propagation);
				var old:Number = getVar(this, 'old');
				var state:int = getVar(this, 'state');
				var bias:Number = getVar(this, 'bias');
				if (this.selfconnection.gater)
					var self_gain:* = getVar(this.selfconnection, 'gain');
				if (this.selfconnected())
					var self_weight:Number = getVar(this.selfconnection, 'weight');
				buildSentence(old, ' = ', state, store_activation);
				if (this.selfconnected())
					if (this.selfconnection.gater)
						buildSentence(state, ' = ', self_gain, ' * ', self_weight, ' * ', state, ' + ', bias, store_activation);
					else
						buildSentence(state, ' = ', self_weight, ' * ', state, ' + ', bias, store_activation);
				else
					buildSentence(state, ' = ', bias, store_activation);
				for (var i:String in this.connections.inputs) {
					var input:Object = this.connections.inputs[i];
					var input_activation:Function = getVar(input.from, 'activation');
					var input_weight:Number = getVar(input, 'weight');
					if (input.gater)
						var input_gain:Number = getVar(input, 'gain');
					if (this.connections.inputs[i].gater)
						buildSentence(state, ' += ', input_activation, ' * ', input_weight, ' * ', input_gain, store_activation);
					else
						buildSentence(state, ' += ', input_activation, ' * ', input_weight, store_activation);
				}
				var derivative:Number = getVar(this, 'derivative');
				switch (this.squash) {
					case Neuron.squash.LOGISTIC: 
						buildSentence(activation, ' = (1 / (1 + Math.exp(-', state, ')))', store_activation);
						buildSentence(derivative, ' = ', activation, ' * (1 - ', activation, ')', store_activation);
						break;
					case Neuron.squash.TANH: 
						var eP:Number = getVar('aux');
						var eN:Number = getVar('aux_2');
						buildSentence(eP, ' = Math.exp(', state, ')', store_activation);
						buildSentence(eN, ' = 1 / ', eP, store_activation);
						buildSentence(activation, ' = (', eP, ' - ', eN, ') / (', eP, ' + ', eN, ')', store_activation);
						buildSentence(derivative, ' = 1 - (', activation, ' * ', activation, ')', store_activation);
						break;
					case Neuron.squash.IDENTITY: 
						buildSentence(activation, ' = ', state, store_activation);
						buildSentence(derivative, ' = 1', store_activation);
						break;
					case Neuron.squash.HLIM: 
						buildSentence(activation, ' = +(', state, ' > 0)', store_activation);
						buildSentence(derivative, ' = 1', store_activation);
						break;
					case Neuron.squash.RELU: 
						buildSentence(activation, ' = ', state, ' > 0 ? ', state, ' : 0', store_activation);
						buildSentence(derivative, ' = ', state, ' > 0 ? 1 : 0', store_activation);
						break;
				}
				
				for (var id:String in this.trace.extended) {
					// calculate extended elegibility traces in advance
					var neuron:Neuron = this.neighboors[id];
					var influence:Number = getVar('influences[' + neuron.ID + ']');
					var neuron_old:Number = getVar(neuron, 'old');
					var initialized:Boolean = false;
					if (neuron.selfconnection.gater == this) {
						buildSentence(influence, ' = ', neuron_old, store_trace);
						initialized = true;
					}
					for (var incoming:String in this.trace.influences[neuron.ID]) {
						var incoming_weight:Number = getVar(this.trace.influences[neuron.ID][incoming], 'weight');
						var incoming_activation:Function = getVar(this.trace.influences[neuron.ID][incoming].from, 'activation');
						
						if (initialized)
							buildSentence(influence, ' += ', incoming_weight, ' * ', incoming_activation, store_trace);
						else {
							buildSentence(influence, ' = ', incoming_weight, ' * ', incoming_activation, store_trace);
							initialized = true;
						}
					}
				}
				
				for (i in this.connections.inputs) {
					input = this.connections.inputs[i];
					if (input.gater)
						input_gain = getVar(input, 'gain');
					input_activation = getVar(input.from, 'activation');
					var trace:String = getVar(this, 'trace', 'elegibility', input.ID, this.trace.elegibility[input.ID]);
					if (this.selfconnected()) {
						if (this.selfconnection.gater) {
							if (input.gater)
								buildSentence(trace, ' = ', self_gain, ' * ', self_weight, ' * ', trace, ' + ', input_gain, ' * ', input_activation, store_trace);
							else
								buildSentence(trace, ' = ', self_gain, ' * ', self_weight, ' * ', trace, ' + ', input_activation, store_trace);
						}
						else {
							if (input.gater)
								buildSentence(trace, ' = ', self_weight, ' * ', trace, ' + ', input_gain, ' * ', input_activation, store_trace);
							else
								buildSentence(trace, ' = ', self_weight, ' * ', trace, ' + ', input_activation, store_trace);
						}
					}
					else {
						if (input.gater)
							buildSentence(trace, ' = ', input_gain, ' * ', input_activation, store_trace);
						else
							buildSentence(trace, ' = ', input_activation, store_trace);
					}
					for (id in this.trace.extended) {
						// extended elegibility trace
						neuron = this.neighboors[id];
						influence = getVar('influences[' + neuron.ID + ']');
						
						trace = getVar(this, 'trace', 'elegibility', input.ID, this.trace.elegibility[input.ID]);
						var xtrace:Object = getVar(this, 'trace', 'extended', neuron.ID, input.ID, this.trace.extended[neuron.ID][input.ID]);
						if (neuron.selfconnected())
							var neuron_self_weight:Number = getVar(neuron.selfconnection, 'weight');
						if (neuron.selfconnection.gater)
							var neuron_self_gain:Number = getVar(neuron.selfconnection, 'gain');
						if (neuron.selfconnected())
							if (neuron.selfconnection.gater)
								buildSentence(xtrace, ' = ', neuron_self_gain, ' * ', neuron_self_weight, ' * ', xtrace, ' + ', derivative, ' * ', trace, ' * ', influence, store_trace);
							else
								buildSentence(xtrace, ' = ', neuron_self_weight, ' * ', xtrace, ' + ', derivative, ' * ', trace, ' * ', influence, store_trace);
						else
							buildSentence(xtrace, ' = ', derivative, ' * ', trace, ' * ', influence, store_trace);
					}
				}
				for (var connection:* in this.connections.gated) {
					var gated_gain:* = getVar(this.connections.gated[connection], 'gain');
					buildSentence(gated_gain, ' = ', activation, store_activation);
				}
			}
			if (!isInput) {
				var responsibility:* = getVar(this, 'error', 'responsibility', this.error.responsibility);
				if (isOutput) {
					var target:* = getVar('target');
					buildSentence(responsibility, ' = ', target, ' - ', activation, store_propagation);
					for (id in this.connections.inputs) {
						input = this.connections.inputs[id];
						trace = getVar(this, 'trace', 'elegibility', input.ID, this.trace.elegibility[input.ID]);
						input_weight = getVar(input, 'weight');
						buildSentence(input_weight, ' += ', rate, ' * (', responsibility, ' * ', trace, ')', store_propagation);
					}
					outputs.push(activation.id);
				}
				else {
					if (!noProjections && !noGates) {
						var error:* = getVar('aux');
						for (id in this.connections.projected) {
							connection = this.connections.projected[id];
							neuron = connection.to;
							var connection_weight:* = getVar(connection, 'weight');
							var neuron_responsibility:* = getVar(neuron, 'error', 'responsibility', neuron.error.responsibility);
							if (connection.gater) {
								var connection_gain:* = getVar(connection, 'gain');
								buildSentence(error, ' += ', neuron_responsibility, ' * ', connection_gain, ' * ', connection_weight, store_propagation);
							}
							else
								buildSentence(error, ' += ', neuron_responsibility, ' * ', connection_weight, store_propagation);
						}
						var projected:* = getVar(this, 'error', 'projected', this.error.projected);
						buildSentence(projected, ' = ', derivative, ' * ', error, store_propagation);
						buildSentence(error, ' = 0', store_propagation);
						for (id in this.trace.extended) {
							neuron = this.neighboors[id];
							influence = getVar('aux_2');
							neuron_old = getVar(neuron, 'old');
							if (neuron.selfconnection.gater == this)
								buildSentence(influence, ' = ', neuron_old, store_propagation);
							else
								buildSentence(influence, ' = 0', store_propagation);
							for (input in this.trace.influences[neuron.ID]) {
								connection = this.trace.influences[neuron.ID][input];
								connection_weight = getVar(connection, 'weight');
								var neuron_activation:* = getVar(connection.from, 'activation');
								buildSentence(influence, ' += ', connection_weight, ' * ', neuron_activation, store_propagation);
							}
							neuron_responsibility = getVar(neuron, 'error', 'responsibility', neuron.error.responsibility);
							buildSentence(error, ' += ', neuron_responsibility, ' * ', influence, store_propagation);
						}
						var gated:* = getVar(this, 'error', 'gated', this.error.gated);
						buildSentence(gated, ' = ', derivative, ' * ', error, store_propagation);
						buildSentence(responsibility, ' = ', projected, ' + ', gated, store_propagation);
						for (id in this.connections.inputs) {
							input = this.connections.inputs[id];
							var gradient:* = getVar('aux');
							trace = getVar(this, 'trace', 'elegibility', input.ID, this.trace.elegibility[input.ID]);
							buildSentence(gradient, ' = ', projected, ' * ', trace, store_propagation);
							for (id in this.trace.extended) {
								neuron = this.neighboors[id];
								neuron_responsibility = getVar(neuron, 'error', 'responsibility', neuron.error.responsibility);
								xtrace = getVar(this, 'trace', 'extended', neuron.ID, input.ID, this.trace.extended[neuron.ID][input.ID]);
								buildSentence(gradient, ' += ', neuron_responsibility, ' * ', xtrace, store_propagation);
							}
							input_weight = getVar(input, 'weight');
							buildSentence(input_weight, ' += ', rate, ' * ', gradient, store_propagation);
						}
						
					}
					else if (noGates) {
						buildSentence(responsibility, ' = 0', store_propagation);
						for (id in this.connections.projected) {
							connection = this.connections.projected[id];
							neuron = connection.to;
							connection_weight = getVar(connection, 'weight');
							neuron_responsibility = getVar(neuron, 'error', 'responsibility', neuron.error.responsibility);
							if (connection.gater) {
								connection_gain = getVar(connection, 'gain');
								buildSentence(responsibility, ' += ', neuron_responsibility, ' * ', connection_gain, ' * ', connection_weight, store_propagation);
							}
							else
								buildSentence(responsibility, ' += ', neuron_responsibility, ' * ', connection_weight, store_propagation);
						}
						buildSentence(responsibility, ' *= ', derivative, store_propagation);
						for (id in this.connections.inputs) {
							input = this.connections.inputs[id];
							trace = getVar(this, 'trace', 'elegibility', input.ID, this.trace.elegibility[input.ID]);
							input_weight = getVar(input, 'weight');
							buildSentence(input_weight, ' += ', rate, ' * (', responsibility, ' * ', trace, ')', store_propagation);
						}
					}
					else if (noProjections) {
						buildSentence(responsibility, ' = 0', store_propagation);
						for (id in this.trace.extended) {
							neuron = this.neighboors[id];
							influence = getVar('aux');
							neuron_old = getVar(neuron, 'old');
							if (neuron.selfconnection.gater == this)
								buildSentence(influence, ' = ', neuron_old, store_propagation);
							else
								buildSentence(influence, ' = 0', store_propagation);
							for (input in this.trace.influences[neuron.ID]) {
								connection = this.trace.influences[neuron.ID][input];
								connection_weight = getVar(connection, 'weight');
								neuron_activation = getVar(connection.from, 'activation');
								buildSentence(influence, ' += ', connection_weight, ' * ', neuron_activation, store_propagation);
							}
							neuron_responsibility = getVar(neuron, 'error', 'responsibility', neuron.error.responsibility);
							buildSentence(responsibility, ' += ', neuron_responsibility, ' * ', influence, store_propagation);
						}
						buildSentence(responsibility, ' *= ', derivative, store_propagation);
						for (id in this.connections.inputs) {
							input = this.connections.inputs[id];
							gradient = getVar('aux');
							buildSentence(gradient, ' = 0', store_propagation);
							for (id in this.trace.extended) {
								neuron = this.neighboors[id];
								neuron_responsibility = getVar(neuron, 'error', 'responsibility', neuron.error.responsibility);
								xtrace = getVar(this, 'trace', 'extended', neuron.ID, input.ID, this.trace.extended[neuron.ID][input.ID]);
								buildSentence(gradient, ' += ', neuron_responsibility, ' * ', xtrace, store_propagation);
							}
							input_weight = getVar(input, 'weight');
							buildSentence(input_weight, ' += ', rate, ' * ', gradient, store_propagation);
						}
					}
				}
				buildSentence(bias, ' += ', rate, ' * ', responsibility, store_propagation);
			}
			return {memory: varID, neurons: neurons + 1, inputs: inputs, outputs: outputs, targets: targets, variables: variables, activation_sentences: activation_sentences, trace_sentences: trace_sentences, propagation_sentences: propagation_sentences, layers: layers}
		}
		
		
	
	}

}