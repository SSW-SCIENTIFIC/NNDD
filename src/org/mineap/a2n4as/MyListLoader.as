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
	
	public class MyListLoader extends EventDispatcher
	{
		
		//<input type="hidden" name="csrf_token" value="66a938cdec2c49fbd87ff2a9ebf09a81f8c932c0">
		private static const tokenPattern:RegExp = new RegExp("NicoAPI.token = \"(.+)\";");
		
		//<option value="434361">おきに</option>
		private static const myListPattern:RegExp = new RegExp("<option value=\"(\\d+)\"[^>]*>([^<]+)</option>", "ig");
		
		private static const itemTypePattern:RegExp = new RegExp("<input type=\"hidden\" name=\"item_type\" value=\"(.+)\">", "ig");
		
		private static const itemIdPattern:RegExp = new RegExp("<input type=\"hidden\" name=\"item_id\" value=\"(.+)\">", "ig");
		
		public static const NICO_MYLIST_API_URL:String = "http://www.nicovideo.jp/mylist_add/video/";
		
		public static const GET_MYLISTGROUP_SUCCESS:String = "GetMyListGroupSuccess";
		
		public static const GET_MYLISTGROUP_FAILURE:String = "GetMyListGroupFailure";
		
		private var _loader:URLLoader;
		
		public function MyListLoader()
		{
			_loader = new URLLoader();
		}
		
		/**
		 * マイリストの一覧を取得します
		 * @param videoId
		 * 
		 */
		public function getMyListGroup(videoId:String):void{
			
			var url:String = NICO_MYLIST_API_URL + videoId;
			
			var urlRequest:URLRequest = new URLRequest(url);
			
			this._loader.addEventListener(Event.COMPLETE, completeEventHandler);
			this._loader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			this._loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusHandler);
			this._loader.load(urlRequest);
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseStatusHandler(event:HTTPStatusEvent):void{
			trace(event);
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		public function completeEventHandler(event:Event):void{
			
			trace(event);
			dispatchEvent(new Event(GET_MYLISTGROUP_SUCCESS));
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		public function errorEventHandler(event:ErrorEvent):void{
			
			trace(event);
			dispatchEvent(new ErrorEvent(GET_MYLISTGROUP_FAILURE, false, false, event.text));
			close();
			
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._loader.close();
			}catch(error:Error){
				trace(error);
			}
				
		}
		
		/**
		 * 
		 * @return 
		 * Array(
		 * 　　Array("マイリスト名", "マイリストID"),
		 *    Array("マイリスト名", "マイリストID"),
		 *    ...
		 * )
		 */
		public function getMyLists():Array{
			var myListArray:Array = new Array();
			
			if(this._loader != null && this._loader.data != null){
				
				var array:Array = myListPattern.exec(this._loader.data);
				
				while(true){
					if(array != null && array.length > 2){
						myListArray.push(new Array(array[2], array[1]));
						
						array = myListPattern.exec(this._loader.data);
					}else{
						break;
					}
				}
				
			}
			
			return myListArray;
		}
		
		/**
		 * Tokenを返します。存在しないときはnullです。
		 * @return 
		 * 
		 */
		public function getToken():String{
			
			if(this._loader == null || this._loader.data == null){
				return null;
			}
			
			var array:Array = tokenPattern.exec(this._loader.data);
			trace(array);
			if(array != null && array.length > 1){
				return array[1];
			}else{
				return null;
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getItemId():String{
			if(this._loader == null || this._loader.data == null){
				return null;
			}
			
			var array:Array = itemIdPattern.exec(this._loader.data);
			trace(array);
			if(array != null && array.length > 1){
				return array[1];
			}else{
				return null;
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getItemType():String{
			if(this._loader == null || this._loader.data == null){
				return null;
			}
			
			var array:Array = itemTypePattern.exec(this._loader.data);
			trace(array);
			if(array != null && array.length > 1){
				return array[1];
			}else{
				return null;
			}
		}
		

	}
}