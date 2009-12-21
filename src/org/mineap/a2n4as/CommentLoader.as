package org.mineap.a2n4as
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	
	import org.mineap.a2n4as.util.CommentAnalyzer;
	import org.mineap.a2n4as.util.GetFlvResultAnalyzer;
	import org.mineap.a2n4as.util.GetThreadKeyResultAnalyzer;
	
	[Event(name="commentGetSuccess", type="Event")]
	[Event(name="commentGetFail", type="ErrorEvent")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * ニコニコ動画からコメントを取得します。<br>
	 *  
	 * @author shiraminekeisuke(MineAP)
	 * @eventType CommentLoader.COMMENT_GET_SUCCESS
	 * @eventType CommentLoader.COMMENT_GET_FAIL
	 * @eventType HTTPStatusEvent.HTTP_RESPONSE_STATUS
	 */
	public class CommentLoader extends EventDispatcher
	{
		
		private var _commentLoader:URLLoader;
		
		private var _messageServerUrl:String;
		
		private var _apiAccess:ApiGetFlvAccess;
		
		private var _apiGetThreadkeyAccess:ApiGetThreadkeyAccess;
		
		private var _getflvAnalyzer:GetFlvResultAnalyzer;
		
		private var _commentAnalyzer:CommentAnalyzer;
		
		private var _isOwnerComment:Boolean
		
		private var _count:int = 0;
		
		private var _xml:XML;
		
		public static const COMMENT_GET_SUCCESS:String = "CommentGetSuccess";
		
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
		 * threadIdが指定された場合はapiAccessの結果を使わずに指定されたthreadIdを使用します。
		 * 
		 * @param videoId コメントを取得したい動画のビデオID。
		 * @param count 取得するコメントの数。
		 * @param isOwnerComment 投稿者コメントかどうか
		 * @param apiAccess getFlvにアクセスするApiGetFlvAccessオブジェクト
		 * @param threadId スレッドID
		 */
		public function getComment(videoId:String, count:int, isOwnerComment:Boolean, apiAccess:ApiGetFlvAccess):void
		{
			this._count = count;
			
			this._apiAccess = apiAccess;
			
			this._getflvAnalyzer = new GetFlvResultAnalyzer();
			
			this._isOwnerComment = isOwnerComment;
			
			var isSucess:Boolean = _getflvAnalyzer.analyze(apiAccess.data);
			
			if(!isSucess){
				dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false, _getflvAnalyzer.result));
				close();
				return;
			}
			
			//コメントを投稿する際に使う
			this._messageServerUrl = _getflvAnalyzer.ms;
			
			// getthreadkeyにアクセス
			this._apiGetThreadkeyAccess = new ApiGetThreadkeyAccess();
			this._apiGetThreadkeyAccess.addEventListener(ApiGetThreadkeyAccess.SUCCESS, _getComment);
			this._apiGetThreadkeyAccess.addEventListener(ApiGetThreadkeyAccess.FAIL, function(event:ErrorEvent):void{
				trace(event);
				dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false, _getflvAnalyzer.result));
				close();
			});
			this._apiGetThreadkeyAccess.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
			});
			this._apiGetThreadkeyAccess.getthreadkey(this._getflvAnalyzer.threadId);
			
		}
		
		/**
		 * 
		 */
		private function _getComment(event:Event):void{
			
			//POSTリクエストを生成
			var getComment:URLRequest = new URLRequest(unescape(this._getflvAnalyzer.ms));
			getComment.method = "POST";
			getComment.requestHeaders = new Array(new URLRequestHeader("Content-Type", "text/html"));

			_apiGetThreadkeyAccess.close();
			
			//XMLを生成
			//var xml:String = "<thread fork=\"1\" user_id=\"" + user_id + "\" res_from=\"1000\" version=\"20061206\" thread=\"" + threadId + "\" />";
			var xml:XML = null;
			var fork:String = "";
			if(this._isOwnerComment){
				fork = "fork=\"1\"";
			}
			
			if(this._getflvAnalyzer.needs_key == 1 && !this._isOwnerComment ){ // 投コメは取りに行かないよ
				
				var getThreadKeyResultAnalyzer:GetThreadKeyResultAnalyzer = new GetThreadKeyResultAnalyzer();
				getThreadKeyResultAnalyzer.analyze((event.currentTarget as ApiGetThreadkeyAccess).result);
				
				// 公式 
				/*
				  <thread 
				　thread="******" ← getflv で返ってくる thread_id を使用 
				　version="20061206" 
				　res_from="-1000" 
				　user_id="******" ← getflv で返ってくる user_id を使用 
				　threadkey="******" ← これ以降の属性は getthreadkey で返ってくる内容 
				　force_184="1" 
					　/> 
				*/
				xml = new XML("<thread/>");
				xml.@thread = this._getflvAnalyzer.threadId;
				xml.@version = "20061206";
				xml.@res_from = (this._count * -1);
				xml.@user_id = this._getflvAnalyzer.userId;
				xml.@threadkey = getThreadKeyResultAnalyzer.threadkey;
				xml.@force_184 = getThreadKeyResultAnalyzer.force_184;
			}else{
				xml = new XML("<thread res_from=\"-"+ this._count +"\" "+ fork +" version=\"20061206\" thread=\"" + this._getflvAnalyzer.threadId + "\" />");
			}
//			trace(xml.toXMLString());
			getComment.data = xml;
			
			this._commentLoader.dataFormat=URLLoaderDataFormat.TEXT;
			
			this._commentLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._commentLoader.addEventListener(Event.COMPLETE, commentGetSuccess);
			this._commentLoader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			this._commentLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			
			//読み込み開始
			this._commentLoader.load(getComment);
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseStatusEventHandler(event:HTTPStatusEvent):void{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function commentGetSuccess(event:Event):void{
			try{
				this._xml = new XML((event.currentTarget as URLLoader).data);
				
				var analyzer:CommentAnalyzer = new CommentAnalyzer();
				if(analyzer.analyze(xml, this._count)){
					this._commentAnalyzer = analyzer;
					
					dispatchEvent(new Event(COMMENT_GET_SUCCESS));
					return;	
				}
				
			}catch(error:Error){
				trace(error.getStackTrace())
			}
			dispatchEvent(new ErrorEvent(COMMENT_GET_FAIL, false, false, "fail:analyze"));
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorEventHandler(event:ErrorEvent):void{
			dispatchEvent(new ErrorEvent(COMMENT_GET_FAIL, false, false, event.text));
			close();
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
			return this._getflvAnalyzer.userId;
		}
		
		/**
		 * APIの結果から取得したthreadIdを返します。
		 * @return 
		 * 
		 */
		public function get threadId():String{
			return this._getflvAnalyzer.threadId;
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
			}
			try{
				this._apiGetThreadkeyAccess.close();
			}catch(error:Error){
			}
			try{
				this._apiAccess.close();
			}catch(error:Error){
				
			}
		}

		public function get commentAnalzyer():CommentAnalyzer
		{
			return _commentAnalyzer;
		}

		public function get xml():XML
		{
			return _xml;
		}

		
	}
}