package org.mineap.nndd.model
{
	import org.mineap.nndd.util.PathMaker;

	public class DownloadQueueItem
	{
		
		/**
		 * キューに追加したNNDDVideoです
		 */
		public var nnddVideo:NNDDVideo;
		
		/**
		 * キューに追加した日付です
		 */
		public var date:Date;
		
		public function DownloadQueueItem(nnddVideo:NNDDVideo, date:Date = null)
		{
			this.nnddVideo = nnddVideo;
			if(date == null){
				this.date = new Date();
			}else{
				this.date = date;
			}
		}
		
		/**
		 * ダウンロードIDを返します。
		 * @return 
		 * 
		 */
		public function getDownloadID():String{
			return date.time.toString() + "-" + PathMaker.getVideoID(nnddVideo.getDecodeUrl());
		}
		
	}
}