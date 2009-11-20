package org.mineap.nInterpreter.operation.seek
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.operation.IOperationAnalyzer;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class SeekOperationAnalyzer implements IOperationAnalyzer
	{
		
		/**
		 * seek(vpos:時間)
		 */
		public static const SEEK_OPERATION_PATTERN_1:RegExp = new RegExp("seek\\(vpos:['\"]([^'\"]*)['\"][\\s]*\\)");
		
		/**
		 * seek(vpos:時間,msg:文字列)
		 */
		public static const SEEK_OPERATION_PATTERN_2:RegExp = new RegExp("seek\\(vpos:['\"]([^'\"]*)['\"][\\s]*,msg:['\"]([^'\"]*)['\"][\\s]*\\)");
		
		/**
		 * 
		 * 
		 */
		public function SeekOperationAnalyzer()
		{
		}
		
		/**
		 * seek命令を解析し、その結果を返します。
		 * 
		 * @param source 解析したいseek命令
		 * @return SeekResultオブジェクト
		 * 
		 */
		public function analyze(source:String):IAnalyzeResult
		{
			//seek(vpos:時間,msg:文字列)
			
			var result:SeekResult = null;
			var resultArray:Array = null;
			var paraCount:int = getParameterCount(source);
			
			if(paraCount >= 1){
				
				switch(paraCount){
					case 1:
						//引数が一つ
						resultArray = SEEK_OPERATION_PATTERN_1.exec(source);
						if(resultArray != null && resultArray.length > 0){
							result = new SeekResult();
							result.vpos = String(resultArray[1]);
						}
						break;
					case 2:
						resultArray = SEEK_OPERATION_PATTERN_2.exec(source);
						if(resultArray != null && resultArray.length > 0){
							result = new SeekResult();
							result.vpos = String(resultArray[1]);
							result.msg = String(resultArray[2]);
						}
						break;
					default:
						break;
				}
			}
			
			return result;
		}
		
		/**
		 * パラメータの個数を返します。
		 * @param source
		 * @return 
		 * 
		 */
		private function getParameterCount(source:String):int{
			
			var parameterSeparatorPattern:RegExp = new RegExp("(['\"][\\s]*,)+", "ig");
			var array:Array = parameterSeparatorPattern.exec(source);
			var count:int = 1;
			while(array != null){
				if(array.length > 0){
					count++;
				}
				array = null;
				array = parameterSeparatorPattern.exec(source);
			}
			
			return count;
		}
		
	}
}