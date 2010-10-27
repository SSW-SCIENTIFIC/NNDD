package org.mineap.nndd.tag
{
	import flash.filesystem.File;
	
	import mx.controls.TileList;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.model.NNDDVideo;
	
	/**
	 *
	 * TagManager.as
	 * 
	 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */
	public class TagManager
	{
		
		public var tagProvider:Array;
		public var tagMap:Object = new Object();
		public var tempTagArray:Array;
		private var libraryManager:ILibraryManager;
		private var logManager:LogManager;
		
		private static const _tagManager:TagManager = new TagManager();
		
		/**
		 * シングルトンパターン
		 */
		public function TagManager()
		{
			if(_tagManager != null){
				throw new ArgumentError("TagManagerはインスタンス化できません。");
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():TagManager{
			return _tagManager;
		}
		
		/**
		 * 
		 * @param dataProvider
		 * @return 
		 * 
		 */
		public function initialize(dataProvider:Array):void{
			this.libraryManager = LibraryManagerBuilder.instance.libraryManager;
			this.tagProvider = dataProvider;
			this.logManager = LogManager.instance;
		}
		
		/**
		 * 
		 * 
		 */
		public function loadTag():void{
			
			var array:Array = libraryManager.collectTag();
			for(var i:int=0; i<array.length; i++){
				if(isAddEnable(array[i])){
					tagProvider.push(array[i]);
					tagMap[String(array[i])] = String(array[i]);
				}
			}
			
			tagProvider.sort();
			tagProvider.unshift("すべて");
			
			logManager.addLog("ローカルのタグ情報を表示(すべて):" + tagProvider.length);
		}
		
		/**
		 * タグが既にMapに存在するかどうか調べます。
		 * @param tag
		 * @return 
		 * 
		 */
		public function isExist(tag:String):Boolean{
			if(tagMap[tag] != null){
				return true;
			}
			return false;
		}
		
		/**
		 * タグが追加可能かどうかを返します。
		 * フィルタリストに追加されているか、既にタグ一覧に追加されている場合はfalseを返し、それ以外の場合はtrueを返します。
		 * @param tag
		 * @return 
		 * 
		 */
		public function isAddEnable(tag:String):Boolean{
			if(!isExist(tag) && !NgTagManager.instance.isExist(tag)){
				return true;
			}
			return false;
		}
		
		/**
		 * 指定されたディレクトリに対応するタグを取得し、表示します。
		 * ディレクトリを指定しない場合はすべてのタグを取得して表示します。
		 * @param dir
		 * 
		 */
		public function tagRenew(tileList:TileList, dir:File = null):void{
			
			if(tileList == null){
				return;
			}
			
			tagProvider.splice(0, tagProvider.length);
			tagMap = new Object();
			
			if(dir == null){
				loadTag();
				
			}else{
				var array:Array = libraryManager.collectTag(dir);
				
				for(var i:int=0; i<array.length; i++){
					if(isAddEnable(array[i])){
						tagProvider.push(array[i]);
						tagMap[String(array[i])] = String(array[i]);
					}
				}
				
				tagProvider.sort();
				tagProvider.unshift("すべて");
				
				logManager.addLog("ローカルのタグ情報を表示(ディレクトリ指定):" + dir.nativePath + ":" + tagProvider.length);
			}
			
			tileList.dataProvider = tagProvider;
		}
		
		/**
		 * プレイリストが指定された際のタグリストを更新します。
		 * @param tileList
		 * @param playList
		 * 
		 */
		public function tagRenewOnPlayList(tileList:TileList, videoArray:Vector.<NNDDVideo>):void{
			tagProvider.splice(0, tagProvider.length);
			tagMap = new Object();
			
			var videoNameArray:Array = new Array();
			for each(var video:NNDDVideo in videoArray){
				videoNameArray.push(video.getVideoNameWithVideoID());
			}
			
			var array:Array = libraryManager.collectTagByVideoName(videoNameArray);
			for(var i:int=0; i<array.length; i++){
				if(isAddEnable(array[i])){
					tagProvider.push(array[i]);
					tagMap[String(array[i])] = String(array[i]);
				}
			}
			
			tagProvider.sort();
			tagProvider.unshift("すべて");
			
			logManager.addLog("プレイリストのタグ情報を表示:" + tagProvider.length);
			
			tileList.dataProvider = tagProvider;
		}
		
		
		/**
		 * タグ表示用のTileListを更新します。
		 * @param words
		 * @return 
		 * 
		 */
		public function searchTagByWords(words:Array):Array{
			
			if(words.length > 0){
				
				var newTagProvider:Array = new Array();
				for(var i:int = 0; i < tagProvider.length; i++ ){
					var existCount:int = 0;
					var tag:String = tagProvider[i];
					tag = tag.toUpperCase();
					for(var j:int = 0; j<words.length; j++){
						
						var tempWord:String = words[j];
						tempWord = tempWord.toUpperCase();
						
						if(j < 1){
							if(tag.indexOf(tempWord) != -1){
								existCount++;
							}
						}else if(tempWord != " "){
							tempWord = tempWord.substring(1).toUpperCase();
							if(tag.indexOf(tempWord) != -1){
								existCount++;
							}
						}else{
							existCount++;
						}
					}
					if(existCount >= words.length){
						//発見した項目を追加
						newTagProvider.push(tagProvider[i]);
					}
				}
				
				newTagProvider.sort();
				
				return newTagProvider;
				
			}else{
				return tagProvider;
			}
		}
		

	}
}