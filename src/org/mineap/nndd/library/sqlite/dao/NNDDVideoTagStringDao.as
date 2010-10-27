package org.mineap.nndd.library.sqlite.dao
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	
	import org.mineap.nndd.library.sqlite.DbAccessHelper;
	import org.mineap.nndd.library.sqlite.Queries;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class NNDDVideoTagStringDao
	{
		
		private static const dao:NNDDVideoTagStringDao = new NNDDVideoTagStringDao();
		
		private var _stmt:SQLStatement;
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():NNDDVideoTagStringDao{
			return dao;
		}
		
		/**
		 * 
		 * 
		 */
		public function NNDDVideoTagStringDao()
		{
			if(dao != null){
				throw new ArgumentError("NNDDVideoTagStringDaoはインスタンス化できません。");
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function insertNNDDVideoTagStringRelation(videoIdArray:Array, tagStringIdArray:Array):Boolean{
			try{
				
				if(videoIdArray.length != tagStringIdArray.length){
					return false;
				}
				
				for(var i:int=0; i<videoIdArray.length; i++){
				
					this._stmt = new SQLStatement();
					this._stmt.sqlConnection = DbAccessHelper.instance.connection;
					this._stmt.text = Queries.INSERT_NNDDVIDEO_TAG;
				
					this._stmt.parameters[":nnddvideo_id"] = videoIdArray[i];
					this._stmt.parameters[":tag_id"] = tagStringIdArray[i];
					
					this._stmt.execute();
					
				}
				
				return true;
				
			}catch(error:Error){
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
		public function selectNNDDVideoTagStringRelationByVideoId(id:Number):Array{
			try{
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.SELECT_NNDDVIDEO_TAG_BY_NNDDVIDEO_ID;
				
				this._stmt.parameters[":nnddvideo_id"] = id;
				
				this._stmt.execute();
				
				var result:SQLResult = this._stmt.getResult();
				
				if(result == null){
					return new Array();
				}
				
				if(result.data == null){
					return new Array();
				}
				
				return result.data;
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			return new Array();
		}
		
		/**
		 * 
		 * @param id
		 * @return 
		 * 
		 */
		public function selectNNDDVideoTagStringRelationByTagStringId(id:Number):Array{
			try{
				
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.SELECT_NNDDVIDEO_TAG_BY_TAG_ID;
				
				this._stmt.parameters[":tag_id"] = id;
				
				this._stmt.execute();
				
				var result:SQLResult = this._stmt.getResult();
				
				if(result == null){
					return new Array();
				}
				
				if(result.data == null){
					return new Array();
				}
				
				return result.data;
				
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			return new Array();
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function deleteNNDDVideoTagStringRelationByVideoId(id:Number):Boolean{
			try{
				
				var array:Array = selectNNDDVideoTagStringRelationByVideoId(id);
				
				for each(var object:Object in array){
					
					var id:Number = object.id;
					var tagId:Number = object.tag_id;
					
					deleteNNDDVideoTagStringRelation(id);
					
					var tagArray:Array = selectNNDDVideoTagStringRelationByTagStringId(tagId);
					if(tagArray.length == 0){
						TagStringDao.instance.deleteTagStringById(tagId);
					}
					
				}
				
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
		public function deleteNNDDVideoTagStringRelationByTagId(id:Number):Boolean{
			try{
				
				var array:Array = selectNNDDVideoTagStringRelationByTagStringId(id);
				
				for each(var object:Object in array){
					
					var id:Number = object.id;
					
					deleteNNDDVideoTagStringRelation(id);
					
				}
				
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
		public function deleteNNDDVideoTagStringRelation(id:Number):Boolean{
			try{
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.DELETE_NNDDVIDEO_TAG;
				
				this._stmt.parameters[":id"] = id;
				
				this._stmt.execute();
				
				return true;
				
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			
			return false;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function dropTable():Boolean{
			try{
				this._stmt = new SQLStatement();
				this._stmt.sqlConnection = DbAccessHelper.instance.connection;
				this._stmt.text = Queries.DROP_NNDDVIDEO_TAG;
				this._stmt.execute();
				return true;
			}catch(error:SQLError){
				trace(error.getStackTrace());
			}
			
			return false;
		}
		
	}
}