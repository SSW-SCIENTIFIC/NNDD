/**
 * NNDD.as
 * ニコニコ動画からのダウンロードを処理およびその他のGUI関連処理を行う。
 * 
 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
 * 
 */

import flash.data.EncryptedLocalStore;
import flash.desktop.Clipboard;
import flash.desktop.ClipboardFormats;
import flash.desktop.NativeApplication;
import flash.desktop.NativeDragActions;
import flash.desktop.NativeDragManager;
import flash.display.NativeMenu;
import flash.display.NativeMenuItem;
import flash.errors.EOFError;
import flash.events.ContextMenuEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IOErrorEvent;
import flash.events.InvokeEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.NativeDragEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestDefaults;
import flash.net.URLVariables;
import flash.net.navigateToURL;
import flash.system.Capabilities;
import flash.text.Font;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;
import flash.ui.Keyboard;
import flash.ui.Mouse;
import flash.utils.ByteArray;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.containers.Canvas;
import mx.controls.Alert;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.DataGrid;
import mx.controls.FileSystemComboBox;
import mx.controls.FileSystemEnumerationMode;
import mx.controls.Label;
import mx.controls.TextInput;
import mx.controls.TileList;
import mx.controls.Tree;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.dataGridClasses.DataGridItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.sliderClasses.Slider;
import mx.controls.treeClasses.TreeItemRenderer;
import mx.core.Application;
import mx.core.ClassFactory;
import mx.core.IUIComponent;
import mx.core.UITextField;
import mx.events.AIREvent;
import mx.events.CloseEvent;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.FlexNativeWindowBoundsEvent;
import mx.events.IndexChangedEvent;
import mx.events.ListEvent;
import mx.events.ResizeEvent;
import mx.events.SliderEvent;
import mx.events.TreeEvent;
import mx.managers.DragManager;
import mx.managers.FocusManager;
import mx.managers.PopUpManager;

import org.mineap.nicovideo4as.*;
import org.mineap.nicovideo4as.model.*;
import org.mineap.nicovideo4as.util.HtmlUtil;
import org.mineap.nndd.*;
import org.mineap.nndd.Access2Nico;
import org.mineap.nndd.LogManager;
import org.mineap.nndd.Message;
import org.mineap.nndd.RenewDownloadManager;
import org.mineap.nndd.SystemTrayIconManager;
import org.mineap.nndd.download.DownloadManager;
import org.mineap.nndd.download.ScheduleManager;
import org.mineap.nndd.downloadedList.DownloadedListManager;
import org.mineap.nndd.event.LibraryLoadEvent;
import org.mineap.nndd.event.MyListRenewProgressEvent;
import org.mineap.nndd.history.HistoryManager;
import org.mineap.nndd.library.ILibraryManager;
import org.mineap.nndd.library.LibraryManagerBuilder;
import org.mineap.nndd.library.LibraryTreeBuilder;
import org.mineap.nndd.library.LocalVideoInfoLoader;
import org.mineap.nndd.library.namedarray.NamedArrayLibraryManager;
import org.mineap.nndd.library.sqlite.SQLiteLibraryManager;
import org.mineap.nndd.model.*;
import org.mineap.nndd.model.tree.ITreeItem;
import org.mineap.nndd.model.tree.TreeFileItem;
import org.mineap.nndd.model.tree.TreeFolderItem;
import org.mineap.nndd.myList.MyListBuilder;
import org.mineap.nndd.myList.MyListManager;
import org.mineap.nndd.myList.MyListRenewScheduler;
import org.mineap.nndd.myList.MyListTreeItemRenderer;
import org.mineap.nndd.nativeProcessPlayer.NativeProcessPlayerManager;
import org.mineap.nndd.playList.PlayListDataGridBuilder;
import org.mineap.nndd.playList.PlayListManager;
import org.mineap.nndd.player.PlayerController;
import org.mineap.nndd.search.SearchItemManager;
import org.mineap.nndd.tag.NgTagManager;
import org.mineap.nndd.tag.TagManager;
import org.mineap.nndd.user.UserManager;
import org.mineap.nndd.util.*;
import org.mineap.nndd.versionCheck.VersionChecker;
import org.mineap.nndd.versionCheck.VersionCheckerFactory;
import org.mineap.nndd.versionCheck.VersionUtil;
import org.mineap.nndd.view.LoadingPicture;
import org.mineap.util.config.ConfUtil;
import org.mineap.util.config.ConfigManager;
import org.mineap.util.font.FontUtil;

private var nndd:NNDD;
private var downloadedListManager:DownloadedListManager;
private var playListManager:PlayListManager;
private var libraryManager:ILibraryManager;
private var tagManager:TagManager;
private var ngTagManager:NgTagManager;
private var playerController:PlayerController;
private var logManager:LogManager;
private var loading:LoadingPicture;
private var downloadManager:DownloadManager;
private var scheduleManager:ScheduleManager;
private var historyManager:HistoryManager;

private var renewDownloadManager:RenewDownloadManager;
private var a2nForRanking:Access2Nico;
private var a2nForSearch:Access2Nico;

private var _nnddMyListLoader:NNDDMyListLoader;
private var _myListManager:MyListManager;
private var _searchItemManager:SearchItemManager;
private var _myListAdder:NNDDMyListAdder;

private var loginDialog:LoginDialog;
private var loadingWindow:LoadWindow;

private var _libraryDir:File;
private var _selectedLibraryFile:File;

private var playingVideoPath:String;

public static const RANKING_AND_SERACH_TAB_NUM:int = 0;
public static const SEARCH_TAB_NUM:int = 1
public static const MYLIST_TAB_NUM:int = 2;
public static const DOWNLOAD_LIST_TAB_NUM:int = 3;
public static const LIBRARY_LIST_TAB_NUM:int = 4;
public static const HISTORY_LIST_TAB_NUM:int = 5;
public static const OPTION_TAB_NUM:int = 6;

public var version:String = "";

private var MAILADDRESS:String = "";
private var PASSWORD:String = "";

private var logString:String = "";

//private var urlList:Array = new Array();
private var categoryList:Array = new Array();
private var searchPageLinkList:Array = new Array();

private var isVersionCheckEnable:Boolean = true;

private var isUseDownloadDir:Boolean = false;

private var isFirstTimePlayerActiveEvent:Boolean = true;

private var isRankingRenewAtStart:Boolean = false;

private var rankingPageIndex:int = 0;
private var searchPageIndex:int = 0;

private var lastRect:Rectangle = new Rectangle();
private var lastCanvasPlaylistHight:int = -1;
private var lastCanvasTagTileListHight:int = -1;

private var isArgumentBoot:Boolean = false;
private var argumentURL:String = "";

private var isAutoLogin:Boolean = false;

private var isSayHappyNewYear:Boolean = false;

private var isAutoDownload:Boolean = true;

private var isRankingWatching:Boolean = true;

private var isEnableEcoCheck:Boolean = true;

private var isShowOnlyNowLibraryTag:Boolean = true;

private var isOutStreamingPlayerUse:Boolean = false;

private var isDoubleClickOnStreaming:Boolean = true;

private var libraryDataGridSortFieldName:String = "";

private var libraryDataGridSortDescending:Boolean = false;

private var isEnableLibrary:Boolean = true;

private var isCtrlKeyPush:Boolean = false;

private var isAddedDefSearchItems:Boolean = false;

private var _exitProcessCompleted:Boolean = false;

private var isAlwaysEconomy:Boolean = false;

private var isDisEnableAutoExit:Boolean = false;

private var isAppendComment:Boolean = false;

private var mylistRenewOnScheduleEnable:Boolean = true;

private var selectedMyListFolder:Boolean = false;

private var isSaveSearchHistory:Boolean = true;

private var saveCommentMaxCount:Number = 10000;

private var textInput_url_foculsIn:Boolean = false;

private var showAll:Boolean = false;

private var isEnableNativePlayer:Boolean = false;

private var useAppDirLibFile:Boolean = false;

private var period:int = 0;
private var target:int = 0;

private var lastTagWidth:int = -1;

private var lastCategoryListWidth:int = -1;
private var lastMyListSummaryWidth:int = -1;
private var lastMyListHeight:int = -1;
private var lastLibraryWidth:int = -1;
private var lastSearchItemListWidth:int = -1;

private var thumbImageSize:Number = -1;
private var thumbImgSizeForSearch:Number = -1;
private var thumbImgSizeForMyList:Number = -1;
private var thumbImgSizeForDLList:Number = -1;
private var thumbImgSizeForLibrary:Number = -1;
private var thumbImgSizeHistory:Number = -1;

private var myListRenewScheduleTime:Number = 30;

private var loadWindow:LoadWindow = null;

[Bindable]
private var rankingProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var searchProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var downloadedProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var categoryListProvider:Array = new Array();
[Bindable]
private var searchSortListProvider:Array = SearchSortString.NICO_SEARCH_SORT_TEXT_ARRAY;
[Bindable]
private var myListItemProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var myListProvider:Array = new Array();
[Bindable]
private var rankingPageCountProvider:Array = new Array();
[Bindable]
private var searchListProvider:Array = new Array();
[Bindable]
private var searchPageCountProvider:Array = new Array();
[Bindable]
private var serchTypeProvider:Array = SearchTypeString.NICO_SEARCH_TYPE_TEXT;
[Bindable]
private var downloadProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var tagProvider:Array = new Array();
[Bindable]
private var ngTagProvider:Array = new Array();
[Bindable]
private var historyProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var myListRenewScheduleTimeProvider:Array = MyListRenewScheduler.MyListRenewScheduleTimeArray;
[Bindable]
private var myListStatusProvider:String = new String();
[Bindable]
private var fontDataProvider:Array = new Array();
[Bindable]
private var searchHistoryProvider:Array = new Array();
[Bindalbe]
private var fontSizeDataProvider:Array = new Array("小","中","大");

/**
 * イニシャライザです。<br>
 * 当クラスのインスタンスを使って、以下のクラスを初期化します。<br>
 * ・LoginDialogクラスのオブジェクト<br>
 * ・PlayerControllerクラスのオブジェクト<br>
 * ・DownloadedListManagerクラスのオブジェクト<br>
 * @param nndd
 * 
 */
public function initNNDD(nndd:NNDD):void
{
	
	// 設定ファイルをコピー
	var confFileUtil:ConfFileUtil = new ConfFileUtil();
	confFileUtil.checkExistAndCopy();
	
	
	/*デフォルト設定はSQLite*/
	var libraryType:String = LibraryManagerBuilder.LIBRARY_TYPE_SQL;
	var confType:String = ConfigManager.getInstance().getItem("libraryType");
	if(confType != null){
		if(confType == LibraryManagerBuilder.LIBRARY_TYPE_SQL){
			/* 設定でSQLが指定されていればSQLライブラリ */
			libraryType = LibraryManagerBuilder.LIBRARY_TYPE_SQL;
		}else if(confType == LibraryManagerBuilder.LIBRARY_TYPE_NAMED_ARRAY){
			/* 設定でNamedArrayが指定されていれば連想配列 */
			libraryType = LibraryManagerBuilder.LIBRARY_TYPE_NAMED_ARRAY;
		}
	}
	LibraryManagerBuilder.instance.libraryType = libraryType;
	this.libraryManager = LibraryManagerBuilder.instance.libraryManager;
	
	/*クラスインスタンスの初期化*/
	this.nndd = nndd;
	
	this.version = VersionUtil.instance.versionNumber;
	
	this.title =  "NNDD - v" + VersionUtil.instance.versionLabel;
	
	URLRequestDefaults.userAgent = URLRequestDefaults.userAgent + " NNDD/" + this.version;
	
	NativeApplication.nativeApplication.addEventListener(Event.EXITING, exitingEventHandler);
	
	/* ロガー */
	LogManager.instance.initialize(textArea_log);
	logManager = LogManager.instance;
	
	/* ストアの内容をまとめて呼び出し */
	readStore();
	
	/* バージョンチェック */
//	VersionChecker.instance.init(this.isVersionCheckEnable);
	VersionCheckerFactory.create().init(this.isVersionCheckEnable);
	
//	var startDate:Date = new Date(2009, 0, 1);
//	var lastDate:Date = new Date(2009, 0, 4);
//	var nowDate:Date = new Date();
//	if(nowDate.getTime() > startDate.getTime() && nowDate.getTime() < lastDate.getTime() && !isSayHappyNewYear){
//		Alert.show("あけましておめでとうございます！\n新年も皆様がニコニコできますように！");
//		isSayHappyNewYear = true;
//	}
	
	/* タグマネージャー */
	this.tagManager = TagManager.instance;
	this.tagManager.initialize(tagProvider);
	
	this.ngTagManager = NgTagManager.instance;
	this.ngTagManager.initialize(ngTagProvider);
	
	/* ライブラリマネージャー生成 */
//	this.libraryManager = LibraryManagerBuilder.instance.libraryManager;
	
	//動画の保存先ディレクトリはあるか？(保存先ディレクトリは存在するか？)
	if(!_libraryDir.exists){
		
		// デフォルトに戻す
		Alert.show(Message.M_LIBRARY_FILE_NOT_FOUND + this._libraryDir.nativePath, Message.M_ERROR);
		this._libraryDir = libraryManager.defaultLibraryDir;
		
	}
	
	
	//アプリケーションディレクトリのライブラリを使う準備
	this.libraryManager.useAppDirLibFile = this.useAppDirLibFile;
	if(true == this.useAppDirLibFile){
		//アプリケーションディレクトリを使う場合
		if(this.libraryManager.libraryFile.exists){
			//ライブラリファイルがもうあるので何もしない
		}else{
			//ライブラリファイルは無い場合
			this.libraryManager.useAppDirLibFile = false;
			
			//古いライブラリファイル(SQL)をアプリケーションディレクトリにコピー
			var oldLibFile:File = _libraryDir.resolvePath("system/").resolvePath(SQLiteLibraryManager.LIBRARY_FILE_NAME);
			var oldXMLLibFile:File = _libraryDir.resolvePath("system/").resolvePath(NamedArrayLibraryManager.LIBRARY_FILE_NAME);
			
			this.libraryManager.useAppDirLibFile = true;
			var newLibFile:File = File.applicationStorageDirectory.resolvePath(SQLiteLibraryManager.LIBRARY_FILE_NAME);
			if(oldLibFile.exists && !newLibFile.exists){
				oldLibFile.copyTo(newLibFile);
				logManager.addLog("ライブラリファイルの保存先を変更(新しい保存先:" + File.applicationStorageDirectory.resolvePath(SQLiteLibraryManager.LIBRARY_FILE_NAME).nativePath + ")");
			}
			
			//古いライブラリファイル(XML)をアプリケーションディレクトリにコピー
			var newXMLFile:File = File.applicationStorageDirectory.resolvePath(NamedArrayLibraryManager.LIBRARY_FILE_NAME);
			if(oldXMLLibFile.exists && !newXMLFile.exists){
				oldXMLLibFile.copyTo(newXMLFile);
			}
			
//			oldLibFile.moveToTrash();
		}
	}
	
	
	this.libraryManager.changeLibraryDir(this._libraryDir, false);
	
	this.ngTagManager.loadNgTags();
	
	//システムディレクトリにライブラリファイルがあればそっちを取りに行く
	var isSuccess:Boolean = this.libraryManager.loadLibrary();
	this.libraryManager.addEventListener(LibraryLoadEvent.LIBRARY_LOAD_COMPLETE, libraryLoadCompleteEventHandler);
	if(!isSuccess){
		//システムディレクトリにライブラリが無い
		var file:File = libraryManager.libraryDir.resolvePath(NamedArrayLibraryManager.LIBRARY_FILE_NAME);
		
		//古いライブラリファイル(XML)はあるか？
		if(file.exists){
			//あるなら持ってくる
			try{
				file.copyTo(libraryManager.systemFileDir.resolvePath(NamedArrayLibraryManager.LIBRARY_FILE_NAME));
				isSuccess = this.libraryManager.loadLibrary();
			}catch(error:Error){
				trace(error.getStackTrace());
			}
		}
		
		//古いライブラリファイルが読み込めたか？
		if(!isSuccess){
			//古いライブラリファイルが無い、もしくは読み込みに失敗したなら更新を薦める
			askAndRenewAtBootTime();
		}
	}
	
	/* ダウンロード済リストマネージャー */
	this.downloadedListManager = DownloadedListManager.instance;
	this.downloadedListManager.initialize(downloadedProvider);
	
	/* プレイリストマネージャー */
	this.playListManager = PlayListManager.instance;
	this.playListManager.initialize();
	this.playListManager.readPlayListSummary(libraryManager.playListDir);
	
	/* マイリストマネージャー */
	this._myListManager = MyListManager.instance;
	this._myListManager.initialize(myListProvider);
	isSuccess = this._myListManager.readMyListSummary(libraryManager.systemFileDir);
	if(isSuccess){
		renewMyListUnPlayCount();
	}
	
	MyListRenewScheduler.instance.addEventListener(Event.COMPLETE, function(event:Event):void{
		renewMyListUnPlayCount();
		var date:Date = new Date();
		myListStatusProvider = "更新完了(" +  DateUtil.getDateString(date) + ")";
	});
	MyListRenewScheduler.instance.addEventListener(MyListRenewProgressEvent.MYLIST_RENEW_PROGRESS, function(event:MyListRenewProgressEvent):void{
		myListStatusRenew(event.bytesLoaded, event.bytesTotal, event.renewingMyListId);
	});
	
	/* 検索条件マネージャー */
	this._searchItemManager = new SearchItemManager(searchListProvider, logManager);
	isSuccess = this._searchItemManager.readSearchItems(libraryManager.systemFileDir);
	if(!isAddedDefSearchItems){
		this._searchItemManager.addDefSearchItems();
		isAddedDefSearchItems = true;
	}
	
	/* ダウンロードマネージャ */
	this.downloadManager = new DownloadManager(downloadProvider, downloadedListManager, MAILADDRESS, PASSWORD, canvas_queue, 
		rankingProvider, searchProvider, myListItemProvider, logManager);
	this.downloadManager.isAlwaysEconomy = this.isAlwaysEconomy;
	this.downloadManager.isAppendComment = this.isAppendComment;
	this.downloadManager.isUseDownloadDir = this.isUseDownloadDir;
	
	/* 履歴管理 */
	HistoryManager.initialize(historyProvider);
	this.historyManager = HistoryManager.instance;
	this.historyManager.loadHistory();
	
	var menu:NativeMenu = this.nativeApplication.menu;
	if(menu != null){
		var menuItem:NativeMenuItem = menu.items[2];
		var isExists:Boolean = false;
		if(menuItem != null){
			menuItem = menuItem.submenu.items[2];
			if(menuItem != null){
				//Macの時はショートカットを使う
				isExists = true;
			}
		}
	}
	if(isExists){
		menuItem.addEventListener(Event.SELECT, queueMenuHandler);
	}else{
		//WindowsとLinuxの時は自分で追加
		this.addEventListener(AIREvent.WINDOW_COMPLETE, function(event:Event):void{
			stage.addEventListener(KeyboardEvent.KEY_UP, queueKeyUpHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, queueKeyDownHandler);
		});
	}
	
	this.addEventListener(AIREvent.WINDOW_COMPLETE, function(event:Event):void{
		//初回自動ランキング更新
		if(isRankingRenewAtStart){
			rankingRenewButtonClicked();
		}else{
			var value:Object = ConfigManager.getInstance().getItem("selectedTabIndex");
			if(value != null){
				viewstack1.selectedIndex = int(value);
			}
		}
		
		if(lastCategoryListWidth != -1){
  			list_categoryList.width = lastCategoryListWidth;
  		}else{
  			lastCategoryListWidth = list_categoryList.width;
  		}
		
	});
	
	/* タスクトレイ or Dockの設定 */
	var trayIconManager:SystemTrayIconManager = new SystemTrayIconManager();
	trayIconManager.setTrayIcon();
	
	
	// サムネイル画像拡大表示用Image
	thumbImageView.visible = false;
	thumbImageView.alpha = 0.9;
//	this.addChild(thumbImageView);
	this.addElement(thumbImageView);
}

public function myListStatusRenew(loaded:Number, total:Number, myListId:String):void{
	if(tree_myList != null){
//		var openItems:Object = tree_myList.openItems;
//		var selectedIndex:int = tree_myList.selectedIndex;
//		
//		tree_myList.addEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteEventHandler);
//		
//		tree_myList.dataProvider = tree_myList.dataProvider;
//		
//		function updateCompleteEventHandler(event:Event):void{
//			tree_myList.openItems = openItems;
//			tree_myList.selectedIndex = selectedIndex;
//			if(selectedIndex > 0){
//				tree_myList.scrollToIndex(selectedIndex);
//			}
//			tree_myList.removeEventListener(FlexEvent.UPDATE_COMPLETE, updateCompleteEventHandler);
//		}
		tree_myList.invalidateList();
		tree_myList.validateNow();
		
	}
	myListStatusProvider = "mylist/" + myListId + " を更新中(" + loaded + "/" + total + ")";
}

public function renewMyListUnPlayCount(tree_myListRenew:Boolean = true):void{
	var count:int = MyListManager.instance.countUnPlayVideosFromAll();
	
	if(count == 0){
		canvas_myList.label = "マイリスト";
	}else{
		canvas_myList.label = "マイリスト(" + count + ")";
	}
}

public function askAndRenewAtBootTime():void{
	Alert.show("ライブラリファイルがありません。\n今すぐライブラリを更新しますか？\n(この処理は時間がかかる事があります。また、更新は「設定」タブで後からでも実行できます。)\n\n更新対象フォルダ:" + libraryManager.libraryDir.nativePath, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
		if(event.detail == Alert.YES){
			renewAndShowDialog(libraryManager.libraryDir, true)
		}
	}, null, Alert.YES);
}

private function renewAndShowDialog(file:File, withSubDir:Boolean):void{
	loadWindow = PopUpManager.createPopUp(nndd, LoadWindow, true) as LoadWindow;
	loadWindow.label_loadingInfo.text = "ライブラリを更新中";
	loadWindow.progressBar_loading.label = "更新中...";
	PopUpManager.centerPopUp(loadWindow);
	
	var timer:Timer = new Timer(200, 1);
	
	timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
		
		libraryManager.addEventListener(LibraryLoadEvent.LIBRARY_LOADING, libraryLoadingEventHandler);
		libraryManager.addEventListener(LibraryLoadEvent.LIBRARY_LOAD_COMPLETE, libraryLoadCompleteEventHandler);
		libraryManager.renewLibrary(file, withSubDir);
		
	});
	
	timer.start();
	
}

private function libraryLoadingEventHandler(event:LibraryLoadEvent):void{
	if(loadWindow != null){
		loadWindow.label_loadingInfo.text = "ライブラリを更新中(" + event.completeVideoCount + "/" + event.totalVideoCount + ")";
	}
}

private function libraryLoadCompleteEventHandler(event:LibraryLoadEvent):void{
	if(loadWindow != null){
		PopUpManager.removePopUp(loadWindow);
	}
	libraryManager.removeEventListener(LibraryLoadEvent.LIBRARY_LOADING, libraryLoadingEventHandler);
	libraryManager.removeEventListener(LibraryLoadEvent.LIBRARY_LOAD_COMPLETE, libraryLoadCompleteEventHandler);
	
	if(viewStack.selectedIndex == LIBRARY_LIST_TAB_NUM){
		tabChanged();
	}
	
	logManager.addLog("ライブラリを更新:" + libraryManager.libraryDir.nativePath);
	if(loadWindow != null){
		Alert.show("ライブラリの更新が完了しました。", Message.M_MESSAGE);
	}
}

public function versionCheck():void{
	
	/* バージョンチェック */
//	VersionChecker.instance.checkUpdate(true);
	VersionCheckerFactory.create().checkUpdate(true);
}

/**
 * コンテキストメニュー選択時のイベントハンドラ
 * @param event
 * 
 */
private function dataGridContextMenuSelectHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer){
			if((event.mouseTarget as DataGridItemRenderer).data != null){
				var newSelectedItem:Object = (event.mouseTarget as DataGridItemRenderer).data;
				if(newSelectedItem is DataGridColumn){
					return;
				}
				if(dataGrid.selectedIndices.length > 1){
					//複数選択中
					var selectedItems:Array = dataGrid.selectedItems;
					
					var isExist:Boolean = false;
					for each(var item:Object in selectedItems){
						if(item == newSelectedItem){
							isExist = true;
							break;
						}
					}
					
					if(!isExist){
						selectedItems.push(newSelectedItem);
					}
					dataGrid.selectedItems = selectedItems;
				}else{
					//選択の変更
					dataGrid.selectedItem = newSelectedItem;
				}
			}
			
		}
	}
}


/**
 * 「URLをコピー」のコンテキストメニューアイテム用イベントハンドラ
 * @param event
 * 
 */
private function copyUrl(event:ContextMenuEvent):void{
			
	var videoId:String = getVideoIdDataGridContextEvent(event);
	
	if(videoId != null && videoId){
		var url:String = "http://www.nicovideo.jp/watch/" + videoId;
		if(url.indexOf("http://") != -1){
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, url);
		}
	}
}

private function openNicomimi(event:ContextMenuEvent):void{
	var videoId:String = getVideoIdDataGridContextEvent(event);
	if(videoId != null){
		WebServiceAccessUtil.openNicomimi(videoId);
	}
}

private function openNicoSound(event:ContextMenuEvent):void{
	var videoId:String = getVideoIdDataGridContextEvent(event);
	if(videoId != null){
		WebServiceAccessUtil.openNicoSound(videoId);
	}
}

private function openWebBrowserForContextMenu(event:ContextMenuEvent):void{
	var videoId:String = getVideoIdDataGridContextEvent(event);
	if(videoId != null){
		WebServiceAccessUtil.openNiconicoDougaForVideo(videoId);
	}
}

private function getVideoIdDataGridContextEvent(event:ContextMenuEvent):String{
	var videoId:String = null;
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null){
			var url:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
			if(url == null || url == "" || url == "undefined"){
				url = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoUrl;
			}
			if(url == null || url == "" || url == "undefined"){
				url = (event.mouseTarget as DataGridItemRenderer).data.col_videoUrl;
			}
			if(url == null || url == "" || url == "undefined"){
				url = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoName;
			}
			
			videoId = PathMaker.getVideoID(url);
		}
	}
	return videoId;
}


/**
 * ランキングのデータグリッドコンテキストメニュー用イベントハンドラ
 * @param event
 * 
 */
private function rankingItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null){
			var videoPath:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath;
			if(videoPath == null || videoPath == ""){
				videoPath = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
			}
			if(videoPath != null && videoPath != ""){
				if((event.target as ContextMenuItem).label == Message.L_RANKING_MENU_ITEM_LABEL_PLAY){
					this.playingVideoPath = videoPath;
					playMovie(this.playingVideoPath, -1);
				}else if((event.target as ContextMenuItem).label == Message.L_RANKING_MENU_ITEM_LABEL_STREAMING_PLAY){
					this.playingVideoPath = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
					this.videoStreamingPlayStart(this.playingVideoPath);
				}else if((event.target as ContextMenuItem).label == Message.L_RANKING_MENU_ITEM_LABEL_ADD_DL_LIST){
					
					var itemIndices:Array = dataGrid.selectedIndices;
					itemIndices.reverse();
					
					var i:int = 0;
					for each(var index:int in itemIndices){
						
						var video:NNDDVideo = new NNDDVideo(rankingProvider[index].dataGridColumn_nicoVideoUrl, rankingProvider[index].dataGridColumn_videoName);
						addDownloadList(video, itemIndices[i]);
						
						i++;
					}
				}
			}
		}
	}
}

/**
 * 検索結果のコンテキストメニューハンドラ
 * @param event
 * 
 */
private function searchItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null && (event.mouseTarget as DataGridItemRenderer).data.hasOwnProperty("dataGridColumn_nicoVideoUrl")){
			var videoPath:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath;
			if(videoPath == null || videoPath == ""){
				videoPath = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
			}
			if(videoPath != null && videoPath != ""){
				if((event.target as ContextMenuItem).label == Message.L_RANKING_MENU_ITEM_LABEL_PLAY){
					this.playingVideoPath = videoPath;
					playMovie(this.playingVideoPath, -1);
				}else if((event.target as ContextMenuItem).label == Message.L_RANKING_MENU_ITEM_LABEL_STREAMING_PLAY){
					this.playingVideoPath = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_nicoVideoUrl;
					this.videoStreamingPlayStart(this.playingVideoPath);
				}else if((event.target as ContextMenuItem).label == Message.L_RANKING_MENU_ITEM_LABEL_ADD_DL_LIST){
					
					var itemIndices:Array = dataGrid.selectedIndices;
					itemIndices.reverse();
					
					var i:int = 0;
					for each(var index:int in itemIndices){
						
						var video:NNDDVideo = new NNDDVideo(searchProvider[index].dataGridColumn_nicoVideoUrl, searchProvider[index].dataGridColumn_videoName);
						addDownloadListForSearch(video, itemIndices[i]);
						
						i++;
					}
				}
			}
		}
	}
}

/**
 * マイリストのコンテキストメニューイベントハンドラ
 * @param event
 * 
 */
