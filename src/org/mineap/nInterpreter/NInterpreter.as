package org.mineap.nInterpreter
{
	

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class NInterpreter
	{
		
		public static const SEPARATE_PATTERN:RegExp = new RegExp("[([^;]*);?]+");
		
		/**
		 * 
		 * 
		 */
		public function NInterpreter()
		{
			/* 何もしない */
		}
		
		/**
		 * 渡された命令を解析し、解析結果を返します。
		 * 
		 * @param source "/"で始まるニワン語、もしくは"@"で始まるニコスクリプト
		 * @return 解析結果
		 * 
		 */
		public function analyze(source:String):IAnalyzeResult{
			
			var firstChar:String = source.charAt(0);
			
			if(firstChar == "/"){
				
				
				//命令を分割
				var array:Array = separate(source);
				
				
				//中に式が入りうる命令
				//commentTrigger
				//ctrig
				//if
				//alternative
				
				
			}else if(firstChar == "@" || firstChar == "＠"){
				
				
			}
			
		}
		
		/**
		 * 渡された命令列を";"で区切って分割します。
		 * @param source
		 * @return 命令文字列を格納したArray
		 * 
		 */
		public function separate(source:String):Array{
			
			// a=true;if(a,then:dt(a,pos:'hidari'))
			var results:Array = SEPARATE_PATTERN.exec(source);
			var array:Array = new Array();
			
			if(results != null && results.length > 0){
				for(var i:int = 1; i < results.length; i++){
					array.push(results[i]);
				}
			}
			
			return array;
		}
		
		
	}
}