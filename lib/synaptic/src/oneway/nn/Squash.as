package oneway.nn {
	
	/**
	 * ...
	 * @author ww
	 */
	public class Squash {
		
		public function Squash() {
		
		}
		
		public static function LOGISTIC(x:Number, derivate:Boolean = false):Number {
			var fx:Number = 1 / (1 + Math.exp(-x));
			if (!derivate)
				return fx;
			return fx * (1 - fx);
		}
		
		public static function TANH(x:Number, derivate:Boolean = false):Number {
			if (derivate)
				return 1 - Math.pow(Math["tanh"](x), 2);
			return Math["tanh"](x);
		}
		
		public static function IDENTITY(x:Number, derivate:Boolean = false):Number {
			return derivate ? 1 : x;
		}
		
		public static function HLIM(x:Number, derivate:Boolean = false):Number {
			return derivate ? 1 : x > 0 ? 1 : 0;
		}
		
		public static function RELU(x:Number, derivate:Boolean = false):Number {
			if (derivate)
				return x > 0 ? 1 : 0;
			return x > 0 ? x : 0;
		}
	
	}

}