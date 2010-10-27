package org.mineap.nndd.library
{
	import flash.filesystem.File;
	
	import org.mineap.nndd.model.PlayList;
	import org.mineap.nndd.model.tree.ITreeItem;
	import org.mineap.nndd.model.tree.TreeFileItem;
	import org.mineap.nndd.model.tree.TreeFolderItem;
	import org.mineap.nndd.playList.PlayListManager;
	import org.mineap.nndd.util.TreeDataBuilder;

	public class LibraryTreeBuilder
	{
		private var treeDataBuilder:TreeDataBuilder;
		private var libraryManager:ILibraryManager;
		
		public function LibraryTreeBuilder()
		{
			treeDataBuilder = new TreeDataBuilder();
			libraryManager = LibraryManagerBuilder.instance.libraryManager;
		}
		
		/**
		 * ライブラリディレクトリ直下の一覧およびプレイリストディレクトリ直下の一覧を取得し、
		 * それぞれのディレクトリ構造(TreeFolderItem)およびフォルダ構造(TreeFileItem)をリストに格納して返します。
		 * 
		 * @param onlyChildren
		 * @return 
		 * 
		 */
		public function build(onlyChildren:Boolean):Array{
			
			var array:Array = new Array();
			
			// ライブラリのディレクトリ構造を生成
			var libraryFolder:TreeFolderItem = treeDataBuilder.getFolderObject("Library");
			libraryFolder.file = libraryManager.libraryDir;
			array.push(libraryFolder);
			
			libraryFolder.children = buildTreeFolderItems(libraryManager.libraryDir, onlyChildren);
			for each(var item:ITreeItem in libraryFolder.children){
				item.parent = libraryFolder;
			}
			
			for(var index:int=0; index<libraryFolder.children.length; index++){
				if((libraryFolder.children[index] as TreeFolderItem).file.nativePath == libraryManager.systemFileDir.nativePath){
					libraryFolder.children.splice(index, 1);
					break;
				}
			}
			
			// プレイリスト構造を生成
			var playListFolder:TreeFolderItem = treeDataBuilder.getFolderObject("PlayList");
			array.push(playListFolder);
			
			var playLists:Vector.<PlayList> = PlayListManager.instance.readPlayListSummary(libraryManager.playListDir);
			for each(var playList:PlayList in playLists){
				var file:TreeFileItem = treeDataBuilder.getFileObject(playList.name);
				playListFolder.children.push(file);
				file.parent = playListFolder;
			}
			
			return array;
			
		}
		
		/**
		 * 指定されたディレクトリ直下のディレクトリ一覧を取得し、これを元にTreeFolderItemのリストを生成し、返します。
		 * 
		 * @param array
		 * @return 
		 * 
		 */
		public function buildOnlyChildDir(item:TreeFolderItem):Array{
			
			var array:Array = buildTreeFolderItems(item.file, true);
			
			for(var index:int=0; index<array.length; index++){
				if((array[index] as TreeFolderItem).file.nativePath == libraryManager.systemFileDir.nativePath){
					array.splice(index, 1);
					break;
				}
			}
			
			for each(var temp:ITreeItem in array){
				temp.parent = item;
			}
			
			return array;
		}
		
		/**
		 * 指定されたディレクトリ下のディレクトリを表現するTreeFolderItemをArrayに格納して返します。
		 * 
		 * @param file
		 * @param onlyChildren
		 * @return 
		 * 
		 */
		private function buildTreeFolderItems(file:File, onlyChildren:Boolean):Array{
			
			var array:Array = new Array();
			
			if(!file.isDirectory){
				return array;
			}
			
			var files:Array = file.getDirectoryListing();
			
			for each(var file:File in files){
				if(!file.isDirectory){
					continue;
				}
				
				var item:TreeFolderItem = treeDataBuilder.getFolderObject(file.name);
				item.file = file;
				
				array.push(item);
				
				if(!onlyChildren){
					item.children = buildTreeFolderItems(file, false);
				}
			}
			
			return array;
			
		}
		
		
	}
}