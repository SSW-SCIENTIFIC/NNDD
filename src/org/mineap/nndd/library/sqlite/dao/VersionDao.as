package org.mineap.nndd.library.sqlite.dao
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import mx.controls.Text;
	
	import org.mineap.nndd.library.sqlite.DbAccessHelper;
	import org.mineap.nndd.library.sqlite.Queries;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class VersionDao
	{
		
		private static const dao:VersionDao = new VersionDao();
		
		private var _stmt:SQLStatement;
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():VersionDao
		{
			return dao;
		}
		
		/**
		 * 
		 * 
		 */
		public function VersionDao()
		{
			if(dao != null){
				throw new ArgumentError("VersionDaoはインスタンス化できません。");
			}
		}
		
		/**
		 * 
		 * @param version
		 * 
		 */
		public function insertVersion(version:String):Boolean{
			try{
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.INSERT_VERSION;
				
				this._stmt.parameters[":id"] = 0;
				this._stmt.parameters[":version"] = version;
				
				this._stmt.execute();
				
				return true;
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			return false;
		}
		
		/**
		 * 
		 * @param version
		 * @return 
		 * 
		 */
		public function updateVersion(version:String):Boolean{
			try{
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.UPDATE_VERSION;
				
				this._stmt.parameters[":id"] = 0;
				this._stmt.parameters[":version"] = version;
				
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
		public function selectVersion():String{
			try{
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.SELECT_VERSION_BY_ID;
				
				this._stmt.parameters[":id"] = 0;
				
				this._stmt.execute();
				
				var result:SQLResult = this._stmt.getResult();
				if(result == null){
					return null;
				}
				
				if(result.data == null){
					return null;
				}
				
				if(result.data.length > 0){
					
					var version:String = result.data[0].version;
					return version;
					
				}else{
					return null;
				}
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			return null;
		}
	}
}