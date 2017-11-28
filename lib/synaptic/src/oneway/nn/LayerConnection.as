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
		
		public function LayerConnection(fromLayer:Layer, toLayer:Layer, type:String = null, weights:Array = null) {
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
				for (var here in this.from.list) {
					for (var there in this.to.list) {
						var from = this.from.list[here];
						var to = this.to.list[there];
						if (this.type == Layer.connectionType.ALL_TO_ELSE && from == to)
							continue;
						var connection = from.project(to, weights);
						
						this.connections[connection.ID] = connection;
						this.size = this.list.push(connection);
					}
				}
			}
			else if (this.type == Layer.connectionType.ONE_TO_ONE) {
				
				for (var neuron in this.from.list) {
					var from = this.from.list[neuron];
					var to = this.to.list[neuron];
					var connection = from.project(to, weights);
					
					this.connections[connection.ID] = connection;
					this.size = this.list.push(connection);
				}
			}
			
			fromLayer.connectedTo.push(this);
		}
	
	}

}