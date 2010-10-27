package org.mineap.nndd.library
{
	import flash.filesystem.File;
	
	import mx.logging.Log;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.model.VideoType;

	public class LibraryDirSearchUtil
	{
		private var _logger:LogManager;
		
		public function LibraryDirSearchUtil()
		{
			this._logger = LogManager.instance;
		}
		
		/**
		 * 指定されたディレクトリを更新します。
		 * 
		 * @param dir 更新対象ディレクトリ
		 * @param renewSubDir サブディレクトリを更新するかどうか
		 * 
		 */
		public function renewDir(dir:File, renewSubDir:Boolean):Array{
			
			if(!dir.isDirectory){
				// ディレクトリじゃなければ見に行かない
				return new Array();
			}
			
			if(dir.nativePath == LibraryManagerBuilder.instance.libraryManager.systemFileDir.nativePath){
				// systemディレクトリ下は見に行かない
				return new Array();
			}
			
			var fileList:Array = dir.getDirectoryListing();
			
			var videoList:Array = new Array();
			
			for(var index:uint = 0; index<fileList.length;index++){
				try{
					if(renewSubDir && fileList[index].isDirectory){	// サブディレクトリを探索
						var array:Array = renewDir((fileList[index] as File), true);
						
						for each(var obj:Object in array){
							videoList.push(obj);
						}
						
					}else if(!fileList[index].isDirectory){	// このファイルが動画かどうかチェック
						
						var extension:String = (fileList[index] as File).extension;
						if(extension != null){	// 拡張子が無い場合はスキップ
							extension = extension.toUpperCase();
							if(extension == VideoType.FLV_L || extension == VideoType.MP4_L){
								
								videoList.push(fileList[index].url);
								
							}else if(extension == VideoType.SWF_L){
								if((fileList[index] as File).nativePath.indexOf(VideoType.NICOWARI) == -1){
									videoList.push(fileList[index].url);
								}
							}
						}
					}
				}catch(error:Error){
					_logger.addLog("次のフォルダ・ディレクトリを更新できませんでした:" + (fileList[index] as File).nativePath + ":" + error);
					trace(error.getStackTrace());
				}
			}
			
			return videoList;
		}
		
	}
}