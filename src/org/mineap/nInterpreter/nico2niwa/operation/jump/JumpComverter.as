package org.mineap.nInterpreter.nico2niwa.operation.jump
{
	import org.mineap.nInterpreter.nico2niwa.operation.Nico2NiwaConverter;

	/**
	 * ニコスクリプトの@ジャンプ命令をニワン語に変換します。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class JumpComverter implements Nico2NiwaConverter
	{
		
		/**
		 * ＠ジャンプ命令のパラメータの数をカウントするのに使う正規表現です。
		 */
		public var JUMP_OPERATION_PARAM_COUNT:RegExp = new RegExp("([\\s+][\\S+])+");
		
		/**
		 * 次のニコスクリプトを解析する正規表現です。
		 * "＠ジャンプ ジャンプ先"
		 * ジャンプ先は、動画ID、"#再生時"、"#ラベル"のいずれかです。
		 */
		public static const JUMP_OPERATION_PATTERN1:RegExp = new RegExp("ジャンプ\\s+([\\S]+)");
		
		/**
		 * 次のニコスクリプトを解析する正規表現です。
		 * "＠ジャンプ ジャンプ先 [ジャンプメッセージ]"
		 * ジャンプ先は、動画ID、"#再生時"、"#ラベル"のいずれかです。
		 */
		public static const JUMP_OPERATION_PATTERN2:RegExp = new RegExp("ジャンプ\\s+([\\S]+)\\s+([\\S]+)")
		
		/**
		 * 次のニコスクリプトを解析する正規表現です。
		 * "＠ジャンプ ジャンプ先 [ジャンプメッセージ] [ジャンプ先再生開始位置]"
		 */
		public static const JUMP_OPERATION_PATTERN3:RegExp = new RegExp("ジャンプ\\s+([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)\\s+([\\S]+)\\s+([\\S]+)");
		
		/**
		 * 次のニコスクリプトを解析する正規表現です。
		 * "＠ジャンプ ジャンプ先 [ジャンプメッセージ] [ジャンプ先再生開始位置] [戻り秒数]"
		 */
		public static const JUMP_OPERATION_PATTERN4:RegExp = new RegExp("ジャンプ\\s+([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)\\s+([\\S]+)\\s+([\\S]+)\\s+([\\S]+)");
		
		/**
		 * 次のニコスクリプトを解析する正規表現です。
		 * "＠ジャンプ ジャンプ先 [ジャンプメッセージ] [ジャンプ先再生開始位置] [戻り秒数] [戻りメッセージ]"
		 */
		public static const JUMP_OPERATION_PATTERN5:RegExp = new RegExp("ジャンプ\\s+([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)\\s+([\\S]+)\\s+([\\S]+)\\s+([\\S]+)\\s+([\\S]+)");
		
		/**
		 * ジャンプ先が動画IDでないとき、時間指定なのかラベル指定なのかを調べるための正規表現です。
		 */
		public static const JUMP_TO_TIME_PATTERN:RegExp = new RegExp("#(\\d+):(\\d+)");
		
		public static const JUMP_TO_LABEL_PATTERN:RegExp = new RegExp("#([^\\s+])");
		
		/**
		 * 動画IDを表す正規表現です。
		 */
		public static const VIDEO_ID_PATTERN:RegExp = new RegExp("([A-LN-Za-ln-z0-9][A-Za-z0-9]\\d+)");
		
		private static const JUMP_PRE:String = "jump(";
		private static const JUMP_LAST:String = ")";
		private static const JUMP_COMMA:String = ",";
		private static const JUMP_P_ID:String = "id:"; 
		private static const JUMP_P_MSG:String = "msg:"; 
		private static const JUMP_P_FROM:String = "from:"; 
		private static const JUMP_P_LEN:String = "length:"; 
		private static const JUMP_P_RET:String = "retern:"; 
		private static const JUMP_P_RETMES:String = "returnmsg:"; 
		private static const JUMP_P_NEWWINDOW:String = "newwindow:"; 
		private static const JUMP_DOUBLE_QUOTE:String = "'";
		
		private static const SEEK_PRE:String = "seek(";
		private static const SEEK_LAST:String = ")";
		private static const SEEK_COMMA:String = ",";
		private static const SEEK_P_VPOS:String = "vpos:";
		private static const SEEK_P_MSG:String = "msg:";
		private static const SEEK_DOUBLE_QUOTE:String = "'";
		
		/**
		 * 
		 * 
		 */
		public function JumpComverter()
		{
		}
		
		/**
		 * 渡された@ジャンプ命令を、ニワン語に変換して返します。
		 * 
		 * @param source @ジャンプ命令
		 * @return ニワン語に変換された@ジャンプ命令。
		 * 
		 */
		public function converte(source:String):String{
			
			//パターン１ ＠ジャンプ ジャンプ先 [ジャンプメッセージ] [ジャンプ先再生開始位置] [戻り秒数] [戻りメッセージ]
			//パターン２ ＠ジャンプ　#再生秒数/#ジャンプマーカーラベル名　ジャンプメッセージ
			
			source = source.replace(new RegExp("　", "g"), " ");
			var paramCount:int = getParameterCount(source);
			var operation:String = "";
			
			if(paramCount >= 2){
				
				var array:Array = null;
				var jumpTo:Array = null;
				var min:int = 0;
				var sec:int = 0;
				var vpos:String = "0";
				
				switch(paramCount){
					case 2:
						//ジャンプ先のみ指定
						array = JUMP_OPERATION_PATTERN1.exec(source);
						if(array != null && array.length > 0){
							jumpTo = VIDEO_ID_PATTERN.exec(array[1]);
							if(jumpTo != null && jumpTo.length > 0){
								//ジャンプ先は動画ID
								operation = JUMP_PRE + JUMP_P_ID + 
									JUMP_DOUBLE_QUOTE + array[1] + JUMP_DOUBLE_QUOTE + 
										JUMP_LAST;
							}else{
								jumpTo = JUMP_TO_TIME_PATTERN.exec(array[1]);
								if(jumpTo != null){
									if(jumpTo.length == 3){
										//ジャンプ先は指定された時間
										min = jumpTo[1];
										sec = jumpTo[2];
										vpos = String(int(((min*60) + sec)*100));
										
										operation = SEEK_PRE + SEEK_P_VPOS + 
											SEEK_DOUBLE_QUOTE + vpos + SEEK_DOUBLE_QUOTE + 
												SEEK_LAST;
										
									}
								}else{
									jumpTo = JUMP_TO_LABEL_PATTERN.exec(array[1]);
									if(jumpTo.length == 2){
										//TODO ラベル指定の＠ジャンプは未実装
//										operation = JUMP_PRE + JUMP_P_ID + 
//											JUMP_DOUBLE_QUOTE + jumpTo[1] + JUMP_DOUBLE_QUOTE + 
//												JUMP_LAST;
										
										trace("ラベル指定の＠ジャンプは未実装");
										
									} 
								}
							}
						}
						break;
					case 3:
						array = JUMP_OPERATION_PATTERN2.exec(source);
						if(array != null && array.length > 0){
							jumpTo = VIDEO_ID_PATTERN.exec(array[1]);
							if(jumpTo != null && jumpTo.length > 0){
								//ジャンプ先はID
								operation = JUMP_PRE + 
									JUMP_P_ID + JUMP_DOUBLE_QUOTE + array[1] + JUMP_DOUBLE_QUOTE + 
										JUMP_COMMA + 
											JUMP_P_MSG + JUMP_DOUBLE_QUOTE + array[2] + JUMP_DOUBLE_QUOTE + 
												JUMP_LAST;
							}else{
								jumpTo = JUMP_TO_TIME_PATTERN.exec(array[1]);
								if(jumpTo != null){
									if(jumpTo.length == 3){
										//ジャンプ先は指定された時間
										min = jumpTo[1];
										sec = jumpTo[2];
										vpos = String(int(((min*60) + sec)*100));
										
										operation = SEEK_PRE + SEEK_P_VPOS + 
											SEEK_DOUBLE_QUOTE + vpos + SEEK_DOUBLE_QUOTE + 
												SEEK_LAST;
										
									}
								}else{
									jumpTo = JUMP_TO_LABEL_PATTERN.exec(array[1]);
									if(jumpTo.length == 2){
										//TODO ラベル指定の＠ジャンプは未実装
//										operation = JUMP_PRE + JUMP_P_ID + 
//											JUMP_DOUBLE_QUOTE + jumpTo[1] + JUMP_DOUBLE_QUOTE + 
//												JUMP_LAST;
										
										trace("ラベル指定の＠ジャンプは未実装");
										
									} 
								}
							}
						}
						break;
					case 4:
						// TODO 第3引数以降は無視
						array = JUMP_OPERATION_PATTERN3.exec(source);
						if(array != null && array.length > 0){
							operation = JUMP_PRE + 
								JUMP_P_ID + JUMP_DOUBLE_QUOTE + array[1] + JUMP_DOUBLE_QUOTE + 
									JUMP_COMMA + 
										JUMP_P_MSG + JUMP_DOUBLE_QUOTE + array[2] + JUMP_DOUBLE_QUOTE + 
											JUMP_LAST;
						}
						break;
					case 5:
						// TODO 第3引数以降は無視
						array = JUMP_OPERATION_PATTERN4.exec(source);
						if(array != null && array.length > 0){
							operation = JUMP_PRE + 
								JUMP_P_ID + JUMP_DOUBLE_QUOTE + array[1] + JUMP_DOUBLE_QUOTE + 
									JUMP_COMMA + 
										JUMP_P_MSG + JUMP_DOUBLE_QUOTE + array[2] + JUMP_DOUBLE_QUOTE + 
											JUMP_LAST;
						}
						break;
					case 6:
						// TODO 第3引数以降は無視
						array = JUMP_OPERATION_PATTERN5.exec(source);
						if(array != null && array.length > 0){
							operation = JUMP_PRE + 
								JUMP_P_ID + JUMP_DOUBLE_QUOTE + array[1] + JUMP_DOUBLE_QUOTE + 
									JUMP_COMMA + 
										JUMP_P_MSG + JUMP_DOUBLE_QUOTE + array[2] + JUMP_DOUBLE_QUOTE + 
											JUMP_LAST;
						}
						break;
					default:
						break;
				}
				
			}
			
			return operation;
			
		}
		
		/**
		 * パラメータの個数を返します。
		 * @param source
		 * @return 
		 * 
		 */
		private function getParameterCount(source:String):int{
			
			var parameterSeparatorPattern:RegExp = new RegExp("([\\s]+[\\S]+)", "ig");
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