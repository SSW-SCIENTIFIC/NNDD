package org.mineap.nndd.download
{
	public class DownloadStatusType
	{
		
		/**
		 * ダウンロードが完了しています(0)
		 */
		public static const COMPLETE:DownloadStatusType = new DownloadStatusType(0);
		
		/**
		 * リトライオーバーでダウンロードを中止しました(1)
		 */
		public static const RETRY_OVER:DownloadStatusType = new DownloadStatusType(1);
		
		/**
		 * ダウンロード中です(2)
		 */
		public static const DOWNLOADEING:DownloadStatusType = new DownloadStatusType(2);
		
		/**
		 * ダウンロードが開始されていません(3)
		 */
		public static const NOT_START:DownloadStatusType = new DownloadStatusType(3);
		
		
		private var _value:int = 0;
		
		public function DownloadStatusType(value:int)
		{
			this._value = value;
		}
		
		public function get value():int{
			return this._value;
		}
		
	}
}