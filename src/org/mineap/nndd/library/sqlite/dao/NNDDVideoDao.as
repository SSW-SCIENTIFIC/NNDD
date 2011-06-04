package org.mineap.nndd.library.sqlite.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.library.sqlite.DbAccessHelper;
	import org.mineap.nndd.library.sqlite.Queries;
	import org.mineap.nndd.model.NNDDFile;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.model.TagString;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class NNDDVideoDao
	{
		
		private static const dao:NNDDVideoDao = new NNDDVideoDao();
		
		private var _stmt:SQLStatement;
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():NNDDVideoDao{
			return dao;
		}
		
		/**
		 * 
		 * 
		 */
		public function NNDDVideoDao()
		{
			if(dao != null){
				throw new ArgumentError("NNDDVideoDaoはインスタンス化できません。");
			}
		}
		
		/**
		 * トランザクションを開始します。
		 * 
		 */		
		public function transactionStart():void
		{
			DbAccessHelper.instance.connection.begin();
		}
		
		/**
		 * トランザクションを終了し、コミットします。
		 * 
		 */
		public function transactionEnd():void
		{
			DbAccessHelper.instance.connection.commit();
		}
		
		/**
		 * ロールバックします。
		 * 
		 */
		public function rollback():void
		{
			DbAccessHelper.instance.connection.rollback();
		}
		
		/**
		 * 指定された動画を一括してデータベースに登録します。
		 * データベースに存在しない動画はinsertされ、既に存在する動画は上書きされます。
		 * 
		 * @param nnddVideos 
		 * @param updateProperties 上書きするプロパティ。nullを指定した場合はwithOutUpdatePropertiesで指定した値以外を上書きします。
		 * @param withOutUpdateProperties 上書きしないプロパティ。updatePropertiesを指定された場合は無視されます。
		 * @return 
		 * 
		 */
		public function addNNDDVideos(nnddVideos:Vector.<NNDDVideo>, 
									  updateProperties:Vector.<String>, 
									  withOutUpdateProperties:Vector.<String>):Boolean
		{
			
			try
			{
				DbAccessHelper.instance.connection.begin();
				
				trace("フォルダをDBに登録中...");
				LogManager.instance.addLog("フォルダ情報をDBに登録中...");
				
				/* 存在しないファイルを一括して登録 */
				var dbFile:NNDDFile = null;
				var nnddVideo:NNDDVideo = null;
				var dbFile_map:Object = new Object();
				var newFile_map:Object = new Object();
				
				var dbFiles:Vector.<NNDDFile> = FileDao.instance.selectFileAll();
				for each(dbFile in dbFiles)
				{
					dbFile_map[dbFile.url] = dbFile;
				}
				
				for each(nnddVideo in nnddVideos)
				{
					var file:File = nnddVideo.dir;
					if(null == dbFile_map[file.url] && null == newFile_map[file.url])
					{
						newFile_map[file.url] = new NNDDFile(file.url);
					}
				}
				for each(var newFile:File in newFile_map)
				{
					if(FileDao.instance.insertFile(newFile, false))
					{
						trace("DBへの登録に失敗(フォルダ):" + newFile.nativePath);
					}
				}
				
				/* 必要なFileが全て永続化されているはず */
				dbFiles = FileDao.instance.selectFileAll();
				dbFile_map = new Object();
				for each(dbFile in dbFiles)
				{
					dbFile_map[dbFile.url] = dbFile;
				}
				
				/* 永続化されていない動画を抽出 */
				var dbVideos:Vector.<NNDDVideo> = selectAllNNDDVideo();
				var dbVideo_map:Object = new Object();
				var insertVideo_map:Object = new Object();
				for each(nnddVideo in dbVideos)
				{
					dbVideo_map[nnddVideo.key] = nnddVideo;
				}
				for each(nnddVideo in nnddVideos)
				{
					if (null == dbVideo_map[nnddVideo.key])
					{
						insertVideo_map[nnddVideo.key] = nnddVideo;
					}
				}
				
				trace("動画をDBに登録中...");
				LogManager.instance.addLog("動画をDBに登録中...");
				
				/* 永続化済みFileを元に動画を登録 */
				for each(nnddVideo in nnddVideos)
				{
					dbFile = null;
					dbFile = dbFile_map[nnddVideo.dir.url];
					
					if (dbFile == null)
					{
						continue;
					}
					
					var result:Boolean = false;
					
					if (null != insertVideo_map[nnddVideo.key])
					{
						result = insertNNDDVideo(nnddVideo, dbFile.id, false);
					}
					else
					{
						var tempVideo:NNDDVideo = dbVideo_map[nnddVideo.key];
						
						var prop:String = null;
						
						if(updateProperties == null)
						{
							nnddVideo.id = tempVideo.id;
							
							if (withOutUpdateProperties != null)
							{
								for each(prop in updateProperties)
								{
									if(tempVideo.hasOwnProperty(prop))
									{
										nnddVideo[prop] = tempVideo[prop];
									}
								}
							}
							
							result = updateNNDDVideo(nnddVideo, dbFile.id, false);
						}
						else
						{
							for each(prop in updateProperties)
							{
								if(tempVideo.hasOwnProperty(prop))
								{
									tempVideo[prop] = nnddVideo[prop];
								}
							}
														
							result = updateNNDDVideo(tempVideo, dbFile.id, false);
						}
					}
					
					if (!result)
					{
						trace("登録に失敗:" + nnddVideo.getDecodeUrl());
						LogManager.instance.addLog("DBへの登録に失敗:" + nnddVideo.getDecodeUrl());
					}
				}
				
				trace("タグをDBに登録中...");
				LogManager.instance.addLog("タグ情報をDBに登録中...");
				
				/* 今回永続化した動画から永続化する必要のあるタグを抽出 */
				var dbTagString:TagString = null;
				var tag:String = null;
				var dbTagStrings:Vector.<TagString> = TagStringDao.instance.selectAllTagString();
				var dbTagString_map:Object = new Object();
				var newTagString_map:Object = new Object();
				for each(dbTagString in dbTagStrings)
				{
					dbTagString_map[dbTagString.tag] = dbTagString;
				}
				for each(nnddVideo in nnddVideos)
				{
					for each(tag in nnddVideo.tagStrings)
					{
						if(null == dbTagString_map[tag])
						{
							newTagString_map[tag] = new TagString(tag);
						}
					}
				}
				
				/* 永続化されていないタグ情報を永続化 */
				for each(var newTagString:TagString in newTagString_map)
				{
					TagStringDao.instance.insertTagString(newTagString, false);
				}
				
				/* 必要なタグは全て永続化されているはず */
				dbTagString_map = new Object();
				dbTagStrings = TagStringDao.instance.selectAllTagString();
				for each(dbTagString in dbTagStrings)
				{
					dbTagString_map[dbTagString.tag] = dbTagString;
				}
				
				trace("タグと動画の関連をDBに登録中...");
				LogManager.instance.addLog("タグと動画の関連をDBに登録中...");
				/* タグと動画の関連を永続化 */
				for each(nnddVideo in nnddVideos)
				{
					var tempNNDDVideo:NNDDVideo = dbVideo_map[nnddVideo.key];
					if(null == tempNNDDVideo)
					{
						tempNNDDVideo = selectNNDDVideoByKey(nnddVideo.key);
					}
					
					var id:Number = tempNNDDVideo.id;
					
					var array:Array = NNDDVideoTagStringDao.instance.selectNNDDVideoTagStringRelationByVideoId(id);
					
					var tagIdArray:Array = new Array();
					var videoIdArray:Array = new Array();
					
					for (tag in nnddVideo.tagStrings)
					{
						dbTagString = dbTagString_map[tag];
						if (null == dbTagString)
						{
							continue;
						}
						if (!(array.indexOf(dbTagString.id) > -1))
						{
							continue;
						}
						tagIdArray.push(dbTagString.id);
						videoIdArray.push(id);
					}
					
					if (tagIdArray.length > 0)
					{
						NNDDVideoTagStringDao.instance.insertNNDDVideoTagStringRelation(videoIdArray, tagIdArray, false);
					}
				}
				
				DbAccessHelper.instance.connection.commit();
				
				return true;
				
			}
			catch(error:SQLError)
			{
				DbAccessHelper.instance.connection.rollback();
				trace(error.getStackTrace());
			}
			
			return false;
		}
		
		/**
		 * 動画を追加します
		 * 
		 * @param nnddVideo
		 * @return 
		 * 
		 */
		public function insertNNDDVideoWithFileAndTags(nnddVideo:NNDDVideo, transactionEnable:Boolean = true):Boolean{
			
			try{
				
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.begin();
				}
				
				/* ディレクトリ情報を探す */
				var dir:NNDDFile = FileDao.instance.selectFileByFile(nnddVideo.dir);
				if(dir == null){
					/* 無ければ追加 */
					FileDao.instance.insertFile(nnddVideo.dir, false);
					dir = FileDao.instance.selectFileByFile(nnddVideo.dir);
				}
				
				/* 動画を永続化 */
				if(!insertNNDDVideo(nnddVideo, dir.id, false))
				{
					if (transactionEnable)
					{
						DbAccessHelper.instance.connection.rollback();
					}
					
					return false;
				}
				
				var tempVideo:NNDDVideo = selectNNDDVideoByKey(nnddVideo.key);
				
				/* タグ情報も同時に保存 */
				
				var tagIdArray:Array = new Array();
				var videoIdArray:Array = new Array();
				for each(var str:String in nnddVideo.tagStrings){
					var tag:TagString = TagStringDao.instance.selectTagStringByTag(str);
					if(tag == null){
						tag = new TagString(str);
						/* タグが無ければ追加 */
						TagStringDao.instance.insertTagString(tag, false);
					}
					
					var tagString:TagString = TagStringDao.instance.selectTagStringByTag(str);
					if(tagString != null){
						tagIdArray.push(tagString.id);
						videoIdArray.push(tempVideo.id);
					}
				}
				
				/* タグとの関連情報を保存 */
				NNDDVideoTagStringDao.instance.insertNNDDVideoTagStringRelation(videoIdArray, tagIdArray, false);
				
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.commit();
				}
				
				return true;
				
			}catch(error:SQLError){
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.rollback();
				}
				trace(error.getStackTrace());
			}
			
			return false;
		}
		
		/**
		 * 指定された動画をデータベースに永続化します
		 * 
		 * @param nnddVideo
		 * @param dirId
		 * @param transactionEnable
		 * @return 
		 * 
		 */
		private function insertNNDDVideo(nnddVideo:NNDDVideo, dirId:Number, transactionEnable:Boolean = true):Boolean
		{
			try
			{
			
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.begin();
				}
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.INSERT_NNDDVIDEO;
				
				var isEconomy:int = 0;
				if(nnddVideo.isEconomy){
					isEconomy = 1;
				}
				
				var lastPlayDate:Number = -1;
				if(nnddVideo.lastPlayDate != null){
					lastPlayDate = nnddVideo.lastPlayDate.time;
				}
				
				var yetReading:int = 0;
				if(nnddVideo.yetReading){
					yetReading = 1;
				}
				
				var pubDate:Number = -1;
				if(nnddVideo.pubDate != null){
					pubDate = nnddVideo.pubDate.time;
				}
				
				this._stmt.parameters[":key"] = nnddVideo.key;
				this._stmt.parameters[":uri"] = nnddVideo.uri;
				this._stmt.parameters[":dirpath_id"] = dirId;
				this._stmt.parameters[":videoName"] = nnddVideo.videoName;
				this._stmt.parameters[":isEconomy"] = isEconomy;
				this._stmt.parameters[":modificationDate"] = nnddVideo.modificationDate.time;
				this._stmt.parameters[":creationDate"] = nnddVideo.creationDate.time;
				this._stmt.parameters[":thumbUrl"] = nnddVideo.thumbUrl;
				this._stmt.parameters[":playCount"] = nnddVideo.playCount;
				this._stmt.parameters[":time"] = nnddVideo.time;
				this._stmt.parameters[":lastPlayDate"] = lastPlayDate;
				this._stmt.parameters[":yetReading"] = yetReading;
				this._stmt.parameters[":pubDate"] = pubDate;
				
				this._stmt.execute();
			
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.commit();
				}
				
				return true;
				
			}
			catch(error:SQLError)
			{
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.rollback();
				}
				trace(error.getStackTrace());
			}
			
			return false;
		}
		
		
		/**
		 * 動画の情報を更新します
		 * 
		 * @param nnddVideo
		 * @return 
		 * 
		 */
		public function updateNNDDVideoWithFileAndTags(nnddVideo:NNDDVideo, transactionEnable:Boolean = true):Boolean{
			
			try{
				
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.begin();
				}
				
				/* ディレクトリ情報を探す */
				var dir:NNDDFile = FileDao.instance.selectFileByFile(nnddVideo.dir);
				if(dir == null){
					/* 無ければ追加 */
					FileDao.instance.insertFile(nnddVideo.dir, false);
					dir = FileDao.instance.selectFileByFile(nnddVideo.dir);
				}
				
				if (!updateNNDDVideo(nnddVideo, dir.id, false))
				{
					if (transactionEnable)
					{
						DbAccessHelper.instance.connection.rollback();
					}
					return false;
				}
				
				// 動画とタグの関連をリセット
				NNDDVideoTagStringDao.instance.deleteNNDDVideoTagStringRelationByVideoId(nnddVideo.id);
				
				var tagIdArray:Array = new Array();
				var videoIdArray:Array = new Array();
				for each(var str:String in nnddVideo.tagStrings){
				
					var tagString:TagString = TagStringDao.instance.selectTagStringByTag(str);
					
					if(tagString == null){
						// タグがDBにないので新規追加
						TagStringDao.instance.insertTagString(new TagString(str), false);
						tagString = TagStringDao.instance.selectTagStringByTag(str);
					}
					
					if(tagString != null){
						tagIdArray.push(tagString.id);
						videoIdArray.push(nnddVideo.id);
					}
					
				}
				
				// 動画とタグの関連を再設定
				NNDDVideoTagStringDao.instance.insertNNDDVideoTagStringRelation(videoIdArray, tagIdArray, false);
				
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.commit();
				}					
				
				return true;
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
				
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.rollback();
				}
			}
			
			return false;
		}
		
		/**
		 * データベース上のNNDDVideoを指定されたNNDDVideoで上書きします
		 * 
		 * @param nnddVideo
		 * @param dirId
		 * @param transactionEnable
		 * @return 
		 * 
		 */
		private function updateNNDDVideo(nnddVideo:NNDDVideo, 
										 dirId:Number, 
										 transactionEnable:Boolean = true):Boolean
		{
			try
			{
				
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.begin();
				}
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.UPDATE_NNDDVIDEO;
				
				var isEconomy:int = 0;
				if(nnddVideo.isEconomy){
					isEconomy = 1;
				}
				
				var lastPlayDate:Number = -1;
				if(nnddVideo.lastPlayDate != null){
					lastPlayDate = nnddVideo.lastPlayDate.time;
				}
				
				var yetReading:int = 0;
				if(nnddVideo.yetReading){
					yetReading = 1;
				}
				
				var pubDate:Number = -1;
				if(nnddVideo.pubDate != null){
					pubDate = nnddVideo.pubDate.time;
				}
				
				this._stmt.parameters[":key"] = nnddVideo.key;
				this._stmt.parameters[":uri"] = nnddVideo.uri;
				this._stmt.parameters[":dirpath_id"] = dirId;
				this._stmt.parameters[":videoName"] = nnddVideo.videoName;
				this._stmt.parameters[":isEconomy"] = isEconomy;
				this._stmt.parameters[":modificationDate"] = nnddVideo.modificationDate.time;
				this._stmt.parameters[":creationDate"] = nnddVideo.creationDate.time;
				this._stmt.parameters[":thumbUrl"] = nnddVideo.thumbUrl;
				this._stmt.parameters[":playCount"] = nnddVideo.playCount;
				this._stmt.parameters[":time"] = nnddVideo.time;
				this._stmt.parameters[":lastPlayDate"] = lastPlayDate;
				this._stmt.parameters[":yetReading"] = yetReading;
				this._stmt.parameters[":pubDate"] = pubDate;
				this._stmt.parameters[":id"] = nnddVideo.id;
				
				this._stmt.execute();
				
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.commit();
				}	
				
				return true;
				
			}
			catch(error:SQLError)
			{
				if (transactionEnable)
				{
					DbAccessHelper.instance.connection.rollback();
				}
				trace(error.getStackTrace());
			}
			
			return false;
		}
		
		
		/**
		 * 動画を削除します
		 * 
		 * @param id
		 * @return 
		 * 
		 */
		public function deleteNNDDVideoById(id:Number):Boolean{
			
			try{
				
				DbAccessHelper.instance.connection.begin();
				
				// 動画とタグの関連を消す
				var result:Boolean = NNDDVideoTagStringDao.instance.deleteNNDDVideoTagStringRelationByVideoId(id);
				if(!result){
					DbAccessHelper.instance.connection.rollback();
					return false;
				}
				
				// 動画を消す
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.DELETE_NNDDVIDEO;
				this._stmt.parameters[":id"] = id;
				
				this._stmt.execute();
				
				// どの動画にも見られていないファイルを消す
				FileDao.instance.deleteNeedlessFile();
				
				DbAccessHelper.instance.connection.commit();
				
				return true;
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
				DbAccessHelper.instance.connection.rollback();
			}
			return false;
		}
		
		/**
		 * 動画を削除します
		 * 
		 * @param key 動画のID。
		 * @return 
		 * 
		 */
		public function deleteNNDDVideoByKey(key:String):Boolean{
			try{
				var nnddVideo:NNDDVideo = selectNNDDVideoByKey(key);
				
				DbAccessHelper.instance.connection.begin();
				
				// 動画とタグの関連を消す
				var result:Boolean = NNDDVideoTagStringDao.instance.deleteNNDDVideoTagStringRelationByVideoId(nnddVideo.id);
				if(!result){
					DbAccessHelper.instance.connection.rollback();
					return false;
				}
				
				// 動画を消す
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.DELETE_NNDDVIDEO;
				this._stmt.parameters[":id"] = nnddVideo.id;
				
				this._stmt.execute();
				
				// どの動画にも見られていないファイルを消す
				FileDao.instance.deleteNeedlessFile();
				
				DbAccessHelper.instance.connection.commit();
				
				return true;
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
				DbAccessHelper.instance.connection.rollback();
			}
			return false;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function selectAllNNDDVideo():Vector.<NNDDVideo>{
			
			var vector:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			
			try{
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.SELECT_NNDDVIDEO_ALL;
				
				this._stmt.execute();
				
				var result:SQLResult = this._stmt.getResult();
				if(result == null){
					return vector;
				}
				
				for each(var object:Object in result.data){
					
					var nnddVideo:NNDDVideo = convertObjectToNNDDVideo(object);
					
					vector.splice(vector.length, 0, nnddVideo);
					
				}
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			return vector;
		}
		
		/**
		 * 
		 * @param id
		 * @return 
		 * 
		 */
		public function selectNNDDVideoById(id:int):NNDDVideo{
			try{
				
				DbAccessHelper.instance.connection.begin();
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.SELECT_NNDDVIDEO_BY_ID;
				
				this._stmt.parameters[":id"] = id;
				
				this._stmt.execute();
				
				var result:SQLResult = this._stmt.getResult();
				
				if(result == null){
					DbAccessHelper.instance.connection.commit();
					return null;
				}
				
				if(result.data == null){
					DbAccessHelper.instance.connection.commit();
					return null;
				}
				
				if(result.data.length > 0){
					var object:Object = result.data[0];
					var nnddVideo:NNDDVideo = convertObjectToNNDDVideo(object);
					DbAccessHelper.instance.connection.commit();
					return nnddVideo;
				}
				
			}catch(error:SQLError){
				DbAccessHelper.instance.connection.rollback();
				trace(error.getStackTrace());
			}
			return null;
		}
		
		/**
		 * 
		 * @param key
		 * @return 
		 * 
		 */
		public function selectNNDDVideoByKey(key:String):NNDDVideo{
			try{
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.SELECT_NNDDVIDEO_BY_KEY;
				
				this._stmt.parameters[":key"] = key;
				
				this._stmt.execute();
				
				var result:SQLResult = this._stmt.getResult();
				
				if(result == null){
					return null;
				}
				
				if(result.data == null){
					return null;
				}
				
				if(result.data.length > 0){
					var object:Object = result.data[0];
					var nnddVideo:NNDDVideo = convertObjectToNNDDVideo(object);
					
					return nnddVideo;
				}
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			return null;
		}
		
		/**
		 * 
		 * @param uri
		 * @return 
		 * 
		 */
		public function selectNNDDVideoByFile(file:File, 
											  enableTran:Boolean = true, 
											  fetchTags:Boolean = true, 
											  withSubFile:Boolean = true):Vector.<NNDDVideo>{
			
			var vector:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			
			try{
				
				if(enableTran){
					DbAccessHelper.instance.connection.begin();
				}
				
				var files:Vector.<NNDDFile> = null;
				if(withSubFile){
					files = FileDao.instance.selectFileByFileWithSubFile(file);
				}else{
					files = new Vector.<NNDDFile>();
					file = FileDao.instance.selectFileByFile(file);
					if(file == null){
						return vector;
					}
					files.push(file);
				}
				
				var needlessFiles:Vector.<NNDDFile> = new Vector.<NNDDFile>();
				for each(var tempFile:NNDDFile in files){
					
					this._stmt = new SQLStatement();
					this._stmt.sqlConnection = DbAccessHelper.instance.connection;
					
					this._stmt.text = Queries.SELECT_NNDDVIDEO_BY_FILE_ID;
					
					this._stmt.parameters[":dirpath_id"] = tempFile.id;
					
					this._stmt.execute();
					
					var result:SQLResult = this._stmt.getResult();
					
					if(result == null){
						continue;
					}
					
					if(result.data == null){
						continue;
					}
					
					if(result.data.length > 0){
						for each(var object:Object in result.data){
							var nnddVideo:NNDDVideo = convertObjectToNNDDVideo(object, fetchTags);
							vector.push(nnddVideo);
						}
					}
				}
				
				if(enableTran){
					DbAccessHelper.instance.connection.commit();
				}
				FileDao.instance.deleteNeedlessFile();
				return vector;
				
			}catch(error:SQLError){
				if(enableTran){
					DbAccessHelper.instance.connection.rollback();
				}
				trace(error.getStackTrace());
			}
			
			return vector;
			
		}
		
		/**
		 * 
		 * @param object
		 * @return 
		 * 
		 */
		private function convertObjectToNNDDVideo(object:Object, fetchTags:Boolean = true):NNDDVideo{
			var uri:String = object.uri;
			var videoName:String = object.videoName;
			var isEconomy:Boolean = false;
			if(object.isEconomy == 1){
				isEconomy = true;
			}
			
			var tags:Vector.<String> = new Vector.<String>();
			
			var modificationDate:Date = null;
			if(object.modificationDate != null && object.modificationDate != -1){
				modificationDate = new Date(Number(object.modificationDate));
			}
			
			var creationDate:Date = null;
			if(object.creationDate != null && object.creationDate != -1){
				creationDate = new Date(Number(object.creationDate));
			}
			
			var thumbUrl:String = object.thumbUrl;
			var playCount:Number = Number(object.playCount);
			var time:Number = Number(object.time);
			var lastPlayDate:Date = null;
			if(object.lastPlayDate != null && object.lastPlayDate != -1){
				lastPlayDate = new Date(Number(object.lastPlayDate));
			}
			
			var pubDate:Date = null;
			if(object.pubDate != null && object.pubDate != -1){
				pubDate = new Date(Number(object.pubDate));
			}
			
			var nnddVideo:NNDDVideo = new NNDDVideo(uri, videoName, isEconomy, 
				tags, modificationDate, creationDate, thumbUrl, playCount, 
				time, lastPlayDate, pubDate);
			
			nnddVideo.id = object.id;
			
			// 関連するタグ文字列を取得
			if(fetchTags){
				var array:Array = NNDDVideoTagStringDao.instance.selectNNDDVideoTagStringRelationByVideoId(nnddVideo.id);
				for each(var object:Object in array){
					var id:Number = Number(object.tag_id);
					var tagString:TagString = TagStringDao.instance.selectTagStringById(id);
					nnddVideo.tagStrings.push(tagString.tag);
				}
			}
			
			return nnddVideo;
		}
		
	}

}