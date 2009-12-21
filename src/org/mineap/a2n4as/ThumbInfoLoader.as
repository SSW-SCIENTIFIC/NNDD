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
	
	[Event(name="success", type="Event")]
	[Event(name="fail", type="ErrorEvent")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * サムネイル情報を取得します。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class ThumbInfoLoader extends EventDispatcher
	{
		
		private var _thumbInfoLoader:URLLoader;
		
		private var _thumbInfo:String;
		
		public static const SUCCESS:String = "Success";
		
		public static const FAIL:String = "Fail";
		
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
//			this._thumbInfoLoader.load(new URLRequest("http://www.nicovideo.jp/api/getthumbinfo/" + videoId));
			
			this._thumbInfoLoader.addEventListener(Event.COMPLETE, getThumbInfoSuccess);
			this._thumbInfoLoader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			this._thumbInfoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			this._thumbInfoLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._thumbInfoLoader.load(new URLRequest("http://ext.nicovideo.jp/api/getthumbinfo/" + videoId));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function getThumbInfoSuccess(event:Event):void{
			try{
				this._thumbInfo = event.currentTarget.data;
			}catch(error:Error){
				trace(error.getStackTrace());
				dispatchEvent(new ErrorEvent(FAIL, false, false, error.toString()));
			}
			dispatchEvent(new Event(SUCCESS));
			removeAllHandler();
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorEventHandler(event:ErrorEvent):void{
			dispatchEvent(new ErrorEvent(FAIL, false, false, event.text));
			removeAllHandler();
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
		 * @param target
		 * 
		 */
		private function removeAllHandler():void{
			this._thumbInfoLoader.removeEventListener(Event.COMPLETE, getThumbInfoSuccess);
			this._thumbInfoLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._thumbInfoLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			this._thumbInfoLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
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

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get thumbInfo():String
		{
			return _thumbInfo;
		}


	}
}