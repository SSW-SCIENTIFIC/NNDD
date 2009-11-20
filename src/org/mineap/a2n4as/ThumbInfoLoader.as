package org.mineap.a2n4as
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * サムネイル情報を取得します。
	 * 取得結果は、addEventListener()で登録したリスナから取得します。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class ThumbInfoLoader
	{
		
		private var _thumbInfoLoader:URLLoader;
		
		public function ThumbInfoLoader()
		{
			this._thumbInfoLoader = new URLLoader();
			
		}
		
		/**
		 * 指定したビデオIDの動画のサムネイル情報を取得します。
		 * 
		 * @param videoId
		 * @return 
		 * 
		 */
		public function getThumbInfo(videoId:String):void{
			
			//http://www.nicovideo.jp/api/getthumbinfo/動画ID
			this._thumbInfoLoader.load(new URLRequest("http://www.nicovideo.jp/api/getthumbinfo/" + videoId));
			
		}
		
		/**
		 * サムネイル情報取得用のURLLoaderにリスナを追加します。
		 * 
		 * @param event
		 * @param listener
		 * 
		 */
		public function addEventListener(event:String, listener:Function):void{
		 	this._thumbInfoLoader.addEventListener(event, listener);
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._thumbInfoLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._thumbInfoLoader = null;
		}

	}
}