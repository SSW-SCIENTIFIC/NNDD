package org.mineap.a2n4as
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	/**
	 * ニコニコ動画から動画をダウンロードします。
	 * 取得結果は、addVideoLoaderListener()で登録したリスナから取得します。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class VideoLoader extends EventDispatcher
	{
		
		private var _videoLoader:URLLoader;
		
		private var _apiAccess:ApiGetFlvAccess;
		
		private var _videoType:VideoType;
		
		private var _isStreamingPlay:Boolean;
		
		private var _videoUrl:String;
		
		public static const VIDEO_URL_GET_SUCCESS:String = "VideoUrlGetSuccess";
		
		public static const VIDEO_URL_GET_FAIL:String = "VideoUrlGetFail";
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function VideoLoader()
		{
			this._videoLoader = new URLLoader();
			this._apiAccess = new ApiGetFlvAccess();
		}
		
		/**
		 * ニコニコ動画から動画を取得します。
		 * 
		 * @param isStreamingPlay ストリーミング再生かどうかです。
		 * 	trueに設定すると、URL取得完了時にEvent(VIDEO_URL_GET_SUCCESS)が発行され、その後ダウンロード処理を行いません。
		 * @param getflvAccess
		 */
		public function getVideo(isStreamingPlay:Boolean, getflvAccess:ApiGetFlvAccess):void{
			
			this._isStreamingPlay = isStreamingPlay;
			this._apiAccess = getflvAccess;
			
			this._getVideo();
		}
		
		/**
		 * APIから取得したURLを使って動画をダウンロードします。
		 * @param url 
		 * 
		 */
		public function getVideoForApiResult(url:String):void{
			
			this._videoUrl = url;
			
			if(this._videoUrl.indexOf("smile?m=")!=-1){
				this._videoType = VideoType.VIDEO_TYPE_MP4;
			}else if(this._videoUrl.indexOf("smile?v=")!=-1){
				this._videoType = VideoType.VIDEO_TYPE_FLV;
			}else if(this._videoUrl.indexOf("smile?s=")!=-1){
				this._videoType = VideoType.VIDEO_TYPE_SWF;
			}else{
				dispatchEvent(new IOErrorEvent(VIDEO_URL_GET_FAIL, false, false, "UnknownUrl:" + url));
				return;
			}
			
			//通常のダウンロード処理
			var getVideo:URLRequest;
			getVideo = new URLRequest(this._videoUrl);
			this._videoLoader.dataFormat=URLLoaderDataFormat.BINARY;
			this._videoLoader.load(getVideo);
		}
		
		/**
		 * APIのアクセスが成功したら呼ばれます。
		 * @param event
		 * 
		 */
		private function _getVideo():void{
			trace(unescape(decodeURIComponent(_apiAccess.data)));
			//&url=http://smile-pso42.nicovideo.jp/smile?m=6930243.48927&
			var pattern:RegExp = new RegExp("&url=(http://smile-[^&]+)&", "ig");
			var array:Array = pattern.exec(unescape(decodeURIComponent(_apiAccess.data)));
			
			if(array != null && array.length > 1){
				this._videoUrl = array[array.length-1];
				
				if(this._videoUrl.indexOf("smile?m=")!=-1){
					this._videoType = VideoType.VIDEO_TYPE_MP4;
				}else if(this._videoUrl.indexOf("smile?v=")!=-1){
					this._videoType = VideoType.VIDEO_TYPE_FLV;
				}else if(this._videoUrl.indexOf("smile?s=")!=-1){
					this._videoType = VideoType.VIDEO_TYPE_SWF;
				}
			}else{
				dispatchEvent(new IOErrorEvent(VIDEO_URL_GET_FAIL, false, false, "UnknownUrl:" + unescape(decodeURIComponent(_apiAccess.data))));
				close();
				return;
			}
			
			if(this._isStreamingPlay){
				//ストリーミング再生なのでFLVをダウンロードする必要は無い。
				dispatchEvent(new Event(VideoLoader.VIDEO_URL_GET_SUCCESS));
			}else{
				//通常のダウンロード処理
				var getVideo:URLRequest;
				getVideo = new URLRequest(this._videoUrl);
				this._videoLoader.dataFormat=URLLoaderDataFormat.BINARY;
				this._videoLoader.load(getVideo);
			}
			
		}
		
		/**
		 * 動画ロード用のURLLoaderにリスナを追加します。
		 * @param event
		 * @param listener
		 * 
		 */
		public function addVideoLoaderListener(event:String, listener:Function):void{
			this._videoLoader.addEventListener(event, listener);
		}
		
		/**
		 * APIアクセスの結果から取得した動画のURLを返します。
		 * @return 
		 * 
		 */
		public function get videoUrl():String{
			return this._videoUrl;
		}
		
		/**
		 * APIアクセスの結果から取得した動画の種類を返します。
		 * @return 
		 * 
		 */
		public function get videoType():VideoType{
			return this._videoType;
		}
		
		/**
		 * APIアクセスの結果から現在エコノミーモードかどうかを返します。
		 * @return エコノミーモードのときtrue
		 * 
		 */
		public function isEconomyMode():Boolean{
			return this._apiAccess.isEconomyMode();
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._videoLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._videoLoader = null;
		}
		
	}
}