private function myListItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null){
			var videoName:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoName;
			var myListId:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_myListId;
			
			if((event.target as ContextMenuItem).label == Message.L_RANKING_MENU_ITEM_LABEL_PLAY){
				var videoLocalPath:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoLocalPath;
				if(videoLocalPath != null){
					//マイリストの項目を既読に設定
					if(myListId != null){
						var vector:Vector.<String> = new Vector.<String>();
						vector.splice(0, 0, PathMaker.getVideoID(videoLocalPath));
						_myListManager.setPlayedAndSave(myListId, vector);
					}
					
					if(!selectedMyListFolder){
						var xml:XML = MyListManager.instance.readLocalMyList(myListId);
						if(xml != null){
							myListRenew(xml);
						}
					}else{
						if(tree_myList.selectedItem != null){
							var name:String = tree_myList.selectedItem.label;
							myListRenewForName(name);
						}
					}
					
					playMovie(videoLocalPath, -1);
				}
			}else if((event.target as ContextMenuItem).label == Message.L_RANKING_MENU_ITEM_LABEL_STREAMING_PLAY){
				var videoUrl:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoUrl;
				if(videoUrl != null){
					//マイリストの項目を既読に設定
					if(myListId != null){
						var vector:Vector.<String> = new Vector.<String>();
						vector.splice(0, 0, PathMaker.getVideoID(videoUrl));
						_myListManager.setPlayedAndSave(myListId, vector);
					}
					
					if(!selectedMyListFolder){
						var xml:XML = MyListManager.instance.readLocalMyList(myListId);
						if(xml != null){
							myListRenew(xml);
						}
					}else{
						if(tree_myList.selectedItem != null){
							var name:String = tree_myList.selectedItem.label;;
							myListRenewForName(name);
						}
					}
					
					videoStreamingPlayStart(videoUrl);
				}
			}else if((event.target as ContextMenuItem).label == Message.L_RANKING_MENU_ITEM_LABEL_ADD_DL_LIST){
				var itemIndices:Array = dataGrid.selectedIndices;
				itemIndices.reverse();
				for each(var index:int in itemIndices){
					
					var video:NNDDVideo = new NNDDVideo(myListItemProvider[index].dataGridColumn_videoUrl, myListItemProvider[index].dataGridColumn_videoName);
					addDownloadListForMyList(video, itemIndices[index]);
					
				}
			}else if((event.target as ContextMenuItem).label == Message.L_MYLIST_MENU_ITEM_LABEL_SET_PLAYED){
				
				var items:Array = dataGrid.selectedItems;
				var vector:Vector.<String> = new Vector.<String>();
				myListId = dataGrid.selectedItem.dataGridColumn_myListId;
				
				for each(var item:Object in items){
					var videoId:String = item.dataGridColumn_videoId;
					var tempListId:String = item.dataGridColumn_myListId;
					
					if(tempListId != myListId){
						try{
							MyListManager.instance.setPlayedAndSave(myListId, vector);
						}catch(error:Error){
							trace(error.getStackTrace());
						}
						vector.splice(0, vector.length);
						myListId = tempListId;
					}
					
					if(videoId != null){
						vector.splice(0, 0, videoId);
					}
					
				}
				
				try{
					MyListManager.instance.setPlayedAndSave(myListId, vector);
				}catch(error:Error){
					trace(error.getStackTrace());
				}
				
				var myListBuilder:MyListBuilder = new MyListBuilder();
				var scrollIndex:int = dataGrid.verticalScrollPosition;
				if(!selectedMyListFolder){
					var xml:XML = MyListManager.instance.readLocalMyList(myListId);
					if(xml != null){
						myListItemProvider = myListBuilder.getMyListArrayCollection(xml);
						var name:String = tree_myList.selectedItem.label;;
						myListRenewForName(name);
					}
				}else{
					if(tree_myList.selectedItem != null){
						var name:String = tree_myList.selectedItem.label;
						myListRenewForName(name);
					}
				}
				
				renewMyListUnPlayCount();
				
				dataGrid.scrollToIndex(scrollIndex);
			}
		}
	}
}


/**
 * ダウンロードリストのデータグリッドコンテキストメニュー用イベントハンドラ 
 * @param event
 * 
 */
private function queueItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if((event.target as ContextMenuItem).label == Message.L_DOWNLOADED_MENU_ITEM_LABEL_PLAY_BY_QUEUE){
			if((event.mouseTarget as DataGridItemRenderer).data != null && (event.mouseTarget as DataGridItemRenderer).data.hasOwnProperty("col_downloadedPath")){
				this.playingVideoPath = (event.mouseTarget as DataGridItemRenderer).data.col_downloadedPath;
				if(this.playingVideoPath != null){
					playMovie(this.playingVideoPath, -1);
				}
			}
		}else{
			if(dataGrid_downloadList.selectedIndices.length > 0){
				downloadManager.deleteSelectedItems(dataGrid_downloadList.selectedIndices);
			}
		}
	}
}

/**
 * 
 * @param event
 * 
 */
private function downloadItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null){
			var videoPath:String = (event.mouseTarget as DataGridItemRenderer).data.col_downloadedPath
			if(videoPath != null && videoPath != ""){
				this.playingVideoPath = videoPath;
				playMovie(this.playingVideoPath, -1);		
			}
		}
	}
}

/**
 * ダウンロード済アイテムのデータグリッドコンテキストメニュー用イベントハンドラ
 * @param event
 * 
 */
private function downloadedItemHandler(event:ContextMenuEvent):void {
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null 
				&& (event.mouseTarget as DataGridItemRenderer).data.hasOwnProperty("dataGridColumn_videoPath")){
			if((event.target as ContextMenuItem).label == Message.L_DOWNLOADED_MENU_ITEM_LABEL_PLAY){
				if(this.playListManager.isSelectedPlayList){
					var pIndex:int = playListManager.getPlayListIndexByName(tree_library.selectedItem.label);
					this.playMovie((event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath, 
						dataGrid_downloaded.selectedIndex, playListManager.getPlayList(pIndex));
				}else{
					this.playMovie((event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath, -1);
				}
			}else if((event.target as ContextMenuItem).label == Message.L_DOWNLOADED_MENU_ITEM_LABEL_DELETE){
				
				//右クリックされた対象のURL
//				var targetVideoPath:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath;
				
				//すでに選択済みのURL
				var indices:Array = dataGrid_downloaded.selectedIndices;
				indices.reverse();
				if(indices.length > 0 && indices[0] > -1){
					var urls:Array = new Array(indices.length);
					var isExist:Boolean = false;
					for(var i:int=indices.length-1; -1 < i; i--){
						urls[i] = this.downloadedListManager.getVideoPath(indices[i]);
//						if(urls[i] == targetVideoPath){
//							isExist = true;
//						}
					}
//					if(!isExist){
//						urls.push(targetVideoPath);
//					}
//					
					deleteVideo(urls,indices);
				}
			}else if((event.target as ContextMenuItem).label == Message.L_DOWNLOADED_MENU_ITEM_LABEL_EDIT){
				var isExists:Boolean = false;
				
				var url:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_videoPath;
				var video:NNDDVideo = this.libraryManager.isExist(LibraryUtil.getVideoKey(url));
				
				if(video == null && url.indexOf("http://") == -1){
					//ライブラリ管理出来ていない動画については新規追加
					video = new LocalVideoInfoLoader().loadInfo(url);
					isExists = false;
				}else if(video == null && playListManager.isSelectedPlayList){
					//これはストリーミング用。編集不可。
					Alert.show("この動画はまだダウンロードされていません。先にダウンロードしてください。", Message.M_MESSAGE);
					return;
				}else{
					isExists = true;
				}
				
				var videoEditDialog:VideoEditDialog = PopUpManager.createPopUp(this, VideoEditDialog, true) as VideoEditDialog;
				PopUpManager.centerPopUp(videoEditDialog);
				videoEditDialog.init(video, logManager);
				
				videoEditDialog.addEventListener(Event.COMPLETE, function(event:Event):void{
					try{
						// ファイルの移動はダイアログ側でやる
//						if(videoEditDialog.oldVideo.uri != videoEditDialog.newVideo.uri){
//							(new File(videoEditDialog.oldVideo.uri)).moveTo(new File(videoEditDialog.newVideo.uri));
//						}
						if(dataGrid_downloaded.selectedItem != null){
							dataGrid_downloaded.selectedItem.dataGridColumn_videoName = videoEditDialog.newVideo.file.name;
							dataGrid_downloaded.selectedItem.dataGridColumn_videoPath = videoEditDialog.newVideo.getDecodeUrl();
						}
						if(libraryManager.update(videoEditDialog.newVideo, true)){
							// 成功
						}else{
							// 新しくビデオIDが追加された
							libraryManager.remove(videoEditDialog.oldVideo.key, true);
							libraryManager.add(videoEditDialog.newVideo, true);
						}
					}catch(error:IOError){
						Alert.show("ファイル名の変更に失敗しました。" + error, Message.M_ERROR)
						logManager.addLog("ファイル名の変更に失敗:" + error + ":" + error.getStackTrace());
					}
					downloadedListManager.refresh();
					PopUpManager.removePopUp(videoEditDialog);
				});
				videoEditDialog.addEventListener(Event.CANCEL, function(event:Event):void{
					if(isExists == false){
						//新規動画の場合はキャンセルでも登録
						libraryManager.add(video, true);
					}
					PopUpManager.removePopUp(videoEditDialog);
				});
			}
		}
	}
}

/**
 * ライブラリタブのライブラリツリーコンテキストメニュー用イベントハンドラ
 * @param event
 * 
 */
private function fileSystemTreeItemHandler(event:ContextMenuEvent):void{
	
	if((event.target as ContextMenuItem).label == Message.L_FILE_SYSTEM_TREE_MENU_ITEM_LABEL_RENEW
		|| (event.target as ContextMenuItem).label == Message.L_FILE_SYSTEM_TREE_MENU_ITEM_LABEL_RENEW_WITH_SUBDIR){
	
		var file:File = null;
		
		if((event.mouseTarget is DataGridItemRenderer)){
			
			var item:ITreeItem = (tree_library.selectedItem as ITreeItem);
			
			if(item == null){
				file = libraryManager.libraryDir;
			}else{
				file = item.file;
			}
			
		}else if((event.mouseTarget as UITextField) != null && (event.mouseTarget as UITextField).owner != null 
			&& ((event.mouseTarget as UITextField).owner is TreeItemRenderer)){
			var object:Object = ((event.mouseTarget as UITextField).owner as TreeItemRenderer).data;
			if(object != null && object is TreeFolderItem){ 
				file = (object as TreeFolderItem).file;
			}
		}
		
		if(file != null){
		
			if((event.target as ContextMenuItem).label == Message.L_FILE_SYSTEM_TREE_MENU_ITEM_LABEL_RENEW_WITH_SUBDIR){
				
				//サブディレクトリを更新するディレクトリ更新
				askForDirRenew(file);
					
			}else if((event.target as ContextMenuItem).label == Message.L_FILE_SYSTEM_TREE_MENU_ITEM_LABEL_RENEW){
				
				//サブディレクトリを更新しないディレクトリ更新
				renewAndShowDialog(file, false);
				
			}
		
		}
	}else if((event.target as ContextMenuItem).label == Message.L_FILE_SYSTEM_TREE_MENU_ITEM_LABEL_PLAYALL){
		var itreeItem:ITreeItem = null;
		itreeItem = (tree_library.selectedItem as ITreeItem);
		
		if (itreeItem != null)
		{
			var labelName:String = itreeItem.label;
			if(itreeItem.file == null){
				// ファイルを持っていないのはプレイリスト
				playMovieByPlayListIndex(labelName);
				
			}else{
				if(isEnableLibrary){
					// ファイルを持っているのはライブラリ
					playMovieByLibraryDir(itreeItem.file);
				}
			}
		}
		else
		{
			// treeが選択されていない時は自分が居るディレクトリから調べる
			var obj:Object = dataGrid_downloaded.selectedItem;
			if(obj != null){
				var file:File = new File(obj.dataGridColumn_videoPath as String);
				playMovieByLibraryDir(file.parent);
			}
		}
	}
	
}

/**
 * 
 * @param dir
 * 
 */
private function askForDirRenew(dir:File):void{

	trace(dir.nativePath);
	
	Alert.show("指定されたフォルダ及びサブフォルダ内の情報を再収集します。よろしいですか？\n(この処理には時間がかかる事があります。)\n\n" + dir.nativePath, 
				Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
		if(event.detail == Alert.YES){
			renewAndShowDialog(dir, true);
		}
	});
	
}

private function addMyList(myListId:String, video:NNDDVideo):void{
	
	if(this._myListAdder != null){
		this._myListAdder.close();
		this._myListAdder = null;
	}
	
	this._myListAdder = new NNDDMyListAdder(this.logManager);
	
	this._myListAdder.addEventListener(NNDDMyListAdder.ADD_MYLIST_SUCESS, function(event:Event):void{
		logManager.addLog("次の動画をマイリストに追加:" + video.getVideoNameWithVideoID());
		logManager.addLog("***マイリストへの追加成功***");
		_myListAdder.close();
		_myListAdder = null;
	});
	this._myListAdder.addEventListener(NNDDMyListAdder.ADD_MYLIST_DUP, function(event:Event):void{
		logManager.addLog("次の動画はすでにマイリストに登録済:" + video.getVideoNameWithVideoID());
		logManager.addLog("***マイリストへの追加失敗***");
		Alert.show("次の動画は既にマイリストに追加されています。\n" + video.getVideoNameWithVideoID(), Message.M_MESSAGE);
		_myListAdder.close();
		_myListAdder = null;
	});
	this._myListAdder.addEventListener(NNDDMyListAdder.ADD_MYLIST_NOT_EXIST, function(event:Event):void{
		logManager.addLog("次の動画は存在しない:" + video.getVideoNameWithVideoID());
		logManager.addLog("***マイリストへの追加失敗***");
		Alert.show("次の動画をマイリストに追加しようとしましたが、動画が存在しませんでした。\n" + video.getVideoNameWithVideoID(), Message.M_MESSAGE);
		_myListAdder.close();
		_myListAdder = null;
	});
	this._myListAdder.addEventListener(NNDDMyListAdder.ADD_MYLSIT_FAIL, function(event:ErrorEvent):void{
		logManager.addLog("マイリストへの登録に失敗:" + video.getVideoNameWithVideoID() + ":" + event);
		logManager.addLog("***マイリストへの追加失敗***");
		Alert.show("マイリストへの登録に失敗\n" + event, Message.M_ERROR);
		Application.application.activate();
		_myListAdder.close();
		_myListAdder = null;
	});
	this._myListAdder.addEventListener(NNDDMyListAdder.LOGIN_FAIL, function(event:Event):void{
		logManager.addLog("マイリストへの登録に失敗:" + video.getVideoNameWithVideoID() + ":" + event);
		logManager.addLog("***マイリストへの追加失敗***");
		Alert.show("マイリストへの登録に失敗\n" + event, Message.M_ERROR);
		Application.application.activate();
		_myListAdder.close();
		_myListAdder = null;
	});
	this._myListAdder.addEventListener(NNDDMyListAdder.GET_MYLISTGROUP_FAIL, function(event:Event):void{
		logManager.addLog("マイリストへの登録に失敗:" + video.getVideoNameWithVideoID() + ":" + event);
		logManager.addLog("***マイリストへの追加失敗***");
		Alert.show("マイリストへの登録に失敗\n" + event, Message.M_ERROR);
		Application.application.activate();
		_myListAdder.close();
		_myListAdder = null;
	});
	
	this._myListAdder.addMyList("http://www.nicovideo.jp/watch/" + PathMaker.getVideoID(video.getDecodeUrl()), myListId, this.MAILADDRESS, this.PASSWORD);	
}


/**
 * ライブラリタブのタグ表示タイルリストコンテキストメニュー用イベントハンドラ
 * @param event
 * 
 */
private function tagListItemHandler(event:ContextMenuEvent):void {
	if(event.mouseTarget is UITextField){
		
		var tags:Array = new Array();
		
		var selectedItems:Array = (event.contextMenuOwner as TileList).selectedItems;
		
		for each(var object:Object in selectedItems){
			if(object.hasOwnProperty("label") && object.label != null){
				tags.push(object.label);
			}else if(object is String){
				tags.push(object);
			}
		}
		
		var textField:UITextField = (event.mouseTarget as UITextField);
		if (textField != null)
		{
			var renderer:IListItemRenderer = (textField.automationOwner as IListItemRenderer);
			if (renderer != null)
			{
				var tag:String = String(renderer.data);
				if (tag != null)
				{
					tags.push(tag);
				}
			}
		}
		
		var label:String = (event.target as ContextMenuItem).label;
		if(tag != null && tag.length > 0 && label != null){
			if(label == Message.L_TAB_LIST_MENU_ITEM_LABEL_SEARCH){
				search(new SearchItem(tag, SearchSortString.convertSortTypeFromIndex(4), 
					SearchType.TAG, tag));
			}else if(label == Message.L_TAB_LIST_MENU_ITEM_LABEL_JUMP_DIC){
				navigateToURL(new URLRequest("http://dic.nicovideo.jp/a/" + encodeURIComponent(tag)));
			}else if(label == Message.L_TAB_LIST_MENU_ITEM_LABEL_HIDE_TAG){
				ngTagManager.addTags(tags);
			}else if(label == Message.L_TAB_LIST_MENU_ITEM_LABEL_SHOW_TAG){
				ngTagManager.removeTags(tags);
			}
			
			var file:File = (this.tree_library.selectedItem as File);
			if(file == null){
				file = libraryManager.libraryDir;
			}
			tagManager.tagRenew(this.tileList_tag, file);
			ngTagManager.tagRenew(this.tileList_filterTag);
			
		}
	}
}

public function tagShow():void{
	var array:Array = tileList_filterTag.selectedItems;
	
	if(array != null){
		ngTagManager.removeTags(array);
		
		var file:File = (this.tree_library.selectedItem as File);
		if(file == null){
			file = libraryManager.libraryDir;
		}
		tagManager.tagRenew(this.tileList_tag, file);
		ngTagManager.tagRenew(this.tileList_filterTag);
	}
		
}

public function tagHide():void{
	var array:Array = tileList_tag.selectedItems;
	
	if(array != null){
		ngTagManager.addTags(array);

		var file:File = (this.tree_library.selectedItem as File);
		if(file == null){
			file = libraryManager.libraryDir;
		}
		tagManager.tagRenew(this.tileList_tag, file);
		ngTagManager.tagRenew(this.tileList_filterTag);
	}
}


/**
 * 「連続再生」が選択されたときのイベントハンドラ
 * @param event
 * 
 */
private function playAllMenuItemHandler(event:ContextMenuEvent):void{
	if((event.contextMenuOwner as DataGrid).dataProvider != null){
		var array:ArrayCollection = ((event.contextMenuOwner as DataGrid).dataProvider as ArrayCollection);
		var selectedIndices:Array = (event.contextMenuOwner as DataGrid).selectedIndices;
		if(array.length > 0){
			
			var playList:PlayList = new PlayList();
			playList.name = "新規プレイリスト.m3u";
			var isMyList:Boolean = false;
			
			if(array[0].hasOwnProperty("dataGridColumn_videoLocalPath")){
				isMyList = true;
			}
			
			for(var i:int = 0; i<array.length; i++){
				
				//ランキング・検索
//				dataGridColumn_videoPath: localURL,
//				dataGridColumn_nicoVideoUrl: urlList[i][0]
				//マイリスト
//				dataGridColumn_videoUrl:videoUrl,
//				dataGridColumn_videoLocalPath:videoLocalPath
				
				var url:String = "";
				if(isMyList){
					url = array[i].dataGridColumn_videoLocalPath;
					if(url == null || url == ""){
						url = array[i].dataGridColumn_videoUrl;
					}
				}else{
					url = array[i].videoPath;
					if(url == null || url == ""){
						url = array[i].dataGridColumn_nicoVideoUrl;
					}
				}
				
				var videoName:String = array[i].dataGridColumn_videoName;
				var videoId:String = PathMaker.getVideoID(url);
				if(videoName.indexOf("\n") != -1){
					videoName = videoName.substring(0, videoName.indexOf("\n")) + " - [" + videoId + "]";
				}
				
				playList.items.push(new NNDDVideo(url, videoName));
				
			}
			
			var startIndex:int = (event.contextMenuOwner as DataGrid).selectedIndex;
			
			// 項目が２個以上選択されている場合は選択されている物のみプレイリストに追加
			var selectedItemPlayList:PlayList = new PlayList();
			selectedItemPlayList.name = "新規プレイリスト.m3u";
			if(selectedIndices.length > 1){
				startIndex = 0;
				
				selectedIndices.reverse();
				for each(var index:int in selectedIndices){
					selectedItemPlayList.items.push(playList.items[index]);
				}
				
				playList = selectedItemPlayList;
			}
			
			if(playList.items.length > 0 && startIndex >= 0 && playList.items.length > startIndex){
				playMovie(playList[startIndex], startIndex, playList);
			}
			
		}
	}
}

/**
 * 起動時に引数が指定されていた場合、その引数を受け取ります。
 * @param event
 * 
 */
private function invokeEventHandler(event:InvokeEvent):void{
	if(event.arguments.length >= 1){
		
		var arguments:String = "";
		for each(var arg:String in event.arguments){
			if(arguments.length != 0){
				arguments = arguments + ",";
			}
			arguments = arguments + arg;
		}
		
		logManager.addLog(Message.INVOKE_ARGUMENT + ":" + arguments);
		
		var arg1:String = event.arguments[0];
		
		try{
			if(arg1.indexOf("-d") != -1){
				var url:String = event.arguments[1];
				var videoId:String = PathMaker.getVideoID(url);
				if(videoId != null){
					url = "http://www.nicovideo.jp/watch/" + videoId;
				}
				
				if(url.indexOf("http://www.nicovideo.jp/watch/") > -1){
					//DLリストに追加
					
					var video:NNDDVideo = new NNDDVideo(url, "-");
					var timer:Timer = new Timer(1000, 1);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
						addDownloadList(video, -1);
					}, false, 0, true);
					timer.start();
				}else if(url.indexOf("http://") > -1){
					var checker:ShortUrlChecker = new ShortUrlChecker();
					if (checker.isShortUrl(url))
					{
						// 短縮URLなら展開
						logManager.addLog("短縮URLを展開中...:" + url);
						checker.addEventListener(Event.COMPLETE, function(event:Event):void{
							if (checker.url != null)
							{
								logManager.addLog("短縮URLを展開:" + checker.url);
								
								if(checker.url.indexOf("http://www.nicovideo.jp/watch/") > -1){
									//DLリストに追加
									var video:NNDDVideo = new NNDDVideo(checker.url, "-");
									var timer:Timer = new Timer(1000, 1);
									timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
										addDownloadList(video, -1);
									}, false, 0, true);
									timer.start();
								}
								else
								{
									//これはニコ動のURL or 動画IDじゃない
									logManager.addLog(Message.FAIL_ARGUMENT_BOOT + ":argument=[" + arguments + "]\n" + Message.ARGUMENT_FORMAT);
									Alert.show(Message.M_FAIL_ARGUMENT_BOOT + "\n\n" + arguments + "\n" + Message.ARGUMENT_FORMAT, Message.M_ERROR);
								}
							} 
							else
							{
								logManager.addLog(Message.M_SHORT_URL_EXPANSION_FAIL + ":ShortUrlChecker.url is null.");
								Alert.show(Message.M_SHORT_URL_EXPANSION_FAIL, Message.M_ERROR);
							}
						});
						checker.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void{
							logManager.addLog(Message.M_SHORT_URL_EXPANSION_FAIL + ":" + event);
							Alert.show(Message.M_SHORT_URL_EXPANSION_FAIL, Message.M_ERROR);
						});
						checker.expansion(url);
					}
				}else{
					//これはニコ動のURL or 動画IDじゃない
					logManager.addLog(Message.FAIL_ARGUMENT_BOOT + ":argument=[" + arguments + "]\n" + Message.ARGUMENT_FORMAT);
					Alert.show(Message.M_FAIL_ARGUMENT_BOOT + "\n\n" + arguments + "\n" + Message.ARGUMENT_FORMAT, Message.M_ERROR);
				}
			}else if(arg1.indexOf("http://") == -1){
				// ローカルのファイル
				
				var file:File = new File(arg1);
				if(file.exists){
//					this.isArgumentBoot = true;
					this.playingVideoPath = decodeURIComponent(file.nativePath);
					playMovie(decodeURIComponent(file.url), -1);
				}
			}else if(arg1.indexOf("http://www.nicovideo.jp/watch/") > -1){
				// ニコ動
				
				if(MAILADDRESS == ""){
					this.isArgumentBoot = true;
					this.argumentURL = arg1;
				}else{
					this.playingVideoPath = arg1;
					this.videoStreamingPlayStart(arg1);
				}
			}else if(arg1.indexOf("http://") > -1){
				var checker:ShortUrlChecker = new ShortUrlChecker();
				if (checker.isShortUrl(arg1))
				{
					// 短縮URLなら展開
					logManager.addLog("短縮URLを展開中...:" + arg1);
					checker.addEventListener(Event.COMPLETE, function(event:Event):void{
						if (checker.url != null)
						{
							logManager.addLog("短縮URLを展開...:" + checker.url);
							if(MAILADDRESS == ""){
								isArgumentBoot = true;
								argumentURL = checker.url;
							}else{
								playingVideoPath = checker.url;
								videoStreamingPlayStart(checker.url);
							}
						} else
						{
							logManager.addLog(Message.M_SHORT_URL_EXPANSION_FAIL + ":ShortUrlChecker.url is null.");
							Alert.show(Message.M_SHORT_URL_EXPANSION_FAIL, Message.M_ERROR);
						}
					});
					checker.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void{
						logManager.addLog(Message.M_SHORT_URL_EXPANSION_FAIL + ":" + event);
						Alert.show(Message.M_SHORT_URL_EXPANSION_FAIL, Message.M_ERROR);
					});
					checker.expansion(arg1);
				}
			}else{
				logManager.addLog(Message.FAIL_ARGUMENT_BOOT + ":argument=[" + arguments + "]\n" + Message.ARGUMENT_FORMAT);
				Alert.show(Message.M_FAIL_ARGUMENT_BOOT + "\n\n" + arguments + "\n" + Message.ARGUMENT_FORMAT, Message.M_ERROR);
			}
		}catch(error:Error){
			logManager.addLog(Message.FAIL_ARGUMENT_BOOT + ":argument=[" + arguments + "]\n" + error.getStackTrace());
			Alert.show(Message.M_FAIL_ARGUMENT_BOOT + "\n\n" + arguments + "\n" + Message.ARGUMENT_FORMAT, Message.M_ERROR);
		}
	}
}

/**
 * 動画の削除を行います。
 * @param url URIエンコードされていないURLを指定します。
 * @param index データグリッドのインデックスです
 * 
 */
private function deleteVideo(urls:Array, indices:Array):void{
	if(!this.playListManager.isSelectedPlayList){
		var fileNames:String = "";
		for(var j:int=0; indices.length > j; j++){
			fileNames += "・"+ urls[j].substring(urls[j].lastIndexOf("/")+1) + "\n";
		}
		
		if(urls.length > 0){
			Alert.show("次のファイルを削除してもよろしいですか？（コメント・サムネイル情報・ユーザーニコ割も同時に削除されます。）\n\n" + fileNames, 
					Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					try{
						for(var i:int=indices.length-1; -1 < i; i--){
							var url:String = urls[i];
							var index:int = i;
							
							//動画を削除
							var movieFile:File = new File(url);
							
							var nnddVideo:NNDDVideo = libraryManager.remove(LibraryUtil.getVideoKey(decodeURIComponent(movieFile.url)), false);
							if(nndd == null){
								logManager.addLog("指定された動画はNNDDの管理外です。:" + movieFile.nativePath);
							}
							
							if(!movieFile.exists){
								//もうない。次のファイルへ。
								continue;
							}
							movieFile.moveToTrash();
//							downloadedProvider.removeItemAt(index);
							logManager.addLog(Message.DELETE_FILE + ":" + movieFile.nativePath);
							
							try{
								
								var failURL:String = "";
								
								//通常コメントを削除
								var commentFile:File = new File(PathMaker.createNomalCommentPathByVideoPath(decodeURIComponent(url)));
								failURL = decodeURIComponent(commentFile.url);
								if(commentFile.exists){
									commentFile.moveToTrash();
									logManager.addLog(Message.DELETE_FILE + ":" + commentFile.nativePath);
								}
								
								//投稿者コメントを削除
								var ownerCommentFile:File = new File(PathMaker.createOwnerCommentPathByVideoPath(decodeURIComponent(url)));
								failURL = decodeURIComponent(ownerCommentFile.url);
								if(ownerCommentFile.exists){
									ownerCommentFile.moveToTrash();
									logManager.addLog(Message.DELETE_FILE + ":" + ownerCommentFile.nativePath);
								}
								
								//サムネイル情報を削除
								var thmbInfoFile:File = new File(PathMaker.createThmbInfoPathByVideoPath(decodeURIComponent(url)));
								failURL = decodeURIComponent(thmbInfoFile.url);
								if(thmbInfoFile.exists){
									thmbInfoFile.moveToTrash();
									logManager.addLog(Message.DELETE_FILE + ":" + thmbInfoFile.nativePath);
								}
								
								//市場情報を削除
								var iChibaFile:File = new File(PathMaker.createNicoIchibaInfoPathByVideoPath(decodeURIComponent(url)));
								failURL = decodeURIComponent(iChibaFile.url);
								if(iChibaFile.exists){
									iChibaFile.moveToTrash();
									logManager.addLog(Message.DELETE_FILE + ":" + iChibaFile.nativePath);
								}
								
								//サムネイル画像を削除（あれば）
								var thumbImgFile:File = new File(PathMaker.createThumbImgFilePath(decodeURIComponent(url)));
								failURL = decodeURIComponent(thumbImgFile.url);
								if(thumbImgFile.exists){
									thumbImgFile.moveToTrash();
									logManager.addLog(Message.DELETE_FILE + ":" + thumbImgFile.nativePath);
								}
								
								//ニコ割を削除
								while(true){
									var file:File = new File(PathMaker.createNicowariPathByVideoPathAndNicowariVideoID(decodeURIComponent(url)));
									if(file.exists){
										failURL = decodeURIComponent(file.url);
										file.moveToTrash();
										logManager.addLog(Message.DELETE_FILE + ":" + file.nativePath);
									}else{
										break;
									}
								}
								
							}catch (error:Error){
								Alert.show(Message.M_FAIL_OTHER_DELETE, Message.M_ERROR);
								logManager.addLog(Message.M_FAIL_OTHER_DELETE + ":" + failURL + ":" + error + "\n" + error.getStackTrace());
							}
						}
						
						updateLibrary(tree_library.selectedIndex);
						
					}catch (error:Error){
//						tree_library.refresh();
						updateLibrary(tree_library.selectedIndex);
						Alert.show(Message.M_FAIL_VIDEO_DELETE, Message.M_ERROR);
						logManager.addLog(Message.M_FAIL_VIDEO_DELETE + ":" + movieFile.nativePath + ":" + error + "\n" + error.getStackTrace());
					}
					
					libraryManager.saveLibrary();
					
				}
			}, null, Alert.NO);
		}
	}else{
		var index:int = playListManager.getPlayListIndexByName(tree_library.selectedItem.label);
		playListManager.removePlayListItemByIndex(index, indices);
		updatePlayList(index);
	}
}

