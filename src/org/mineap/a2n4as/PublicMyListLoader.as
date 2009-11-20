package org.mineap.a2n4as
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	
	public class PublicMyListLoader
	{
		
		private var _myListLoader:URLLoader;
		
		/**
		 * 
		 * 
		 */
		public function PublicMyListLoader()
		{
			this._myListLoader = new URLLoader();
		}
		
		/**
		 * 
		 * @param myListId
		 * 
		 */
		public function getPublicMyList(myListId:String):void{
			
//			feed://www.nicovideo.jp/mylist/7121837?rss=2.0
			
			var request:URLRequest = new URLRequest("http://www.nicovideo.jp/mylist/" + myListId + "?rss=2.0");
			
			this._myListLoader.load(request);
			
		}
		
		/**
		 * URLLoaderにリスナを追加します。
		 * @param event
		 * @param listener
		 * 
		 */
		public function addEventListener(event:String, listener:Function):void{
			this._myListLoader.addEventListener(event, listener);
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._myListLoader.close()
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._myListLoader = null;
		}
		
		

	}
}