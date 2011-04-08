package org.mineap.nndd
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class RenewDownloadManager extends EventDispatcher
	{
		
		public static const PROCCESS_COMPLETE:String = "ProcessComplate";
		public static const PROCCESS_FAIL:String = "ProcessFail";
		public static const PROCCESS_CANCEL:String = "ProcessCancel";
		
		private var _dataProvider:ArrayCollection;
		private var _nnddDownloader:NNDDDownloader;
		private var _logManager:LogManager;
		private var _videoName:String;
		private var _localThumbUri:String;
		
		/**
		 * 
		 * @param dataProvider
		 * @param logManager
		 * 
		 */
		public function RenewDownloadManager(dataProvider:ArrayCollection, logManager:LogManager)
		{
			this._logManager = logManager;	
			this._dataProvider = dataProvider;
			this._nnddDownloader = new NNDDDownloader();
			
		}
		
		/**
		 * 
		 * @param user
		 * @param password
		 * @param videoId
		 * @param videoName
		 * @param saveDir
		 * @param isAppendComment
		 * @param when
		 * @param commentMaxCount
		 */
		public function renewForCommentOnly(user:String, 
											password:String, 
											videoId:String, 
											videoName:String, 
											saveDir:File, 
											isAppendComment:Boolean, 
											when:Date, 
											commentMaxCount:Number):void{
			//失敗系ハンドラ登録
			this._nnddDownloader.addEventListener(NNDDDownloader.COMMENT_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.GETFLV_API_ACCESS_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.ICHIBA_INFO_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.LOGIN_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.NICOWARI_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.OWNER_COMMENT_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_IMG_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_INFO_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.VIDEO_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.WATCH_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.GETWAYBACKKEY_API_ACCESS_FAIL, getFailListener, false, 0, true);
			
			//成功系ハンドラ登録
			this._nnddDownloader.addEventListener(NNDDDownloader.COMMENT_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.GETFLV_API_ACCESS_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.ICHIBA_INFO_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.LOGIN_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.NICOWARI_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.OWNER_COMMENT_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_IMG_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_INFO_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.VIDEO_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.WATCH_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.GETWAYBACKKEY_API_ACCESS_SUCCESS, getSuccessListener, false, 0, true);
			
			//完了系ハンドラ登録
			this._nnddDownloader.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_CANCELD, downlaodFailListener);
			this._nnddDownloader.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_ERROR, downlaodFailListener);
			this._nnddDownloader.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_COMPLETE, downloadCompleteListener);
			
			this._videoName = videoName;
			this._nnddDownloader.requestDownloadForCommentOnly(user, password, videoId, videoName, saveDir, false, isAppendComment, when, commentMaxCount);
		}
		
		/**
		 * 
		 * @param user
		 * @param password
		 * @param videoId
		 * @param videoName
		 * @param saveDir
		 * @param isAppendComment
		 * @param when
		 * @param commentMaxCount
		 * 
		 */
		public function renewForOtherVideo(user:String, 
										   password:String, 
										   videoId:String, 
										   videoName:String, 
										   saveDir:File, 
										   isAppendComment:Boolean, 
										   when:Date, 
										   commentMaxCount:Number):void{
			//失敗系ハンドラ登録
			this._nnddDownloader.addEventListener(NNDDDownloader.COMMENT_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.GETFLV_API_ACCESS_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.ICHIBA_INFO_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.LOGIN_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.NICOWARI_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.OWNER_COMMENT_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_IMG_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_INFO_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.VIDEO_GET_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.WATCH_FAIL, getFailListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.GETWAYBACKKEY_API_ACCESS_FAIL, getFailListener, false, 0, true);
			
			//成功系ハンドラ登録
			this._nnddDownloader.addEventListener(NNDDDownloader.COMMENT_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.GETFLV_API_ACCESS_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.ICHIBA_INFO_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.LOGIN_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.NICOWARI_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.OWNER_COMMENT_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_IMG_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.THUMB_INFO_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.VIDEO_GET_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.WATCH_SUCCESS, getSuccessListener, false, 0, true);
			this._nnddDownloader.addEventListener(NNDDDownloader.GETWAYBACKKEY_API_ACCESS_SUCCESS, getSuccessListener, false, 0, true);
			
			//完了系ハンドラ登録
			this._nnddDownloader.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_CANCELD, downlaodFailListener);
			this._nnddDownloader.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_ERROR, downlaodFailListener);
			this._nnddDownloader.addEventListener(NNDDDownloader.DOWNLOAD_PROCESS_COMPLETE, downloadCompleteListener);
			
			this._videoName = videoName;
			this._nnddDownloader.requestDownloadForOtherVideo(user, password, videoId, videoName, saveDir, false, isAppendComment, when, commentMaxCount);
		}
		
		/**
		 * 取得失敗系リスナー
		 * @param event
		 * 
		 */
		public function getFailListener(event:IOErrorEvent):void{
			var status:String = "";
			if(event.type == NNDDDownloader.LOGIN_FAIL){
				status = "ログイン失敗";
			}else if(event.type == NNDDDownloader.WATCH_FAIL){
				status = "動画ページアクセス失敗";
			}else if(event.type == NNDDDownloader.GETFLV_API_ACCESS_FAIL){
				status = "getflvAPIアクセス失敗";
			}else if(event.type == NNDDDownloader.COMMENT_GET_FAIL){
				status = "コメント取得失敗";
			}else if(event.type == NNDDDownloader.OWNER_COMMENT_GET_FAIL){
				status = "投稿者コメント取得失敗";
			}else if(event.type == NNDDDownloader.NICOWARI_GET_FAIL){
				status = "ニコ割取得失敗";
			}else if(event.type == NNDDDownloader.THUMB_INFO_GET_FAIL){
				status = "サムネイル情報取得失敗";
			}else if(event.type == NNDDDownloader.THUMB_IMG_GET_FAIL){
				status = "サムネイル画像取得失敗";
			}else if(event.type == NNDDDownloader.ICHIBA_INFO_GET_FAIL){
				status = "市場情報取得失敗";
			}else if(event.type == NNDDDownloader.VIDEO_GET_FAIL){
				status = "動画取得失敗";
			}else if(event.type == NNDDDownloader.GETWAYBACKKEY_API_ACCESS_FAIL){
				status = "getwaybackkeyAPIアクセス失敗"
			}
			
			this._logManager.addLog(status + ":" + event.type + ":" + event.text);
			setStatus(status, this._videoName);
			
			dispatchEvent(event);
		}
		
		/**
		 * 取得成功系リスナー
		 * @param event
		 * 
		 */
		public function getSuccessListener(event:Event):void{
			var status:String = "";
			var statusInt:int = 0;
			if(event.type == NNDDDownloader.LOGIN_SUCCESS){
				status = "ログイン成功";
			}else if(event.type == NNDDDownloader.WATCH_SUCCESS){
				status = "動画ページアクセス成功";
			}else if(event.type == NNDDDownloader.GETFLV_API_ACCESS_SUCCESS){
				status = "getflvAPIアクセス成功";
			}else if(event.type == NNDDDownloader.COMMENT_GET_SUCCESS){
				status = "コメント取得成功";
			}else if(event.type == NNDDDownloader.OWNER_COMMENT_GET_SUCCESS){
				status = "投稿者コメント取得成功";
			}else if(event.type == NNDDDownloader.NICOWARI_GET_SUCCESS){
				status = "ニコ割取得成功";
			}else if(event.type == NNDDDownloader.THUMB_INFO_GET_SUCCESS){
				status = "サムネイル情報取得成功";
			}else if(event.type == NNDDDownloader.THUMB_IMG_GET_SUCCESS){
				status = "サムネイル画像取得成功";
			}else if(event.type == NNDDDownloader.ICHIBA_INFO_GET_SUCCESS){
				status = "市場情報取得成功";
			}else if(event.type == NNDDDownloader.VIDEO_GET_SUCCESS){
				status = "動画取得成功";
			}else if(event.type == NNDDDownloader.GETWAYBACKKEY_API_ACCESS_SUCCESS){
				status = "getwaybackkeyAPIアクセス成功"
			}
			
			this._logManager.addLog(status + ":" + event.type);
			setStatus(status, this._videoName);
			
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param status
		 * @param index
		 * 
		 */
		public function setStatus(status:String, videoName:String):void{
			var index:int = -1;
			if(this._dataProvider != null){
				for(var i:int = 0; i<this._dataProvider.length; i++){
					if(this._dataProvider[i].dataGridColumn_videoName.indexOf(videoName) != -1){
						index = i;
						break;
					}
				}
			}
			
			//videoNameが一致するものを探す
			if(this._dataProvider != null){
				if(this._dataProvider.length > index && this._dataProvider[index] != undefined && this._dataProvider[index].dataGridColumn_videoName.indexOf(videoName) != -1){
					this._dataProvider.setItemAt({
						dataGridColumn_ranking: this._dataProvider[index].dataGridColumn_ranking,
						dataGridColumn_preview: this._dataProvider[index].dataGridColumn_preview,
						dataGridColumn_videoName: this._dataProvider[index].dataGridColumn_videoName,
						dataGridColumn_Info: this._dataProvider[index].dataGridColumn_Info,
						dataGridColumn_videoInfo: this._dataProvider[index].dataGridColumn_videoInfo,
						dataGridColumn_condition: status,
						dataGridColumn_count: this._dataProvider[index].dataGridColumn_count,
						dataGridColumn_videoPath: this._dataProvider[index].dataGridColumn_videoPath,
						dataGridColumn_date: this._dataProvider[index].dataGridColumn_date
					},index);
				}
			}
		}
		
		/**
		 * ダウンロード失敗リスナー
		 * @param event
		 * 
		 */
		public function downlaodFailListener(event:Event):void{
			var status:String = "";
			if(event.type == NNDDDownloader.DOWNLOAD_PROCESS_CANCELD){
				status = "キャンセル";
				this._logManager.addLog("***更新キャンセル***");
				setStatus(status, this._videoName);
				dispatchEvent(new Event(PROCCESS_CANCEL));
			}else if(event.type == NNDDDownloader.DOWNLOAD_PROCESS_ERROR){
				status = "失敗(エラー)";
				this._logManager.addLog("***更新エラー終了***");
				setStatus(status, this._videoName);
				dispatchEvent(new Event(PROCCESS_FAIL));
			}
			
		}
		
		/**
		 * ダウンロード完了リスナー
		 * @param event
		 * 
		 */
		public function downloadCompleteListener(event:Event):void{
			this._localThumbUri = (event.currentTarget as NNDDDownloader).localThumbUri;
			removeHandler();
			this._logManager.addLog("***更新完了***")
			var status:String = "更新完了";
			setStatus(status, this._videoName);
			dispatchEvent(new Event(PROCCESS_COMPLETE));
		}
		
		/**
		 * リスナを解除します。
		 * 
		 */
		public function removeHandler():void{
			this._nnddDownloader.removeEventListener(NNDDDownloader.DOWNLOAD_PROCESS_COMPLETE, downloadCompleteListener);
			this._nnddDownloader.removeEventListener(NNDDDownloader.DOWNLOAD_PROCESS_CANCELD, downlaodFailListener);
			this._nnddDownloader.removeEventListener(NNDDDownloader.DOWNLOAD_PROCESS_ERROR, downlaodFailListener);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get localThumbUri():String{
			return this._localThumbUri;
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			this._nnddDownloader.close(true, false);
		}
		
	}
}