package org.mineap.a2n4as
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	[Event(name="success", type="ApiGetBgmAccess")]
	[Event(name="fail", type="ApiGetBgmAccess")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * ニコニコ動画のAPI(getbgm)へのアクセスを担当するクラスです。
	 *  
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ApiGetBgmAccess extends EventDispatcher
	{
		
		public static const SUCCESS:String = "Success";
		
		public static const FAIL:String = "Fail";
		
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
			var url:String = "http://flapi.nicovideo.jp/api/getbgm?v=" + threadID + "&as3=1";
			getAPIResult = new URLRequest(url);
			getAPIResult.method = "GET";
			
			this._loader.addEventListener(Event.COMPLETE, getBgmSuccess);
			this._loader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			this._loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			
			this._loader.load(getAPIResult);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorEventHandler(event:ErrorEvent):void{
			removeHandler(event.currentTarget as URLLoader);
			dispatchEvent(new ErrorEvent(FAIL, false, false, event.text));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseStatusEventHandler(event:HTTPStatusEvent):void{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function getBgmSuccess(event:Event):void{
			removeHandler(event.currentTarget as URLLoader);
			dispatchEvent(new Event(SUCCESS));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function removeHandler(target:URLLoader):void{
			target.removeEventListener(Event.COMPLETE, getBgmSuccess);
			target.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			target.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get data():Object{
			return this._loader.data;
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
					if(/*temp.movie_type.text() == "swf" && */temp.bgm_type.text() == "cm"){
						var url:String = temp.url.text();
						if(url != null && url != ""){
							urls.push(url);
						}
					}
				}
//				trace(xml);
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
					if(/*temp.movie_type.text() == "swf" && */temp.bgm_type.text() == "cm"){
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
		 * 
		 * 
		 */
		public function close():void{
			try{
				removeHandler(this._loader);
				this._loader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._loader = null;
		}
		

	}
}