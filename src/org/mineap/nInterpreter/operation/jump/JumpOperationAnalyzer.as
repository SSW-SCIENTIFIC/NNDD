package org.mineap.nInterpreter.operation.jump
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.operation.IOperationAnalyzer;

	public class JumpOperationAnalyzer implements IOperationAnalyzer
	{
		
		/**
		 * 「jump(id:'動画ID')」を解析するための正規表現
		 */
		public static const JUMP_OPERATION_PATTERN_1:RegExp = new RegExp("jump\\(i?d?:?['\"]([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)['\"][\\s]*\\)");
		
		/**
		 * 「jump(id:'動画ID',msg:'メッセージ')」を解析するための正規表現
		 */
		public static const JUMP_OPERATION_PATTERN_2:RegExp = new RegExp("jump\\(i?d?:?['\"]([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)['\"][\\s]*,msg:['\"]([^'\"]*)['\"][\\s]*\\)");
		
		/**
		 * 「jump(id:'動画ID',msg:'メッセージ',from:'開始位置')」を解析するための正規表現
		 */
		public static const JUMP_OPERATION_PATTERN_3:RegExp = new RegExp("jump\\(i?d?:?['\"]([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)['\"][\\s]*,msg:['\"]([^'\"]*)['\"][\\s]*,from:['\"]([^'\"]*)['\"][\\s]*\\)");
		
		/**
		 * 「jump(id:'動画ID',msg:'メッセージ',from:'開始位置',length:'再生時間')」を解析するための正規表現
		 */
		public static const JUMP_OPERATION_PATTERN_4:RegExp = new RegExp("jump\\(i?d?:?['\"]([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)['\"][\\s]*,msg:['\"]([^'\"]*)['\"][\\s]*,from:['\"]([^'\"]*)['\"][\\s]*,length:['\"]([^'\"]*)['\"][\\s]*\\)");
		
		/**
		 * 「jump(id:'動画ID',msg:'メッセージ',from:'開始位置',length:'再生時間',return:'戻り')」を解析するための正規表現
		 */
		public static const JUMP_OPERATION_PATTERN_5:RegExp = new RegExp("jump\\(i?d?:?['\"]([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)['\"][\\s]*,msg:['\"]([^'\"]*)['\"][\\s]*,from:['\"]([^'\"]*)['\"][\\s]*,length:['\"]([^'\"]*)['\"][\\s]*,return:['\"]([^'\"]*)['\"][\\s]*\\)");
		
		/**
		 * 「jump(id:'動画ID',msg:'メッセージ',from:'開始位置',length:'再生時間',return:'戻り',returmmsg:'戻りメッセージ')」を解析するための正規表現
		 */
		public static const JUMP_OPERATION_PATTERN_6:RegExp = new RegExp("jump\\(i?d?:?['\"]([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)['\"][\\s]*,msg:['\"]([^'\"]*)['\"][\\s]*,from:['\"]([^'\"]*)['\"][\\s]*,length:['\"]([^'\"]*)['\"][\\s]*,return:['\"]([^'\"]*)['\"][\\s]*,returnmsg['\"]([^'\"]*)['\"][\\s]*\\)");
		
		/**
		 * 「jump(id:'動画ID',msg:'メッセージ',from:'開始位置',length:'再生時間',return:'戻り',returmmsg:'戻りメッセージ',newwindow:'対象窓')」を解析するための正規表現
		 */
		public static const JUMP_OPERATION_PATTERN_7:RegExp = new RegExp("jump\\(i?d?:?['\"]([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)['\"][\\s]*,msg:['\"]([^'\"]*)['\"][\\s]*,from:['\"]([^'\"]*)['\"][\\s]*,length:['\"]([^'\"]*)['\"][\\s]*,return:['\"]([^'\"]*)['\"][\\s]*,returnmsg['\"]([^'\"]*)['\"][\\s]*,newwindow:['\"]([^'\"]*)['\"][\\s]*\\)");
		
		
		/**
		 * 
		 * 
		 */
		public function JumpOperationAnalyzer()
		{
		}
		
		/**
		 * 渡された文字列を解析し、AnalyzeResultに結果を格納して返します。
		 * 
		 * @param source 
		 * @return 解析結果
		 * 
		 */
		public function analyze(source:String):IAnalyzeResult{
			
			//jump(id:動画ID,msg:ジャンプメッセージ,from:開始位置,length:再生時間,return:戻り,returnmsg:戻りメッセージ,newwindow:対象窓)
			
			var result:JumpResult = null;
			var resultArray:Array = null;
			source = getJumpOperation(source);
			var paraCount:int = getParameterCount(source);
			
			if(paraCount >= 1){
				//引数が一つ
				switch(paraCount){
					case 1:
						resultArray = JUMP_OPERATION_PATTERN_1.exec(source);
						if(resultArray != null && resultArray.length > 0){
							result = new JumpResult();
							result.id = String(resultArray[1]);
						}
						break;
					case 2:
						resultArray = JUMP_OPERATION_PATTERN_2.exec(source);
						if(resultArray != null && resultArray.length > 0){
							result = new JumpResult();
							result.id = String(resultArray[1]);
							result.msg = String(resultArray[2]);
						}
						break;
					case 3:
						resultArray = JUMP_OPERATION_PATTERN_3.exec(source);
						if(resultArray != null && resultArray.length > 0){
							result = new JumpResult();
							result.id = String(resultArray[1]);
							result.msg = String(resultArray[2]);
							result.from = String(resultArray[3]);
						}
						break;
					case 4:
						resultArray = JUMP_OPERATION_PATTERN_4.exec(source);
						if(resultArray != null && resultArray.length > 0){
							result = new JumpResult();
							result.id = String(resultArray[1]);
							result.msg = String(resultArray[2]);
							result.from = String(resultArray[3]);
							result.length = String(resultArray[4]);
						}
						break;
					case 5:
						resultArray = JUMP_OPERATION_PATTERN_5.exec(source);
						if(resultArray != null && resultArray.length > 0){
							result = new JumpResult();
							result.id = String(resultArray[1]);
							result.msg = String(resultArray[2]);
							result.from = String(resultArray[3]);
							result.length = String(resultArray[4]);
							result.isReturn = Boolean(resultArray[5]);
						}
						break;
					case 6:
						resultArray = JUMP_OPERATION_PATTERN_6.exec(source);
						if(resultArray != null && resultArray.length > 0){
							result = new JumpResult();
							result.id = String(resultArray[1]);
							result.msg = String(resultArray[2]);
							result.from = String(resultArray[3]);
							result.length = String(resultArray[4]);
							result.isReturn = Boolean(resultArray[5]);
							result.returnMessage = String(resultArray[6]);
						}
						break;
					case 7:
						resultArray = JUMP_OPERATION_PATTERN_7.exec(source);
						if(resultArray != null && resultArray.length > 0){
							result = new JumpResult();
							result.id = String(resultArray[1]);
							result.msg = String(resultArray[2]);
							result.from = String(resultArray[3]);
							result.length = String(resultArray[4]);
							result.isReturn = Boolean(resultArray[5]);
							result.returnMessage = String(resultArray[6]);
							result.isNewWindow = Boolean(resultArray[7]);
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
		
		/**
		 * 
		 * @param sorce
		 * @param startIndex
		 * @return 
		 * 
		 */
		public function getJumpOperation(source:String, startIndex:Number = 0):String{
			
			var index:Number = source.indexOf("jump(", startIndex);
			var tempStartIndex:Number = index;
			if(index != -1){
				
				//文字列を探す
				var startStringIndex:Number = -1;
				var endStringIndex:Number = -1;
				var tempEndStringIndex:Number = -1;
				
				var endIndex:Number = -1;
				
				for(var i:int = 0; i<100; i++){
					
					//関数の終わりと思われる箇所を探す
					endIndex = source.indexOf(")", index);
	
					startStringIndex = -1;
					endStringIndex = -1;
					
					startStringIndex = source.indexOf("\"", index);
					if(startStringIndex != -1){
						endStringIndex = source.indexOf("\"", startStringIndex+1);
					}
					var tempStart:Number = source.indexOf("'", index);
					if(tempStart != -1){
						var tempEnd:Number = source.indexOf("'", tempStart+1);
					}
					if(startStringIndex == -1 || tempStart < startStringIndex){
						startStringIndex = tempStart;
						endStringIndex = tempEnd;
					}
					
					//文字列があったのであれば、文字列の最後をstartIndexに変更
					if(startStringIndex != -1 && endStringIndex != -1){
						
						//endIndexがstartStringIndexより前なら終了
						if(endIndex <= startStringIndex && tempEndStringIndex < endIndex){
							//この関数の終わりは有効
							break;
						}
						
						index = endStringIndex+1;
						tempEndStringIndex = endStringIndex;
						
					}else{
						//文字列無し、この関数の終わりは有効
						break;
					}
					
					
					
				}
				
				
				
				//jump命令の中にjump命令が入る事は無い
//				var subSource:String = getJumpOperation(source, index+1);
				
//				if(subSource == null){
//					//この関数の終わりを探す
//					endIndex = source.indexOf(")", startIndex);
//					
//				}else{
//					//入れ子の関数の分を考慮してこの関数の終わりを探す
//					endIndex = source.indexOf(")", startIndex+subSource.length);
//					
//				}
				
				if(endIndex == -1){
					trace("関数の終わりが不正です。( \")\"が見つかりません。 )");
					return null;
				}else{
					return source.substring(tempStartIndex, endIndex+1);
				}
			}else{
				return null;
			}
			
		}
		
	}
}