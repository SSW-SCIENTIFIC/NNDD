package org.mineap.nndd.library.sqlite
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	
	import mx.charts.chartClasses.StackedSeries;
	
	import org.mineap.nndd.library.sqlite.dao.VersionDao;
	import org.mineap.nndd.model.NNDDVideo;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class DbAccessHelper
	{
		private static const dbAccessHelper:DbAccessHelper = new DbAccessHelper();
		
		public static const version:String = "2";
		
		private var _connection:SQLConnection;
		private var _stmt:SQLStatement;
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():DbAccessHelper{
			return dbAccessHelper;
		}
		
		/**
		 * 
		 * 
		 */
		public function DbAccessHelper()
		{
			if(dbAccessHelper != null){
				throw new ArgumentError("DbAccessHelperはインスタンス化できません。");
			}
		}
		
		/**
		 * 指定されたデータベースへのコネクションを確立します。(同期モード)
		 * @param dbFile
		 * 
		 */
		public function connect(dbFile:File):Boolean{
			
			try{
			
				this._connection = new SQLConnection();
				this._connection.open(dbFile);
				
				var version:String = VersionDao.instance.selectVersion();
				
				if(version == null){
					this.createTables();
				}
				
				return this._connection.connected;
			
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			
			return false;
			
		}

		/**
		 * 
		 * 
		 */
		public function disconnect():void{
			if(this._connection != null){
				try{
					this._connection.close();
				}catch(error:Error){
					trace(error.getStackTrace());
				}
			}
		}	
		
		/**
		 * テーブルを作成します
		 * 
		 */
		public function createTables():void{
			
			createNNDDTable();
			
			createTagTable();
			
			createNNDDVIDEO_TAGTable();
			
			createNNDDVIDEO_FILETable();
			
			createVersionTable();
			
		}
		
		/**
		 * 
		 * 
		 */
		public function createNNDDTable():void{
			this._stmt = new SQLStatement();
			this._stmt.sqlConnection = this._connection;
			
			this._stmt.text = Queries.CREATE_TABLE_NNDDVIDEO;
			this._stmt.execute();
			
			try{
				this._stmt.text = Queries.CREATE_INDEX_KEY_OF_NNDDVIDEO;
				this._stmt.execute();
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
		}
		
		/**
		 * 
		 * 
		 */
		public function createTagTable():void{
			this._stmt = new SQLStatement();
			this._stmt.sqlConnection = this._connection;
			
			this._stmt.text = Queries.CREATE_TABLE_TAG;
			this._stmt.execute();
		}
		
		/**
		 * 
		 * 
		 */
		public function createNNDDVIDEO_TAGTable():void{
			this._stmt = new SQLStatement();
			this._stmt.sqlConnection = this._connection;
			
			this._stmt.text = Queries.CREATE_TABLE_NNDDVIDEO_TAG;
			this._stmt.execute();
		}
		
		/**
		 * 
		 * 
		 */
		public function createNNDDVIDEO_FILETable():void{
			this._stmt = new SQLStatement();
			this._stmt.sqlConnection = this._connection;
			
			this._stmt.text = Queries.CREATE_TABLE_FILE;
			this._stmt.execute();
		}
		
		/**
		 * 
		 * 
		 */
		public function createVersionTable():void{
			this._stmt = new SQLStatement();
			this._stmt.sqlConnection = this._connection;
			
			this._stmt.text = Queries.CREATE_TABLE_VERSION;
			this._stmt.execute();
		}
		
		
		/**
		 * 
		 * 
		 */
		public function dropTables():void{
			this._stmt = new SQLStatement();
			this._stmt.sqlConnection = this._connection;
			try{
				this._stmt.text = Queries.DROP_NNDDVIDEO_TAG;
				this._stmt.execute();
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			try{
				this._stmt.text = Queries.DROP_TAGSTRING;
				this._stmt.execute();
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			try{
				this._stmt.text = Queries.DROP_INDEX_KEY_OF_NNDDVIDEO;
				this._stmt.execute();
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			try{
				this._stmt.text = Queries.DROP_NNDDVIDEO;
				this._stmt.execute();
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			try{
				this._stmt.text = Queries.DROP_FILE;
				this._stmt.execute();
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get connection():SQLConnection{
			return this._connection;
		}
		
	}
}