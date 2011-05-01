package org.mineap.nndd.library.sqlite.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	
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
		 * 動画を追加します
		 * 
		 * @param nnddVideo
		 * @return 
		 * 
		 */
		public function insertNNDDVideo(nnddVideo:NNDDVideo):Boolean{
			
			try{
				
				DbAccessHelper.instance.connection.begin();
				
				/* ディレクトリ情報を探す */
				var dir:NNDDFile = FileDao.instance.selectFileByFile(nnddVideo.dir);
				if(dir == null){
					/* 無ければ追加 */
					FileDao.instance.insertFile(nnddVideo.dir);
					dir = FileDao.instance.selectFileByFile(nnddVideo.dir);
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
				this._stmt.parameters[":dirpath_id"] = dir.id;
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
				
				var tempVideo:NNDDVideo = selectNNDDVideoByKey(nnddVideo.key, false);
				
				/* タグ情報も同時に保存 */
				
				var tagIdArray:Array = new Array();
				var videoIdArray:Array = new Array();
				for each(var str:String in nnddVideo.tagStrings){
					var tag:TagString = TagStringDao.instance.selectTagStringByTag(str);
					if(tag == null){
						tag = new TagString(str);
						/* タグが無ければ追加 */
						TagStringDao.instance.insertTagString(tag);
					}
					
					var tagString:TagString = TagStringDao.instance.selectTagStringByTag(str);
					if(tagString != null){
						tagIdArray.push(tagString.id);
						videoIdArray.push(tempVideo.id);
					}
				}
				
				/* タグとの関連情報を保存 */
				NNDDVideoTagStringDao.instance.insertNNDDVideoTagStringRelation(videoIdArray, tagIdArray);
				
				DbAccessHelper.instance.connection.commit();
				
				return true;
				
			}catch(error:SQLError){
				DbAccessHelper.instance.connection.rollback();
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
		public function updateNNDDVideo(nnddVideo:NNDDVideo):Boolean{
			
			try{
				
				DbAccessHelper.instance.connection.begin();
				
				/* ディレクトリ情報を探す */
				var dir:NNDDFile = FileDao.instance.selectFileByFile(nnddVideo.dir);
				if(dir == null){
					/* 無ければ追加 */
					FileDao.instance.insertFile(nnddVideo.dir);
					dir = FileDao.instance.selectFileByFile(nnddVideo.dir);
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
				this._stmt.parameters[":dirpath_id"] = dir.id;
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
				
				// 動画とタグの関連をリセット
				NNDDVideoTagStringDao.instance.deleteNNDDVideoTagStringRelationByVideoId(nnddVideo.id);
				
				var tagIdArray:Array = new Array();
				var videoIdArray:Array = new Array();
				for each(var str:String in nnddVideo.tagStrings){
				
					var tagString:TagString = TagStringDao.instance.selectTagStringByTag(str);
					
					if(tagString == null){
						// タグがDBにないので新規追加
						TagStringDao.instance.insertTagString(new TagString(str));
						tagString = TagStringDao.instance.selectTagStringByTag(str);
					}
					
					if(tagString != null){
						tagIdArray.push(tagString.id);
						videoIdArray.push(nnddVideo.id);
					}
					
				}
				
				// 動画とタグの関連を再設定
				NNDDVideoTagStringDao.instance.insertNNDDVideoTagStringRelation(videoIdArray, tagIdArray);
				
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
				
				DbAccessHelper.instance.connection.begin();
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.SELECT_NNDDVIDEO_ALL;
				
				this._stmt.execute();
				
				var result:SQLResult = this._stmt.getResult();
				if(result == null){
					DbAccessHelper.instance.connection.commit();
					return vector;
				}
				
				for each(var object:Object in result.data){
					
					var nnddVideo:NNDDVideo = convertObjectToNNDDVideo(object);
					
					vector.splice(vector.length, 0, nnddVideo);
					
				}
				
				DbAccessHelper.instance.connection.commit();
				
			}catch(error:SQLError){
				DbAccessHelper.instance.connection.rollback();
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
		public function selectNNDDVideoByKey(key:String, enableTran:Boolean = true):NNDDVideo{
			try{
				
				if(enableTran){
					DbAccessHelper.instance.connection.begin();
				}
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.SELECT_NNDDVIDEO_BY_KEY;
				
				this._stmt.parameters[":key"] = key;
				
				this._stmt.execute();
				
				var result:SQLResult = this._stmt.getResult();
				
				if(result == null){
					if(enableTran){
						DbAccessHelper.instance.connection.commit();
					}
					return null;
				}
				
				if(result.data == null){
					if(enableTran){
						DbAccessHelper.instance.connection.commit();
					}
					return null;
				}
				
				if(result.data.length > 0){
					var object:Object = result.data[0];
					var nnddVideo:NNDDVideo = convertObjectToNNDDVideo(object);
					
					if(enableTran){
						DbAccessHelper.instance.connection.commit();
					}
					return nnddVideo;
				}
				
			}catch(error:SQLError){
				if(enableTran){
					DbAccessHelper.instance.connection.rollback();
				}
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