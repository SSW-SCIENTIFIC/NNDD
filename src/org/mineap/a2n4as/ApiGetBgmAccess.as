package org.mineap.a2n4as
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ニコニコ動画のAPI(getbgm)へのアクセスを担当するクラスです。
	 *  
	 * @author shiraminekeisuke
	 * 
	 */
	public class ApiGetBgmAccess
	{
		
		private var _loader:URLLoader;
		
		public function ApiGetBgmAccess()
		{
			this._loader = new URLLoader();
		}
		
		/**
		 * ニコ割等のURLを取得するためのAPIへのアクセスを行う
		 * @param threadID
		 * 
		 */
		public function getAPIResult(threadID:String):void
		{
			//ニコ割等のURLを取得するためにニコニコ動画のAPIにアクセスする。
			var getAPIResult:URLRequest;
			var url:String = "http://www.nicovideo.jp/api/getbgm?v=" + threadID + "&as3=1";
			getAPIResult = new URLRequest(url);
			getAPIResult.method = "GET";
			
			this._loader.load(getAPIResult);
		}
		
		/**
		 * APIアクセスの結果、得られたニコ割のURLをArrayに格納して返します。
		 * @return 
		 * 
		 */
		public function getNicowariUrl():Array{
			var xml:XML = new XML(this._loader.data);
			var urls:Array = new Array();
			if(xml.@status == "ok"){
				var xmlList:XMLList = xml.children();
				for each(var temp:XML in xmlList){
					if(temp.movie_type.text() == "swf" && temp.bgm_type.text() == "cm"){
						var url:String = temp.url.text();
						if(url != null && url != ""){
							urls.push(url);
						}
					}
				}
				trace(xml);
			}else{
				trace("解析失敗:" + xml);
			}
			
			return urls;
		}
		
		/**
		 * APIアクセスの結果、得られたニコ割のビデオIDをArrayに格納して返します。
		 * @return 
		 * 
		 */
		public function getNicowariVideoIds():Array{
			var xml:XML = new XML(this._loader.data);
			var ids:Array = new Array();
			if(xml.@status == "ok"){
				var xmlList:XMLList = xml.children();
				for each(var temp:XML in xmlList){
					if(temp.movie_type.text() == "swf" && temp.bgm_type.text() == "cm"){
						var id:String = temp.video_id.text();
						if(id != null && id != ""){
							ids.push(id);
						}
					}
				}
			}else{
				trace("解析失敗:" + xml);
			}
			
			return ids;
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