/**
 * データグリッドでキーボードイベントを受け取るイベントハンドラです
 * @param event
 * 
 */
private function downloadedKeyUpHandler(event:KeyboardEvent):void{
	if(event.keyCode == Keyboard.DELETE || event.keyCode == Keyboard.BACKSPACE){
		var indices:Array = dataGrid_downloaded.selectedIndices;
		if(indices.length > 0 && indices[0] > -1){
			var urls:Array = new Array(indices.length);
			for(var i:int=indices.length-1; -1 < i; i--){
				urls[i] = this.downloadedListManager.getVideoPath(indices[i]);
			}
			deleteVideo(urls,indices);
		}
	}
}

/**
 * 暗号化されたローカルストアから各種設定値を読み込みます
 * 
 */
private function readStore(isLogout:Boolean = false):void{
	
	var errorName:String = "LocalStoreKey";
	var isStore:Boolean = false;
	var name:String = "" , pass:String = "";
	
	this._libraryDir = libraryManager.defaultLibraryDir;

	logManager.addLog("設定情報の読み込み:" + ConfigManager.getInstance().confFileNativePath);
	trace("設定情報の読み込み:" + ConfigManager.getInstance().confFileNativePath);
	
	errorName = "NameAndPass";
	
	/*ローカルストアから値の呼び出し*/
	try{
		var confValue:String = ConfigManager.getInstance().getItem("storeNameAndPass");
		if (confValue == null) {
			var storedValue:ByteArray = EncryptedLocalStore.getItem("storeNameAndPass");
			if(storedValue != null){
				isStore = storedValue.readBoolean();
				
				if(isStore){
					storedValue = EncryptedLocalStore.getItem("userName");
					if(storedValue != null){
						name = storedValue.readUTFBytes(storedValue.length);
					}
					storedValue = EncryptedLocalStore.getItem("password");
					if(storedValue != null){
						pass = storedValue.readUTFBytes(storedValue.length);
					}
				}
			}
		}else{
			isStore = ConfUtil.parseBoolean(confValue);
			if(isStore){
				storedValue = EncryptedLocalStore.getItem("userName");
				if(storedValue != null){
					name = storedValue.readUTFBytes(storedValue.length);
				}
				storedValue = EncryptedLocalStore.getItem("password");
				if(storedValue != null){
					pass = storedValue.readUTFBytes(storedValue.length);
				}
			}
		}
	}catch(error:Error){
		
		EncryptedLocalStore.reset();
		
		ConfigManager.getInstance().removeItem("isAutoLogin");
		ConfigManager.getInstance().setItem("isAutoLogin", false);
		
		name = "";
		pass = "";
		
		/* エラーログ出力 */
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.M_LOCAL_STORE_IS_BROKEN + ":" + Message.FAIL_LOAD_LOCAL_STORE_FOR_NNDD_MAIN_WINDOW + "[" + errorName + "]:" + error + ":" + error.getStackTrace());
		trace(error.getStackTrace());
	}
	
	try{
		
		errorName = "windowPosition_x";
		//x,y,w,h
		confValue = ConfigManager.getInstance().getItem("windowPosition_x");
		if (confValue == null) {
			//何もしない
		}else{
			nativeWindow.x = lastRect.x = int(confValue);
		}
		
		errorName = "windowPosition_y";
		confValue = ConfigManager.getInstance().getItem("windowPosition_y");
		if (confValue == null) {
			//何もしない
		}else{
			nativeWindow.y = lastRect.y = int(confValue);
		}
		
		errorName = "windowPosition_w";
		confValue = ConfigManager.getInstance().getItem("windowPosition_w");
		if (confValue == null) {
			//何もしない
		}else{
			nativeWindow.width = lastRect.width = int(confValue);
		}
		
		errorName = "windowPosition_h";
		confValue = ConfigManager.getInstance().getItem("windowPosition_h");
		if (confValue == null) {
			//何もしない
		}else{
			nativeWindow.height = lastRect.height = int(confValue);
		}
		
		errorName = "isVersionCheckEnable";
		confValue = ConfigManager.getInstance().getItem("isVersionCheckEnable");
		if (confValue == null) {
			//何もしない
		}else{
			this.isVersionCheckEnable = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "isUseDownloadDir";
		confValue = ConfigManager.getInstance().getItem("isUseDownloadDir");
		if (confValue != null){
			this.isUseDownloadDir = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "lastCanvasPlaylistHight";
		confValue = ConfigManager.getInstance().getItem("lastCanvasPlaylistHight");
		if (confValue == null) {
			//何もしない
		}else{
			this.lastCanvasPlaylistHight = int(confValue);
		}
		
		errorName = "thumbImageSize";
		confValue = ConfigManager.getInstance().getItem("thumbImageSize");
		if (confValue == null) {
			//何もしない
		}else{
			thumbImageSize = Number(confValue);
			if(dataGrid_ranking != null && dataGrid_ranking != null && dataGridColumn_thumbImage != null){
				// 一番手前のタブだけはプロパティ読み込み前に初期化が終わっているのでココで設定
				slider_thumbImageSize.value = thumbImageSize;
				dataGrid_ranking.rowHeight = 55*slider_thumbImageSize.value;
				dataGridColumn_thumbImage.width = 70*slider_thumbImageSize.value;
				this.validateNow();
			}
		}
		
		errorName = "thumbImgSizeForMyList";
		confValue = ConfigManager.getInstance().getItem("thumbImgSizeForMyList");
		if (confValue == null) {
			//何もしない
		}else{
			thumbImgSizeForMyList = Number(confValue);
		}
		
		errorName = "thumbImgSizeForDLList";
		confValue = ConfigManager.getInstance().getItem("thumbImgSizeForDLList");
		if (confValue == null){
			//なにもしない
		}else{
			thumbImgSizeForDLList = Number(confValue);
		}
		
		errorName = "thumbImgSizeForLibrary";
		confValue = ConfigManager.getInstance().getItem("thumbImgSizeForLibrary");
		if (confValue == null) {
			//何もしない
		}else{
			thumbImgSizeForLibrary = Number(confValue);
		}
		
		errorName = "thumbImgSizeHistory";
		confValue = ConfigManager.getInstance().getItem("thumbImgSizeHistory");
		if (confValue == null){
			// 何もしない
		}else{
			thumbImgSizeHistory = Number(confValue);
		}
		
		errorName = "thumbImgSizeForSearch";
		confValue = ConfigManager.getInstance().getItem("thumbImgSizeForSearch");
		if (confValue == null) {
			//何もしない
		}else{
			thumbImgSizeForSearch = Number(confValue);
		}
		
		errorName = "isAutoLogin";
		confValue = ConfigManager.getInstance().getItem("isAutoLogin");
		if (confValue == null) {
			//何もしない
		}else{
			this.isAutoLogin = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "isAutoDownload";
		confValue = ConfigManager.getInstance().getItem("isAutoDownload");
		if (confValue == null) {
			//何もしない
		}else{
			this.isAutoDownload = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "isEnableEcoCheck";
		confValue = ConfigManager.getInstance().getItem("isEnableEcoCheck");
		if (confValue == null) {
			//何もしない
		}else{
			this.isEnableEcoCheck = ConfUtil.parseBoolean(confValue);
		}
		
		
		errorName = "rankingTarget";
		confValue = ConfigManager.getInstance().getItem("rankingTarget");
		if (confValue == null) {
			//何もしない
		}else{
			this.target = int(confValue);
			this.addEventListener(AIREvent.WINDOW_COMPLETE, function():void{
				radiogroup_target.selectedValue = target;
			});
		}
		
		errorName = "rankingPeriod";
		confValue = ConfigManager.getInstance().getItem("rankingPeriod");
		if (confValue == null) {
			//何もしない
		}else{
			this.period = int(confValue);
			this.addEventListener(AIREvent.WINDOW_COMPLETE, function():void{
				radiogroup_period.selectedValue = period;
			});
		}
		
		errorName = "libraryURL";
		/*保存先を設定*/
		confValue = ConfigManager.getInstance().getItem("libraryURL");
		if (confValue == null) {
			this._libraryDir = File.documentsDirectory;
			this._libraryDir.url = this._libraryDir.url + "/NNDD";
		}else{
			this._libraryDir.url = String(confValue);
		}
		logManager.setLogDir(new File(this._libraryDir.url + "/system/"));
		
		errorName = "isSayHappyNewYear";
		confValue = ConfigManager.getInstance().getItem("isSayHappyNewYear");
		if (confValue == null) {
			//何もしない
		}else{
			isSayHappyNewYear = ConfUtil.parseBoolean(confValue);
		}
		
//		errorName = "isShowOnlyNowLibraryTag";
//		storedValue = EncryptedLocalStore.getItem("isShowOnlyNowLibraryTag");
//		if(storedValue != null){
//			this.isShowOnlyNowLibraryTag = storedValue.readBoolean();
//		}
		
		errorName = "isAlwaysEconomy";
		confValue = ConfigManager.getInstance().getItem("isAlwaysEconomy");
		if (confValue == null) {
			//何もしない
		}else{
			this.isAlwaysEconomy = ConfUtil.parseBoolean(confValue);
		}
		
		
		errorName = "lastCanvasTagTileListHight";
		confValue = ConfigManager.getInstance().getItem("lastCanvasTagTileListHight");
		if (confValue == null) {
			//何もしない
		}else{
			this.lastCanvasTagTileListHight = int(confValue);
		}
		
		errorName = "lastSearchItemListWidth";
		confValue = ConfigManager.getInstance().getItem("lastSearchItemListWidth");
		if (confValue == null) {
			//何もしない
		}else{
			this.lastSearchItemListWidth = int(confValue);
		}
		
		errorName = "isRankingRenewAtStart";
		confValue = ConfigManager.getInstance().getItem("isRankingRenewAtStart");
		if (confValue == null) {
			//何もしない
		}else{
			this.isRankingRenewAtStart = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "isOutStreamingPlayerUse";
		confValue = ConfigManager.getInstance().getItem("isOutStreamingPlayerUse");
		if (confValue == null) {
			//何もしない
		}else{
			this.isOutStreamingPlayerUse = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "isDoubleClickOnStreaming";
		confValue = ConfigManager.getInstance().getItem("isDoubleClickOnStreaming");
		if (confValue == null) {
			//何もしない
		}else{
			this.isDoubleClickOnStreaming = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "lastCategoryListWidth";
		confValue = ConfigManager.getInstance().getItem("lastCategoryListWidth");
		if (confValue == null) {
			//何もしない
		}else{
			this.lastCategoryListWidth = int(confValue);
		}
		
		errorName = "lastMyListSummaryWidth";
		confValue = ConfigManager.getInstance().getItem("lastCategoryListWidth");
		if (confValue == null) {
			//何もしない
		}else{
			this.lastMyListSummaryWidth = int(confValue);
		}
		
		errorName = "lastMyListHeight";
		confValue = ConfigManager.getInstance().getItem("lastMyListHeight");
		if (confValue == null) {
			//何もしない
		}else{
			this.lastMyListHeight = int(confValue);
		}
		
		errorName = "lastLibraryWidth";
		confValue = ConfigManager.getInstance().getItem("lastLibraryWidth");
		if (confValue == null) {
			//何もしない
		}else{
			this.lastLibraryWidth = int(confValue);
		}
		
		errorName = "lastCategoryListWidth";
		confValue = ConfigManager.getInstance().getItem("lastCategoryListWidth");
		if (confValue == null) {
			//何もしない
		}else{
			this.lastCategoryListWidth = int(confValue);
		}
		
		errorName = "libraryDataGridSortFieldName";
		confValue = ConfigManager.getInstance().getItem("libraryDataGridSortFieldName");
		if (confValue == null) {
			//何もしない
		}else{
			this.libraryDataGridSortFieldName = String(confValue);
		}
		
		errorName = "libraryDataGridSortDescending";
		confValue = ConfigManager.getInstance().getItem("libraryDataGridSortDescending");
		if (confValue == null) {
			//何もしない
		}else{
			this.libraryDataGridSortDescending = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "isEnableLibrary";
		confValue = ConfigManager.getInstance().getItem("isEnableLibrary");
		if (confValue == null) {
			//何もしない
		}else{
			this.isEnableLibrary = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "isAddedDefSearchItems";
		confValue = ConfigManager.getInstance().getItem("isAddedDefSearchItems");
		if (confValue == null) {
			//何もしない
		}else{
			this.isAddedDefSearchItems = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "isDisEnableAutoExit";
		confValue = ConfigManager.getInstance().getItem("isDisEnableAutoExit");
		if (confValue == null) {
			//何もしない
		}else{
			this.isDisEnableAutoExit = ConfUtil.parseBoolean(confValue);
		}
		this.autoExit = !this.isDisEnableAutoExit;
		
		errorName = "isAppendComment";
		confValue = ConfigManager.getInstance().getItem("isAppendComment");
		if (confValue == null) {
			//何もしない
		}else{
			this.isAppendComment = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "myListRenewScheduleTime";
		confValue = ConfigManager.getInstance().getItem("myListRenewScheduleTime");
		if(confValue == null){
			// 何もしない
		}else{
			this.myListRenewScheduleTime = Number(confValue);
		}
		
		errorName = "myListRenewDelayOfMylist";
		confValue = ConfigManager.getInstance().getItem("myListRenewDelayOfMylist");
		if(confValue == null){
			// 何もしない
		}else{
			MyListRenewScheduler.instance.delayOfMylist = Number(confValue);
		}
		
		errorName = "mylistRenewOnScheduleEnable";
		confValue = ConfigManager.getInstance().getItem("mylistRenewOnScheduleEnable");
		if(confValue == null){
			// 何もしない
		}else{
			this.mylistRenewOnScheduleEnable = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "fontFamily";
		confValue = ConfigManager.getInstance().getItem("fontFamily");
		if(confValue == null){
			confValue = "Verdana";
		}
		confValue = FontUtil.setFont(confValue);
		ConfigManager.getInstance().setItem("fontFamily", confValue);
		
		errorName = "isSaveSearchHistory";
		confValue = ConfigManager.getInstance().getItem("isSaveSearchHistory");
		if(confValue == null){
			// 何もしない
		}else{
			this.isSaveSearchHistory = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "saveCommentMaxCount";
		confValue = ConfigManager.getInstance().getItem("saveCommentMaxCount");
		if(confValue == null){
			//何もしない
		}else{
			this.saveCommentMaxCount = Number(confValue);
		}
		
		errorName = "showAll";
		confValue = ConfigManager.getInstance().getItem("showAll");
		if(confValue == null){
			
		}else{
			this.showAll = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "isEnableNativePlayer";
		confValue = ConfigManager.getInstance().getItem("isEnableNativePlayer");
		if(confValue == null){
			
		}else{
			this.isEnableNativePlayer = ConfUtil.parseBoolean(confValue);
		}
		
		errorName = "nativePlayerPath";
		confValue = ConfigManager.getInstance().getItem("nativePlayerPath");
		if(confValue == null){
			
		}else{
			try{
				var file:File = new File();
				file.nativePath = String(confValue);
				
				NativeProcessPlayerManager.instance.executeFile = file;
				
			}catch(error:Error){
				trace(error.getStackTrace());
			}
		}
		
		errorName = "fontSize";
		confValue = ConfigManager.getInstance().getItem("fontSize");
		if(confValue == null){
			confValue = "11";
		}
		confValue = FontUtil.setSize(Number(confValue));
		ConfigManager.getInstance().setItem("fontSize", confValue);
		
		
		errorName = "useAppDirLibFile";
		confValue = ConfigManager.getInstance().getItem("useAppDirLibFile");
		if(confValue != null){
			useAppDirLibFile = ConfUtil.parseBoolean(confValue);
		}else{
			useAppDirLibFile = false;
		}
		
		
	}catch(error:Error){
		/* ストアをリセット */
//		EncryptedLocalStore.reset();
		
		/* エラー時は初期値を利用 */
		this._libraryDir = libraryManager.defaultLibraryDir;		
		logManager.setLogDir(libraryManager.systemFileDir);
		
		/* エラーログ出力 */
		Alert.show(Message.M_CONF_FILE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.M_CONF_FILE_IS_BROKEN + ":" + Message.FAIL_LOAD_CONF_FILE_FOR_NNDD_MAIN_WINDOW + "[" + errorName + "]:" + error + ":" + error.getStackTrace());
		trace(error.getStackTrace());
	}
	
	/* ログイン処理 */
	createLoginDialog(isStore, isAutoLogin, name, pass, isLogout);
	
}

private function createLoginDialog(isStore:Boolean, isAutoLogin:Boolean, name:String, pass:String, isLogout:Boolean):void{
	// ログインダイアログの作成
	loginDialog = PopUpManager.createPopUp(this, LoginDialog, true) as LoginDialog;
	loginDialog.initLoginDialog(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, isStore, isAutoLogin, LogManager.instance, name, pass, isLogout);
	// ログイン時のイベントリスナを追加
	loginDialog.addEventListener(LoginDialog.ON_LOGIN_SUCCESS, onFirstTimeLoginSuccess);
	loginDialog.addEventListener(LoginDialog.LOGIN_FAIL, loginFailEventHandler);
	loginDialog.addEventListener(LoginDialog.NO_LOGIN, noLogin);
	// ダイアログを中央に表示
	PopUpManager.centerPopUp(loginDialog);
}

/**
 * 
 * @param event
 * 
 */
private function loginFailEventHandler(event:Event):void{
	logManager.addLog("ログインに失敗:" + event);
}

/**
 * 初回ログイン作業が成功した場合に呼ばれるリスナー
 * @param event
 * 
 */
private function onFirstTimeLoginSuccess(event:HTTPStatusEvent):void
{
	logoutButton.label = "ログアウト";
	logoutButton.enabled = true;
	
	PopUpManager.removePopUp(loginDialog);
	
	this.MAILADDRESS = loginDialog.textInput_userName.text;
	this.PASSWORD = loginDialog.textInput_password.text;
	
	MyListRenewScheduler.instance.mailAddress = this.MAILADDRESS;
	MyListRenewScheduler.instance.password = this.PASSWORD;
	
	if(this.mylistRenewOnScheduleEnable){
		MyListRenewScheduler.instance.startNow();
		MyListRenewScheduler.instance.start((this.myListRenewScheduleTime*60)*1000);
	}
	
	downloadManager.setMailAndPass(this.MAILADDRESS, this.PASSWORD);
	downloadManager.isContactTheUser = isEnableEcoCheck;
	scheduleManager = new ScheduleManager(logManager, downloadManager);
	
//	this.nndd.label_status.text = "ログインに成功(" + event.status + ")";
	trace("ログインに成功"+event);
	logManager.addLog("ログイン:" + event);
	
//	nndd.rankingRenewButton.enabled = true;
//	nndd.downloadStartButton.enabled = true;
//	nndd.button_SearchNico.enabled = true;
//	nndd.dataGrid_ranking.enabled = true;
//	nndd.list_categoryList.enabled = true;
//	nndd.playStartButton.enabled = true;
//	
//	setEnableRadioButtons(true);
	
//	if(nndd.newCommentDownloadButton != null){
//		nndd.newCommentDownloadButton.enabled = true;
//	}
	
	//引数指定起動でニコ動のURLが指定されていたときはログイン後に再生開始
	if(isArgumentBoot){
		isArgumentBoot = false;
		try{
			this.playingVideoPath = this.argumentURL;
			this.videoStreamingPlayStart(this.playingVideoPath);
			this.isArgumentBoot = false;
			this.argumentURL = "";
		}catch(error:Error){
			Alert.show("引数で指定されていた動画の再生に失敗\n" + this.argumentURL, Message.M_ERROR);
			logManager.addLog("引数で指定されていた動画の再生に失敗:url" + this.argumentURL + "\n" + error.getStackTrace());
		}
	}
	

}

/**
 * ログインダイアログで"今はログインしない"を選択したときに呼ばれるリスナー
 * 
 */
private function noLogin(event:HTTPStatusEvent):void
{
	logoutButton.label = "ログイン";
	logoutButton.enabled = true;
	
	PopUpManager.removePopUp(loginDialog);
	
	this.MAILADDRESS = "";
	this.PASSWORD = "";
	
	MyListRenewScheduler.instance.mailAddress = this.MAILADDRESS;
	MyListRenewScheduler.instance.password = this.PASSWORD;
	
	MyListRenewScheduler.instance.stop();
	
	logManager.addLog("ログインせず:" + event);
	
	downloadManager.setMailAndPass(this.MAILADDRESS, this.PASSWORD);
	scheduleManager = new ScheduleManager(logManager, downloadManager);
	
//	this.nndd.label_status.text = "ログインしていません。";
	
//	nndd.rankingRenewButton.enabled = false;
//	nndd.downloadStartButton.enabled = false;
//	nndd.button_SearchNico.enabled = false;
//	nndd.dataGrid_ranking.enabled = false;
//	nndd.list_categoryList.enabled = false;
//	nndd.playStartButton.enabled = false;
//	
//	setEnableRadioButtons(false);
//	
//	if(nndd.newCommentDownloadButton != null){
//		nndd.newCommentDownloadButton.enabled = false;
//	}
	
	this.isArgumentBoot = false;
	this.argumentURL = "";
	
}

private function setEnableTargetRadioButtons(enable:Boolean):void{
	
	nndd.radio_target_mylist.enabled = enable;
	nndd.radio_target_res.enabled = enable;
	nndd.radio_target_view.enabled = enable;
	
}

/**
 * ラジオボタンをまとめて有効・無効に設定します。
 * @param enable
 * 
 */
private function setEnableRadioButtons(enable:Boolean):void{
	nndd.radiogroup_period.enabled = enable;
	nndd.radiogroup_target.enabled = enable;
	
	nndd.radio_period_new.enabled = enable;
	nndd.radio_period_daily.enabled = enable;
	nndd.radio_period_hourly.enabled = enable;
	nndd.radio_period_monthly.enabled = enable;
	nndd.radio_period_weekly.enabled = enable;
	nndd.radio_period_all.enabled = enable;
	nndd.radio_target_mylist.enabled = enable;
	nndd.radio_target_res.enabled = enable;
	nndd.radio_target_view.enabled = enable;
}

/**
 * 「参照」ボタンがクリックされた際に呼ばれます。 <br>
 * 
 */
private function folderSelectButtonClicked(event:MouseEvent):void
{
	var directory:File = new File(libraryManager.libraryDir.url);
	
	directory.browseForDirectory("ファイルの保存先を指定");
	
	// ファイル選択イベントのリスナを登録
	directory.addEventListener(Event.SELECT, function(event:Event):void
	{
		// ライブラリディレクトリが既に存在するなら今のデータを保存
		if (libraryManager.libraryDir != null && libraryManager.libraryDir.exists)
		{
			
			// 検索項目
			_searchItemManager.saveSearchItems(libraryManager.systemFileDir);
			
			// マイリスト
			MyListManager.instance.saveMyListSummary(libraryManager.systemFileDir);
			
			// DLリスト
//			DownloadedListManager.instance.
			
			// ライブラリ
			libraryManager.saveLibrary(libraryManager.systemFileDir);
			
			// 履歴
			HistoryManager.instance.saveHistory();
			
			// NGタグ
			ngTagManager.saveNgTags();
			
		}
		
		
		// イベントのターゲットが選択されたファイルなので、`File`型に変換
		libraryManager.changeLibraryDir(File(event.target));
		
		nndd.textInput_saveAdress.text = libraryManager.libraryDir.nativePath;
		
		if(tree_library != null){
			
			var libraryTreeBuilder:LibraryTreeBuilder = new LibraryTreeBuilder();
			tree_library.dataProvider = libraryTreeBuilder.build(true);
			
		}
		
		var vector:Vector.<PlayList> = playListManager.readPlayListSummary(libraryManager.playListDir);
		
		var treeDataBuilder:TreeDataBuilder = new TreeDataBuilder();
		var object:Object = treeDataBuilder.getFolderObject("PlayList");
		for each(var playList:PlayList in vector){
			var file:Object = treeDataBuilder.getFileObject(playList.name);
			(object.children as Array).push(file);
		}
		
//		libraryProvider.addItem(object);
		
		if(tree_library != null){
			tree_library.invalidateList();
			tree_library.validateNow();
		}
		
		// 検索項目
		searchProvider.removeAll();
		searchListProvider.splice(0, searchListProvider.length);
		_searchItemManager.readSearchItems(libraryManager.systemFileDir);
		
		// マイリスト
		myListItemProvider.removeAll();
		myListProvider.splice(0, myListProvider.length);
		MyListManager.instance.readMyListSummary(libraryManager.systemFileDir);
		
		// DLリスト
		downloadedListManager.updateDownLoadedItems(libraryManager.systemFileDir.url, showAll);
		
		// 履歴
		HistoryManager.instance.loadHistory();
		
		// Ngタグ
		ngTagManager.loadNgTags();
		
		logManager.addLog("保存先を変更:"+libraryManager.libraryDir.nativePath);
	});
}


/**
 * タブが変更されたときに呼ばれます。
 * 
 */
private function tabChanged():void{
	switch(viewStack.selectedIndex){
		case RANKING_AND_SERACH_TAB_NUM:
			
			break;
		case SEARCH_TAB_NUM:
			(tree_SearchItem.dataProvider as ArrayCollection).refresh();
			tree_SearchItem.invalidateList();
			tree_SearchItem.validateNow();
			
			break;	
		case MYLIST_TAB_NUM:
			
			var confValue:String = ConfigManager.getInstance().getItem("firstTimeMyListShow");
			if(confValue == null){
				if(MAILADDRESS.length > 0 && PASSWORD.length > 0){
					Alert.show(Message.M_RENEW_MYLIST_GROUP, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
						if(event.detail == Alert.YES){
							MyListManager.instance.addEventListener(MyListManager.MYLIST_RENEW_COMPLETE, myListRenewCompleteHandler);
							MyListManager.instance.renewMyListIds(MAILADDRESS, PASSWORD);
						}
						ConfigManager.getInstance().setItem("firstTimeMyListShow", false);
						ConfigManager.getInstance().save();
					});
				}
			}
			
			(tree_myList.dataProvider as ArrayCollection).refresh();
			tree_myList.invalidateList();
			tree_myList.validateNow();
			
			break;
		case DOWNLOAD_LIST_TAB_NUM:
			
			if (scheduleManager != null)
			{
				label_nextDownloadTime.text = scheduleManager.scheduleString;
			}
			dataGrid_downloadList.setFocus();
			
			(dataGrid_downloadList.dataProvider as ArrayCollection).refresh();
			dataGrid_downloadList.invalidateList();
//			dataGrid_downloadList.validateNow();
			
			if(downloadManager.listLength > 100){
				Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER_DELETE, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
					if(event.detail == Alert.YES){
						downloadManager.removeDownloadedVideo();
					}
				});
			}
			
			break;
		case LIBRARY_LIST_TAB_NUM:
			
			if(tileList_tag == null){
				this.canvas_tagList.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:Event):void{
					tabChanged();
				});
				return;
			}
			
			this.tree_library.enabled = isEnableLibrary;
			this.button_addDir.enabled = isEnableLibrary;
			this.button_delDir.enabled = isEnableLibrary;
			this.button_fileNameEdit.enabled = isEnableLibrary;
	  		
			if((this.tree_library.openItems as Array).length == 0){
//				this.tree_library.openItems = libraryProvider;
			}
			
//			if(isEnableLibrary){
//				var folder:TreeFolderItem = (libraryProvider[0] as TreeFolderItem);
//				if(folder != null){
//					folder.children = new Array();
//				}
//			}
			
			if(playListManager.isSelectedPlayList){
				updatePlayListSummery();
				var index:int = playListManager.selectedPlayListIndex;
				if(index < 0){
					index = 0;
				}
				updatePlayList(index);
			}else if(isEnableLibrary){
				if(isEnableLibrary){
					
					var item:ITreeItem = (tree_library.selectedItem as ITreeItem);
					
//					if(item == null){
//						item = libraryProvider[0];
//					}
					
					updateLibrary(tree_library.selectedIndex);
					
					tree_library.selectedItem = item;
				}
			}
	  		
			(this.dataGrid_downloaded.dataProvider as ArrayCollection).refresh();
			break;
		case HISTORY_LIST_TAB_NUM:
			historyManager.refresh();
			break;
		case OPTION_TAB_NUM:
			if(textArea_log != null){
				logManager.showLog(textArea_log);
			}else{
				canvas_innerConfing_log.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
					logManager.showLog(textArea_log);
				});
			}
			break;
		
	}
}

private function sourceTabChanged(event:IndexChangedEvent):void{
	if(event.newIndex == 0){
		
	}else if(event.newIndex == 1){
		
	}
}

private function confTabChange(event:Event):void{
	if(textArea_log != null){
		logManager.showLog(textArea_log);
	}else{
		canvas_innerConfing_log.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
			logManager.showLog(textArea_log);
		});
	}
}


private function rankingCanvasCreationComplete(event:FlexEvent):void{
	if(this.lastCategoryListWidth != -1){
  		this.list_categoryList.width = this.lastCategoryListWidth;
  		this.validateNow();
  	}
  	this.list_categoryList.addEventListener(ResizeEvent.RESIZE, categoryListWidthChanged);
}


private function setLibraryTab():void{
	if(fileSystemTreeComplete && downloadedDataGridComplete && /*playListComplete &&*/ tileListComplete){
		libraryTabCreationComplete();
	}
}

private function libraryTabCreationComplete():void{

	if(isEnableLibrary){
		
		var openItems:Array = new Array();
		var selectedItems:Array = new Array();
		if(this.tree_library.openItems != null){
			openItems = (this.tree_library.openItems as Array);
		}
		if(this.tree_library.selectedItems != null){
			selectedItems = this.tree_library.selectedItems;
		}
		//ダウンロード済みリストを更新する。
		var myFile:File = new File((libraryManager.libraryDir.url.substr(0,libraryManager.libraryDir.url.lastIndexOf("/"))));
		
		var selectedItem:ITreeItem = (tree_library.selectedItem as ITreeItem);
		if(selectedItem != null){
			this.downloadedListManager.updateDownLoadedItems(selectedItem.file.url, this.showAll);
		}else{
			this.downloadedListManager.updateDownLoadedItems(libraryManager.libraryDir.url, this.showAll);
		}
		//ツリーで以前開いていた部分を再度開く
		var newOpenItems:Array = new Array();
		for(var i:int = 0; i<openItems.length; i++){
			if(newOpenItems.indexOf(openItems[i]) == -1){
				var file:File = openItems[i].file;
				if(file != null && file.exists){
					newOpenItems.push(openItems[i]);
				}else if(file == null){
					newOpenItems.push(openItems[i]);
				}
			}
		}
		this.tree_library.openItems = newOpenItems;
		
		//ツリーで以前選択されていた部分を再度選択する
		var newSelectedItems:Array = new Array();
		for(i = 0; i<selectedItems.length; i++){
			file = new File(selectedItems[i].file);
			if(file.exists){
				newSelectedItems.push(selectedItems[i]);
			}
		}
		
		if(newSelectedItems.length == 0){
//			this.tree_library.selectedItem = libraryProvider;
		}else{
			this.tree_library.selectedItem = newSelectedItems;
		}
		
		if(newSelectedItems.length > 0){
			/* 開かれているパスの項目でタグを更新 */
			var selectedFile:File = new File();
			selectedFile.nativePath = newSelectedItems[0].file;
			tagManager.tagRenew(tileList_tag, selectedFile);
		}else{
			/* ライブラリ直下でタグを更新 */
			tagManager.tagRenew(tileList_tag, libraryManager.libraryDir);
		}
		
		//ソートを反映
		if(this.libraryDataGridSortFieldName != null && this.libraryDataGridSortFieldName != ""){
			(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort = new Sort();
			(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort.fields = [new SortField(this.libraryDataGridSortFieldName, false, this.libraryDataGridSortDescending)];
		}else{
			(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort = new Sort();
			(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort.fields = [new SortField("dataGridColumn_videoName", false, false)];
		}
		(this.dataGrid_downloaded.dataProvider as ArrayCollection).refresh();
	}else if(!isEnableLibrary){
		var openItems:Array = new Array();
		var selectedItems:Array = new Array();
		if(this.tree_library.openItems != null){
			openItems = (this.tree_library.openItems as Array);
		}
		if(this.tree_library.selectedItem != null){
			selectedItems = this.tree_library.selectedItem.selectedItems;
		}
		//ダウンロード済みリストを更新する。
		var myFile:File = new File((libraryManager.libraryDir.url.substr(0,libraryManager.libraryDir.url.lastIndexOf("/"))));
		
		if(tree_library != null){
			
			var libraryTreeBuilder:LibraryTreeBuilder = new LibraryTreeBuilder();
			this.tree_library.dataProvider = libraryTreeBuilder.build(true);
			
		}
		
		//ツリーで以前開いていた部分を再度開く
		var newOpenItems:Array = new Array();
		for(var i:int = 0; i<openItems.length; i++){
			var file:File = new File(openItems[i].file);
			if(file.exists){
				newOpenItems.push(openItems[i]);
			}
		}
		this.tree_library.openItems = openItems;
		
		//ツリーで以前選択されていた部分を再度選択する
		var newSelectedItems:Array = new Array();
		for(i = 0; i<selectedItems.length; i++){
			file = new File(selectedItems[i].file);
			if(file.exists){
				newSelectedItems.push(selectedItems[i]);
			}
		}
		this.tree_library.selectedItems = newSelectedItems;
	}
	
	
}

private function allConfigCanvasCreationComplete(event:FlexEvent):void{
	textInput_saveAdress.text = this.libraryManager.libraryDir.nativePath;
	checkBox_useDownloadDir.selected = this.isUseDownloadDir;
	
	checkBox_versionCheck.selected = this.isVersionCheckEnable;
	
	checkBox_DisEnableAutoExit.selected = this.isDisEnableAutoExit;
	
	fontListRenew();
	
	fontSizeListRenew();
}

private function allConfigCanvasShow(event:Event):void{
	
	fontListRenew();
	
	fontSizeListRenew();
	
}

private function fontSizeListRenew():void{
	var fontSize:String = ConfigManager.getInstance().getItem("fontSize");
	if(fontSize == "10"){
		comboBox_fontsize.selectedIndex = 0;
	}else if(fontSize == "11"){
		comboBox_fontsize.selectedIndex = 1;
	}else if(fontSize == "12"){
		comboBox_fontsize.selectedIndex = 2;
	}else{
		comboBox_fontsize.selectedIndex = 1;
	}
}

private function fontListRenew():void{
	var array:Array = new Array();
	var vector:Vector.<Font> = FontUtil.fontList();
	const NICONICO_STRING:String = "ニコニコ動画";
	
	for each(var font:Font in vector){
		array.splice(-1,0, font.fontName);
	}
	
	array.sort();
	
	var appFontName:String = FontUtil.applicationFont;
	var selectedIndex:int = -1;
	
	for(var index:int = 0; index < array.length; index++){
		if(appFontName == array[index]){
			selectedIndex = index;
			break;
		}
	}
	
	if(selectedIndex == -1){
		array.splice(0,0, appFontName);
		selectedIndex = 0;
	}
	
	comboBox_font.dataProvider = array;
	
	comboBox_font.selectedIndex = selectedIndex;
}

private function nicoConfigCanvasCreationComplete(event:FlexEvent):void{
	
	checkbox_isRankingRenewAtStart.selected = isRankingRenewAtStart;
	checkBox_isUseOutStreamPlayer.selected = this.isOutStreamingPlayerUse;
	checkBox_isDoubleClickOnStreaming.selected = this.isDoubleClickOnStreaming;
	
	checkBox_myListRenewOnSchedule.selected = this.mylistRenewOnScheduleEnable;
	
	checkbox_saveSearchHistory.selected = this.isSaveSearchHistory;
	
	var index:int = 0;
	for each(var str:String in MyListRenewScheduler.MyListRenewScheduleTimeArray){
		if(str == String(this.myListRenewScheduleTime)){
			combobox_myListRenewTime.selectedIndex = index;
			break;
		}
		index++;
	}
	
}

private function libraryConfigCanvasCreationComplete(event:FlexEvent):void{
	checkbox_autoDL.selected = this.isAutoDownload;
	checkBox_isAlwaysEconomyMode.selected = this.isAlwaysEconomy;
	checkBox_enableLibrary.selected = this.isEnableLibrary;	
	checkbox_ecoDL.selected = this.isEnableEcoCheck;
	checkBox_isAppendComment.selected = this.isAppendComment;
	numericStepper_saveCommentMaxCount.value = this.saveCommentMaxCount;
	numericStepper_saveCommentMaxCount.enabled = this.isAppendComment;
}

private function libraryWidthChanged(event:ResizeEvent):void{
	this.lastLibraryWidth = event.currentTarget.width;
}

private function categoryListWidthChanged(event:ResizeEvent):void{
	this.lastCategoryListWidth = event.currentTarget.width;
}

private function searchItemListWidthChanged(event:ResizeEvent):void{
	this.lastSearchItemListWidth = event.currentTarget.width;
}


private function myListSummaryWidthChagned(event:ResizeEvent):void{
	this.lastMyListSummaryWidth = event.currentTarget.width;
}

private function myListHeightChanged(event:ResizeEvent):void{
	this.lastMyListHeight = event.currentTarget.height;
}

/**
 * ダウンロードボタンを押したときの動作
 * 
 */
private function addDownloadListButtonClicked():void{
	if(downloadStartButton.enabled == true){
		
		// データグリッド選択時
		if(dataGrid_ranking.selectedIndices.length > 0){
			
			var items:Array = dataGrid_ranking.selectedItems;
			var itemIndices:Array = dataGrid_ranking.selectedIndices;
			for(var index:int = 0; index<items.length; index++){
				
				var video:NNDDVideo = new NNDDVideo(items[index].dataGridColumn_nicoVideoUrl, items[index].dataGridColumn_videoName);
				addDownloadList(video, itemIndices[index]);
				
			}
		}
	}
}

private function rankingStreamingPlayButtonClicked(event:MouseEvent):void{
	var index:int = this.dataGrid_ranking.selectedIndex;
	var url:String = null;
	
	if(dataGrid_ranking.dataProvider.length > 0 && index<dataGrid_ranking.dataProvider.length && index >= 0){
		url = dataGrid_ranking.dataProvider[index].dataGridColumn_nicoVideoUrl;
		if(url != null){
			videoStreamingPlayStart(url);
		}
	}
}

/**
 * ストリーミング再生
 * @param url
 * 
 */
private function videoStreamingPlayStart(url:String):void{
	if(playStartButton.enabled == true){
		
		var mUrl:String = null;
		
		var videoId:String = PathMaker.getVideoID(url);
		if(videoId != null){
			mUrl = "http://www.nicovideo.jp/watch/" + videoId;
		}
		
		if(mUrl != null && mUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
			
			if(isOutStreamingPlayerUse){
				
				navigateToURL(new URLRequest(mUrl));
				
			}else if(isEnableNativePlayer){
				
				playNative(url);
				
			}else{
				
				if(playerController == null){
					playerController = new PlayerController(MAILADDRESS, PASSWORD, playListManager);
					playerController.open();
				}else{
					if(!playerController.isOpen()){
						playerController.destructor();
						playerController = null;
						playerController = new PlayerController(MAILADDRESS, PASSWORD, playListManager);
						playerController.open();
					}
				}
				
				try{
					
					playerController.playMovie(mUrl);
					
				}catch(e:Error){
					
					Alert.show("ストリーミング再生中に予期せぬ例外が発生しました。\nError:" + e, Message.M_ERROR);
					logManager.addLog("ストリーミング再生中に予期せぬ例外が発生しました。\nError:" + e + ":" + e.getStackTrace());
					
				}
			}
			
		}else{
			Alert.show(Message.M_NOT_NICO_URL, Message.M_ERROR);
		}
		
	}
}

/**
 * ランキングデータグリッドがダブルクリックされたときの動作
 * 
 */
private function rankingDataGridDoubleClicked(event:ListEvent):void{
	
	var myDataGrid:DataGrid = (event.currentTarget as DataGrid);
	
	var mUrl:String = myDataGrid.dataProvider[myDataGrid.selectedIndex].dataGridColumn_nicoVideoUrl;
	
	if(myDataGrid.enabled == true){
		
		if(isDoubleClickOnStreaming){
			this.videoStreamingPlayStart(mUrl);
		}else{
			var videoName:String = myDataGrid.dataProvider[myDataGrid.selectedIndex].dataGridColumn_videoName;
			var index:int = myDataGrid.selectedIndex;
			
			var video:NNDDVideo = new NNDDVideo(mUrl, videoName);
			var isExistsInLibrary:Boolean = false;
			video = libraryManager.isExist(LibraryUtil.getVideoKey(mUrl));
			if(video != null){
				isExistsInLibrary = true;
			}
			
			if(isExistsInLibrary){
				Alert.show(Message.M_ALREADY_DOWNLOADED_VIDEO_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
					if(event.detail == Alert.YES){
						var video:NNDDVideo = new NNDDVideo(mUrl, videoName);
						addDownloadList(video, index);
					}
				}, null, Alert.NO);
			}else{
				video = new NNDDVideo(mUrl, videoName);
				addDownloadList(video, index);
			}
				
		
		}
	}
}

/**
 * 検索データグリッドがダブルクリックされたときの動作
 * 
 */
private function searchDataGridDoubleClicked(event:ListEvent):void{
	
	var myDataGrid:DataGrid = (event.currentTarget as DataGrid);
	
	var mUrl:String = myDataGrid.dataProvider[myDataGrid.selectedIndex].dataGridColumn_nicoVideoUrl;
	
	if(myDataGrid.enabled == true){
		
		if(isDoubleClickOnStreaming){
			this.videoStreamingPlayStart(mUrl);
		}else{
			var videoName:String = myDataGrid.dataProvider[myDataGrid.selectedIndex].dataGridColumn_videoName;
			var index:int = myDataGrid.selectedIndex;
			
			var video:NNDDVideo = new NNDDVideo(mUrl, videoName);
			var isExistsInLibrary:Boolean = false;
			video = libraryManager.isExist(LibraryUtil.getVideoKey(mUrl));
			if(video != null){
				isExistsInLibrary = true;
			}
			
			if(isExistsInLibrary){
				Alert.show(Message.M_ALREADY_DOWNLOADED_VIDEO_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
					if(event.detail == Alert.YES){
						var video:NNDDVideo = new NNDDVideo(mUrl, videoName);
						addDownloadListForSearch(video, index);
					}
				}, null, Alert.NO);
			}else{
				video = new NNDDVideo(mUrl, videoName);
				addDownloadListForSearch(video, index);
			}
				
		
		}
	}
}


/**
 * 
 * @param event
 * 
 */
private function addDownloadListForDownloadedList(event:Event):void{
	
	var array:Array = dataGrid_downloaded.selectedItems;
	array = array.reverse();
	var videoArray:Array = new Array();
	var missVideoPath:Array = new Array();
	
	for each(var object:Object in array){
		var path:String = object.dataGridColumn_videoPath;
		var name:String = object.dataGridColumn_videoName;
		if(path != null){
			var id:String = PathMaker.getVideoID(path);
			if(id != null){
				
				var nnddVideo:NNDDVideo = libraryManager.isExist(id);
				if(nnddVideo == null){
					nnddVideo = new NNDDVideo(path, name);
				}
				
				videoArray.push(nnddVideo);
				
			}else{
				missVideoPath.push(path);
				logManager.addLog("動画IDが見つかりませんでした。:" + path);
			}
		}
	}
	
	if(videoArray.length > 0){
		Alert.show("動画をダウンロードし直します。よろしいですか？(DLリストに追加します。)", Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
			if(event.detail == Alert.YES){
				for each(var video:NNDDVideo in videoArray){
					addDownloadList(video, -1);
				}
			}
		}, null, Alert.YES);
	}
	
	if(missVideoPath.length > 0){
		var str:String = "";
		for each(var temp:String in missVideoPath){
			if (str.length == 0) {
				str = temp;
			} else {
				str += ", " + temp;
			}
		}
		
		Alert.show("動画IDが見つからなかったため、次の動画を更新できませんでした。\n" + str);
	}
}

/**
 * DLリストを最後に追加した項目の場所までスクロールさせます。
 * 
 */
private function scrollToLastAddedDownloadItem():void{
	if(dataGrid_downloadList != null){
		dataGrid_downloadList.verticalScrollPosition = downloadProvider.length;
	}else{
		canvas_queue.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:Event):void{
			dataGrid_downloadList.verticalScrollPosition = downloadProvider.length;
		});
	}
}

/**
 * 
 * @param video
 * @param index
 * 
 */
private function addDownloadList(video:NNDDVideo, index:int = -1):void{
	
	var isExistsInDLList:Boolean = false;
	isExistsInDLList = downloadManager.isExists(video);
	
	if(isExistsInDLList){
		Alert.show(Message.M_ALREADY_DLLIST_VIDEO_EXIST + "\n\n" + video.getVideoNameWithVideoID(), Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
			if(event.detail == Alert.YES){
				downloadManager.add(video, isAutoDownload);
				if(index != -1 && rankingProvider.length > index){
					rankingProvider.setItemAt({
						dataGridColumn_preview: rankingProvider[index].dataGridColumn_preview,
						dataGridColumn_ranking: rankingProvider[index].dataGridColumn_ranking,
						dataGridColumn_videoName: rankingProvider[index].dataGridColumn_videoName,
						dataGridColumn_videoInfo: rankingProvider[index].dataGridColumn_videoInfo,
						dataGridColumn_condition: "DLリストに追加済",
						dataGridColumn_downloadedItemUrl: rankingProvider[index].dataGridColumn_downloadedItemUrl,
						dataGridColumn_nicoVideoUrl: rankingProvider[index].dataGridColumn_nicoVideoUrl
					}, index);
				}
				scrollToLastAddedDownloadItem();
			}
		}, null, Alert.NO);
	}else{
		if(!downloadManager.add(video, isAutoDownload)){
			Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
		}else{
			if(index != -1 && rankingProvider.length > index){
				rankingProvider.setItemAt({
					dataGridColumn_preview: rankingProvider[index].dataGridColumn_preview,
					dataGridColumn_ranking: rankingProvider[index].dataGridColumn_ranking,
					dataGridColumn_videoName: rankingProvider[index].dataGridColumn_videoName,
					dataGridColumn_videoInfo: rankingProvider[index].dataGridColumn_videoInfo,
					dataGridColumn_condition: "DLリストに追加済",
					dataGridColumn_downloadedItemUrl: rankingProvider[index].dataGridColumn_downloadedItemUrl,
					dataGridColumn_nicoVideoUrl: rankingProvider[index].dataGridColumn_nicoVideoUrl
				}, index);
			}
			scrollToLastAddedDownloadItem();
		}
	}
}

/**
 * 
 * @param video
 * 
 */
public function addDownloadListForInfoView(video:NNDDVideo):void{
	if(video != null){
		var isExistsInDLList:Boolean = false;
		isExistsInDLList = downloadManager.isExists(video);
		
		if(isExistsInDLList){
			this.activate();
			Alert.show(Message.M_ALREADY_DLLIST_VIDEO_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					if(!downloadManager.add(video, isAutoDownload)){
						Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
					}else{
						scrollToLastAddedDownloadItem();
					}
				}
			}, null, Alert.NO);
		}else{
			if(!downloadManager.add(video, isAutoDownload)){
				Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
			}else{
				scrollToLastAddedDownloadItem();
			}
		}
	}
}

