package oneway.nn {
	
	/**
	 * ...
	 * @author ww
	 */
	public class NetWork {
		
		public static function getWorkerSharedFunctions() {
			// If we already computed the source code for the shared functions
			if (typeof NetWork._SHARED_WORKER_FUNCTIONS !== 'undefined')
				return NetWork._SHARED_WORKER_FUNCTIONS;
			
			// Otherwise compute and return the source code
			// We compute them by simply copying the source code of the train, _trainSet and test functions
			//  using the .toString() method
			
			// Load and name the train function
			var train_f = Trainer.prototype.train.toString();
			train_f = train_f.replace(/this._trainSet/g, '_trainSet');
			train_f = train_f.replace(/this.test/g, 'test');
			train_f = train_f.replace(/this.crossValidate/g, 'crossValidate');
			train_f = train_f.replace('crossValidate = true', '// REMOVED BY WORKER');
			
			// Load and name the _trainSet function
			var _trainSet_f = Trainer.prototype._trainSet.toString().replace(/this.network./g, '');
			
			// Load and name the test function
			var test_f = Trainer.prototype.test.toString().replace(/this.network./g, '');
			
			return NetWork._SHARED_WORKER_FUNCTIONS = train_f + '\n' + _trainSet_f + '\n' + test_f;
		}
		
		public static function fromJSON(json) {
			var neurons = [];
			
			var layers = {input: new Layer(), hidden: [], output: new Layer()};
			
			for (var i = 0; i < json.neurons.length; i++) {
				var config = json.neurons[i];
				
				var neuron = new Neuron();
				neuron.trace.elegibility = {};
				neuron.trace.extended = {};
				neuron.state = config.state;
				neuron.old = config.old;
				neuron.activation = config.activation;
				neuron.bias = config.bias;
				neuron.squash = config.squash in Neuron.squash ? Neuron.squash[config.squash] : Neuron.squash.LOGISTIC;
				neurons.push(neuron);
				
				if (config.layer == 'input')
					layers.input.add(neuron);
				else if (config.layer == 'output')
					layers.output.add(neuron);
				else {
					if (typeof layers.hidden[config.layer] == 'undefined')
						layers.hidden[config.layer] = new Layer();
					layers.hidden[config.layer].add(neuron);
				}
			}
			
			for (var i = 0; i < json.connections.length; i++) {
				var config = json.connections[i];
				var from = neurons[config.from];
				var to = neurons[config.to];
				var weight = config.weight;
				var gater = neurons[config.gater];
				
				var connection = from.project(to, weight);
				if (gater)
					gater.gate(connection);
			}
			
			return new NetWork(layers);
		}
		
		public var layers:Object;
		public var optimized:Object;
		public var trainer:Trainer;
		public function NetWork(layers:Object = null) {
			if (layers) {
				this.layers = {input: layers.input || null, hidden: layers.hidden || [], output: layers.output || null};
				this.optimized = null;
			}
		}
		
		public function activate(input:Array):* {
			if (this.optimized === false) {
				this.layers.input.activate(input);
				for (var i = 0; i < this.layers.hidden.length; i++)
					this.layers.hidden[i].activate();
				return this.layers.output.activate();
			}
			else {
				if (this.optimized == null)
					this.optimize();
				return this.optimized.activate(input);
			}
		}
		
		public function propagate(rate, target):void {
			if (this.optimized === false) {
				this.layers.output.propagate(rate, target);
				for (var i = this.layers.hidden.length - 1; i >= 0; i--)
					this.layers.hidden[i].propagate(rate);
			}
			else {
				if (this.optimized == null)
					this.optimize();
				this.optimized.propagate(rate, target);
			}
		}
		
		public function project(unit, type, weights):* {
			if (this.optimized)
				this.optimized.reset();
			
			if (unit instanceof NetWork)
				return this.layers.output.project(unit.layers.input, type, weights);
			
			if (unit instanceof Layer)
				return this.layers.output.project(unit, type, weights);
			
			throw new Error('Invalid argument, you can only project connections to LAYERS and NETWORKS!');
		}
		
		public function clear():void {
			this.restore();
			
			var inputLayer = this.layers.input, outputLayer = this.layers.output;
			
			inputLayer.clear();
			for (var i = 0; i < this.layers.hidden.length; i++) {
				this.layers.hidden[i].clear();
			}
			outputLayer.clear();
			
			if (this.optimized)
				this.optimized.reset();
		}
		
		public function reset():void {
			this.restore();
			
			var inputLayer = this.layers.input, outputLayer = this.layers.output;
			
			inputLayer.reset();
			for (var i = 0; i < this.layers.hidden.length; i++) {
				this.layers.hidden[i].reset();
			}
			outputLayer.reset();
			
			if (this.optimized)
				this.optimized.reset();
		}
		
		public function optimize():void {
			var that = this;
			var optimized = {};
			var neurons = this.neurons();
			
			for (var i = 0; i < neurons.length; i++) {
				var neuron = neurons[i].neuron;
				var layer = neurons[i].layer;
				while (neuron.neuron)
					neuron = neuron.neuron;
				optimized = neuron.optimize(optimized, layer);
			}
			
			for (var i = 0; i < optimized.propagation_sentences.length; i++)
				optimized.propagation_sentences[i].reverse();
			optimized.propagation_sentences.reverse();
			
			var hardcode = '';
			hardcode += 'var F = Float64Array ? new Float64Array(' + optimized.memory + ') : []; ';
			for (var i in optimized.variables)
				hardcode += 'F[' + optimized.variables[i].id + '] = ' + (optimized.variables[i].value || 0) + '; ';
			hardcode += 'var activate = function(input){\n';
			for (var i = 0; i < optimized.inputs.length; i++)
				hardcode += 'F[' + optimized.inputs[i] + '] = input[' + i + ']; ';
			for (var i = 0; i < optimized.activation_sentences.length; i++) {
				if (optimized.activation_sentences[i].length > 0) {
					for (var j = 0; j < optimized.activation_sentences[i].length; j++) {
						hardcode += optimized.activation_sentences[i][j].join(' ');
						hardcode += optimized.trace_sentences[i][j].join(' ');
					}
				}
			}
			hardcode += ' var output = []; '
			for (var i = 0; i < optimized.outputs.length; i++)
				hardcode += 'output[' + i + '] = F[' + optimized.outputs[i] + ']; ';
			hardcode += 'return output; }; '
			hardcode += 'var propagate = function(rate, target){\n';
			hardcode += 'F[' + optimized.variables.rate.id + '] = rate; ';
			for (var i = 0; i < optimized.targets.length; i++)
				hardcode += 'F[' + optimized.targets[i] + '] = target[' + i + ']; ';
			for (var i = 0; i < optimized.propagation_sentences.length; i++)
				for (var j = 0; j < optimized.propagation_sentences[i].length; j++)
					hardcode += optimized.propagation_sentences[i][j].join(' ') + ' ';
			hardcode += ' };\n';
			hardcode += 'var ownership = function(memoryBuffer){\nF = memoryBuffer;\nthis.memory = F;\n};\n';
			hardcode += 'return {\nmemory: F,\nactivate: activate,\npropagate: propagate,\nownership: ownership\n};';
			hardcode = hardcode.split(';').join(';\n');
			
			var constructor = new Function(hardcode);
			
			var network = constructor();
			network.data = {variables: optimized.variables, activate: optimized.activation_sentences, propagate: optimized.propagation_sentences, trace: optimized.trace_sentences, inputs: optimized.inputs, outputs: optimized.outputs, check_activation: this.activate, check_propagation: this.propagate}
			
			network.reset = function() {
				if (that.optimized) {
					that.optimized = null;
					that.activate = network.data.check_activation;
					that.propagate = network.data.check_propagation;
				}
			}
			
			this.optimized = network;
			this.activate = network.activate;
			this.propagate = network.propagate;
		}
		
		public function restore() {
			if (!this.optimized)
				return;
			
			var optimized = this.optimized;
			
			var getValue = function() {
				var args = Array.prototype.slice.call(arguments);
				
				var unit = args.shift();
				var prop = args.pop();
				
				var id = prop + '_';
				for (var property in args)
					id += args[property] + '_';
				id += unit.ID;
				
				var memory = optimized.memory;
				var variables = optimized.data.variables;
				
				if (id in variables)
					return memory[variables[id].id];
				return 0;
			}
			
			var list = this.neurons();
			
			// link id's to positions in the array
			for (var i = 0; i < list.length; i++) {
				var neuron = list[i].neuron;
				while (neuron.neuron)
					neuron = neuron.neuron;
				
				neuron.state = getValue(neuron, 'state');
				neuron.old = getValue(neuron, 'old');
				neuron.activation = getValue(neuron, 'activation');
				neuron.bias = getValue(neuron, 'bias');
				
				for (var input in neuron.trace.elegibility)
					neuron.trace.elegibility[input] = getValue(neuron, 'trace', 'elegibility', input);
				
				for (var gated in neuron.trace.extended)
					for (var input in neuron.trace.extended[gated])
						neuron.trace.extended[gated][input] = getValue(neuron, 'trace', 'extended', gated, input);
				
				// get connections
				for (var j in neuron.connections.projected) {
					var connection = neuron.connections.projected[j];
					connection.weight = getValue(connection, 'weight');
					connection.gain = getValue(connection, 'gain');
				}
			}
		}
		
		public function neurons():Array {
			var neurons = [];
			
			var inputLayer = this.layers.input.neurons(), outputLayer = this.layers.output.neurons();
			
			for (var i = 0; i < inputLayer.length; i++) {
				neurons.push({neuron: inputLayer[i], layer: 'input'});
			}
			
			for (var i = 0; i < this.layers.hidden.length; i++) {
				var hiddenLayer = this.layers.hidden[i].neurons();
				for (var j = 0; j < hiddenLayer.length; j++)
					neurons.push({neuron: hiddenLayer[j], layer: i});
			}
			
			for (var i = 0; i < outputLayer.length; i++) {
				neurons.push({neuron: outputLayer[i], layer: 'output'});
			}
			
			return neurons;
		}
		
		public function inputs() {
			return this.layers.input.size;
		}
		
		public function outputs() {
			return this.layers.output.size;
		}
		
		public function set(layers) {
			this.layers = {input: layers.input || null, hidden: layers.hidden || [], output: layers.output || null};
			if (this.optimized)
				this.optimized.reset();
		}
		
		public function setOptimize(bool) {
			this.restore();
			if (this.optimized)
				this.optimized.reset();
			this.optimized = bool ? null : false;
		}
		
		public function toJSON(ignoreTraces) {
			this.restore();
			
			var list = this.neurons();
			var neurons = [];
			var connections = [];
			
			// link id's to positions in the array
			var ids = {};
			for (var i = 0; i < list.length; i++) {
				var neuron = list[i].neuron;
				while (neuron.neuron)
					neuron = neuron.neuron;
				ids[neuron.ID] = i;
				
				var copy = {"trace": {elegibility: {}, extended: {}}, state: neuron.state, old: neuron.old, activation: neuron.activation, bias: neuron.bias, layer: list[i].layer};
				
				copy.squash = neuron.squash == Neuron.squash.LOGISTIC ? 'LOGISTIC' : neuron.squash == Neuron.squash.TANH ? 'TANH' : neuron.squash == Neuron.squash.IDENTITY ? 'IDENTITY' : neuron.squash == Neuron.squash.HLIM ? 'HLIM' : neuron.squash == Neuron.squash.RELU ? 'RELU' : null;
				
				neurons.push(copy);
			}
			
			for (var i = 0; i < list.length; i++) {
				var neuron = list[i].neuron;
				while (neuron.neuron)
					neuron = neuron.neuron;
				
				for (var j in neuron.connections.projected) {
					var connection = neuron.connections.projected[j];
					connections.push({"from": ids[connection.from.ID], "to": ids[connection.to.ID], "weight": connection.weight, "gater": connection.gater ? ids[connection.gater.ID] : null});
				}
				if (neuron.selfconnected()) {
					connections.push({from: ids[neuron.ID], to: ids[neuron.ID], weight: neuron.selfconnection.weight, gater: neuron.selfconnection.gater ? ids[neuron.selfconnection.gater.ID] : null});
				}
			}
			
			return {neurons: neurons, connections: connections}
		}
		
		public function toDot(edgeConnection) {
			if (!typeof edgeConnection)
				edgeConnection = false;
			var code = 'digraph nn {\n    rankdir = BT\n';
			var layers = [this.layers.input].concat(this.layers.hidden, this.layers.output);
			for (var i = 0; i < layers.length; i++) {
				for (var j = 0; j < layers[i].connectedTo.length; j++) { // projections
					var connection = layers[i].connectedTo[j];
					var layerTo = connection.to;
					var size = connection.size;
					var layerID = layers.indexOf(layers[i]);
					var layerToID = layers.indexOf(layerTo);
					/* http://stackoverflow.com/questions/26845540/connect-edges-with-graph-dot
					 * DOT does not support edge-to-edge connections
					 * This workaround produces somewhat weird graphs ...
					 */
					if (edgeConnection) {
						if (connection.gatedfrom.length) {
							var fakeNode = 'fake' + layerID + '_' + layerToID;
							code += '    ' + fakeNode + ' [label = "", shape = point, width = 0.01, height = 0.01]\n';
							code += '    ' + layerID + ' -> ' + fakeNode + ' [label = ' + size + ', arrowhead = none]\n';
							code += '    ' + fakeNode + ' -> ' + layerToID + '\n';
						}
						else
							code += '    ' + layerID + ' -> ' + layerToID + ' [label = ' + size + ']\n';
						for (var from in connection.gatedfrom) { // gatings
							var layerfrom = connection.gatedfrom[from].layer;
							var layerfromID = layers.indexOf(layerfrom);
							code += '    ' + layerfromID + ' -> ' + fakeNode + ' [color = blue]\n';
						}
					}
					else {
						code += '    ' + layerID + ' -> ' + layerToID + ' [label = ' + size + ']\n';
						for (var from in connection.gatedfrom) { // gatings
							var layerfrom = connection.gatedfrom[from].layer;
							var layerfromID = layers.indexOf(layerfrom);
							code += '    ' + layerfromID + ' -> ' + layerToID + ' [color = blue]\n';
						}
					}
				}
			}
			code += '}\n';
			return {code: code, link: 'https://chart.googleapis.com/chart?chl=' + escape(code.replace('/ /g', '+')) + '&cht=gv'}
		}
		
		public function standalone() {
			if (!this.optimized)
				this.optimize();
			
			var data = this.optimized.data;
			
			// build activation function
			var activation = 'function (input) {\n';
			
			// build inputs
			for (var i = 0; i < data.inputs.length; i++)
				activation += 'F[' + data.inputs[i] + '] = input[' + i + '];\n';
			
			// build network activation
			for (var i = 0; i < data.activate.length; i++) { // shouldn't this be layer?
				for (var j = 0; j < data.activate[i].length; j++)
					activation += data.activate[i][j].join('') + '\n';
			}
			
			// build outputs
			activation += 'var output = [];\n';
			for (var i = 0; i < data.outputs.length; i++)
				activation += 'output[' + i + '] = F[' + data.outputs[i] + '];\n';
			activation += 'return output;\n}';
			
			// reference all the positions in memory
			var memory = activation.match(/F\[(\d+)\]/g);
			var dimension = 0;
			var ids = {};
			
			for (var i = 0; i < memory.length; i++) {
				var tmp = memory[i].match(/\d+/)[0];
				if (!(tmp in ids)) {
					ids[tmp] = dimension++;
				}
			}
			var hardcode = 'F = {\n';
			
			for (var i in ids)
				hardcode += ids[i] + ': ' + this.optimized.memory[i] + ',\n';
			hardcode = hardcode.substring(0, hardcode.length - 2) + '\n};\n';
			hardcode = 'var run = ' + activation.replace(/F\[(\d+)]/g, function(index) {
					return 'F[' + ids[index.match(/\d+/)[0]] + ']'
				}).replace('{\n', '{\n' + hardcode + '') + ';\n';
			hardcode += 'return run';
			
			// return standalone function
			return new Function(hardcode)();
		}
		
		public function worker(memory, set, options) {
			// Copy the options and set defaults (options might be different for each worker)
			var workerOptions = {};
			if (options)
				workerOptions = options;
			workerOptions.rate = workerOptions.rate || .2;
			workerOptions.iterations = workerOptions.iterations || 100000;
			workerOptions.error = workerOptions.error || .005;
			workerOptions.cost = workerOptions.cost || null;
			workerOptions.crossValidate = workerOptions.crossValidate || null;
			
			// Cost function might be different for each worker
			var costFunction = '// REPLACED BY WORKER\nvar cost = ' + (options && options.cost || this.cost || Trainer.cost.MSE) + ';\n';
			var workerFunction = NetWork.getWorkerSharedFunctions();
			workerFunction = workerFunction.replace(/var cost = options && options\.cost \|\| this\.cost \|\| Trainer\.cost\.MSE;/g, costFunction);
			
			// Set what we do when training is finished
			workerFunction = workerFunction.replace('return results;', 'postMessage({action: "done", message: results, memoryBuffer: F}, [F.buffer]);');
			
			// Replace log with postmessage
			workerFunction = workerFunction.replace('console.log(\'iterations\', iterations, \'error\', error, \'rate\', currentRate)', 'postMessage({action: \'log\', message: {\n' + 'iterations: iterations,\n' + 'error: error,\n' + 'rate: currentRate\n' + '}\n' + '})');
			
			// Replace schedule with postmessage
			workerFunction = workerFunction.replace('abort = this.schedule.do({ error: error, iterations: iterations, rate: currentRate })', 'postMessage({action: \'schedule\', message: {\n' + 'iterations: iterations,\n' + 'error: error,\n' + 'rate: currentRate\n' + '}\n' + '})');
			
			if (!this.optimized)
				this.optimize();
			
			var hardcode = 'var inputs = ' + this.optimized.data.inputs.length + ';\n';
			hardcode += 'var outputs = ' + this.optimized.data.outputs.length + ';\n';
			hardcode += 'var F =  new Float64Array([' + this.optimized.memory.toString() + ']);\n';
			hardcode += 'var activate = ' + this.optimized.activate.toString() + ';\n';
			hardcode += 'var propagate = ' + this.optimized.propagate.toString() + ';\n';
			hardcode += 'onmessage = function(e) {\n' + 'if (e.data.action == \'startTraining\') {\n' + 'train(' + JSON.stringify(set) + ',' + JSON.stringify(workerOptions) + ');\n' + '}\n' + '}';
			
			var workerSourceCode = workerFunction + '\n' + hardcode;
			var blob = new Blob([workerSourceCode]);
			var blobURL = window.URL.createObjectURL(blob);
			
			return new Worker(blobURL);
		}
		
		public function clone() {
			return NetWork.fromJSON(this.toJSON());
		}
	
	}

}