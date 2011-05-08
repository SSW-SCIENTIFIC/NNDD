package org.mineap.nndd
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	
	import org.mineap.nicovideo4as.CommentLoader;
	import org.mineap.nicovideo4as.Login;
	import org.mineap.nicovideo4as.ThumbImgLoader;
	import org.mineap.nicovideo4as.ThumbInfoLoader;
	import org.mineap.nicovideo4as.VideoLoader;
	import org.mineap.nicovideo4as.WatchVideoPage;
	import org.mineap.nicovideo4as.analyzer.GetFlvResultAnalyzer;
	import org.mineap.nicovideo4as.analyzer.GetWaybackkeyResultAnalyzer;
	import org.mineap.nicovideo4as.api.ApiGetBgmAccess;
	import org.mineap.nicovideo4as.loader.IchibaInfoLoader;
	import org.mineap.nicovideo4as.loader.api.ApiGetFlvAccess;
	import org.mineap.nicovideo4as.loader.api.ApiGetWaybackkeyAccess;
	import org.mineap.nicovideo4as.model.NgUp;
	import org.mineap.nicovideo4as.model.VideoType;
	import org.mineap.nicovideo4as.util.HtmlUtil;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.player.comment.Command;
	import org.mineap.nndd.util.PathMaker;
	import org.mineap.nndd.util.ThumbInfoAnalyzer;

	/**
	 * ニコニコ動画にアクセスし、ダウンロードを行います。処理は以下の順に進行します。<br>
	 * 1.ログイン<br>
	 * 2.動画ページへアクセス<br>
	 * 3.コメントのDL<br>
	 * 4.投稿者コメントのDL<br>
	 * 5.ユーザーニコ割のDL(存在する場合)<br>
	 * 6.サムネイル情報をDL<br>
	 * 7.サムネイル画像をDL<br>
	 * 8.市場情報をDL<br>
	 * 9.動画をDL<br>
	 * 各ステップの完了ごとにイベントが発行されます。<br>
	 * また、動画のDL時はプログレスイベントが発行されます。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class NNDDDownloader extends EventDispatcher
	{
		private var _login:Login;
		private var _watchVideo:WatchVideoPage;
		private var _getflvAccess:ApiGetFlvAccess;
		private var _getWaybackkeyAccess:ApiGetWaybackkeyAccess;
		private var _commentLoader:CommentLoader;
		private var _ownerCommentLoader:CommentLoader;
		private var _nicowariLoader:VideoLoader;
		private var _getbgmAccess:ApiGetBgmAccess;
		private var _thumbInfoLoader:ThumbInfoLoader;
		private var _thumbImgLoader:ThumbImgLoader;
		private var _ichibaInfoLoader:IchibaInfoLoader;
		private var _videoLoader:VideoLoader;
		
		private var _flvResultAnalyzer:GetFlvResultAnalyzer;
		
		private var _videoId:String;
		private var _saveDir:File;
		private var _saveVideoName:String;
		private var _streamingUrl:String;
		private var _nicoVideoName:String;
		private var _savedVideoPath:String;
		private var _thumbPath:String;
		private var _threadId:String;
		private var _thumbInfoId:String;
		private var _when:Date;
		private var _waybackkey:String;
		private var _maxCommentCount:Number;
		
		private var _nicowariVideoUrl:String;
		private var _nicowariVideoId:String;
		private var _nicowariVideoUrls:Array;
		private var _nicowariVideoIds:Array;
		
		private var _isVideoNotDownload:Boolean = false;
		private var _isCommentOnlyDownload:Boolean = false;
		private var _isAskToDownloadAtEco:Boolean = true;
		private var _watchVideoOnly:Boolean = false;
		private var _isAlwaysEconomy:Boolean = false;
		private var _isAppendComment:Boolean = false;
		
		/**
		 * ログインに失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const LOGIN_FAIL:String = "LoginFail";
		
		/**
		 * ログインに成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const LOGIN_SUCCESS:String = "LoginSuccess";
		
		/**
		 * 動画ページへのアクセスに失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const WATCH_FAIL:String = "WatchFail";
		
		/**
		 * 動画ページへのアクセスに成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const WATCH_SUCCESS:String = "WatchSuccess";
		
		/**
		 * ニコニコ動画のAPIであるgetflvへのアクセスに失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const GETFLV_API_ACCESS_FAIL:String = "GetFlvAccessFail";
		
		/**
		 * ニコニコ動画のAPIであるgetflvへのアクセスに成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const GETFLV_API_ACCESS_SUCCESS:String = "GetFlvAccessSuccess";
		
		/**
		 * ニコニコ動画のAPIであるgetwaybackkeyへのアクセスに失敗した時、typeプロパティがこの定数に設定されたErrorEventが発行されます。
		 */
		public static const GETWAYBACKKEY_API_ACCESS_FAIL:String = "GetWaybackkeyAccessFail";
		
		/**
		 * ニコニコ動画のAPIであるgetwaybackkeyへのアクセスに失敗した時、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const GETWAYBACKKEY_API_ACCESS_SUCCESS:String = "GetWaybackkeyAccessSuccess";
		
		/**
		 * 通常コメントの取得に失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const COMMENT_GET_FAIL:String = "CommentGetFail";
		
		/**
		 * 通常コメントの取得に成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const COMMENT_GET_SUCCESS:String = "CommentGetSuccess";
		
		/**
		 * 投稿者コメントの取得に失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const OWNER_COMMENT_GET_FAIL:String = "OwnerCommentGetFail";
		
		/**
		 * 投稿者コメントの取得に成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const OWNER_COMMENT_GET_SUCCESS:String = "OwnerCommentGetSuccess";
		
		/**
		 * ニコ割の取得に失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const NICOWARI_GET_FAIL:String = "NicowariGetFail";
		
		/**
		 * ニコ割の取得に成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const NICOWARI_GET_SUCCESS:String = "NicowariGetSuccess";
		
		/**
		 * サムネイル情報の取得に失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const THUMB_INFO_GET_FAIL:String = "ThumbInfoGetFail";
		
		/**
		 * サムネイル情報の取得に成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const THUMB_INFO_GET_SUCCESS:String = "ThumbInfoGetSuccess";
		
		/**
		 * サムネイル画像の取得に失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const THUMB_IMG_GET_FAIL:String = "ThumbImgGetFail";
		
		/**
		 * サムネイル画像の取得に成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const THUMB_IMG_GET_SUCCESS:String = "ThumbImgGetSuccess";
		
		/**
		 * 市場情報の取得に失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const ICHIBA_INFO_GET_FAIL:String = "IchibaInfoGetFail";
		
		/**
		 * 市場情報の取得に成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const ICHIBA_INFO_GET_SUCCESS:String = "IchibaInfoGetSuccess";
		
		/**
		 * 動画の取得に失敗したとき、typeプロパティがこの定数に設定されたIOErrorEventが発行されます。
		 */
		public static const VIDEO_GET_FAIL:String = "VideoGetFail";
		
		/**
		 * 動画の取得に成功したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const VIDEO_GET_SUCCESS:String = "VideoGetSuccess";
		
		/**
		 * 動画の取得中に、typeプロパティがこの定数に設定されたProgressEventが発行されます。
		 */
		public static const VIDEO_DOWNLOAD_PROGRESS:String = "VideoDownloadProgress";
		
		/**
		 * ダウンロード処理が通常に終了したとき、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const DOWNLOAD_PROCESS_COMPLETE:String = "DownloadProcessComplete";
		
		/**
		 * ダウンロード処理が中断された際に、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const DOWNLOAD_PROCESS_CANCELD:String = "DonwloadProcessCancel";
		
		/**
		 * ダウンロード処理が以上終了した際に、typeプロパティがこの定数に設定されたEventが発行されます。
		 */
		public static const DOWNLOAD_PROCESS_ERROR:String = "DownloadProccessError";
		
		/**
		 * コンストラクタです。
		 * 
		 */
		public function NNDDDownloader()
		{
			
			this._login = new Login();
			this._watchVideo = new WatchVideoPage();
			this._getflvAccess = new ApiGetFlvAccess();
			this._commentLoader = new CommentLoader();
			this._ownerCommentLoader = new CommentLoader();
			this._nicowariLoader = new VideoLoader();
			this._getbgmAccess = new ApiGetBgmAccess();
			this._thumbInfoLoader = new ThumbInfoLoader();
			this._thumbImgLoader = new ThumbImgLoader();
			this._ichibaInfoLoader = new IchibaInfoLoader();
			this._videoLoader = new VideoLoader();
			
			this._nicowariVideoIds = new Array();
			this._nicowariVideoUrls = new Array();
		}
		
		/**
		 * ニコニコ動画に対して、動画のダウンロードをリクエストします。
		 * 
		 * @param user ニコニコ動画のアカウント名（メールアドレス）
		 * @param password ニコニコ動画にログインするためのパスワード
		 * @param videoId ダウンロードしたい動画ID
		 * @param saveVideoName 保存するときの動画の名前。未指定の場合は動画ページのタイトルを使う。
		 * @param saveDir 保存先ディレクトリ
		 * @param isStart すぐにダウンロードを開始するかどうか。trueの場合は即時実行。
		 * @param isAskToDownloadAtEco エコノミーの際にユーザー問い合わせをするかどうか。
		 * @param isAlwaysEconomy 常にエコノミーモードでダウンロードするかどうか
		 * @param isAppendComment 古いコメントファイルに今回ダウンロードしたコメントを追記するかどうか
		 * @param maxCommentCount 古いコメントファイルにコメントを追加する際、保存するコメントの最大数
		 */
		public function requestDownload(user:String, 
										password:String, 
										videoId:String, 
										saveVideoName:String, 
										saveDir:File, 
										isStart:Boolean, 
										isAskToDownloadAtEco:Boolean, 
										isAlwaysEconomy:Boolean, 
										isAppendComment:Boolean, 
										maxCommentCount:Number):void{
			
			trace("start - requestDownload(" + user + ", ****, " + videoId + ", " + saveDir.nativePath + ")");
			
			this._videoId = videoId;
			this._thumbInfoId = videoId;
			this._saveDir = saveDir;
			this._isAskToDownloadAtEco = isAskToDownloadAtEco;
			this._isAlwaysEconomy = isAlwaysEconomy;
			this._isAppendComment = isAppendComment;
			this._maxCommentCount = maxCommentCount;
			
			//ストリーミング再生の時のファイル名は「nndd」。それ以外のときは「ファイル名+[動画ID]」
			if(saveVideoName != null && saveVideoName != "" && saveVideoName != "nndd"){
				this._saveVideoName = saveVideoName + " - [" + videoId + "]";
			}else if(saveVideoName == "nndd"){
				this._saveVideoName = "nndd";
			}else{
				this._saveVideoName = "";
			}
			
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccess);
			this._login.addEventListener(Login.LOGIN_FAIL, function(event:ErrorEvent):void{
//				(event.target as Login).close();
				LogManager.instance.addLog(LOGIN_FAIL + event.target + ":" + event.text);
//				trace(event + ":" + event.target +  ":" + event.text);
//				dispatchEvent(new IOErrorEvent(LOGIN_FAIL, false, false, event.text));
//				close(true, true, event);
				
				//強引に取りに行く
				loginSuccess(event);
			});
			this._login.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			
			if(isStart){
				this._login.login(user, password);
			}
		}
		
		/**
		 * ストリーミング再生用。
		 * 
		 * @param user ニコニコ動画のアカウント名（メールアドレス）
		 * @param password ニコニコ動画にログインするためのパスワード
		 * @param videoId ダウンロードしたい動画ID
		 * @param saveDir 保存先ディレクトリ
		 * @param isAlwaysEconomy 常にエコノミーモードで再生するかどうか
		 * 
		 */
		public function requestDownloadForStreaming(user:String, 
													password:String, 
													videoId:String, 
													saveDir:File, 
													isAlwaysEconomy:Boolean):void{
			
			this._isCommentOnlyDownload = false;
			this._isVideoNotDownload = true;
			
			this.requestDownload(user, password, videoId, "nndd", saveDir, true, false, isAlwaysEconomy, false, 2000);
			
		}
		
		/**
		 * 動画以外をダウンロードします。
		 * 
		 * @param user
		 * @param pasword
		 * @param videoId
		 * @param videoName
		 * @param saveDir
		 * @param isAlwaysEconomy
		 * @param isAppendComment
		 * @param when
		 */
		public function requestDownloadForOtherVideo(user:String, 
													 password:String, 
													 videoId:String, 
													 videoName:String, 
													 saveDir:File, 
													 isAlwaysEconomy:Boolean, 
													 isAppendComment:Boolean, 
													 when:Date,
													 maxCommentCount:Number):void{
			this._isCommentOnlyDownload = false;
			this._isVideoNotDownload = true;
			this._when = when;
			
			this.requestDownload(user, password, videoId, videoName, saveDir, true, false, isAlwaysEconomy, isAppendComment, maxCommentCount);
		}
		
		/**
		 * コメントのみをダウンロードします。
		 * 
		 * @param user
		 * @param password
		 * @param videoId
		 * @param saveDir
		 * @param isAlwaysEconomy
		 * @param isAppendComment 
		 * @param when
		 */
		public function requestDownloadForCommentOnly(user:String, 
													  password:String, 
													  videoId:String, 
													  videoName:String, 
													  saveDir:File, 
													  isAlwaysEconomy:Boolean, 
													  isAppendComment:Boolean, 
													  when:Date, 
													  maxCommentCount:Number):void{
			
			this._isCommentOnlyDownload = true;
			this._isVideoNotDownload = true;
			this._when = when;
			
			this.requestDownload(user, password, videoId, videoName, saveDir, true, false, isAlwaysEconomy, isAppendComment, maxCommentCount);
			
		}
		
		/**
		 * 動画ページへのアクセスのみを行います。
		 * 
		 * @param user
		 * @param password
		 * @param videoId
		 * @param videoName
		 * 
		 */
		public function requestForWatchOnly(user:String, password:String, videoId:String, videoName:String):void{
			
			this._isCommentOnlyDownload = true;
			this._isVideoNotDownload = true;
			this._watchVideoOnly = true;
			
			this.requestDownload(user, password, videoId, videoName, File.documentsDirectory, true, false, false, false, 2000);
			
		}
		
		
		/**
		 * 
		 * @param user
		 * @param password
		 * 
		 */
		public function requestStart(user:String, password:String):void{
			
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
			LogManager.instance.addLog("\t" + LOGIN_SUCCESS + ":" + this._videoId + ":" +  this._nicoVideoName);
			dispatchEvent(new Event(LOGIN_SUCCESS));
			
			// closeが呼ばれていないか？
			if (this._watchVideo == null)
			{
				return;
			}
			
			//リスナ追加
			this._watchVideo.addEventListener(WatchVideoPage.WATCH_SUCCESS, watchSuccess);
			this._watchVideo.addEventListener(WatchVideoPage.WATCH_FAIL, function(event:ErrorEvent):void{
				(event.target as WatchVideoPage).close();
				LogManager.instance.addLog(WATCH_FAIL + ":" +  _videoId + ":" + event + ":" + event.target +  ":" + event.text);
				trace(WATCH_FAIL + ":" +  _videoId + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(WATCH_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._watchVideo.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				var videoId:String = PathMaker.getVideoID(event.responseURL);
				// リダイレクトされた。
				if(videoId != _videoId){
					LogManager.instance.addLog("リダイレクト: " + _videoId + " -> " + videoId);
					_videoId = videoId;
				}
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			
			//this._videoIdの動画のページを見に行く
			var videoId:String = this._videoId;
			if(this._isAlwaysEconomy){
				videoId += "?eco=1";
			}
			this._watchVideo.watchVideo(videoId);
			
		}
		
		/**
		 * 動画ページへのアクセスが完了したら呼ばれます。
		 * コメントのダウンロードを開始します。
		 * 
		 * @param event
		 * 
		 */
		private function watchSuccess(event:Event):void{
			
			// closeが呼ばれていないか？
			if (this._getflvAccess == null)
			{
				return;
			}
			
			var videoId:String = this._watchVideo.getVideoId();
			if(videoId != this._thumbInfoId){
				this._thumbInfoId = videoId;
				LogManager.instance.addLog("サムネイル情報用ID:" + videoId);
			}
			
			if(this._saveVideoName == null || this._saveVideoName == ""){
				this._saveVideoName = getVideoName(event.target.data);
			}
			this._nicoVideoName = getVideoName(event.target.data);
			if(this._saveVideoName == null || this._saveVideoName == ""){
				LogManager.instance.addLog(WATCH_FAIL + ":VideoNameNotFound:" +  _videoId);
				trace(WATCH_FAIL + ":VideoNameNotFound");
				dispatchEvent(new IOErrorEvent(WATCH_FAIL, false, false, "VideoNameNotFound"));
				close(true, true, new IOErrorEvent(WATCH_FAIL, false, false, "VideoNameNotFound"));
				return;
			}
			trace(this._saveVideoName);
			
			//動画ページアクセス完了通知(動画ページへのアクセスは閉じない)
			trace(WATCH_SUCCESS + ":" + event);
			LogManager.instance.addLog("\t" + WATCH_SUCCESS + ":" + this._videoId + ":" +  this._nicoVideoName);
			dispatchEvent(new Event(WATCH_SUCCESS));
			
			//動画ページの閲覧のみ。
			if(this._watchVideoOnly){
				close(false, false);
				return;
			}
			
			//APIアクセス開始
			this._getflvAccess.addEventListener(IOErrorEvent.IO_ERROR, function(event:ErrorEvent):void{
				(event.target as URLLoader).close();
				LogManager.instance.addLog(GETFLV_API_ACCESS_FAIL + ":" + _videoId + ":" + event + ":" + event.target +  ":" + event.text);
				trace(GETFLV_API_ACCESS_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(GETFLV_API_ACCESS_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._getflvAccess.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			this._getflvAccess.addEventListener(Event.COMPLETE, getFlvAccessSuccess);
			this._getflvAccess.getAPIResult(this._videoId, this._isAlwaysEconomy);
			
		}
		
		/**
		 * getflvへのアクセスに成功した場合に呼ばれます。
		 * 
		 * @param event
		 * 
		 */
		private function getFlvAccessSuccess(event:Event):void{
			
			//APIアクセス成功(アクセスは閉じない)
			trace(GETFLV_API_ACCESS_SUCCESS + ":" + event);
			LogManager.instance.addLog("\t" + GETFLV_API_ACCESS_SUCCESS + ":" + this._videoId + ":" +  this._nicoVideoName);
			dispatchEvent(new Event(GETFLV_API_ACCESS_SUCCESS));
			
			this._flvResultAnalyzer = new GetFlvResultAnalyzer();
			this._flvResultAnalyzer.analyze(this._getflvAccess.data);
			this._threadId = this._flvResultAnalyzer.threadId;
			
			if(this._when == null){
				//過去ログは取得しない
				getNormalComment();
			}else{
				//過去ログモード
				this._getWaybackkeyAccess = new ApiGetWaybackkeyAccess();
				
				this._getWaybackkeyAccess.addEventListener(Event.COMPLETE, getWaybackkeySuccess);
				this._getWaybackkeyAccess.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
					(event.target as ApiGetWaybackkeyAccess).close();
					LogManager.instance.addLog(GETWAYBACKKEY_API_ACCESS_FAIL + ":" + _videoId + ":" + event + ":" + event.target +  ":" + event.text);
					trace(GETWAYBACKKEY_API_ACCESS_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
					dispatchEvent(new IOErrorEvent(GETWAYBACKKEY_API_ACCESS_FAIL, false, false, event.text));
					close(true, true, event);
				});
				this._getWaybackkeyAccess.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
					trace(event);
					LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
				});
				this._getWaybackkeyAccess.getAPIResult(this._threadId);
			}
		}
		
		/**
		 * waybackkey APIへのアクセスが完了したら呼ばれるイベントハンドラです。
		 * @param event
		 * 
		 */
		private function getWaybackkeySuccess(event:Event):void{
			
			var analyzer:GetWaybackkeyResultAnalyzer = new GetWaybackkeyResultAnalyzer();
			analyzer.analyzer(this._getWaybackkeyAccess.data);
			trace(this._getWaybackkeyAccess.data);
			
			if(analyzer.waybackkey != null && analyzer.waybackkey.length > 0 ){
				// 取得続行
				trace(GETWAYBACKKEY_API_ACCESS_SUCCESS + ":" + event);
				dispatchEvent(new Event(GETWAYBACKKEY_API_ACCESS_SUCCESS, false, false));
				this._waybackkey = analyzer.waybackkey;
				getNormalComment();
			}else{
				// waybackkey取得失敗。中断。
				(event.target as ApiGetWaybackkeyAccess).close();
				LogManager.instance.addLog(GETWAYBACKKEY_API_ACCESS_FAIL + ":" + _videoId + ":" + event + ":" + event.target);
				trace(GETWAYBACKKEY_API_ACCESS_FAIL + ":" + event + ":" + event.target);
				dispatchEvent(new IOErrorEvent(GETWAYBACKKEY_API_ACCESS_FAIL, false, false));
				close(true, true);
			}
		}
		
		/**
		 * 通常コメントの取得を開始します。
		 * 
		 */
		private function getNormalComment():void{
			
			// closeが呼ばれていないか？
			if (this._commentLoader == null)
			{
				return;
			}
			
			//リスナ追加
			this._commentLoader.addEventListener(CommentLoader.COMMENT_GET_SUCCESS, commentGetSuccess);
			this._commentLoader.addEventListener(CommentLoader.COMMENT_GET_FAIL, function(event:ErrorEvent):void{
				(event.target as CommentLoader).close();
				LogManager.instance.addLog(COMMENT_GET_FAIL + ":" + _videoId + ":" + event + ":" + event.target +  ":" + event.text);
				trace(COMMENT_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._commentLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			//通常コメントを1000件取りにいく
			this._commentLoader.getComment(this._videoId, 1000, false, this._getflvAccess, this._when, this._waybackkey);
		}
		
		
		/**
		 * 動画ページのタイトルから動画のタイトルを取得します。
		 * @param html
		 * 
		 */
		private function getVideoName(html:String):String{
			var pattern:RegExp = new RegExp("<title>(.*)</title>","ig"); 
			
			var array:Array = pattern.exec(html);
			
			var videoName:String = "";
			
			if(array != null && array.length > 1){
				videoName = array[1];
				var index:int = videoName.lastIndexOf("‐ ニコニコ動画(");
				if(index != -1){
					videoName = videoName.substr(0, index);
				}
			}
			
			var videoId:String = PathMaker.getVideoID(this._videoId);
			
			videoName = HtmlUtil.convertSpecialCharacterNotIncludedString(videoName) + " - [" + videoId + "]";
			videoName = FileIO.getSafeFileName(videoName);
			
			return videoName 
			
		}
		
		/**
		 * コメントのダウンロードが終わったら呼ばれます。
		 * コメントの保存後、投稿者コメントのダウンロードを開始します。
		 * 
		 * @param event
		 * 
		 */
		private function commentGetSuccess(event:Event):void{
			
			if(this._commentLoader.economyMode && saveVideoName != "nndd" && this._isAskToDownloadAtEco){
				Alert.show("現在エコノミーモードです。ダウンロードしますか？", Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(closeEvent:CloseEvent):void{
					if(closeEvent.detail == Alert.YES){
						ownerCommentGetStart(event.currentTarget as CommentLoader);
					}else{
						trace(DOWNLOAD_PROCESS_CANCELD + ":" + event);
						dispatchEvent(new Event(DOWNLOAD_PROCESS_CANCELD));
						close(true, false, null);
					}
				});
			}else{
				ownerCommentGetStart(event.currentTarget as CommentLoader);
			}
				
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function ownerCommentGetStart(loader:CommentLoader):void{
			
			// closeが呼ばれていないか？
			if (this._ownerCommentLoader == null)
			{
				return;
			}
			
			var fileIO:FileIO = new FileIO();
			fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				trace(COMMENT_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(COMMENT_GET_FAIL + ":" + _saveVideoName + ".xml" + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(COMMENT_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			var path:String = fileIO.saveComment(loader.xml, this._saveVideoName + ".xml", this._saveDir.url, this._isAppendComment, this._maxCommentCount).nativePath;
			
			this._threadId = this._commentLoader.threadId;
			
			//通常コメントの取得完了を通知
			loader.close();
			this._commentLoader.close();
			LogManager.instance.addLog("\t" + COMMENT_GET_SUCCESS + ":" + path);
			trace(COMMENT_GET_SUCCESS + ":" + loader + "\n" + path);
			dispatchEvent(new Event(COMMENT_GET_SUCCESS));
			
			this._ownerCommentLoader.addEventListener(CommentLoader.COMMENT_GET_SUCCESS, ownerCommentGetSuccess);
			this._ownerCommentLoader.addEventListener(CommentLoader.COMMENT_GET_FAIL, function(event:ErrorEvent):void{
				(event.target as CommentLoader).close();
				trace(OWNER_COMMENT_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(OWNER_COMMENT_GET_FAIL + ":" + _videoId + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(OWNER_COMMENT_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._ownerCommentLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			//isOwner=trueでコメントを取得しにいく。過去コメントは取りに行かない。
			this._ownerCommentLoader.getComment(this._videoId, 1000, true, this._getflvAccess, null, null);
			
		}
		
		
		/**
		 * 投稿者コメントのダウンロードが終わったら呼ばれます。
		 * 投稿者コメントの保存後、ユーザーニコ割のダウンロードを開始します。
		 * 
		 * @param event
		 * 
		 */
		private function ownerCommentGetSuccess(event:Event):void{
			
			// closeが呼ばれていないか？
			if (this._getbgmAccess == null)
			{
				return;
			}
			
			var fileIO:FileIO = new FileIO();
			fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				trace(OWNER_COMMENT_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(OWNER_COMMENT_GET_FAIL + ":" + _saveVideoName + "[Owner].xml" + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(OWNER_COMMENT_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			
			var ownerComments:XML = (event.currentTarget as CommentLoader).xml;
			
			var ngups:XML = new XML("<ngups/>");
			//投稿者によってフィルタが設定されていればそれを投稿者コメントXMLファイルに追記
			for each(var ngup:NgUp in this._ownerCommentLoader.ngWords){
				var xml:XML = new XML("<ngup/>");
				xml.@ngword = encodeURIComponent(ngup.ngWord);
				xml.@changeValue = encodeURIComponent(ngup.changeValue);
				ngups.appendChild(xml);
			}
			ownerComments.appendChild(ngups);
			
			var path:String = fileIO.saveComment(ownerComments, this._saveVideoName + "[Owner].xml", this._saveDir.url, this._isAppendComment, this._maxCommentCount).nativePath;
			
			this._threadId = this._ownerCommentLoader.threadId;
			
			//投稿者コメントの取得完了を通知
			(event.currentTarget as CommentLoader).close();
			this._ownerCommentLoader.close();
			LogManager.instance.addLog("\t" + OWNER_COMMENT_GET_SUCCESS + ":" + path);
			trace(OWNER_COMMENT_GET_SUCCESS + ":" + event + "\n" + path);
			dispatchEvent(new Event(OWNER_COMMENT_GET_SUCCESS));
			
			if(this._isCommentOnlyDownload){
				//コメントのみ取得。全行程終了
				trace(DOWNLOAD_PROCESS_COMPLETE + ":" + event);
				dispatchEvent(new Event(DOWNLOAD_PROCESS_COMPLETE));
				
				close(false, false);
			} else {
				
				//投稿者コメントを解析して@cm命令を探す
				this._nicowariVideoIds = this.searchAtCMInstruction(ownerComments);
				
				if(this._nicowariVideoIds.length == 0){
					//投コメにニコ割は指定されていない。getbgmを確認せずにサムネイル情報取得へ
					getThumbInfo(this._thumbInfoId);
				}else{
					//投コメにニコ割が指定されている。getbgmを確認してニコ割をダウンロード
					this._getbgmAccess.addEventListener(ApiGetBgmAccess.SUCCESS, getNicowariUrlsSuccess);
					this._getbgmAccess.addEventListener(ApiGetBgmAccess.FAIL, function(event:IOErrorEvent):void{
						(event.currentTarget as ApiGetBgmAccess).close();
						trace(NICOWARI_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
						LogManager.instance.addLog(NICOWARI_GET_FAIL + ":" + _videoId + ":" + event + ":" + event.target +  ":" + event.text);
						dispatchEvent(new IOErrorEvent(NICOWARI_GET_FAIL, false, false, event.text));
						close(true, true, event);
					});
					this._getbgmAccess.getAPIResult(this._threadId);
				}
			}
		}
		
		/**
		 * 投稿者コメントから@CM命令で指定されたユーザーニコ割の動画IDを探します。
		 * 
		 * @param ownerComment 投稿者コメント
		 * @return 動画IDの配列
		 * 
		 */
		private function searchAtCMInstruction(ownerComment:XML):Array{
			var xmlList:XMLList = ownerComment.chat;
			var nicowariVideoIDs:Array = new Array();
			
			var command:Command = new Command();
			for each(var com:String in xmlList){
				var nicowariID:String = command.getNicowariVideoID(com)[0];
				if( nicowariID != null && nicowariID != ""){
					nicowariVideoIDs.push(nicowariID);
				}
			}
			
			return nicowariVideoIDs;
		}
		
		/**
		 * 投稿者コメントを解析して、ユーザーニコ割が存在するかどうか調べます。
		 * 存在する場合、ニコ割のIDを配列に格納して返します。存在しない場合はカラの配列を返します。
		 * 
		 * @param ownerComment 投稿者コメントXML
		 * @return ニコ割の動画IDを格納する配列
		 * 
		 */
		private function getNicowariUrlsSuccess(event:Event):void{
			
			var nicowariVideoUrlsByGetBgm:Array = this._getbgmAccess.getNicowariUrl();
			var nicowariVideoIdByGetBgm:Array = this._getbgmAccess.getNicowariVideoIds();
			
			//取得したURLから実際に@CM命令で再生を指示されている物を抽出
			for each(var id:String in this._nicowariVideoIds){
				for(var i:int = 0; i < nicowariVideoIdByGetBgm.length; i++){
					if(id == nicowariVideoIdByGetBgm[i]){
						//実際に@CM命令で指定されているニコ割。
						
						var exists:Boolean = false;
						for each(var url:String in this._nicowariVideoUrls){
							if(url == nicowariVideoUrlsByGetBgm[i]){
								exists = true;
								break;
							}
						}
						
						//既に追加済みの場合はスキップ
						if(!exists){
							this._nicowariVideoUrls.push(nicowariVideoUrlsByGetBgm[i]);
						}
						break;
					}
				}
			}
			
			trace("getbgm:" + this._nicowariVideoIds + ":" + this._nicowariVideoUrls);
			this._getbgmAccess.close();
			
			if(this._isCommentOnlyDownload){
				
				//コメントのみのダウンロードはココで終了
				dispatchEvent(new Event(NNDDDownloader.DOWNLOAD_PROCESS_COMPLETE));
				
			}else if(this._nicowariVideoUrls == null || this._nicowariVideoUrls.length <= 0){
				//ニコ割無し
				getThumbInfo(this._thumbInfoId);
				
			}else{
				
				{
					// 重複するnicowariVideoIdを取り除く
					var tempVideoIds:Array = new Array();
					for each(var nicowariVideoId:String in this._nicowariVideoIds){
						
						var exists:Boolean = false;
						for each(var tempId:String in tempVideoIds){
							if(nicowariVideoId == tempId){
								exists = true;
								break;
							}
						}
						
						if(!exists){
							tempVideoIds.push(nicowariVideoId);
						}
					}
					this._nicowariVideoIds = tempVideoIds;
				}
				
				trace("getbgm:" + this._nicowariVideoIds);
				LogManager.instance.addLog("\tgetbgm:" + this._nicowariVideoIds);
				
				//ニコ割あり
				getNicowari();
			}
		}
		
		/**
		 * ニコ割を取得します。
		 */
		private function getNicowari():void{
			
			this._nicowariVideoUrl = this._nicowariVideoUrls.shift();
			this._nicowariVideoId = this._nicowariVideoIds.shift();
			
			this._nicowariLoader.addVideoLoaderListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				(event.target as URLLoader).close();
				trace(NICOWARI_GET_FAIL + ":" +  _nicowariVideoId + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(NICOWARI_GET_FAIL + ":" + _videoId + ":" + _nicowariVideoId + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(NICOWARI_GET_FAIL, false, false, event.text));
//				close(true, true, event);
				
				// ニコ割が取れていなくても次へ
				if(_nicowariVideoIds.length <= 0 || _nicowariVideoUrls.length <= 0){
					//サムネイル情報取得
					getThumbInfo(_thumbInfoId);
					
				}else{
					//次のニコ割を取りにいく
					//次で使う為にloaderを初期化
					_nicowariLoader = new VideoLoader();
					getNicowari();
				}
			});
			this._nicowariLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			this._nicowariLoader.addVideoLoaderListener(Event.COMPLETE, nicowariGetSuccess);
			this._nicowariLoader.getVideoForApiResult(this._nicowariVideoUrl);
		}
		
		/**
		 * ニコ割のダウンロードが終わったら呼ばれます。
		 * ニコ割の保存後、ダウンロードすべきニコ割がまだ残っていれば続けてニコ割をダウンロードし、
		 * ダウンロードすべきニコ割が無ければサムネイル情報の取得を開始します。
		 * 
		 * @param event
		 * 
		 */
		private function nicowariGetSuccess(event:Event):void{
			
			var fileName:String = this._saveVideoName + "[Nicowari]" + "[" + this._nicowariVideoId + "].swf";
			
			var fileIO:FileIO = new FileIO();
			fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				trace(NICOWARI_GET_FAIL + ":" + fileName + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(NICOWARI_GET_FAIL + ":" + fileName + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(NICOWARI_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			var file:File = fileIO.saveVideoByURLLoader((event.target as URLLoader), fileName, this._saveDir.url);
			
			//ニコ割取得完了を通知
			(event.target as URLLoader).close();
			this._nicowariLoader.close();
			trace(event + "\n" + file.nativePath);
			LogManager.instance.addLog("\t" + NICOWARI_GET_SUCCESS + ":" + file.nativePath);
			dispatchEvent(new Event(NICOWARI_GET_SUCCESS));
			
			if(this._nicowariVideoIds.length <= 0 || this._nicowariVideoUrls.length <= 0){
				//サムネイル情報取得
				getThumbInfo(this._thumbInfoId);
				
			}else{
				//次のニコ割を取りにいく
				//次で使う為にloaderを初期化
				this._nicowariLoader = new VideoLoader();
				getNicowari();
			}
			
		}
		
		/**
		 * サムネイル情報を取得します。
		 * 
		 * @param videoId
		 * 
		 */
		private function getThumbInfo(videoId:String):void{
			
			// closeが呼ばれていないか？
			if (this._thumbInfoLoader == null)
			{
				return;
			}
			
			this._thumbInfoLoader.addEventListener(ThumbInfoLoader.FAIL, function(event:IOErrorEvent):void{
				(event.target as URLLoader).close();
				trace(THUMB_INFO_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(THUMB_INFO_GET_FAIL + ":" + videoId + "(" + _videoId + "):" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(THUMB_INFO_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._thumbInfoLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			this._thumbInfoLoader.addEventListener(ThumbInfoLoader.SUCCESS, thumbInfoGetSuccess);
			this._thumbInfoLoader.getThumbInfo(videoId);
			
		}
		
		/**
		 * サムネイル情報の取得が完了したら呼ばれます。<br>
		 * サムネルの保存が完了したら、サムネイル画像の取得を行います。
		 * 
		 * @param event
		 * 
		 */
		private function thumbInfoGetSuccess(event:Event):void{
			
			// closeが呼ばれていないか？
			if (this._thumbImgLoader == null)
			{
				return;
			}
			
			try{
			
				var xml:XML = new XML((event.currentTarget as ThumbInfoLoader).thumbInfo);
				
				var analyzer:ThumbInfoAnalyzer = new ThumbInfoAnalyzer(xml);
				
				// サムネイル情報を取得したが動画は削除済み。サムネ情報およびサムネ画像取得をスキップして市場を取りに行く
				if(analyzer.status == ThumbInfoAnalyzer.STATUS_FAIL){
					
					downloadIchibaInfo();
					
					return;
				}
				
			}catch(error:Error){
				trace(error.getStackTrace());
				
				// 取得したサムネイルが正しくない。スキップして市場を取りに行く
				downloadIchibaInfo();
				
				return;
			}
			
			var fileIO:FileIO = new FileIO();
			fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				trace(THUMB_INFO_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(THUMB_INFO_GET_FAIL + ":" + _saveVideoName + "[ThumbInfo].xml" + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(THUMB_INFO_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			var path:String = fileIO.saveComment(new XML((event.currentTarget as ThumbInfoLoader).thumbInfo), this._saveVideoName + "[ThumbInfo].xml", this._saveDir.url, false, 0).nativePath;
			
			//サムネイル情報取得完了通知
			this._thumbInfoLoader.close();
			trace(THUMB_INFO_GET_SUCCESS + ":" + event + "\n" + path);
			LogManager.instance.addLog("\t" + THUMB_INFO_GET_SUCCESS + ":" + path);
			dispatchEvent(new Event(THUMB_INFO_GET_SUCCESS));
			
			this._thumbImgLoader.addThumbImgLoaderListener(Event.COMPLETE, thumbImgGetSuccess);
			this._thumbImgLoader.addThumbImgLoaderListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
//				(event.target as URLLoader).close();
				trace(THUMB_IMG_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(THUMB_IMG_GET_FAIL + ":" + _videoId + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(THUMB_IMG_GET_FAIL, false, false, event.text));
				downloadIchibaInfo();
			});
			this._thumbImgLoader.addThumbImgLoaderListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			try{
				// サムネ情報からサムネ画像を取得
				var thumbUrl:String = this._thumbImgLoader.getThumbImgUrl(XML((event.currentTarget as ThumbInfoLoader).thumbInfo));
				if(thumbUrl != null && thumbUrl != ""){
					this._thumbImgLoader.getThumbImgByUrl(thumbUrl);
				}else{
					
					// サムネ情報から取得できなければ自分で作る
					thumbUrl = PathMaker.getThumbImgUrl(this._thumbInfoId);
					this._thumbImgLoader.getThumbImgByUrl(thumbUrl);
					
				}
			}catch(error:Error){
				trace(error + ":" + error.getStackTrace());
				LogManager.instance.addLog(THUMB_INFO_GET_FAIL + ":" + _videoId + ":" + error.getStackTrace());
				dispatchEvent(new IOErrorEvent(THUMB_IMG_GET_FAIL, false, false, error.getStackTrace()));
				close(true, true, new IOErrorEvent(THUMB_IMG_GET_FAIL, false, false, error.getStackTrace()));
			}
			
		}
		
		/**
		 * サムネイル画像のダウンロードが完了したら呼ばれます。<br>
		 * サムネイル画像の保存が完了したら市場情報のダウンロードを行います。
		 * 
		 * @param event
		 * 
		 */
		private function thumbImgGetSuccess(event:Event):void{
			
			var fileIO:FileIO = new FileIO();
			fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				trace(THUMB_IMG_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(THUMB_IMG_GET_FAIL + ":" + _videoId + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(THUMB_IMG_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._thumbPath = fileIO.saveByteArray(this._saveVideoName + "[ThumbImg].jpeg", this._saveDir.url, (event.target as URLLoader).data).url;
			
			//サムネイル画像取得完了通知
			(event.target as URLLoader).close();
			this._thumbImgLoader.close();
			LogManager.instance.addLog("\t" + THUMB_IMG_GET_SUCCESS + ":" + (new File(this._thumbPath)).nativePath);
			trace(THUMB_IMG_GET_SUCCESS + ":" + event + "\n" + (new File(this._thumbPath)).nativePath);
			dispatchEvent(new Event(THUMB_IMG_GET_SUCCESS));
			
			//市場情報の取得
			downloadIchibaInfo();
		}
		
		/**
		 * サムネイル情報の取得を行います。
		 * 
		 */
		private function downloadIchibaInfo():void{
			
			// closeがよばれていないか？
			if (this._ichibaInfoLoader == null)
			{
				return;
			}
			
			this._ichibaInfoLoader.addEventListener(Event.COMPLETE, ichibaInfoGetSuccess);
			this._ichibaInfoLoader.addEventListener(IOErrorEvent.IO_ERROR, function(event:ErrorEvent):void{
				(event.target as IchibaInfoLoader).close();
				LogManager.instance.addLog(ICHIBA_INFO_GET_FAIL + ":" + _videoId + "("+ _thumbInfoId +"):" + event + ":" + event.target +  ":" + event.text);
				trace(ICHIBA_INFO_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(ICHIBA_INFO_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._ichibaInfoLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			this._ichibaInfoLoader.getIchibaInfo(this._thumbInfoId);
		}
		
		/**
		 * 市場情報のダウンロードが完了したら呼ばれます。<br>
		 * 市場情報の保存が完了したら、動画のダウンロードを行います。
		 * 
		 * @param event
		 * 
		 */
		private function ichibaInfoGetSuccess(event:Event):void{
			
			// closeがよばれていないか？
			if (this._videoLoader == null)
			{
				return;
			}
			
			var fileIO:FileIO = new FileIO();
			fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				trace(ICHIBA_INFO_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(ICHIBA_INFO_GET_FAIL + ":" + _saveVideoName + "[IchibaInfo].html" + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(ICHIBA_INFO_GET_FAIL, false, false, event.text));
				close(true, true);
			});
			var path:String = fileIO.saveHtml(((event.target as IchibaInfoLoader).data as String), this._saveVideoName + "[IchibaInfo].html", this._saveDir.url).nativePath;
			
			//市場情報取得完了通知
			this._ichibaInfoLoader.close();
			LogManager.instance.addLog("\t" + ICHIBA_INFO_GET_SUCCESS + ":" + path);
			trace(ICHIBA_INFO_GET_SUCCESS + ":" + event + "\n" + path);
			dispatchEvent(new Event(ICHIBA_INFO_GET_SUCCESS));
			
			this._videoLoader.addVideoLoaderListener(VideoLoader.VIDEO_URL_GET_FAIL, function(event:IOErrorEvent):void{
				(event.target as URLLoader).close();
				trace(VIDEO_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(VIDEO_GET_FAIL + ":" + _videoId + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(VIDEO_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._videoLoader.addVideoLoaderListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				(event.target as URLLoader).close();
				trace(VIDEO_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(VIDEO_GET_FAIL + ":" + _videoId + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(VIDEO_GET_FAIL, false, false, event.text));
				close(true, true, event);
			});
			this._videoLoader.addVideoLoaderListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				trace(event);
				LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			});
			
			if(!this._isVideoNotDownload){
				var beforeBytes:Number = 0;
				this._videoLoader.addVideoLoaderListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void{
					//イベントを乱発すると性能が落ちるので間引き
					if(event.bytesLoaded - beforeBytes > 1000000 || beforeBytes == 0){
						trace(VIDEO_DOWNLOAD_PROGRESS + ":" + event.bytesLoaded + "/" + event.bytesTotal + " bytes");
						dispatchEvent(new ProgressEvent(VIDEO_DOWNLOAD_PROGRESS, false, false, event.bytesLoaded, event.bytesTotal));
						beforeBytes = event.bytesLoaded;
					}
				});
				this._videoLoader.addVideoLoaderListener(Event.COMPLETE, videoGetSuccess);
			}else{
				//ストリーミング再生用
				this._videoLoader.addEventListener(VideoLoader.VIDEO_URL_GET_SUCCESS, function(event:Event):void{
					
					trace(VideoLoader.VIDEO_URL_GET_SUCCESS + ":" + event);
					_streamingUrl = (event.target as VideoLoader).videoUrl;
					
					var extension:String = "";
					if((event.target as VideoLoader).videoType == VideoType.VIDEO_TYPE_FLV){
						extension = ".flv";
					}else if((event.target as VideoLoader).videoType == VideoType.VIDEO_TYPE_MP4){
						extension = ".mp4";
					}else if((event.target as VideoLoader).videoType == VideoType.VIDEO_TYPE_SWF){
						extension = ".swf";
					}else{
						dispatchEvent(new IOErrorEvent(DOWNLOAD_PROCESS_ERROR, false, false, _streamingUrl));
						close(true, true, new IOErrorEvent(DOWNLOAD_PROCESS_ERROR, false, false, _streamingUrl));
						return;
					}
					
					_nicoVideoName = _nicoVideoName + extension;
					
					dispatchEvent(new Event(DOWNLOAD_PROCESS_COMPLETE));
					close(false, false);
				});
			}
			this._videoLoader.getVideo(this._isVideoNotDownload, this._getflvAccess);
		}
		
		/**
		 * 動画のダウンロードが完了したら呼ばれます。<br>
		 * 動画の保存終了後、requestDownloadの全行程終了イベントを発行します。
		 * 
		 * @param event
		 * 
		 */
		private function videoGetSuccess(event:Event):void{
			
			var fileIO:FileIO = new FileIO();
			fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				trace(VIDEO_GET_FAIL + ":" + event + ":" + event.target +  ":" + event.text);
				LogManager.instance.addLog(VIDEO_GET_FAIL + ":" + _videoId + ":" + event + ":" + event.target +  ":" + event.text);
				dispatchEvent(new IOErrorEvent(VIDEO_GET_FAIL, false, false, event.text));
				close(true, true);
			});
			var extension:String = "";
			if(this._videoLoader.videoType == VideoType.VIDEO_TYPE_FLV){
				extension = ".flv";
			}else if(this._videoLoader.videoType == VideoType.VIDEO_TYPE_MP4){
				extension = ".mp4";
			}else if(this._videoLoader.videoType == VideoType.VIDEO_TYPE_SWF){
				extension = ".swf";
			}else{
				dispatchEvent(new IOErrorEvent(VIDEO_GET_FAIL, false, false, "UnkwownVideoType"));
				close(true, true);
				return;
			}
			//HTML特殊文字置き換え済動画名
			this._saveVideoName = HtmlUtil.convertSpecialCharacterNotIncludedString(this._saveVideoName) + extension;
			this._nicoVideoName = this._nicoVideoName + extension;
			
			//ファイルの大きさチェック（小さすぎたらそれは何らかの障害で取得できていない）
			trace((event.target as URLLoader).bytesTotal + "bytes");
			if((event.target as URLLoader).bytesTotal < 1000){
				var myEvent:ErrorEvent = new IOErrorEvent(VIDEO_GET_FAIL, false, false, "DownloadFail");
				dispatchEvent(myEvent);
				close(true, true, myEvent);
				return;
			}
			
			//禁則文字置き換え済動画Path
			try{
				var file:File = fileIO.saveVideoByURLLoader((event.target as URLLoader), this._saveVideoName , this._saveDir.url);
				this._savedVideoPath = decodeURIComponent(file.url);
			}catch(error:Error){
				var myEvent:ErrorEvent = new IOErrorEvent(NNDDDownloader.VIDEO_GET_FAIL, false, false, error.toString()); 
				dispatchEvent(myEvent);
				close(true, true, myEvent);
				
				return;
			}
			//動画取得成功
			(event.target as URLLoader).close();
			this._videoLoader.close();
			LogManager.instance.addLog("\t" + VIDEO_GET_SUCCESS + ":" + file.nativePath);
			trace(VIDEO_GET_SUCCESS + ":" + event + "\n" + file.nativePath);
			dispatchEvent(new Event(VIDEO_GET_SUCCESS));
			
			//全行程終了
			trace(DOWNLOAD_PROCESS_COMPLETE + ":" + event);
			dispatchEvent(new Event(DOWNLOAD_PROCESS_COMPLETE));
			
			close(false, false);
		}
		
		/**
		 * 保存済動画のパスを返します。
		 * @return 
		 * 
		 */
		public function get savedVideoPath():File{
			if(this._savedVideoPath != null && this._savedVideoPath != ""){
				return new File(this._savedVideoPath);
			}else{
				
				var file:File = null;
				try{
					var path:String = this._saveDir.url;
					if(path.charAt(path.length) != "/"){
						path += "/";
					}
					file = new File(path + this._saveVideoName);
				}catch(error:Error){
					
				}
				
				return file;
			}
		}
		
		/**
		 * 保存済動画の名前を返します。
		 * @return 
		 * 
		 */
		public function get saveVideoName():String{
			return this._saveVideoName;
		}
		
		/**
		 * エコノミーモードかどうかを返します。
		 * @return 
		 * 
		 */
		public function get isEconomyMode():Boolean{
			if(this._videoLoader.economyMode || this._commentLoader.economyMode){
				return true;
			}
			return false;
		}
		
		/**
		 * ストリーミング再生の際にストリーミング先URLを返します。
		 * @return 
		 * 
		 */
		public function get streamingUrl():String{
			return this._streamingUrl;
		}
		
		/**
		 * ダウンロード済動画を表すNNDDVideoオブジェクトを返します。
		 * 動画のタイトル、URL、エコノミーモードか否かの情報を含みますが、タグ情報等は含みません。
		 * 
		 * @return 
		 * 
		 */
		public function get downloadedVideo():NNDDVideo{
			var video:NNDDVideo = new NNDDVideo(this.savedVideoPath.url, null, isEconomyMode);
			return video;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get localThumbUri():String{
			return this._thumbPath;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get nicoVideoName():String{
			return this._nicoVideoName
		}
		
		/**
		 * 
		 * 
		 */
		private function terminate():void{
			this._login = null;
			this._watchVideo = null;
			this._getflvAccess = null;
			this._commentLoader = null;
			this._ownerCommentLoader = null;
			this._nicowariLoader = null;
			this._getbgmAccess = null;
			this._thumbInfoLoader = null;
			this._thumbImgLoader = null;
			this._ichibaInfoLoader = null;
			this._videoLoader = null;
		}
		
		/**
		 * Loaderをすべて閉じます。
		 * 
		 * @param isCancel trueにするとDOWNLOAD_PROCESS_CANCELDを発行します
		 * @param isError trueにするとDOWNLOAD_PROCESS_ERRORを発行します
		 * @param event isCancel=true、isError=trueの時にErrorEventを設定すると、ErrorEvent.textのテキストを含むDOWNLOAD_PROCESS_ERRORを発行します。
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
				this._watchVideo.close();
				trace(this._watchVideo + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._getflvAccess.close();
				trace(this._getflvAccess + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._commentLoader.close();
				trace(this._commentLoader + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._ownerCommentLoader.close();
				trace(this._ownerCommentLoader + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._getbgmAccess.close();
				trace(this._getbgmAccess + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._nicowariLoader.close();
				trace(this._nicowariLoader + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._thumbInfoLoader.close();
				trace(this._thumbInfoLoader + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._thumbImgLoader.close();
				trace(this._thumbImgLoader + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._ichibaInfoLoader.close();
				trace(this._ichibaInfoLoader + " is closed.");
			}catch(error:Error){
//				trace(error.getStackTrace());
			}
			try{
				this._videoLoader.close();
				trace(this._videoLoader + " is closed.");
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
		
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get messageServerURL():String{
			if(this._commentLoader != null){
				return this._commentLoader.messageServerUrl;
			}
			return null;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get videoUrl():String{
			if(this._videoLoader != null){
				return this._videoLoader.videoUrl;
			}
			return null;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get videoType():VideoType{
			if(this._videoLoader != null){
				return this._videoLoader.videoType;
			}
			return null;
		}
		
		/**
		 * getFlv APIの取得結果が存在する場合は、それを返します。
		 * @return 
		 * 
		 */
		public function get getFlvResultAnalyzer():GetFlvResultAnalyzer{
			return this._flvResultAnalyzer;
		}

	}
}