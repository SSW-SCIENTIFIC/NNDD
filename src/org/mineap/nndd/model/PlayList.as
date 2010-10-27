package org.mineap.nndd.model
{
	/**
	 * 
	 * プレイリスト一つを管理します。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class PlayList
	{
		
		/**
		 * プレイリスト名です
		 */
		public var name:String = "";
		
		/**
		 * プレイリストに登録されている項目です
		 */
		public var items:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
		
		/**
		 * プレイリストオブジェクトがフォルダかどうかを表します
		 */
		public var isDir:Boolean = false;
		
		
		/**
		 * コンストラクタ<br>
		 * プレイリストを生成します。
		 * 
		 * @param name プレイリストの名前を指定します
		 * @param items プレイリストに格納する項目を指定します
		 * @param isDir プレイリストがフォルダかどうかを表します
		 * 
		 */
		public function PlayList(name:String = "", items:Vector.<NNDDVideo> = null, isDir:Boolean = false)
		{
			if(name != null && name != ""){
				this.name = name;
			}
			if(items != null){
				this.items = items;
			}
			this.isDir = isDir;
			
		}
	}
}