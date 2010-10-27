package org.mineap.nndd
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	
	import org.mineap.nicovideo4as.Login;
	import org.mineap.nicovideo4as.ThumbInfoLoader;
	import org.mineap.nicovideo4as.WatchVideoPage;
	import org.mineap.nicovideo4as.loader.IchibaInfoLoader;
	
	[Event(name="success", type="NNDDVideoPageWatcher")]
	[Event(name="fail", type="NNDDVideoPageWatcher")]
	
	/**
	 * ニコニコ動画の動画ページへのアクセスします。このアクセスで、以下の情報を取得します。
	 * ・動画ページ
	 * ・動画のThumbInfo
	 * ・動画の市場情報 
	 * ・オススメ動画情報
	 * 
	 * @author shiraminekeisuke (MineAP)
	 * 
	 */
	public class NNDDVideoPageWatcher extends EventDispatcher
	{
		
		private var _videoId:String = null;
		
		private var _onlyOwnerText:Boolean = false;
		
		private var _login:Login = null;
		
		private var _watch:WatchVideoPage = null;
		
		private var _thumbInfoLoader:ThumbInfoLoader = null;
		
		private var _ichibaInfoLoader:IchibaInfoLoader = null;
		
		/**
		 * 動画ページの閲覧に成功した場合、typeにこの文字列が設定されたイベントが発行されます。
		 */
		public static const SUCCESS:String = "SUCCESS";
		
		/**
		 * 動画ページの閲覧に失敗した場合、typeにこの文字列が設定されたイベントが発行されます。
		 */
		public static const FAIL:String = "FAIL";
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function NNDDVideoPageWatcher()
		{
		}
		
		/**
		 * 指定されたメールアドレス、パスワードを使って動画ページにアクセスします。
		 * @param mailAddr
		 * @param password
		 * @param videoId
		 * @param onlyOwnerText
		 * 
		 */
		public function watch(mailAddr:String, password:String, videoId:String, onlyOwnerText:Boolean):void{
			
			this._videoId = videoId;
			this._onlyOwnerText = onlyOwnerText;
			
			this._login = new Login();
			
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccessEventListener);
			this._login.addEventListener(Login.LOGIN_FAIL, loginFailEventListener);
			
			this._login.login(mailAddr, password);
		}
		
		/**
		 * ログインが成功した際に呼ばれる
		 * @param event
		 * 
		 */
		private function loginSuccessEventListener(event:Event):void{
			
			this._watch = new WatchVideoPage();
			
			this._watch.addEventListener(WatchVideoPage.WATCH_SUCCESS, pageWatchSuccessListener);
			this._watch.addEventListener(WatchVideoPage.WATCH_FAIL, pageWatchFailListener);
			
			this._watch.watchVideo(this._videoId)
			
		}
		
		/**
		 * ログインに失敗した際に呼ばれる
		 * @param event
		 * 
		 */
		private function loginFailEventListener(event:Event):void{
			close();
			dispatchEvent(new ErrorEvent(FAIL));
		}
		
		/**
		 * ページの閲覧に成功した場合に呼ばれる
		 * @param event
		 * 
		 */
		private function pageWatchSuccessListener(event:Event):void{
			
			if(this._onlyOwnerText){
				close();
				dispatchEvent(new Event(SUCCESS));
				return;
			}
			
			this._thumbInfoLoader = new ThumbInfoLoader();
			
			this._thumbInfoLoader.addEventListener(ThumbInfoLoader.SUCCESS, thumbInfoLoadSuccessEventListener);
			this._thumbInfoLoader.addEventListener(ThumbInfoLoader.FAIL, thumbInfoLoadFailEventListner);
			this._thumbInfoLoader.getThumbInfo(this._videoId);
			
		}
		
		/**
		 * ページの閲覧に失敗した場合に呼ばれる
		 * @param event
		 * 
		 */
		private function pageWatchFailListener(event:Event):void{
			close();
			dispatchEvent(new ErrorEvent(FAIL));
		}
		
		private function thumbInfoLoadSuccessEventListener(event:Event):void{
			
			this._ichibaInfoLoader = new IchibaInfoLoader();
			
			this._ichibaInfoLoader.addEventListener(Event.COMPLETE, ichibaInfoLoadSuccssEventListener);
			this._ichibaInfoLoader.addEventListener(IOErrorEvent.IO_ERROR, ichibaInfoLoadFailEventListener);
			this._ichibaInfoLoader.getIchibaInfo(this._videoId);
		}
		
		private function thumbInfoLoadFailEventListner(event:Event):void{
			close();
			dispatchEvent(new ErrorEvent(FAIL));
		}
		
		private function ichibaInfoLoadSuccssEventListener(event:Event):void{
			close();
			dispatchEvent(new Event(SUCCESS));
		}
		
		private function ichibaInfoLoadFailEventListener(event:Event):void{
			close();
			dispatchEvent(new ErrorEvent(FAIL));
		}
		
		/**
		 * 動画ページへアクセスしたWatchVideoPageクラスのインスタンスを返します。
		 * @return 
		 * 
		 */
		public function get watcher():WatchVideoPage{
			return this._watch;
		}
		
		/**
		 * 動画ページへのアクセス後、ThumbInfoAPIにアクセスしたThumbInfoLoaderクラスのインスタンスを返します。
		 * @return 
		 * 
		 */
		public function get thumbInfoLoader():ThumbInfoLoader{
			return this._thumbInfoLoader;
		}
		
		/**
		 * 動画ページへのアクセス後、市場情報取得APIにアクセスしたIchibaInfoLaoderクラスのインスタンスを返します。
		 * @return 
		 * 
		 */
		public function get ichibaInfoLoader():IchibaInfoLoader{
			return this._ichibaInfoLoader;
		}
		
		/**
		 * タグ要素を含む投稿者コメントの取得のみを行ったかどうかです。
		 * @return 
		 * 
		 */
		public function get onlyOwnerText():Boolean{
			return this._onlyOwnerText;
		}
		
		/**
		 * ニコニコ動画へのアクセスをすべてクローズします。
		 * 
		 */
		public function close():void{
			try{
				if(this._login != null){
					this._login.close();
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			
			try{
				if(this._watch != null){
					this._watch.close();
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			
			try{
				if(this._thumbInfoLoader != null){
					this._thumbInfoLoader.close();
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			
		}
		
		
	}
		
}