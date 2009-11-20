package org.mineap.nInterpreter.operation.jump
{
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.ResultType;

	/**
	 * jump命令の解析結果を格納するクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class JumpResult implements IAnalyzeResult
	{
		
		/**
		 * 動画のIDを指定する。ちなみに id: は省略できる。
		 */
		public var id:String = "";
		
		/**
		 * ジャンプする直前にメッセージを表示する。未設定でもそれ用のメッセージが表示される。
		 */
		public var msg:String = "";
		
		/**
		 * 指定した再生時から再生する。ただし、移動先は動画を完全に読み込むまで再生が開始されなくなる。
		 */
		public var from:String = "";
		
		/**
		 * ジャンプした先の動画の再生を指定時間で終了する。
		 */
		public var length:String = "";
		
		/**
		 * trueなら再生終了時に移動前の動画へ戻る。
		 */
		public var isReturn:Boolean = false;
		
		/**
		 * ジャンプ先から戻るときに表示される。
		 */
		public var returnMessage:String = "";
		
		/**
		 * trueなら新しいウインドウで、falseなら同じウィンドウでURLを開く。
		 */
		public var isNewWindow:Boolean = false;
		
		
		/**
		 * このコンストラクタは何もしません。
		 * 
		 */
		public function JumpResult()
		{
			//jump(id:動画ID,msg:ジャンプメッセージ,from:開始位置,length:再生時間,return:戻り,returnmsg:戻りメッセージ,newwindow:対象窓)
		}
		
		
		/**
		 * このResultクラスのタイプを返します。
		 * 
		 * @return 
		 * 
		 */
		public function get resultType():ResultType{
			return ResultType.JUMP;
		}
		
	}
}