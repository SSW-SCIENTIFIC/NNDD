package org.mineap.nndd.library.sqlite.dao
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	
	import org.mineap.nndd.library.sqlite.DbAccessHelper;
	import org.mineap.nndd.library.sqlite.Queries;
	import org.mineap.nndd.model.NNDDFile;

	public class FileDao
	{
		
		private static const dao:FileDao = new FileDao();
		
		private var _stmt:SQLStatement;
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():FileDao{
			return dao;
		}
		
		/**
		 * 
		 * 
		 */
		public function FileDao()
		{
			if(dao != null){
				throw new ArgumentError("FileDaoはインスタンス化できません。");
			}			
		}
		
		/**
		 * 
		 * @param file
		 * 
		 */
		public function insertFile(file:File):Boolean{
			try{
				
				if(!file.isDirectory){
					file = file.parent;
				}
				
				if(file == null){
					return false;
				}
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.INSERT_FILE;
				
				this._stmt.parameters[":dirpath"] = file.url;
				
				this._stmt.execute();
				return true;
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			return false;
		}
		
		/**
		 * 
		 * @param id
		 * @return 
		 * 
		 */
		public function selectFileById(id:Number):NNDDFile{
			
			try{
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.SELECT_FILE_BY_ID;
				
				this._stmt.parameters[":id"] = id;
				
				this._stmt.execute();
				
				var sqlResult:SQLResult = this._stmt.getResult();
				if(sqlResult == null){
					return null;
				}
				
				if(sqlResult.data.length == 0){
					return null;
				}
				
				if(sqlResult.data.length > 0){
					var object:Object = sqlResult.data[0];
					var path:String = object.dirpath;
					var file:NNDDFile = new NNDDFile(path);
					file.id = object.id;
					return file;
				}
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}

			return null;
		}
		
		/**
		 * 
		 * @param file
		 * @return 
		 * 
		 */
		public function selectFileAll():Vector.<NNDDFile>{
			
			var vector:Vector.<NNDDFile> = new Vector.<NNDDFile>();
			
			try{
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.SELECT_FILE_ALL;
				
				this._stmt.execute();
				
				var sqlResult:SQLResult = this._stmt.getResult();
				if(sqlResult == null){
					return vector;
				}
				
				if(sqlResult.data == null){
					return vector;
				}
				
				if(sqlResult.data.length == 0){
					return vector;
				}
				
				for each(var object:Object in sqlResult.data){
					var file:NNDDFile = new NNDDFile(object.dirpath);
					file.id = object.id;
					vector.push(file);
				}
				
				return vector;
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			return vector;
		}
		
		/**
		 * 
		 * @param file
		 * 
		 */
		public function selectFileByFile(file:File):NNDDFile{
			var files:Vector.<NNDDFile> = selectFileAll();
			
			var returnValue:NNDDFile = null;
			for each(var temp:NNDDFile in files){
				if(temp.nativePath == file.nativePath){
					returnValue = temp;
					break;
				}
			}
			
			return returnValue;
			
		}
		
		/**
		 * 
		 * @param file
		 * @return 
		 * 
		 */
		public function selectFileByFileWithSubFile(file:File):Vector.<NNDDFile>{
			var files:Vector.<NNDDFile> = selectFileAll();
			var length:Number = file.nativePath.length;
			
			var vector:Vector.<NNDDFile> = new Vector.<NNDDFile>();
			for each(var temp:NNDDFile in files){
				if(temp.nativePath.substr(0, length) == file.nativePath){
					vector.push(temp);
				}
			}
			
			return vector;
		}
		
		/**
		 * 
		 * @param id
		 * @return 
		 * 
		 */
		public function deleteFile(id:Number):Boolean{
			try{
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.DELETE_FILE;
				
				this._stmt.parameters[":id"] = id;
				
				this._stmt.execute();
				return true;
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			return false;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function deleteNeedlessFile():Boolean{
			try{
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.DELETE_NEEDLESS_FILE;
				
				this._stmt.execute();
				
				return true;
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			return false;
		}
		
	}	
}