/**
 * 
 * @param video
 * @param index
 * 
 */
public function addDownloadListForSearch(video:NNDDVideo, index:int = -1):void{
	var isExistsInDLList:Boolean = false;
	isExistsInDLList = downloadManager.isExists(video);
	
	if(isExistsInDLList){
		Alert.show(Message.M_ALREADY_DLLIST_VIDEO_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
			if(event.detail == Alert.YES){
				downloadManager.add(video, isAutoDownload);
				if(index != -1 && searchProvider.length > index){
					searchProvider.setItemAt({
						dataGridColumn_preview: searchProvider[index].dataGridColumn_preview,
						dataGridColumn_ranking: searchProvider[index].dataGridColumn_ranking,
						dataGridColumn_videoName: searchProvider[index].dataGridColumn_videoName,
						dataGridColumn_videoInfo: searchProvider[index].dataGridColumn_videoInfo,
						dataGridColumn_condition: "DLリストに追加済",
						dataGridColumn_downloadedItemUrl: searchProvider[index].dataGridColumn_downloadedItemUrl,
						dataGridColumn_nicoVideoUrl: searchProvider[index].dataGridColumn_nicoVideoUrl
					}, index);
				}
				scrollToLastAddedDownloadItem();
			}
		}, null, Alert.NO);
	}else{
		if(!downloadManager.add(video, isAutoDownload)){
			Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
		}else{
			if(index != -1 && searchProvider.length > index){
				searchProvider.setItemAt({
					dataGridColumn_preview: searchProvider[index].dataGridColumn_preview,
					dataGridColumn_ranking: searchProvider[index].dataGridColumn_ranking,
					dataGridColumn_videoName: searchProvider[index].dataGridColumn_videoName,
					dataGridColumn_videoInfo: searchProvider[index].dataGridColumn_videoInfo,
					dataGridColumn_condition: "DLリストに追加済",
					dataGridColumn_downloadedItemUrl: searchProvider[index].dataGridColumn_downloadedItemUrl,
					dataGridColumn_nicoVideoUrl: searchProvider[index].dataGridColumn_nicoVideoUrl
				}, index);
			}
			scrollToLastAddedDownloadItem();
		}
	}
}

/**
 * 動画のURLが変更されたときはDataGridのフォーカスを外します。
 * @param event
 * 
 */
private function textInputMurlChange(event:Event):void{
	dataGrid_ranking.selectedIndex = -1;
}

/**
 * 
 * @param event
 * 
 */
private function categoryListItemClicked(event:ListEvent):void{
	if(rankingRenewButton.label != Message.L_CANCEL){
		rankingRenewButtonClicked();
	}
}

/**
 * ランキングの更新ボタンが押されたときの動作
 * 
 */
private function rankingRenewButtonClicked(url:String = null):void{
	
	if(rankingRenewButton.label != Message.L_CANCEL){
		if(a2nForRanking == null){

			//選択中の期間、対象を保存
			this.period = int(this.radiogroup_period.selectedValue);
			this.target = int(this.radiogroup_target.selectedValue);
			
			// selectedIndexだと正しくない(画面で表示されている項目の上からいくつ目かという値）が取れてしまう事がある
			var selectedItem:Object = list_categoryList.selectedItem;
			var categoryListIndex:int = list_categoryList.selectedIndex;
			if(selectedItem != null){
				var i:int = 0;
				for each(var object:Object in categoryListProvider){
					if(selectedItem.toString() == object.toString()){
						categoryListIndex = i;
						break;
					}
					i++;
				}
			}
			
			trace(categoryListIndex);
			trace(selectedItem);
			
			try{
				//ランキングのURL
				var rankingURL:String;
				
				if(url == null){
					
					rankingProvider.removeAll();
					
					//urlが指定されていなければ
					if(this.radiogroup_period.selectedValue != 5){
						//普通のライブラリ更新
						combobox_pageCounter_ranking.selectedIndex = 0;
						
						this.rankingPageCountProvider = new Array();
						this.rankingPageCountProvider.push(1);
						this.rankingPageIndex = 1;
						rankingURL = Access2Nico.NICO_RANKING_URLS[this.radiogroup_period.selectedValue][this.radiogroup_target.selectedValue];
						setEnableTargetRadioButtons(true);
					}else{
						//新着の場合は期間を無視
						if(this.combobox_pageCounter_ranking.selectedIndex >= 0){
							this.rankingPageIndex = this.combobox_pageCounter_ranking.selectedIndex + 1;
							this.combobox_pageCounter_ranking.selectedIndex = 0;
							this.rankingPageCountProvider = new Array();
							
						}else{
							this.rankingPageIndex = 1;
							this.combobox_pageCounter_ranking.selectedIndex = 0;
							this.rankingPageCountProvider = new Array();
							
						}
						
						//ページインデックスを挿入
						for(var i:int = 0; i<10; i++){
							this.rankingPageCountProvider.push(i+1);
						}
						
						this.categoryListProvider = new Array();
						
						combobox_pageCounter_ranking.selectedIndex = rankingPageIndex - 1;
						
						rankingURL = Access2Nico.NICO_RANKING_URLS[this.radiogroup_period.selectedValue][0];
						setEnableTargetRadioButtons(false);
					}
				}else{
					//urlが指定されていれば
					rankingURL = url;
				}
				
				setEnableRadioButtons(false);
				rankingRenewButton.label = Message.L_CANCEL;
				list_categoryList.enabled = false;
				dataGrid_ranking.enabled = false;
				
				//ローディングウィンドウ
				loading = new LoadingPicture();
				loading.show(dataGrid_ranking, dataGrid_ranking.width/2, dataGrid_ranking.height/2);
				loading.start(360/12);
				
				a2nForRanking = new Access2Nico(null, downloadedListManager, null, logManager, null);
				a2nForRanking.addEventListener(Access2Nico.RANKING_GET_COMPLETE, function(event:Event):void{
					setEnableRadioButtons(true);
					rankingRenewButton.label = Message.L_RENEW;
					list_categoryList.enabled = true;
					dataGrid_ranking.enabled = true;
					
					rankingProvider = a2nForRanking.getRankingList();
					if(period != 5){
						categoryList = a2nForRanking.getCategoryTitleList();
						categoryListProvider = new Array(categoryList.length);
						for(var index:int = 0; index<categoryList.length;index++){
							categoryListProvider[index] = categoryList[index][0];
						}
					}
					
					logManager.addLog("ランキング更新:"+rankingURL+" page:"+rankingPageIndex);
					if(radiogroup_period.selectedValue != 5){
						logManager.addLog("カテゴリ更新:"+rankingURL);
					}
					
					if(rankingURL.indexOf("?") != -1){
						rankingURL = rankingURL.substring(0, rankingURL.lastIndexOf("?"));
					}
					
					if(radiogroup_period.selectedValue != 5){
						//通常のランキングのときのページリンク
					}else{
					}
					
					if(categoryListIndex != -1 && categoryList.length >= categoryListIndex ){
						list_categoryList.selectedIndex = categoryListIndex;
						list_categoryList.scrollToIndex(categoryListIndex);
					}
					
					a2nForRanking = null;
					loading.stop();
					loading.remove();
					loading = null;
				});
				
				var category:String = "all";
				if(categoryListIndex != -1 && categoryList.length > 0){
					category = categoryList[categoryListIndex][1];
				}
				
				if(period == 5){
					a2nForRanking.request_rankingRenew(period, target, category, rankingProvider, rankingPageIndex, new ArrayCollection());
				}else{
					a2nForRanking.request_rankingRenew(period, target, category, rankingProvider, 1, new ArrayCollection());
				}
			}catch(error:Error){
				trace(error.getStackTrace());
				setEnableRadioButtons(true);
				rankingRenewButton.label = Message.L_RENEW;
				list_categoryList.enabled = true;
				Alert.show("ランキング更新中に想定外の例外が発生しました。\n"+ error + "\nURL:" + rankingURL, "エラー");
				logManager.addLog("ランキング更新中に想定外の例外が発生しました。\n"+ "\nURL:"+rankingURL +error.getStackTrace() );
				a2nForRanking = null;
				if(loading != null){
					loading.stop();
					loading.remove();
					loading = null;
				}
				dataGrid_ranking.enabled = true;
			}
		}else if(rankingRenewButton.label == Message.L_CANCEL){
			a2nForRanking.rankingRenewCancel();
			a2nForRanking = null;
			rankingRenewButton.label = Message.L_RENEW;
			setEnableRadioButtons(true);
			rankingRenewButton.label = Message.L_RENEW;
			list_categoryList.enabled = true;
			dataGrid_ranking.enabled = true;
			
			loading.stop();
			loading.remove();
			loading = null;
		}else{
			Alert.show(Message.M_ALREADY_UPDATE_PROCESS_EXIST, Message.M_MESSAGE);
		}
	} else if(rankingRenewButton.label == Message.L_CANCEL){
		a2nForRanking.rankingRenewCancel();
		a2nForRanking = null;
		rankingRenewButton.label = Message.L_RENEW;
		setEnableRadioButtons(true);
		rankingRenewButton.label = Message.L_RENEW;
		list_categoryList.enabled = true;
		dataGrid_ranking.enabled = true;
		if(loading != null){
			loading.stop();
			loading.remove();
			loading = null;
		}

	}
}

/**
 * 
 * @param index
 * 
 */
private function downLoadedItemDoubleClicked(index:int):void{
	
	if(index > -1){
		this.playingVideoPath = this.downloadedListManager.getVideoPath(index);
		
		if(playListManager.isSelectedPlayList){
			
			var pIndex:int = playListManager.selectedPlayListIndex;
			
			playMovie(this.playingVideoPath, dataGrid_downloaded.selectedIndex, playListManager.getPlayList(pIndex));
		}else{
			playMovie(this.playingVideoPath, index);
		}
	}
}

/**
 * 
 * 
 */
private function downLoadedItemPlay():void{
	
	var index:int = this.dataGrid_downloaded.selectedIndex;
	if(index > -1){
		this.playingVideoPath = this.downloadedListManager.getVideoPath(index);
		playMovie(this.playingVideoPath, index);
	}
	
}

/**
 * 動画の再生を開始します。
 * @param url 動画のURLを指定します。
 * @param startIndex 動画のindexを指定します。これはプレイリストを使った再生の際に指定します。プレイリストを使わない場合は-1を指定してください。
 * @param playList プレイリストを使って再生する場合、プレイリストを指定します。Playerに渡されるプレイリストはこの配列のコピーです。
 * 
 */
