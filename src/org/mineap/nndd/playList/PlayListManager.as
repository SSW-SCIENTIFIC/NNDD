package org.mineap.nndd.playList
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.media.Video;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.DataGrid;
	import mx.events.CloseEvent;
	
	import org.mineap.nndd.FileIO;
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.Message;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.model.PlayList;
	import org.mineap.nndd.util.DateUtil;
	import org.mineap.nndd.util.LibraryUtil;
	import org.mineap.nndd.util.PathMaker;

	/**
	 * プレイリストの管理を行うクラスです。
	 * 
	 * Copyright (c) 2008 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class PlayListManager
	{
		
		private static const playListManager:PlayListManager = new PlayListManager();
		
		private var playLists:Vector.<PlayList> = new Vector.<PlayList>();
		
		private var logManager:LogManager = LogManager.instance;
		private var libraryManager:ILibraryManager = LibraryManagerBuilder.instance.libraryManager;
		
		private var isPlayListSaveError:Boolean = false;
		
		public var isSelectedPlayList:Boolean = false;
		public var selectedPlayListIndex:int = -1;
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():PlayListManager{
			return playListManager;
		}
		
		/**
		 * 
		 * 
		 */
		public function PlayListManager(){
			if(playListManager != null){
				throw new ArgumentError("PlayListManagerはインスタンス化できません。");
			}
			
			this.logManager = logManager;
		}
		
		/**
		 * PlayListManagerを初期化します。
		 * 
		 */
		public function initialize():void
		{
			//TODO プレイリスト一覧の読み込み開始
			var dir:File = new File(libraryManager.playListDir.url);
			if(dir.exists){
//				readPlayListSummary(dir);
			}else{
				dir = libraryManager.libraryDir.resolvePath("playList/");
				try{
					dir.moveTo(libraryManager.playListDir);
				}catch(error:Error){
					trace(error);
				}
//				readPlayListSummary(libraryManager.playListDir);
//				saveAllPlayList();
			}
		}
		
		/**
		 * プレイリストの一覧を読込み、その一覧を返します。
		 * 読み込むファイルは拡張子がm3uのファイルです。
		 * 
		 * @param path プレイリストが保存されているディレクトリへのパス
		 * @return 
		 */
		public function readPlayListSummary(dir:File):Vector.<PlayList>{
			
			this.playLists = new Vector.<PlayList>();
			
			if(!dir.exists){
				return this.playLists;
			}
			
			try{
				
				var myPlayListArray:Array = dir.getDirectoryListing();
				
				//ディレクトリの項目一覧をプレイリストに追加
				var myIndex:int = 0;
				for each(var file:File in myPlayListArray){
					var extension:String = file.extension;
					
					if(extension != null && extension.toUpperCase() == "M3U"){
						
						var name:String = file.name;
						var videos:Vector.<NNDDVideo> = readPlayList(file.url, myIndex++);
						
						this.playLists.push(new PlayList(name, videos, false));
						
					}
				}
				
			}catch(error:Error){
				Alert.show("プレイリスト一覧の生成に失敗しました。\nパス:" + dir.nativePath + "\n"+error, "エラー");
				logManager.addLog("プレイリスト一覧の生成に失敗\nパス:" + dir.nativePath + "\n"+error);
			}
			
			
			return this.playLists;
		}
		
		/**
		 * 指定されたpathのファイルをプレイリストとして読込み、読み込んだ結果をVector.<NNDDVideo>に格納して返します。
		 * 
		 * @param path
		 * @param pIndex
		 * @return 
		 * 
		 */
		public function readPlayList(path:String, pIndex:int = -1):Vector.<NNDDVideo>{
			
			var videoArray:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			
			var fileIO:FileIO = new FileIO();
			
			try{
				logManager.addLog("プレイリストの読み込みを開始:Path=" + new File(path).nativePath);
				
				var str:String = null;
				str = fileIO.loadTextSync(path);
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			if(str == null){
				Alert.show("プレイリストの読み込みに失敗しました。\n" +
					"指定されたプレイリストが存在しません。\n" +
					"パス:" + path, Message.M_ERROR);
				logManager.addLog("プレイリストの読み込みに失敗(プレイリストが存在しない):" + path);
				return videoArray;
			}
			
			// ロードしたプレイリストファイルを解析
			videoArray = PlayListAnalyzer.analyze(str);
			
			return videoArray;
			
		}
		
		/**
		 * 指定されたindex番目にあるプレイリストを返します
		 *  
		 * @param index
		 * 
		 */
		public function getPlayList(index:int, isSave:Boolean = true):PlayList{
			
			if(index >= playLists.length){
				return null;
			}
			
			//今あるプレイリストを保存
			if(isSave){
				this.saveAllPlayList();
			}
			
			logManager.addLog("プレイリスト表示:" + playLists[index].name);
			
			return playLists[index];
		}
		
		/**
		 * 指定されたインデックスのプレイリストに項目を追加します。
		 * 
		 * @param pIndex プレイリストのインデックス
		 * @param nnddVideoArray 追加したいNNDDVideoオブジェクトの配列
		 * @param index プレイリストの何番目にURLを追加するかを指定するIndex
		 * 
		 */
		public function addNNDDVideos(pIndex:int, nnddVideoArray:Array, index:int = -1):void{
			if(playLists[pIndex] != null){
				if(index == -1){
					index = playLists[pIndex].items.length;
				}
				for each(var video:NNDDVideo in nnddVideoArray){
					this.playLists[pIndex].items.splice(index, 0, video);
					index++;
				}
			}
		}
		
		/**
		 * 新しいプレイリストを追加します。
		 * @param newName プレイリストの名前を指定します。指定しない場合は"新規プレイリスト"になります。
		 * @return 追加したプレイリストのファイル名を返します。
		 */
		public function addPlayList(newName:String = null):String{
			
			if(newName == null){
				newName = "新規プレイリスト"
			}
			var tempFileName:String = newName;
			for(var j:int=0;;j++){
				
				var playList:PlayList = isExist(tempFileName);
				
				if(playList != null){
					tempFileName = newName + (j+1);
				}else{
					break;
				}
			}

			var fileName:String = tempFileName + ".m3u";
			
			this.playLists.push(new PlayList(fileName));
			
			this.savePlayListByIndex(this.playLists.length - 1);
			
			return fileName;
		}
		
		/**
		 * 指定された名前のプレイリストが存在するかどか調べ、存在すれば返します。
		 * 
		 * @param 
		 * @param PlayList
		 * @return 
		 * 
		 */
		public function isExist(name:String):PlayList{
			
			if(name.toUpperCase().substring(name.length - 4) != ".M3U"){
				name = name + ".m3u";
			}
			
			for each(var tempPlayList:PlayList in this.playLists){
				if(tempPlayList.name == name){
					return tempPlayList;
				}
			}
			
			return null;
		}
		
		
		/**
		 * 指定されたプレイリストのitemIndex番目の項目をプレイリストから取り除きます。
		 * 
		 * @param pIndex
		 * @param itemIndex
		 * @return 
		 * 
		 */
		public function removePlayListItemByIndex(pIndex:int, itemIndices:Array):void{
			itemIndices.sort();
			for(var i:int = itemIndices.length-1; i>-1; i--){
				if(playLists[pIndex].items.length > itemIndices[i]){
					playLists[pIndex].items.splice(itemIndices[i], 1);
				}
			}
		}
		
		
		/**
		 * 指定されたプレイリストの名前を変更します。
		 * @param pIndex
		 * @param newName
		 * @return 
		 * 
		 */
		public function reNamePlayList(pIndex:int, newName:String):void{
			for each(var playList:PlayList in playLists){
				if(playList.name == newName){
					return;
				}
			}
			
			playLists[pIndex].name = newName;
			
			this.savePlayListByIndex(pIndex);
		}
		
		/**
		 * playListProviderのインデックスに該当するプレイリストをProviderから削除します。
		 * 同時に、ローカルディレクトリに存在するプレイリストファイルを削除します。
		 * 
		 * @param index
		 * 
		 */
		public function removePlayListByIndex(index:int):void{
			
			var url:String = libraryManager.playListDir.resolvePath( this.playLists[index].name ).url;
			
			var file:File = new File(url);
			if(file.exists){
				file.moveToTrash();
				logManager.addLog("ファイルを削除:" + file.nativePath);
			}
			playLists = playLists.splice(index, 1);
			
		}
		
		/**
		 * playListProviderのインデックスに該当するプレイリストの配列を返します。
		 * 
		 * @param index
		 * @return 
		 * 
		 */
		public function getUrlListByIndex(index:int):Array{
			
			var urlArray:Array = new Array();
			for each(var video:NNDDVideo in playLists[index].items){
				urlArray.push(video.getDecodeUrl());
			}
			
			return urlArray;
		}
		
		/**
		 * playListProviderのインデックスに該当するプレイリストの動画の一覧を返します。
		 * 
		 * @param index
		 * @return 
		 * 
		 */
		public function getNNDDVideoListByIndex(index:int):Vector.<NNDDVideo>{
			
			var nnddVideoArray:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			for each(var video:NNDDVideo in playLists[index].items){
				nnddVideoArray.splice(0, 0, video);
			}
			
			return nnddVideoArray;
		}
		
		/**
		 * playListProviderのインデックスに対応する動画の一覧を返します
		 * @param index
		 * @return 
		 * 
		 */
		public function getPlayListVideoListByIndex(index:int):Vector.<NNDDVideo>{
			return playLists[index].items;
		}
		
		/**
		 * playListProviderのインデックスに対応する動画名の一覧を返します
		 * @param index
		 * @return 
		 * 
		 */
		public function getPlayListVideoNameList(index:int):Array{
			var array:Array = new Array();
			
			for each(var video:NNDDVideo in playLists[index].items){
				array.push(video.getVideoNameWithVideoID());
			}
			
			return array;
		}
		
		/**
		 * プレイリストの名前を返します。この名前はプレイリストの純粋なファイル名です。
		 * @param index
		 * @return 
		 * 
		 */
		public function getPlayListNameByIndex(index:int):String{
			return playLists[index].name;
		}
		
		/**
		 * 指定された名前のプレイリストが存在するインデックスを返します。
		 * 
		 * @param name
		 * @return 指定された名前のプレイリストが存在する場合は、そのインデックス。存在しない場合は-1。
		 * 
		 */
		public function getPlayListIndexByName(name:String):int{
			for(var index:int=0; index<playLists.length; index++){
				if(playLists[index].name == name){
					return index;
				}
			}
			return -1;
		}
		
		/**
		 * 指定されたインデックスのプレイリストのフルパスを返します。
		 * @param pIndex
		 * @return 
		 * 
		 */
		private function getFullPath(pIndex:int):String{
			var file:File = new File(libraryManager.playListDir.url);
			file.url += "/" + playLists[pIndex].name;
			
			return file.url;
		}
		
		/**
		 * プレイリストを保存します。
		 * @param pIndex
		 * 
		 */
		public function savePlayListByIndex(pIndex:int):Boolean{
			
			var fileIO:FileIO = new FileIO();
			
			try{
				var filePath:String = getFullPath(pIndex);
				fileIO.savePlayList(filePath, playLists[pIndex].items);
				fileIO.closeFileStream();
				logManager.addLog("プレイリストを保存:" + new File(getFullPath(pIndex)).nativePath);
				return true;
			}catch(error:Error){
				fileIO.closeFileStream();
				if(isPlayListSaveError){
					isPlayListSaveError = true;
					Alert.show("プレイリストの保存に失敗しました。\n" + error, "エラー", 4, null, function():void{isPlayListSaveError = false;});
					logManager.addLog("プレイリストの保存に失敗:" + new File(getFullPath(pIndex)).nativePath + "\n" + error);
				}
			}
			return false;
		}
		
		/**
		 * 指定された名前のプレイリストを、渡されたPlayListの内容で上書きします。
		 * 
		 * @param name
		 * @param videos
		 * @return 
		 * 
		 */
		public function updatePlayList(name:String, videos:Vector.<NNDDVideo>):Boolean{
			
			var index:int = getPlayListIndexByName(name);
			
			var videoArray:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			
			for each(var video:NNDDVideo in videos){
				
				var videoId:String = LibraryUtil.getVideoKey(video.getDecodeUrl());
				var tempVideo:NNDDVideo = libraryManager.isExist(videoId);
				
				if(tempVideo != null){
					video = tempVideo;
				}
				
				videoArray.push(video);
				
			}
			
			playLists[index].items = videoArray;
			
			var fileIO:FileIO = new FileIO();
			
			try{
				var filePath:String = libraryManager.playListDir.url  + "/" + name;
				
				fileIO.savePlayList(filePath, playLists[index].items);
				fileIO.closeFileStream();
				logManager.addLog("プレイリストを保存:" + new File(libraryManager.playListDir.url + "/" + name).nativePath);
				return true;
			}catch(error:Error){
				fileIO.closeFileStream();
				if(isPlayListSaveError){
					isPlayListSaveError = true;
					Alert.show("プレイリストの保存に失敗しました。\n" + error, "エラー", 4, null, function():void{isPlayListSaveError = false;});
					logManager.addLog("プレイリストの保存に失敗:" + libraryManager.playListDir.url + "/" + name + "\n" + error);
				}
			}
			return false;
		}
		
		/**
		 * プレイリストの名前の一覧を返します
		 * @return 
		 * 
		 */
		public function getPlayListNames():Array{
			
			var array:Array = new Array();
			for each(var playList:PlayList in playLists){
				array.push(playList.name);
			}
			
			return array;
		}
		
		/**
		 * すべてのプレイリストを保存します。
		 * 
		 */
		public function saveAllPlayList():Boolean{
			logManager.addLog("***すべてのプレイリストを保存***")
			var isSuccess:Boolean = true;
			for(var i:int=0; i<playLists.length; i++){
				if(!savePlayListByIndex(i)){
					isSuccess = false;
				}
			}
			logManager.addLog("***プレイリストを保存終了***")
			return isSuccess;
		}
		
	}
}