package org.mineap.nndd.library.sqlite
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.Message;
	import org.mineap.nndd.event.LibraryLoadEvent;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryDirSearchUtil;
	import org.mineap.nndd.library.LocalVideoInfoLoader;
	import org.mineap.nndd.library.namedarray.NamedArrayLibraryManager;
	import org.mineap.nndd.library.sqlite.dao.NNDDVideoDao;
	import org.mineap.nndd.library.sqlite.dao.TagStringDao;
	import org.mineap.nndd.library.sqlite.dao.VersionDao;
	import org.mineap.nndd.library.sqlite.util.DbMigrationUtil;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.model.TagString;
	import org.mineap.nndd.tag.TagManager;
	import org.mineap.nndd.util.LibraryUtil;
	
	/**
	 * SQLite版ライブラリとのコネクションを管理するクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class SQLiteLibraryManager extends EventDispatcher implements ILibraryManager
	{
		
		private static const sqliteLibraryManager:SQLiteLibraryManager = new SQLiteLibraryManager();
		
		private var _logger:LogManager;
		private var _tagManager:TagManager;
		private var _dbAccessHelper:DbAccessHelper;
		private var _libraryDir:File;
		
		private var _converting:Boolean = false;
		
		private var _tempLibraryMap:Object;
		
		private var _allDirRenew:Boolean = false;
		private var _renewingDir:File = null;
		private var _totalVideoCount:Number = 0;
		private var _videoCount:Number = 0;
		
		private var _useAppDirLibFile:Boolean = true;
		
		public static const LIBRARY_FILE_NAME:String = "library.db";
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():SQLiteLibraryManager{
			return sqliteLibraryManager;
		}
		
		/**
		 * 
		 * @param target
		 * 
		 */
		public function SQLiteLibraryManager(target:IEventDispatcher=null)
		{
			super(target);
			if(sqliteLibraryManager != null){
				throw new ArgumentError("SQLiteLibraryManagerはインスタンス化できません。");
			}
			
			this._logger = LogManager.instance;
			this._tagManager = TagManager.instance;
			this._libraryDir = this.defaultLibraryDir;
			this._dbAccessHelper = DbAccessHelper.instance;
		}
		
		/**
		 * ライブラリファイルの場所を返します。
		 * @return 
		 * 
		 */
		public function get libraryFile():File{
			if(_useAppDirLibFile){
				return File.applicationStorageDirectory.resolvePath(SQLiteLibraryManager.LIBRARY_FILE_NAME);
			}else{
				return this.systemFileDir.resolvePath(SQLiteLibraryManager.LIBRARY_FILE_NAME);
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get libraryDir():File
		{
			return new File(this._libraryDir.url);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get defaultLibraryDir():File
		{
			return new File(File.documentsDirectory.resolvePath("NNDD/").url);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get systemFileDir():File
		{
			return new File(libraryDir.resolvePath("system/").url);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get tempDir():File
		{
			return new File(systemFileDir.resolvePath("temp/").url);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get playListDir():File
		{
			return new File(systemFileDir.resolvePath("playList/").url);
		}
		
		/**
		 * 
		 * @param value
		 * 
		 */
		public function set useAppDirLibFile(value:Boolean):void
		{
			this._useAppDirLibFile = value;
		}
		
		/**
		 * ライブラリディレクトリを変更します
		 * @param libraryDir
		 * @param isSave
		 * @return 
		 * 
		 */
		public function changeLibraryDir(libraryDir:File, isSave:Boolean=true):Boolean
		{
			if(libraryDir.isDirectory){
				disconnect();
				this._libraryDir = libraryDir;
				return loadLibrary();
			}else{
				return false;
			}
		}
		
		/**
		 * ライブラリを保存します。<br />
		 * SQLiteLibraryManagerの実装では、このメソッドを実行しても何もしません。
		 * 常にtrueが返されます。
		 * @param saveDir
		 * @return 
		 * 
		 */
		public function saveLibrary(saveDir:File=null):Boolean
		{
			return true;
		}
		
		/**
		 * ライブラリをロードします。<br />
		 * SQLiteLibraryManagerの実装では、このメソッドはDBへのコネクションの確立を行います。
		 * @param libraryDir
		 * @return 
		 * 
		 */
		public function loadLibrary(libraryDir:File=null):Boolean
		{
			if(libraryDir != null){
				changeLibraryDir(libraryDir);
			}
			return connect();
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		private function connect():Boolean{
			
			disconnect();
			
			var isConvertFromXML:Boolean = false;
			if(!this.libraryFile.exists){
				//SQLiteライブラリが存在しないので、
				//新規SQLiteライブラリを作る
				
				//古い形式のライブラリファイルはあるか？
				var oldLibraryFile:File = this.systemFileDir.resolvePath("library.xml");
				if(oldLibraryFile != null && oldLibraryFile.exists){
					// ある。古いXMLから変換
					isConvertFromXML = true;
				}else{
					// ない。SQL版ライブラリを新規作成
					isConvertFromXML = false;
				}
				
			}
			
			var result:Boolean = this._dbAccessHelper.connect(this.libraryFile);
			
			trace("コネクションを確立:" + result);
			_logger.addLog("データベースへコネクションを確立(" + this.libraryFile.nativePath + "):" + result);
			
			var oldVersion:String = VersionDao.instance.selectVersion();
			var newVersion:String = DbAccessHelper.version;
			
			var isConvertFromDB:Boolean = false;
			if(oldVersion != newVersion){
				//テーブル構造が変わっているのでDBを再構築(SQLite版DBファイルが無い場合もtrueが入る)
				isConvertFromDB = true;
			}
			
			if(isConvertFromXML || isConvertFromDB){
				if(!_converting){
					_converting = true;
					
					var message:String = "ライブラリを再構築します。";
					var createNewLibrary:Boolean = false;
					if(isConvertFromDB && !isConvertFromXML){
						// SQLite版ライブラリが無くて、XML版ライブラリも無い場合
						message = "ライブラリ用のデータベースを作成します。";
						createNewLibrary = true;
					}
					
					Alert.show(message, Message.M_MESSAGE, Alert.OK, null, function(event:CloseEvent):void{
						
						var loadWindow:LoadWindow = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, LoadWindow, true) as LoadWindow;
						if(createNewLibrary){
							loadWindow.label_loadingInfo.text = "データベースを作成中";
							loadWindow.progressBar_loading.label = "作成中...";
						}else{
							loadWindow.label_loadingInfo.text = "ライブラリを再構築中";
							loadWindow.progressBar_loading.label = "再構築中...";
						}
						PopUpManager.centerPopUp(loadWindow);
						
						var timer:Timer = new Timer(1000, 1);
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
							if(isConvertFromXML){
								convertFromXML();
							}else if(isConvertFromDB){
								convertFromDB(createNewLibrary);
							}
							_converting = false;
							
							dispatchEvent(new LibraryLoadEvent(LibraryLoadEvent.LIBRARY_LOAD_COMPLETE, false, false, 0, 0));
							
							PopUpManager.removePopUp(loadWindow);
							
						});
						timer.start();
					});
				}
			}
			return result;
		}
		
		/**
		 * 
		 * 
		 */
		private function disconnect():void{
			this._dbAccessHelper.disconnect();
			
			trace("コネクションを切断");
			_logger.addLog("データベースとのコネクションを切断(" + this.libraryFile.nativePath + ")");
		}
		
		/**
		 * 
		 * 
		 */
		private function convertFromXML():void{
			_logger.addLog("library.xmlをlibrary.dbに変換中...");
			trace("変換開始");
			
			try{
				
				_logger.addLog("データベースのテーブルを作成");
				_dbAccessHelper.dropTables();
				_dbAccessHelper.createTables();
				
				var libraryManager:NamedArrayLibraryManager = NamedArrayLibraryManager.instance;
				libraryManager.useAppDirLibFile = this._useAppDirLibFile;
				libraryManager.changeLibraryDir(this.libraryDir, false);
				_logger.addLog("読み込み先XML:" + libraryManager.libraryFile.nativePath);
				if(!libraryManager.loadLibrary()){
					_logger.addLog("読み込み先XMLが存在しないため中断");
					throw new Error("読み込み先XMLが存在しないため中断");
				}
				var vector:Vector.<NNDDVideo> = libraryManager.getNNDDVideoArray(this._libraryDir, true);
				trace(vector.length);
				_logger.addLog("変換対象動画数:" + vector.length);
				
				var date:Date = new Date();
				
				for each(var nnddVideo:NNDDVideo in vector){
					add(nnddVideo, false, false);
				}
				
				var time:Number = (new Date().time - date.time);
				trace(time + " ms, " + (time/vector.length) + " ms/video.");
				
				_logger.addLog("変換完了(" + time + " ms)");
				
				updateVersion();
				
				Alert.show("再構築が完了しました。", Message.M_MESSAGE);
				
			}catch(error:Error){
				trace(error.getStackTrace());
				_logger.addLog("ライブラリの変換に失敗:" + error);
				Alert.show("ライブラリの変換に失敗しました。\n" +
					"手動でライブラリを更新してください。\n" +
					"(設定>全般>ライブラリを更新)\n\n" + error, Message.M_ERROR);
			}
			
		}
		
		/**
		 * 
		 * 
		 */
		public function convertFromDB(createNew:Boolean):void{
			_logger.addLog("データベースをバージョンアップしています...");
			trace("変換開始");
			
			try{
				
				var date:Date = new Date();
				
				var migration:DbMigrationUtil = new DbMigrationUtil();
				migration.migrate();
				
				var time:Number = (new Date().time - date.time);
				
				_logger.addLog("変換完了(" + time + " ms)");
				
				updateVersion();
				
				if(createNew){
					Alert.show("データベースの作成が完了しました。", Message.M_MESSAGE);
				}else{
					Alert.show("再構築が完了しました。", Message.M_MESSAGE);
				}
			}catch(error:Error){
				trace(error.getStackTrace());
				_logger.addLog("ライブラリの変換に失敗:" + error);
				Alert.show("ライブラリの変換に失敗しました。\n" +
					"手動でライブラリを更新してください。" + error, Message.M_ERROR);
			}
		}
		
		/**
		 * 
		 * @param libraryDir
		 * @param renewSubDir
		 * 
		 */
		public function renewLibrary(libraryDir:File, renewSubDir:Boolean):void
		{
			
			this._allDirRenew = false;
			this._renewingDir = null;
			this._totalVideoCount = 0;
			this._videoCount = 0;
			
			var videoList:Array = new LibraryDirSearchUtil().renewDir(libraryDir, renewSubDir);
			
			this._tempLibraryMap = new Object();
			
			this._totalVideoCount = videoList.length;
			
			trace(_totalVideoCount);
			
			this._logger.addLog("更新対象動画数:" + this._totalVideoCount);
			
			//トップレベルディレクトリの探索およびサブディレクトリを含む探索
			if(libraryDir.url == this.libraryDir.url && renewSubDir ){
				this._allDirRenew = true;
			}
			
			videoList.forEach(infoLoadFunction);
			
			if(videoList.length == 0){
				updateVersion();
				dispatchEvent(new LibraryLoadEvent(LibraryLoadEvent.LIBRARY_LOAD_COMPLETE, false, false, _totalVideoCount, _videoCount));
			}
			
		}
		
		
		/**
		 * 動画一覧生成済みのArrayから呼ばれるコールバック関数です。
		 * 
		 * @param item コールバックもと配列の当該インデックスの要素
		 * @param index コールバック元の配列のインデックス
		 * @param array コールバック元の配列
		 * 
		 */
		private function infoLoadFunction(item:*, index:int, array:Array):void
		{
			var file:File = null;
			var fileName:String = "不明";
			
			try{
				
				_videoCount++;
				
				if(item is String){
					file = new File(item);
					fileName = file.nativePath;
					if(_renewingDir != null && _renewingDir.nativePath != file.parent.nativePath){
						_logger.addLog("次のディレクトリの情報を収集中:" + file.parent.nativePath);
					}
					_renewingDir = file.parent;
				}else{
					trace(item);
					return;
				}
				
				
				var loader:LocalVideoInfoLoader = new LocalVideoInfoLoader();
				var nnddVideo:NNDDVideo = loader.loadInfo(file.url);
				
				var key:String = nnddVideo.key;
				
				_tempLibraryMap[key] = nnddVideo;
				
				if(index%10 == 0){
					dispatchEvent(new LibraryLoadEvent(LibraryLoadEvent.LIBRARY_LOADING, false, false, _totalVideoCount, _videoCount, file));
					trace(_videoCount + "(" + index + "):" + file.nativePath);
				}
				
				if(_videoCount >= _totalVideoCount){
					var tempKey:Object = null;
					// ライブラリに今回見つかった物を追加
					for(tempKey in _tempLibraryMap){
						var nnddVideo:NNDDVideo = _tempLibraryMap[tempKey];
						
						var tempVideo:NNDDVideo = isExistByVideoId(nnddVideo.key);
						if(tempVideo == null){
							add(nnddVideo, false, true);
						}else{
							nnddVideo.id = tempVideo.id;
							update(nnddVideo, false);
						}
					}
					
					if(_allDirRenew){
						//全ディレクトリ探索の場合は単純に削除判定が出来る
						tempKey = null;
						_logger.addLog("見つからなかった動画をライブラリから除去中...");
						
						var vector:Vector.<NNDDVideo> = NNDDVideoDao.instance.selectAllNNDDVideo();
						
						for each(var nnddVideo:NNDDVideo in vector){
							var tempVideo:NNDDVideo = _tempLibraryMap[nnddVideo.key];
							if(tempVideo == null){
								_logger.addLog("見つからなかった動画:" + tempKey);
								trace("見つからなかった動画:" + tempKey);
								NNDDVideoDao.instance.deleteNNDDVideoById(nnddVideo.id);
							}
						}
					}else{
						// 今回探索したフォルダについて、無くなったファイルを取り除く
						_logger.addLog("見つからなかった動画をライブラリから除去中...");
						
						// 今回探索したフォルダの一覧を作る
						var folders:Object = new Object();
						for(tempKey in _tempLibraryMap){
							var tempVideo:NNDDVideo = _tempLibraryMap[tempKey];
							folders[tempVideo.dir.url] = tempVideo.dir;
						}
						
						// 探索したフォルダの一覧から今回探したフォルダから無くなった物を探す
						for each(var file:File in folders){
							var vector:Vector.<NNDDVideo> = getNNDDVideoArray(file, false);
							
							// ディレクトリについて無くなった物を探索
							for each(var video:NNDDVideo in vector){
								var videoKey:String = LibraryUtil.getVideoKey(video.getDecodeUrl());
								
								// この動画は今回見つかったか？
								var object:Object = _tempLibraryMap[videoKey];
								if(object == null){
									// 見つからなかったので削除
									_logger.addLog("見つからなかった動画:" + videoKey);
									trace("見つからなかった動画:" + videoKey);
									NNDDVideoDao.instance.deleteNNDDVideoById(video.id);
								}
							}
						}
					}
					
					_tempLibraryMap = null;
					
					this._tagManager.loadTag();
					
					updateVersion();
					
					dispatchEvent(new LibraryLoadEvent(LibraryLoadEvent.LIBRARY_LOAD_COMPLETE, false, false, _totalVideoCount, _videoCount));
				}
				
			}catch(error:Error){
				trace(error.getStackTrace());
				_logger.addLog("ファイルの読み込みに失敗:" + error + ":"+ fileName +":" + error.getStackTrace());
				
				if(_videoCount >= _totalVideoCount){
					for(var value:Object in _tempLibraryMap){
						add(_tempLibraryMap[value], false, true);
					}
					_tempLibraryMap = null;
					
					this._tagManager.loadTag();
					
					updateVersion();
					
					dispatchEvent(new LibraryLoadEvent(LibraryLoadEvent.LIBRARY_LOAD_COMPLETE, false, false, _totalVideoCount, _videoCount))
				}
			}
			
		}
		
		/**
		 * 
		 * 
		 */
		private function updateVersion():void{
			var newVersion:String = DbAccessHelper.version;
			var oldVersion:String = VersionDao.instance.selectVersion();
			
			if(oldVersion == null){
				VersionDao.instance.insertVersion(newVersion);
			}else{
				VersionDao.instance.updateVersion(newVersion);
			}
		}
		
		/**
		 * 
		 * @param videoId
		 * @param isSaveLibrary SQLite版のLibrary実装ではこの引数に意味はありません。
		 * @return 
		 * 
		 */
		public function remove(videoId:String, isSaveLibrary:Boolean):NNDDVideo
		{
			var nnddVideo:NNDDVideo = NNDDVideoDao.instance.selectNNDDVideoByKey(videoId);
			if(nnddVideo == null){
				return null;
			}
			var result:Boolean = NNDDVideoDao.instance.deleteNNDDVideoById(nnddVideo.id);
			return nnddVideo;
		}
		
		/**
		 * 
		 * @param video
		 * @param isSaveLibrary SQLite版のLibrary実装ではこの引数に意味はありません。
		 * @return 
		 * 
		 */
		public function update(video:NNDDVideo, isSaveLibrary:Boolean):Boolean
		{
			if(video.id == -1){
				var tempVideo:NNDDVideo = NNDDVideoDao.instance.selectNNDDVideoByKey(video.key);
				if(tempVideo == null){
					return false;
				}else{
					video.id = tempVideo.id;
				}
			}
			return NNDDVideoDao.instance.updateNNDDVideo(video);
		}
		
		/**
		 * 
		 * @param video
		 * @param isSaveLibrary SQLite版のLibrary実装ではこの引数に意味はありません。
		 * @param isOverWrite
		 * @return 
		 * 
		 */
		public function add(video:NNDDVideo, isSaveLibrary:Boolean, isOverWrite:Boolean=false):Boolean
		{
			var result:Boolean = NNDDVideoDao.instance.insertNNDDVideo(video);
			if(!result && isOverWrite){
				result = update(video, false);
			}
			return result;
		}
		
		/**
		 * 
		 * @param oldDir
		 * @param newDir
		 * 
		 */
		public function changeDirName(oldDir:File, newDir:File):void
		{
			var oldPattern:RegExp = new RegExp(decodeURIComponent(oldDir.url));
			var isFailed:Boolean = false;
			
			var videos:Vector.<NNDDVideo> = getNNDDVideoArray(oldDir, true);
			
			var oldUrl:String = decodeURIComponent(oldDir.url);
			var newUrl:String = decodeURIComponent(newDir.url);
			
			for each(var video:NNDDVideo in videos){
				if(video != null && video.getDecodeUrl().indexOf(oldUrl) != -1){
					var url:String = video.getDecodeUrl().replace(oldUrl, newUrl);
					
					var thumbUrl:String = video.thumbUrl;
					if(thumbUrl.indexOf("http") != -1){
						video.thumbUrl = thumbUrl.replace(oldPattern, newUrl);
					}else{
						//そのまま
					}
					
					var newVideo:NNDDVideo = new NNDDVideo(encodeURI(url), video.videoName, video.isEconomy, video.tagStrings, video.modificationDate, video.creationDate, video.thumbUrl, video.playCount);
					add(newVideo, false, true);
				}
			}
			
			_logger.addLog("ライブラリを更新:" + newDir.nativePath);
		}
		
		/**
		 * 
		 * @param videoId
		 * @return 
		 * 
		 */
		public function isExistByVideoId(videoId:String):NNDDVideo
		{
			return NNDDVideoDao.instance.selectNNDDVideoByKey(videoId);
		}
		
		/**
		 * 
		 * @param key
		 * @return 
		 * 
		 */
		public function isExist(key:String):NNDDVideo
		{
			return isExistByVideoId(key);
		}
		
		/**
		 * 
		 * @param dir
		 * @return 
		 * 
		 */
		public function collectTag(dir:File=null):Array
		{
			var array:Array = new Array();
			var map:Object = new Object();
			
			var vector:Vector.<NNDDVideo> = getNNDDVideoArray(dir, false);
			
			var date:Date = new Date();
			
			try{
				DbAccessHelper.instance.connection.begin();
				
				for each(var video:NNDDVideo in vector){
					
					var tagStrings:Vector.<TagString> = TagStringDao.instance.selectTagStringRelatedByVideo(video.id);
					
					for each(var tag:TagString in tagStrings){
						if(map[tag.tag] == null){
							array.push(tag.tag);
							map[tag.tag] = tag.tag;
						}
					}
				}
				
				DbAccessHelper.instance.connection.commit();
			}catch(error:Error){
				trace(error.getStackTrace());
				DbAccessHelper.instance.connection.rollback();
			}
			
			trace("動画に関連するタグを抽出:" + (new Date().time - date.time) + " ms");
			
			return array;
		}
		
		/**
		 * 
		 * @param nameArray
		 * @return 
		 * 
		 */
		public function collectTagByVideoName(nameArray:Array):Array
		{
			var tagArray:Array = new Array();
			var tagMap:Object = new Object();
			
			for each(var videoName:String in nameArray){
				var key:String = LibraryUtil.getVideoKey(videoName);
				if(key != null){
					var video:NNDDVideo = isExist(key);
					if(video != null){
						for each(var tag:String in video.tagStrings){
							if(tagMap[tag] == null){
								tagArray.push(tag);
								tagMap[tag] = tag;
							}
						}
					}
				}
			}
			
			return tagArray;
		}
		
		/**
		 * 
		 * @param word
		 * @return 
		 * 
		 */
		public function searchTagAndShow(word:String):Array
		{
			//wordをスペースで分割
			var pattern:RegExp = new RegExp("\\s*([^\\s]*)", "ig");
			var array:Array = word.match(pattern);
			
			return this._tagManager.searchTagByWords(array);
		}
		
		/**
		 * 
		 * @param saveDir
		 * @param isShowAll
		 * @return 
		 * 
		 */
		public function getNNDDVideoArray(saveDir:File, isShowAll:Boolean):Vector.<NNDDVideo>
		{
			
			var date:Date = new Date();
			
			if(saveDir == null){
				saveDir = libraryDir;
			}
			
			var vector:Vector.<NNDDVideo> = NNDDVideoDao.instance.selectNNDDVideoByFile(saveDir, true, false, isShowAll);
			
			var count:int = 0;
			if(vector != null){
				count = vector.length;
			}else{
				vector = new Vector.<NNDDVideo>();
			}
			
			trace("動画を抽出:" + (new Date().time - date.time) + " ms, " + count + "件");
			
			return vector;
		}
	}
}