public function playMovie(url:String, startIndex:int, playList:PlayList = null):void{
	
	try{
		if(url.length > 0){
			if(url.indexOf("http") == -1){
				var file:File = new File(url);
				
				if(!file.exists){
					var videoId:String = LibraryUtil.getVideoKey(decodeURIComponent(file.url));
					if(videoId != null){
						var video:NNDDVideo = libraryManager.isExist(videoId);
						if(video != null){
							file = new File(video.getDecodeUrl());
						}
					}
				}
				
				if(!file.exists){
					Alert.show(Message.M_FILE_NOT_FOUND_REFRESH + "\n" + file.nativePath, Message.M_ERROR);
					logManager.addLog(Message.M_FILE_NOT_FOUND_REFRESH + "\n" + file.nativePath);
					return;
				}
				url = file.url;
			}else{
//				url = url;
			}
			
			
			if(isEnableNativePlayer){
				
				playNative(url);
				
			}else{
				
				if(playerController == null){
					playerController = new PlayerController(MAILADDRESS, PASSWORD, playListManager)
					playerController.open();
				}else{
					if(!playerController.isOpen()){
						playerController.destructor();
						playerController = null;
						playerController = new PlayerController(MAILADDRESS, PASSWORD, playListManager)
						playerController.open();
					}
				}
				if(startIndex != -1 && playList != null){
					playerController.playMovie(url, playList, startIndex);
				}else{
					playerController.playMovie(url);
				}
			}
		}
	}catch(error:Error){
		Alert.show("再生に失敗しました\n" + url + "\n" + error, Message.M_ERROR);
		logManager.addLog("再生に失敗しました。\nurl:" + url + "\nError:" + error + ":" + error.getStackTrace());
	}
	
}

private function playNative(url:String):void{
	
	try{
		
		if(url.toLowerCase().indexOf("http") > -1){
			// ニコ動を直接
			NativeProcessPlayerManager.instance.play(url);
		}else{
			// DL済みファイル
			try{
				var file:File = new File(url);
				if(file.exists){
					NativeProcessPlayerManager.instance.play(file.nativePath);
				}else{
					Alert.show("動画ファイルが存在しません。", Message.M_ERROR);
				}
				
			}catch(error:Error){
				logManager.addLog("動画ファイルが存在しません:" + error);
				Alert.show("動画ファイルが存在しません。", Message.M_ERROR);
				trace(error.getStackTrace());
			}
		}
		
	}catch(error:Error){
		logManager.addLog("外部Player起動中に予期せぬ例外が発生しました:" + error);
		Alert.show("外部Player起動中に予期せぬ例外が発生しました。\n" + error, Message.M_ERROR);
		trace(error.getStackTrace());
	}
}


/**
 * 
 * 最新のコメントに更新
 */
private function newCommentDownloadButtonClicked(isCommentOnly:Boolean = false):void{
	if(newCommentDownloadButton.enabled == true && newCommentOnlyDownloadButton.enabled == true){
		if(this.newCommentDownloadButton.label != Message.L_CANCEL && this.newCommentOnlyDownloadButton.label != Message.L_CANCEL){
		
			if(this.dataGrid_downloaded.selectedIndex >= 0){
				
				if(isCommentOnly){
					this.newCommentOnlyDownloadButton.label = Message.L_CANCEL;
					this.newCommentDownloadButton.enabled = false;
				}else{
					this.newCommentDownloadButton.label = Message.L_CANCEL;
					this.newCommentOnlyDownloadButton.enabled = false;
				}
				
				var filePath:String = this.downloadedListManager.getVideoPath(this.dataGrid_downloaded.selectedIndex);
				if(filePath.indexOf("http://") == 0){
					newCommentOnlyDownloadButton.label = "コメント";
					newCommentDownloadButton.label = "動画以外";
					newCommentOnlyDownloadButton.enabled = true;
					newCommentDownloadButton.enabled = true;
					
					Alert.show("この動画はまだダウンロードされていません。先にダウンロードしてください。", Message.M_MESSAGE);
					return;
				}
				
				var fileName:String = filePath.substring(filePath.lastIndexOf("/")+1);
				
				var videoID:String = PathMaker.getVideoID(fileName);
//				trace(array);
				if(videoID == null){
//					trace(fileName);
					newCommentOnlyDownloadButton.label = "コメント";
					newCommentDownloadButton.label = "動画以外";
					newCommentOnlyDownloadButton.enabled = true;
					newCommentDownloadButton.enabled = true;
					if(isCommentOnly){
						logManager.addLog(Message.M_VIDEOID_NOTFOUND_FOR_COMMENT_ONLY + "\n" + filePath);
						Alert.show(Message.M_VIDEOID_NOTFOUND_FOR_COMMENT_ONLY, Message.M_ERROR);
					}else{
						logManager.addLog(Message.M_VIDEOID_NOTFOUND + "\n" + filePath);
						Alert.show(Message.M_VIDEOID_NOTFOUND, Message.M_ERROR);
					}
					return;
				}
				
				if(videoID.length >= 3){
					if(renewDownloadManager == null){
//						trace(videoID);
						fileName = PathMaker.getVideoName(filePath);
						var videoURL:String = "http://www.nicovideo.jp/watch/"+videoID;
						var index:int = this.dataGrid_downloaded.selectedIndex;
						
						if((filePath.substring(filePath.indexOf(this.libraryManager.libraryDir.url)+this.libraryManager.libraryDir.url.length+1)).indexOf("/") != -1){
							var rankingListName:String = filePath.substring(0,filePath.lastIndexOf("/"));
							rankingListName = rankingListName.substring(rankingListName.lastIndexOf("/")+1);
						}
						
						if(isCommentOnly){
							logManager.addLog("***コメントのみを更新***\n" + filePath);
						}else{
							logManager.addLog("***動画以外を更新***\n" + filePath);
						}
						
						renewDownloadManager = new RenewDownloadManager(downloadedProvider, logManager);
						renewDownloadManager.addEventListener(RenewDownloadManager.PROCCESS_FAIL, function(event:Event):void{
							newCommentOnlyDownloadButton.label = "コメント";
							newCommentDownloadButton.label = "動画以外";
				
							newCommentOnlyDownloadButton.enabled = true;
							newCommentDownloadButton.enabled = true;
							
							renewDownloadManager = null;
						});
						renewDownloadManager.addEventListener(RenewDownloadManager.PROCCESS_CANCEL, function(event:Event):void{
							newCommentOnlyDownloadButton.label = "コメント";
							newCommentDownloadButton.label = "動画以外";
				
							newCommentOnlyDownloadButton.enabled = true;
							newCommentDownloadButton.enabled = true;
							
							renewDownloadManager = null;
						});
						renewDownloadManager.addEventListener(RenewDownloadManager.PROCCESS_COMPLETE, function(event:Event):void{
							
							var video:NNDDVideo = libraryManager.remove(LibraryUtil.getVideoKey(filePath), false);
							if(video == null){
								if(!new File(filePath).exists){
									Alert.show("ファイルが見つかりませんでした。\n" + new File(filePath).nativePath, Message.M_ERROR);
									return;
								}
								video = new LocalVideoInfoLoader().loadInfo(filePath);
								video.modificationDate = new File(filePath).modificationDate;
								video.creationDate = new File(filePath).creationDate;
							}else{
								var tempVideo:NNDDVideo = new LocalVideoInfoLoader().loadInfo(filePath);
								video.time = tempVideo.time;
								video.pubDate = tempVideo.pubDate;
							}
							var thumbUrl:String = (event.currentTarget as RenewDownloadManager).localThumbUri;
							var isLocal:Boolean = false;
							try{
								//すでにローカルのファイルが設定されてるなら再設定しない。
								var file:File = new File(video.thumbUrl);
								if(file.exists){
									isLocal = true;
								}
							}catch(e:Error){
								trace(e);
							}
							
							//thumbUrlのURLがローカルで無ければ無条件で上書き
							if(!isLocal){
								if(thumbUrl != null){
									//新しく取得したthumbUrlを設定
									video.thumbUrl = thumbUrl;
								}else if (video.thumbUrl == null || video.thumbUrl == ""){
									//thumbUrlが取れない==動画は削除済
									var videoId:String = PathMaker.getVideoID(this._videoID);
									if(videoId != null){
										video.thumbUrl = PathMaker.getThumbImgUrl(videoId);
									}else{
										video.thumbUrl = "";
									}
								}
							}
							
							libraryManager.add(video, true);
							
							newCommentOnlyDownloadButton.label = "コメント";
							newCommentDownloadButton.label = "動画以外";
				
							newCommentOnlyDownloadButton.enabled = true;
							newCommentDownloadButton.enabled = true;
								
							renewDownloadManager = null;
						});
						
						if(isCommentOnly){
							renewDownloadManager.renewForCommentOnly(this.MAILADDRESS, 
								this.PASSWORD, PathMaker.getVideoID(filePath), 
								PathMaker.getVideoName(filePath), new File(filePath.substring(0, filePath.lastIndexOf("/")+1)), 
								this.isAppendComment, null, this.saveCommentMaxCount);
						}else{
							renewDownloadManager.renewForOtherVideo(this.MAILADDRESS, this.PASSWORD, 
								PathMaker.getVideoID(filePath), PathMaker.getVideoName(filePath), 
								new File(filePath.substring(0, filePath.lastIndexOf("/")+1)), 
								this.isAppendComment, null, this.saveCommentMaxCount);
						}
						
					}else{
						Alert.show("更新が既に進行中です。", Message.M_MESSAGE);
					}
				}else{
					trace(fileName);
					newCommentOnlyDownloadButton.label = "コメント";
					newCommentDownloadButton.label = "動画以外";
					newCommentOnlyDownloadButton.enabled = true;
					newCommentDownloadButton.enabled = true;
					if(isCommentOnly){
						logManager.addLog(Message.M_VIDEOID_NOTFOUND_FOR_COMMENT_ONLY + "\n" + filePath);
						Alert.show(Message.M_VIDEOID_NOTFOUND_FOR_COMMENT_ONLY, Message.M_ERROR);
					}else{
						logManager.addLog(Message.M_VIDEOID_NOTFOUND + "\n" + filePath);
						Alert.show(Message.M_VIDEOID_NOTFOUND, Message.M_ERROR);
					}
				}
			}
		}else{
			
			newCommentOnlyDownloadButton.label = "コメント";
			newCommentDownloadButton.label = "動画以外";
			
			renewDownloadManager.close();
			renewDownloadManager = null;
			
			newCommentOnlyDownloadButton.enabled = true;
			newCommentDownloadButton.enabled = true;
		}
	}
}

/**
 * 
 * 
 */
private function searchDLListTextInputChange():void{
	
	if(textInput_searchInDLList.text == "リスト内を検索"){
		return;
	}
	this.downloadedListManager.searchAndShow(dataGrid_downloaded, tileList_tag, textInput_searchInDLList.text);
}

/**
 * 
 * 
 */
private function searchTagListTextInputChange():void{
	
	if(isEnableLibrary){
		var word:String = textInput_searchInTagList.text;
		
		if(word == "タグを検索"){
			return;
		}
		
		if(word.length > 0){
			tileList_tag.dataProvider = this.libraryManager.searchTagAndShow(word);
		}else{
			if(!this.playListManager.isSelectedPlayList){
				if(this._selectedLibraryFile == null){
					tagManager.tagRenew(tileList_tag, this.libraryManager.libraryDir);
				}else{
					tagManager.tagRenew(tileList_tag, this._selectedLibraryFile);
				}
			}else{
				
				if(playListManager.selectedPlayListIndex > 0){
					tagManager.tagRenewOnPlayList(tileList_tag, playListManager.getNNDDVideoListByIndex(playListManager.selectedPlayListIndex));
				}else{
					tagManager.tagRenewOnPlayList(tileList_tag, new Vector.<NNDDVideo>());
				}
			}
		}
	}
	
}

/**
 * 指定されたITreeItem下の項目を更新します
 */
private function updateLibraryTree(item:ITreeItem):void{
	
	if(item != null){
		
		if(item is TreeFolderItem){
			if(item.file != null){
				var libraryTreeBuilder:LibraryTreeBuilder = new LibraryTreeBuilder();
				(item as TreeFolderItem).children = libraryTreeBuilder.buildOnlyChildDir(item as TreeFolderItem);
			}
		}
		
		var openItems:Array = (tree_library.openItems as Array);
		if(openItems.indexOf(item) == -1){
			openItems.push(item);
		}
		
		tree_library.openItems = openItems;
		
		tree_library.invalidateDisplayList();
		tree_library.validateNow();
		
		tree_library.selectedItem = item;
		
		updateLibrary(tree_library.selectedIndex);
		
	}
	
}

/**
 * ライブラリのツリーが選択されたときに呼ばれます。
 * 
 */
private function updateLibrary(index:int):void{
	if(isEnableLibrary){
		
		logManager.addLog("***ライブラリ表示開始***");
		
		var searchWord:String = textInput_searchInDLList.text;
		var tagSearchWord:String = textInput_searchInTagList.text;
		var tagIndices:Array = null;
		if(tileList_tag != null){
			tagIndices = tileList_tag.selectedIndices;
		}
		textInput_searchInDLList.text = "";
		if(searchWord.length > 0){
			searchDLListTextInputChange();
		}
		textInput_searchInTagList.text = "";
		if(tagSearchWord.length > 0){
			searchTagListTextInputChange();
		}
		
		this.playListManager.isSelectedPlayList = false;
		
		if(index > -1){
			var item:ITreeItem = (tree_library.selectedItem as ITreeItem);
			this._selectedLibraryFile = item.file;
			this.tagManager.tagRenew(tileList_tag, _selectedLibraryFile);
			this.downloadedListManager.updateDownloadedListItems(this._selectedLibraryFile.url, this.showAll);
		}else if(index == -1){
			this.tagManager.tagRenew(tileList_tag, this.libraryManager.libraryDir);
			this.downloadedListManager.updateDownloadedListItems(this.libraryManager.libraryDir.url, this.showAll);
		}
		
		if(tileList_tag != null){
			tileList_tag.selectedIndices = tagIndices;
		}
		textInput_searchInDLList.text = searchWord;
		if(searchWord.length > 0){
			searchDLListTextInputChange();
		}
		textInput_searchInTagList.text = tagSearchWord;
		if(tagSearchWord.length > 0){
			searchTagListTextInputChange();
		}
		(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort = new Sort();
		(this.dataGrid_downloaded.dataProvider as ArrayCollection).sort.fields = [new SortField(this.libraryDataGridSortFieldName, false, this.libraryDataGridSortDescending)];
		(this.dataGrid_downloaded.dataProvider as ArrayCollection).refresh();
		
		logManager.addLog("***ライブラリ表示完了***");
		
	}
}

/**
 * 
 * @param event
 * 
 */
private function fileNameEdit():void{
	var item:ITreeItem = (tree_library.selectedItem as ITreeItem);
	var index:int = tree_library.selectedIndex;
	if(item == null){
		return;
	}
	var file:File = item.file;
	var url:String = decodeURIComponent(file.url);
	
	if(url == null || url.length < -1 || libraryManager.libraryDir.url == new File(url).url){
		return;
	}
	
	var nameEditDialog:NameEditDialog = PopUpManager.createPopUp(nndd, NameEditDialog, true) as NameEditDialog;
	nameEditDialog.initNameEditDialog(url);
	nameEditDialog.addEventListener(Event.COMPLETE, function():void{
		if(item != null){
			updateLibraryTree(item.parent);
		}
	});
	// ダイアログを中央に表示
	PopUpManager.centerPopUp(nameEditDialog);
}

/**
 * 
 * @param event
 * 
 */
private function playListNameEdit():void{
	var selectedIndex:int = tree_library.selectedIndex;
	if(selectedIndex == -1){
		return;
	}
	var url:String = libraryManager.systemFileDir.url + "/playList/" + tree_library.selectedItem.label;
	
	if(url.toUpperCase().indexOf(".M3U") == -1){
		return;
	}
	selectedIndex = playListManager.getPlayListIndexByName(tree_library.selectedItem.label);
	
	var nameEditDialog:NameEditDialog = PopUpManager.createPopUp(nndd, NameEditDialog, true) as NameEditDialog;
	nameEditDialog.initNameEditDialog(url, true);
	nameEditDialog.label_info.text = "新しいプレイリスト名を入力してください。";
	nameEditDialog.addEventListener(Event.COMPLETE, function():void{
		var newUrl:String = nameEditDialog.getNewFilePath();
		if(newUrl.toUpperCase().indexOf(".M3U") == -1){
			newUrl = newUrl + ".m3u";
		}
		
		trace(newUrl);
		
		playListManager.reNamePlayList(selectedIndex, decodeURIComponent(newUrl.substring(newUrl.lastIndexOf("/")+1)));
		
		updatePlayListSummery();
	});
	// ダイアログを中央に表示
	PopUpManager.centerPopUp(nameEditDialog);
}

/**
 * 
 * @param event
 * 
 */
private function checkBoxShowAllChanged(event:Event):void{
	
	this.showAll = checkBox_showAll.selected;
	
	if(tree_library != null && !playListManager.isSelectedPlayList){
		updateLibrary(tree_library.selectedIndex);
	}
}

/**
 * 
 * 
 */
private function addDirectory():void{
	
	var url:String = libraryManager.libraryDir.url;
	if(tree_library.selectedIndex > -1){
		var tempFile:File = (tree_library.selectedItem as ITreeItem).file;
		url = decodeURIComponent(tempFile.url);
	}
	var pFile:File = new File(url);
	var array:Array = pFile.getDirectoryListing();
	var newFileUrl:String = url + "/新規フォルダ"
	
	var file:File = new File(newFileUrl);
	for(var i:int; i<array.length; i++){
		if(!file.exists){
			break;
		}
		file = new File(newFileUrl+(i+1));
	}
	try{
		file.createDirectory();
		
		var item:ITreeItem = (tree_library.selectedItem as ITreeItem);
		if(item != null){
			updateLibraryTree(item);
		}
	}catch(e:Error){
		Alert.show("フォルダの作成に失敗しました。" + e, "エラー");
		logManager.addLog("フォルダの作成に失敗しました:" + e.getStackTrace());
	}
	
}

/**
 * 
 * 
 */
private function deleteDirectory():void{
	var selectedItem:ITreeItem = (tree_library.selectedItem as ITreeItem);
	var selectedIndex:int = tree_library.selectedIndex;
	var tempFile:File = selectedItem.file;
	
	if(tempFile != null && tree_library.selectedIndex > -1 && !(tempFile.url == libraryManager.libraryDir.url)){
		try{
			Alert.show("フォルダ内のすべての項目も同時に削除されます。よろしいですか？", "警告", Alert.YES | Alert.NO, null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					var url:String = decodeURIComponent(tempFile.url);
					var file:File = new File(url);
					file.moveToTrash();
					if(selectedItem != null){
						updateLibraryTree(selectedItem.parent);
					}
				}
			}, null, Alert.NO);
			
		}catch(e:Error){
			Alert.show("フォルダの削除に失敗しました。" + e, "エラー");
			logManager.addLog("フォルダの削除に失敗しました:" + e.getStackTrace());
		}
	}else if(tempFile.nativePath == libraryManager.libraryDir.nativePath){
		Alert.show("ライブラリフォルダそのものを消す事は出来ません。", Message.M_MESSAGE, Alert.OK);
	}
}

/**
 * 
 * 
 */
private function logoutButtonClicked():void{
	
	if(logoutButton.label == "ログイン"){
		
		var confValue:String = ConfigManager.getInstance().getItem("storeNameAndPass");
		var isStore:Boolean = ConfUtil.parseBoolean(confValue);
		var name:String = "";
		var pass:String = "";
		if(isStore){
			var storedValue:ByteArray = EncryptedLocalStore.getItem("userName");
			if(storedValue != null){
				name = storedValue.readUTFBytes(storedValue.length);
			}
			storedValue = EncryptedLocalStore.getItem("password");
			if(storedValue != null){
				pass = storedValue.readUTFBytes(storedValue.length);
			}
		}
		
		createLoginDialog(isStore, false, name, pass, false);
		
	}else{
		this.logoutButton.enabled = false;
		saveStore();
		this.logout();
	}
}

/**
 * ニコニコ動画からのログアウトを行います。
 * 
 */
private function logout(isBootTime:Boolean = true):void
{
	var loader:URLLoader = new URLLoader();
	
	var login:Login = new Login();
	login.addEventListener(Login.LOGOUT_COMPLETE, function(event:Event):void{
		if(isBootTime){
			readStore(true);
		}
		logoutButton.enabled = true;
		logoutButton.label = "ログイン";
	});
	
	this.MAILADDRESS = "";
	this.PASSWORD = "";
	
	if(this.downloadManager != null){
		this.downloadManager.stop();
		this.downloadManager.setMailAndPass(this.MAILADDRESS, this.PASSWORD);
	}
	
	login.logout();
	logManager.addLog(logoutButton.label);
	
}

private function windowMove(event:FlexNativeWindowBoundsEvent):void{
	lastRect = event.afterBounds;
}

private function saveStore():void{
		
	try{
		
		//現在の保存先を保存
		ConfigManager.getInstance().removeItem("libraryURL");
		ConfigManager.getInstance().setItem("libraryURL", libraryManager.libraryDir.url);
		
		// ウィンドウの位置情報保存
		ConfigManager.getInstance().removeItem("windowPosition_x");
		ConfigManager.getInstance().setItem("windowPosition_x", lastRect.x);
		
		ConfigManager.getInstance().removeItem("windowPosition_y");
		ConfigManager.getInstance().setItem("windowPosition_y", lastRect.y);
		
		ConfigManager.getInstance().removeItem("windowPosition_w");
		ConfigManager.getInstance().setItem("windowPosition_w", lastRect.width);
		
		ConfigManager.getInstance().removeItem("windowPosition_h");
		ConfigManager.getInstance().setItem("windowPosition_h", lastRect.height);
		
		//挨拶
		ConfigManager.getInstance().removeItem("isSayHappyNewYear");
		ConfigManager.getInstance().setItem("isSayHappyNewYear", isSayHappyNewYear);
		
		//自動DL
		ConfigManager.getInstance().removeItem("isAutoDownload");
		ConfigManager.getInstance().setItem("isAutoDownload", isAutoDownload);
		
		//エコノミー時の確認有無
		ConfigManager.getInstance().removeItem("isEnableEcoCheck");
		ConfigManager.getInstance().setItem("isEnableEcoCheck", isEnableEcoCheck);
		
		//選択されているランキング期間
		ConfigManager.getInstance().removeItem("rankingTarget");
		ConfigManager.getInstance().setItem("rankingTarget", this.target);
		
		//選択されているランキング対象
		ConfigManager.getInstance().removeItem("rankingPeriod");
		ConfigManager.getInstance().setItem("rankingPeriod", this.period);
		
		//起動時更新をしないかどうか
		ConfigManager.getInstance().removeItem("isRankingRenewAtStart");
		ConfigManager.getInstance().setItem("isRankingRenewAtStart", isRankingRenewAtStart);
		
		/*サイドバーのプレイリストの高さを保存*/
		if(this.lastCanvasPlaylistHight != -1){
			ConfigManager.getInstance().removeItem("lastCanvasPlaylistHight");
			ConfigManager.getInstance().setItem("lastCanvasPlaylistHight", lastCanvasPlaylistHight);
		}
		
		/*サムネイルの大きさを保存*/
		if(this.thumbImageSize != -1){
			ConfigManager.getInstance().removeItem("thumbImageSize");
			ConfigManager.getInstance().setItem("thumbImageSize", thumbImageSize);
		}
		
		if(this.thumbImgSizeForMyList != -1){
			ConfigManager.getInstance().removeItem("thumbImgSizeForMyList");
			ConfigManager.getInstance().setItem("thumbImgSizeForMyList", thumbImgSizeForMyList);
		}
		
		if(this.thumbImgSizeHistory != -1){
			ConfigManager.getInstance().removeItem("thumbImgSizeHistory");
			ConfigManager.getInstance().setItem("thumbImgSizeHistory", thumbImgSizeHistory);
		}
		
		if(this.thumbImgSizeForDLList != -1){
			ConfigManager.getInstance().removeItem("thumbImgSizeForDLList");
			ConfigManager.getInstance().setItem("thumbImgSizeForDLList", thumbImgSizeForDLList);
		}
		
		if(this.thumbImgSizeForLibrary != -1){
			ConfigManager.getInstance().removeItem("thumbImgSizeForLibrary");
			ConfigManager.getInstance().setItem("thumbImgSizeForLibrary", thumbImgSizeForLibrary);
		}
		
		if(this.thumbImgSizeForSearch != -1){
			ConfigManager.getInstance().removeItem("thumbImgSizeForSearch");
			ConfigManager.getInstance().setItem("thumbImgSizeForSearch", thumbImgSizeForSearch);
		}
		
		/*タグビューの大きさを保存*/
		if(this.lastCanvasTagTileListHight != -1){
			ConfigManager.getInstance().removeItem("lastCanvasTagTileListHight");
			ConfigManager.getInstance().setItem("lastCanvasTagTileListHight", lastCanvasTagTileListHight);
		}
		
		/*すべてのタグを表示するか*/
//		EncryptedLocalStore.removeItem("isShowOnlyNowLibraryTag");
//		bytes = new ByteArray();
//		bytes.writeBoolean(isShowOnlyNowLibraryTag);
//		EncryptedLocalStore.setItem("isShowOnlyNowLibraryTag", bytes);
		
		/*常にエコノミーモードでダウンロードするかどうか*/
		ConfigManager.getInstance().removeItem("isAlwaysEconomy");
		ConfigManager.getInstance().setItem("isAlwaysEconomy", isAlwaysEconomy);
		
		/* ランキングダブルクリックでストリーミング再生するかどうか */
		ConfigManager.getInstance().removeItem("isDoubleClickOnStreaming");
		ConfigManager.getInstance().setItem("isDoubleClickOnStreaming", isDoubleClickOnStreaming);
		
		/* 外部ストリーミングプレーヤ設定 */
		ConfigManager.getInstance().removeItem("isOutStreamingPlayerUse");
		ConfigManager.getInstance().setItem("isOutStreamingPlayerUse", isOutStreamingPlayerUse);
		
		/* カテゴリリストの横幅 */
		if(this.lastCategoryListWidth != -1){
			ConfigManager.getInstance().removeItem("lastCategoryListWidth");
			ConfigManager.getInstance().setItem("lastCategoryListWidth", lastCategoryListWidth);
		}
		
		/* ライブラリの横幅 */
		if(this.lastLibraryWidth != -1){
			ConfigManager.getInstance().removeItem("lastLibraryWidth");
			ConfigManager.getInstance().setItem("lastLibraryWidth", lastLibraryWidth);
		}
		
		/* マイリストの高さ */
		if(this.lastMyListHeight != -1){
			ConfigManager.getInstance().removeItem("lastMyListHeight");
			ConfigManager.getInstance().setItem("lastMyListHeight", lastMyListHeight);
		}
		
		/* マイリスト一覧の横幅 */
		if(this.lastMyListSummaryWidth != -1){
			ConfigManager.getInstance().removeItem("lastMyListSummaryWidth");
			ConfigManager.getInstance().setItem("lastMyListSummaryWidth", lastMyListSummaryWidth);
		}
		
		/* 検索条件一覧の横幅 */
		if(this.lastSearchItemListWidth != -1){
			ConfigManager.getInstance().removeItem("lastSearchItemListWidth");
			ConfigManager.getInstance().setItem("lastSearchItemListWidth", lastSearchItemListWidth);
		}
		
		/* ライブラリを特定のフィールドでソートするかどうか */
		if(this.libraryDataGridSortFieldName != null && this.libraryDataGridSortFieldName != ""){
			ConfigManager.getInstance().removeItem("libraryDataGridSortFieldName");
			ConfigManager.getInstance().setItem("libraryDataGridSortFieldName", libraryDataGridSortFieldName);
		}
		
		/* ライブラリを降順に並べるかどうか */
		ConfigManager.getInstance().removeItem("libraryDataGridSortDescending");
		ConfigManager.getInstance().setItem("libraryDataGridSortDescending", libraryDataGridSortDescending);
		
		/* ライブラリを使うかどうか */
		ConfigManager.getInstance().removeItem("isEnableLibrary");
		ConfigManager.getInstance().setItem("isEnableLibrary", isEnableLibrary);
		
		/* デフォルトの検索項目が追加済かどうか */
		ConfigManager.getInstance().removeItem("isAddedDefSearchItems");
		ConfigManager.getInstance().setItem("isAddedDefSearchItems", isAddedDefSearchItems);
		
		/* メインウィンドウを閉じてもアプリケーションを終了しないかどうか*/
		ConfigManager.getInstance().removeItem("isDisEnableAutoExit");
		ConfigManager.getInstance().setItem("isDisEnableAutoExit", isDisEnableAutoExit);
		
		/* コメントを更新したときに古いファイルを別名保存するかどうか */
		ConfigManager.getInstance().removeItem("isAppendComment");
		ConfigManager.getInstance().setItem("isAppendComment", isAppendComment);

		/* 起動時にバージョンチェックをするかどうか */
		ConfigManager.getInstance().removeItem("isVersionCheckEnable");
		ConfigManager.getInstance().setItem("isVersionCheckEnable", isVersionCheckEnable);
		
		/* Downloadフォルダを作ってそこにダウンロードするかどうか */
		ConfigManager.getInstance().removeItem("iseUsDownloadDir");
		ConfigManager.getInstance().setItem("isUseDownloadDir", isUseDownloadDir);
		
		/* マイリスト更新のスケジュール */
		ConfigManager.getInstance().removeItem("myListRenewScheduleTime");
		ConfigManager.getInstance().setItem("myListRenewScheduleTime", this.myListRenewScheduleTime);
		
		/* マイリスト更新１つあたりの間隔 */
		ConfigManager.getInstance().removeItem("myListRenewDelayOfMylist");
		ConfigManager.getInstance().setItem("myListRenewDelayOfMylist", MyListRenewScheduler.instance.delayOfMylist);
		
		/* マイリスト自動更新の有無 */
		ConfigManager.getInstance().removeItem("mylistRenewOnScheduleEnable");
		ConfigManager.getInstance().setItem("mylistRenewOnScheduleEnable", this.mylistRenewOnScheduleEnable);
		
		/* 検索履歴保存有無 */
		ConfigManager.getInstance().removeItem("isSaveSearchHistory");
		ConfigManager.getInstance().setItem("isSaveSearchHistory", this.isSaveSearchHistory);
		
		if(this.viewstack1 != null){
			/* 選択中のタブ */
			ConfigManager.getInstance().removeItem("selectedTabIndex");
			ConfigManager.getInstance().setItem("selectedTabIndex", this.viewstack1.selectedIndex);
		}
		
		/* 保存コメント最大数 */
		ConfigManager.getInstance().removeItem("saveCommentMaxCount");
		ConfigManager.getInstance().setItem("saveCommentMaxCount", this.saveCommentMaxCount);
		
		/* フォルダ内表示時にサブディレクトリの項目も見せるかどうか */
		ConfigManager.getInstance().removeItem("showAll");
		ConfigManager.getInstance().setItem("showAll", this.showAll);
		
		/* 外部プレーヤを有効にするかどうか */
		ConfigManager.getInstance().removeItem("isEnableNativePlayer");
		ConfigManager.getInstance().setItem("isEnableNativePlayer", this.isEnableNativePlayer);
		
		/* ライブラリファイルをアプリケーションディレクトリに保存するかどうか */
		ConfigManager.getInstance().removeItem("useAppDirLibFile");
		ConfigManager.getInstance().setItem("useAppDirLibFile", this.useAppDirLibFile);
		
		
		
		ConfigManager.getInstance().save();
		
	}catch(error:Error){
		logManager.addLog(Message.FAIL_SAVE_CONF_FILE_FOR_NNDD_MAIN_WINDOW + ":" + Message.M_CONF_FILE_IS_BROKEN + ":" + ConfigManager.getInstance().confFileNativePath + ":" + error);
		trace(error.getStackTrace());
	}
	
	try{
		
		/*タイマー設定*/
		if(this.scheduleManager != null){
			this.scheduleManager.saveSchedule();
		}
		
	}catch(error:Error){
		logManager.addLog(error + ":" + error.getStackTrace());
		trace(error.getStackTrace());
	}
	
	try{
		
		/*ダウンロードリスト保存*/
		if(this.downloadManager != null){
			this.downloadManager.stop();
			this.downloadManager.saveDownloadList();
		}
		
	}catch(error:Error){
		logManager.addLog(error + ":" + error.getStackTrace());
		trace(error.getStackTrace());
	}
	
}

