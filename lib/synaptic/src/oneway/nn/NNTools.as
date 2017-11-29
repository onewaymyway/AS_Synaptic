package oneway.nn 
{
	/**
	 * ...
	 * @author ww
	 */
	public class NNTools 
	{
		
		public function NNTools() 
		{
			
		}
		
		public static function createFunction(code:String):Function
		{
			return __JS__("new Function(code)");
		}
		
		public static function now():Number
		{
			return __JS__('Date.now()');
		}
		
		/**
		 * 给传入的函数绑定作用域，返回绑定后的函数。
		 * @param	fun 函数对象。
		 * @param	scope 函数作用域。
		 * @return 绑定后的函数。
		 */
		public static function bind(fun:Function, scope:*):Function {
			var rst:Function = fun;
			__JS__("rst=fun.bind(scope);");
			return rst;
		}
	}

}