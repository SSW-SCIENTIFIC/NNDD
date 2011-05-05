package org.mineap.nndd.library.namedarray
{
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	import mx.controls.TileList;
	
	import org.mineap.nndd.FileIO;
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.event.LibraryLoadEvent;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryDirSearchUtil;
	import org.mineap.nndd.library.LocalVideoInfoLoader;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.model.VideoType;
	import org.mineap.nndd.tag.TagManager;
	import org.mineap.nndd.util.LibraryUtil;
	
	[Event(name="libraryLoadComplete", type="LibraryLoadEvent")]
	[Event(name="libraryLoading", type="LibraryLoadEvent")]
	
	/**
	 * 
	 * 動画を管理するためのクラスです。
	 * 
	 * @author shiraminekeisuke (MineAP)
	 * 
	 */
	public class NamedArrayLibraryManager extends EventDispatcher implements ILibraryManager
	{
		
		/**
		 * ロガー
		 */
		private var _logger:LogManager;
		
		/**
		 * タグ管理
		 */
		private var _tagManager:TagManager;
		
		/**
		 * NNDDVideoとvideoIdのマッピングを行うMapオブジェクト
		 */
		private var _libraryVideoIdMap:Object = new Object();
		
		/**
		 * NNDDVideoが格納されているディレクトリとNNDDvideoオブジェクトのマッピングを行うMapオブジェクト
		 */
		private var _libraryDirMap:Object = new Object();
		
		/**
		 * ライブラリ更新時に一時的に利用するTempオブジェクトです。
		 */
		private var _tempLibraryMap:Object = null;
		
		/**
		 * LibraryManagerの唯一のインスタンス
		 */
		private static const _libraryManager:NamedArrayLibraryManager = new NamedArrayLibraryManager();
		
		/**
		 * ライブラリファイルの名前です
		 */
		public static const LIBRARY_FILE_NAME:String = "library.xml";
		
		/**
		 * NNDDのライブラリファイルの保存先ディレクトリです
		 */
		private var _libraryDir:File = null;
		
		/**
		 * 
		 */
		private var _totalVideoCount:int = 0;
		
		/**
		 * 
		 */
		private var _videoCount:int = 0;
		
		/**
		 * 
		 */
		private var _renewingDir:File = null;
		
		/**
		 * 
		 */
		private var _allDirRenew:Boolean = false;
		
		/**
		 * 
		 */
		private var _useAppDirLibFile:Boolean = true;
		
		/**
		 * 
		 * 
		 */
		public function NamedArrayLibraryManager()
		{
			if(_libraryManager != null){
				throw new ArgumentError("LibraryManagerはインスタンス化出来ません。");
			}
			
			this._libraryDir = this.defaultLibraryDir;
			this._logger = LogManager.instance;
			this._tagManager = TagManager.instance;
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():NamedArrayLibraryManager{
			return _libraryManager;
		}
		
		/**
		 * ライブラリファイルの場所を返します。
		 * @return 
		 * 
		 */
		public function get libraryFile():File{
			if(_useAppDirLibFile){
				return File.applicationStorageDirectory.resolvePath(NamedArrayLibraryManager.LIBRARY_FILE_NAME);
			}else{
				return this.systemFileDir.resolvePath(NamedArrayLibraryManager.LIBRARY_FILE_NAME);
			}
		}
		
		/**
		 * 現在のライブラリディレクトリを返します。
		 * @return 
		 * 
		 */
		public function get libraryDir():File{
			return new File(this._libraryDir.url);
		}
		
		/**
		 * NNDDのシステムディレクトリを返します。
		 * @return 
		 * 
		 */
		public function get systemFileDir():File{
			var systemDir:File = new File(libraryDir.url + "/system/");
			return systemDir;
		}
		
		/**
		 * NNDDの一時ファイル保存ディレクトリを返します。
		 * @return 
		 * 
		 */
		public function get tempDir():File{
			var tempDir:File = new File(systemFileDir.url + "/temp/");
			return tempDir;
		}
		
		/**
		 * NNDDのプレイリスト保存先ディレクトリを返します。
		 * @return 
		 * 
		 */
		public function get playListDir():File{
			var playListDir:File = new File(systemFileDir.url + "/playList/");
			return playListDir;
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
		 * ライブラリファイルの保存場所を更新します。
		 * 
		 * @param libraryDir
		 * @return 
		 */
		public function changeLibraryDir(libraryDir:File, isSave:Boolean = true):Boolean{
			if(libraryDir.isDirectory){
				this._libraryDir = libraryDir;
				if(isSave){
					this.saveLibrary();
				}
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * 指定されたディレクトリに対してライブラリファイルを保存します。
		 * 
		 * @param saveDir 保存先ディレクトリ。指定されていない場合は既定の場所に保存する。
		 * @return 
		 * 
		 */
		public function saveLibrary(saveDir:File = null):Boolean{
			
			try{
				
				if(saveDir == null){
					saveDir = this.systemFileDir;
				}
				
				if(!saveDir.exists){
					return false;
				}
				
				var xml:XML = new LibraryXMLHelper().convert(this._libraryVideoIdMap);
				
				var fileIO:FileIO = new FileIO(_logger);
				fileIO.saveXMLSync(this.libraryFile, xml);
				
				this._logger.addLog("ライブラリを保存:" + new File(saveDir.url + "/" + LIBRARY_FILE_NAME).nativePath);
				fileIO.closeFileStream();
				
				return true;
				
			}catch(error:Error){
				_logger.addLog("ライブラリの保存に失敗:" + error + ":" + error.getStackTrace());
			}
			return false;
		}
		
		/**
		 * ライブラリファイルの読み込みを行います。
		 * 
		 * @param libraryDir ライブラリ
		 * @return ライブラリファイルの読み込みに成功すればtrue、失敗すればfalse。
		 */
		public function loadLibrary(libraryDir:File = null):Boolean{
			if(libraryDir == null){
				if(this.libraryFile.exists){
					return loadLibraryFile();
				}else{
					return false;
				}
			}else{
				if(libraryDir.isDirectory){
					this._libraryDir = libraryDir;
					return loadLibraryFile();
				}else{
					return false;
				}
			}
		}
		
		/**
		 * ライブラリを読み込みます。
		 * 
		 * @return 正常に読み込みが完了したかどうか。成功していればtrueを返す。
		 * 
		 */
		private function loadLibraryFile():Boolean{
			var fileIO:FileIO = new FileIO(_logger);
			
			try{
				
				var libraryXML:XML = fileIO.loadXMLSync(this.libraryFile.url, true);
				
				if(libraryXML != null){
					
					this._libraryVideoIdMap = new LibraryXMLHelper().perseXML(libraryXML);
					
					this._libraryDirMap = convertVideoIdMapToDirMap(this._libraryVideoIdMap);
					
					this._tagManager.loadTag();
					
					return true;
				}
				
			}catch(error:Error){
				_logger.addLog("ライブラリの読み込みに失敗:" + error);
				trace(error.getStackTrace());
			}
			
			return false;
			
		}
		
		/**
		 * ライブラリを更新します。
		 * 
		 * @param libraryDir 更新先ディレクトリ
		 * @param renewSubDir サブディレクトリも更新するかどうか。trueの場合は更新する。
		 */
		public function renewLibrary(libraryDir:File, renewSubDir:Boolean):void{
			
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
				this._libraryDirMap = convertVideoIdMapToDirMap(this._libraryVideoIdMap);
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
		private function infoLoadFunction(item:*, index:int, array:Array):void{

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
						_libraryVideoIdMap[tempKey] = _tempLibraryMap[tempKey];
					}
					
					if(_allDirRenew){
						//全ディレクトリ探索の場合は単純に削除判定が出来る
						tempKey = null;
						_logger.addLog("見つからなかった動画をライブラリから除去中...");
						for(tempKey in _libraryVideoIdMap){
							var tempVideo:NNDDVideo = _tempLibraryMap[tempKey];
							if(tempVideo == null){
								_logger.addLog("見つからなかった動画:" + tempKey);
								trace("見つからなかった動画:" + tempKey);
								delete _libraryVideoIdMap[tempKey];
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
									delete _libraryVideoIdMap[videoKey];
								}
							}
						}
					}
					
					_tempLibraryMap = null;
					
					this._libraryDirMap = convertVideoIdMapToDirMap(this._libraryVideoIdMap);
					this._tagManager.loadTag();
					
					dispatchEvent(new LibraryLoadEvent(LibraryLoadEvent.LIBRARY_LOAD_COMPLETE, false, false, _totalVideoCount, _videoCount));
				}
				
			}catch(error:Error){
				trace(error.getStackTrace());
				_logger.addLog("ファイルの読み込みに失敗:" + error + ":"+ fileName +":" + error.getStackTrace());
				
				if(_videoCount >= _totalVideoCount){
					for(var value:Object in _tempLibraryMap){
						_libraryVideoIdMap[value] = _tempLibraryMap[value];
					}
					_tempLibraryMap = null;
					
					this._libraryDirMap = convertVideoIdMapToDirMap(this._libraryVideoIdMap);
					this._tagManager.loadTag();
					
					dispatchEvent(new LibraryLoadEvent(LibraryLoadEvent.LIBRARY_LOAD_COMPLETE, false, false, _totalVideoCount, _videoCount))
				}
			}
			
		}
		
		/**
		 * 指定されたVideoIDをもつ動画を削除します。
		 * 
		 * @param videoId
		 * @param isSaveLibraryFile ライブラリファイルを保存するかどうか
		 * @return 
		 * 
		 */
		public function remove(videoId:String, isSaveLibraryFile:Boolean):NNDDVideo{
			
			var video:NNDDVideo = this._libraryVideoIdMap[videoId];
			
			delete this._libraryVideoIdMap[videoId];
			
			this._libraryDirMap = convertVideoIdMapToDirMap(this._libraryVideoIdMap);
			
			if(isSaveLibraryFile){
				saveLibrary();
			}
			
			return video;
		}
		
		/**
		 * 指定されたNNDDVideoでライブラリの動画を更新します。
		 * 
		 * @param video
		 * @param isSaveLibraryFile
		 * @return 
		 * 
		 */
		public function update(video:NNDDVideo, isSaveLibraryFile:Boolean):Boolean{
			
			var key:String = LibraryUtil.getVideoKey(video.getDecodeUrl());
			
			if(key != null){
				this._libraryVideoIdMap[key] = video;
				
				this._libraryDirMap = convertVideoIdMapToDirMap(this._libraryVideoIdMap);
				
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * 指定されたNNDDVideoをライブラリに追加します。
		 * 
		 * @param video
		 * @param isSaveLibrary ライブラリファイルを保存するかどうか
		 * @param isOverWrite 動画が登録済の場合に上書きするかどうか
		 * @return 
		 * 
		 */
		public function add(video:NNDDVideo, isSaveLibrary:Boolean, isOverWrite:Boolean = false):Boolean{
			var url:String = video.getDecodeUrl();
			
			if(!url.match(/\[Nicowari\]/)){
				var key:String = LibraryUtil.getVideoKey(video.getDecodeUrl());
				if(key != null && isExist(key) == null){
					
					_libraryVideoIdMap[key] = video;
					
					this._libraryDirMap = convertVideoIdMapToDirMap(this._libraryVideoIdMap);
					
					if(isSaveLibrary){
						saveLibrary();
					}
					
					return true;
				}else{
					if(isOverWrite){
						_libraryVideoIdMap[key] = video;
						this._libraryDirMap = convertVideoIdMapToDirMap(this._libraryVideoIdMap);
						
						if(isSaveLibrary){
							saveLibrary();
						}
						
						return true;
					}else{
						return false;
					}
				}
				
			}else{
				return false;
			}
		}
		
		/**
		 * ディレクトリのパスが変わったときに呼ばれます。
		 * ライブラリに登録されている項目で、oldDirUrlを含む動画のパスを、newDirUrlに変更します。
		 * @param oldDirUrl デコード済の変更前ディレクトリURL
		 * @param newDirUrl でコード済の変更後ディレクトリURL
		 */
		public function changeDirName(oldDir:File, newDir:File):void{
			var oldPattern:RegExp = new RegExp(decodeURIComponent(oldDir.url));
			var isFailed:Boolean = false;
			
			var videos:Vector.<NNDDVideo> = this._libraryDirMap[oldDir.nativePath];
			
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
					
					// Dir-NNDDVideoMapから取り除く
					removeFromDirMap(video);
					
					var newVideo:NNDDVideo = new NNDDVideo(encodeURI(url), null, video.isEconomy, video.tagStrings, video.modificationDate, video.creationDate, video.thumbUrl, video.playCount);
					this._libraryVideoIdMap[LibraryUtil.getVideoKey(video.getDecodeUrl())] = newVideo;
					
					// Dir-NNDDVideoMapに追加
					addForDirMap(newVideo);
					
					//ライブラリ保存
					saveLibrary();
				}
			}
			
			_logger.addLog("ライブラリを更新:" + newDir.nativePath);
		}
		
		/**
		 * 指定された動画IDの動画が存在するかどうかを調べます。
		 * 
		 * @param videoId
		 * @return 
		 * 
		 */
		public function isExistByVideoId(videoId:String):NNDDVideo{
			var nnddVideo:NNDDVideo = null;
			if(videoId != null){
				nnddVideo = _libraryVideoIdMap[videoId];
			}
			return nnddVideo;
		}
		
		/**
		 * 指定されたキーの動画が存在するかどうか調べます。<br />
		 * キーはgetVideoKey()で取得した値です。
		 * @param key
		 * @return 
		 * 
		 */
		public function isExist(key:String):NNDDVideo{
			var nnddVideo:NNDDVideo = null;
			if(key != null){
				nnddVideo = _libraryVideoIdMap[key];
			}
			return nnddVideo;
		}
		
		
		
		/**
		 * タグ情報を取得します。
		 * 
		 * @param dir タグ情報を収集するディレクトリ。nullの場合すべてのディレクトリ。
		 * @return 
		 * 
		 */
		public function collectTag(dir:File = null):Array{
			var array:Array = new Array();
			var map:Object = new Object();
			
			for(var key:Object in _libraryVideoIdMap){
				
				var video:NNDDVideo = _libraryVideoIdMap[key];
				if(video == null){
					delete _libraryVideoIdMap[key];
					continue;
				}
				
				if(dir != null && (decodeURIComponent(dir.url) == video.getDecodeUrl().substr(0, video.getDecodeUrl().lastIndexOf("/")))){
					for each(var tag:String in video.tagStrings){
						if(map[tag] == null){
							array.push(tag);
							map[tag] = tag;
						}
					}
				}else if(dir == null){
					for each(var tag:String in video.tagStrings){
						if(map[tag] == null){
							array.push(tag);
							map[tag] = tag;
						}
					}
				}
			}
			return array;
		}
		
		/**
		 * arrayで指定された名前の動画がもつタグを返します。
		 * 
		 * @param array
		 * @return 
		 * 
		 */
		public function collectTagByVideoName(nameArray:Array):Array{
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
		 * 渡された文字列からタグを検索し、返します。
		 * 
		 * @param word
		 * @return 
		 * 
		 */
		public function searchTagAndShow(word:String):Array{
			
			//wordをスペースで分割
			var pattern:RegExp = new RegExp("\\s*([^\\s]*)", "ig");
			var array:Array = word.match(pattern);
			
			return this._tagManager.searchTagByWords(array);
			
		}
		
		/**
		 * saveDirで指定されたディレクトリ下に存在する動画を返します。
		 * 
		 * @param saveDir
		 * @param isShowAll tureに設定すると、saveDir下のすべての動画を返します。
		 * @return 
		 * 
		 */
		public function getNNDDVideoArray(saveDir:File, isShowAll:Boolean):Vector.<NNDDVideo>{
			
			// 探索先ディレクトリをデコード
			var saveUrl:String = decodeURIComponent(saveDir.url);
			var videos:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			
			if(!isShowAll){
				videos = this._libraryDirMap[saveDir.nativePath];
			}else{
				videos = getNNDDVideoArrayWithSubDirVideo(saveDir);
			}
			
			if(videos == null){
				videos = new Vector.<NNDDVideo>();
			}
			
			// 探索先URLが"/"で終わっていなければ付加
//			if(saveUrl.lastIndexOf("/") != saveUrl.length-1){
//				saveUrl += "/";
//			}
//			var pattern:RegExp = new RegExp(saveUrl);
//			
//			for each(var video:NNDDVideo in _libraryVideoIdMap){
//				// 動画のURLを探索先URLと同じ文字分だけ抽出
//				var videoUrl:String = video.getDecodeUrl().substr(0, saveUrl.length);
//				if(videoUrl == saveUrl){
//					// 抽出した文字が等しかったらチェック対象
//					
//					if(!isShowAll){
//						
//						// 最後の/のindexを探す
//						var index:int = video.getDecodeUrl().lastIndexOf("/");
//						
//						// 先頭から最後の/までを抽出して等しければ返却対象
//						videoUrl = video.getDecodeUrl().substring(0, index+1);
//						if(videoUrl == saveUrl){
//							videos.push(video);
//						}
//					}else{
//						
//						// すべて返す
//						videos.push(video);
//					}
//				}
//			}
			
			return videos;
		}
		
		/**
		 * 
		 * @param saveDir
		 * @return 
		 * 
		 */
		private function getNNDDVideoArrayWithSubDirVideo(saveDir:File):Vector.<NNDDVideo>{
			
			var saveDirPath:String = saveDir.nativePath;
			var videos:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			
			for(var key:String in this._libraryDirMap){
				
				try{
					
					var file:File = new File(key);
					
					if(!file.exists){
						continue;
					}
					
					var videoDirPath:String = key.substr(0, saveDirPath.length);
					
					if(saveDirPath == videoDirPath){
						var list:Vector.<NNDDVideo> = this._libraryDirMap[file.nativePath];
						for each(var video:NNDDVideo in list){
							videos.push(video);
						}
					}
					
				}catch(error:Error){
					trace(error.getStackTrace());
				}
			}
			
			return videos;
		}
		
		/**
		 * 渡されたVideoID-NNDDVideoの連想配列構造を元にDir-NNDDVideoの連想配列を生成します。
		 * @param videoIdMap
		 * @return 
		 * 
		 */
		private function convertVideoIdMapToDirMap(videoIdMap:Object):Object{
			
//			var oldDate:Date = new Date();
//			var newDate:Date = new Date();
//			trace("VideoIdMap -> VideoDirMap 変換");
			
			var dirVideoMap:Object = new Object();
			
			for each(var object:Object in videoIdMap){
				if(object is NNDDVideo){
					var nnddVideo:NNDDVideo = NNDDVideo(object);
					
					var file:File = nnddVideo.dir;
					
					if(file != null){
						var list:Vector.<NNDDVideo> = dirVideoMap[file.nativePath];
						
						if(list == null){
							list = new Vector.<NNDDVideo>();
						}
						
						list.splice(0,0, nnddVideo);
						
						dirVideoMap[file.nativePath] = list;
						
					}
				}
			}
			
//			trace(newDate.getTime() - oldDate.getTime() + " ms");
			
			return dirVideoMap;
		}
		
		/**
		 * Dir-NNDDVideoの連想配列から指定されたNNDDVideoを取り除きます。
		 * 
		 * @param nnddVideo
		 * @return 
		 * 
		 */
		private function removeFromDirMap(nnddVideo:NNDDVideo):Boolean{
			if(nnddVideo != null){
				var file:File = nnddVideo.dir;
				if(file != null){
					var list:Vector.<NNDDVideo> = this._libraryDirMap[file.nativePath];
					
					if(list != null){
						for(var index:int=0; index < list.length; index++){
							
							var temp:NNDDVideo = list[index];
							
							if(temp != null && temp.videoName == nnddVideo.videoName){
								
								delete list[index];
								
								this._libraryDirMap[file.nativePath] = list;
								
								return true;
							}
						}
					}
				}
			}
			return false;
		}
		
		/**
		 * Dir-NNDDVideoの連想配列に指定されたNNDDVideoオブジェクトを追加します。
		 * 
		 * @param nnddVideo
		 * @return 
		 * 
		 */
		private function addForDirMap(nnddVideo:NNDDVideo):Boolean{
			
			if(nnddVideo != null){
				
				var file:File = nnddVideo.dir;
				
				if(file != null){
					
					var vector:Vector.<NNDDVideo> = this._libraryDirMap[file.nativePath];
					
					if(vector == null){
						vector = new Vector.<NNDDVideo>();
					}
					
					vector.splice(0,0, nnddVideo);
					
					this._libraryDirMap[file.nativePath] = vector;
					
					return true;
					
				}
				
			}
			return false;
		}
		
		/**
		 * デフォルトのライブラリのディレクトリを返します。
		 * @return 
		 * 
		 */
		public function get defaultLibraryDir():File{
			var file:File = File.documentsDirectory.resolvePath("NNDD/");
			return file;
		}
		
	}
}