package org.mineap.a2n4as.util
{
	/**
	 * getFlvの応答を解析するためのクラスです。 
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class GetFlvResultAnalyzer
	{
		
		/**
		 * スレッドIDを抽出するための正規表現です
		 */
		public static const THREAD_ID_PATTERN:RegExp = new RegExp("thread_id=([^&]*)&");
		
		/**
		 * 長さを抽出するための正規表現です。
		 */
		public static const L_PATTERN:RegExp = new RegExp("&l=([^&]*)&");
		
		/**
		 * 動画へのURLを抽出するための正規表現です
		 */
		public static const VIDEO_URL_PATTERN:RegExp = new RegExp("&url=([^&]*)&");
		
		/**
		 * 当該動画のSmileVideoへのリンクを抽出するための正規表現です
		 */
		public static const SMILE_VIDEO_LINK_PATTERN:RegExp = new RegExp("&link=([^&]*)&");
		
		/**
		 * メッセージサーバのURLを抽出するための正規表現です。
		 */
		public static const MESSAGE_SERVER_URL_PATTERN:RegExp = new RegExp("&ms=([^&]*)&");
		
		/**
		 * ユーザーIDを抽出するための正規表現です。
		 */
		public static const USER_ID_PATTERN:RegExp = new RegExp("&user_id=([^&]*)&");
		
		/**
		 * プレミアム会員かどうかを抽出するための正規表現です。
		 */
		public static const IS_PREMIUM_PATTERN:RegExp = new RegExp("&is_premium=([^&]*)&");
		
		/**
		 * ニックネームを抽出するための正規表現です。
		 */
		public static const NICK_NAME_PATTERN:RegExp = new RegExp("&nickname=([^&]*)&");
		
		/**
		 * 時刻を抽出するための正規表現です。
		 */
		public static const TIME_PATTERN:RegExp = new RegExp("&time=([^&]*)&");
		
		/**
		 * 
		 */
		public static const DONE_PATTERN:RegExp = new RegExp("&done=([^&]*)");
		
		/**
		 * needs_key
		 */
		public static const NEEDS_KEY_PATTERN:RegExp = new RegExp("&needs_key=([^&]*)");
		
		/**
		 * optional_thread_id
		 */
		public static const OPTIONAL_THREAD_ID_PATTERN:RegExp = new RegExp("&optional_thread_id=([^&]*)");
		
		/**
		 * feedrev
		 */
		public static const FEED_REV_PATTERN:RegExp = new RegExp("&feedrev=([^&]*)");
		
		private var _threadId:String = null;
		
		private var _l:Number = 0;
		
		private var _url:String = null;
		
		private var _link:String = null;
		
		private var _ms:String = null;
		
		private var _userId:String = null;
		
		private var _isPremium:Boolean = false;
		
		private var _nickName:String = null;
		
		private var _time:Number = 0;
		
		private var _done:Boolean = false;
		
		private var _needs_key:int = 0;
		
		private var _optional_thread_id:String = null;
		
		private var _feedrev:String = null;
		
		
		private var _result:String = null;
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function GetFlvResultAnalyzer()
		{
			/* nothing */
		}

		/**
		 * 渡されたString表現をgetflvの応答として解析します。
		 * 
		 * @param result getflvの応答
		 * @return 解析に成功した場合はtrue、失敗した場合はfalse。
		 * 
		 */
		public function analyze(result:String):Boolean{
			
			try{
				
				if(result.indexOf("%") != -1){
					// "%"が含まれていればデコード
					result = decodeURIComponent(result);
				}
				
				this._result = result;
				
				/*
				thread_id=1258917637
				&l=512	//なんの長さだ？
				&url=http://smile-pso00.nicovideo.jp/smile?v=8889000.46967
				&link=http://www.smilevideo.jp/view/8889000/573999
				&ms=http://msg.nicovideo.jp/42/api/	
				&user_id=******
				&is_premium=1	//1の時プレミアム
				&nickname=MineAP
				&time=1258934153
				&done=true
				&needs_key=1	//公式の時のみ？
				&optional_thread_id=1254473671	//公式の時のみ？
				&feedrev=b852b	//公式の時のみ？
				*/
				
				var array:Array = THREAD_ID_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._threadId = array[array.length-1];
				}
				
				array = L_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._l = Number(array[array.length-1]);
				}
				
				array = VIDEO_URL_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._url = array[array.length-1];
				}
				
				array = SMILE_VIDEO_LINK_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._link = array[array.length-1];
				}
				
				array = MESSAGE_SERVER_URL_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._ms = array[array.length-1];
				}
				
				array = USER_ID_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._userId = array[array.length-1];
				}
				
				array = IS_PREMIUM_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._isPremium = Boolean(array[array.length-1]);
				}
				
				array = NICK_NAME_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._nickName = array[array.length-1];
				}
				
				array = TIME_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._time = Number(array[array.length-1]);
				}
				
				array = DONE_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._done = Boolean(array[array.length-1]);
				}
				
				array = NEEDS_KEY_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._needs_key = int(array[array.length-1]);
				}
				
				array = OPTIONAL_THREAD_ID_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._optional_thread_id = array[array.length-1];
				}
				
				array = FEED_REV_PATTERN.exec(result);
				if(array != null && array.length > 1){
					this._feedrev = array[array.length-1];
				}
				
				return true;
				
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			return false;
		}
		
		public function get done():Boolean
		{
			return _done;
		}

		public function get time():Number
		{
			return _time;
		}

		public function get nickName():String
		{
			return _nickName;
		}

		public function get isPremium():Boolean
		{
			return _isPremium;
		}

		public function get userId():String
		{
			return _userId;
		}

		public function get ms():String
		{
			return _ms;
		}

		public function get link():String
		{
			return _link;
		}

		public function get url():String
		{
			return _url;
		}

		public function get l():Number
		{
			return _l;
		}

		public function get threadId():String
		{
			return _threadId;
		}
		
		public function get result():String
		{
			return _result;
		}

		public function get needs_key():int
		{
			return _needs_key;
		}

		public function get optional_thread_id():String
		{
			return _optional_thread_id;
		}

		public function get feedrev():String
		{
			return _feedrev;
		}


	}
}