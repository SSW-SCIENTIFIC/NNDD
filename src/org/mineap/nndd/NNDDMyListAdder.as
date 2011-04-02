package org.mineap.nndd
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	
	import org.mineap.nndd.util.PathMaker;
	import org.mineap.nicovideo4as.Login;
	import org.mineap.nicovideo4as.MyListAdder;
	import org.mineap.nicovideo4as.MyListLoader;
	import org.mineap.nicovideo4as.WatchVideoPage;

	/**
	 * 動画をマイリストへ追加するクラス。
	 * 1.ニコニコ動画へログイン
	 * 2.動画ページへアクセスし、csrf_tokenを取得
	 * 3.取得したcsrf_tokenを使ってマイリストへ追加
	 * 
	 * ※Playerは、動画の再生のたびに動画ページにアクセスし、マイリストの一覧を取得しておく必要がある。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class NNDDMyListAdder extends EventDispatcher
	{
		private var _mailAddr:String = "";
		private var _password:String = "";
		private var _watchUrl:String = "";
		private var _group_id:String = "";
		
		private var _retryEnable:Boolean = false;
		
		private var _logManager:LogManager = null;
		private var _login:Login = null;
		private var _myListLoader:MyListLoader = null;
		private var _myListAdder:MyListAdder = null;
		
		/**
		 * ログインに失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const LOGIN_FAIL:String = "LoginFail";
		
		/**
		 * ログインに成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const LOGIN_SUCCESS:String = "LoginSuccess";
		
		/**
		 * マイリストグループ一覧の取得に失敗した時、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const GET_MYLISTGROUP_FAIL:String = "GetMyListGroupFailure";
		
		/**
		 * マイリストグループ一覧の取得に成功した時、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const GET_MYLISTGROUP_SUCCESS:String = "GetMyListGroupSuccess";
		
		/**
		 * マイリストへの追加に失敗したとき、typeプロパティがこの定数に設定されたErrorEventが発行されます。
		 */
		public static const ADD_MYLSIT_FAIL:String = "AddMyListFail";
		
		/**
		 * マイリストへの追加に成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const ADD_MYLIST_SUCESS:String = "AddMyListSuccess";
		
		/**
		 * マイリストにすでに追加されていたときに、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const ADD_MYLIST_DUP:String = "AddMyListDup";
		
		/**
		 * マイリストに追加しようとした動画が既に存在しなかったときに、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const ADD_MYLIST_NOT_EXIST:String = "AddMyListNotExist";
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function NNDDMyListAdder(_logManager:LogManager)
		{
			this._logManager = _logManager;
			this._login = new Login();
			this._myListLoader = new MyListLoader();
			this._myListAdder = new MyListAdder();
		}
		
		/**
		 * マイリストへの追加を行います。
		 * 
		 * @param watchUrl 閲覧先動画ID
		 * @param group_id 追加先マイリストID
		 * @param mailAddr ログイン名
		 * @param password ログインパスワード
		 * @param retryBoolean マイリストAPIの戻り値が不正だった場合にリトライするかどうか
		 */
		public function addMyList(watchUrl:String, 
								  group_id:String, 
								  mailAddr:String, 
								  password:String, 
								  retryEnable:Boolean = true):void{
			
			this._watchUrl = watchUrl;
			this._group_id = group_id;
			this._mailAddr = mailAddr;
			this._password = password;
			
			this._retryEnable = retryEnable;
			
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccess);
			this._login.addEventListener(Login.LOGIN_FAIL, function(event:IOErrorEvent):void{
				(event.target as URLLoader).close();
				_logManager.addLog(LOGIN_FAIL + event.target + ":" + event.text);
				trace(event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(LOGIN_FAIL, false, false, event.text));
				close();
			});
			this._login.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				_logManager.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			this._logManager.addLog("ニコニコ動画へログイン");
			this._login.login(mailAddr, password, Login.LOGIN_URL);
			
		}
		
		/**
		 * ログインに成功したら呼ばれる。
		 * @param event
		 * 
		 */
		private function loginSuccess(event:Event):void{
			//ログイン成功通知
			trace(LOGIN_SUCCESS + ":" + event);
			this._logManager.addLog("\t" + LOGIN_SUCCESS + ":" + _watchUrl);
			dispatchEvent(new Event(LOGIN_SUCCESS));
			
			//リスナ追加
			this._myListLoader.addEventListener(MyListLoader.GET_MYLISTGROUP_SUCCESS, getMylistGroupSuccess);
			this._myListLoader.addEventListener(MyListLoader.GET_MYLISTGROUP_FAILURE, function(event:ErrorEvent):void{
				(event.target as URLLoader).close();
				_logManager.addLog(GET_MYLISTGROUP_FAIL + ":" +  _watchUrl + ":" + event + ":" + event.target +  ":" + event.text);
				trace(GET_MYLISTGROUP_FAIL + ":" +  _watchUrl + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(GET_MYLISTGROUP_FAIL, false, false, event.text));
				close();
			});
			this._myListLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				_logManager.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			
			this._logManager.addLog("マイリストグループの取得:" + this._watchUrl);
			this._myListLoader.getMyListGroup(PathMaker.getVideoID(this._watchUrl));
		}
		
		/**
		 * 動画ページへのアクセスが完了したら呼ばれます。
		 * コメントのダウンロードを開始します。
		 * 
		 * @param event
		 * 
		 */
		private function getMylistGroupSuccess(event:Event):void{
			
			//動画ページアクセス完了通知(動画ページへのアクセスは閉じない)
			trace(GET_MYLISTGROUP_SUCCESS + ":" + event);
			this._logManager.addLog("\t" + GET_MYLISTGROUP_SUCCESS + ":" + _watchUrl);
			dispatchEvent(new Event(GET_MYLISTGROUP_SUCCESS));
			
			//マイリスト登録開始
			this._myListAdder.addEventListener(MyListAdder.FAIL, function(event:ErrorEvent):void{
				
				_logManager.addLog("\t" + ADD_MYLSIT_FAIL + ":" + _watchUrl + ":" + event + ":" + event.target + ":" + event.text);
				trace(ADD_MYLSIT_FAIL + ":" + _watchUrl + ":" + event + ":" + event.target + ":" + event.text);
				
				dispatchEvent(new ErrorEvent(NNDDMyListAdder.ADD_MYLSIT_FAIL, false, false, event.text));
				close();
			});
			this._myListAdder.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				_logManager.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			this._myListAdder.addEventListener(MyListAdder.SUCCESS, myListAddSuccess);
			this._myListAdder.addEventListener(MyListAdder.DUP_ERROR, myListAddDup);
			this._myListAdder.addEventListener(MyListAdder.NOTEXIST, myListAddNotExist);
			
			this._logManager.addLog("マイリストへ追加:url=" + this._watchUrl + ", group_id=" + this._group_id);
			
			var itemType:String = this._myListLoader.getItemType();
			var itemId:String = this._myListLoader.getItemId();
			if((itemType == null || itemId == null) && this._retryEnable){
				close();
				this._logManager.addLog("マイリストへの追加をリトライ(マイリストAPIの応答が正しくない)");
				this.addMyList(this._watchUrl, this._group_id, this._mailAddr, this._password);
			}else{
				this._myListAdder.addMyList(this._myListLoader.getToken(), this._group_id, itemType, itemId);
			}
		}
		
		/**
		 * マイリストへの追加が成功したら呼ばれます。
		 * @param event
		 * 
		 */
		private function myListAddSuccess(event:Event):void{
			
			trace(ADD_MYLIST_SUCESS + ":" + event);
			this._logManager.addLog("\t" + ADD_MYLIST_SUCESS + ":" + _watchUrl);
			dispatchEvent(new Event(ADD_MYLIST_SUCESS));
			
			close();
			
		}
		
		/**
		 * マイリストにすでに追加済みの場合に呼ばれます
		 * @param event
		 * 
		 */
		private function myListAddDup(event:Event):void{
			
			trace(ADD_MYLIST_DUP + ":" + event);
			this._logManager.addLog("\t" + ADD_MYLIST_DUP + ":" + _watchUrl);
			dispatchEvent(new Event(ADD_MYLIST_DUP));
			
			close();
			
		}
		
		/**
		 * マイリストに追加しようとした動画IDが存在しない場合に呼ばれます
		 * @param event
		 * 
		 */
		private function myListAddNotExist(event:Event):void{
			
			trace(ADD_MYLIST_NOT_EXIST + ":" + event);
			this._logManager.addLog("\t" + ADD_MYLIST_NOT_EXIST + ":" + _watchUrl);
			dispatchEvent(new Event(ADD_MYLIST_NOT_EXIST));
			
			close();
		}
		
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._login.close();
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			try{
				this._myListLoader.close();
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			try{
				this._myListAdder.close();
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			
			this._retryEnable = false;
		}
					
	}
}