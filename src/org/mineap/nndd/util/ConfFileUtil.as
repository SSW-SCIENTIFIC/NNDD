package org.mineap.nndd.util
{
	import flash.filesystem.File;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.util.config.ConfigManager;

	public class ConfFileUtil
	{
		public function ConfFileUtil()
		{
		}
		
		/**
		 * 設定ファイルが存在するかどうかチェックし、存在しない場合は古い設定ファイルの内容をコピーします。
		 * 古い設定ファイルが存在しない場合は何もしません。
		 * 
		 */
		public function checkExistAndCopy():void{
			
			var boolean:Boolean = ConfigManager.getInstance().reload();
			
			
			if(!boolean){
				// 設定ファイルが無い、もしくは読み込みに失敗
				
				// まずはバックアップファイルを探す
				var backUpFile:File = File.applicationStorageDirectory.resolvePath("config.xml.back");
				
				if(backUpFile.exists){
					
					// 設定ファイルをコピー
					LogManager.instance.addLog("設定をバックアップから復元しました。(" + backUpFile.nativePath + ")");
					
					// 全力で上書き
					backUpFile.copyTo(File.applicationStorageDirectory.resolvePath("config.xml"), true);
					
					// 新しい設定ファイルを読み込み
					ConfigManager.getInstance().reload();
					
					return;
				}
			}
			
			if(!boolean){
				// 設定ファイルがなくてバックアップファイルも無い
				
				// 古いバージョンの物が無いかどうか探す
				var file:File = null;
				
				try{
					file = searchOldVersionConfFile("NNDD");
				}catch(error:Error){
					trace(error.getStackTrace());
				}
				
				if(file == null){
					// 設定ファイルが無い。
					return;
				}
				
				// 設定ファイルをコピー
				LogManager.instance.addLog("旧バージョンの設定ファイルをコピーしました。(" + file.nativePath + ")");
				file.copyTo(File.applicationStorageDirectory.resolvePath("config.xml"));
				
				// 新しい設定ファイルを読み込み
				ConfigManager.getInstance().reload();
				
			}else{
				// 何もしない
			}
			
		}
		
		/**
		 * アプリケーションストレージディレクトリから、指定された文字列を含むフォルダを探し、
		 * そのなかから設定ファイルを探してその場所を示すFileオブジェクトを返します。
		 * 
		 * @param str
		 * @return 
		 * 
		 */
		public function searchOldVersionConfFile(str:String):File{
			
			str = str.toLowerCase();
			
			var appStorageDir:File = File.applicationStorageDirectory;
			
			var tempFile:File = new File();
			tempFile.nativePath = appStorageDir.nativePath;
			
			var array:Array = tempFile.parent.parent.getDirectoryListing();
			
			for each(var file:File in array){
				var name:String = file.name;
				
				if(name == null){
					continue;
				}
				
				if(name.length < str.length){
					continue;
				}
				
				if(name.substr(0, str.length).toLocaleLowerCase() == str){
					var confFile:File = file.resolvePath("Local Store").resolvePath("config.xml");
					if(confFile.exists){
						return confFile;
					}else{
						continue;
					}
				}
			}
			
			return null;
			
		}
	}
}