/**
 * 
 * 
 */
public function exitButtonClicked():void{
	
	logManager.addLog("終了処理を開始");
	
	var timer:Timer = new Timer(200, 1);
	
	var loadWindow:LoadWindow = PopUpManager.createPopUp(nndd, LoadWindow, true) as LoadWindow;
	loadWindow.label_loadingInfo.text = "設定を保存しています...";
	loadWindow.progressBar_loading.label = "保存中...";
	PopUpManager.centerPopUp(loadWindow);
	
	if(playerController != null && playerController.isOpen() ){
		playerController.stop();
	}
	
	timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void{
		
		restore();
		
		if(playerController != null && playerController.isOpen() ){
			playerController.playerExit();
		}
		
		saveStore();
		
		loadWindow.label_loadingInfo.text = "ダウンロードリストを保存しています...";
		loadWindow.validateNow();
		//ダウンロードリスト保存
		downloadManager.stop();
		downloadManager.saveDownloadList();
		
		loadWindow.label_loadingInfo.text = "プレイリストを保存しています...";
		loadWindow.validateNow();
		//プレイリスト保存
		playListManager.saveAllPlayList()
		
		loadWindow.label_loadingInfo.text = "ライブラリを保存しています...";
		loadWindow.validateNow();
		//ライブラリ保存
		libraryManager.saveLibrary();
		
		loadWindow.label_loadingInfo.text = "マイリスト一覧を保存しています...";
		loadWindow.validateNow();
		//マイリストを保存
		_myListManager.saveMyListSummary(libraryManager.systemFileDir);
		
		loadWindow.label_loadingInfo.text = "検索条件を保存しています...";
		loadWindow.validateNow();
		//検索条件を保存
		_searchItemManager.saveSearchItems(libraryManager.systemFileDir);
		
		loadWindow.label_loadingInfo.text = "再生履歴を保存しています...";
		loadWindow.validateNow();
		//再生履歴を保存
		historyManager.saveHistory();
		
		loadWindow.label_loadingInfo.text = "タグフィルタ情報を保存しています...";
		loadWindow.validateNow();
		//NGタグを保存
		ngTagManager.saveNgTags();
		
		PopUpManager.removePopUp(loadWindow);
		
		_exitProcessCompleted = true;
		
		logManager.addLog("終了処理完了");
		
		exit();
		
	});
	
	timer.start();
	

}

/**
 * 
 * 
 */
private function windowClose(event:Event):void{
	
	if(event.cancelable){
		event.preventDefault();
	}
	
	if(isDisEnableAutoExit && ( NativeApplication.supportsSystemTrayIcon || NativeApplication.supportsDockIcon)){
		
		this.visible = false;
		
	}else{	//システムトレイもDockもサポートしていないときはアプリケーションを終了
		
		exitButtonClicked();
		
	}
}

private function exitingEventHandler(event:Event):void{
	
	logManager.addLog(event.toString());
	
	if(!_exitProcessCompleted){
		
		event.preventDefault();
		
		this.activate();
		
		exitButtonClicked();
		
	}
	
}

protected function searchHistoryClearButtonClicked(event:Event):void{
	searchHistoryProvider.splice(0, searchHistoryProvider.length);
	saveSearchHistory(searchHistoryProvider);
}

private function addSearchHistory(word:String):void{
	
	var exist:Boolean = false;
	for(var index:int = 0; searchHistoryProvider.length > index; index++ ){
		if(searchHistoryProvider[index] == word){
			searchHistoryProvider.splice(index, 1);
			break;
		}
	}
	
	searchHistoryProvider.splice(0,0,word);
	
	if(searchHistoryProvider.length > 10){
		searchHistoryProvider.splice(10, searchHistoryProvider.length-10);
	}
	
	if(isSaveSearchHistory){
		saveSearchHistory(searchHistoryProvider);
	}else{
		saveSearchHistory(new Array());
	}
	
	this.combobox_NicoSearch.invalidateDisplayList();
	this.combobox_NicoSearch.validateNow();
}

private function saveSearchHistory(searchHistoryProvider:Array):void{
	
	for(var index:int = 0; 10 >= index; index++){
		ConfigManager.getInstance().removeItem("searchHistory" + index);
		if(index >= searchHistoryProvider.length){
			
		}else{
			ConfigManager.getInstance().setItem("searchHistory" + index, encodeURIComponent(searchHistoryProvider[index]));
		}
	}
	
	if(searchHistoryProvider.length > 0){
		ConfigManager.getInstance().save();
	}
}

private function loadSearchHistory():void{
	
	for(var index:int = 0; 10 >= index; index++){
		var value:String = ConfigManager.getInstance().getItem("searchHistory" + index);
		if(value != null){
			searchHistoryProvider[index] = decodeURIComponent(value);
		}else{
			ConfigManager.getInstance().removeItem("searchHistory" + index);
		}
	}
	
	if(this.combobox_NicoSearch != null){
		this.combobox_NicoSearch.invalidateDisplayList();
		this.combobox_NicoSearch.validateNow();
	}
}


/**
 * ニコニコ動画内を検索語で検索します。
 * 
 */
private function searchNicoButtonClicked(url:String = null):void{
	if(a2nForSearch == null){
		if(combobox_NicoSearch.text.length > 0 || url != null){
			
			isRankingWatching = false;
			
			var searchWord:String = this.combobox_NicoSearch.text;
			addSearchHistory(searchWord);
			
			var searchUrl:String = Access2Nico.NICO_SEARCH_TYPE_URL[combobox_serchType.selectedIndex];
			searchPageCountProvider = new Array();
			if(url != null){
				searchWord = url.substring(url.lastIndexOf("/")+1);
			}else{
				searchPageCountProvider.push(1);
				combobox_pageCounter_search.selectedIndex = searchPageCountProvider.indexOf(1);
				searchWord = encodeURIComponent(searchWord);
				this.searchPageIndex = 1;
			}
			
			try{
				
				loading = new LoadingPicture();
				loading.show(dataGrid_search, dataGrid_ranking.width/2, dataGrid_ranking.height/2);
				loading.start(360/12);
				
//				setEnableSearchButton(false);
//				radiogroup_period.enabled = false;
//				radiogroup_target.enabled = false;
//				rankingRenewButton.enabled = false;
//				list_categoryList.enabled = false;
				button_SearchNico.label = Message.L_CANCEL;
				
				a2nForSearch = new Access2Nico(null, downloadedListManager, null, logManager, null);
				a2nForSearch.addEventListener(Access2Nico.NICO_SEARCH_COMPLETE, function(event:Event):void{
//					setEnableSearchButton(true);
//					radiogroup_period.enabled = true;
//					radiogroup_target.enabled = true;
//					rankingRenewButton.enabled = true;
//					list_categoryList.enabled = true;
					button_SearchNico.label = "検索";
					searchPageLinkList = a2nForSearch.getPageLinkList();
					
					//リンクリストを更新
					if(searchPageLinkList != null){
						searchPageCountProvider.splice(0,searchPageCountProvider.length);
						searchPageCountProvider.push(searchPageIndex);
						for(var i:int=0; i<searchPageLinkList.length/2; i++){
							searchPageCountProvider.push(searchPageLinkList[i][1]);
						}
					}
					label_totalCount.text = "(合計: " + searchPageCountProvider.length + "ページ )";
					logManager.addLog("検索結果を更新:"+ decodeURIComponent(searchUrl + searchWord));
					
					a2nForSearch = null;
					loading.stop();
					loading.remove();
					loading = null;
				});
				a2nForSearch.request_search(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, this.MAILADDRESS, this.PASSWORD, searchUrl, searchWord , searchProvider, comboBox_sortType.selectedIndex, this.searchPageIndex);
			}catch(error:Error){
//				setEnableSearchButton(true);
//				radiogroup_period.enabled = true;
//				radiogroup_target.enabled = true;
//				rankingRenewButton.enabled = true;
//				list_categoryList.enabled = true;
				loading.stop();
				loading.remove();
				loading = null;
				button_SearchNico.label = "検索";
				Alert.show("検索中に想定外の例外が発生しました。\n"+ error + "\nURL:" + searchUrl + encodeURIComponent(searchWord), "エラー");
				logManager.addLog("検索中に想定外の例外が発生しました。\n"+ error +  "\nURL:"+ searchUrl + encodeURIComponent(searchWord) + "\n" + error.getStackTrace() );
				a2nForSearch = null;
			}
		}
	}else if(button_SearchNico.label == Message.L_CANCEL){
		a2nForSearch.searchCancel();
		a2nForSearch = null;
//		setEnableSearchButton(true);
//		radiogroup_period.enabled = true;
//		radiogroup_target.enabled = true;
//		rankingRenewButton.enabled = true;
//		list_categoryList.enabled = true;
		button_SearchNico.label = "検索";
		if(loading != null){
			loading.stop();
			loading.remove();
			loading = null;
		}
	}else{
	}
}

/**
 * 
 * @param event
 * 
 */
private function nicoSearchComboboxClosed(event:Event):void{
	var index:int = comboBox_sortType.selectedIndex;
	
	if(index != -1){
		ConfigManager.getInstance().setItem("searchSortTypeIndex", index);
	}
	
	searchNicoButtonClicked();
}

/**
 * 
 * @param event
 * 
 */
private function nicoSearchEnter(event:Event):void{
	var index:int = combobox_serchType.selectedIndex;
	
	if(index != -1){
		ConfigManager.getInstance().setItem("searchTypeIndex", index);
	}
	
	searchNicoButtonClicked();
}

/**
 * 
 * 
 */
private function versionCheckCheckBoxChenged():void{
	isVersionCheckEnable = checkBox_versionCheck.selected;
}

private function useDownloadDirCheckBoxChenged():void{
	isUseDownloadDir = checkBox_useDownloadDir.selected;
	this.downloadManager.isUseDownloadDir = isUseDownloadDir;
}

private function disEnableAutoExitCheckBoxChanged(event:Event):void{
	
	this.isDisEnableAutoExit = checkBox_DisEnableAutoExit.selected;
	
	this.autoExit = !isDisEnableAutoExit;
	
}

/**
 * ページ数選択用コンボボックスの値が変更されたときに呼ばれます
 * 
 */
private function rankingPageCountChanged():void{
	if(combobox_pageCounter_ranking.selectedIndex >= 0 ){
		this.rankingPageIndex = combobox_pageCounter_ranking.selectedIndex;
		
		rankingRenewButtonClicked();
		
//		rankingPageCountProvider.unshift(rankingPageIndex);
//		combobox_pageCounter_ranking.selectedIndex = rankingPageCountProvider.indexOf(rankingPageIndex);
	}
}

/**
 * 
 * 
 */
private function searchPageCountChanged():void{
	if(searchPageLinkList.length > 0 && combobox_pageCounter_search.selectedIndex >= 0 ){
		this.searchPageIndex = new int(combobox_pageCounter_search.selectedLabel);
		searchNicoButtonClicked(searchPageLinkList[getIndexByPageCountForSearch(searchPageIndex)][0]);
		
		searchPageCountProvider.unshift(searchPageIndex);
		combobox_pageCounter_search.selectedIndex = searchPageCountProvider.indexOf(searchPageIndex);
	}
}


/**
 * 次へボタンが押されたときに呼ばれるキーリスナーです。
 * 
 */
private function nextButtonClicked():void{
	if(rankingPageCountProvider.length > 0){
		if(this.rankingPageIndex < rankingPageCountProvider.length){
			this.rankingPageIndex++;
			
			combobox_pageCounter_ranking.selectedIndex = rankingPageCountProvider.indexOf(rankingPageIndex);
			
			rankingRenewButtonClicked();
		}
	}
}

/**
 * 
 * 
 */
private function searchNextButtonClicked():void{
	if(searchPageCountProvider.length > 0){
		if(searchPageLinkList != null && searchPageLinkList.length > 0){
			var index:int = getIndexByPageCountForSearch(searchPageIndex+1);
			if(index != -1){
				this.searchPageIndex++;
				
				searchNicoButtonClicked(searchPageLinkList[index][0]);
				
				searchPageCountProvider.push(searchPageIndex);
				combobox_pageCounter_search.selectedIndex = searchPageCountProvider.indexOf(searchPageIndex);
			}
		}
	}
}

/**
 * 戻るボタンを押されたときに呼ばれるキーリスナーです。
 * 
 */
private function backButtonClicked():void{
	if(rankingPageCountProvider.length > 0){
		if(this.rankingPageIndex > 1){
			this.rankingPageIndex--;
			
			combobox_pageCounter_ranking.selectedIndex = rankingPageCountProvider.indexOf(rankingPageIndex);
			
			rankingRenewButtonClicked();
		}	
	}
}

/**
 * 戻るボタンを押されたときに呼ばれるキーリスナーです。
 * 
 */
private function searchBackButtonClicked():void{
	if(searchPageCountProvider.length > 0){
		if(searchPageLinkList != null && searchPageLinkList.length > 0){
			var index:int = getIndexByPageCountForSearch(searchPageIndex-1);
			if(index != -1){
				this.searchPageIndex--;
				searchNicoButtonClicked(searchPageLinkList[index][0]);
				searchPageCountProvider.push(searchPageIndex);
				combobox_pageCounter_search.selectedIndex = searchPageCountProvider.indexOf(searchPageIndex);
			}
		}
	}
}

/**
 * 
 * @param pageCount
 * @return 
 * 
 */
private function getIndexByPageCountForSearch(pageCount:int):int{
	for(var i:int = 0; i<searchPageLinkList.length; i++){
		if(searchPageLinkList[i][1] == pageCount){
			return i;
		}
	}
	return -1;
}


/**
 * 検索関係ボタンの有効・無効を一括設定します
 * @param isEnable
 * 
 */
private function setEnableSearchButton(isEnable:Boolean):void{
	button_back.enabled = isEnable;
	button_next.enabled = isEnable;
	combobox_pageCounter_ranking.enabled = isEnable;
}

/**
 * 
 * @param index
 * 
 */
private function playListItemClicked(event:ListEvent):void{
	if(tree_library.selectedItem != null){
		var name:String = tree_library.selectedItem.label;
		if(name != null){
			var index:int = playListManager.getPlayListIndexByName(name);
			updatePlayList(index);
		}
	}
}

/**
 * 
 * 
 */
public function updatePlayListSummery():void{
	
	var selectedItem:Object = null;
	var openItems:Array = null;
	if(tree_library != null){
		selectedItem = tree_library.selectedItem;
		openItems = (tree_library.openItems as Array);
	}
	
	var playLists:Vector.<PlayList> = this.playListManager.readPlayListSummary(libraryManager.playListDir);

	if(tree_library != null){

	
		var item:TreeFolderItem = this.tree_library.dataProvider[1];
		item.children = new Array();
		
		var treeDataBuilder:TreeDataBuilder = new TreeDataBuilder();
		for each(var playList:PlayList in playLists){
			var file:TreeFileItem = treeDataBuilder.getFileObject(playList.name);
			
			item.children.push(file);
			file.parent = item;
		}
	
		if(openItems.indexOf(item) == -1){
			openItems.push(item);
		}
		
		tree_library.openItems = openItems;
		
		tree_library.invalidateDisplayList();
		tree_library.validateNow();
		
		tree_library.selectedItem = selectedItem;
		
	}
	
}


/**
 * 指定されたインデックスのプレイリストで、DataGridを更新します。
 * @param index
 * 
 */
public function updatePlayList(index:int):void{
	
	var selectedIndex:int = -1;
	if(tree_library != null){
		selectedIndex = tree_library.selectedIndex;
	}
	
	var word:String = textInput_searchInDLList.text;
	var tagWord:String = textInput_searchInTagList.text;
	textInput_searchInDLList.text = "";
	textInput_searchInTagList.text = "";
	searchDLListTextInputChange();
	searchTagListTextInputChange();
	
	playListManager.isSelectedPlayList = true;
	tree_library.selectedIndex = -1;
	playListManager.selectedPlayListIndex = index;
	
	downloadedProvider.removeAll();
	if(index > -1){
	
		var playList:PlayList = playListManager.getPlayList(playListManager.selectedPlayListIndex);
		var builder:PlayListDataGridBuilder = new PlayListDataGridBuilder();
		for each(var object:Object in builder.build(playList.items)){
			downloadedProvider.addItem(object);
		}
	
	}
	
	downloadedProvider.sort = null;
	downloadedProvider.refresh();
	
	dataGrid_downloaded.invalidateDisplayList();
	dataGrid_downloaded.validateDisplayList();
	
	if(index > -1){
		tagManager.tagRenewOnPlayList(tileList_tag, playListManager.getNNDDVideoListByIndex(playListManager.selectedPlayListIndex));
	}else{
		tagManager.tagRenewOnPlayList(tileList_tag, new Vector.<NNDDVideo>());
	}
	tileList_tag.invalidateDisplayList();
	tileList_tag.validateNow();
	
	if(word == "リスト内を検索"){
		searchDLListTextInputChange();
		textInput_searchInDLList.text = word;
	}else{
		textInput_searchInDLList.text = word;
		searchDLListTextInputChange();
	}
	if(tagWord == "タグを検索"){
		searchTagListTextInputChange();
		textInput_searchInTagList.text = tagWord;
	}else{
		textInput_searchInTagList.text = tagWord;
		searchTagListTextInputChange();
	}
	
	if(tree_library != null){
		tree_library.selectedIndex = selectedIndex;
	}
	
}

/**
 * 
 * @param event
 * 
 */
private function playMovieByPlayListIndex(pName:String):void{
	
	var index:int = playListManager.getPlayListIndexByName(pName);
	
	updatePlayList(index);
	
	this.playingVideoPath = this.downloadedListManager.getVideoPath(0);
	
	if(this.playingVideoPath != null){
		
		playMovie(this.playingVideoPath, 0, playListManager.getPlayList(index));

	}	
}

/**
 * 
 * @param file
 * 
 */
private function playMovieByLibraryDir(file:File):void{
	
	var vector:Vector.<NNDDVideo> = libraryManager.getNNDDVideoArray(file, this.showAll);
	
	if(vector.length > 0){
		
		var playList:PlayList = new PlayList();
		playList.name = file.name + ".m3u";
		playList.items = vector;
		
		playMovie(vector[0].getDecodeUrl(), 0, playList);
		
	}
}

/**
 * 
 * 
 */
private function addPlayList():void{
	
	playListManager.addPlayList();
	updatePlayListSummery();
}

/**
 * 
 * 
 */
private function deletePlayList():void{
	if(tree_library.selectedIndex > 0){
		var index:int = playListManager.getPlayListIndexByName(tree_library.selectedItem.label);
		
		if(index != -1){
			
			var playlist:PlayList = playListManager.getPlayList(index);
			
			Alert.show("プレイリストを削除してもよろしいですか？\n\n" + playlist.name, "確認", (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					try{
						playListManager.removePlayListByIndex(index);
						updatePlayListSummery();
					}catch (error:IOError){
						Alert.show("削除できませんでした。\nファイルが開かれていない状態で再度実行してください。\n"+error, "エラー");
						logManager.addLog("プレイリストの削除に失敗:" + error);
					}
				}
			}, null, Alert.NO);
			
		}
		
	}
}



/**
 * 
 * @param event
 * 
 */
//private function itemDroped(event:DragEvent):void{
//	if(event.target == dataGrid_downloaded){
//		
//		//dataGrid_downloaded内で項目を並べ替えます
//		var selectedIndexArray:Array = dataGrid_downloaded.selectedIndices;
//		selectedIndexArray.sort();
//		var j:int = 0;
//		
//		//プレイリストの時
//		if(this.playListManager.isSelectedPlayList){
//			
//			event.preventDefault();
//			dataGrid_downloaded.hideDropFeedback(event);
//			
//			var pIndex:int = playListManager.getPlayListIndexByName(tree_library.selectedItem.label);
//			var dropIndex:int = dataGrid_downloaded.calculateDropIndex(event);
//			var tempArray:Array = new Array();
//			var shiftCount:int = 0;
//			
//			for(j=0; j<selectedIndexArray.length; j++){
//				var nnddVideo:NNDDVideo = new NNDDVideo(downloadedProvider[selectedIndexArray[j]].dataGridColumn_videoPath, 
//					downloadedProvider[selectedIndexArray[j]].dataGridColumn_videoName);
//				tempArray.push(nnddVideo);
//				if(dropIndex > selectedIndexArray[j]){
//					shiftCount++;
//				}
//			}
//			
//			playListManager.removePlayListItemByIndex(pIndex, selectedIndexArray);
//			playListManager.addNNDDVideos(pIndex, tempArray);
//			
//			var playList:PlayList = playListManager.getPlayList(playListManager.selectedPlayListIndex);
//			var builder:PlayListDataGridBuilder = new PlayListDataGridBuilder();
//			downloadedProvider.removeAll();
//			for each(var object:Object in builder.build(playList.items)){
//				downloadedProvider.addItem(object);
//			}
//			
//			downloadedProvider.sort = null;
//			downloadedProvider.refresh();
//			
//			dataGrid_downloaded.invalidateDisplayList();
//			dataGrid_downloaded.validateNow();
//			
//		}else{	//ライブラリの時
//			
//			//元のDataGridから取り除く。
//			for(j=0; j<selectedIndexArray.length; j++){
//				downloadedProvider.removeItemAt(selectedIndexArray[j]);
//			}
//		}
//	}
//	
//}

/**
 * oldFileで指定された動画をnewFileで指定されたパスへ移動します。
 * @param oldFile 移動前の動画の場所を表すFile
 * @param newFile 移動後の動画の場所を表すFile
 * @param isSaveLibrary ファイルを移動した後、ライブラリを保存するかどうかです
 * 
 */
private function moveFile(oldFile:File, newFile:File, isSaveLibrary:Boolean):void{
	try{
		
		//動画を移動
		if(newFile.exists){
			newFile.deleteFile();
		}
		oldFile.moveTo(newFile);
		logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(oldFile.url) + " -> " + decodeURIComponent(newFile.url));
		
		//ライブラリを更新
		var key:String = LibraryUtil.getVideoKey(decodeURIComponent(oldFile.url));
		var video:NNDDVideo = null;
		
		//videoIDが無ければライブラリの管理対象にならない
		if(key != null){
			
			video = libraryManager.isExist(key);
			
			if(video != null){
				video.uri = newFile.url;			
			}else{
				video = new LocalVideoInfoLoader().loadInfo(newFile.url);
				logManager.addLog("動画を新たに管理対象に追加:" + video.videoName);
			}
			
			libraryManager.update(video, false);
			logManager.addLog("動画のパスを更新:" + oldFile.nativePath + " -> " + newFile.nativePath);
			
		}
		
		//コメントも移動する
		oldFile.url = oldFile.url.substring(0, oldFile.url.lastIndexOf(".")) + ".xml";
		var moveFileName:String = decodeURIComponent(oldFile.url);
		if(oldFile.exists){
			newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf(".")) + ".xml";
			if(newFile.exists){
				newFile.deleteFile();
			}
			oldFile.moveTo(newFile);
			logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(oldFile.url) + " -> " + decodeURIComponent(newFile.url));
		}
		
		//投稿者コメントも移動する
		oldFile.url = oldFile.url.substring(0, oldFile.url.lastIndexOf(".")) + "[Owner].xml";
		moveFileName = decodeURIComponent(oldFile.url);
		if(oldFile.exists){
			newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf(".")) + "[Owner].xml";
			if(newFile.exists){
				newFile.deleteFile();
			}
			oldFile.moveTo(newFile);
			logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(oldFile.url) + " -> " + decodeURIComponent(newFile.url));
		}

		//サムネイル情報も移動
		//アイドルマスター 伊織 Love You PV風‐ニコニコ動画(秋) - [sm5082988][ThumbInfo].xml
		oldFile.url = oldFile.url.substring(0, oldFile.url.lastIndexOf("Owner")) + "ThumbInfo].xml";
		moveFileName = decodeURIComponent(oldFile.url);
		if(oldFile.exists){
			newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf("Owner")) + "ThumbInfo].xml";
			if(newFile.exists){
				newFile.deleteFile();
			}
			oldFile.moveTo(newFile);
			logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(oldFile.url) + " -> " + decodeURIComponent(newFile.url));
		}

		//市場情報も移動
		var iChibaOldFile:File = new File(oldFile.url.substring(0, oldFile.url.lastIndexOf("ThumbInfo")) + "IchibaInfo].html");
		moveFileName = decodeURIComponent(iChibaOldFile.url);
		if(iChibaOldFile.exists){
			newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf("ThumbInfo")) + "IchibaInfo].html";
			if(newFile.exists){
				newFile.deleteFile();
			}
			iChibaOldFile.moveTo(newFile);
			logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(iChibaOldFile.url) + " -> " + decodeURIComponent(newFile.url));
		}
		
		//サムネ画像も移動
		try{
			var thumbImgFile:File = new File(video.thumbUrl);
		}catch(error:Error){
			thumbImgFile = new File(oldFile.url.substring(0, oldFile.url.lastIndexOf("ThumbInfo")) + "ThumbImg].jpeg");
		}
		moveFileName = decodeURIComponent(thumbImgFile.url);
		if(thumbImgFile.exists){
			newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf("/")) + thumbImgFile.url.substring(thumbImgFile.url.lastIndexOf("/"));
			if(newFile.exists){
				newFile.deleteFile();
			}
			thumbImgFile.moveTo(newFile);
			logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(thumbImgFile.url) + " -> " + decodeURIComponent(newFile.url));
			
			//ライブラリを更新
			key = LibraryUtil.getVideoKey(decodeURIComponent(video.getDecodeUrl()));
			var tempVideo:NNDDVideo = null;
			
			//ライブラリのVideoのサムネイル画像を更新
			if(key != null){
				tempVideo = libraryManager.isExist(key);
				if(tempVideo != null){
					tempVideo.thumbUrl = decodeURIComponent(newFile.url);
					if(!libraryManager.update(tempVideo, false)){
						logManager.addLog("動画がすでに登録されています:" + tempVideo.getDecodeUrl());
						trace("動画がすでに登録されている(サムネイル画像更新1)");
					}
				}else{
					video.thumbUrl = decodeURIComponent(newFile.url);
					if(!libraryManager.add(video, false)){
						logManager.addLog("動画がすでに登録されています:" + video.getDecodeUrl());
						trace("動画がすでに登録されている(サムネイル画像更新2)");
					}
				}
			}
		}
		
		//ニコ割も移動
		var nicowariFile:File = new File(decodeURIComponent(oldFile.url).substring(0, decodeURIComponent(oldFile.url).lastIndexOf("/")));
		var myArray:Array = nicowariFile.getDirectoryListing();
		var fileName:String = decodeURIComponent(oldFile.url).substring(decodeURIComponent(oldFile.url).lastIndexOf("/")+1, decodeURIComponent(oldFile.url).lastIndexOf("[ThumbInfo]"));
		for each(var file:File in myArray){
			if(!file.isDirectory){
				var extensions:String = file.nativePath.substr(-4);
				if(extensions == ".swf"){
					if((decodeURIComponent(file.url).indexOf(fileName) != -1) && decodeURIComponent(file.url).match(/\[Nicowari\]/)){
						moveFileName = decodeURIComponent(file.url);
						newFile.url = newFile.url.substring(0, newFile.url.lastIndexOf("/")) + file.url.substring(file.url.lastIndexOf("/"));
						if(file.exists){
							if(newFile.exists){
								newFile.deleteFile();
							}
							file.moveTo(newFile);
							logManager.addLog(Message.MOVE_FILE + ":" + decodeURIComponent(oldFile.url) + " -> " + decodeURIComponent(newFile.url));
						}
					}
				}
			}
		}
		
		if(video != null && isSaveLibrary){
			libraryManager.saveLibrary();
		}
		
	}catch(error:Error){
		logManager.addLog(error + ":" + moveFile + "->" + decodeURIComponent(newFile.url) + "\n" + error.getStackTrace());
		trace(error + ":" + moveFile + "->" + decodeURIComponent(newFile.url) + "\n" + error.getStackTrace());
//		throw error;
	}
}


