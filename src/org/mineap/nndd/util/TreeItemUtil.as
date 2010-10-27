package org.mineap.nndd.util
{
	import mx.controls.Tree;
	
	import org.mineap.nndd.model.tree.ITreeItem;
	import org.mineap.nndd.model.tree.TreeFolderItem;

	public class TreeItemUtil
	{
		public function TreeItemUtil()
		{
		}
		
		public static function treeOpenItemArrayCreate(treeItem:ITreeItem, tree:Tree):Array{
			
			var array:Array = new Array();
			
			if(tree.openItems == null){
				return array;
			}
			
			if(!(tree.openItems as Array).indexOf(treeItem)){
				return array;
			}
			
			var folderItem:TreeFolderItem = null;
			if(treeItem is TreeFolderItem){
				folderItem = (treeItem as TreeFolderItem);
			}else{
				return array;
			}
			
			for each(var item:ITreeItem in folderItem.children){
				var tempArray:Array = treeOpenItemArrayCreate(item, tree);
				
				for each(var item2:ITreeItem in tempArray){
					array.push(item2);
				}
			}
			
			return array;
		}
		
	}
}