package oneway.nn {
	
	/**
	 * ...
	 * @author ww
	 */
	public class LayerConnection {
		public static var connections:int = 0;
		
		public static function uid():int {
			return connections++;
		}
		public var ID:int;
		public var from:Layer;
		public var to:Layer;
		public var selfconnection:Boolean;
		public var type:String;
		public var list:Array;
		public var size:int;
		public var gatedfrom:Array;
		public var connections:Object;
		public function LayerConnection(fromLayer:Layer, toLayer:Layer, type:String = null, weights:* = null) {
			this.ID = LayerConnection.uid();
			this.from = fromLayer;
			this.to = toLayer;
			this.selfconnection = toLayer == fromLayer;
			this.type = type;
			this.connections = {};
			this.list = [];
			this.size = 0;
			this.gatedfrom = [];
			
			if (this.type == null) {
				if (fromLayer == toLayer)
					this.type = Layer.connectionType.ONE_TO_ONE;
				else
					this.type = Layer.connectionType.ALL_TO_ALL;
			}
			
			if (this.type == Layer.connectionType.ALL_TO_ALL || this.type == Layer.connectionType.ALL_TO_ELSE) {
				for (var here:String in this.from.list) {
					for (var there:String in this.to.list) {
						var from:Neuron = this.from.list[here];
						var to:Neuron = this.to.list[there];
						if (this.type == Layer.connectionType.ALL_TO_ELSE && from == to)
							continue;
						var connection:Object = from.project(to, weights);
						
						this.connections[connection.ID] = connection;
						this.size = this.list.push(connection);
					}
				}
			}
			else if (this.type == Layer.connectionType.ONE_TO_ONE) {
				
				for (var neuron:String in this.from.list) {
					from = this.from.list[neuron];
					to = this.to.list[neuron];
					connection = from.project(to, weights);
					
					this.connections[connection.ID] = connection;
					this.size = this.list.push(connection);
				}
			}
			
			fromLayer.connectedTo.push(this);
		}
	
	}

}