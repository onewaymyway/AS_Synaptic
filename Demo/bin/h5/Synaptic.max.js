var window = window || global;
var document = document || (window.document = {});
/***********************************/
/*http://www.layabox.com 2017/01/16*/
/***********************************/
var Laya=window.Laya=(function(window,document){
	var Laya={
		__internals:[],
		__packages:{},
		__classmap:{'Object':Object,'Function':Function,'Array':Array,'String':String},
		__sysClass:{'object':'Object','array':'Array','string':'String','dictionary':'Dictionary'},
		__propun:{writable: true,enumerable: false,configurable: true},
		__presubstr:String.prototype.substr,
		__substr:function(ofs,sz){return arguments.length==1?Laya.__presubstr.call(this,ofs):Laya.__presubstr.call(this,ofs,sz>0?sz:(this.length+sz));},
		__init:function(_classs){_classs.forEach(function(o){o.__init$ && o.__init$();});},
		__isClass:function(o){return o && (o.__isclass || o==Object || o==String || o==Array);},
		__newvec:function(sz,value){
			var d=[];
			d.length=sz;
			for(var i=0;i<sz;i++) d[i]=value;
			return d;
		},
		__extend:function(d,b){
			for (var p in b){
				if (!b.hasOwnProperty(p)) continue;
				var gs=Object.getOwnPropertyDescriptor(b, p);
				var g = gs.get, s = gs.set; 
				if ( g || s ) {
					if ( g && s)
						Object.defineProperty(d,p,gs);
					else{
						g && Object.defineProperty(d, p, g);
						s && Object.defineProperty(d, p, s);
					}
				}
				else d[p] = b[p];
			}
			function __() { Laya.un(this,'constructor',d); }__.prototype=b.prototype;d.prototype=new __();Laya.un(d.prototype,'__imps',Laya.__copy({},b.prototype.__imps));
		},
		__copy:function(dec,src){
			if(!src) return null;
			dec=dec||{};
			for(var i in src) dec[i]=src[i];
			return dec;
		},
		__package:function(name,o){
			if(Laya.__packages[name]) return;
			Laya.__packages[name]=true;
			var p=window,strs=name.split('.');
			if(strs.length>1){
				for(var i=0,sz=strs.length-1;i<sz;i++){
					var c=p[strs[i]];
					p=c?c:(p[strs[i]]={});
				}
			}
			p[strs[strs.length-1]] || (p[strs[strs.length-1]]=o||{});
		},
		__hasOwnProperty:function(name,o){
			o=o ||this;
		    function classHas(name,o){
				if(Object.hasOwnProperty.call(o.prototype,name)) return true;
				var s=o.prototype.__super;
				return s==null?null:classHas(name,s);
			}
			return (Object.hasOwnProperty.call(o,name)) || classHas(name,o.__class);
		},
		__typeof:function(o,value){
			if(!o || !value) return false;
			if(value===String) return (typeof o==='string');
			if(value===Number) return (typeof o==='number');
			if(value.__interface__) value=value.__interface__;
			else if(typeof value!='string')  return (o instanceof value);
			return (o.__imps && o.__imps[value]) || (o.__class==value);
		},
		__as:function(value,type){
			return (this.__typeof(value,type))?value:null;
		},		
		interface:function(name,_super){
			Laya.__package(name,{});
			var ins=Laya.__internals;
			var a=ins[name]=ins[name] || {self:name};
			if(_super)
			{
				var supers=_super.split(',');
				a.extend=[];
				for(var i=0;i<supers.length;i++){
					var nm=supers[i];
					ins[nm]=ins[nm] || {self:nm};
					a.extend.push(ins[nm]);
				}
			}
			var o=window,words=name.split('.');
			for(var i=0;i<words.length-1;i++) o=o[words[i]];
			o[words[words.length-1]]={__interface__:name};
		},
		class:function(o,fullName,_super,miniName){
			_super && Laya.__extend(o,_super);
			if(fullName){
				Laya.__package(fullName,o);
				Laya.__classmap[fullName]=o;
				if(fullName.indexOf('.')>0){
					if(fullName.indexOf('laya.')==0){
						var paths=fullName.split('.');
						miniName=miniName || paths[paths.length-1];
						if(Laya[miniName]) console.log("Warning!,this class["+miniName+"] already exist:",Laya[miniName]);
						Laya[miniName]=o;
					}
				}
				else {
					if(fullName=="Main")
						window.Main=o;
					else{
						if(Laya[fullName]){
							console.log("Error!,this class["+fullName+"] already exist:",Laya[fullName]);
						}
						Laya[fullName]=o;
					}
				}
			}
			var un=Laya.un,p=o.prototype;
			un(p,'hasOwnProperty',Laya.__hasOwnProperty);
			un(p,'__class',o);
			un(p,'__super',_super);
			un(p,'__className',fullName);
			un(o,'__super',_super);
			un(o,'__className',fullName);
			un(o,'__isclass',true);
			un(o,'super',function(o){this.__super.call(o);});
		},
		imps:function(dec,src){
			if(!src) return null;
			var d=dec.__imps|| Laya.un(dec,'__imps',{});
			function __(name){
				var c,exs;
				if(! (c=Laya.__internals[name]) ) return;
				d[name]=true;
				if(!(exs=c.extend)) return;
				for(var i=0;i<exs.length;i++){
					__(exs[i].self);
				}
			}
			for(var i in src) __(i);
		},
		getset:function(isStatic,o,name,getfn,setfn){
			if(!isStatic){
				getfn && Laya.un(o,'_$get_'+name,getfn);
				setfn && Laya.un(o,'_$set_'+name,setfn);
			}
			else{
				getfn && (o['_$GET_'+name]=getfn);
				setfn && (o['_$SET_'+name]=setfn);
			}
			if(getfn && setfn) 
				Object.defineProperty(o,name,{get:getfn,set:setfn,enumerable:false});
			else{
				getfn && Object.defineProperty(o,name,{get:getfn,enumerable:false});
				setfn && Object.defineProperty(o,name,{set:setfn,enumerable:false});
			}
		},
		static:function(_class,def){
				for(var i=0,sz=def.length;i<sz;i+=2){
					if(def[i]=='length') 
						_class.length=def[i+1].call(_class);
					else{
						function tmp(){
							var name=def[i];
							var getfn=def[i+1];
							Object.defineProperty(_class,name,{
								get:function(){delete this[name];return this[name]=getfn.call(this);},
								set:function(v){delete this[name];this[name]=v;},enumerable: true,configurable: true});
						}
						tmp();
					}
				}
		},		
		un:function(obj,name,value){
			value || (value=obj[name]);
			Laya.__propun.value=value;
			Object.defineProperty(obj, name, Laya.__propun);
			return value;
		},
		uns:function(obj,names){
			names.forEach(function(o){Laya.un(obj,o)});
		}
	};

	window.console=window.console || ({log:function(){}});
	window.trace=window.console.log;
	Error.prototype.throwError=function(){throw arguments;};
	String.prototype.substr=Laya.__substr;
	Object.defineProperty(Array.prototype,'fixed',{enumerable: false});

	return Laya;
})(window,document);