private function windowPositionReset():void{
	// ウィンドウの位置情報を初期化
	try{
		EncryptedLocalStore.removeItem("windowPosition_x");
		EncryptedLocalStore.removeItem("windowPosition_y");
		EncryptedLocalStore.removeItem("windowPosition_w");
		EncryptedLocalStore.removeItem("windowPosition_h");
		
	}catch(error:Error){
		Alert.show(Message.M_LOCAL_STORE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.M_LOCAL_STORE_IS_BROKEN + error.getStackTrace());
		EncryptedLocalStore.reset();
	}
	
	if(this.nativeWindow != null){
		this.nativeWindow.x = 0;
		this.nativeWindow.y = 0;
	}
	this.width = 850;
	this.height = 600;
	
	if(playerController == null){
		playerController = new PlayerController(MAILADDRESS, PASSWORD, playListManager);
		playerController.open();
	}else{
		if(!playerController.isOpen()){
			playerController.destructor();
			playerController = null;
			playerController = new PlayerController(MAILADDRESS, PASSWORD, playListManager);
			playerController.open();
		}
	}
	
	playerController.resetWindowPosition();
	
	logManager.addLog(Message.WINDOW_POSITION_RESET);
	Alert.show(Message.WINDOW_POSITION_RESET, Message.M_MESSAGE);
	
}

private function renewLibraryButtonClicked():void{
	
	renewAndShowDialog(libraryManager.libraryDir, true);
	
}


/**
 * プレイリスト内の、現状のDataGridの並び順を保存します。
 * 
 */
private function savePlayListByDataGridSort():void{
	var vector:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
	for each(var dataGridColumn:Object in downloadedProvider){
		var name:String = dataGridColumn.dataGridColumn_videoName;
		var path:String = dataGridColumn.dataGridColumn_videoPath;
		vector.push(new NNDDVideo(path, name));
	}
	
	var pName:String = playListManager.getPlayListNameByIndex(playListManager.selectedPlayListIndex);
	playListManager.updatePlayList(pName, vector);
	playListManager.savePlayListByIndex(playListManager.selectedPlayListIndex);
	
	var playList:PlayList = playListManager.getPlayList(playListManager.selectedPlayListIndex);
	var builder:PlayListDataGridBuilder = new PlayListDataGridBuilder();
	downloadedProvider.removeAll();
	for each(var object:Object in builder.build(playList.items)){
		downloadedProvider.addItem(object);
	}
	
	downloadedProvider.sort = null;
	downloadedProvider.refresh();
	
	dataGrid_downloaded.invalidateDisplayList();
	dataGrid_downloaded.validateNow();
}

private function thumbSizeChanged(event:SliderEvent):void{
	this.thumbImageSize = event.value;
	dataGrid_ranking.rowHeight = 55*event.value;
	dataGridColumn_thumbImage.width = 70*event.value;
}

private function thumbSizeChangedForSearch(event:SliderEvent):void{
	this.thumbImgSizeForSearch = event.value;
	dataGrid_search.rowHeight = 55*event.value;
	dataGridColumn_thumbImage_Search.width = 70*event.value;
}

private function thumbSizeChangedForMyList(event:SliderEvent):void{
	this.thumbImgSizeForMyList = event.value;
	dataGrid_myList.rowHeight = 55*event.value;
	dataGridColumn_thumbUrl.width = 70*event.value;
}

private function thumbSizeChangedForDLList(event:SliderEvent):void
{
	this.thumbImgSizeForDLList = event.value;
	dataGrid_downloadList.rowHeight = 55*event.value;
}

private function thumbSizeChangedForLibrary(event:SliderEvent):void{
	this.thumbImgSizeForLibrary = event.value;
	dataGrid_downloaded.rowHeight = 20*event.value;
	dataGridColumn_LibraryThumbImage.width = 25*event.value;
}

private function thumbSizeChangedForHistory(event:SliderEvent):void{
	this.thumbImgSizeHistory = event.value;
	dataGrid_history.rowHeight = 20*event.value;
	dataGridColumn_thumbImage_history.width = 25*event.value;
}

private function donation():void{
	navigateToURL(new URLRequest("http://d.hatena.ne.jp/MineAP/20080730/1217412550"));
}

private function checkBoxAutoDLChanged(event:Event):void{
	isAutoDownload = (event.currentTarget as CheckBox).selected;
}

private function checkBoxEcoCheckChanged(event:Event):void{
	isEnableEcoCheck = (event.currentTarget as CheckBox).selected;
	this.downloadManager.isContactTheUser = isEnableEcoCheck;
}

private function downloadListDoubleClicked(event:ListEvent):void{
	//videoIDはあるか？
	var videoId:String = LibraryUtil.getVideoKey(event.itemRenderer.data.col_videoName);
	if(videoId != null){
		//ライブラリに登録済か？
		var video:NNDDVideo = libraryManager.isExist(videoId);
		if(video != null){
			this.playMovie(video.getDecodeUrl(), -1);
			return;
		}
	}
	//ファイルを直接見に行く。
	var videoPath:String = event.itemRenderer.data.col_downloadedPath;
	if(videoPath != null && videoPath != "undefined"){
		this.playMovie(videoPath, -1);
		return;
	}
	//ファイルが無い。ストリーミングしとく。
	videoPath = event.itemRenderer.data.col_videoUrl;
	if(videoPath != null && videoPath != "undefined"){
		this.playMovie(videoPath, -1);
		return;
	}
}

private function deleteDLListButtonClicked(event:Event):void{
	downloadManager.deleteSelectedItems(dataGrid_downloadList.selectedIndices);
}

/**
 * 
 * @param clipboard
 * 
 */
private function addDLListForClipboard(clipboard:Clipboard):void{
	if(clipboard != null){
	
		if(clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
			var url:String = String(clipboard.getData(ClipboardFormats.TEXT_FORMAT));
			addDLList(url);
		}
	
	}
	
}

/**
 * 
 * @param event
 * 
 */
private function addDLListButtonClicked(event:MouseEvent):void{
	
	if(textInput_url != null && textInput_url.text != null && textInput_url.text.length > 0){
	
		addDLList(textInput_url.text);
		textInput_url.text = "";
	}
		
}

/**
 * 
 * @param url
 * 
 */
private function addDLList(url:String):void{
	
	var auto:Boolean = isAutoDownload;
	if(MAILADDRESS != "" && PASSWORD != ""){
		// ログインしていないなら自動ダウンロードしない
		auto = false;
	}		
	
	var matchResult:Array = url.match(new RegExp("http://www.nicovideo.jp/watch/"));
	if(matchResult != null && matchResult.length > 0){
		var video:NNDDVideo = new NNDDVideo(url, "-");
		if(!downloadManager.add(video, auto)){
			Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
		}else{
			scrollToLastAddedDownloadItem();
		}
		return;
	}
	
	var videoId:String = PathMaker.getVideoID(url);
	if(videoId != null){
		url = "http://www.nicovideo.jp/watch/" + videoId;
		var video:NNDDVideo = new NNDDVideo(url, "-");
		if(!downloadManager.add(video, auto)){
			Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
		}else{
			scrollToLastAddedDownloadItem();
		}
		return;
	}
	
	Alert.show("動画のURL以外は追加できません。\n" + url, Message.M_ERROR);
	logManager.addLog("動画のURL以外は追加できません:" + url);
}



private function queueKeyDownHandler(event:KeyboardEvent):void{
	if(viewstack1.selectedIndex == DOWNLOAD_LIST_TAB_NUM){
		if(event.ctrlKey){
			isCtrlKeyPush = true;
		}
	}
}

private function queueKeyUpHandler(event:KeyboardEvent):void{
	if(viewstack1.selectedIndex == DOWNLOAD_LIST_TAB_NUM){
		if(!textInput_url_foculsIn){
			if(event.keyCode == Keyboard.DELETE || event.keyCode == Keyboard.BACKSPACE){
				downloadManager.deleteSelectedItems(dataGrid_downloadList.selectedIndices);
			}else if(isCtrlKeyPush && event.keyCode == Keyboard.V){
				isCtrlKeyPush = false;
				addDLListForClipboard(Clipboard.generalClipboard);
			}
		}
	}
}

private function queueMenuHandler(event:Event):void{
	if(viewstack1.selectedIndex == DOWNLOAD_LIST_TAB_NUM){
		if(!textInput_url_foculsIn){
			addDLListForClipboard(Clipboard.generalClipboard);
		}
	}
}

public function playerOpenButtonClicked(event:Event):void{
	playerOpen();
}

public function playerOpen():void{
	if(playerController != null && playerController.isOpen()){
		playerController.videoInfoView.activate();
		playerController.videoPlayer.activate();
	}else{
		if(playerController != null){
			playerController.destructor();
		}
		playerController = null;
		playerController = new PlayerController(MAILADDRESS, PASSWORD, playListManager);
		playerController.open();
	}
}

private function dlListDroped(event:NativeDragEvent):void{
	if(event.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
		addDLListForClipboard(event.clipboard);
	}
}

private function dlListDragEnter(event:NativeDragEvent):void{
	if(event.clipboard.hasFormat(ClipboardFormats.TEXT_FORMAT)){
		NativeDragManager.acceptDragDrop(this.dataGrid_downloadList);
	}
}

private function changeIsRankingRenewAtStart(event:Event):void{
	isRankingRenewAtStart = checkbox_isRankingRenewAtStart.selected;
}

//private function showOnlyNowLibraryTagCheckboxChanged(event:MouseEvent):void{
//	
//	isShowOnlyNowLibraryTag = checkbox_showOnlyNowLibraryTag.selected;
//	
//	if(!this.playListManager.isSelectedPlayList){
//		if((event.currentTarget as CheckBox).selected){
//			if(this.selectedLibraryFile == null){
//				tagManager.tagRenew(tileList_tag, this.libraryFile);
//			}else{
//				tagManager.tagRenew(tileList_tag, this.selectedLibraryFile);
//			}
//		}else{
//			tagManager.tagRenew(tileList_tag);
//		}
//	}else{
//		tagManager.tagRenewOnPlayList(tileList_tag, playListManager.getUrlListByIndex(playListManager.selectedPlayListIndex));
//	}
//	
//}

private function tileListHeightChanged(event:ResizeEvent):void{
	lastCanvasTagTileListHight = (event.currentTarget as Canvas).height;
}

private function tagTileListClicked(event:Event):void{
	
	var array:Array = (event.currentTarget as TileList).selectedItems;
	trace(array);	
	
	if(!playListManager.isSelectedPlayList){
		this.downloadedListManager.searchAndShowByTag(dataGrid_downloaded, array);
	}else{
		this.downloadedListManager.searchAndShowByTag(dataGrid_downloaded, array);
	}
	
	if(textInput_searchInDLList.text.length > 0){
		this.searchDLListTextInputChange();
	}
}

private function checkBoxOutStreamingPlayerChanged(event:Event):void{
	this.isOutStreamingPlayerUse = (event.currentTarget as CheckBox).selected;
}

private function checkBoxDoubleClickOnStreamingChanged(event:Event):void{
	this.isDoubleClickOnStreaming = (event.currentTarget as CheckBox).selected;
}

private function checkBoxSaveSearchHistoryChanged(event:Event):void{
	this.isSaveSearchHistory = (event.currentTarget as CheckBox).selected;
}


private function error(event:ErrorEvent):void{
	if(logManager != null){
		logManager.addLog("ハンドルされないエラーです。:" + event + "\ntarget:" + event.target + "\ncurrent:" + event.currentTarget);
	}
	Alert.show("ハンドルされないエラーです。\n" + event);
}


private function addDownloadListButtonClickedForMyList():void{
	
	var indices:Array = dataGrid_myList.selectedIndices;
	indices.reverse();
	
	for each(var index:int in indices){
		
		if(index > -1 && index < dataGrid_myList.dataProvider.length){
			
			var videoUrl:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoUrl;
			var videoName:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoName;
			
			if(videoUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
				//ダウンロード
				var video:NNDDVideo = new NNDDVideo(videoUrl, videoName);
				addDownloadListForMyList(video, index);
			}
			
		}
	}
	
}

private function addDownloadListButtonClickedForSearch():void{
	
	var indices:Array = dataGrid_search.selectedIndices;
	indices.reverse();
	
	for each(var index:int in indices){
		
		if(index > -1 && index < dataGrid_search.dataProvider.length){
			
			var videoUrl:String = dataGrid_search.dataProvider[index].dataGridColumn_nicoVideoUrl;
			var videoName:String = dataGrid_search.dataProvider[index].dataGridColumn_videoName;
			
			if(videoUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
				//ダウンロード
				var video:NNDDVideo = new NNDDVideo(videoUrl, videoName);
				addDownloadListForSearch(video, index);
			}
			
		}
	}
}


private function videoStreamingPlayButtonClickedForMyList():void{
	var index:int = dataGrid_myList.selectedIndex;
	if(index > -1 && index < dataGrid_myList.dataProvider.length){
		
		var videoUrl:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoUrl;
		var videoName:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoName;
		
		if(videoUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
			var myListId:String = dataGrid_myList.dataProvider[index].dataGridColumn_myListId;
			if(myListId != null){
				var vector:Vector.<String> = new Vector.<String>();
				vector.splice(0, 0, PathMaker.getVideoID(videoUrl));
				_myListManager.setPlayedAndSave(myListId, vector);
				
				if(!selectedMyListFolder){
					var xml:XML = MyListManager.instance.readLocalMyList(myListId);
					if(xml != null){
						myListRenew(xml);
					}
				}else{
					if(tree_library.selectedItem != null){
						var name:String = tree_library.selectedItem.label;
						myListRenewForName(name);
					}
				}
			}
			
			//ストリーミング
			videoStreamingPlayStart(videoUrl);
			
			dataGrid_myList.scrollToIndex(index);
		}
		
	}
}

private function videoStreamingPlayButtonClickedForSearch():void{
	var index:int = dataGrid_search.selectedIndex;
	if(index > -1 && index < dataGrid_search.dataProvider.length){
		
		var videoUrl:String = dataGrid_search.dataProvider[index].dataGridColumn_nicoVideoUrl;
		var videoName:String = dataGrid_search.dataProvider[index].dataGridColumn_videoName;
		
		if(videoUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
			//ストリーミング
			videoStreamingPlayStart(videoUrl);
		}
		
	}
}

/**
 * 
 * 
 */
private function myListItemDataGridDoubleClicked():void{
	var index:int = dataGrid_myList.selectedIndex;
	if(index > -1 && index < dataGrid_myList.dataProvider.length){
		
		var videoUrl:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoUrl;
		var videoName:String = dataGrid_myList.dataProvider[index].dataGridColumn_videoName;
		
		if(videoUrl.indexOf("http://www.nicovideo.jp/watch/") != -1){
			//ダウンロード or ストリーミング
			if(isDoubleClickOnStreaming){
				//ストリーミング
				var myListId:String = dataGrid_myList.dataProvider[index].dataGridColumn_myListId;
				if(myListId != null){
					var vector:Vector.<String> = new Vector.<String>();
					vector.splice(0, 0, PathMaker.getVideoID(videoUrl));
					_myListManager.setPlayedAndSave(myListId, vector);
					
					if(!selectedMyListFolder){
						var xml:XML = MyListManager.instance.readLocalMyList(myListId);
						if(xml != null){
							myListRenew(xml);
						}
					}else{
						if(tree_myList.selectedItem != null){
							var name:String = tree_myList.selectedItem.label;
							myListRenewForName(name);
						}
					}
				}
				videoStreamingPlayStart(videoUrl);
				if(index >= 0){
					dataGrid_myList.selectedIndex = index;
				}
			}else{
				//ダウンロード
				var video:NNDDVideo = new NNDDVideo(videoUrl, videoName);
				addDownloadListForMyList(video, index);
			}
			
			tree_myList.invalidateList();
			tree_myList.validateNow();
			
		}
		
	}
}

/**
 * 
 * @param video
 * @param index
 * 
 */
private function addDownloadListForMyList(video:NNDDVideo, index:int = -1):void{
	
	var isExistsInDLList:Boolean = false;
	isExistsInDLList = downloadManager.isExists(video);
	
	if(isExistsInDLList){
		Alert.show(Message.M_ALREADY_DLLIST_VIDEO_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
			if(event.detail == Alert.YES){
				downloadManager.add(video, isAutoDownload);
				if(index != -1 && myListItemProvider.length > index){
					myListItemProvider.setItemAt({
						dataGridColumn_index: myListItemProvider[index].dataGridColumn_index,
						dataGridColumn_preview: myListItemProvider[index].dataGridColumn_preview,
						dataGridColumn_ranking: myListItemProvider[index].dataGridColumn_ranking,
						dataGridColumn_videoName: myListItemProvider[index].dataGridColumn_videoName,
						dataGridColumn_videoInfo: myListItemProvider[index].dataGridColumn_videoInfo,
						dataGridColumn_condition: "DLリストに追加済",
						dataGridColumn_videoUrl: myListItemProvider[index].dataGridColumn_videoUrl,
						dataGridColumn_downloadedItemUrl: myListItemProvider[index].dataGridColumn_downloadedItemUrl
					}, index);
				}
				scrollToLastAddedDownloadItem();
			}
		}, null, Alert.NO);
	}else{
		if(!downloadManager.add(video, isAutoDownload)){
			Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
		}else{
			if(index != -1 && myListItemProvider.length > index){
				myListItemProvider.setItemAt({
					dataGridColumn_index: myListItemProvider[index].dataGridColumn_index,
					dataGridColumn_preview: myListItemProvider[index].dataGridColumn_preview,
					dataGridColumn_ranking: myListItemProvider[index].dataGridColumn_ranking,
					dataGridColumn_videoName: myListItemProvider[index].dataGridColumn_videoName,
					dataGridColumn_videoInfo: myListItemProvider[index].dataGridColumn_videoInfo,
					dataGridColumn_condition: "DLリストに追加済",
					dataGridColumn_videoUrl: myListItemProvider[index].dataGridColumn_videoUrl,
					dataGridColumn_downloadedItemUrl: myListItemProvider[index].dataGridColumn_downloadedItemUrl
				}, index);
			}
			scrollToLastAddedDownloadItem();
		}
	}
}

/**
 * 
 * @param myListId
 * 
 */
public function renewMyList(myListId:String):void{
	
	
	if(viewstack1.selectedIndex != MYLIST_TAB_NUM){
	
		this.canvas_myList.addEventListener(FlexEvent.SHOW, renewMyListInner);
		
		viewstack1.selectedIndex = MYLIST_TAB_NUM;
	
	}else{
		renewMyListInner(null);
	}
	
	function renewMyListInner(event:FlexEvent):void{
		textinput_mylist.text = myListId;
		
		myListRenewButtonClicked(new MouseEvent(MouseEvent.CLICK));
		
		Application.application.activate();
		
		canvas_myList.removeEventListener(FlexEvent.SHOW, renewMyListInner);
	}
}


/**
 * 
 * @param event
 * 
 */
private function myListRenewButtonClicked(event:Event):void{
	try{
	
		var url:String = this.textinput_mylist.text;
		
		if(button_myListRenew.label == "更新" && this._nnddMyListLoader == null){
		
			if(url != null){
				
				tree_myList.enabled = false;
				dataGrid_myList.enabled = false;
				textinput_mylist.enabled = false;
				
				button_myListRenew.label == "キャンセル";
				loading = new LoadingPicture();
				loading.show(dataGrid_myList, dataGrid_myList.width/2, dataGrid_myList.height/2);
				loading.start(360/12);
				
				this._nnddMyListLoader = new NNDDMyListLoader();
				this._nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_COMPLETE, function(myevent:Event):void{
		
					try{
						// マイリストをローカルに保存
						_myListManager.saveMyList(MyListUtil.getMyListId(url), _nnddMyListLoader.xml);
					}catch(error:Error){
						trace(error.getStackTrace());
					}
					
					var myListBuilder:MyListBuilder = new MyListBuilder();
					myListItemProvider.removeAll();
					myListItemProvider.addAll(myListBuilder.getMyListArrayCollection(_nnddMyListLoader.xml));
					
					var text:String = myListBuilder.title + " [" + myListBuilder.creator + "]\n" + myListBuilder.description;
					var title:String = myListBuilder.title + " [" + myListBuilder.creator + "]";
					
					textArea_myList.text = HtmlUtil.convertSpecialCharacterNotIncludedString(text);
					_myListManager.lastTitle = HtmlUtil.convertSpecialCharacterNotIncludedString(title);
					
					button_myListRenew.label == "更新";
					dataGrid_myList.validateNow();
					if(loading != null){
						loading.stop();
						loading.remove();
						loading = null;
					}
					_nnddMyListLoader = null;
					tree_myList.enabled = true;
					dataGrid_myList.enabled = true;
					textinput_mylist.enabled = true;
				});
				this._nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_ERROR, function(myevent:Event):void{
					logManager.addLog("マイリストの更新に失敗:" + url + ":" + myevent);
					Alert.show("マイリストの更新に失敗しました。\n" + myevent, Message.M_ERROR);
					button_myListRenew.label == "更新";
					if(loading != null){
						loading.stop();
						loading.remove();
						loading = null;
					}
					_nnddMyListLoader = null;
					tree_myList.enabled = true;
					dataGrid_myList.enabled = true;
					textinput_mylist.enabled = true;
				});
				this._nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_CANCELD, function(myevent:Event):void{
					logManager.addLog("マイリストの更新をキャンセル:" + url + ":" + myevent);
					button_myListRenew.label == "更新";
					if(loading != null){
						loading.stop();
						loading.remove();
						loading = null;
					}
					_nnddMyListLoader = null;
					tree_myList.enabled = true;
					dataGrid_myList.enabled = true;
					textinput_mylist.enabled = true;
				});
				this._nnddMyListLoader.addEventListener(NNDDMyListLoader.PUBLIC_MY_LIST_GET_FAIL, function(myevent:Event):void{
					logManager.addLog("マイリストの更新に失敗:" + url + ":" + myevent);
					Alert.show("マイリストの更新に失敗しました。\nマイリストが削除されている可能性があります。\n" + myevent, Message.M_ERROR);
					button_myListRenew.label == "更新";
					if(loading != null){
						loading.stop();
						loading.remove();
						loading = null;
					}
					_nnddMyListLoader = null;
					tree_myList.enabled = true;
					dataGrid_myList.enabled = true;
					textinput_mylist.enabled = true;
				});
				
				var myListId:String = MyListUtil.getMyListId(url);
				if(myListId != null){
					this._nnddMyListLoader.requestDownloadForPublicMyList(this.MAILADDRESS, this.PASSWORD, myListId);
					return;
				}
				
				button_myListRenew.label == "更新";
				loading.stop();
				loading.remove();
				loading = null;
				_nnddMyListLoader = null;
				
				tree_myList.enabled = true;
				dataGrid_myList.enabled = true;
				textinput_mylist.enabled = true;
			}
		}else{
			//キャンセル
			button_myListRenew.label == "更新";
			
			if(loading != null){
				loading.stop();
				loading.remove();
			}
			
			tree_myList.enabled = true;
			dataGrid_myList.enabled = true;
			textinput_mylist.enabled = true;
			
			if(this._nnddMyListLoader != null){
				this._nnddMyListLoader.close(true, false);
				this._nnddMyListLoader = null;
			}
		}
	
	}catch(error:Error){
		
		//キャンセル
		button_myListRenew.label == "更新";
		
		if(loading != null){
			loading.stop();
			loading.remove();
		}
		
		tree_myList.enabled = true;
		dataGrid_myList.enabled = true;
		textinput_mylist.enabled = true;
		
		if(this._nnddMyListLoader != null){
			this._nnddMyListLoader.close(true, false);
		}
		
		Alert.show("マイリストの更新中に予期せぬ例外が発生しました。\n" + error, Message.M_ERROR);
		logManager.addLog("マイリスト更新中に予期せぬ例外が発生しました:" + error + ":" + error.getStackTrace());
	}
}

private function addPublicMyList(event:Event):void{
	
	var myListEditDialog:MyListEditDialog = PopUpManager.createPopUp(this, MyListEditDialog, true) as MyListEditDialog;
	PopUpManager.centerPopUp(myListEditDialog);
	myListEditDialog.initNameEditDialog(logManager);
	var name:String = this._myListManager.lastTitle;
	if(name != null && name.length < 1){
		name = textinput_mylist.text;
	}
	myListEditDialog.textInput_name.text = name;
	myListEditDialog.textInput_url.text = textinput_mylist.text;
	myListEditDialog.title = "マイリストを新規作成";
	myListEditDialog.button_edit.label = "作成";
	myListEditDialog.setDir(false);
	myListEditDialog.addEventListener(Event.COMPLETE, function(event:Event):void{
		var isSuccess:Boolean = _myListManager.addMyList(myListEditDialog.myListUrl, myListEditDialog.myListName, myListEditDialog.getIsDir(), true);
		if(!isSuccess){
			Alert.show("同名のマイリストかフォルダがすでに存在します。別な名前を設定してください。", Message.M_MESSAGE);
			return;
		}
		var openItems:Object = tree_myList.openItems;
		tree_myList.dataProvider = myListProvider;
		tree_myList.invalidateList();
		tree_myList.validateNow();
		tree_myList.openItems = openItems;
		PopUpManager.removePopUp(myListEditDialog);
	});
	
}

private function removePublicMyList(event:Event):void{
	var selectedItems:Array = tree_myList.selectedItems;
	if(selectedItems != null && selectedItems.length > 0){
		if(selectedItems.length == 1){
			var searchItemName:String = selectedItems[0].label;
			var label:String = "このマイリストを削除してもよろしいですか？\n";
			if(selectedItems[0].hasOwnProperty("children")){
				searchItemName = selectedItems[0].label;
				label = "このフォルダを削除してもよろしいですか？\n(フォルダ下のマイリストも削除されます。)\n";
			}
			
			Alert.show(label + "\n" + searchItemName, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					_myListManager.removeMyList(searchItemName, true);
					var openItems:Object = tree_myList.openItems;
					tree_myList.dataProvider = myListProvider;
					tree_myList.invalidateList();
					tree_myList.validateNow();
					tree_myList.openItems = openItems;
				}
			}, null, Alert.NO);
		}else{
			var selectedItemNames:Array = new Array();
			for(var i:int=0; i<selectedItems.length; i++){
				var searchItemName:String = selectedItems[i];
				if(selectedItems[i].hasOwnProperty("label")){
					searchItemName = selectedItems[i].label;
				}
				selectedItemNames.push(searchItemName);
			}
			
			Alert.show("これらのマイリストを削除してもよろしいですか？\n" + selectedItemNames, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					for(var i:int=0; i<selectedItemNames.length; i++){
						_myListManager.removeMyList(selectedItemNames[i], true);
					}
					var openItems:Object = tree_myList.openItems;
					tree_myList.dataProvider = myListProvider;
					tree_myList.invalidateList();
					tree_myList.validateNow();
					tree_myList.openItems = openItems;
				}
			}, null, Alert.NO);
		}
	}
	
}

private function editPublicMyList(event:Event):void{
	var object:Object = tree_myList.selectedItem;
	var index:int = tree_myList.selectedIndex;
	
	if(object != null){
		
		var myListEditDialog:MyListEditDialog = PopUpManager.createPopUp(this, MyListEditDialog, true) as MyListEditDialog;
		PopUpManager.centerPopUp(myListEditDialog);
		myListEditDialog.initNameEditDialog(logManager);
		
		var selectedItem:Object = this.tree_myList.selectedItem;
		var name:String = "";
		if(selectedItem.hasOwnProperty("label")){
			name = selectedItem.label;
		}else{
			name = String(selectedItem);
		}
		myListEditDialog.textInput_name.text = name;
		myListEditDialog.textInput_url.text = _myListManager.getUrl(name);
		myListEditDialog.setDir(_myListManager.getMyListIdDir(name));
		myListEditDialog.comboBox_isFolder.enabled = false;
		myListEditDialog.addEventListener(Event.COMPLETE, function(event:Event):void{
			if(_myListManager.isExsits(myListEditDialog.myListName)){
				Alert.show("同名のマイリストかフォルダがすでに存在します。別な名前を設定してください。", Message.M_MESSAGE);
				return;
			}
			
			var myList:Object = _myListManager.search(name);
			
			if(myList.hasOwnProperty("children")){
				_myListManager.updateMyList(myListEditDialog.myListUrl, myListEditDialog.myListName, myListEditDialog.getIsDir(), true, name, myList.children);
			}else{
				_myListManager.updateMyList(myListEditDialog.myListUrl, myListEditDialog.myListName, myListEditDialog.getIsDir(), true, name, null);
			}
			
			var openItems:Object = tree_myList.openItems;
			tree_myList.dataProvider = myListProvider;
			tree_myList.invalidateList();
			tree_myList.validateNow();
			tree_myList.openItems = openItems;
			PopUpManager.removePopUp(myListEditDialog);
		});
	}
}

private function myListUrlChanged(event:Event):void{
	this._myListManager.lastTitle = "";
}

private function myListClicked(event:ListEvent):void{
	myListRenewForName(String(event.itemRenderer.data.label));
}

