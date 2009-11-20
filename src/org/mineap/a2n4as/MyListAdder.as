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
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * 動画をマイリストに追加するためのクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class MyListAdder extends EventDispatcher
	{
		
		/**
		 * マイリストへの追加に成功すると、この文字列をEvent種別に持つEventが発行されます。
		 */
		public static const SUCCESS:String = "Success";
		
		/**
		 * マイリストへの追加に失敗すると、この文字列をEvent種別に持つErrorEventが発行されます。
		 */
		public static const FAIL:String = "Fail";
		
		/**
		 * マイリストに登録しようとしたが重複していたときに、この文字列をEvent種別に持つEventが発行されます。
		 */		
		public static const DUP_ERROR:String = "DupError";
		
		/**
		 * 指定された動画が存在しない時、この文字列をEvent種別に持つEventが発行されます。
		 */
		public static const NOTEXIST:String = "NotExist";
		
		/**
		 * 
		 */
		public static const API_MYLIST_ADD:String = "http://www.nicovideo.jp/api/mylist/add"
		
		private var _urlLoader:URLLoader = null;
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function MyListAdder()
		{
			this._urlLoader = new URLLoader();
		}
		
		/**
		 * マイリストに動画を追加します。
		 * 
		 * @param token 動画ページのHTMLから得られるtokenです
		 * @param group_id 動画を追加したいマイリストのIDです
		 * @param item_type
		 * @param item_id
		 */
		public function addMyList(token:String, group_id:String, item_type:String, item_id:String):void{
			
			var urlRequest:URLRequest = new URLRequest();
			urlRequest.url = API_MYLIST_ADD;
			urlRequest.method = URLRequestMethod.POST;
			
			var variables:URLVariables = new URLVariables();
			variables.token = token;
			variables.group_id = group_id;
			variables.item_id = item_id;
			variables.item_type = item_type;
			
			urlRequest.data = variables;
			this._urlLoader.addEventListener(Event.COMPLETE, completeHandler);
			this._urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpResponseEventHandler);
			this._urlLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			this._urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			this._urlLoader.load(urlRequest);

		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function completeHandler(event:Event):void{
			var result:String = String((event.currentTarget as URLLoader).data);
			trace(result);
			if(result.indexOf("ok") != -1){
				dispatchEvent(new Event(MyListAdder.SUCCESS, false, false));
			}else if(result.indexOf("\"code\":\"EXIST\"") != -1){
				dispatchEvent(new Event(MyListAdder.DUP_ERROR, false, false));
			}else if(result.indexOf("\"code\":\"NONEXIST\"") != -1){
				dispatchEvent(new Event(MyListAdder.NOTEXIST, false, false));
			}else{
				dispatchEvent(new ErrorEvent(MyListAdder.FAIL, false, false, event.toString()));
			}
			
			close();
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorHandler(event:ErrorEvent):void{
			trace(event);
			dispatchEvent(new ErrorEvent(MyListAdder.FAIL, false, false, event + ":" + event.text));
			
			close();
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseEventHandler(event:HTTPStatusEvent):void{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				if(this._urlLoader != null){
					this._urlLoader.close();
					this._urlLoader = null;
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
		}
		
		
	}
}