(function(window,document,Laya){
	var __un=Laya.un,__uns=Laya.uns,__static=Laya.static,__class=Laya.class,__getset=Laya.getset,__newvec=Laya.__newvec;
	/**
	*...
	*@author ww
	*/
	//class TestNN
	var TestNN=(function(){
		function TestNN(){
			Neuron;
			NetWork;
			this.testNet();
		}

		__class(TestNN,'TestNN');
		var __proto=TestNN.prototype;
		__proto.testNet=function(){
			var pNet;
			pNet=new Perceptron(2,3,1);
			pNet.trainer.XOR();
			console.log(pNet.activate([0,0]));
			console.log(pNet.activate([1,0]));
			console.log(pNet.activate([0,1]));
			console.log(pNet.activate([1,1]));
		}

		return TestNN;
	})()


	/**
	*...
	*@author ww
	*/
	//class oneway.nn.Connection
	var Connection=(function(){
		function Connection(from,to,weight){
			this.ID=0;
			this.from=null;
			this.to=null;
			this.weight=NaN;
			this.gain=1;
			this.gater=null;
			(weight===void 0)&& (weight=-1);
			this.ID=oneway.nn.Connection.uid();
			this.from=from;
			this.to=to;
			this.weight=weight < 0 ? Math.random()*.2-.1 :weight;
			this.gain=1;
			this.gater=null;
		}

		__class(Connection,'oneway.nn.Connection');
		Connection.uid=function(){
			return Connection.connections++;
		}

		Connection.connections=0;
		return Connection;
	})()


	/**
	*...
	*@author ww
	*/
	//class oneway.nn.Cost
	var Cost=(function(){
		function Cost(){}
		__class(Cost,'oneway.nn.Cost');
		Cost.CROSS_ENTROPY=function(target,output){
			var crossentropy=0;
			for (var i in output)
			crossentropy-=(target[i] *Math.log(output[i]+1e-15))+((1-target[i])*Math.log((1+1e-15)-output[i]));
			return crossentropy;
		}

		Cost.MSE=function(target,output){
			var mse=0;
			for (var i=0;i < output.length;i++)
			mse+=Math.pow(target[i]-output[i],2);
			return mse / output.length;
		}

		Cost.BINARY=function(target,output){
			var misses=0;
			for (var i=0;i < output.length;i++)
			misses+=Math.round(target[i] *2)!=Math.round(output[i] *2);
			return misses;
		}

		return Cost;
	})()


	/**
	*...
	*@author ww
	*/
	//class oneway.nn.Layer
	var Layer=(function(){
		function Layer(size){
			this.size=0;
			this.list=null;
			this.connectedTo=null;
			this.size=size | 0;
			this.list=[];
			this.connectedTo=[];
			while (size--){
				var neuron=new Neuron();
				this.list.push(neuron);
			}
		}

		__class(Layer,'oneway.nn.Layer');
		var __proto=Layer.prototype;
		__proto.activate=function(input){
			var activations=[];
			if (input){
				if (input.length !=this.size)
					throw new Error('INPUT size and LAYER size must be the same to activate!');
				for (var id in this.list){
					var neuron=this.list[id];
					var activation=neuron.activate(input[id]);
					activations.push(activation);
				}
			}
			else {
				for (var id in this.list){
					var neuron=this.list[id];
					var activation=neuron.activate();
					activations.push(activation);
				}
			}
			return activations;
		}

		__proto.propagate=function(rate,target){
			if (typeof target !='undefined'){
				if (target.length !=this.size)
					throw new Error('TARGET size and LAYER size must be the same to propagate!');
				for (var id=this.list.length-1;id >=0;id--){
					var neuron=this.list[id];
					neuron.propagate(rate,target[id]);
				}
			}
			else {
				for (var id=this.list.length-1;id >=0;id--){
					var neuron=this.list[id];
					neuron.propagate(rate);
				}
			}
		}

		__proto.project=function(layer,type,weights){
			if (layer instanceof NetWork)
				layer=layer.layers.input;
			if (layer instanceof Layer){
				if (!this.connected(layer))
					return new LayerConnection(this,layer,type,weights);
			}
			else
			throw new Error('Invalid argument, you can only project connections to LAYERS and NETWORKS!');
		}

		__proto.gate=function(connection,type){
			if (type==oneway.nn.Layer.gateType.INPUT){
				if (connection.to.size !=this.size)
					throw new Error('GATER layer and CONNECTION.TO layer must be the same size in order to gate!');
				for (var id in connection.to.list){
					var neuron=connection.to.list[id];
					var gater=this.list[id];
					for (var input in neuron.connections.inputs){
						var gated=neuron.connections.inputs[input];
						if (gated.ID in connection.connections)
							gater.gate(gated);
					}
				}
			}
			else if (type==oneway.nn.Layer.gateType.OUTPUT){
				if (connection.from.size !=this.size)
					throw new Error('GATER layer and CONNECTION.FROM layer must be the same size in order to gate!');
				for (var id in connection.from.list){
					var neuron=connection.from.list[id];
					var gater=this.list[id];
					for (var projected in neuron.connections.projected){
						var gated=neuron.connections.projected[projected];
						if (gated.ID in connection.connections)
							gater.gate(gated);
					}
				}
			}
			else if (type==oneway.nn.Layer.gateType.ONE_TO_ONE){
				if (connection.size !=this.size)
					throw new Error('The number of GATER UNITS must be the same as the number of CONNECTIONS to gate!');
				for (var id in connection.list){
					var gater=this.list[id];
					var gated=connection.list[id];
					gater.gate(gated);
				}
			}
			connection.gatedfrom.push({layer:this,type:type});
		}

		__proto.selfconnected=function(){
			for (var id in this.list){
				var neuron=this.list[id];
				if (!neuron.selfconnected())
					return false;
			}
			return true;
		}

		__proto.connected=function(layer){
			var connections=0;
			for (var here in this.list){
				for (var there in layer.list){
					var from=this.list[here];
					var to=layer.list[there];
					var connected=from.connected(to);
					if (connected.type=='projected')
						connections++;
				}
			}
			if (connections==this.size *layer.size)
				return oneway.nn.Layer.connectionType.ALL_TO_ALL;
			connections=0;
			for (var neuron in this.list){
				var from=this.list[neuron];
				var to=layer.list[neuron];
				var connected=from.connected(to);
				if (connected.type=='projected')
					connections++;
			}
			if (connections==this.size)
				return oneway.nn.Layer.connectionType.ONE_TO_ONE;
		}

		__proto.clear=function(){
			for (var id in this.list){
				var neuron=this.list[id];
				neuron.clear();
			}
		}

		__proto.reset=function(){
			for (var id in this.list){
				var neuron=this.list[id];
				neuron.reset();
			}
		}

		__proto.neurons=function(){
			return this.list;
		}

		__proto.add=function(neuron){
			neuron=neuron || new Neuron();
			this.list.push(neuron);
			this.size++;
		}

		__proto.set=function(options){
			options=options || {};
			for (var i in this.list){
				var neuron=this.list[i];
				if (options.label)
					neuron.label=options.label+'_'+neuron.ID;
				if (options.squash)
					neuron.squash=options.squash;
				if (options.bias)
					neuron.bias=options.bias;
			}
			return this;
		}

		__static(Layer,
		['connectionType',function(){return this.connectionType={ALL_TO_ALL:"ALL TO ALL",ONE_TO_ONE:"ONE TO ONE",ALL_TO_ELSE:"ALL TO ELSE"};},'gateType',function(){return this.gateType={INPUT:"INPUT",OUTPUT:"OUTPUT",ONE_TO_ONE:"ONE TO ONE"};}
		]);
		return Layer;
	})()


	/**
	*...
	*@author ww
	*/
	//class oneway.nn.LayerConnection
	var LayerConnection=(function(){
		function LayerConnection(fromLayer,toLayer,type,weights){
			this.ID=oneway.nn.LayerConnection.uid();
			this.from=fromLayer;
			this.to=toLayer;
			this.selfconnection=toLayer==fromLayer;
			this.type=type;
			this.connections={};
			this.list=[];
			this.size=0;
			this.gatedfrom=[];
			if (this.type==null){
				if (fromLayer==toLayer)
					this.type=Layer.connectionType.ONE_TO_ONE;
				else
				this.type=Layer.connectionType.ALL_TO_ALL;
			}
			if (this.type==Layer.connectionType.ALL_TO_ALL || this.type==Layer.connectionType.ALL_TO_ELSE){
				for (var here in this.from.list){
					for (var there in this.to.list){
						var from=this.from.list[here];
						var to=this.to.list[there];
						if (this.type==Layer.connectionType.ALL_TO_ELSE && from==to)
							continue ;
						var connection=from.project(to,weights);
						this.connections[connection.ID]=connection;
						this.size=this.list.push(connection);
					}
				}
			}
			else if (this.type==Layer.connectionType.ONE_TO_ONE){
				for (var neuron in this.from.list){
					var from=this.from.list[neuron];
					var to=this.to.list[neuron];
					var connection=from.project(to,weights);
					this.connections[connection.ID]=connection;
					this.size=this.list.push(connection);
				}
			}
			fromLayer.connectedTo.push(this);
		}

		__class(LayerConnection,'oneway.nn.LayerConnection');
		LayerConnection.uid=function(){
			return LayerConnection.connections++;
		}

		LayerConnection.connections=0;
		return LayerConnection;
	})()


	/**
	*...
	*@author ww
	*/
	//class oneway.nn.NetWork
	var NetWork=(function(){
		function NetWork(layers){
			this.layers=null;
			this.optimized=null;
			this.trainer=null;
			if (layers){
				this.layers={input:layers.input || null,hidden:layers.hidden || [],output:layers.output || null};
				this.optimized=null;
			}
		}

		__class(NetWork,'oneway.nn.NetWork');
		var __proto=NetWork.prototype;
		__proto.activate=function(input){
			if (this.optimized===false){
				this.layers.input.activate(input);
				for (var i=0;i < this.layers.hidden.length;i++)
				this.layers.hidden[i].activate();
				return this.layers.output.activate();
			}
			else {
				if (this.optimized==null)
					this.optimize();
				return this.optimized.activate(input);
			}
		}

		__proto.propagate=function(rate,target){
			if (this.optimized===false){
				this.layers.output.propagate(rate,target);
				for (var i=this.layers.hidden.length-1;i >=0;i--)
				this.layers.hidden[i].propagate(rate);
			}
			else {
				if (this.optimized==null)
					this.optimize();
				this.optimized.propagate(rate,target);
			}
		}

		__proto.project=function(unit,type,weights){
			if (this.optimized)
				this.optimized.reset();
			if (unit instanceof NetWork)
				return this.layers.output.project(unit.layers.input,type,weights);
			if (unit instanceof Layer)
				return this.layers.output.project(unit,type,weights);
			throw new Error('Invalid argument, you can only project connections to LAYERS and NETWORKS!');
		}

		__proto.clear=function(){
			this.restore();
			var inputLayer=this.layers.input,outputLayer=this.layers.output;
			inputLayer.clear();
			for (var i=0;i < this.layers.hidden.length;i++){
				this.layers.hidden[i].clear();
			}
			outputLayer.clear();
			if (this.optimized)
				this.optimized.reset();
		}

		__proto.reset=function(){
			this.restore();
			var inputLayer=this.layers.input,outputLayer=this.layers.output;
			inputLayer.reset();
			for (var i=0;i < this.layers.hidden.length;i++){
				this.layers.hidden[i].reset();
			}
			outputLayer.reset();
			if (this.optimized)
				this.optimized.reset();
		}

		__proto.optimize=function(){
			var that=this;
			var optimized={};
			var neurons=this.neurons();
			for (var i=0;i < neurons.length;i++){
				var neuron=neurons[i].neuron;
				var layer=neurons[i].layer;
				while (neuron.neuron)
				neuron=neuron.neuron;
				optimized=neuron.optimize(optimized,layer);
			}
			for (var i=0;i < optimized.propagation_sentences.length;i++)
			optimized.propagation_sentences[i].reverse();
			optimized.propagation_sentences.reverse();
			var hardcode='';
			hardcode+='var F = Float64Array ? new Float64Array('+optimized.memory+') : []; ';
			for (var i in optimized.variables)
			hardcode+='F['+optimized.variables[i].id+'] = '+(optimized.variables[i].value || 0)+'; ';
			hardcode+='var activate = function(input){\n';
			for (var i=0;i < optimized.inputs.length;i++)
			hardcode+='F['+optimized.inputs[i]+'] = input['+i+']; ';
			for (var i=0;i < optimized.activation_sentences.length;i++){
				if (optimized.activation_sentences[i].length > 0){
					for (var j=0;j < optimized.activation_sentences[i].length;j++){
						hardcode+=optimized.activation_sentences[i][j].join(' ');
						hardcode+=optimized.trace_sentences[i][j].join(' ');
					}
				}
			}
			hardcode+=' var output = []; '
			for (var i=0;i < optimized.outputs.length;i++)
			hardcode+='output['+i+'] = F['+optimized.outputs[i]+']; ';
			hardcode+='return output; }; '
			hardcode+='var propagate = function(rate, target){\n';
			hardcode+='F['+optimized.variables.rate.id+'] = rate; ';
			for (var i=0;i < optimized.targets.length;i++)
			hardcode+='F['+optimized.targets[i]+'] = target['+i+']; ';
			for (var i=0;i < optimized.propagation_sentences.length;i++)
			for (var j=0;j < optimized.propagation_sentences[i].length;j++)
			hardcode+=optimized.propagation_sentences[i][j].join(' ')+' ';
			hardcode+=' };\n';
			hardcode+='var ownership = function(memoryBuffer){\nF = memoryBuffer;\nthis.memory = F;\n};\n';
			hardcode+='return {\nmemory: F,\nactivate: activate,\npropagate: propagate,\nownership: ownership\n};';
			hardcode=hardcode.split(';').join(';\n');
			var constructor=new Function(hardcode);
			var network=constructor();
			network.data={variables:optimized.variables,activate:optimized.activation_sentences,propagate:optimized.propagation_sentences,trace:optimized.trace_sentences,inputs:optimized.inputs,outputs:optimized.outputs,check_activation:this.activate,check_propagation:this.propagate}
			network.reset=function (){
				if (that.optimized){
					that.optimized=null;
					that.activate=network.data.check_activation;
					that.propagate=network.data.check_propagation;
				}
			}
			this.optimized=network;
			this.activate=network.activate;
			this.propagate=network.propagate;
		}

		__proto.restore=function(){
			if (!this.optimized)
				return;
			var optimized=this.optimized;
			var getValue=function (){
				var args=Array.prototype.slice.call(arguments);
				var unit=args.shift();
				var prop=args.pop();
				var id=prop+'_';
				for (var property in args)
				id+=args[property]+'_';
				id+=unit.ID;
				var memory=optimized.memory;
				var variables=optimized.data.variables;
				if (id in variables)
					return memory[variables[id].id];
				return 0;
			};
			var list=this.neurons();
			for (var i=0;i < list.length;i++){
				var neuron=list[i].neuron;
				while (neuron.neuron)
				neuron=neuron.neuron;
				neuron.state=getValue(neuron,'state');
				neuron.old=getValue(neuron,'old');
				neuron.activation=getValue(neuron,'activation');
				neuron.bias=getValue(neuron,'bias');
				for (var input in neuron.trace.elegibility)
				neuron.trace.elegibility[input]=getValue(neuron,'trace','elegibility',input);
				for (var gated in neuron.trace.extended)
				for (var input in neuron.trace.extended[gated])
				neuron.trace.extended[gated][input]=getValue(neuron,'trace','extended',gated,input);
				for (var j in neuron.connections.projected){
					var connection=neuron.connections.projected[j];
					connection.weight=getValue(connection,'weight');
					connection.gain=getValue(connection,'gain');
				}
			}
		}

		__proto.neurons=function(){
			var neurons=[];
			var inputLayer=this.layers.input.neurons(),outputLayer=this.layers.output.neurons();
			for (var i=0;i < inputLayer.length;i++){
				neurons.push({neuron:inputLayer[i],layer:'input'});
			}
			for (var i=0;i < this.layers.hidden.length;i++){
				var hiddenLayer=this.layers.hidden[i].neurons();
				for (var j=0;j < hiddenLayer.length;j++)
				neurons.push({neuron:hiddenLayer[j],layer:i});
			}
			for (var i=0;i < outputLayer.length;i++){
				neurons.push({neuron:outputLayer[i],layer:'output'});
			}
			return neurons;
		}

		__proto.inputs=function(){
			return this.layers.input.size;
		}

		__proto.outputs=function(){
			return this.layers.output.size;
		}

		__proto.set=function(layers){
			this.layers={input:layers.input || null,hidden:layers.hidden || [],output:layers.output || null};
			if (this.optimized)
				this.optimized.reset();
		}

		__proto.setOptimize=function(bool){
			this.restore();
			if (this.optimized)
				this.optimized.reset();
			this.optimized=bool ? null :false;
		}

		__proto.toJSON=function(ignoreTraces){
			this.restore();
			var list=this.neurons();
			var neurons=[];
			var connections=[];
			var ids={};
			for (var i=0;i < list.length;i++){
				var neuron=list[i].neuron;
				while (neuron.neuron)
				neuron=neuron.neuron;
				ids[neuron.ID]=i;
				var copy={"trace":{elegibility:{},extended:{}},state:neuron.state,old:neuron.old,activation:neuron.activation,bias:neuron.bias,layer:list[i].layer};
				copy.squash=neuron.squash==Neuron.squash.LOGISTIC ? 'LOGISTIC' :neuron.squash==Neuron.squash.TANH ? 'TANH' :neuron.squash==Neuron.squash.IDENTITY ? 'IDENTITY' :neuron.squash==Neuron.squash.HLIM ? 'HLIM' :neuron.squash==Neuron.squash.RELU ? 'RELU' :null;
				neurons.push(copy);
			}
			for (var i=0;i < list.length;i++){
				var neuron=list[i].neuron;
				while (neuron.neuron)
				neuron=neuron.neuron;
				for (var j in neuron.connections.projected){
					var connection=neuron.connections.projected[j];
					connections.push({"from":ids[connection.from.ID],"to":ids[connection.to.ID],"weight":connection.weight,"gater":connection.gater ? ids[connection.gater.ID] :null});
				}
				if (neuron.selfconnected()){
					connections.push({from:ids[neuron.ID],to:ids[neuron.ID],weight:neuron.selfconnection.weight,gater:neuron.selfconnection.gater ? ids[neuron.selfconnection.gater.ID] :null});
				}
			}
			return {neurons:neurons,connections:connections}
		}

		__proto.toDot=function(edgeConnection){
			if (!typeof edgeConnection)
				edgeConnection=false;
			var code='digraph nn {\n    rankdir = BT\n';
			var layers=[this.layers.input].concat(this.layers.hidden,this.layers.output);
			for (var i=0;i < layers.length;i++){
				for (var j=0;j < layers[i].connectedTo.length;j++){
					var connection=layers[i].connectedTo[j];
					var layerTo=connection.to;
					var size=connection.size;
					var layerID=layers.indexOf(layers[i]);
					var layerToID=layers.indexOf(layerTo);
					if (edgeConnection){
						if (connection.gatedfrom.length){
							var fakeNode='fake'+layerID+'_'+layerToID;
							code+='    '+fakeNode+' [label = "", shape = point, width = 0.01, height = 0.01]\n';
							code+='    '+layerID+' -> '+fakeNode+' [label = '+size+', arrowhead = none]\n';
							code+='    '+fakeNode+' -> '+layerToID+'\n';
						}
						else
						code+='    '+layerID+' -> '+layerToID+' [label = '+size+']\n';
						for (var from in connection.gatedfrom){
							var layerfrom=connection.gatedfrom[from].layer;
							var layerfromID=layers.indexOf(layerfrom);
							code+='    '+layerfromID+' -> '+fakeNode+' [color = blue]\n';
						}
					}
					else {
						code+='    '+layerID+' -> '+layerToID+' [label = '+size+']\n';
						for (var from in connection.gatedfrom){
							var layerfrom=connection.gatedfrom[from].layer;
							var layerfromID=layers.indexOf(layerfrom);
							code+='    '+layerfromID+' -> '+layerToID+' [color = blue]\n';
						}
					}
				}
			}
			code+='}\n';
			return {code:code,link:'https://chart.googleapis.com/chart?chl='+escape(code.replace('/ /g','+'))+'&cht=gv'}
		}

		__proto.standalone=function(){
			if (!this.optimized)
				this.optimize();
			var data=this.optimized.data;
			var activation='function (input) {\n';
			for (var i=0;i < data.inputs.length;i++)
			activation+='F['+data.inputs[i]+'] = input['+i+'];\n';
			for (var i=0;i < data.activate.length;i++){
				for (var j=0;j < data.activate[i].length;j++)
				activation+=data.activate[i][j].join('')+'\n';
			}
			activation+='var output = [];\n';
			for (var i=0;i < data.outputs.length;i++)
			activation+='output['+i+'] = F['+data.outputs[i]+'];\n';
			activation+='return output;\n}';
			var memory=activation.match(/F\[(\d+)\]/g);
			var dimension=0;
			var ids={};
			for (var i=0;i < memory.length;i++){
				var tmp=memory[i].match(/\d+/)[0];
				if (!(tmp in ids)){
					ids[tmp]=dimension++;
				}
			};
			var hardcode='F = {\n';
			for (var i in ids)
			hardcode+=ids[i]+': '+this.optimized.memory[i]+',\n';
			hardcode=hardcode.substring(0,hardcode.length-2)+'\n};\n';
			hardcode='var run = '+activation.replace(/F\[(\d+)]/g,function(index){
				return 'F['+ids[index.match(/\d+/)[0]]+']'
			}).replace('{\n','{\n'+hardcode+'')+';\n';
			hardcode+='return run';
			return new Function(hardcode)();
		}

		__proto.worker=function(memory,set,options){
			var workerOptions={};
			if (options)
				workerOptions=options;
			workerOptions.rate=workerOptions.rate ||.2;
			workerOptions.iterations=workerOptions.iterations || 100000;
			workerOptions.error=workerOptions.error ||.005;
			workerOptions.cost=workerOptions.cost || null;
			workerOptions.crossValidate=workerOptions.crossValidate || null;
			var costFunction='// REPLACED BY WORKER\nvar cost = '+(options && options.cost || this.cost || Trainer.cost.MSE)+';\n';
			var workerFunction=oneway.nn.NetWork.getWorkerSharedFunctions();
			workerFunction=workerFunction.replace(/var cost=options && options\.cost \|\| this\.cost \|\| Trainer\.cost\.MSE;/g,costFunction);
			workerFunction=workerFunction.replace('return results;','postMessage({action: "done", message: results, memoryBuffer: F}, [F.buffer]);');
			workerFunction=workerFunction.replace('console.log(\'iterations\', iterations, \'error\', error, \'rate\', currentRate)','postMessage({action: \'log\', message: {\n'+'iterations: iterations,\n'+'error: error,\n'+'rate: currentRate\n'+'}\n'+'})');
			workerFunction=workerFunction.replace('abort = this.schedule.do({ error: error, iterations: iterations, rate: currentRate })','postMessage({action: \'schedule\', message: {\n'+'iterations: iterations,\n'+'error: error,\n'+'rate: currentRate\n'+'}\n'+'})');
			if (!this.optimized)
				this.optimize();
			var hardcode='var inputs = '+this.optimized.data.inputs.length+';\n';
			hardcode+='var outputs = '+this.optimized.data.outputs.length+';\n';
			hardcode+='var F =  new Float64Array(['+this.optimized.memory.toString()+']);\n';
			hardcode+='var activate = '+this.optimized.activate.toString()+';\n';
			hardcode+='var propagate = '+this.optimized.propagate.toString()+';\n';
			hardcode+='onmessage = function(e) {\n'+'if (e.data.action == \'startTraining\') {\n'+'train('+JSON.stringify(set)+','+JSON.stringify(workerOptions)+');\n'+'}\n'+'}';
			var workerSourceCode=workerFunction+'\n'+hardcode;
			var blob=new /*no*/this.Blob([workerSourceCode]);
			var blobURL=window.URL.createObjectURL(blob);
			return new /*no*/this.Worker(blobURL);
		}

		__proto.clone=function(){
			return oneway.nn.NetWork.fromJSON(this.toJSON());
		}

		NetWork.getWorkerSharedFunctions=function(){
			if (typeof oneway.nn.NetWork._SHARED_WORKER_FUNCTIONS!=='undefined')
				return oneway.nn.NetWork._SHARED_WORKER_FUNCTIONS;
			var train_f=Trainer.prototype.train.toString();
			train_f=train_f.replace(/this._trainSet/g,'_trainSet');
			train_f=train_f.replace(/this.test/g,'test');
			train_f=train_f.replace(/this.crossValidate/g,'crossValidate');
			train_f=train_f.replace('crossValidate = true','// REMOVED BY WORKER');
			var _trainSet_f=Trainer.prototype._trainSet.toString().replace(/this.network./g,'');
			var test_f=Trainer.prototype.test.toString().replace(/this.network./g,'');
			return oneway.nn.NetWork._SHARED_WORKER_FUNCTIONS=train_f+'\n'+_trainSet_f+'\n'+test_f;
		}

		NetWork.fromJSON=function(json){
			var neurons=[];
			var layers={input:new Layer(),hidden:[],output:new Layer()};
			for (var i=0;i < json.neurons.length;i++){
				var config=json.neurons[i];
				var neuron=new Neuron();
				neuron.trace.elegibility={};
				neuron.trace.extended={};
				neuron.state=config.state;
				neuron.old=config.old;
				neuron.activation=config.activation;
				neuron.bias=config.bias;
				neuron.squash=config.squash in Neuron.squash ? Neuron.squash[config.squash] :Neuron.squash.LOGISTIC;
				neurons.push(neuron);
				if (config.layer=='input')
					layers.input.add(neuron);
				else if (config.layer=='output')
				layers.output.add(neuron);
				else {
					if (typeof layers.hidden[config.layer]=='undefined')
						layers.hidden[config.layer]=new Layer();
					layers.hidden[config.layer].add(neuron);
				}
			}
			for (var i=0;i < json.connections.length;i++){
				var config=json.connections[i];
				var from=neurons[config.from];
				var to=neurons[config.to];
				var weight=config.weight;
				var gater=neurons[config.gater];
				var connection=from.project(to,weight);
				if (gater)
					gater.gate(connection);
			}
			return new NetWork(layers);
		}

		return NetWork;
	})()


	/**
	*...
	*@author ww
	*/
	//class oneway.nn.Neuron
	var Neuron=(function(){
		function Neuron(){
			this.ID=0;
			this.connections=null;
			this.error=null;
			this.trace=null;
			this.state=0;
			this.old=NaN;
			this.selfconnection=null;
			this.squash=null;
			this.neighboors=null;
			this.bias=NaN;
			this.derivative=NaN;
			this.activation=Number;
			this.ID=oneway.nn.Neuron.uid();
			this.connections={"inputs":{},"projected":{},"gated":{}};
			this.error={"responsibility":0,"projected":0,"gated":0};
			this.trace={"elegibility":{},"extended":{},"influences":{}};
			this.state=0;
			this.old=0;
			this.activation=0;
			this.selfconnection=new Connection(this,this,0);
			this.squash=oneway.nn.Neuron.squash.LOGISTIC;
			this.neighboors={};
			this.bias=Math.random()*.2-.1;
		}

		__class(Neuron,'oneway.nn.Neuron');
		var __proto=Neuron.prototype;
		__proto.activate=function(input){
			if (input !=null){
				this.activation=input;
				this.derivative=0;
				this.bias=0;
				return this.activation;
			}
			this.old=this.state;
			this.state=this.selfconnection.gain *this.selfconnection.weight *this.state+this.bias;
			for (var i in this.connections.inputs){
				var input=this.connections.inputs[i];
				this.state+=input.from.activation *input.weight *input.gain;
			}
			this.activation=this.squash(this.state);
			this.derivative=this.squash(this.state,true);
			var influences=[];
			for (var id in this.trace.extended){
				var neuron=this.neighboors[id];
				var influence=neuron.selfconnection.gater==this ? neuron.old :0;
				for (var incoming in this.trace.influences[neuron.ID]){
					influence+=this.trace.influences[neuron.ID][incoming].weight *this.trace.influences[neuron.ID][incoming].from.activation;
				}
				influences[neuron.ID]=influence;
			}
			for (var i in this.connections.inputs){
				var input=this.connections.inputs[i];
				this.trace.elegibility[input.ID]=this.selfconnection.gain *this.selfconnection.weight *this.trace.elegibility[input.ID]+input.gain *input.from.activation;
				for (var id in this.trace.extended){
					var xtrace=this.trace.extended[id];
					var neuron=this.neighboors[id];
					var influence=influences[neuron.ID];
					xtrace[input.ID]=neuron.selfconnection.gain *neuron.selfconnection.weight *xtrace[input.ID]+this.derivative *this.trace.elegibility[input.ID] *influence;
				}
			}
			for (var connection in this.connections.gated){
				this.connections.gated[connection].gain=this.activation;
			}
			return this.activation;
		}

		__proto.propagate=function(rate,target){
			var error=0;
			var isOutput=!(target===null);
			var id;
			var input;
			var connection;
			var neuron;
			if (isOutput){
				this.error.responsibility=this.error.projected=target-this.activation;
			}
			else{
				for (id in this.connections.projected){
					connection=this.connections.projected[id];
					neuron=connection.to;
					error+=neuron.error.responsibility *connection.gain *connection.weight;
				}
				this.error.projected=this.derivative *error;
				error=0;
				for (id in this.trace.extended){
					neuron=this.neighboors[id];
					var influence=neuron.selfconnection.gater==this ? neuron.old :0;
					for (input in this.trace.influences[id]){
						influence+=this.trace.influences[id][input].weight *this.trace.influences[neuron.ID][input].from.activation;
					}
					error+=neuron.error.responsibility *influence;
				}
				this.error.gated=this.derivative *error;
				this.error.responsibility=this.error.projected+this.error.gated;
			}
			rate=rate || 0.1;
			for (id in this.connections.inputs){
				input=this.connections.inputs[id];
				var gradient=this.error.projected *this.trace.elegibility[input.ID];
				for (id in this.trace.extended){
					neuron=this.neighboors[id];
					gradient+=neuron.error.responsibility *this.trace.extended[neuron.ID][input.ID];
				}
				input.weight+=rate *gradient;
			}
			this.bias+=rate *this.error.responsibility;
		}

		__proto.project=function(neuron,weight){
			if (neuron==this){
				this.selfconnection.weight=1;
				return this.selfconnection;
			};
			var connected=this.connected(neuron);
			if (connected && connected.type=='projected'){
				if (typeof weight !='undefined')
					connected.connection.weight=weight;
				return connected.connection;
			}
			else {
				var connection=new Connection(this,neuron,weight);
			}
			this.connections.projected[connection.ID]=connection;
			this.neighboors[neuron.ID]=neuron;
			neuron.connections.inputs[connection.ID]=connection;
			neuron.trace.elegibility[connection.ID]=0;
			for (var id in neuron.trace.extended){
				var trace=neuron.trace.extended[id];
				trace[connection.ID]=0;
			}
			return connection;
		}

		__proto.gate=function(connection){
			this.connections.gated[connection.ID]=connection;
			var neuron=connection.to;
			if (!(neuron.ID in this.trace.extended)){
				this.neighboors[neuron.ID]=neuron;
				var xtrace=this.trace.extended[neuron.ID]={};
				for (var id in this.connections.inputs){
					var input=this.connections.inputs[id];
					xtrace[input.ID]=0;
				}
			}
			if (neuron.ID in this.trace.influences)
				this.trace.influences[neuron.ID].push(connection);
			else
			this.trace.influences[neuron.ID]=[connection];
			connection.gater=this;
		}

		__proto.selfconnected=function(){
			return this.selfconnection.weight!==0;
		}

		__proto.connected=function(neuron){
			var result={type:null,connection:false};
			if (this==neuron){
				if (this.selfconnected()){
					result.type='selfconnection';
					result.connection=this.selfconnection;
					return result;
				}
				else
				return false;
			}
			for (var type in this.connections){
				for (var connection in this.connections[type]){
					var connection=this.connections[type][connection];
					if (connection.to==neuron){
						result.type=type;
						result.connection=connection;
						return result;
					}
					else if (connection.from==neuron){
						result.type=type;
						result.connection=connection;
						return result;
					}
				}
			}
			return false;
		}

		__proto.clear=function(){
			for (var trace in this.trace.elegibility){
				this.trace.elegibility[trace]=0;
			}
			for (var trace in this.trace.extended){
				for (var extended in this.trace.extended[trace]){
					this.trace.extended[trace][extended]=0;
				}
			}
			this.error.responsibility=this.error.projected=this.error.gated=0;
		}

		__proto.reset=function(){
			this.clear();
			for (var type in this.connections){
				for (var connection in this.connections[type]){
					this.connections[type][connection].weight=Math.random()*.2-.1;
				}
			}
			this.bias=Math.random()*.2-.1;
			this.old=this.state=this.activation=0;
		}

		__proto.optimize=function(optimized,layer){
			optimized=optimized || {};
			var store_activation=[];
			var store_trace=[];
			var store_propagation=[];
			var varID=optimized.memory || 0;
			var neurons=optimized.neurons || 1;
			var inputs=optimized.inputs || [];
			var targets=optimized.targets || [];
			var outputs=optimized.outputs || [];
			var variables=optimized.variables || {};
			var activation_sentences=optimized.activation_sentences || [];
			var trace_sentences=optimized.trace_sentences || [];
			var propagation_sentences=optimized.propagation_sentences || [];
			var layers=optimized.layers || {__count:0,__neuron:0};
			var allocate=function (store){
				var allocated=layer in layers && store[layers.__count];
				if (!allocated){
					layers.__count=store.push([])-1;
					layers[layer]=layers.__count;
				}
			};
			allocate(activation_sentences);
			allocate(trace_sentences);
			allocate(propagation_sentences);
			var currentLayer=layers.__count;
			var getVar=function (){
				var args=Array.prototype.slice.call(arguments);
				if (args.length==1){
					if (args[0]=='target'){
						var id='target_'+targets.length;
						targets.push(varID);
					}
					else;
					var id=args[0];
					if (id in variables)
						return variables[id];
					return variables[id]={value:0,id:varID++};
				}
				else {
					var extended=args.length > 2;
					if (extended)
						var value=args.pop();
					var unit=args.shift();
					var prop=args.pop();
					if (!extended)
						var value=unit[prop];
					var id=prop+'_';
					for (var i=0;i < args.length;i++)
					id+=args[i]+'_';
					id+=unit.ID;
					if (id in variables)
						return variables[id];
					return variables[id]={value:value,id:varID++};
				}
			};
			var buildSentence=function (){
				var args=Array.prototype.slice.call(arguments);
				var store=args.pop();
				var sentence='';
				for (var i=0;i < args.length;i++)
				if (typeof args[i]=='string')
					sentence+=args[i];
				else
				sentence+='F['+args[i].id+']';
				store.push(sentence+';');
			};
			var isEmpty=function (obj){
				for (var prop in obj){
					if (obj.hasOwnProperty(prop))
						return false;
				}
				return true;
			};
			var noProjections=isEmpty(this.connections.projected);
			var noGates=isEmpty(this.connections.gated);
			var isInput=layer=='input' ? true :isEmpty(this.connections.inputs);
			var isOutput=layer=='output' ? true :noProjections && noGates;
			var rate=getVar('rate');
			var activation=getVar(this,'activation');
			if (isInput)
				inputs.push(activation.id);
			else {
				activation_sentences[currentLayer].push(store_activation);
				trace_sentences[currentLayer].push(store_trace);
				propagation_sentences[currentLayer].push(store_propagation);
				var old=getVar(this,'old');
				var state=getVar(this,'state');
				var bias=getVar(this,'bias');
				if (this.selfconnection.gater)
					var self_gain=getVar(this.selfconnection,'gain');
				if (this.selfconnected())
					var self_weight=getVar(this.selfconnection,'weight');
				buildSentence(old,' = ',state,store_activation);
				if (this.selfconnected())
					if (this.selfconnection.gater)
				buildSentence(state,' = ',self_gain,' * ',self_weight,' * ',state,' + ',bias,store_activation);
				else
				buildSentence(state,' = ',self_weight,' * ',state,' + ',bias,store_activation);
				else
				buildSentence(state,' = ',bias,store_activation);
				for (var i in this.connections.inputs){
					var input=this.connections.inputs[i];
					var input_activation=getVar(input.from,'activation');
					var input_weight=getVar(input,'weight');
					if (input.gater)
						var input_gain=getVar(input,'gain');
					if (this.connections.inputs[i].gater)
						buildSentence(state,' += ',input_activation,' * ',input_weight,' * ',input_gain,store_activation);
					else
					buildSentence(state,' += ',input_activation,' * ',input_weight,store_activation);
				};
				var derivative=getVar(this,'derivative');
				switch (this.squash){
					case oneway.nn.Neuron.squash.LOGISTIC:
						buildSentence(activation,' = (1 / (1 + Math.exp(-',state,')))',store_activation);
						buildSentence(derivative,' = ',activation,' * (1 - ',activation,')',store_activation);
						break ;
					case oneway.nn.Neuron.squash.TANH:;
						var eP=getVar('aux');
						var eN=getVar('aux_2');
						buildSentence(eP,' = Math.exp(',state,')',store_activation);
						buildSentence(eN,' = 1 / ',eP,store_activation);
						buildSentence(activation,' = (',eP,' - ',eN,') / (',eP,' + ',eN,')',store_activation);
						buildSentence(derivative,' = 1 - (',activation,' * ',activation,')',store_activation);
						break ;
					case oneway.nn.Neuron.squash.IDENTITY:
						buildSentence(activation,' = ',state,store_activation);
						buildSentence(derivative,' = 1',store_activation);
						break ;
					case oneway.nn.Neuron.squash.HLIM:
						buildSentence(activation,' = +(',state,' > 0)',store_activation);
						buildSentence(derivative,' = 1',store_activation);
						break ;
					case oneway.nn.Neuron.squash.RELU:
						buildSentence(activation,' = ',state,' > 0 ? ',state,' : 0',store_activation);
						buildSentence(derivative,' = ',state,' > 0 ? 1 : 0',store_activation);
						break ;
					}
				for (var id in this.trace.extended){
					var neuron=this.neighboors[id];
					var influence=getVar('influences['+neuron.ID+']');
					var neuron_old=getVar(neuron,'old');
					var initialized=false;
					if (neuron.selfconnection.gater==this){
						buildSentence(influence,' = ',neuron_old,store_trace);
						initialized=true;
					}
					for (var incoming in this.trace.influences[neuron.ID]){
						var incoming_weight=getVar(this.trace.influences[neuron.ID][incoming],'weight');
						var incoming_activation=getVar(this.trace.influences[neuron.ID][incoming].from,'activation');
						if (initialized)
							buildSentence(influence,' += ',incoming_weight,' * ',incoming_activation,store_trace);
						else {
							buildSentence(influence,' = ',incoming_weight,' * ',incoming_activation,store_trace);
							initialized=true;
						}
					}
				}
				for (var i in this.connections.inputs){
					var input=this.connections.inputs[i];
					if (input.gater)
						var input_gain=getVar(input,'gain');
					var input_activation=getVar(input.from,'activation');
					var trace=getVar(this,'trace','elegibility',input.ID,this.trace.elegibility[input.ID]);
					if (this.selfconnected()){
						if (this.selfconnection.gater){
							if (input.gater)
								buildSentence(trace,' = ',self_gain,' * ',self_weight,' * ',trace,' + ',input_gain,' * ',input_activation,store_trace);
							else
							buildSentence(trace,' = ',self_gain,' * ',self_weight,' * ',trace,' + ',input_activation,store_trace);
						}
						else {
							if (input.gater)
								buildSentence(trace,' = ',self_weight,' * ',trace,' + ',input_gain,' * ',input_activation,store_trace);
							else
							buildSentence(trace,' = ',self_weight,' * ',trace,' + ',input_activation,store_trace);
						}
					}
					else {
						if (input.gater)
							buildSentence(trace,' = ',input_gain,' * ',input_activation,store_trace);
						else
						buildSentence(trace,' = ',input_activation,store_trace);
					}
					for (var id in this.trace.extended){
						var neuron=this.neighboors[id];
						var influence=getVar('influences['+neuron.ID+']');
						var trace=getVar(this,'trace','elegibility',input.ID,this.trace.elegibility[input.ID]);
						var xtrace=getVar(this,'trace','extended',neuron.ID,input.ID,this.trace.extended[neuron.ID][input.ID]);
						if (neuron.selfconnected())
							var neuron_self_weight=getVar(neuron.selfconnection,'weight');
						if (neuron.selfconnection.gater)
							var neuron_self_gain=getVar(neuron.selfconnection,'gain');
						if (neuron.selfconnected())
							if (neuron.selfconnection.gater)
						buildSentence(xtrace,' = ',neuron_self_gain,' * ',neuron_self_weight,' * ',xtrace,' + ',derivative,' * ',trace,' * ',influence,store_trace);
						else
						buildSentence(xtrace,' = ',neuron_self_weight,' * ',xtrace,' + ',derivative,' * ',trace,' * ',influence,store_trace);
						else
						buildSentence(xtrace,' = ',derivative,' * ',trace,' * ',influence,store_trace);
					}
				}
				for (var connection in this.connections.gated){
					var gated_gain=getVar(this.connections.gated[connection],'gain');
					buildSentence(gated_gain,' = ',activation,store_activation);
				}
			}
			if (!isInput){
				var responsibility=getVar(this,'error','responsibility',this.error.responsibility);
				if (isOutput){
					var target=getVar('target');
					buildSentence(responsibility,' = ',target,' - ',activation,store_propagation);
					for (var id in this.connections.inputs){
						var input=this.connections.inputs[id];
						var trace=getVar(this,'trace','elegibility',input.ID,this.trace.elegibility[input.ID]);
						var input_weight=getVar(input,'weight');
						buildSentence(input_weight,' += ',rate,' * (',responsibility,' * ',trace,')',store_propagation);
					}
					outputs.push(activation.id);
				}
				else {
					if (!noProjections && !noGates){
						var error=getVar('aux');
						for (var id in this.connections.projected){
							var connection=this.connections.projected[id];
							var neuron=connection.to;
							var connection_weight=getVar(connection,'weight');
							var neuron_responsibility=getVar(neuron,'error','responsibility',neuron.error.responsibility);
							if (connection.gater){
								var connection_gain=getVar(connection,'gain');
								buildSentence(error,' += ',neuron_responsibility,' * ',connection_gain,' * ',connection_weight,store_propagation);
							}
							else
							buildSentence(error,' += ',neuron_responsibility,' * ',connection_weight,store_propagation);
						};
						var projected=getVar(this,'error','projected',this.error.projected);
						buildSentence(projected,' = ',derivative,' * ',error,store_propagation);
						buildSentence(error,' = 0',store_propagation);
						for (var id in this.trace.extended){
							var neuron=this.neighboors[id];
							var influence=getVar('aux_2');
							var neuron_old=getVar(neuron,'old');
							if (neuron.selfconnection.gater==this)
								buildSentence(influence,' = ',neuron_old,store_propagation);
							else
							buildSentence(influence,' = 0',store_propagation);
							for (var input in this.trace.influences[neuron.ID]){
								var connection=this.trace.influences[neuron.ID][input];
								var connection_weight=getVar(connection,'weight');
								var neuron_activation=getVar(connection.from,'activation');
								buildSentence(influence,' += ',connection_weight,' * ',neuron_activation,store_propagation);
							};
							var neuron_responsibility=getVar(neuron,'error','responsibility',neuron.error.responsibility);
							buildSentence(error,' += ',neuron_responsibility,' * ',influence,store_propagation);
						};
						var gated=getVar(this,'error','gated',this.error.gated);
						buildSentence(gated,' = ',derivative,' * ',error,store_propagation);
						buildSentence(responsibility,' = ',projected,' + ',gated,store_propagation);
						for (var id in this.connections.inputs){
							var input=this.connections.inputs[id];
							var gradient=getVar('aux');
							var trace=getVar(this,'trace','elegibility',input.ID,this.trace.elegibility[input.ID]);
							buildSentence(gradient,' = ',projected,' * ',trace,store_propagation);
							for (var id in this.trace.extended){
								var neuron=this.neighboors[id];
								var neuron_responsibility=getVar(neuron,'error','responsibility',neuron.error.responsibility);
								var xtrace=getVar(this,'trace','extended',neuron.ID,input.ID,this.trace.extended[neuron.ID][input.ID]);
								buildSentence(gradient,' += ',neuron_responsibility,' * ',xtrace,store_propagation);
							};
							var input_weight=getVar(input,'weight');
							buildSentence(input_weight,' += ',rate,' * ',gradient,store_propagation);
						}
					}
					else if (noGates){
						buildSentence(responsibility,' = 0',store_propagation);
						for (var id in this.connections.projected){
							var connection=this.connections.projected[id];
							var neuron=connection.to;
							var connection_weight=getVar(connection,'weight');
							var neuron_responsibility=getVar(neuron,'error','responsibility',neuron.error.responsibility);
							if (connection.gater){
								var connection_gain=getVar(connection,'gain');
								buildSentence(responsibility,' += ',neuron_responsibility,' * ',connection_gain,' * ',connection_weight,store_propagation);
							}
							else
							buildSentence(responsibility,' += ',neuron_responsibility,' * ',connection_weight,store_propagation);
						}
						buildSentence(responsibility,' *= ',derivative,store_propagation);
						for (var id in this.connections.inputs){
							var input=this.connections.inputs[id];
							var trace=getVar(this,'trace','elegibility',input.ID,this.trace.elegibility[input.ID]);
							var input_weight=getVar(input,'weight');
							buildSentence(input_weight,' += ',rate,' * (',responsibility,' * ',trace,')',store_propagation);
						}
					}
					else if (noProjections){
						buildSentence(responsibility,' = 0',store_propagation);
						for (var id in this.trace.extended){
							var neuron=this.neighboors[id];
							var influence=getVar('aux');
							var neuron_old=getVar(neuron,'old');
							if (neuron.selfconnection.gater==this)
								buildSentence(influence,' = ',neuron_old,store_propagation);
							else
							buildSentence(influence,' = 0',store_propagation);
							for (var input in this.trace.influences[neuron.ID]){
								var connection=this.trace.influences[neuron.ID][input];
								var connection_weight=getVar(connection,'weight');
								var neuron_activation=getVar(connection.from,'activation');
								buildSentence(influence,' += ',connection_weight,' * ',neuron_activation,store_propagation);
							};
							var neuron_responsibility=getVar(neuron,'error','responsibility',neuron.error.responsibility);
							buildSentence(responsibility,' += ',neuron_responsibility,' * ',influence,store_propagation);
						}
						buildSentence(responsibility,' *= ',derivative,store_propagation);
						for (var id in this.connections.inputs){
							var input=this.connections.inputs[id];
							var gradient=getVar('aux');
							buildSentence(gradient,' = 0',store_propagation);
							for (var id in this.trace.extended){
								var neuron=this.neighboors[id];
								var neuron_responsibility=getVar(neuron,'error','responsibility',neuron.error.responsibility);
								var xtrace=getVar(this,'trace','extended',neuron.ID,input.ID,this.trace.extended[neuron.ID][input.ID]);
								buildSentence(gradient,' += ',neuron_responsibility,' * ',xtrace,store_propagation);
							};
							var input_weight=getVar(input,'weight');
							buildSentence(input_weight,' += ',rate,' * ',gradient,store_propagation);
						}
					}
				}
				buildSentence(bias,' += ',rate,' * ',responsibility,store_propagation);
			}
			return {memory:varID,neurons:neurons+1,inputs:inputs,outputs:outputs,targets:targets,variables:variables,activation_sentences:activation_sentences,trace_sentences:trace_sentences,propagation_sentences:propagation_sentences,layers:layers}
		}

		Neuron.uid=function(){
			return Neuron.neurons++;
		}

		Neuron.quantity=function(){
			return {"neurons":Neuron.neurons,"connections":Connection.connections}
		}

		Neuron.neurons=0;
		__static(Neuron,
		['squash',function(){return this.squash=Squash;}
		]);
		return Neuron;
	})()


	/**
	*...
	*@author ww
	*/
	//class oneway.nn.Squash
	var Squash=(function(){
		function Squash(){}
		__class(Squash,'oneway.nn.Squash');
		Squash.LOGISTIC=function(x,derivate){
			(derivate===void 0)&& (derivate=false);
			var fx=1 / (1+Math.exp(-x));
			if (!derivate)
				return fx;
			return fx *(1-fx);
		}

		Squash.TANH=function(x,derivate){
			(derivate===void 0)&& (derivate=false);
			if (derivate)
				return 1-Math.pow(Math["tanh"](x),2);
			return Math["tanh"](x);
		}

		Squash.IDENTITY=function(x,derivate){
			(derivate===void 0)&& (derivate=false);
			return derivate ? 1 :x;
		}

		Squash.HLIM=function(x,derivate){
			(derivate===void 0)&& (derivate=false);
			return derivate ? 1 :x > 0 ? 1 :0;
		}

		Squash.RELU=function(x,derivate){
			(derivate===void 0)&& (derivate=false);
			if (derivate)
				return x > 0 ? 1 :0;
			return x > 0 ? x :0;
		}

		return Squash;
	})()


	/**
	*...
	*@author ww
	*/
	//class oneway.nn.Trainer
	var Trainer=(function(){
		function Trainer(network,options){
			this.network=null;
			this.rate=NaN;
			this.iterations=0;
			this.error=NaN;
			this.cost=null;
			this.crossValidate=null;
			options=options || {};
			this.network=network;
			this.rate=options.rate ||.2;
			this.iterations=options.iterations || 100000;
			this.error=options.error ||.005;
			this.cost=options.cost || null;
			this.crossValidate=options.crossValidate || null;
		}

		__class(Trainer,'oneway.nn.Trainer');
		var __proto=Trainer.prototype;
		__proto.train=function(set,options){
			var error=1;
			var iterations=bucketSize=0;
			var abort=false;
			var currentRate;
			var cost=options && options.cost || this.cost || oneway.nn.Trainer.cost.MSE;
			var crossValidate=false,testSet,trainSet;
			var start=Date.now();
			if (options){
				if (options.iterations)
					this.iterations=options.iterations;
				if (options.error)
					this.error=options.error;
				if (options.rate)
					this.rate=options.rate;
				if (options.cost)
					this.cost=options.cost;
				if (options.schedule)
					this.schedule=options.schedule;
				if (options.customLog){
					console.log('Deprecated: use schedule instead of customLog')
					this.schedule=options.customLog;
				}
				if (this.crossValidate || options.crossValidate){
					if (!this.crossValidate)
						this.crossValidate={};
					crossValidate=true;
					if (options.crossValidate.testSize)
						this.crossValidate.testSize=options.crossValidate.testSize;
					if (options.crossValidate.testError)
						this.crossValidate.testError=options.crossValidate.testError;
				}
			}
			currentRate=this.rate;
			if (Array.isArray(this.rate)){
				var bucketSize=Math.floor(this.iterations / this.rate.length);
			}
			if (crossValidate){
				var numTrain=Math.ceil((1-this.crossValidate.testSize)*set.length);
				trainSet=set.slice(0,numTrain);
				testSet=set.slice(numTrain);
			};
			var lastError=0;
			while ((!abort && iterations < this.iterations && error > this.error)){
				if (crossValidate && error <=this.crossValidate.testError){
					break ;
				};
				var currentSetSize=set.length;
				error=0;
				iterations++;
				if (bucketSize > 0){
					var currentBucket=Math.floor(iterations / bucketSize);
					currentRate=this.rate[currentBucket] || currentRate;
				}
				if (typeof this.rate==='function'){
					currentRate=this.rate(iterations,lastError);
				}
				if (crossValidate){
					this._trainSet(trainSet,currentRate,cost);
					error+=this.test(testSet).error;
					currentSetSize=1;
				}
				else {
					error+=this._trainSet(set,currentRate,cost);
					currentSetSize=set.length;
				}
				error /=currentSetSize;
				lastError=error;
				if (options){
					if (this.schedule && this.schedule.every && iterations % this.schedule.every==0)
						abort=this.schedule.do({error:error,iterations:iterations,rate:currentRate});
					else if (options.log && iterations % options.log==0){
						console.log('iterations',iterations,'error',error,'rate',currentRate);
					};
					if (options.shuffle)
						Trainer.shuffleInplace(set);
				}
			};
			var results={error:error,iterations:iterations,time:Date.now()-start};
			return results;
		}

		__proto.trainAsync=function(set,options){
			var train=this.workerTrain.bind(this);
			return new Promise(function(resolve,reject){
				try {
					train(set,resolve,options,true)
				}
				catch (e){
					reject(e)
				}
			})
		}

		__proto._trainSet=function(set,currentRate,costFunction){
			var errorSum=0;
			for (var i=0;i < set.length;i++){
				var input=set[i].input;
				var target=set[i].output;
				var output=this.network.activate(input);
				this.network.propagate(currentRate,target);
				errorSum+=costFunction(target,output);
			}
			return errorSum;
		}

		__proto.test=function(set,options){
			var error=0;
			var input,output,target;
			var cost=options && options.cost || this.cost || oneway.nn.Trainer.cost.MSE;
			var start=Date.now();
			for (var i=0;i < set.length;i++){
				input=set[i].input;
				target=set[i].output;
				output=this.network.activate(input);
				error+=cost(target,output);
			}
			error /=set.length;
			var results={error:error,time:Date.now()-start};
			return results;
		}

		__proto.workerTrain=function(set,callback,options,suppressWarning){
			if (!suppressWarning){
				console.warn('Deprecated: do not use `workerTrain`, use `trainAsync` instead.')
			};
			var that=this;
			if (!this.network.optimized)
				this.network.optimize();
			var worker=this.network.worker(this.network.optimized.memory,set,options);
			worker.onmessage=function (e){
				switch (e.data.action){
					case 'done':;
						var iterations=e.data.message.iterations;
						var error=e.data.message.error;
						var time=e.data.message.time;
						that.network.optimized.ownership(e.data.memoryBuffer);
						callback({error:error,iterations:iterations,time:time});
						worker.terminate();
						break ;
					case 'log':
						console.log(e.data.message);
					case 'schedule':
						if (options && options.schedule && typeof options.schedule.do==='function'){
							var scheduled=options.schedule.do
							scheduled(e.data.message)
						}
						break ;
					}
			};
			worker.postMessage({action:'startTraining'});
		}

		__proto.XOR=function(options){
			if (this.network.inputs()!=2 || this.network.outputs()!=1)
				throw new Error('Incompatible network (2 inputs, 1 output)');
			var defaults={iterations:100000,log:false,shuffle:true,cost:oneway.nn.Trainer.cost.MSE};
			if (options)
				for (var i in options)
			defaults[i]=options[i];
			return this.train([{input:[0,0],output:[0]},{input:[1,0],output:[1]},{input:[0,1],output:[1]},{input:[1,1],output:[0]}],defaults);
		}

		__proto.DSR=function(options){
			options=options || {};
			var targets=options.targets || [2,4,7,8];
			var distractors=options.distractors || [3,5,6,9];
			var prompts=options.prompts || [0,1];
			var length=options.length || 24;
			var criterion=options.success || 0.95;
			var iterations=options.iterations || 100000;
			var rate=options.rate ||.1;
			var log=options.log || 0;
			var schedule=options.schedule || {};
			var cost=options.cost || this.cost || oneway.nn.Trainer.cost.CROSS_ENTROPY;
			var trial,correct,i,j,success;
			trial=correct=i=j=success=0;
			var error=1,symbols=targets.length+distractors.length+prompts.length;
			var noRepeat=function (range,avoid){
				var number=Math.random()*range | 0;
				var used=false;
				for (var i in avoid)
				if (number==avoid[i])
					used=true;
				return used ? noRepeat(range,avoid):number;
			};
			var equal=function (prediction,output){
				for (var i in prediction)
				if (Math.round(prediction[i])!=output[i])
					return false;
				return true;
			};
			var start=Date.now();
			while (trial < iterations && (success < criterion || trial % 1000 !=0)){
				var sequence=[],sequenceLength=length-prompts.length;
				for (i=0;i < sequenceLength;i++){
					var any=Math.random()*distractors.length | 0;
					sequence.push(distractors[any]);
				};
				var indexes=[],positions=[];
				for (i=0;i < prompts.length;i++){
					indexes.push(Math.random()*targets.length | 0);
					positions.push(noRepeat(sequenceLength,positions));
				}
				positions=positions.sort();
				for (i=0;i < prompts.length;i++){
					sequence[positions[i]]=targets[indexes[i]];
					sequence.push(prompts[i]);
				};
				var distractorsCorrect;
				var targetsCorrect=distractorsCorrect=0;
				error=0;
				for (i=0;i < length;i++){
					var input=[];
					for (j=0;j < symbols;j++)
					input[j]=0;
					input[sequence[i]]=1;
					var output=[];
					for (j=0;j < targets.length;j++)
					output[j]=0;
					if (i >=sequenceLength){
						var index=i-sequenceLength;
						output[indexes[index]]=1;
					};
					var prediction=this.network.activate(input);
					if (equal(prediction,output))
						if (i < sequenceLength)
					distractorsCorrect++;
					else
					targetsCorrect++;
					else {
						this.network.propagate(rate,output);
					}
					error+=cost(output,prediction);
					if (distractorsCorrect+targetsCorrect==length)
						correct++;
				}
				if (trial % 1000==0)
					correct=0;
				trial++;
				var divideError=trial % 1000;
				divideError=divideError==0 ? 1000 :divideError;
				success=correct / divideError;
				error /=length;
				if (log && trial % log==0)
					console.log('iterations:',trial,' success:',success,' correct:',correct,' time:',Date.now()-start,' error:',error);
				if (schedule.do && schedule.every && trial % schedule.every==0)
					schedule.do({iterations:trial,success:success,error:error,time:Date.now()-start,correct:correct});
			}
			return {iterations:trial,success:success,error:error,time:Date.now()-start}
		}

		__proto.ERG=function(options){
			var _$this=this;
			options=options || {};
			var iterations=options.iterations || 150000;
			var criterion=options.error ||.05;
			var rate=options.rate ||.1;
			var log=options.log || 500;
			var cost=options.cost || this.cost || oneway.nn.Trainer.cost.CROSS_ENTROPY;
			var Node=function (){
				_$this.paths=[];
			};
			Node.prototype={connect:function (node,value){
					this.paths.push({node:node,value:value});
					return this;
					},any:function (){
					if (this.paths.length==0)
						return false;
					var index=Math.random()*this.paths.length | 0;
					return this.paths[index];
					},test:function (value){
					for (var i in this.paths)
					if (this.paths[i].value==value)
						return this.paths[i];
					return false;
			}};
			var reberGrammar=function (){
				var output=new Node();
				var n1=(new Node()).connect(output,'E');
				var n2=(new Node()).connect(n1,'S');
				var n3=(new Node()).connect(n1,'V').connect(n2,'P');
				var n4=(new Node()).connect(n2,'X');
				n4.connect(n4,'S');
				var n5=(new Node()).connect(n3,'V');
				n5.connect(n5,'T');
				n2.connect(n5,'X');
				var n6=(new Node()).connect(n4,'T').connect(n5,'P');
				var input=(new Node()).connect(n6,'B');
				return {input:input,output:output}
			};
			var embededReberGrammar=function (){
				var reber1=reberGrammar();
				var reber2=reberGrammar();
				var output=new Node();
				var n1=(new Node).connect(output,'E');
				reber1.output.connect(n1,'T');
				reber2.output.connect(n1,'P');
				var n2=(new Node).connect(reber1.input,'P').connect(reber2.input,'T');
				var input=(new Node).connect(n2,'B');
				return {input:input,output:output}
			};
			var generate=function (){
				var node=embededReberGrammar().input;
				var next=node.any();
				var str='';
				while (next){
					str+=next.value;
					next=next.node.any();
				}
				return str;
			};
			var test=function (str){
				var node=embededReberGrammar().input;
				var i=0;
				var ch=str.charAt(i);
				while (i < str.length){
					var next=node.test(ch);
					if (!next)
						return false;
					node=next.node;
					ch=str.charAt(++i);
				}
				return true;
			};
			var different=function (array1,array2){
				var max1=0;
				var i1=-1;
				var max2=0;
				var i2=-1;
				for (var i in array1){
					if (array1[i] > max1){
						max1=array1[i];
						i1=i;
					}
					if (array2[i] > max2){
						max2=array2[i];
						i2=i;
					}
				}
				return i1 !=i2;
			};
			var iteration=0;
			var error=1;
			var table={'B':0,'P':1,'T':2,'X':3,'S':4,'E':5};
			var start=Date.now();
			while (iteration < iterations && error > criterion){
				var i=0;
				error=0;
				var sequence=generate();
				var read=sequence.charAt(i);
				var predict=sequence.charAt(i+1);
				while (i < sequence.length-1){
					var input=[];
					var target=[];
					for (var j=0;j < 6;j++){
						input[j]=0;
						target[j]=0;
					}
					input[table[read]]=1;
					target[table[predict]]=1;
					var output=this.network.activate(input);
					if (different(output,target))
						this.network.propagate(rate,target);
					read=sequence.charAt(++i);
					predict=sequence.charAt(i+1);
					error+=cost(target,output);
				}
				error /=sequence.length;
				iteration++;
				if (iteration % log==0){
					console.log('iterations:',iteration,' time:',Date.now()-start,' error:',error);
				}
			}
			return {iterations:iteration,error:error,time:Date.now()-start,test:test,generate:generate}
		}

		__proto.timingTask=function(options){
			if (this.network.inputs()!=2 || this.network.outputs()!=1)
				throw new Error('Invalid Network: must have 2 inputs and one output');
			if (typeof options=='undefined')
				options={};
			function getSamples (trainingSize,testSize){
				var size=trainingSize+testSize;
				var t=0;
				var set=[];
				for (var i=0;i < size;i++){
					set.push({input:[0,0],output:[0]});
				}
				while (t < size-20){
					var n=Math.round(Math.random()*20);
					set[t].input[0]=1;
					for (var j=t;j <=t+n;j++){
						set[j].input[1]=n / 20;
						set[j].output[0]=0.5;
					}
					t+=n;
					n=Math.round(Math.random()*20);
					for (var k=t+1;k <=(t+n)&& k < size;k++)
					set[k].input[1]=set[t].input[1];
					t+=n;
				};
				var trainingSet=[];
				var testSet=[];
				for (var l=0;l < size;l++)
				(l < trainingSize ? trainingSet :testSet).push(set[l]);
				return {train:trainingSet,test:testSet}
			};
			var iterations=options.iterations || 200;
			var error=options.error ||.005;
			var rate=options.rate || [.03,.02];
			var log=options.log===false ? false :options.log || 10;
			var cost=options.cost || this.cost || oneway.nn.Trainer.cost.MSE;
			var trainingSamples=options.trainSamples || 7000;
			var testSamples=options.trainSamples || 1000;
			var samples=getSamples(trainingSamples,testSamples);
			var result=this.train(samples.train,{rate:rate,log:log,iterations:iterations,error:error,cost:cost});
			return {train:result,test:this.test(samples.test)}
		}

		Trainer.shuffleInplace=function(o){
			for (var j,x,i=o.length;i;j=Math.floor(Math.random()*i),x=o[--i],o[i]=o[j],o[j]=x);
			return o;
		}

		__static(Trainer,
		['cost',function(){return this.cost=Cost;}
		]);
		return Trainer;
	})()


	/**
	*...
	*@author ww
	*/
	//class oneway.nn.networks.Perceptron extends oneway.nn.NetWork
	var Perceptron=(function(_super){
		function Perceptron(__argList){
			var argList=arguments;
			Perceptron.__super.call(this);
			var args=Array.prototype.slice.call(argList);
			if (args.length < 3)
				throw new Error('not enough layers (minimum 3) !!');
			var inputs=args.shift();
			var outputs=args.pop();
			var layers=args;
			var input=new Layer(inputs);
			var hidden=[];
			var output=new Layer(outputs);
			var previous=input;
			for (var i=0;i < layers.length;i++){
				var size=layers[i];
				var layer=new Layer(size);
				hidden.push(layer);
				previous.project(layer);
				previous=layer;
			}
			previous.project(output);
			this.set({input:input,hidden:hidden,output:output });
			this.trainer=new Trainer(this);
		}

		__class(Perceptron,'oneway.nn.networks.Perceptron',_super);
		return Perceptron;
	})(NetWork)



	new TestNN();

})(window,document,Laya);


/*
1 file:///D:/machinelearning/AS_Synaptic.git/trunk/lib/synaptic/src/oneway/nn/NetWork.as (465):warning:Blob This variable is not defined.
2 file:///D:/machinelearning/AS_Synaptic.git/trunk/lib/synaptic/src/oneway/nn/NetWork.as (468):warning:Worker This variable is not defined.
*/