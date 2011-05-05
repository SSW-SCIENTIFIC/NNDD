package org.mineap.nndd.search
{
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	import org.mineap.nndd.FileIO;
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.model.SearchItem;
	import org.mineap.nndd.model.SearchSortString;
	import org.mineap.nndd.util.TreeDataBuilder;
	import org.mineap.nicovideo4as.model.SearchSortType;
	import org.mineap.nicovideo4as.model.SearchType;

	/**
	 * SearchItemManager.as<br>
	 * SaerchItemManagerクラスは、検索条件を管理します。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class SearchItemManager
	{
		
		/**
		 * デフォルトの検索項目です
		 */
		public static const DEF_SEARCH_ITEMS:Array = new Array(
			new SearchItem("#音楽", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "音楽"),
			new SearchItem("#エンターテイメント", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "エンターテイメント"),
			new SearchItem("#アニメ", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "アニメ"),
			new SearchItem("#ゲーム", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "ゲーム"),
			new SearchItem("#ラジオ", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "ラジオ"),
			new SearchItem("#スポーツ", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "スポーツ"),
			new SearchItem("#科学", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "科学"),
			new SearchItem("#料理", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "料理"),
			new SearchItem("#政治", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "政治"),
			new SearchItem("#動物", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "動物"),
			new SearchItem("#歴史", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "歴史"),
			new SearchItem("#自然", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "自然"),
			new SearchItem("#ニコニコ動画講座", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "ニコニコ動画講座"),
			new SearchItem("#演奏してみた", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "演奏してみた"),
			new SearchItem("#歌ってみた", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "歌ってみた"),
			new SearchItem("#踊ってみた", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "踊ってみた"),
			new SearchItem("#投稿者コメント", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "投稿者コメント"),
			new SearchItem("#日記", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "日記"),
			new SearchItem("#アンケート", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "アンケート"),
			new SearchItem("#チャット", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "チャット"),
			new SearchItem("#テスト", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "テスト"),
			new SearchItem("#ニコニ・コモンズ", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "ニコニ・コモンズ"),
			new SearchItem("#ひとこと動画", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "ひとこと動画"),
			new SearchItem("#その他", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "その他"),
			new SearchItem("#R-18", SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, "R-18")
		);
		
		/**
		 * ライブラリマネージャーです。
		 */
		private var _libraryManager:ILibraryManager;
		
		/**
		 * 画面上の検索条件のリストのデータプロバイダーです
		 */
		private var _searchItemProvider:Array;
		
		/**
		 * 画面上の検索条件のリストに対応するSearchItemのリストです
		 */
		private var _searchItemMap:Object;
		
		/**
		 * 
		 */
		private var _logManager:LogManager;
		
		/**
		 * コンストラクタ
		 * @param searchItemProvider
		 * @param logManager
		 * 
		 */
		public function SearchItemManager(searchItemProvider:Array, logManager:LogManager)
		{
			this._libraryManager = LibraryManagerBuilder.instance.libraryManager;;
			this._searchItemMap = new Object();
			this._searchItemProvider = searchItemProvider;
			this._logManager = logManager;
		}
		
		/**
		 * 指定されたserachItemで、oldNameの検索項目を置き換えます。
		 * @param searchItem 上書きするsearchItem
		 * @param isDir ディレクトリかどうか
		 * @param isSave 
		 * @param oldName
		 * @param children
		 * @return 
		 * 
		 */
		public function updateMyList(searchItem:SearchItem, isDir:Boolean, isSave:Boolean, oldName:String, children:Array = null):Object{
			
			var object:Object = searchByName(oldName, this._searchItemProvider);
			
			delete this._searchItemMap[oldName];
			
			var builder:TreeDataBuilder = new TreeDataBuilder();
			var folder:Object = builder.getFolderObject(searchItem.name);
			
			object.label = searchItem.name;
			if(children != null){
				object.children = children;
			}
			
			this._searchItemMap[searchItem.name] = searchItem;
			
			if(isSave){
				this.saveSearchItems(this._libraryManager.systemFileDir);
			}
			
			return object;
		}
		
		/**
		 * 検索条件を追加します。同名の検索条件は追加できません。
		 * @param searchItem 追加する検索条件
		 * @param searchItemName 検索条件名
		 * @param isDir ディレクトリかどうか
		 * @param isSave 保存するかどうか
		 * @param index 追加するインデックス。-1の時は最後に追加。
		 * @param children ディレクトリを追加した際に同時に追加する子。
		 * 
		 */
		public function addSearchItem(searchItem:SearchItem, isDir:Boolean, isSave:Boolean, index:int = -1, children:Array = null):Object{
			var exsits:Boolean = false;
			var item:SearchItem = this._searchItemMap[searchItem.name];
			var addedTreeObject:Object = null;
			
			if(item != null){
				exsits = true;
			}
			
			if(!exsits){
				
				var builder:TreeDataBuilder = new TreeDataBuilder();
				
				if(isDir){
					
					var folder:Object = builder.getFolderObject(searchItem.name);
					if(children != null){
						folder.children = children;
					}
					
					if(index == -1){
						this._searchItemProvider.push(folder);
						this._searchItemMap[searchItem.name] = searchItem;
					}else{
						this._searchItemProvider.splice(index, 0, folder);
						this._searchItemMap[searchItem.name] = searchItem;
					}
					
					addedTreeObject = folder;
					
				}else{
					
					var file:Object = builder.getFileObject(searchItem.name);
					
					if(index == -1){
						this._searchItemProvider.push(file);
						this._searchItemMap[searchItem.name] = searchItem;
					}else{
						this._searchItemProvider.splice(index, 0, file);
						this._searchItemMap[searchItem.name] = searchItem;
					}
					
					addedTreeObject = file;
					
				}
				
				if(isSave){
					this.saveSearchItems(this._libraryManager.systemFileDir);
				}
				
				return addedTreeObject;
			}else{
				return null;
			}
		}
		
		/**
		 * 
		 * @param name
		 * @return 
		 * 
		 */
		public function search(name:String):Object{
			return searchByName(name, this._searchItemProvider);
		}
		
		/**
		 * 
		 * @param searchItemName
		 * @return 
		 * 
		 */
		public function searchByName(searchItemName:String, array:Array):Object{
			for(var index:int = 0; index<array.length; index++){
				
				var object:Object = array[index];
				if(object.hasOwnProperty("children")){
					
					if(object.label == searchItemName){
						return object;
					}else{
						//フォルダのなかの項目かもしれない。探す。
						var tempObject:Object = searchByName(searchItemName, object.children);
						if(tempObject != null){
							return tempObject;
						}
					}
				}else{
					//ファイル
					if(object.label == searchItemName){
						return object;
					}
				}
				
			}
			return null;
		}
		
		/**
		 * 
		 * @param searchItemName
		 * @return 
		 * 
		 */
		public function isExsits(searchItemName:String):Boolean{
			
			var object:Object = this._searchItemMap[searchItemName];
			if(object != null){
				return true;
			}
			return false;
		}
		
		/**
		 * 検索条件を削除します。
		 * @param searchItemName
		 * @return 削除したTreeの項目
		 * 
		 */
		public function removeSearchItem(searchItemName:String, isSave:Boolean):Object{
			var deleteObject:Object = deleteSearchItemFromTree(searchItemName, this._searchItemProvider);
			if(deleteObject != null){
				delete this._searchItemMap[searchItemName];
				if(isSave){
					this.saveSearchItems(this._libraryManager.systemFileDir);
				}
				return deleteObject;
			}
			return null;
		}
		
		/**
		 * 
		 * @param searchItemName
		 * @param searchItemArray
		 * @return 
		 * 
		 */
		public function deleteSearchItemFromTree(searchItemName:String, searchItemArray:Array):Object{
			for(var index:int = 0; index<searchItemArray.length; index++){
				
				var object:Object = searchItemArray[index];
				if(object.hasOwnProperty("children") && object.children != null){
					
					if(object.label == searchItemName){
						//フォルダそのものを消す
						return searchItemArray.splice(index, 1)[0];
												
					}else{
						//フォルダのなかの項目かもしれない。探す。
						var deleteObject:Object = deleteSearchItemFromTree(searchItemName, object.children);
						if(deleteObject != null){
							return deleteObject;
						}
					}
				}else{
					//ファイル
					if(object.label == searchItemName){
						
						return searchItemArray.splice(index, 1)[0];
						
					}
				}
					
			}
			return null;
		}
		
		
		/**
		 * 
		 * @param searchItemName
		 * @return 
		 * 
		 */
		public function getSearchItem(searchItemName:String):SearchItem{
			return this._searchItemMap[searchItemName];
		}
		
		/**
		 * デフォルトの検索項目をトップに追加します。
		 * 
		 */
		public function addDefSearchItems():void{
			
			var addCount:int = 0;
			
			for each(var searchItem:SearchItem in DEF_SEARCH_ITEMS){
				
				if(addSearchItem(searchItem, false, false, addCount)){
					addCount++;
				}
				
			}
			
		}
		
		/**
		 * 
		 * @param xml
		 * @param searchItemArray
		 * @param searchItemMap
		 * 
		 */
		public function addSearchItemFromXML(xml:XML, searchItemArray:Array, searchItemMap:Object):void{
			for each(var temp:XML in xml.children()){
				
				var name:String = decodeURIComponent(String(temp.@name));
				var searchItem:SearchItem = null;
				
				var builder:TreeDataBuilder = new TreeDataBuilder();
				
				if(temp.@isDir != null && temp.@isDir != undefined && temp.@isDir == "true"){
					//ディレクトリの時
					var folder:Object = builder.getFolderObject(name);
					
					searchItem = new SearchItem(name, 
						SearchSortString.convertSortTypeFromIndex(4), 	// コメントが新しい順
						SearchType.KEY_WORD, "", true);
					
					if(temp.children().length() > 0){
						addSearchItemFromXML(temp, folder.children, searchItemMap);
					}
					
					searchItemArray.push(folder);
					searchItemMap[name] = searchItem;
					
				}else{
					var sortType:int = 0;
					if(temp.@sortType == null || temp.@sortType == undefined || temp.@sortType == "" ){
						sortType = int(temp.sortType);
					}else{
						sortType = int(temp.@sortType);
					}
					var searchType:int = 0;
					if(temp.@searchType == null || temp.@searchType == undefined || temp.@searchType == "" ){
						searchType = int(temp.searchType);
					}else{
						searchType = int(temp.@searchType);
					}
					var searchWord:String = null;
					if(temp.@searchWord == null || temp.@searchWord == undefined || temp.@searchWord == "" ){
						searchWord = decodeURIComponent(String(temp.searchWord));
					}else{
						searchWord = decodeURIComponent(String(temp.@searchWord));
					}
					
					var file:Object = builder.getFileObject(name);
					
					searchItem = new SearchItem(name, SearchSortString.convertSortTypeFromIndex(sortType), 
						searchType, searchWord);
					searchItemArray.push(file);
					searchItemMap[searchItem.name] = searchItem;
				}
			}
		}
		
		/**
		 * 検索条件ファイルを読み出します。
		 * @param dir
		 * 
		 */
		public function readSearchItems(dir:File):Boolean{
			
			try{
				
				var saveFile:File = new File(dir.url + "/searchItems.xml");
				
				if(saveFile.exists){
					var fileIO:FileIO = new FileIO(this._logManager);
					var xml:XML = fileIO.loadXMLSync(saveFile.url, true);
				
					addSearchItemFromXML(xml, this._searchItemProvider, this._searchItemMap);
					
					this._logManager.addLog("検索条件の読み込み完了:" + saveFile.nativePath);
					
					return true;
					
				}else{
					this._logManager.addLog("検索条件ファイルが存在しません:" + saveFile.nativePath);
					
					return false;
				}
				
			}catch(error:Error){
				Alert.show("検索条件ファイルの読み込みに失敗しました:" + dir.url + "/searchItems.xml" + "\n" + error);
				this._logManager.addLog("検索条件ファイルの読み込みに失敗" + dir.url + "/searchItems.xml" + "\n" + error + ":" + error.getStackTrace());
			}
			return false;
		}
		
		/**
		 * 
		 * @param saveXML
		 * @param searchItemArray
		 * @param searchItemMap
		 * @return 
		 * 
		 */
		public function addSearchItemToXML(saveXML:XML, searchItemArray:Array, searchItemMap:Object):XML{
			
			for(var i:int = 0; i<searchItemArray.length; i++){
				
				var searchItem:SearchItem = searchItemMap[searchItemArray[i].label];
				var xml:XML = <searchItem/>;
				
				if(searchItem != null){
					
					if(searchItem.isDir){
						xml.@name = encodeURIComponent(searchItem.name);
						xml.@searchWord = "";
						xml.@isDir = true;
						
						var array:Array = searchItemArray[i].children;
						if(array != null && array.length >= 1){
							xml = addSearchItemToXML(xml, array, searchItemMap);
						}
					}else{
						var name:String = searchItemArray[i].label;
						xml.@name = encodeURIComponent(searchItemMap[name].name);
						xml.@sortType = SearchSortString.convertTextArrayIndexFromSearchSortType(searchItemMap[name].sortType);
						xml.@searchType = searchItemMap[name].searchType;
						xml.@searchWord = encodeURIComponent(searchItemMap[name].searchWord);
						xml.@isDir = false;
					}
					saveXML.appendChild(xml);
					
				}
			}
			
			return saveXML;
		}
		
		/**
		 * 検索条件ファイルを保存します。
		 * @param dir 保存先ディレクトリ
		 * 
		 */
		public function saveSearchItems(dir:File):void{
			
			try{
				var saveFile:File = new File(dir.url + "/searchItems.xml");
				
				var saveXML:XML = <searchItems/>;
				saveXML = addSearchItemToXML(saveXML, this._searchItemProvider, this._searchItemMap);
				
				var fileIO:FileIO = new FileIO(this._logManager);
				fileIO.saveXMLSync(saveFile, saveXML);
				
				this._logManager.addLog("検索条件を保存:" + saveFile.nativePath);
				
			}catch(error:Error){
				Alert.show("検索条件ファイルの保存に失敗しました:" + dir.url + "/searchItems.xml" + "\n" + error);
				this._logManager.addLog("検索条件ファイルの保存に失敗" + dir.url + "/searchItems.xml" + "\n" + error + ":" + error.getStackTrace());
			}
			
		}
		
	}
}