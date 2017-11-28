package oneway.nn {
	
	/**
	 * ...
	 * @author ww
	 */
	public class Cost {
		
		public function Cost() {
		
		}
		
		public static function CROSS_ENTROPY(target, output) {
			var crossentropy = 0;
			for (var i in output)
				crossentropy -= (target[i] * Math.log(output[i] + 1e-15)) + ((1 - target[i]) * Math.log((1 + 1e-15) - output[i])); // +1e-15 is a tiny push away to avoid Math.log(0)
			return crossentropy;
		}
		
		public static function MSE(target, output) {
			var mse = 0;
			for (var i = 0; i < output.length; i++)
				mse += Math.pow(target[i] - output[i], 2);
			return mse / output.length;
		}
		
		public static function BINARY(target, output) {
			var misses = 0;
			for (var i = 0; i < output.length; i++)
				misses += Math.round(target[i] * 2) != Math.round(output[i] * 2);
			return misses;
		}
	
	}

}