package org.mineap.a2n4as
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/**
	 * サムネイル画像を取得するクラスです。
	 * 取得結果は、addEventListener()で登録したリスナから取得します。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class ThumbImgLoader extends EventDispatcher
	{
		
		private var _thumbInfoLoader:ThumbInfoLoader;
		private var _thumbImgLoader:URLLoader;
		private var _videoId:String;
		
		/**
		 * サムネイル情報XMLの解析に失敗した事を表します。
		 */
		public static const THUMB_INFO_PARSE_ERROR:String = "ThumbInfoParseError";
		/**
		 * サムネイル情報XML内にサムネイル画像URLが見つからなかった事を表します。
		 */
		public static const THUMB_IMG_URL_NOTFOUND_ERROR:String = "ThumbImageNotFoundError";
		
		public function ThumbImgLoader()
		{
			this._thumbInfoLoader = new ThumbInfoLoader();
			this._thumbImgLoader = new URLLoader();
			
		}
		
		/**
		 * サムネイル画像を取得します。
		 * @param videoId
		 * 
		 */
		public function getThumbImg(videoId:String):void{
			
			this._videoId = videoId;
			this._thumbInfoLoader.addEventListener(Event.COMPLETE, apiAccessSuccess);
			this._thumbInfoLoader.getThumbInfo(videoId);
			
		}
		
		/**
		 * 
		 * @param event
		 * @throws ErrorEvent XMLの解析に失敗したか、サムネイル画像のURLが取得できない。
		 */
		private function apiAccessSuccess(event:Event):void{
			try{
				var xml:XML = new XML((event.target as URLLoader).data);
				var errorEvent:ErrorEvent = null;
				var thumbImgUrl:String = getThumbImgUrl(xml);
				if(thumbImgUrl != null && thumbImgUrl != ""){
					getThumbImgByUrl(thumbImgUrl);
				}else{
					errorEvent = new ErrorEvent(THUMB_IMG_URL_NOTFOUND_ERROR);
					dispatchEvent(errorEvent);
				}
			}catch(error:Error){
				trace(error.getStackTrace());
				errorEvent = new ErrorEvent(THUMB_INFO_PARSE_ERROR, false, false, error.getStackTrace());
				dispatchEvent(errorEvent);
			}
			
		}
		
		
		/**
		 * 渡されたXMLからサムネイル画像のURLを探して返します。
		 * @param xml
		 * @return 
		 * 
		 */
		public function getThumbImgUrl(xml:XML):String{
			var thumbImgUrl:String = null;
			thumbImgUrl = xml.thumb.thumbnail_url;
			return thumbImgUrl;
		}
		
		/**
		 * 指定されたThumbImgUrlにバイナリモードでアクセスします。
		 * @param thumbImgUrl
		 * 
		 */
		public function getThumbImgByUrl(thumbImgUrl:String):void{
			this._thumbImgLoader.dataFormat = URLLoaderDataFormat.BINARY;
			this._thumbImgLoader.load(new URLRequest(thumbImgUrl));
		}
		
		/**
		 * サムネイル画像読み込み用のURLLoaderにリスナを追加します。
		 * @param event
		 * @param listener
		 * 
		 */
		public function addThumbImgLoaderListener(event:String, listener:Function):void{
			this._thumbImgLoader.addEventListener(event, listener);
		}
		
		/**
		 * サムネイル情報取得用のThumbInfoLoaderにリスナを追加します。
		 * @param event
		 * @param listener
		 * @see ThumbInfoLoader#addEventListener()
		 */
		public function addThumbInfoLoaderListener(event:String, listener:Function):void{
			this._thumbInfoLoader.addEventListener(event, listener);
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._thumbImgLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._thumbImgLoader = null;
			try{
				this._thumbInfoLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace())
			}
//			this._thumbInfoLoader = null;
		}

	}
}