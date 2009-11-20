package org.mineap.a2n4as
{
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;

	/**
	 * ニコニコ動画からコメントを取得します。<br>
	 * 取得結果は、addCommentLoaderListener()で登録したリスナから取得します。
	 *  
	 * @author shiraminekeisuke
	 * 
	 */
	public class CommentLoader extends EventDispatcher
	{
		
		private var _commentLoader:URLLoader;
		
		private var _count:int;
		
		private var _messageServerUrl:String;
		
		private var _userID:String;
		
		private var _apiAccess:ApiGetFlvAccess;
		
		private var _isOwnerComment:Boolean;
		
		private var _threadId:String;
		
		private var _isPremium:String;
		
		public static const COMMENT_GET_FAIL:String = "CommentGetFail";
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function CommentLoader()
		{
			this._commentLoader = new URLLoader();
		}
		
		/**
		 * ニコニコ動画にアクセスしてコメントを取得します。
		 * 
		 * @param videoId コメントを取得したい動画のビデオID。
		 * @param count 取得するコメントの数。
		 * @param isOwnerComment 投稿者コメントかどうか
		 * @param apiAccess getFlvにアクセスするApiGetFlvAccessオブジェクト
		 * 
		 */
		public function getComment(videoId:String, count:int, isOwnerComment:Boolean, apiAccess:ApiGetFlvAccess):void
		{
			this._count = count;
			this._isOwnerComment = isOwnerComment;
			this._apiAccess = apiAccess;
			
			this._getComment();
			
		}
		
		/**
		 * 
		 */
		private function _getComment():void{
			
			var result:String = unescape(decodeURIComponent(this._apiAccess.data));
			
			//APIから得られたデータの"thread_ID="にあるスレッドIDを探す
			//thread_id=1240164480&
			var threadId:String = "";
			var pattern:RegExp = new RegExp("thread_id=([^&]*)&", "ig");
			var array:Array = pattern.exec(result);
			if(array != null && array.length > 1){
				threadId = array[array.length-1];
			}else{
				dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false, result));
				close();
				return;
			}
			//APIから得られたデータの"user_id="にあるユーザーIDを探す
			//&user_id=573999&
			var userID:String = "";
			pattern = new RegExp("&user_id=([^&])*&", "ig");
			array = pattern.exec(result);
			if(array != null && array.length > 1){
				userID = array[array.length-1];
			}else{
				dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false,  result));
				close();
				return;
			}
			//APIから得られたデータの"&ms="にあるURLを探す
			//&ms=http://msg.nicovideo.jp/43/api/&
			var commentURL:String = "";
			pattern = new RegExp("&ms=(http://msg.nicovideo.jp/[^/]*/api/)&", "ig");
			array = pattern.exec(result);
			if(array != null && array.length > 1){
				commentURL = array[array.length-1];
			}else{
				dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false,  result));
				close();
				return;
			}
			//APIから得られたデータの"@is_premium="にあるURLを探す
			//&is_premium=0&
			var isPremium:String = "";
			pattern = new RegExp("&is_premium=(\\d)&", "ig");
			array = pattern.exec(result);
			if(array != null && array.length > 1){
				isPremium = array[array.length-1];
			}else{
				dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false,  result));
				close();
				return;
			}
			
			//コメントを投稿する際に使う
			this._messageServerUrl = commentURL;
			this._userID = userID;
			this._threadId = threadId;
			this._isPremium = isPremium;
			
			//POSTリクエストを生成
			var getComment:URLRequest = new URLRequest(unescape(commentURL));
			getComment.method = "POST";
			getComment.requestHeaders = new Array(new URLRequestHeader("Content-Type", "text/html"));

			//XMLを生成
			//var xml:String = "<thread fork=\"1\" user_id=\"" + user_id + "\" res_from=\"1000\" version=\"20061206\" thread=\"" + threadId + "\" />";
			var xml:XML = null;
			if(!this._isOwnerComment){
				xml = new XML("<thread res_from=\"-"+ this._count +"\" version=\"20061206\" thread=\"" + threadId + "\" />");
				getComment.data = xml;
			}else{
				xml = new XML("<thread res_from=\"-"+ this._count +"\" fork=\"1\" version=\"20061206\" thread=\"" + threadId + "\" />"); 
				getComment.data = xml;
			}
			
			this._commentLoader.dataFormat=URLLoaderDataFormat.TEXT;
			//読み込み開始
			this._commentLoader.load(getComment);
			
		}
		
		/**
		 * コメントロード用のURLLoaderにリスナを追加します。
		 * @param event
		 * @param listener
		 * 
		 */
		public function addCommentLoaderListener(event:String, listener:Function):void{
			this._commentLoader.addEventListener(event, listener);
		}
		
		/**
		 * APIアクセス用URLLoader（getFlv）にリスナを追加します
		 * @param event
		 * @param listener
		 * 
		 */
		public function addApiGetFlvAccessListener(event:String, listener:Function):void{
			this._apiAccess.addEventListener(event, listener);
		}
		
		/**
		 * APIの結果から取得したメッセージサーバーのURLを返します。
		 * @return 
		 * 
		 */
		public function get messageServerUrl():String{
			return this._messageServerUrl;
		}
		
		/**
		 * APIの結果から取得したuserIDを返します。
		 * @return 
		 * 
		 */
		public function get userID():String{
			return this._userID;
		}
		
		/**
		 * APIの結果から取得したthureadIdを返します。
		 * @return 
		 * 
		 */
		public function get thureadId():String{
			return this._threadId;
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
		 * @return 
		 * 
		 */
		public function close():void{
			try{
				this._commentLoader.close();
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
//			this._commentLoader = null;
		}
		
	}
}