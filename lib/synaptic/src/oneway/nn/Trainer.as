package oneway.nn {
	
	/**
	 * ...
	 * @author ww
	 */
	public class Trainer {
		public static function shuffleInplace(o:Array):Array { //v1.0
			for (var j:int, x:int, i:int = o.length; i; j = Math.floor(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x) {
			}
			return o;
		}
		public static var cost:Object = Cost;
		
		public var network:NetWork;
		public var rate:*;
		public var iterations:int;
		public var error:Number;
		public var cost:Function;
		public var crossValidate:*;
		public var schedule:*;
		
		public function Trainer(network:NetWork, options:Object = null) {
			options = options || {};
			this.network = network;
			this.rate = options.rate || .2;
			this.iterations = options.iterations || 100000;
			this.error = options.error || .005;
			this.cost = options.cost || null;
			this.crossValidate = options.crossValidate || null;
		}
		
		public function train(set:Array, options:Object = null):* {
			var error:int = 1;
			var bucketSize:int = 0;
			var iterations:int = 0;
			var abort:Boolean = false;
			var currentRate:Number;
			var cost:Function = options && options.cost || this.cost || Trainer.cost.MSE;
			var crossValidate:Boolean = false, testSet:Array, trainSet:Array;
			
			var start:Number = NNTools.now();
			
			if (options) {
				if (options.iterations)
					this.iterations = options.iterations;
				if (options.error)
					this.error = options.error;
				if (options.rate)
					this.rate = options.rate;
				if (options.cost)
					this.cost = options.cost;
				if (options.schedule)
					this.schedule = options.schedule;
				if (options.customLog) {
					// for backward compatibility with code that used customLog
					console.log('Deprecated: use schedule instead of customLog')
					this.schedule = options.customLog;
				}
				if (this.crossValidate || options.crossValidate) {
					if (!this.crossValidate)
						this.crossValidate = {};
					crossValidate = true;
					if (options.crossValidate.testSize)
						this.crossValidate.testSize = options.crossValidate.testSize;
					if (options.crossValidate.testError)
						this.crossValidate.testError = options.crossValidate.testError;
				}
			}
			
			currentRate = this.rate;
			if (this.rate is Array) {
				bucketSize = Math.floor(this.iterations / this.rate.length);
			}
			
			if (crossValidate) {
				var numTrain:int = Math.ceil((1 - this.crossValidate.testSize) * set.length);
				trainSet = set.slice(0, numTrain);
				testSet = set.slice(numTrain);
			}
			
			var lastError:int = 0;
			while ((!abort && iterations < this.iterations && error > this.error)) {
				if (crossValidate && error <= this.crossValidate.testError) {
					break;
				}
				
				var currentSetSize:int = set.length;
				error = 0;
				iterations++;
				
				if (bucketSize > 0) {
					var currentBucket:int = Math.floor(iterations / bucketSize);
					currentRate = this.rate[currentBucket] || currentRate;
				}
				
				if (typeof this.rate === 'function') {
					currentRate = this.rate(iterations, lastError);
				}
				
				if (crossValidate) {
					this._trainSet(trainSet, currentRate, cost);
					error += this.test(testSet).error;
					currentSetSize = 1;
				}
				else {
					error += this._trainSet(set, currentRate, cost);
					currentSetSize = set.length;
				}
				
				// check error
				error /= currentSetSize;
				lastError = error;
				
				if (options) {
					if (this.schedule && this.schedule.every && iterations % this.schedule.every == 0)
						abort = this.schedule["do"]({error: error, iterations: iterations, rate: currentRate});
					else if (options.log && iterations % options.log == 0) {
						console.log('iterations', iterations, 'error', error, 'rate', currentRate);
					}
					;
					if (options.shuffle)
						shuffleInplace(set);
				}
			}
			
			var results:Object = {error: error, iterations: iterations, time: NNTools.now() - start};
			
			return results;
		}
		
		public function trainAsync(set:Array, options:Object):Promise {
			//var train = this.workerTrain.bind(this);
			var train:Function = NNTools.bind(this.workerTrain, this);
			return new Promise(function(resolve:Function, reject:Function):* {
					try {
						train(set, resolve, options, true)
					}
					catch (e:*) {
						reject(e)
					}
				})
		}
		
		public function _trainSet(set:Array, currentRate:Number, costFunction:Function):Number {
			var errorSum:Number = 0;
			for (var i:int = 0; i < set.length; i++) {
				var input:Array = set[i].input;
				var target:Array = set[i].output;
				
				var output:Array = this.network.activate(input);
				this.network.propagate(currentRate, target);
				
				errorSum += costFunction(target, output);
			}
			return errorSum;
		}
		
		public function test(set:Array, options:Object = null):Object {
			var error:Number = 0;
			var input:Array, output:Array, target:Array;
			var cost:Function = options && options.cost || this.cost || Trainer.cost.MSE;
			
			var start:Number = NNTools.now();
			
			for (var i:int = 0; i < set.length; i++) {
				input = set[i].input;
				target = set[i].output;
				output = this.network.activate(input);
				error += cost(target, output);
			}
			
			error /= set.length;
			
			var results:Object = {error: error, time: NNTools.now() - start};
			
			return results;
		}
		
		public function workerTrain(set:Array, callback:Function = null, options:Object = null, suppressWarning:Boolean = false):* {
			if (!suppressWarning) {
				console.warn('Deprecated: do not use `workerTrain`, use `trainAsync` instead.')
			}
			var that:Trainer = this;
			
			if (!this.network.optimized)
				this.network.optimize();
			
			// Create a new worker
			var worker:* = this.network.worker(this.network.optimized.memory, set, options);
			
			// train the worker
			worker.onmessage = function(e:*):void {
				switch (e.data.action) {
					case 'done': 
						var iterations:int = e.data.message.iterations;
						var error:Number = e.data.message.error;
						var time:Number = e.data.message.time;
						
						that.network.optimized.ownership(e.data.memoryBuffer);
						
						// Done callback
						callback({error: error, iterations: iterations, time: time});
						
						// Delete the worker and all its associated memory
						worker.terminate();
						break;
					
					case 'log': 
						console.log(e.data.message);
					
					case 'schedule': 
						if (options && options.schedule && typeof options.schedule["do"] === 'function') {
							var scheduled:Function = options.schedule["do"];
							scheduled(e.data.message)
						}
						break;
				}
			};
			
			// Start the worker
			worker.postMessage({action: 'startTraining'});
		}
		
		public function XOR(options:Object = null):* {
			if (this.network.inputs() != 2 || this.network.outputs() != 1)
				throw new Error('Incompatible network (2 inputs, 1 output)');
			
			var defaults:Object = {iterations: 100000, log: false, shuffle: true, cost: Trainer.cost.MSE};
			
			if (options)
				for (var i:String in options)
					defaults[i] = options[i];
			
			return this.train([{input: [0, 0], output: [0]}, {input: [1, 0], output: [1]}, {input: [0, 1], output: [1]}, {input: [1, 1], output: [0]}], defaults);
		}
		
		public function DSR(options:Object = null):* {
			options = options || {};
			
			var targets:Array = options.targets || [2, 4, 7, 8];
			var distractors:Array = options.distractors || [3, 5, 6, 9];
			var prompts:Array = options.prompts || [0, 1];
			var length:int = options.length || 24;
			var criterion:Number = options.success || 0.95;
			var iterations:int = options.iterations || 100000;
			var rate:Number = options.rate || .1;
			var log:Number = options.log || 0;
			var schedule:Object = options.schedule || {};
			var cost:Function = options.cost || this.cost || Trainer.cost.CROSS_ENTROPY;
			
			var trial:int, correct:int, i:int, j:int, success:int;
			trial = correct = i = j = success = 0;
			var error:int = 1, symbols:int = targets.length + distractors.length + prompts.length;
			
			var noRepeat:Function = function(range:Number, avoid:Object):Number {
				var number:Number = Math.random() * range | 0;
				var used:Boolean = false;
				for (var i:String in avoid)
					if (number == avoid[i])
						used = true;
				return used ? noRepeat(range, avoid) : number;
			};
			
			var equal:Function = function(prediction:Array, output:Array):Boolean {
				for (var i:String in prediction)
					if (Math.round(prediction[i]) != output[i])
						return false;
				return true;
			};
			
			var start:Number = NNTools.now();
			
			while (trial < iterations && (success < criterion || trial % 1000 != 0)) {
				// generate sequence
				var sequence:Array = [], sequenceLength:int = length - prompts.length;
				for (i = 0; i < sequenceLength; i++) {
					var any:int = Math.random() * distractors.length | 0;
					sequence.push(distractors[any]);
				}
				var indexes:Array = [], positions:Array = [];
				for (i = 0; i < prompts.length; i++) {
					indexes.push(Math.random() * targets.length | 0);
					positions.push(noRepeat(sequenceLength, positions));
				}
				positions = positions.sort();
				for (i = 0; i < prompts.length; i++) {
					sequence[positions[i]] = targets[indexes[i]];
					sequence.push(prompts[i]);
				}
				
				//train sequence
				var distractorsCorrect:int;
				var targetsCorrect:int = distractorsCorrect = 0;
				error = 0;
				for (i = 0; i < length; i++) {
					// generate input from sequence
					var input:Array = [];
					for (j = 0; j < symbols; j++)
						input[j] = 0;
					input[sequence[i]] = 1;
					
					// generate target output
					var output:Array = [];
					for (j = 0; j < targets.length; j++)
						output[j] = 0;
					
					if (i >= sequenceLength) {
						var index:int = i - sequenceLength;
						output[indexes[index]] = 1;
					}
					
					// check result
					var prediction:* = this.network.activate(input);
					
					if (equal(prediction, output))
						if (i < sequenceLength)
							distractorsCorrect++;
						else
							targetsCorrect++;
					else {
						this.network.propagate(rate, output);
					}
					
					error += cost(output, prediction);
					
					if (distractorsCorrect + targetsCorrect == length)
						correct++;
				}
				
				// calculate error
				if (trial % 1000 == 0)
					correct = 0;
				trial++;
				var divideError:Number = trial % 1000;
				divideError = divideError == 0 ? 1000 : divideError;
				success = correct / divideError;
				error /= length;
				
				// log
				if (log && trial % log == 0)
					console.log('iterations:', trial, ' success:', success, ' correct:', correct, ' time:', NNTools.now() - start, ' error:', error);
				if (schedule["do"] && schedule.every && trial % schedule.every == 0)
					schedule["do"]({iterations: trial, success: success, error: error, time: NNTools.now() - start, correct: correct});
			}
			
			return {iterations: trial, success: success, error: error, time: NNTools.now() - start}
		}
		
		public function ERG(options:Object = null):* {
			
			options = options || {};
			var iterations:int = options.iterations || 150000;
			var criterion:Number = options.error || .05;
			var rate:Number = options.rate || .1;
			var log:int = options.log || 500;
			var cost:Function = options.cost || this.cost || Trainer.cost.CROSS_ENTROPY;
			
			// gramar node
			var Node:* = function():void {
				this.paths = [];
			};
			Node.prototype = {connect: function(node:*, value:*):* {
					this.paths.push({node: node, value: value});
					return this;
				}, any: function():* {
					if (this.paths.length == 0)
						return false;
					var index:int = Math.random() * this.paths.length | 0;
					return this.paths[index];
				}, test: function(value:*):* {
					for (var i:int in this.paths)
						if (this.paths[i].value == value)
							return this.paths[i];
					return false;
				}};
			
			var reberGrammar:Function = function():* {
				
				// build a reber grammar
				var output:* = new Node();
				var n1:* = (new Node()).connect(output, 'E');
				var n2:* = (new Node()).connect(n1, 'S');
				var n3:* = (new Node()).connect(n1, 'V').connect(n2, 'P');
				var n4:* = (new Node()).connect(n2, 'X');
				n4.connect(n4, 'S');
				var n5:* = (new Node()).connect(n3, 'V');
				n5.connect(n5, 'T');
				n2.connect(n5, 'X');
				var n6:* = (new Node()).connect(n4, 'T').connect(n5, 'P');
				var input:* = (new Node()).connect(n6, 'B');
				
				return {input: input, output: output}
			};
			
			// build an embeded reber grammar
			var embededReberGrammar:Function = function():Object {
				var reber1:* = reberGrammar();
				var reber2:* = reberGrammar();
				
				var output:* = new Node();
				var n1:* = (new Node).connect(output, 'E');
				reber1.output.connect(n1, 'T');
				reber2.output.connect(n1, 'P');
				var n2:* = (new Node).connect(reber1.input, 'P').connect(reber2.input, 'T');
				var input:* = (new Node).connect(n2, 'B');
				
				return {input: input, output: output}
			
			};
			
			// generate an ERG sequence
			var generate:Function = function():String {
				var node:* = embededReberGrammar().input;
				var next:* = node.any();
				var str:String = '';
				while (next) {
					str += next.value;
					next = next.node.any();
				}
				return str;
			};
			
			// test if a string matches an embeded reber grammar
			var test:Function = function(str:String):* {
				var node:* = embededReberGrammar().input;
				var i:int = 0;
				var ch:String = str.charAt(i);
				while (i < str.length) {
					var next:* = node.test(ch);
					if (!next)
						return false;
					node = next.node;
					ch = str.charAt(++i);
				}
				return true;
			};
			
			// helper to check if the output and the target vectors match
			var different:Function = function(array1:Array, array2:Array):Boolean {
				var max1:int = 0;
				var i1:int = -1;
				var max2:int = 0;
				var i2:int = -1;
				for (var i:* in array1) {
					if (array1[i] > max1) {
						max1 = array1[i];
						i1 = i;
					}
					if (array2[i] > max2) {
						max2 = array2[i];
						i2 = i;
					}
				}
				
				return i1 != i2;
			};
			
			var iteration:int = 0;
			var error:Number = 1;
			var table:Object = {'B': 0, 'P': 1, 'T': 2, 'X': 3, 'S': 4, 'E': 5};
			
			var start:Number = NNTools.now();
			while (iteration < iterations && error > criterion) {
				var i:int = 0;
				error = 0;
				
				// ERG sequence to learn
				var sequence:* = generate();
				
				// input
				var read:* = sequence.charAt(i);
				// target
				var predict:* = sequence.charAt(i + 1);
				
				// train
				while (i < sequence.length - 1) {
					var input:Array = [];
					var target:Array = [];
					for (var j:int = 0; j < 6; j++) {
						input[j] = 0;
						target[j] = 0;
					}
					input[table[read]] = 1;
					target[table[predict]] = 1;
					
					var output:Array = this.network.activate(input);
					
					if (different(output, target))
						this.network.propagate(rate, target);
					
					read = sequence.charAt(++i);
					predict = sequence.charAt(i + 1);
					
					error += cost(target, output);
				}
				error /= sequence.length;
				iteration++;
				if (iteration % log == 0) {
					console.log('iterations:', iteration, ' time:', NNTools.now() - start, ' error:', error);
				}
			}
			
			return {iterations: iteration, error: error, time: NNTools.now() - start, test: test, generate: generate}
		}
		
		public function timingTask(options:Object=null):* {
			
			if (this.network.inputs() != 2 || this.network.outputs() != 1)
				throw new Error('Invalid Network: must have 2 inputs and one output');
			
			if (!options)
				options = {};
			
			// helper
			function getSamples(trainingSize:int, testSize:int):Object {
				
				// sample size
				var size:int = trainingSize + testSize;
				
				// generate samples
				var t:int = 0;
				var set:Array = [];
				for (var i:int = 0; i < size; i++) {
					set.push({input: [0, 0], output: [0]});
				}
				while (t < size - 20) {
					var n:int = Math.round(Math.random() * 20);
					set[t].input[0] = 1;
					for (var j:int = t; j <= t + n; j++) {
						set[j].input[1] = n / 20;
						set[j].output[0] = 0.5;
					}
					t += n;
					n = Math.round(Math.random() * 20);
					for (var k:int = t + 1; k <= (t + n) && k < size; k++)
						set[k].input[1] = set[t].input[1];
					t += n;
				}
				
				// separate samples between train and test sets
				var trainingSet:Array = [];
				var testSet:Array = [];
				for (var l:int = 0; l < size; l++)
					(l < trainingSize ? trainingSet : testSet).push(set[l]);
				
				// return samples
				return {train: trainingSet, test: testSet}
			}
			
			var iterations:Number = options.iterations || 200;
			var error:Number = options.error || .005;
			var rate:Array = options.rate || [.03, .02];
			var log:* = options.log === false ? false : options.log || 10;
			var cost:Function = options.cost || this.cost || Trainer.cost.MSE;
			var trainingSamples:Number = options.trainSamples || 7000;
			var testSamples:Number = options.trainSamples || 1000;
			
			// samples for training and testing
			var samples:* = getSamples(trainingSamples, testSamples);
			
			// train
			var result:Object = this.train(samples.train, {rate: rate, log: log, iterations: iterations, error: error, cost: cost});
			
			return {train: result, test: this.test(samples.test)}
		}
	}

}