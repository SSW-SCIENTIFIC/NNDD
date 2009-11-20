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
	import flash.net.URLRequestDefaults;
	import flash.net.URLVariables;

	/**
	 * ニコニコ動画へのログインリクエストを格納するクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class Login extends EventDispatcher
	{
		
		private var _loginLoader:URLLoader;
		private var _loginRequest:URLRequest;
		private var _logoutLoader:URLLoader;
		private var _isRetry:Boolean = false;
		
		/**
		 * ニコニコ動画のログインURLです。
		 */
		public static const LOGIN_URL:String = "https://secure.nicovideo.jp/secure/login?site=niconico";
		
		/**
		 * ニコニコ動画のログアウトURLです。
		 */
		public static const LOGOUT_URL:String = "https://secure.nicovideo.jp/secure/logout";
		
		/**
		 * ニコニコ動画へのログインに失敗した際に遷移するページのURLです。
		 */
		public static const LOGIN_FAIL_URL:String = "https://secure.nicovideo.jp/secure/login_form?message=cant_login";
		
		/**
		 * ニコニコ動画のトップページURLです。
		 */
		public static const TOP_PAGE_URL:String = "http://www.nicovideo.jp/";
		
		/**
		 * 
		 */
		public static const LOGIN_SUCCESS:String = "LoginSuccess";
		
		/**
		 * 
		 */
		public static const LOGIN_FAIL:String = "LoginFail";
		
		/**
		 * 
		 */
		public static const LOGOUT_COMPLETE:String = "LogoutComplete";
		
		/**
		 * コンストラクタ<br>
		 * 
		 */
		public function Login()
		{
			this._loginLoader = new URLLoader();
			this._logoutLoader = new URLLoader();
		}
		
		/**
		 * ニコニコ動画にログインします。
		 * 
		 * @param user ログイン名です。
		 * @param password ログインパスワードです。
		 * @param url ログインに使うURLです。
		 * @param isDefault 今回設定したログインをデフォルトに設定するかどうかです
		 * @param topPageUrl デフォルトのログイン設定を有効にするURLです。
		 * @param isRetry このフラグがtrueで、かつIOエラーが発生したときに、ログアウト→ログインの順で一度だけ再試行します。
		 * @return 
		 * 
		 */
		public function login(user:String, password:String, url:String=LOGIN_URL, isDefault:Boolean=true, topPageUrl:String=TOP_PAGE_URL, isRetry:Boolean = true):void{
			if(isDefault){
				setURLRequestDefaults(user, password, topPageUrl);
			}
			
			this._isRetry = isRetry;
			
			var variables:URLVariables = new URLVariables();
			variables.mail = user;
			variables.password = password;
			
			this._loginRequest = new URLRequest(url);
			this._loginRequest.method = "POST";
			this._loginRequest.data = variables;
			
			this._loginLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpCompleteHandler);
			this._loginLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			this._loginLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			this._loginLoader.load(this._loginRequest);
		}
		
		/**
		 * ニコニコ動画からログアウトします。
		 * 
		 */
		public function logout():void{
			
			this._logoutLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, logoutCompleteHandler);
			this._logoutLoader.addEventListener(IOErrorEvent.IO_ERROR, logoutCompleteHandler);
			
			this._logoutLoader.load(new URLRequest(LOGOUT_URL));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function logoutCompleteHandler(event:Event):void{
			trace(event);
			if(this._isRetry){
				trace("ログインリトライ");
				login(String(this._loginRequest.data.mail), String(this._loginRequest.data.password), LOGIN_URL, true, TOP_PAGE_URL, false);
			}else{
				dispatchEvent(new Event(LOGOUT_COMPLETE));
			}
		}
		
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorHandler(event:ErrorEvent):void{
			trace(event);
			if(this._isRetry){
				trace("ログアウト");
				logout();
			}else{
				dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, event.toString()));
			}
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpCompleteHandler(event:HTTPStatusEvent):void{
			trace(event);
			
			dispatchEvent(event);
			
			if (event.status != 200) {
				dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, event.toString()));
				
				return;
			}
			
			if (event.responseURL == LOGIN_FAIL_URL){
				dispatchEvent(new ErrorEvent(LOGIN_FAIL, false, false, event.toString()));
				
				return;
			}
			
			dispatchEvent(new Event(LOGIN_SUCCESS));
		}
		
		/**
		 * 指定されたURL下のページにアクセスする際のデフォルトユーザー名およびパスワードに、
		 * 引数で指定された値を設定します。
		 * @param user
		 * @param password
		 * @param url
		 * @return 
		 * 
		 */
		public function setURLRequestDefaults(user:String, password:String, url:String):void{
			URLRequestDefaults.setLoginCredentialsForHost(url, user, password);
		}
		
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				if(this._loginLoader != null){
					this._loginLoader.close();
				}
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			this._loginLoader = null;
			this._loginRequest = null;
		}
		
	}
}