private function myListRenewForName(name:String):void{
	
	var selectedIndex:int = tree_myList.selectedIndex;
	var openItems:Object = tree_myList.openItems;
	selectedMyListFolder = false;
	
	var url:String = this._myListManager.getUrl(name);
	textinput_mylist.text = url;
	textArea_myList.text = "";
	var xml:XML = MyListManager.instance.readLocalMyList(MyListUtil.getMyListId(url));
	try{
		if(xml != null){
			myListRenew(xml, false);
		}else if(url != null && url != ""){
			myListItemProvider.removeAll();
			myListItemProvider.addItem({
				dataGridColumn_index:1,
				dataGridColumn_preview:"",
				dataGridColumn_videoName:"ローカルにマイリストが保存されていません。\n一度\"更新\"してください。",
				dataGridColumn_videoInfo:"",
				dataGridColumn_condition:"",
				dataGridColumn_videoUrl:"",
				dataGridColumn_videoLocalPath:"",
				dataGridColumn_played:false,
				dataGridColumn_videoId:""
			});
			logManager.addLog("ローカルにマイリストが保存されていません。一度\"更新\"してください。");
		}else if(url == ""){
			// urlが空のときはフォルダ
			selectedMyListFolder = true;
			textinput_mylist.text = name;
			
			var vector:Vector.<XML> = MyListManager.instance.readFromSubDirMyList(name);
			
			var myListBuilder:MyListBuilder = new MyListBuilder();
			
			var index:int = dataGrid_myList.selectedIndex;
			
			myListItemProvider.removeAll();
			for each(var temp:XML in vector){
				var array:ArrayCollection = myListBuilder.getMyListArrayCollection(temp, true);
				myListItemProvider.addAll(array);
			}
			
			if(index >= 0){
				dataGrid_myList.scrollToIndex(index);
				dataGrid_myList.selectedIndex = index;
			}
			
		}
		tree_myList.scrollToIndex(selectedIndex);
//		tree_myList.openItems = openItems;
		tree_myList.selectedIndex = selectedIndex;
		
		
	}catch(error:Error){
		logManager.addLog("ローカルのマイリスト情報読み込みに失敗:" + error.toString());
		trace(error.getStackTrace());
	}
}

private function myListRenew(xml:XML, renewUnPlayCount:Boolean = true):void{
	
	var index:int = dataGrid_myList.selectedIndex;
	
	myListItemProvider.sort = null;
	
	myListItemProvider.removeAll();
	
	var myListBuilder:MyListBuilder = new MyListBuilder();
	myListItemProvider = myListBuilder.getMyListArrayCollection(xml);
	textArea_myList.text = myListBuilder.description;
	
	if(index >= 0){
		dataGrid_myList.scrollToIndex(index);
	}
	
	if(renewUnPlayCount){
		renewMyListUnPlayCount();
	}
	
	var sortFieldName:String = "dataGridColumn_index";
	var sortDescending:Boolean = false;
	
	if(tree_myList.selectedItem != null && tree_myList.selectedItem.label != null){
		var myListSortType:MyListSortType = MyListManager.instance.getMyListSortType(tree_myList.selectedItem.label);
		if(myListSortType != null){
			if(myListSortType.sortFiledName != null && myListSortType.sortFiledName.length > 0){
				sortFieldName = myListSortType.sortFiledName;
				sortDescending = myListSortType.sortFiledDescending;
			}
		}
	}
	
	myListItemProvider.sort = new Sort();
	myListItemProvider.sort.fields = [new SortField(sortFieldName, false, sortDescending)];
	myListItemProvider.refresh();
	
}

private function myListDoubleClicked(event:ListEvent):void{
	var name:String = String(event.itemRenderer.data.label);
	textinput_mylist.text = this._myListManager.getUrl(name);
	
	this.myListRenewButtonClicked(event);
	
	if(textinput_mylist.text == null || textinput_mylist.text == ""){
		textinput_mylist.text = name;
	}
}

private function donationButtonClicked(event:Event):void{
	
//	var donationRequest:URLRequest = new URLRequest("https://www.paypal.com/j1/cgi-bin/webscr");
//	donationRequest.method = "post";
//	
//	var variables1:URLVariables = new URLVariables();
//	variables1.cmd =  "_donations";
//	variables1.business = "mineappproject@me.com";
//	variables1.item_name = "MineApplicationProject";
//	variables1.item_number = "NNDD";
//	variables1.currency_code = "JPY"
//	
//	donationRequest.data = variables1;
//	
//	navigateToURL(donationRequest);
	
	donation();
	
}

private function dataGridLibraryHeaderReleaseHandler(event:Event):void{
	if(dataGrid_downloaded != null && (dataGrid_downloaded.dataProvider as ArrayCollection).sort != null){
		if(!playListManager.isSelectedPlayList){
			var sortFiled:SortField = (dataGrid_downloaded.dataProvider as ArrayCollection).sort.fields[0];
			this.libraryDataGridSortDescending = sortFiled.descending;
			this.libraryDataGridSortFieldName = sortFiled.name;
		}
	}
}

private function dataGridMyListHeaderReleaseHandler(event:Event):void{
	if(dataGrid_myList != null && (dataGrid_myList.dataProvider as ArrayCollection).sort != null){
		
		if(tree_myList.selectedItem != null){
			
			var name:String = tree_myList.selectedItem.label;
			
			if(name != null && name.length > 0){
				
				var sortFiled:SortField = (dataGrid_myList.dataProvider as ArrayCollection).sort.fields[0];
				var sortFiledDescending:Boolean = sortFiled.descending;
				var sortFiledName:String = sortFiled.name;
				
				MyListManager.instance.setMyListSortType(name, new MyListSortType(sortFiledName, sortFiledDescending));
				
			}
			
		}
	}
}

private function button_schedule_clickHandler(event:MouseEvent):void
{
	var scheduleWindow:ScheduleWindow = PopUpManager.createPopUp(this, ScheduleWindow, true) as ScheduleWindow;
	var schedule:Schedule = scheduleManager.schedule;
	if(schedule != null){
		scheduleWindow.initSchedule(schedule, scheduleManager.isScheduleEnable);
	}
	PopUpManager.centerPopUp(scheduleWindow);
	
	scheduleWindow.addEventListener(Event.COMPLETE, function(event:Event):void{
		var enable:Boolean = event.currentTarget.isScheduleEnable;
		scheduleManager.schedule = event.currentTarget.schedule;
		if(enable == true){
			//スケジューリング開始
			scheduleManager.isScheduleEnable = true;
			scheduleManager.timerStart();
		}else{
			//スケジューリング停止
			scheduleManager.isScheduleEnable = false;
			scheduleManager.timerStop();
		}
		
		label_nextDownloadTime.text = scheduleManager.scheduleString;
		
		PopUpManager.removePopUp(scheduleWindow);
	});
	scheduleWindow.addEventListener(Event.CANCEL, function(event:Event):void{
		//キャンセルなので操作しない
		PopUpManager.removePopUp(scheduleWindow);
	});
}

/**
 * 
 * @param event
 * 
 */
private function addSearchItem(event:MouseEvent):void{
	var searchItemEdit:SearchItemEdit = PopUpManager.createPopUp(this, SearchItemEdit, true) as SearchItemEdit;
	PopUpManager.centerPopUp(searchItemEdit);
	searchItemEdit.initSearchItem(new SearchItem("新規検索条件", 
		SearchSortString.convertSortTypeFromIndex(comboBox_sortType.selectedIndex), 
		combobox_serchType.selectedIndex, combobox_NicoSearch.text), true);
	searchItemEdit.addEventListener(Event.COMPLETE, function(event:Event):void{
		if(!_searchItemManager.addSearchItem(searchItemEdit.searchItem, searchItemEdit.searchItem.isDir, true)){
			Alert.show("すでに同名の検索条件が存在します。名前を変更してください。", Message.M_ERROR);
			return;
		}
		var object:Object = tree_SearchItem.openItems;
		tree_SearchItem.dataProvider = searchListProvider;
		tree_SearchItem.validateNow();
		tree_SearchItem.openItems = object;
		PopUpManager.removePopUp(searchItemEdit);
	});
	searchItemEdit.addEventListener(Event.CANCEL, function(event:Event):void{
		PopUpManager.removePopUp(searchItemEdit);
	});
}

/**
 * 
 * @param event
 * 
 */
private function removeSearchItem(event:MouseEvent):void{
	var selectedItems:Array = tree_SearchItem.selectedItems;
	if(selectedItems != null && selectedItems.length > 0){
		var searchItemNameArray:Array = new Array();
		
		for each(var object:Object in selectedItems){
			if(object.hasOwnProperty("label")){
				searchItemNameArray.push(String(object.label));
			}else{
				searchItemNameArray.push(String(object));
			}
		}
		
		if(selectedItems.length == 1){
			
			var item:SearchItem = _searchItemManager.getSearchItem(searchItemNameArray[0]);
			var text:String = "";
			if(item.isDir){
				text = "このフォルダを削除してもよろしいですか？\n" + searchItemNameArray[0];
			}else{
				text = "この検索条件を削除してもよろしいですか？\n" + searchItemNameArray[0];
			}
			
			Alert.show(text, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					_searchItemManager.removeSearchItem(String(searchItemNameArray[0]), true);
					var object:Object = tree_SearchItem.openItems;
					tree_SearchItem.dataProvider = searchListProvider;
					tree_SearchItem.validateNow();
					tree_SearchItem.openItems = object;
				}
			}, null, Alert.NO);
		}else{
			
			Alert.show("これらの検索条件・フォルダを削除してもよろしいですか？\n" + searchItemNameArray, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
				if(event.detail == Alert.YES){
					for(var i:int=0; i<searchItemNameArray.length; i++){
						_searchItemManager.removeSearchItem(searchItemNameArray[i], true);
					}
					var object:Object = tree_SearchItem.openItems;
					tree_SearchItem.dataProvider = searchListProvider;
					tree_SearchItem.validateNow();
					tree_SearchItem.openItems = object;
				}
			}, null, Alert.NO);
		}
	}

}

/**
 * 
 * @param event
 * 
 */
private function editSearchItem(event:MouseEvent):void{
	var object:Object = tree_SearchItem.selectedItem;
	var index:int = tree_SearchItem.selectedIndex;
	if(object != null){
		
		var name:String = String(object);
		if(object.hasOwnProperty("label")){
			name = String(object.label);
		}
		
		var searchItemEdit:SearchItemEdit = PopUpManager.createPopUp(this, SearchItemEdit, true) as SearchItemEdit;
		PopUpManager.centerPopUp(searchItemEdit);
		var searchItem:SearchItem = this._searchItemManager.getSearchItem(name);
		searchItemEdit.initSearchItem(searchItem, false);
		searchItemEdit.setDir(searchItem.isDir);
		
		//編集ではフォルダのタイプを変えさせない
		searchItemEdit.comboBox_isFolder.enabled = false;
		
		searchItemEdit.addEventListener(Event.COMPLETE, function(event:Event):void{
			
			var searchItem:Object = _searchItemManager.search(name);
			
			if(searchItem.hasOwnProperty("children")){
				_searchItemManager.updateMyList(searchItemEdit.searchItem, true, true, name, searchItem.children);
			}else{
				_searchItemManager.updateMyList(searchItemEdit.searchItem, true, true, name, null);
			}
			
			var object:Object = tree_SearchItem.openItems;
			tree_SearchItem.dataProvider = searchListProvider;
			tree_SearchItem.validateNow();
			tree_SearchItem.openItems = object;
			PopUpManager.removePopUp(searchItemEdit);
		});
		searchItemEdit.addEventListener(Event.CANCEL, function(event:Event):void{
			PopUpManager.removePopUp(searchItemEdit);
		});
	}
}

/**
 * 
 * @param event
 * 
 */
private function searchItemClicked(event:ListEvent):void{
	var itemName:String = String(event.itemRenderer.data.label);
	var searchItem:SearchItem = this._searchItemManager.getSearchItem(itemName);
	if(searchItem != null){
		this.combobox_serchType.selectedIndex = searchItem.searchType;
		this.comboBox_sortType.selectedIndex = SearchSortString.convertTextArrayIndexFromSearchSortType(searchItem.sortType);
		this.combobox_NicoSearch.text = searchItem.searchWord;
	}
}

/**
 * 
 * @param event
 * 
 */
private function searchItemDoubleClicked(event:ListEvent):void{
	var itemName:String = String(event.itemRenderer.data.label);
	var searchItem:SearchItem = this._searchItemManager.getSearchItem(itemName);
	if(searchItem != null){
		this.combobox_serchType.selectedIndex = searchItem.searchType;
		this.comboBox_sortType.selectedIndex = SearchSortString.convertTextArrayIndexFromSearchSortType(searchItem.sortType);
		this.combobox_NicoSearch.text = searchItem.searchWord;
		this.searchNicoButtonClicked();
	}
}

/**
 * TextInputにフォーカスが設定された際、すでにTextInputのすべてのテキストが選択された状態にします。
 * @param event
 * 
 */
private function textInputForcusEventHandler(event:FocusEvent):void{
	var textInput:TextInput = TextInput(event.currentTarget);
	textInput.selectionBeginIndex = 0;
	textInput.selectionEndIndex = textInput.text.length;
}

/**
 * 
 * @param event
 * 
 */
private function checkBoxEnableLibraryChanged(event:MouseEvent):void{
	
	isEnableLibrary = checkBox_enableLibrary.selected
//	checkbox_showOnlyNowLibraryTag.enabled = isEnableLibrary;
	
}

private function checkBoxAlwaysEcoChanged(event:MouseEvent):void{
	isAlwaysEconomy = checkBox_isAlwaysEconomyMode.selected;
	downloadManager.isAlwaysEconomy = isAlwaysEconomy;
}

/**
 * デフォルトの検索項目を追加します
 * 
 */
private function addDefSearchItems():void{
	isAddedDefSearchItems = true;
	this._searchItemManager.addDefSearchItems();
	Alert.show("検索項目一覧にデフォルトの検索項目を追加しました。", Message.M_MESSAGE);
}

/**
 * 
 * @param searchItem
 * 
 */
public function search(searchItem:SearchItem):void{
	if(viewStack.selectedIndex == SEARCH_TAB_NUM){
		setSearchItemAndStartSearch(searchItem);
	}else{
		canvas_search.addEventListener(FlexEvent.SHOW, showEventListener);
		
		viewStack.selectedIndex = SEARCH_TAB_NUM;
		
		function showEventListener(event:FlexEvent):void{
			if(searchItem != null){
				setSearchItemAndStartSearch(searchItem);
			}
			if(canvas_search.hasEventListener(FlexEvent.SHOW)){
				canvas_search.removeEventListener(FlexEvent.SHOW, showEventListener);
			}
		}
		
	}
	
}

/**
 * 
 * @param searchItem
 * 
 */
public function setSearchItemAndStartSearch(searchItem:SearchItem):void{
	comboBox_sortType.selectedIndex = SearchSortString.convertTextArrayIndexFromSearchSortType(searchItem.sortType);
	combobox_serchType.selectedIndex = searchItem.searchType;
	combobox_NicoSearch.text = searchItem.searchWord;
	searchNicoButtonClicked();
	Application.application.activate();
}

/**
 * 
 * @param event
 * 
 */
public function tagTileListItemDoubleClickEventHandler(event:ListEvent):void{
	if(event.itemRenderer.data != null){
		if(event.itemRenderer.data is String){
			var word:String = String(event.itemRenderer.data);
			search(new SearchItem(word, SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, word));
		}
	}
}

/**
 * 
 * @param event
 * 
 */
public function showMyListOnNico(event:Event):void{
	var id:String = textinput_mylist.text;
	id = MyListUtil.getMyListId(id);
	if(id != null){
		navigateToURL(new URLRequest("http://www.nicovideo.jp/mylist/" + id));
		logManager.addLog("マイリストをブラウザで表示:" + "http://www.nicovideo.jp/mylist/" + id);
	}
}

/**
 * 
 * @param event
 * 
 */
public function showRankingOnNico(event:Event):void{
	
	var url:String = null;
	
	if(this.radiogroup_period.selectedValue != 5){
		//普通のライブラリ更新
		url = Access2Nico.NICO_RANKING_URLS[this.radiogroup_period.selectedValue][this.radiogroup_target.selectedValue];
	}else{
		//新着の場合は期間を無視
		url = Access2Nico.NICO_RANKING_URLS[this.radiogroup_period.selectedValue][0];
	}
	
	navigateToURL(new URLRequest(url));
	
	logManager.addLog("ランキングをブラウザで表示:" + url);
	
}

/**
 * 
 * @param event
 * 
 */
public function showSearchResultOnNico(event:Event):void{
	
	var searchWord:String = this.combobox_NicoSearch.text
	var searchURL:String = Access2Nico.NICO_SEARCH_TYPE_URL[combobox_serchType.selectedIndex];
	var nicoSearchURL:String = null;
	
	if(searchWord.length > 0){
		
		searchWord = encodeURIComponent(searchWord);
		
		if(searchWord.indexOf("sort=") == -1 && searchWord.indexOf("order=") == -1){
			if(searchWord.indexOf("page=") == -1){
				nicoSearchURL = searchURL + searchWord + Access2Nico.NICO_SEARCH_SORT_VALUE[comboBox_sortType.selectedIndex];
			}else{
				nicoSearchURL = searchURL + searchWord + "&" + (Access2Nico.NICO_SEARCH_SORT_VALUE[comboBox_sortType.selectedIndex] as String).substring(1);
			}
		}else{
			nicoSearchURL = searchURL + searchWord;
		}
		navigateToURL(new URLRequest(nicoSearchURL));
		logManager.addLog("検索結果をブラウザで表示:" + decodeURIComponent(nicoSearchURL));
	}
}

public function connectionStatusViewCreationCompleteHandler(event:FlexEvent):void{
	connectionStatusView.setLogManager(logManager);
}

public function play():void{
	if(this.playerController != null){
		this.playerController.play();
	}
}

public function stop():void{
	if(this.playerController != null){
		this.playerController.stop();
	}
}

private function removeHistory():void{
	historyManager.clear();
}

private function removeHistoryItem(removeItems:Array):void{
	for(var index:int = removeItems.length; index != 0; index--){
		historyManager.remove(historyManager.getIndex(removeItems[index-1].dataGridColumn_videoName));
	}
}

private function historyItemHandler(event:ContextMenuEvent):void{
	var dataGrid:DataGrid = DataGrid(event.contextMenuOwner);
	if(dataGrid != null && dataGrid.dataProvider.length > 0){
		if(event.mouseTarget is DataGridItemRenderer && (event.mouseTarget as DataGridItemRenderer).data != null){
			var videoPath:String = (event.mouseTarget as DataGridItemRenderer).data.dataGridColumn_url;
			if((event.target as ContextMenuItem).label == Message.L_DOWNLOADED_MENU_ITEM_LABEL_PLAY){
				playMovie(videoPath, -1);
			}else if((event.target as ContextMenuItem).label == Message.L_RANKING_MENU_ITEM_LABEL_ADD_DL_LIST){
				
				var items:Array = dataGrid.selectedItems;
				
				var video:NNDDVideo = new NNDDVideo(videoPath);
				
				var isExistsInDLList:Boolean = downloadManager.isExists(video);
				
				if(isExistsInDLList && items.length == 1 ){
					Alert.show(Message.M_ALREADY_DLLIST_VIDEO_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
						if(event.detail == Alert.YES){
							var success:Boolean = false;
							
							for each(var item:Object in items){
								video = new NNDDVideo(item.dataGridColumn_url, item.dataGridColumn_videoName);
								success = downloadManager.add(video, isAutoDownload);
							}
							if(!success){
								Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
							}else{
								scrollToLastAddedDownloadItem();
							}
						}
					});
				}else{
					var success:Boolean = false;
					
					for each(var item:Object in items){
						video = new NNDDVideo(item.dataGridColumn_url, item.dataGridColumn_videoName);
						success = downloadManager.add(video, isAutoDownload);
					}
					if(!success){
						Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
					}else{
						scrollToLastAddedDownloadItem();
					}
					
				}
				
			}else if((event.target as ContextMenuItem).label == Message.L_DOWNLOADED_MENU_ITEM_LABEL_DELETE_BY_QUEUE){
				var items:Array = dataGrid.selectedItems;
				
				for(var index:int = items.length; index != 0; index--){
					historyManager.remove(historyManager.getIndex(items[index-1].dataGridColumn_videoName));
				}
			}
		}
	}
}

private function historyItemPlay(event:Event):void{
	
	var url:String = dataGrid_history.selectedItem.dataGridColumn_url;
	
	playMovie(url, -1);
	
}

private function historyItemDownload(event:Event):void{
	
	var items:Array = dataGrid_history.selectedItems;
	if(items.length == 0){
		return;
	}
	var url:String = dataGrid_history.selectedItem.dataGridColumn_url;
	
	var video:NNDDVideo = new NNDDVideo(url);
	
	var isExistsInDLList:Boolean = downloadManager.isExists(video);
	
	if(isExistsInDLList && items.length == 1 ){
		Alert.show(Message.M_ALREADY_DLLIST_VIDEO_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
			var success:Boolean = false;
			if(event.detail == Alert.YES){
				for each(var item:Object in items){
					video = new NNDDVideo(item.dataGridColumn_url);
					success = downloadManager.add(video, isAutoDownload);
				}
			}
			if(!success){
				Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
			}else{
				scrollToLastAddedDownloadItem();
			}
		});
	}else{
		var success:Boolean = false;
		
		for each(var item:Object in items){
			video = new NNDDVideo(item.dataGridColumn_url);
			success = downloadManager.add(video, isAutoDownload);
		}
		
		if(!success){
			Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
		}else{
			scrollToLastAddedDownloadItem();
		}
	}
	
}

private function historyItemDoubleClickEventHandler(event:ListEvent):void{
	
	var myDataGrid:DataGrid = (event.currentTarget as DataGrid);
	
	var mUrl:String = myDataGrid.dataProvider[myDataGrid.selectedIndex].dataGridColumn_url;
	
	if(mUrl != null){
		if(isDoubleClickOnStreaming){
			playMovie(mUrl, -1);
		}else{
			var video:NNDDVideo = new NNDDVideo(mUrl);
			
			var isExistsInDLList:Boolean = downloadManager.isExists(video);
			
			if(isExistsInDLList){
				Alert.show(Message.M_ALREADY_DLLIST_VIDEO_EXIST, Message.M_MESSAGE, (Alert.YES | Alert.NO), null, function(event:CloseEvent):void{
					if(event.detail == Alert.YES){
						if(!downloadManager.add(video, isAutoDownload)){
							Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
						}else{
							scrollToLastAddedDownloadItem();
						}
					}
				});
			}else{
				if(!downloadManager.add(video, isAutoDownload)){
					Alert.show(Message.M_DOWNLOAD_LIST_COUNT_OVER, Message.M_ERROR);
				}else{
					scrollToLastAddedDownloadItem();
				}
			}
		}
	}
}

public function get isMouseHide():Boolean{
	if(this.playerController != null && this.playerController.isOpen()){ 
		return (this.playerController.videoPlayer as VideoPlayer).isMouseHide;
	}else{
		return false;
	}
	
}

private function checkBoxAppendCommentChanged(event:Event):void{
	this.isAppendComment = event.target.selected;
	if(playerController != null && playerController.videoInfoView != null){
		playerController.videoInfoView.setAppendComment(this.isAppendComment);
	}
	this.downloadManager.isAppendComment = this.isAppendComment;
	
	numericStepper_saveCommentMaxCount.enabled = this.isAppendComment;
}

private function numericStepperSaveCommentMaxCountChanged(event:Event):void{
	this.saveCommentMaxCount = numericStepper_saveCommentMaxCount.value;
}

public function getSaveCommentMaxCount():Number{
	return this.saveCommentMaxCount;
}

public function getAppendComment():Boolean{
	return this.isAppendComment;
}

public function setAppendComment(boolean:Boolean):void{
	this.isAppendComment = boolean;
	if(checkBox_isAppendComment != null){
		checkBox_isAppendComment.selected = boolean;
	}
	this.downloadManager.isAppendComment = this.isAppendComment;
}

protected function myListRenewScheduleTimeChange(event:ListEvent):void{
	
	var str:String = (event.currentTarget as ComboBox).selectedLabel;
	
	if(str != null){
		try{
			var delay:Number = Number(str);
			this.myListRenewScheduleTime = delay;
			
			MyListRenewScheduler.instance.stop();
			
			//秒 = 分/60  ms=(分/60)/1000
			MyListRenewScheduler.instance.start((this.myListRenewScheduleTime*60)*1000);
			
		}catch(error:Error){
			trace(error.getStackTrace());
		}
	}
	
}

protected function checkBoxMylistRenewOnScheduleChanged(event:Event):void{
	this.mylistRenewOnScheduleEnable = checkBox_myListRenewOnSchedule.selected;
	MyListRenewScheduler.instance.stop();
	if(this.mylistRenewOnScheduleEnable){
		MyListRenewScheduler.instance.start((this.myListRenewScheduleTime*60)*1000);
	}
}

protected function treeMyListInitializer():void{
	tree_myList.itemRenderer = new ClassFactory(MyListTreeItemRenderer);
	
	tree_myList.invalidateList();
	tree_myList.validateNow();
	
}

protected function myListRenewNow():void{
	viewStack.selectedIndex = MYLIST_TAB_NUM;
	MyListRenewScheduler.instance.startNow();
}

protected function getMyListIds(event:Event):void{
	MyListManager.instance.addEventListener(MyListManager.MYLIST_RENEW_COMPLETE, myListRenewCompleteHandler);
	MyListManager.instance.renewMyListIds(this.MAILADDRESS, this.PASSWORD);
}

protected function myListRenewCompleteHandler(event:Event):void{
	MyListManager.instance.removeEventListener(MyListManager.MYLIST_RENEW_COMPLETE, myListRenewCompleteHandler);
	renewMyListUnPlayCount();
	
	tree_myList.invalidateList();
	tree_myList.validateNow();
}

protected function logAreaRenewButtonClicked(event:Event):void{
	logManager.showLog(textArea_log);
}

protected function fontResetButtonClicked(event:Event):void{
	var fontName:String = FontUtil.setFont("Verdana");
	ConfigManager.getInstance().setItem("fontFamily", fontName);
	fontListRenew();
}

protected function fontComboboxChanged(event:ListEvent):void{
	var fontName:String = comboBox_font.selectedLabel;
	FontUtil.setFont(fontName);
	ConfigManager.getInstance().setItem("fontFamily", fontName);
	fontListRenew();
}

protected function fontSizeComboboxChanged(event:ListEvent):void{

	var size:int = 12;
	if(comboBox_fontsize.selectedIndex == 0){
		size = 10;
	}else if(comboBox_fontsize.selectedIndex == 1){
		size = 11;
	}else if(comboBox_fontsize.selectedIndex == 2){
		size = 12;
	}
	FontUtil.setSize(size);
	ConfigManager.getInstance().setItem("fontSize", size);
	fontSizeListRenew();
}

public function setPlayerFont(fontName:String):void{
	if(this.playerController != null){
		this.playerController.setFont(fontName);
	}
}

public function setPlayerFontSize(size:int):void{
	if(this.playerController != null){
		this.playerController.setFontSize(size);
	}
}

public function openProjectPage(event:Event):void{
	navigateToURL(new URLRequest("http://sourceforge.jp/projects/nndd/simple/"));
}

protected function playListContextMenuItemDisplayingEventHandler(event:Event):void{
	var item:ContextMenuItem = (event.currentTarget as ContextMenuItem);
	
	if(item != null){
		
		item.submenu = new NativeMenu();
		
		var nameArray:Array = PlayListManager.instance.getPlayListNames();
		for each(var name:String in nameArray){
			var menuItem:ContextMenuItem = new ContextMenuItem(name);
			menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addPlayListContextMenuItemClicked);
			item.submenu.addItem(menuItem);
		}
		
	}
}

protected function addPlayListContextMenuItemClicked(event:ContextMenuEvent):void{
	var contextMenuItem:ContextMenuItem = (event.target as ContextMenuItem);
	
	var videos:Array = new Array();
	if(event.contextMenuOwner is DataGrid){
		var column_name:String = null;
		var column_path:String = null;
		var dataGrid:DataGrid = (event.contextMenuOwner as DataGrid);
		if(dataGrid.id == "dataGrid_downloaded"){
			// ライブラリ
			column_name = "dataGridColumn_videoName";
			column_path = "dataGridColumn_videoPath";
		}else if(dataGrid.id == "dataGrid_ranking"){
			// ランキング
			column_name = "dataGridColumn_videoName";
			column_path = "dataGridColumn_nicoVideoUrl";
		}else if (dataGrid.id == "dataGrid_search"){
			// 検索
			column_name = "dataGridColumn_videoName";
			column_path = "dataGridColumn_nicoVideoUrl";
		}else if (dataGrid.id == "dataGrid_myList"){
			// マイリスト
			column_name = "dataGridColumn_videoName";
			column_path = "dataGridColumn_videoUrl";
		}else if (dataGrid.id == "dataGrid_downloadList"){
			// DLリスト
			column_name = "col_videoName";
			column_path = "col_videoUrl";
		}else if (dataGrid.id == "dataGrid_history"){
			// 履歴
			column_name = "dataGridColumn_videoName";
			column_path = "dataGridColumn_url";
		}
		
		for each(var object:Object in dataGrid.selectedItems){
			
			var videoName:String = object[column_name];
			if(videoName.indexOf("\n") != -1){
				videoName = videoName.substring(0, videoName.indexOf("\n"));
			}
			var path:String = PathMaker.getVideoID(videoName);
			if(column_path != null){
				path = object[column_path];
			}else{
				path = "http://www.nicovide.co.jp/watch/" + path;
			}
			
			videos.push(new NNDDVideo(path, videoName));
		}
		
	}
	
	var name:String = contextMenuItem.label;
	var pIndex:int = PlayListManager.instance.getPlayListIndexByName(name);
	
	if(videos.length > 0 && pIndex != -1){
		videos = videos.reverse();
		PlayListManager.instance.addNNDDVideos(pIndex, videos);
		updatePlayList(pIndex);
	}else{
		if(videos.length == 0){
			Alert.show("動画が選択されていません", Message.M_MESSAGE);
		}else if(pIndex == -1){
			Alert.show("指定されたプレイリストが見つかりませんでした\n\nプレイリスト名:" + name, Message.M_ERROR);
		}
	}
	
}