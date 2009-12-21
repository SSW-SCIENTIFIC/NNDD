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
	import flash.utils.unescapeMultiByte;
	
	import org.mineap.NNDD.util.PathMaker;

	[Event(name="watchSuccess", type="WatchVideoPage")]
	[Event(name="watchFail", type="WatchVideoPage")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class WatchVideoPage extends EventDispatcher
	{
		
		private var _watchLoader:URLLoader;
		
		//so.addVariable("videoId", "so8174126");
		private static const videoIdPattern:RegExp = new RegExp("addVariable.\"videoId\", \"([^\"]+)\".");
		
		private static const descriptionPattern:RegExp = new RegExp("description:     '([^']+)'");
		
		/**
		 * "http://www.nicovideo.jp/watch/"を表す定数です
		 */
		public static const WATCH_VIDEO_PAGE_URL:String = "http://www.nicovideo.jp/watch/";
		
		/**
		 * 
		 */
		public static const WATCH_SUCCESS:String = "WatchSuccess";
		
		/**
		 * 
		 */
		public static const WATCH_FAIL:String = "WatchFail";
		
		/**
		 * 
		 */
		private var _videoId:String = "";
		
		/**
		 * 
		 */
		private var _data:Object = "";
		
		/**
		 * 
		 * 
		 */
		public function WatchVideoPage()
		{
			this._watchLoader = new URLLoader();
		}
		
		/**
		 * 
		 * @param videoId
		 * @param isEconomyMode
		 * 
		 */
		public function watchVideo(videoId:String):void{
			
			this._videoId = videoId;
			
			var mUrl:String = WATCH_VIDEO_PAGE_URL + videoId;
			
			var watchURL:URLRequest = new URLRequest(mUrl);
			watchURL.method = "GET";
			watchURL.followRedirects = true;
			
			this._watchLoader.addEventListener(Event.COMPLETE, completeEventHandler);
			this._watchLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			this._watchLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			this._watchLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseHandler);
			this._watchLoader.load(watchURL);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getVideoId():String{
			
			if(this._watchLoader.data != null){
				
				var result:Array = videoIdPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					return result[1];
				}else{
					return this._videoId;
				}
				
			}else{
				return this._videoId;
			}
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getDescription():String{
			
			if (this._watchLoader.data != null) {
				
				var result:Array = descriptionPattern.exec(this._watchLoader.data);
				if(result != null && result.length > 1){
					return result[1];
				}else{
					return "";
				}
				
			} else {
				return "";
			}
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function completeEventHandler(event:Event):void{
			
			// TODO テスト
//			trace(this.getDescription());
			
			this._data = this._watchLoader.data;
			dispatchEvent(new Event(WATCH_SUCCESS));
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get data():Object{
			return this._data;
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorHandler(event:ErrorEvent):void{
			dispatchEvent(new ErrorEvent(WATCH_FAIL, false, false, event.text));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseHandler(event:HTTPStatusEvent):void{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._watchLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._watchLoader = null;
			
		}

	}
}