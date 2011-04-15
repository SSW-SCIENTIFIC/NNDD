package org.mineap.nndd.library
{
	import flash.events.IEventDispatcher;
	import flash.filesystem.File;
	
	import org.mineap.nndd.model.NNDDVideo;

	public interface ILibraryManager extends IEventDispatcher
	{
		
		/**
		 * 
		 * @return ライブラリファイル
		 * 
		 */
		function get libraryFile():File;
		
		/**
		 * 
		 * @return ライブラリディレクトリ
		 * 
		 */
		function get libraryDir():File;
		
		/**
		 * 
		 * @return デフォルトのライブラリディレクトリ
		 * 
		 */
		function get defaultLibraryDir():File;
		
		/**
		 * 
		 * @return システムディレクトリ
		 * 
		 */
		function get systemFileDir():File;
		
		/**
		 * 
		 * @return テンポラリディレクトリ
		 * 
		 */
		function get tempDir():File;
		
		/**
		 * 
		 * @return プレイリストディレクトリ
		 * 
		 */
		function get playListDir():File;
		
		/**
		 * ライブラリファイルの保存先をアプリケーションディレクトリにするかどうか指定します
		 * 
		 */
		function set useAppDirLibFile(value:Boolean):void;
		
		/**
		 * ライブラリディレクトリを変更します
		 * @param libraryDir
		 * @param isSave
		 * @return 
		 * 
		 */
		function changeLibraryDir(libraryDir:File, isSave:Boolean = true):Boolean;
		
		/**
		 * メモリ上のライブラリを保存します
		 * @param saveDir
		 * @return 
		 * 
		 */
		function saveLibrary(saveDir:File = null):Boolean;
		
		/**
		 * ライブラリをメモリ上にロードします
		 * @param libraryDir
		 * @return 
		 * 
		 */
		function loadLibrary(libraryDir:File = null):Boolean;
		
		/**
		 * 指定されたディレクトリ下の動画を元にライブラリを再構築します
		 * @param libraryDir
		 * @param renewSubDir
		 * @return 
		 * 
		 */
		function renewLibrary(libraryDir:File, renewSubDir:Boolean):void;
		
		/**
		 * ライブラリから動画情報を削除します
		 * @param videoId
		 * @param isSaveLibrary
		 * @return 
		 * 
		 */
		function remove(videoId:String, isSaveLibrary:Boolean):NNDDVideo;
		
		/**
		 * ライブラリ内の該当する動画情報を更新します
		 * @param video
		 * @param isSaveLibrary
		 * @return 
		 * 
		 */
		function update(video:NNDDVideo, isSaveLibrary:Boolean):Boolean;
		
		/**
		 * ライブラリに動画情報を追加します
		 * @param video
		 * @param isSaveLibrary
		 * @param isOverWrite
		 * @return 
		 * 
		 */
		function add(video:NNDDVideo, isSaveLibrary:Boolean, isOverWrite:Boolean = false):Boolean;
		
		/**
		 * ディレクトリ構成を変更します
		 * @param oldDir
		 * @param newDir
		 * 
		 */
		function changeDirName(oldDir:File, newDir:File):void;
		
		/**
		 * 指定された動画IDの動画がライブラリ内に存在するかどうか調べます。
		 * @param videoId
		 * @return 
		 * 
		 */
		function isExistByVideoId(videoId:String):NNDDVideo;
		
		/**
		 * 指定されたキーの動画がライブラリ内に存在するかどうか調べます。
		 * @param key
		 * @return 
		 * 
		 */
		function isExist(key:String):NNDDVideo;
		
		/**
		 * タグの一覧を取得します
		 * @param dir
		 * @return 
		 * 
		 */
		function collectTag(dir:File = null):Array;
		
		/**
		 * 指定された動画の名前から、それらの動画に関係のあるタグの一覧を取得します
		 * @param nameArray
		 * @return 
		 * 
		 */
		function collectTagByVideoName(nameArray:Array):Array;
		
		/**
		 * wordで指定された単語を含むタグの一覧を返します
		 * @param word
		 * @return 
		 * 
		 */
		function searchTagAndShow(word:String):Array;
		
		/**
		 * 指定されたディレクトリ下にある動画情報の一覧を返します。
		 * @param saveDir
		 * @param isShowAll
		 * @return 
		 * 
		 */
		function getNNDDVideoArray(saveDir:File, isShowAll:Boolean):Vector.<NNDDVideo>;
		
	}
	
}