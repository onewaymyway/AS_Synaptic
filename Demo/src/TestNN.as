package  
{
	import oneway.nn.NetWork;
	import oneway.nn.networks.HopField;
	import oneway.nn.networks.Liquid;
	import oneway.nn.networks.LSTM;
	import oneway.nn.networks.Perceptron;
	import oneway.nn.Neuron;
	/**
	 * ...
	 * @author ww
	 */
	public class TestNN 
	{
		
		public function TestNN() 
		{
			Neuron;
			NetWork;
			HopField;
			Liquid;
			LSTM;
			Perceptron;
			testNet();
		}
		
		private function testNet():void
		{
			var pNet:Perceptron;
			pNet = new Perceptron(2, 3, 1);
			pNet.trainer.XOR();
			trace(pNet.activate([0, 0]));
			trace(pNet.activate([1, 0]));
			trace(pNet.activate([0, 1]));
			trace(pNet.activate([1,1]));
		}
	}

}