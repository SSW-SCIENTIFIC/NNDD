package org.mineap.nndd.myList
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	import org.mineap.nicovideo4as.util.HtmlUtil;
	import org.mineap.nndd.FileIO;
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.Message;
	import org.mineap.nndd.NNDDMyListLoader;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.model.MyListSortType;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.util.MyListUtil;
	import org.mineap.nndd.util.PathMaker;
	import org.mineap.nndd.util.TreeDataBuilder;
	import org.mineap.util.config.ConfUtil;

	/**
	 * MyListManager.as<br>
	 * MyListManagerクラスは、マイリストを管理するクラスです。<br>
	 * <br>
	 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class MyListManager extends EventDispatcher
	{
		
		public static const MYLIST_RENEW_COMPLETE:String = "MylistRenewComplete";
		
		/**
		 * マイリストのMapです
		 */
		private var _myListMap:Object = new Object();
		
		/**
		 * 
		 */
		private var _libraryManager:ILibraryManager;
		
		/**
		 * 
		 */
		private var _tree_MyList:Array;
		
		/**
		 * 
		 */
		private var _logManager:LogManager;
		
		/**
		 * 
		 */
		private var _nnddMyListLoader:NNDDMyListLoader = null;
		
		/**
		 * 
		 */
		private var _myListGroupLoader:NNDDMyListGroupLoader;
		
		/**
		 * 
		 */
		public var lastTitle:String = "";
		
		/**
		 * 唯一のMyListManagerのインスタンス
		 */
		private static const _myListManager:MyListManager = new MyListManager();
		
		/**
		 * コンストラクタ
		 * 
		 */
		public function MyListManager()
		{
			if(_myListManager != null){
				throw new ArgumentError("MyListManagerはインスタンス化できません");
			}
		}
		
		/**
		 * シングルトンパターン
		 * @return 
		 * 
		 */
		public static function get instance():MyListManager{
			return MyListManager._myListManager;
		}
		
		/**
		 * 
		 * @param tree_myList
		 * 
		 */
		public function initialize(tree_myList:Array):void{
			this._tree_MyList = tree_myList;
			
			this._libraryManager = LibraryManagerBuilder.instance.libraryManager;
			this._logManager = LogManager.instance;
			
		}
		
		/**
		 * マイリストを上書きします。
		 * 
		 * @param myListUrl マイリストのURL
		 * @param myListName マイリストの名前
		 * @param isDir ディレクトリかどうか
		 * @param isSave 上書き後保存するかどうか
		 * @param oldName マイリストの古い名前
		 * @param children 上書き対象のマイリストの子供(対象のマイリストがディレクトリの際に指定する)
		 * @return 上書きしたマイリストに対応するツリー表示用のオブジェクト
		 * 
		 */
		public function updateMyList(myListUrl:String, myListName:String, isDir:Boolean, isSave:Boolean, oldName:String, children:Array = null):Object{
			
			var myList:MyList = new MyList(myListUrl, myListName, isDir);
			var object:Object = searchByName(oldName, this._tree_MyList);
			
			delete this._myListMap[oldName];
			
			var builder:TreeDataBuilder = new TreeDataBuilder();
			var folder:Object = builder.getFolderObject(myListName);
			
			object.label = myListName;
			if(children != null){
				object.children = children;
			}
			
			this._myListMap[myListName] = myList;
			
			if(isSave){
				this.saveMyListSummary(this._libraryManager.systemFileDir);
			}
			
			return object;
		}
		
		/**
		 * 
		 * @param name 指定された名前の項目をマイリストのツリーから探して返します。
		 * @return 
		 * 
		 */
		public function search(name:String):Object{
			return searchByName(name, this._tree_MyList);
		}
		
		/**
		 * 指定された名前を持つオブジェクト(Leaf)を、渡されたオブジェクト(tree)の中から探します。
		 * 
		 * @param myListName 探したいLeafの名前
		 * @param array 探す対象のtree
		 * @return 
		 * 
		 */
		public function searchByName(myListName:String, array:Array):Object{
			for(var index:int = 0; index<array.length; index++){
				
				var object:Object = array[index];
				if(object.hasOwnProperty("children")){
					
					if(object.label == myListName){
						return object;
					}else{
						//フォルダのなかの項目かもしれない。探す。
						var tempObject:Object = searchByName(myListName, object.children);
						if(tempObject != null){
							return tempObject;
						}
					}
				}else{
					//ファイル
					if(object.label == myListName){
						return object;
					}
				}
				
			}
			return null;
		}
		
		
		/**
		 * マイリストを追加します。同名のマイリスト名は追加できません。
		 * 
		 * @param myListUrl
		 * @param myListName
		 * @param isDir
		 * @param isSave
		 * @param index
		 * @param children ディレクトリを追加した際に同時に追加する子。
		 * @return 
		 * 
		 */
		public function addMyList(myListUrl:String, myListName:String, isDir:Boolean, isSave:Boolean, index:int = -1, children:Array = null):Object{
			var exsits:Boolean = false;
			var myList:MyList = new MyList(myListUrl, myListName, isDir);
			var addedTreeObject:Object = null;
			
			if(this._myListMap[myListName] != null){
				exsits = true;
			}
			
			if(!exsits){
				
				var builder:TreeDataBuilder = new TreeDataBuilder();
				
				if(isDir){
					
					var folder:Object = builder.getFolderObject(myListName);
					if(children != null){
						folder.children = children;
					}
					
					if(index == -1){
						this._tree_MyList.push(folder);
						this._myListMap[myListName] = myList;
					}else{
						this._tree_MyList.splice(index, 0, folder);
						this._myListMap[myListName] = myList;
					}
					
					addedTreeObject = folder;
					
				}else{
					
					var file:Object = builder.getFileObject(myListName);
					
					if(index == -1){
						this._tree_MyList.push(file);
						this._myListMap[myListName] = myList;
					}else{
						this._tree_MyList.splice(index, 0, file);
						this._myListMap[myListName] = myList;
					}
					
					addedTreeObject = file;
					
				}
				
				if(isSave){
					this.saveMyListSummary(this._libraryManager.systemFileDir);
				}
				
				return addedTreeObject;
			}else{
				return null;
			}
			
		}
		
		
		/**
		 * 指定された名前のマイリストが存在するかどうかを返します。
		 * @param myListName
		 * @return 
		 * 
		 */
		public function isExsits(myListName:String):Boolean{
			
			var object:Object = this._myListMap[myListName];
			if(object != null){
				return true;
			}
			return false;
		}
		
		/**
		 * マイリストを削除します。
		 * 
		 * @param myListName
		 * @return 
		 * 
		 */
		public function removeMyList(myListName:String, isSave:Boolean):Object{
			var deletedObject:Object = deleteMyListItemFromTree(myListName, this._tree_MyList);
			if(deletedObject != null){
				if(isSave){
					this.saveMyListSummary(this._libraryManager.systemFileDir);
				}
				delete this._myListMap[myListName];
				return deletedObject;
			}
			return null;
		}
		
		/**
		 * 指定されたTreeのデータプロバイダであるArrayからmyListNameを探して削除します。
		 * @param myListName
		 * @param myListArray
		 * @return 
		 * 
		 */
		public function deleteMyListItemFromTree(myListName:String, myListArray:Array):Object{
			for(var index:int = 0; index<myListArray.length; index++){
				
				var object:Object = myListArray[index];
				if(object.hasOwnProperty("children") && object.children != null ){
					
					if(object.label == myListName){
						//フォルダそのものを消す
						return myListArray.splice(index, 1)[0];
						
					}else{
						//フォルダのなかの項目かもしれない。探す。
						var deleteObject:Object = deleteMyListItemFromTree(myListName, object.children);
						if(deleteObject != null){
							return deleteObject;
						}
					}
				}else{
					//ファイル
					if(object.label == myListName){
						
						return myListArray.splice(index, 1)[0];
					}
				}
					
			}
			return null;
		}
		
		/**
		 * URLを返します。ただし、http://〜で始まるとは限りません。マイリストの番号である可能性もあります。
		 * @param myListName
		 * @return 
		 * 
		 */
		public function getUrl(myListName:String):String{
			var myList:MyList = MyList(this._myListMap[myListName]);
			if(myList == null || myList.isDir){
				return "";
			}
			return myList.myListUrl;
		}
		
		/**
		 * マイリストのタイトルを返します。
		 * @param index
		 * @return 
		 * 
		 */
		public function getMyListName(index:int):String{
			var object:Object = this._tree_MyList[index];
			if(object.hasOwnProperty("children")){
				return this._tree_MyList[index].label;
			}else{
				return this._tree_MyList[index];
			}
		}
		
		/**
		 * 指定されたマイリストがディレクトリかどうかを返します。
		 * 
		 * @param myListName
		 * @return 
		 * 
		 */
		public function getMyListIdDir(myListName:String):Boolean{
			var myList:MyList = this._myListMap[myListName];
			if(myList == null){
				return false;
			}
			
			return myList.isDir;
		}
		
		/**
		 * 
		 * @param myListName
		 * @return 
		 * 
		 */
		public function getMyListUnPlayVideoCount(myListName:String):int{
			var myList:MyList = this._myListMap[myListName];
			if(myList == null){
				return 0;
			}
			
			return myList.unPlayVideoCount;
		}
		
		/**
		 * 
		 * @param xml
		 * @param myListArray
		 * @param myListMap
		 * 
		 */
		public function addMyListItemFromXML(xml:XML, myListArray:Array, myListMap:Object):void{
			
			for each(var temp:XML in xml.children()){
				
				var name:String = decodeURIComponent(String(temp.@name));
				var myList:MyList = null;
				
				var builder:TreeDataBuilder = new TreeDataBuilder();
				
				if(temp.@isDir != null && temp.@isDir != undefined && temp.@isDir == "true"){
					//ディレクトリの時。
					
					var folder:Object = builder.getFolderObject(name);
					
					myList = new MyList("", name, true);
					myListArray.push(folder);
					myListMap[name] = myList;
					
					if(temp.children().length() > 0){
						addMyListItemFromXML(temp, folder.children, myListMap); 
					}
				}else{
					var url:String = decodeURIComponent(String(temp.@url));
					if(url == null || url == ""){
						url = decodeURIComponent(String(temp.text()));
					}
					
					var file:Object = builder.getFileObject(name);
					file.unPlayVideoCount = MyListManager.instance.getMyListUnPlayVideoCount(name);
					
					myList = new MyList(url, name);
					myListArray.push(file);
					myListMap[name] = myList;
				}
			}
					
		}
		
		/**
		 * 
		 * @param dir
		 * 
		 */
		public function readMyListSummary(dir:File = null):Boolean{
			
			if(dir == null){
				dir = this._libraryManager.systemFileDir;
			}
			
			var saveFile:File = new File(dir.url + "/myLists.xml");
			
			if(saveFile.exists){
				
				var fileIO:FileIO = new FileIO(LogManager.instance);
				var xml:XML = fileIO.loadXMLSync(saveFile.url, true);
				
				_tree_MyList.splice(0, _tree_MyList.length);
				_myListMap = new Object();
				
				addMyListItemFromXML(xml, _tree_MyList, _myListMap);
				
				_logManager.addLog("マイリスト一覧の読み込み完了:" + saveFile.nativePath);
				
				initScheduler();
				
				return true;
				
			}else{
				_logManager.addLog("マイリスト一覧が存在しません:" + saveFile.nativePath);
				
				return false;
			}
		}
		
		/**
		 * マイリストのソート状態を保存します。
		 * 
		 * @param myListName
		 * @param myListSortType
		 * 
		 */
		public function setMyListSortType(myListName:String, myListSortType:MyListSortType):void{
			
			var file:File = new File(LibraryManagerBuilder.instance.libraryManager.systemFileDir.url + "/myLists.xml");
			
			if(file.exists){
				var fileIO:FileIO = new FileIO(LogManager.instance);
				var xml:XML = fileIO.loadXMLSync(file.url, true);
				
				var xmlList:XMLList = xml.children();
				var myList:XML = searchXMLFromMyListXML(xmlList, myListName);
				
				if(myList != null){
					myList.@sortFiledName = decodeURIComponent(myListSortType.sortFiledName);
					myList.@sortFiledDescending = myListSortType.sortFiledDescending;
					
					fileIO.saveXMLSync(file, xml);
				}
			}
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		private function searchXMLFromMyListXML(xmlList:XMLList, targetName:String):XML
		{
			for each(var myList:XML in xmlList){
				
				if("true" == myList.@isDir){
					var xml:XML = searchXMLFromMyListXML(myList.children(), targetName);
					if(xml != null){
						return xml;
					}
						
				}else{
					if(decodeURIComponent(myList.@name) == targetName){
						return myList;
					}
				}
			}
			return null;
		}
		
		
		/**
		 * 
		 * @param myListName
		 * @return 
		 * 
		 */
		public function getMyListSortType(myListName:String):MyListSortType{
			
			var file:File = LibraryManagerBuilder.instance.libraryManager.systemFileDir.resolvePath("myLists.xml");
			
			var name:String = null;
			var descending:Boolean = false;
			
			if(file.exists){
				var fileIO:FileIO = new FileIO(LogManager.instance);
				var xml:XML = fileIO.loadXMLSync(file.url, true);
				
				var xmls:XMLList = xml.children();
				
				var sortType:MyListSortType = seachSortTypeFromXML(xmls, myListName);
				
				if(sortType != null){
					name = sortType.sortFiledName;
					descending = sortType.sortFiledDescending;
				}
			}
			
			return new MyListSortType(name, descending);
		}
		
		/**
		 * 引数で指定されたXMLListから、targetNameで指定された名称のMyListSortTypeを探して返します。
		 * 
		 * @param xmlList
		 * @param targetName
		 * @return 
		 * 
		 */
		private function seachSortTypeFromXML(xmlList:XMLList, targetName:String):MyListSortType
		{
			for each(var myList:XML in xmlList){
				
				if("true" == myList.@isDir){
					var subList:XMLList = myList.children();
					var sortType:MyListSortType = seachSortTypeFromXML(subList, targetName);
					
					if(sortType != null){
						return sortType;
					}
					
				}else{
					
					var tempName:String = null;
					try{
						tempName = decodeURIComponent(myList.@name);
					}catch(error:Error){
						tempName = myList.@name;
					}
					
					if(tempName == targetName){
						var name:String = myList.@sortFiledName;
						var descending:Boolean = ConfUtil.parseBoolean(myList.@sortFiledDescending.toString());
						return new MyListSortType(name, descending);
					}
				}
			}
			
			return null;
		}
		
		/**
		 * 
		 * 
		 */
		public function initScheduler():void{
			
			MyListRenewScheduler.instance.myListReset();
			
			for each(var myList:MyList in this._myListMap){
				var id:String = MyListUtil.getMyListId(myList.myListUrl);
				
				MyListRenewScheduler.instance.addMyListId(id);
			}
		}
		
		
		/**
		 * 渡されたXMLに渡されたマイリスト名順にマイリストを追加します。
		 * 
		 * @param xml
		 * @param myListNameArray
		 * @param myListMap
		 * @return 
		 * 
		 */
		public function addMyListItemToXML(xml:XML, myListNameArray:Array, myListMap:Object):XML{
			
			for(var i:int = 0; i<myListNameArray.length; i++){
				
				var myList:MyList = myListMap[myListNameArray[i].label];
				var myListItem:XML = <myList/>;
				
				if(myList != null){
					
					var myListSortType:MyListSortType = getMyListSortType(myList.myListName);
					
					if(myList.isDir){
						
						//ディレクトリの時
						myList = myListMap[myListNameArray[i].label];
						
						myListItem.@url = "";
						myListItem.@name = encodeURIComponent(myList.myListName);
						myListItem.@isDir = true;
						
						if(myListSortType.sortFiledName != null){
							myListItem.@sortFiledName = encodeURIComponent(myListSortType.sortFiledName);
							myListItem.@sortFiledDescending = myListSortType.sortFiledDescending;
						}
						
						var array:Array = myListNameArray[i].children;
						if(array != null && array.length >= 1){
							myListItem = addMyListItemToXML(myListItem, array, myListMap);
						}
						
					}else{
						
						myListItem.@url = encodeURIComponent(myList.myListUrl);
						myListItem.@name = encodeURIComponent(myList.myListName);
						myListItem.@isDir = false;
						
						if(myListSortType.sortFiledName != null){
							myListItem.@sortFiledName = encodeURIComponent(myListSortType.sortFiledName);
							myListItem.@sortFiledDescending = myListSortType.sortFiledDescending;
						}
					}
					
					
					xml.appendChild(myListItem);
				}
			}
			
			return xml;
		}
		
		
		/**
		 * 
		 * @param dir
		 * 
		 */
		public function saveMyListSummary(dir:File):void{
			
			var xml:XML = <myLists/>;
			xml = addMyListItemToXML(xml, this._tree_MyList, this._myListMap);
			
			var saveFile:File = new File(dir.url + "/myLists.xml");
			
			var fileIO:FileIO = new FileIO(_logManager);
			fileIO.addFileStreamEventListener(Event.COMPLETE, function(event:Event):void{
				_logManager.addLog("マイリスト一覧を保存:" + dir.nativePath);
				trace(event);
				dispatchEvent(event);
			});
			fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				_logManager.addLog("マイリスト一覧の保存に失敗:" + dir.nativePath + ":" + event);
				trace(event + ":" + dir.nativePath);
				dispatchEvent(event);
			});
			fileIO.saveXMLSync(saveFile, xml);
			
		}
		
		/**
		 * 指定されたxmlをマイリストとして保存します。
		 * 
		 * @param myListId
		 * @param xml
		 * 
		 */
		public function saveMyList(myListId:String, xml:XML):void{
			
			try{
			
				var file:File = this._libraryManager.systemFileDir;
				
				var vector:Vector.<String> = null;
				
				file = new File(file.url + "/myList/" + myListId + ".xml");
				
				if(file.exists){
					//既存のXMLがあるときは再生済み項目を抽出
					var tempXML:XML = readLocalMyList(myListId);
					vector = searchPlayedItem(tempXML);
					
					//再生済み項目を新規XMLに反映
					xml = setPlayed(vector, xml);
					
				}
				
				var fileIO:FileIO = new FileIO(_logManager);
				fileIO.addFileStreamEventListener(Event.COMPLETE, function(event:Event):void{
					_logManager.addLog("マイリストを保存:" + file.nativePath);
					trace(event);
				});
				fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
					_logManager.addLog("マイリストの保存に失敗:" + file.nativePath + ":" + event);
					trace(event + ":" + file.nativePath);
				});
				fileIO.saveXMLSync(file, xml);
				
			}catch(error:Error){
				_logManager.addLog("マイリストの保存に失敗:" + error + ":" + error.getStackTrace());
				trace(error.getStackTrace());
			}
			
		}
		
		/**
		 * ローカルに保存されているマイリストを読み込みます
		 * 
		 * @param myListId
		 * @return 
		 * 
		 */
		public function readLocalMyList(myListId:String):XML{
			
			try{
				
				var file:File = this._libraryManager.systemFileDir;
				
				file = new File(file.url + "/myList/" + myListId + ".xml");
				
				var fileIO:FileIO = new FileIO(_logManager);
				fileIO.addFileStreamEventListener(Event.COMPLETE, function(event:Event):void{
					_logManager.addLog("マイリストの読み込み:" + file.nativePath);
					trace(event);
				});
				fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
					_logManager.addLog("マイリストの保存に失敗:" + file.nativePath + ":" + event);
					trace(event + ":" + file.nativePath);
				});
				var xml:XML = fileIO.loadXMLSync(file.url, true);
				
				return xml;
				
			}catch(error:Error){
				_logManager.addLog("マイリストの保存に失敗:" + error + ":" + error.getStackTrace());
				trace(error.getStackTrace());
			}
			
			return null;
			
		}
		
		/**
		 * 指定されたディレクトリ下のマイリスト(XML)の一覧を取得します。
		 * 
		 * @param file
		 * 
		 */
		public function readFromSubDirMyList(name:String):Vector.<XML>{
			var vector:Vector.<XML> = new Vector.<XML>();
 			
			var leaf:Object = searchByName(name, this._tree_MyList);
			if(leaf == null){
				return vector;
			}
			
			if(leaf.hasOwnProperty("children")){
				// これはフォルダ
				var children:Array = leaf.children;
				for each(var tempObject:Object in children){
					
					var tempVector:Vector.<XML> = readFromSubDirMyList(tempObject.label);
					for each(var tempXML:XML in tempVector){
						vector.splice(0,0, tempXML);
					}
					
				}
			
			}else{
				//これはファイル
				var myList:MyList = this._myListMap[leaf.label];
				
				var xml:XML = this.readLocalMyList(myList.myListId);
				
				vector.splice(0,0,xml);
				
			}
			
			return vector;
		}
		
		/**
		 * 指定されたマイリストの、指定された動画の項目を既読に設定します
		 * @param myListId
		 * @param videoIds
		 * 
		 */
		public function setPlayedAndSave(myListId:String, videoIds:Vector.<String>):void{
			
			var xml:XML = readLocalMyList(myListId);
			
			if(xml != null){
				
				xml = setPlayed(videoIds, xml);
				saveMyList(myListId, xml);
				
				var str:String = "";
				for each(var videoId:String in videoIds){
					str += (videoId + ", ");
				}
				
				_logManager.addLog(videoId + "を既読に設定(mylist/" + myListId + ")" );
				
			}
			
		}
		
		/**
		 * ローカルのプレイリストを読み込み、既読判定を行ったNNDDVideoを格納するVectorを返します。
		 * 
		 * @param myListId
		 * @return 
		 * 
		 */
		public function readLocalMyListByNNDDVideo(myListId:String):Vector.<NNDDVideo>{
			
			var videoArray:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			
			var xml:XML = readLocalMyList(myListId);
			
			if(xml != null){
				var xmlList:XMLList = xml.child("channel");
				
				xmlList = xmlList.child("item");
				for each(var tempXML:XML in xmlList){
					var link:String = decodeURIComponent(tempXML.link);
					var title:String = tempXML.title;
					try{
						title = HtmlUtil.convertSpecialCharacterNotIncludedString(title);
						title = decodeURIComponent(unescape(title));
					}catch(error:Error){
						trace("デコード前の名前を使用:" + title);
						trace(error.getStackTrace());
					}
					var played:String = tempXML.played;
					if(link != null && title != null){
						
						var nnddVideo:NNDDVideo = new NNDDVideo(link, title);
						
						if(played != null && played == "true"){
							nnddVideo.yetReading = true;
						}
						
						videoArray.splice(0,0,nnddVideo);
						
					}
				}
				
			}
			
			return videoArray;
			
		}
		
		
		/**
		 * XML無いから指定されたvideoIdの項目を探し、既読に設定します。
		 * 
		 * @param videoId
		 * @param xml
		 * @return 
		 * 
		 */
		private function setPlayed(videoIds:Vector.<String>, xml:XML):XML{
			
			if(xml != null){
				
				var videoIdMap:Object = new Object();
				for each(var videoId:String in videoIds){
					videoIdMap[videoId] = videoId;
				}
				
				var xmlList:XMLList = xml.child("channel");
				
				xmlList = xmlList.child("item");
				
				for each(var tempXML:XML in xmlList){
					var link:String = tempXML.link;
					if(link != null){
						var tempVideoId:String = PathMaker.getVideoID(link);
						if(videoIdMap[tempVideoId] != null){
							delete videoIdMap[tempVideoId];
							var list:XMLList = tempXML.played;
							if(list != null && list.length() > 0){
								// 既読に設定済
							}else{
								tempXML.appendChild(new XML("<played>true</played>"));
							}
							
//							trace("発見:" + videoId);
							
						}
					}
				}
				
//				trace("見つからなかった");
				
			}
			
			return xml;
		}
		
		/**
		 * 渡されたXMLから既読項目(<played>要素がtrueの動画ID)を探します
		 * 
		 * @param xml
		 * @return 
		 * 
		 */
		private function searchPlayedItem(xml:XML):Vector.<String>{
			
			var videoIds:Vector.<String> = new Vector.<String>();
			
			if(xml != null){
				
				var xmlList:XMLList = xml.child("channel");
				
				xmlList = xmlList.child("item");
				
				for each(var tempXML:XML in xmlList){
					var items:XMLList = tempXML.played;
					try{
						if(items != null && items.length() > 0 ){
							if((items[0] as XML).text().toString() == "true"){
								videoIds.splice(-1, 0, PathMaker.getVideoID(tempXML.link));
							}
						}
					}catch(error:Error){
						trace(error.getStackTrace());
					}
				}
			}
			
			return videoIds;
		}
		
		/**
		 * 指定されたXMLから未視聴の動画を探し、未視聴の動画IDの一覧をVector.<String>に格納して返します。
		 * 
		 * @param xml
		 * @return 
		 * 
		 */
		private function searchUnPlaydItem(xml:XML):Vector.<String>{
			var videoIds:Vector.<String> = new Vector.<String>();
			
			if(xml != null){
				
				var xmlList:XMLList = xml.child("channel");
				
				xmlList = xmlList.child("item");
				
				for each(var tempXML:XML in xmlList){
					var items:XMLList = tempXML.played;
					try{
						if(items == null || (items != null && items.length() == 0) ){
							
							var videoId:String = PathMaker.getVideoID(tempXML.link);
							if(this._libraryManager.isExistByVideoId(videoId) == null){
								videoIds.push(videoId);
							}
						}
					}catch(error:Error){
						trace(error.getStackTrace());
					}
				}
			}
			
			return videoIds;
		}
		
		/**
		 * ローカルに保存されているすべてのマイリストについて、
		 * 未視聴の動画の数をカウントし、その数を返します。
		 * 
		 * @return 
		 * 
		 */
		public function countUnPlayVideosFromAll():int{
			
			var count:int = 0;
			
			for each(var myList:MyList in this._myListMap){
				var myListId:String = MyListUtil.getMyListId(myList.myListUrl);
				if(myListId != null){
					var myCount:int = countUnPlayVideos(myListId);
					myList.unPlayVideoCount = myCount;
					count += myCount;
				}
			}
			
			return count;
		}
		
		/**
		 * 指定されたマイリストの未再生の動画の数を数えて返します。
		 * 
		 * @param myListId
		 * @return 
		 * 
		 */
		public function countUnPlayVideos(myListId:String):int{
			
			var xml:XML = readLocalMyList(myListId);
			
			if(xml != null){
				var vector:Vector.<String> = searchUnPlaydItem(xml);
				return vector.length;
			}else{
				return 0;
			}
			
		}
		
		/**
		 * 
		 * @param mailAddress
		 * @param password
		 * 
		 */
		public function renewMyListIds(mailAddress:String, password:String):void{
			
			if(this._myListGroupLoader != null){
				this._myListGroupLoader.close();
				this._myListGroupLoader = null;
			}
			
			this._myListGroupLoader = new NNDDMyListGroupLoader();
			
			this._myListGroupLoader.addEventListener(NNDDMyListGroupLoader.SUCCESS, function(event:Event):void{
				for each(var str:String in _myListGroupLoader.myListIds){
					
					var myList:MyList = MyListManager.instance.getMyList(str);
					if(myList == null){
						myList = new MyList("myListId/" + str, "あなたのマイリスト(" + str + ")", false);
						MyListManager.instance.addMyList(myList.myListUrl, myList.myListName, myList.isDir, true);
					}
					trace(str);
				}
				dispatchEvent(new Event(MYLIST_RENEW_COMPLETE));
				Alert.show("マイリストを追加しました", Message.M_MESSAGE);
				_myListGroupLoader.close();
				_myListGroupLoader = null;
			});
			this._myListGroupLoader.addEventListener(NNDDMyListGroupLoader.FAILURE, function(event:Event):void{
				_myListGroupLoader.close();
				_myListGroupLoader = null;
				Alert.show("マイリスト一覧の更新に失敗\n" + event, Message.M_ERROR);
				dispatchEvent(new Event(MYLIST_RENEW_COMPLETE));
			});
			
			this._myListGroupLoader.getMyListGroup(mailAddress, password);
		}
		
		/**
		 * 
		 * @param myListId
		 * @return 
		 * 
		 */
		public function getMyList(myListId:String):MyList{
			return this._myListMap[myListId];
		}
		
	}
}