package org.mineap.a2n4as
{
	import flash.display.Loader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ニコニコ動画のAPI(getflv)へのアクセスを担当するクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class ApiGetFlvAccess
	{
		
		private var _loader:URLLoader;
		
		public function ApiGetFlvAccess()
		{
			this._loader = new URLLoader();
		}
		
		/**
		 * FLVのURLを取得する為のAPIへのアクセスを行う
		 * @param videoID ビデオID
		 * @param isEconomy 強制的にエコノミーにするかどうか。swfでは無視される。
		 * 
		 */
		public function getAPIResult(videoID:String, isEconomy:Boolean):void
		{
			//FLVのURLを取得する為にニコニコ動画のAPIにアクセスする
			if(videoID.indexOf("nm") != -1){
				
				//swfのとき。swfにエコノミーモードは存在しない
				videoID = videoID + "?as3=1";
				
			}else{
				if(isEconomy){
					videoID = videoID + "?eco=1";
				}
			}
			
			var getAPIResult:URLRequest;
			var url:String = "http://www.nicovideo.jp/api/getflv/" + videoID;
			
			getAPIResult = new URLRequest(url);
			getAPIResult.method = "GET";
			
			this._loader.load(getAPIResult);
		}
		
		/**
		 * APIの結果から現在エコノミーモードかどうかをチェックします。
		 * @return エコノミーモードの時true。
		 * 
		 */
		public function isEconomyMode():Boolean{
			var pattern:RegExp = new RegExp("&url=http.*low&link=");
			if(this._loader.data.search(pattern) != -1){
				return true;
			}
			return false;
		}
		
		/**
		 * URLLoaderにリスナを追加します。
		 * 
		 * @param event
		 * @param listener
		 * 
		 */
		public function addEventListener(event:String, listener:Function):void{
			this._loader.addEventListener(event, listener);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get data():String{
			return this._loader.data;
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._loader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._loader = null;
		}
		
	}
}