package org.mineap.nndd.util
{
	public class NumberUtil
	{
		public function NumberUtil()
		{
		}
		
		/**
		 * 渡された数字に3桁ごとのカンマを追加します。
		 * @param str
		 * @return 
		 * 
		 */
		public static function addComma(str:String):String{
			
			var len:int = str.length;
			
			for(var i:int = 1; i<len; i++){
				var index:int = i*(-3)-(i-1);
				var b:String = str.substring(0, len+index);
				var a:String = str.substring(len+index);
				if(b.length == 0){
					break;
				}
				str =  b + "," + a;
				len++;
			}
			
			return str;
			
		}
		
	}
}