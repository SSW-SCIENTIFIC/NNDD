package org.mineap.nndd
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	
	import org.mineap.nicovideo4as.Login;
	import org.mineap.nicovideo4as.loader.ChannelLoader;
	import org.mineap.nicovideo4as.loader.PublicMyListLoader;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;

	[Event(name="loginSuccess", type="NNDDMyListLoader")]
	[Event(name="loginFail", type="NNDDMyListLoader")]
	[Event(name="downloadSuccess", type="NNDDMyListLoader")]
	[Event(name="downloadGetFail", type="NNDDMyListLoader")]

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
		
		private var _channelLoader:ChannelLoader;
		private var _publicMyListLoader:PublicMyListLoader;
		
		private var _libraryManager:ILibraryManager;
		
		private var _myListId:String;
		private var _channelId:String;
		
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
		public static const DOWNLOAD_SUCCESS:String = "DownloadSuccess";
		
		/**
		 * 
		 */
		public static const DOWNLOAD_FAIL:String = "DownloadFail";
		
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
		}
		
		/**
		 * 
		 * @param user
		 * @param password
		 * @param id
		 * 
		 */
		public function requestDownloadForMyList(user:String, password:String, id:String):void
		{
			trace("start - requestDownload(" + user + ", ****, mylist/" + id + ")");
			
			this._myListId = id;
			
			login(user, password);
		}
		
		/**
		 * 
		 * @param user
		 * @param password
		 * @param id
		 * 
		 */
		public function requestDownloadForChannel(user:String, password:String, id:String):void
		{
			
			trace("start - requestDownload(" + user + ", ****, channel/" + id + ")");
			
			this._channelId = id;
			
			login(user, password);
			
		}
		
		/**
		 * 
		 * @param user
		 * @param password
		 * 
		 */
		private function login(user:String, password:String):void{
			
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccess);
			this._login.addEventListener(Login.LOGIN_FAIL, function(event:ErrorEvent):void{
				(event.target as Login).close();
				LogManager.instance.addLog(DOWNLOAD_FAIL + event.target + ":" + event.text);
				trace(event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new ErrorEvent(DOWNLOAD_FAIL, false, false, event.text));
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
			
			
			if (_myListId != null)
			{
				this._publicMyListLoader = new PublicMyListLoader();
				this._publicMyListLoader.addEventListener(Event.COMPLETE, getXMLSuccess);
				this._publicMyListLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoadIOErrorHandler);
				this._publicMyListLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoadIOErrorHandler);
				
				this._publicMyListLoader.getMyList(this._myListId);
			}
			else
			{
				this._channelLoader = new ChannelLoader();
				this._channelLoader.addEventListener(Event.COMPLETE, getXMLSuccess);
				this._channelLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoadIOErrorHandler);
				this._channelLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoadIOErrorHandler);
				
				this._channelLoader.getChannel(this._channelId);
			}
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function xmlLoadIOErrorHandler(event:ErrorEvent):void
		{
			(event.target as URLLoader).close();
			
			var targetId:String = "";
			if (this._myListId != null)
			{
				targetId = "mylist/" + this._myListId;
			}
			else
			{
				targetId = "channel/" + this._channelId;
			}
			
			LogManager.instance.addLog(DOWNLOAD_FAIL + ":" +  targetId + ":" + event + ":" + event.target +  ":" + event.text);
			trace(DOWNLOAD_FAIL + ":" +  targetId  + ":" + event + ":" + event.target +  ":" + event.text);
			
			dispatchEvent(new IOErrorEvent(DOWNLOAD_FAIL, false, false, event.text));
			close(false, false);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function getXMLSuccess(event:Event):void{
//			trace((event.target as URLLoader).data);
			
			this._xml = new XML((event.target as URLLoader).data);
			
//			trace(DOWNLOAD_PROCESS_COMPLETE + ":" + event + ":" + xml);
			if (this._myListId != null)
			{
				LogManager.instance.addLog(DOWNLOAD_PROCESS_COMPLETE + ": mylist/" + this._myListId);
			}
			else
			{
				LogManager.instance.addLog(DOWNLOAD_PROCESS_COMPLETE + ": channel/" + this._channelId);
			}
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
			this._channelId = null;
			this._myListId = null;
			this._login = null;
			this._publicMyListLoader = null;
			this._channelLoader = null;
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
			}
			try{
				this._publicMyListLoader.close();
				trace(this._publicMyListLoader + " is closed.");
			}catch(error:Error){
			}
			try{
				this._channelLoader.close();
				trace(this._channelLoader + " is closed.");
			}catch(error:Error){
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