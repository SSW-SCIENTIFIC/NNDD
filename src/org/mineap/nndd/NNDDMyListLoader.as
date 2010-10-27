package org.mineap.nndd
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nicovideo4as.Login;
	import org.mineap.nicovideo4as.PublicMyListLoader;

	[Event(name="loginSuccess", type="NNDDMyListLoader")]
	[Event(name="loginFail", type="NNDDMyListLoader")]
	[Event(name="publicMyListGetSuccess", type="NNDDMyListLoader")]
	[Event(name="publicMyListGetFail", type="NNDDMyListLoader")]

	[Event(name="downloadProcessComplete", type="NNDDMyListLoader")]
	[Event(name="donwloadProcessCancel", type="NNDDMyListLoader")]
	[Event(name="downloadProccessError", type="NNDDMyListLoader")]
	
	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class NNDDMyListLoader extends EventDispatcher
	{
		
		private var _login:Login;
		private var _publicMyListLoader:PublicMyListLoader;
		
		private var _libraryManager:ILibraryManager;
		
		private var _publicMyListId:String;
		
		private var _xml:XML;
		
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
		public static const PUBLIC_MY_LIST_GET_SUCCESS:String = "PublicMyListGetSuccess";
		
		/**
		 * 
		 */
		public static const PUBLIC_MY_LIST_GET_FAIL:String = "PublicMyListGetFail";
		
		/**
		 * ダウンロード処理が通常に終了したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const DOWNLOAD_PROCESS_COMPLETE:String = "DownloadProcessComplete";
		
		/**
		 * ダウンロード処理が中断された際に、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const DOWNLOAD_PROCESS_CANCELD:String = "DonwloadProcessCancel";
		
		/**
		 * ダウンロード処理が異状終了した際に、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const DOWNLOAD_PROCESS_ERROR:String = "DownloadProccessError";
		
		/**
		 * 
		 * @param logManager
		 * 
		 */
		public function NNDDMyListLoader()
		{
			this._libraryManager = LibraryManagerBuilder.instance.libraryManager;
			this._login = new Login();
			this._publicMyListLoader = new PublicMyListLoader();
		}
		
		/**
		 * 
		 * @param user
		 * @param password
		 * @param myListId
		 * 
		 */
		public function requestDownloadForPublicMyList(user:String, password:String, myListId:String):void{
			
			trace("start - requestDownload(" + user + ", ****, " + myListId + ")");
			
			this._publicMyListId = myListId;
			
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccess);
			this._login.addEventListener(Login.LOGIN_FAIL, function(event:ErrorEvent):void{
				(event.target as Login).close();
				LogManager.instance.addLog(PUBLIC_MY_LIST_GET_FAIL + event.target + ":" + event.text);
				trace(event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new ErrorEvent(PUBLIC_MY_LIST_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._login.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			
			this._login.login(user, password);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function loginSuccess(event:Event):void{
			
			//ログイン成功通知
			trace(LOGIN_SUCCESS + ":" + event);
			dispatchEvent(new Event(LOGIN_SUCCESS));
			
			this._publicMyListLoader.addEventListener(Event.COMPLETE, getPublicMyListSuccess);
			this._publicMyListLoader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				(event.target as URLLoader).close();
				LogManager.instance.addLog(PUBLIC_MY_LIST_GET_FAIL + ":" +  _publicMyListId + ":" + event + ":" + event.target +  ":" + event.text);
				trace(PUBLIC_MY_LIST_GET_FAIL + ":" +  _publicMyListId  + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(PUBLIC_MY_LIST_GET_FAIL, false, false, event.text));
				close(false, false);
			});
			
			this._publicMyListLoader.getPublicMyList(this._publicMyListId);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function getPublicMyListSuccess(event:Event):void{
//			trace((event.target as URLLoader).data);
			
			this._xml = new XML((event.target as URLLoader).data);
			
//			trace(DOWNLOAD_PROCESS_COMPLETE + ":" + event + ":" + xml);
			LogManager.instance.addLog(DOWNLOAD_PROCESS_COMPLETE + ":" + this._publicMyListId);
			dispatchEvent(new Event(DOWNLOAD_PROCESS_COMPLETE));
		}
		
		/**
		 * 
		 * 
		 */
		public function get xml():XML{
			return this._xml;
		}
		
		/**
		 * 
		 * 
		 */
		private function terminate():void{
			this._login = null;
			this._publicMyListLoader = null;
		}
		
		/**
		 * Loaderをすべて閉じます。
		 * 
		 */
		public function close(isCancel:Boolean, isError:Boolean, event:ErrorEvent = null):void{
			
			//終了処理
			try{
				this._login.close();
				trace(this._login + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._publicMyListLoader.close();
				trace(this._publicMyListLoader + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			terminate();
			
			var eventText:String = "";
			if(event != null){
				eventText = event.text;
			}
			if(isCancel && !isError){
				dispatchEvent(new Event(DOWNLOAD_PROCESS_CANCELD));
			}else if(isCancel && isError){
				dispatchEvent(new IOErrorEvent(DOWNLOAD_PROCESS_ERROR, false, false, eventText));
			}
		}
			
	}
}