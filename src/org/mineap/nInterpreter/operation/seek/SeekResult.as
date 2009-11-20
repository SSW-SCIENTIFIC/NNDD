package org.mineap.nInterpreter.operation.seek
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.ResultType;
	
	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class SeekResult implements IAnalyzeResult
	{
		
		/**
		 * 動画の再生位置を時間まで移動させる。再生時間のミリ秒を指定する。
		 */
		public var vpos:String = "";
		
		/**
		 * 文字列を設定した場合は移動する瞬間に画面が白で塗りつぶされ文字列が中央に表示される。
		 */
		public var msg:String = "";
		
		/**
		 * このコンストラクタは何もしません。
		 * 
		 */
		public function SeekResult()
		{
			//seek(vpos:時間,msg:文字列)
		}
		
		/**
		 * このIAnalyzeResultオブジェクトのResultTypeを返します。
		 * @return 
		 * 
		 */
		public function get resultType():ResultType
		{
			return ResultType.SEEK;
		}
	}
}