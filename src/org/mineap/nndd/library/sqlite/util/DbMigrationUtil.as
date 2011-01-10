package org.mineap.nndd.library.sqlite.util
{
	import flash.filesystem.File;
	
	import org.mineap.nndd.FileIO;
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.library.namedarray.LibraryXMLHelper;
	import org.mineap.nndd.library.sqlite.DbAccessHelper;
	import org.mineap.nndd.library.sqlite.SQLiteLibraryManager;
	import org.mineap.nndd.library.sqlite.dao.NNDDVideoDao;
	import org.mineap.nndd.model.NNDDVideo;

	public class DbMigrationUtil
	{
		
		private var _logger:LogManager = LogManager.instance;
		
		public function DbMigrationUtil()
		{
		}
		
		/**
		 * 
		 * 
		 */
		public function migrate():void{
			
			_logger.addLog("DBの情報をXMLにして書き出し中...");
			
			// テーブルの情報をXMLにして書き出し
			var file:File = export();
			
			_logger.addLog("DBの定義を構築中...");
			
			// テーブルをDropします
			DbAccessHelper.instance.dropTables();
			
			// テーブルをCreateします
			DbAccessHelper.instance.createTables();
			
			_logger.addLog("XMLの情報をDBに書き込み中...");
			
			// テーブル情報をXMLからインポート
			importFromXML(file);
			
			_logger.addLog("完了.");
			
		}
		
		/**
		 * NNDDVideoテーブルに関連するオブジェクトを全てフェッチして取り出した後、XMLにして保存します。
		 * 
		 * @return 保存したXMLファイルを示すFileオブジェクト
		 * 
		 */
		private function export():File{
			
			var nnddVideos:Vector.<NNDDVideo> = NNDDVideoDao.instance.selectAllNNDDVideo();
			
			// Vectorを連想配列に変換
			var map:Object = new Object();
			for each(var video:NNDDVideo in nnddVideos){
				map[video.key] = video;
			}
			
			// 連想配列からXMLに変換
			var xmlHelper:LibraryXMLHelper = new LibraryXMLHelper();
			var libraryXML:XML= xmlHelper.convert(map);
			
			// XMLを保存
			var fileIO:FileIO = new FileIO();
			var file:File = SQLiteLibraryManager.instance.libraryDir.resolvePath("library_back.xml");
			fileIO.saveXMLSync(file, libraryXML);
			
			return file;
		}
		
		/**
		 * 
		 * @param file
		 * 
		 */
		private function importFromXML(file:File):void{
			
			// XMLを読込み
			var fileIO:FileIO = new FileIO();
			var libraryXML:XML = fileIO.loadXMLSync(file.url, true);
			
			// XMLを連想配列に変換
			var xmlHelper:LibraryXMLHelper = new LibraryXMLHelper();
			var map:Object = xmlHelper.perseXML(libraryXML);
			
			// 連想配列内のNNDDVideoオブジェクトをDBに格納
			for each(var nnddVideo:NNDDVideo in map){
				NNDDVideoDao.instance.insertNNDDVideo(nnddVideo);
			}
			
		}
		
		
	}
}