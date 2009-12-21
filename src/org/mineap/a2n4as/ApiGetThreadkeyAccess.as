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
	
	[Event(name="success", type="ApiGetThreadkeyAccess")]
	[Event(name="fail", type="ApiGetThreadkeyAccess")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * ニコニコ動画のAPI(getthreadkey)へのアクセスを担当するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ApiGetThreadkeyAccess extends EventDispatcher
	{
		
		private var _loader:URLLoader;
		
		private var _result:String;
		
		public static const SUCCESS:String = "Success";
		
		public static const FAIL:String = "Fail";
		
		public function ApiGetThreadkeyAccess()
		{
			this._loader = new URLLoader();
		}
		
		/**
		 * スレッドキーを取得するためのAPIへのアクセスを行う
		 * 
		 * @param threadId スレッドID
		 * 
		 */
		public function getthreadkey(threadId:String):void
		{
			
			var getAPIRequest:URLRequest;
			var url:String = "http://flapi.nicovideo.jp/api/getthreadkey?thread=" + threadId;
			
			getAPIRequest = new URLRequest(url);
			getAPIRequest.method = "GET";
			
			this._loader.addEventListener(Event.COMPLETE, getthreadkeySuccess);
			this._loader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			this._loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._loader.load(getAPIRequest);
			
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
		private function getthreadkeySuccess(event:Event):void{
			this._result = this._loader.data;
			removeHandler(event.currentTarget as URLLoader);
			dispatchEvent(new Event(SUCCESS));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function removeHandler(target:URLLoader):void{
			target.removeEventListener(Event.COMPLETE, getthreadkeySuccess);
			target.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			target.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get result():String{
			return this._result;
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
				
			}
		}
		
		
	}
}