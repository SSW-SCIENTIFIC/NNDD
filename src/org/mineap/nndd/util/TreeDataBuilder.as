package org.mineap.nndd.util
{
	import org.mineap.nndd.model.tree.TreeFileItem;
	import org.mineap.nndd.model.tree.TreeFolderItem;

	/**
	 * 
	 * Treeコントロールに渡すObject型のデータを構築するクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class TreeDataBuilder
	{
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function TreeDataBuilder()
		{
		}
		
		/**
		 * フォルダオブジェクトを生成します。フォルダオブジェクトは、String型の値を保持するlabelプロパティと、
		 * 子にフォルダオブジェクトとファイルオブジェクトを格納するためのArray型のchildrenプロパティを持ちます。
		 * 
		 * @param folderName
		 * @return 
		 * 
		 */
		public function getFolderObject(folderName:String):TreeFolderItem{
			var object:TreeFolderItem = new TreeFolderItem();
			object.label = folderName;
			object.children = new Array();
			return object;
		}
		
		/**
		 * ファイルオブジェクトを生成します。ファイルオブジェクトはString型の値を保持するlabelプロパティを持っています。
		 * 
		 * @param fileName
		 * @return 
		 * 
		 */
		public function getFileObject(fileName:String):TreeFileItem{
			var object:TreeFileItem = new TreeFileItem();
			object.label = fileName;
			return object;
		}
		
		/**
		 * 渡されたfolderObjectから、removeNameArrayで指定された名前と同じ名前をlabelプロパティ持つオブジェクトを削除します。
		 * 
		 * @param folderObject
		 * @param removeNameArray
		 * @return 
		 * 
		 */
		public function removeChildrenFromFolderObject(folderObject:Object, removeNameArray:Array):Object{
			var array:Array = folderObject.children;
			
			for(var i:int=0; i<array.length; i++){
				for(var j:int=0; j<removeNameArray.length; j++){
					if(array[i].label == removeNameArray[j]){
						array.splice(i,1);
						break;
					}
				}
			}
			
			folderObject.children = array;
			
			return folderObject;
		}
		
	}
}