package org.mineap.nndd
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTMLUncaughtScriptExceptionEvent;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestDefaults;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.Label;
	import mx.core.Application;
	import mx.events.CloseEvent;
	import mx.formatters.DateFormatter;
	import mx.formatters.NumberFormatter;
	
	import org.mineap.nndd.player.comment.Command;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.library.LocalVideoInfoLoader;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.player.PlayerController;
	import org.mineap.nndd.util.NicoPattern;
	import org.mineap.nndd.util.PathMaker;
	import org.mineap.nndd.util.ThumbInfoAnalyzer;
	import org.mineap.nicovideo4as.analyzer.RankingAnalyzer;
	import org.mineap.nicovideo4as.model.NicoRankingUrl;
	import org.mineap.nicovideo4as.model.RankingItem;
	import org.mineap.nicovideo4as.util.HtmlUtil;
	import org.mineap.nndd.downloadedList.DownloadedListManager;
	
	/**
	 * Access2Nico.as
	 * ニコニコ動画へのアクセスを提供します。
	 * 
	 * <b>注意：動画のダウンロード処理はorg.mineap.a2n4asパッケージに移行されました。
	 * 関連するこのクラスの関数は推奨されません。</>
	 * 
	 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */	
	public class Access2Nico extends EventDispatcher
	{
		
		private var downLoadedListManager:DownloadedListManager;
		private var playerController:PlayerController;
		private var logManager:LogManager;
		private var libraryManager:ILibraryManager;
		private var downloadProvider:ArrayCollection;
		
		private var isRankingListGetting:Boolean = false;
		private var isVideoGetting:Boolean = false;
		private var isAccessing:Boolean = false;
		private var isSearch:Boolean = false;
		private var isStreamingPlay:Boolean = false;
		private var isCommentOnly:Boolean = false;
		private var isMyListGroupRenew:Boolean = false;
		private var isMyListRenew:Boolean = false;
		private var isGetThumbInfo:Boolean = false;
		private var isVideoOnlyDownload:Boolean = false;
		private var isNicowariGetting:Boolean = false;
		private var isGetIchiba:Boolean = false;
		private var isCommentPost:Boolean = false;
		private var showOnlyPermissionIDComment:Boolean = false;
		private var isEconomy:Boolean = true;
		private var isOtherVideo:Boolean = false
		private var isContactTheUser:Boolean = false;
		private var isThumbImgGetting:Boolean = false;
		
		/*追加作成分*/
		private var nnddvideodownload:NNDDDownloader;
		
		/*  */
		
		private var loginLoader:URLLoader;
		private var watchLoader:URLLoader;
		private var listLoader:URLLoader;
		private var commentLoader:URLLoader;
		private var videoLoader:URLLoader;
		private var downLoader:URLLoader;
		private var oldListLoader:URLLoader;
		private var searchLoader:URLLoader;
		private var myListGroupLoader:URLLoader;
		private var myListLoader:URLLoader;
		
		private var videoURL:String;
		private var nicoRankingURL:String;
		private var nicoSearchURL:String;
		private var myPageUrl:String;
		private var myListPageUrl:String;
		private var thumbVideoID:String;
		
		private var rankingListProvider:ArrayCollection;
		private var commentListProvider:ArrayCollection;
		private var ownerCommentListProvider:ArrayCollection;
		private var myListProvider:ArrayCollection;
		private var myListGroupProvider:Array = new Array();
//		private var ngList:ArrayCollection;
		private var pageLinkListProvider:Array;
		
		private var tagsArray:ArrayCollection = null;
		private var tagArray:Array;
		
		private var urlList:Array = new Array();
		private var categoryList:Array = new Array();
		private var myListGroupList:Array = new Array();
		
		private var rankingListName:String;
		
		private const VIDEO_DOWNLOAD:int = 0;
		private const COMMENT_DOWNLOAD:int = 1;
		private const NICOWARI_DOWNLOAD:int = 2;
		
		private var videoTitle:String;
		private var videoID:String;
		private var videoType:String;
		private var nicowariID:String;
			
		private var downloadedVideoFileName:String = null;
		
		private var path:String;
		
		private var mailAddress:String;
		private var password:String;
				
		private var lastSaveComment:String = "";
		private var lastSaveOwnerComment:String = "";
		
		private var rankingIndex:int = -1;
		private var rankingVideoName:String;
		
		private var loginUrl:String;
		private var topPageUrl:String;
		
		private var queueIndex:int = -1;
		
		private var label_statusInfo:Label = null;
		
		private var comment:String = "";
		private var vpos:int = 0;
		private var mail:String = "";
		private var messageServerUrl:String = "";
		private var userID:String = "";
		private var isPremium:String = "0";
		
		private var postCommentXML:XML;
		
		private var owner_description:String = "取得できませんでした。";
		private var videoStatus:String = "サムネイル情報を取得できませんでした。";
		
		private var ichibaInfo:String = "市場情報が取得できませんでした。";
		
		private var pageIndex:int = 1;
		
		private var myNicowariVideoIDs:Array = new Array();
		
		private var analyzer:ThumbInfoAnalyzer = null;
		
		public static const DOWNLOAD_COMPLETE:String = "DownloadComplete";
		public static const RANKING_GET_COMPLETE:String = "RankingGetComplete";
		public static const COMMENT_DOWNLOAD_COMPLETE:String = "CommentDownloadComplete";
		public static const NICOCHART_RANKING_GET_COMPLETE:String = "NicochartRankingGetComplete";
		public static const NICO_SEARCH_COMPLETE:String = "NicoSearchComplete";
		public static const NICO_MY_PAGE_LIST_GET_COMPLETE:String = "NicoMyPageListGetComplete";
		public static const NICO_MY_LIST_GET_COMPLETE:String = "NicoMyListGetComplete";
		public static const NICO_THUMB_INFO_GET_COMPLETE:String = "NicoThumbInfoGetComplete";
		public static const NICO_SINGLE_THUMB_INFO_GET_COMPLETE:String = "NicoSingleThumbInfoGetComplete";
		public static const NICOWARI_DOWNLOAD_COMPLETE:String = "NicowariDownloadComplete";
		public static const DOWNLOAD_CANCEL:String = "DownloadCancel";
		public static const DOWNLOAD_ERROR_CANCEL:String = "DownloadErrorCancel";
		public static const NICO_ICHIBA_INFO_GET_COMPLETE:String = "NicoIchibaInfoGetComplete";
		public static const NICO_POST_COMMENT_COMPLETE:String = "NicoPostCommentComplete";
		public static const NICO_POST_COMMENT_FAIL:String = "NicoPostCommentFail"
		
		public static const LOGIN_URL:String = "https://secure.nicovideo.jp/secure/login?site=niconico";
		public static const LOGIN_FAIL_URL:String = "https://secure.nicovideo.jp/secure/login_form?message=cant_login";
		public static const TOP_PAGE_URL:String = "http://www.nicovideo.jp/";
		public static const NICOCHART_URL:String = "http://www.nicochart.jp/ranking/";
		public static const NICO_WATCH_VIDEO_URL:String = "http://www.nicovideo.jp/watch/";
		
		public static const NICO_RANKING_URLS:Array = new Array(
			new Array("http://www.nicovideo.jp/ranking/mylist/daily/","http://www.nicovideo.jp/ranking/view/daily/","http://www.nicovideo.jp/ranking/res/daily/","http://www.nicovideo.jp/ranking/fav/daily/"),
			new Array("http://www.nicovideo.jp/ranking/mylist/weekly/","http://www.nicovideo.jp/ranking/view/weekly/","http://www.nicovideo.jp/ranking/res/weekly/","http://www.nicovideo.jp/ranking/fav/weekly/"),
			new Array("http://www.nicovideo.jp/ranking/mylist/monthly/","http://www.nicovideo.jp/ranking/view/monthly/","http://www.nicovideo.jp/ranking/res/monthly/","http://www.nicovideo.jp/ranking/fav/monthly/"),
			new Array("http://www.nicovideo.jp/ranking/mylist/hourly/","http://www.nicovideo.jp/ranking/view/hourly/","http://www.nicovideo.jp/ranking/res/hourly/","http://www.nicovideo.jp/ranking/fav/hourly/"),
			new Array("http://www.nicovideo.jp/ranking/mylist/total/","http://www.nicovideo.jp/ranking/view/total/all/","http://www.nicovideo.jp/ranking/res/total/","http://www.nicovideo.jp/ranking/fav/total/"),
			new Array("http://www.nicovideo.jp/newarrival/")
		);
		
		public static const SEARCH_UP_NEW:int = 0;
		public static const SEARCH_UP_OLD:int = 1;
		public static const SEARCH_PLAY_COUNT_MANY:int = 2;
		public static const SEARCH_PLAY_COUNT_FEW:int = 3;
		public static const SEARCH_COMMENT_MANY:int = 4;
		public static const SEARCH_COMMENT_FEW:int = 5;
		public static const SEARCH_COMMENT_NEW:int = 6;
		public static const SEARCH_COMMENT_OLD:int = 7;
		public static const SEARCH_MYLIST_MANY:int = 8;
		public static const SEARCH_MYLIST_FEW:int = 9;
		public static const SEARCH_PLAY_TIME_LONG:int = 10;
		public static const SEARCH_PLAY_TIME_SHORT:int = 11;
		
		public static const NICO_SEARCH_SORT_VALUE:Array = new Array(
			"?sort=f&order=d","?sort=f&order=a","?sort=v&order=d","?sort=v&order=a","?sort=r&order=d","?sort=r&order=a","?sort=n&order=d","?sort=n&order=a","?sort=m&order=d","?sort=m&order=a","?sort=l&order=d","?sort=l&order=a"
		);
		
		public static const NICO_SEARCH_SORT_TEXT:Array = new Array(
			"投稿が新しい順","投稿が古い順","再生が多い順","再生が少ない順","コメントが多い順","コメントが少ない順","コメントが新しい順","コメントが古い順","マイリストが多い順","マイリストが少ない順","再生時間が長い順","再生時間が短い順"
		);
		
		public static const NICO_SEARCH_TYPE_TEXT:Array = new Array(
			"キーワード", "タグ"//, "タグを"
		);
		
		public static const NICO_SEARCH_TYPE_URL:Array = new Array(
			"http://www.nicovideo.jp/search/", "http://www.nicovideo.jp/tag/"//, "http://www.nicovideo.jp/related_tag/"
		);
		
		public static const NICO_MY_PAGE_URL:String = "http://www.nicovideo.jp/my";
		
		private var isCancel:Boolean = false;
		
		private var nicoPattern:NicoPattern = new NicoPattern();
		
		/**
		 * Access2Nicoを初期化します。<br>
		 * Access2Nicoは、与えられたProgressBar、DownLoadedListManager、
		 * PlayerControllerで変数を初期化します。これらの値は、ダウンロードの進捗、
		 * ダウンロードが完了した項目のリストへの追加、ダウンロード後（中）の再生に利用されます。<br>
		 * <br>
		 * <!注意！> フラグが残るので一度使ったら作り直してください。
		 * 
		 * @param progressbar
		 * @param downLoadedListManager
		 * @param playerController
		 * @param logString
		 * @param statusLabel
		 * @param commentListProvider
		 */
		public function Access2Nico(downloadProvider:ArrayCollection, downLoadedListManager:DownloadedListManager, 
			playerController:PlayerController, logManager:LogManager, commentListProvider:ArrayCollection)
		{
			this.downLoadedListManager = downLoadedListManager;
			this.playerController = playerController;
			this.logManager = logManager;
			this.downloadProvider = downloadProvider;
			this.commentListProvider = commentListProvider;
			if(playerController != null){
				this.ownerCommentListProvider = playerController.videoInfoView.ownerCommentProvider;
				this.showOnlyPermissionIDComment = playerController.videoInfoView.isShowOnlyPermissionComment;
			}
//			this.ngList = ngListProvider;
		}
		
		/**
		 * ダウンロードを行います。<br>
		 * 外部向けAPIです。
		 * 
		 * @param topPageUrl ニコニコ動画のトップページのURLです。
		 * @param loginUrl ログイン先のURLです。
		 * @param videoURL ダウンロードしたい動画のURLです。
		 * @param mailAddress ログイン名に使われるメールアドレスです。
		 * @param password ログイン時に必要なパスワードです。
		 * @param isStreamingPlay 動画をダウンロードせずにストリーミング再生するかどうかのフラグです。
		 * @param path 保存先ディレクトリを指定する絶対パスです。
		 * @param target イベントの通知先です。
		 * @param libraryManager ライブラリを管理するLibraryManagerです。
		 * @param isOtherVideo 動画以外の更新を行う場合はこれにtrueをセットします。
		 * @param isCommentOnly ダウンロードをコメントのみ行う場合、これにtrueをセットします。
		 * @param videoFileName コメントのダウンロードを行う際、コメントファイルの名前にこれを使用します。
		 * 						ファイル名の例「videoFileName - [videoId]([Owner]).xml」
		 * @param rankinProvider ランキングリストを管理するプロバイダーです。
		 * @param rankingIndex ダウンロードしたい項目のリストのインデックスです。
		 * 
		 */
//		public function request_downLoad(topPageUrl:String, loginUrl:String, videoURL:String, 
//			mailAddress:String, password:String, isStreamingPlay:Boolean, path:String, libraryManager:LibraryManager,
//			isOtherVideo:Boolean ,isCommentOnly:Boolean, videoFileName:String, rankinProvider:ArrayCollection, rankingIndex:int,
//			rankingVideoName:String, tagArray:Array, isStart:Boolean = true, isContactTheUser:Boolean = true, label_statusInfo:Label = null):void
//		{
//			trace("function:downLoad");
//			this.label_statusInfo = label_statusInfo;
//			this.videoURL = videoURL;
//			this.isStreamingPlay = isStreamingPlay;
//			this.path = path;
//			
//			this.isVideoGetting = true;
//			this.isOtherVideo = isOtherVideo;
//			this.isCommentOnly = isCommentOnly;
//			this.downloadedVideoFileName = videoFileName;
//			
//			this.rankingListProvider = rankinProvider;
//			this.libraryManager = libraryManager;
//			
//			this.rankingIndex = rankingIndex;
//			this.queueIndex = rankingIndex;
//			this.rankingVideoName = rankingVideoName;
//			
//			this.tagArray = tagArray;
//			
//			this.isContactTheUser = isContactTheUser;
//			
//			removeCache();
//			
//			this.mailAddress = mailAddress;
//			this.password = password;
//			
//			this.topPageUrl = topPageUrl;
//			this.loginUrl = loginUrl;
//			
//			if(isStart){
//				login(topPageUrl, loginUrl, this.mailAddress, this.password);
//			}
//			
//		}
		
		/**
		 * request_download()を、isStart=falseで実行した際に、
		 * 実際にダウンロードを開始するタイミングでこのメソッドを呼びます。
		 * 
		 */
		public function startRequest(queueIndex:int):void{
			this.queueIndex = queueIndex;
			login(this.topPageUrl, this.loginUrl, this.mailAddress, this.password);
//			var videoId:String = PathMaker.getVideoID(videoURL);
//			this.nnddvideodownload.requestDownload(mailAddress, password, videoId, null, new File(path));
		}
		
		/**
		 * 
		 * @param topPageUrl
		 * @param loginUrl
		 * @param videoURL
		 * @param mailAddress
		 * @param password
		 * @param path
		 * @param nicowariVideoID
		 * @param videoFileName コメントのダウンロードを行う際、コメントファイルの名前にこれを使用します。
		 * 						ファイル名の例「videoFileName - [videoId]([Owner]).xml」
		 * 
		 */
		public function request_downLoad_Nicowari(topPageUrl:String, loginUrl:String, videoURL:String, 
			mailAddress:String, password:String, path:String, nicowariVideoID:String, videoFileName:String, queueIndex:int):void{
			
			this.videoURL = videoURL;
			this.path = path;
			
			this.isNicowariGetting = true;
			
			this.libraryManager = libraryManager;
			
			this.nicowariID = nicowariVideoID;
			this.queueIndex = queueIndex;
			
			this.downloadedVideoFileName = videoFileName;
			
			this.mailAddress = mailAddress;
			this.password = password;
			
			login(topPageUrl, loginUrl, mailAddress, password);
			
		}
		
		/**
		 * ランキングを取得します。<br>
		 * 外部向けAPIです。
		 * 
		 * @param rankingURL ランキングを取得するURLです。
		 * @param rankingListProvider ランキングを管理するプロバイダーです。
		 * @param tagsArray タグを格納するArrayCollectionです。
		 */
		public function request_rankingRenew(period:int, target:int, category:String, rankingListProvider:ArrayCollection, pageIndex:int, tagsArray:ArrayCollection = null, label_status:Label = null):void
		{
			this.rankingListProvider = rankingListProvider;
			this.tagsArray = tagsArray;
			this.libraryManager = LibraryManagerBuilder.instance.libraryManager;
			this.label_statusInfo = label_status;

			this.pageIndex = pageIndex;
			this.isRankingListGetting = true;
			
			listLoader = watchRanking(period, target, category, pageIndex);
		}
		
		/**
		 * ニコチャートからランキングを取得します。<br>
		 * 外部向けAPIです。
		 *  
		 * @param rankingURL ランキングを取得するニコチャートのURLです。
		 * @param rankingListProvider ランキングを管理するプロバイダーです。
		 * 
		 */
		public function request_rankingRenewOnNicoChart(rankingURL:String, rankingListProvider:ArrayCollection):void
		{
			this.rankingListProvider = rankingListProvider;
			
			var request:URLRequest = new URLRequest(rankingURL);
			this.oldListLoader = new URLLoader();
			request.method="GET";
			
			oldListLoader.addEventListener(Event.COMPLETE, watchRankingNicoChart);
			oldListLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			oldListLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			oldListLoader.load(request);
		}
		
		
		/**
		 * ニコニコ動画のマイページにアクセスしてマイリストの一覧を取得します。<br>
		 * 外部向けAPIです。<br>
		 * マイページの閲覧にはログインが必要です。
		 * 
		 * @param topPageUrl
		 * @param loginUrl
		 * @param mailAddress
		 * @param password
		 * @param myPageUrl
		 * @param myListGroupProvider
		 * 
		 */
		public function request_myListGroupRenew(topPageUrl:String, loginUrl:String, 
			mailAddress:String, password:String, myPageUrl:String, myListGroupProvider:Array):void
		{
			
			this.isMyListGroupRenew = true;
			this.myPageUrl = myPageUrl;
			this.myListGroupProvider = myListGroupProvider;
			
			this.mailAddress = mailAddress;
			this.password = password;
			
			login(topPageUrl, loginUrl, mailAddress, password);
		}
		
		
		/**
		 * 指定されたマイリストにアクセスしてマイリストの項目一覧を取得します。<br>
		 * 外部向けAPIです。<br>
		 * マイリストの閲覧にはログインが必要です。
		 * 
		 * @param topPageUrl
		 * @param loginUrl
		 * @param mailAddress
		 * @param password
		 * @param myListPageUrl
		 * @param myListProvider
		 * 
		 */
		public function request_myListRenew(topPageUrl:String, loginUrl:String, 
			mailAddress:String, password:String, myListPageUrl:String, myListProvider:ArrayCollection):void
		{
			
			this.isMyListRenew = true;
			this.myListPageUrl = myListPageUrl;
			this.myListProvider = myListProvider;
			
			this.mailAddress = mailAddress;
			this.password = password;
			
			login(topPageUrl, loginUrl, mailAddress, password);
		}
		
		
		/**
		 * ニコニコ動画で指定された単語について検索を行います。<br>
		 * 外部向けAPIです。<br>
		 * 
		 * @param topPageUrl ニコニコ動画のトップページのURLです
		 * @param loginUrl ログイン先のURLです
		 * @param mailAddress ログインに必要なメールアドレスです。
		 * @param password ログインに必要なパスワードです。
		 * @param searchURL 検索先のURLです。このURLとsearchWordを結合してリクエストとして送信します。
		 * @param searchWord 検索語です。
		 * @param rankingListProvider ランキングリストを管理するArrayCollectionです。
		 * @param libraryManager ライブラリを管理するLibraryManagerクラスのインスタンスです。
		 * @param sortIndex 取得した検索結果をどのような順番でソートするかを表す数字です。
		 * @param tagArray タグを格納するArrayです。
		 * 
		 */
		public function request_search(topPageUrl:String, loginUrl:String, 
			mailAddress:String, password:String, searchURL:String, 
			searchWord:String, rankingListProvider:ArrayCollection, sortIndex:int, pageIndex:int, tagArray:Array = null, label_statusInfo:Label = null):void
		{
			this.rankingListProvider = rankingListProvider;
			this.tagArray = tagArray;
			
			this.libraryManager = LibraryManagerBuilder.instance.libraryManager;
			
			this.pageIndex = pageIndex;
			
			this.isSearch = true;
			
			if(searchWord.indexOf("sort=") == -1 && searchWord.indexOf("order=") == -1){
				if(searchWord.indexOf("page=") == -1){
					if(sortIndex != -1){
						this.nicoSearchURL = searchURL + searchWord + Access2Nico.NICO_SEARCH_SORT_VALUE[sortIndex];
					}else{
						this.nicoSearchURL = searchURL + searchWord;
					}
				}else{
					if(sortIndex != -1){
						this.nicoSearchURL = searchURL + searchWord + "&" + (Access2Nico.NICO_SEARCH_SORT_VALUE[sortIndex] as String).substring(1);
					}else{
						this.nicoSearchURL = searchURL + searchWord;
					}
				}
			}else{
				this.nicoSearchURL = searchURL + searchWord;
			}
			
//			logManager.addLog(decodeURIComponent(this.nicoSearchURL));
			
			this.mailAddress = mailAddress;
			this.password = password;
			
			this.label_statusInfo = label_statusInfo;
			
//			trace(nicoSearchURL);
			
			this.login(topPageUrl, loginUrl, mailAddress, password);
			
		}
		
		
		
		/**
		 * 指定された動画のサムネイル情報を取得します。
		 * @param topPageUrl
		 * @param loginUrl
		 * @param mailAddress
		 * @param password
		 * @param videoID
		 * @param tagsArray
		 * 
		 */
		public function request_thumbInfo(topPageUrl:String, loginUrl:String, 
			mailAddress:String, password:String, videoID:String, tagArray:Array):void{
			
			this.isGetThumbInfo = true;
			this.thumbVideoID = videoID;
			this.tagArray = tagArray;
			
			this.mailAddress = mailAddress;
			this.password = password;
			
			this.login(topPageUrl, loginUrl, mailAddress, password);
		}
		
		/**
		 * 指定された動画の市場情報を取得します。
		 * @param topPageUrl
		 * @param loginUrl
		 * @param mailAddress
		 * @param password
		 * @param videoID
		 * 
		 */
		public function request_ichiba(topPageUrl:String, loginUrl:String, mailAddress:String, password:String, videoID:String):void{
			
			this.isGetIchiba = true;
			this.videoID = videoID;
			
			this.mailAddress = mailAddress;
			this.password = password;
			
			this.login(topPageUrl, loginUrl, mailAddress, password);
		}
		
		/**
		 * 
		 * @param topPageUrl
		 * @param loginUrl
		 * @param mailAddress
		 * @param password
		 * @return 
		 * 
		 */
		public function postMessage(topPageUrl:String, loginUrl:String, mailAddress:String, password:String, comment:String, mail:String, videoID:String, vpos:int):void{
			this.isVideoGetting = true;
			this.isCommentOnly = true;
			this.isCommentPost = true;
			this.videoURL = NICO_WATCH_VIDEO_URL + videoID;
			
			this.comment = comment;
			this.mail = mail;
			this.videoID = videoID;
			this.vpos = vpos;
			
			login(topPageUrl, loginUrl, this.mailAddress, this.password);
		}
		
		/**
		 * 取得したランキングリストに対応するURLのリストを返します。<br>
		 * ランキングの取得が完了していない場合は空のリストがかえります。<br>
		 * 外部向けAPIです。
		 * 
		 * @return ランキングに対応する動画のURLとサムネイルのURLのリスト。
		 * 
		 */
		public function getRankingUrlList():Array
		{
//			trace(urlList);
			return this.urlList;
		}
		
		/**
		 * 取得したランキングリストに対応するカテゴリの一覧を返します。<br>
		 * カテゴリの一覧が取得し終わっていない場合は空のリストがかえります。<br>
		 * 外部むけAPIです。
		 * 
		 * @return ランキングに対応するカテゴリの一覧とそのカテゴリに対応するURLの末尾部分
		 * 
		 */
		public function getCategoryTitleList():Array
		{
//			trace(categoryList);
			return this.categoryList;	
		}
		
		
		/**
		 * 検索結果を返します。<br>
		 * 外部向けAPIです。
		 * 
		 * @return ニコニコ動画から取得した検索の結果。
		 */
		public function getSearchResult():Array
		{
//			trace(urlList);
			return this.urlList;
		}
		
		/**
		 * マイリストグループ更新の際に受け取ったプロバイダを返します。<br>
		 * 外部向けAPIです。
		 * 
		 * @return ニコニコ動画から取得したマイリスト名の一覧が格納されたデータプロバイダ
		 * 
		 */
		public function getMyListGroupProvider():Array
		{
//			trace(myListGroupProvider);
			return this.myListGroupProvider;
		}
		
		/**
		 * マイリストグループ更新で取得したマイリスト名とマイリストのURLを格納した配列を返します。<br>
		 * 外部向けAPIです。
		 * 
		 * @return ニコニコ動画から取得したマイリスト名とマイリストURLを格納する２次元配列<br>
		 * <pre>
		 * Array(
		 * 	Array("マイリスト名","マイリストのURL"),
		 * 	Array("マイリスト名","マイリストのURL"),
		 * 	...
		 * )
		 * </pre>
		 */
		public function getMyListGroupList():Array{
//			trace(this.myListGroupList);
			return this.myListGroupList;
		}
		
		/**
		 * ランキングリストを返します。<br>
		 * 
		 * @return 
		 */
		public function getRankingList():ArrayCollection{
//			trace(this.rankingListProvider);
			return this.rankingListProvider;
		}
		
		public function getRankingNewList():ArrayCollection{
			
			return this.rankingListProvider;
		}
		
		
		/**
		 * マイリストを管理するProviderであるArrayCollectionを返します。
		 * 
		 * @return 
		 * 
		 */
		public function getMyListProvider():ArrayCollection
		{
//			trace(myListProvider);
			return this.myListProvider;
		}
		
		
		/**
		 * 現在ランキングリストに表示されている項目のタグ一覧を返します。<br>
		 * 
		 * @return 
		 * 
		 */
		public function getTagArray():ArrayCollection{
//			trace(tagsArray);
			return this.tagsArray;
		}
		
		/**
		 * 現在閲覧中のページのリンクリストを返します。
		 * @return 現在閲覧中のリンクリストです。
		 * <pre>
		 * Array(
		 * 	Array(URL:String,ページ番号:int),
		 * 	Array(URL:String,ページ番号:int),
		 *  ...
		 * )
		 * </pre>
		 */
		public function getPageLinkList():Array{
//			trace(this.pageLinkListProvider);
			return this.pageLinkListProvider;
		}
		
		/**
		 * 動画に設定されているタグの一覧を返します。
		 * @return 
		 * 
		 */		
		public function getTag():Array{
//			trace(tagArray);
			return tagArray;
		}
		
		public function getOwnerDescription():String{
//			trace(owner_description);
			return owner_description;
		}
		
		public function getStatus():String{
			return videoStatus;
		}
		
		/**
		 * 市場の埋め込みHTMLを返します。
		 * @return 
		 * 
		 */
		public function getIchibaHTML():String{
			return this.ichibaInfo;
		}
		
		public function getPostComment():XML{
			return this.postCommentXML;
		}
		
// 以下内部処理------------------------------------------------------------------//
		
		/**
		 * ログイン処理を行います。<br>
		 * 指定したトップページ下のURLには引数で指定した承認情報付きでリクエストが行われます。
		 * @param topPageUrl トップページのURL。
		 * @param loginUrl ログインページのURL。
		 * @param mailAddress メールアドレス。ログイン名です。
		 * @param password ログインパスワードです。
		 * 
		 */
		private function login(topPageUrl:String, loginUrl:String, mailAddress:String, password:String):void
		{
			trace("function:login");
			//以降のURLRequestが全て認証情報付きで行われるように、デフォルト値としてセット
			URLRequestDefaults.setLoginCredentialsForHost(topPageUrl, mailAddress, password);
			
			//ログインURLにアクセス
			var req:URLRequest = new URLRequest(loginUrl);
			//POSTメソッドです
			req.method = "POST";
			
			//メールアドレスとパスワードをURLエンコードしてリクエストに付加
			var variables : URLVariables = new URLVariables ();
			variables.mail = mailAddress;
			variables.password = password;
			req.data = variables;
			
			//ログイン成功時のリスナーを追加してリクエストを実行
			loginLoader = new URLLoader();
			loginLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, onLoginSuccess);
			loginLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loginLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
		    loginLoader.load(req);
			
			if(downloadProvider !=  null && queueIndex != -1){
				downloadProvider.setItemAt({
					col_videoName:downloadProvider[queueIndex].col_videoName,
					col_videoUrl:downloadProvider[queueIndex].col_videoUrl,
					col_status:"ログイン中",
					col_a2n:downloadProvider[queueIndex].col_a2n
				}, queueIndex);
			}
			
			if(!this.isStreamingPlay){
				if(rankingListProvider != null && rankingIndex != -1 && rankingListProvider.length > rankingIndex){
					if(rankingVideoName != null && rankingVideoName == rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName){
						this.rankingListProvider.setItemAt({
							dataGridColumn_ranking: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_ranking,
							dataGridColumn_preview: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_preview,
							dataGridColumn_videoName: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName,
							dataGridColumn_Info: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_Info,
							dataGridColumn_videoInfo: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoInfo,
							dataGridColumn_condition: "ログイン中\n",
							dataGridColumn_videoPath: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoPath,
							dataGridColumn_date: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_date
						},rankingIndex);
					}
				}
			}
			
			logManager.addLog("ニコニコ動画にログイン");
			if(label_statusInfo != null){
				label_statusInfo.text = "ニコニコ動画にログインしています";
			}
			
		}
		
		/**
		 * ログイン作業が成功した場合に呼ばれるリスナー
		 * @param event
		 * 
		 */
		private function onLoginSuccess(event:HTTPStatusEvent):void 
		{
//			trace("function:onLoginSuccess");
			
			if(isVideoGetting){
				/* 先にコメントを取りにいく。コメントを取り終わったら２週目で動画を取得しにいく。 */
				logManager.addLog("コメントの取得を開始");
				watchLoader = this.watchVideo(this.videoURL, COMMENT_DOWNLOAD);
			}else if(isNicowariGetting){
				/* ニコ割ダウンロードしにいきます */
				logManager.addLog("ニコ割の取得を開始");
				watchLoader = this.watchVideo(this.videoURL, NICOWARI_DOWNLOAD);
			}else if(isRankingListGetting){
				/* ランキングを取りにいく。 */
//				logManager.addLog("ランキングの取得を開始");
//				listLoader = this.watchRanking(this.nicoRankingURL);
			}else if(isSearch){
				/* 検索リストを取りにいく */
				logManager.addLog("検索結果の取得を開始");
				searchLoader = this.watchSearch(this.nicoSearchURL);
			}else if(isMyListGroupRenew){
				/* マイリストの一覧を取りにいく */
				logManager.addLog("マイリスト一覧の取得を開始");
				myListGroupLoader = this.watchMyListGroup(this.myPageUrl);
			}else if(isMyListRenew){
				/* マイリストの項目一覧を取りにいく */
				logManager.addLog("マイリストの取得を開始");
				myListLoader = this.watchMyList(this.myListPageUrl);
			}else if(isGetThumbInfo){
				/* サムネイル情報のみを取りにいく */
				logManager.addLog("サムネイル情報の取得を開始");
				this.getThumbInfo(this.thumbVideoID, -1, false);
			}else if(isGetIchiba){
				/* 市場の情報を取りにいく */
				logManager.addLog("市場情報の取得を開始");
				this.getIchibaInfo(this.videoID, -1, false);
			}
			
		}
		/* マイリストグループ一覧取得ここから --------------------------------------- */
		
		/**
		 * ニコニコ動画のマイページにアクセスし、アクセスしているURLLoaderを返します。
		 * 
		 * @param myPageUrl
		 * @return 
		 * 
		 */
		private function watchMyListGroup(myPageUrl:String):URLLoader{
			
			var request:URLRequest;
			request = new URLRequest(myPageUrl);
			var loader:URLLoader;
			loader = new URLLoader();
			request.method="GET";
			
			loader.addEventListener(Event.COMPLETE, onMyPageWatchSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			loader.load(request);
			
			return loader;
		
		}
		
		/**
		 * ニコニコ動画のマイページへのアクセスに成功した際に呼ばれるイベントリスナです。
		 * @param event
		 * @return 
		 * 
		 */
		private function onMyPageWatchSuccess(event:Event):void{
			/*TODO マイリストグループの一覧解析実装*/
		}
		
		/* マイリストグループ一覧取得ここまで --------------------------------------- */
		
		/* マイリスト一覧取得ここから --------------------------------------------- */
		
		private function watchMyList(myListUrl:String):URLLoader{
			
			var request:URLRequest;
			request = new URLRequest(myListUrl);
			var loader:URLLoader;
			loader = new URLLoader();
			
			request.method="GET";
			
			loader.addEventListener(Event.COMPLETE, onMyListWatchSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			loader.load(request);
			
			return loader;
		
		}
		
		/**
		 * 
		 * @param event
		 * @return 
		 * 
		 */
		private function onMyListWatchSuccess(event:Event):void{
			/*TODO マイリスト解析実装*/
		}
		
		/* マイリスト一覧取得ここまで --------------------------------------------- */
		
		/* ニコチャートのランキング取得処理ここから --------------------------------- */
		
		/**
		 * ニコチャートへのアクセスに成功した際に呼ばれるリスナー
		 * 
		 * @param event
		 * 
		 */		
		private function watchRankingNicoChart(event:Event):void
		{
			rankingListProvider.removeAll();
			
			var max:int = 100;
			
			var pattern:RegExp = new RegExp("<li class=\"thumbnail\"><a href=\"http://www.nicovideo.jp/watch/.*\">","ig");
			
			var myUrlList:Array = oldListLoader.data.match(pattern);
			
			pattern = new RegExp("<a href=\"\.\./watch/.*\">.*</a>","ig");
			
			var myTitleList:Array = oldListLoader.data.match(pattern);
			
			var list:Array = new Array(max);
			
			//trace("List:"+list);
			
			for(var i:int = 0; max>0 && i<myUrlList.length; max--, i++)
			{
				var key:String = myUrlList[i].substring(myUrlList[i].lastIndexOf("href=\"")+6,myUrlList[i].lastIndexOf("\">"));
				var value:String = myTitleList[i].substring(myTitleList[i].indexOf(">")+1,myTitleList[i].indexOf("</a>"));
				//trace(i + " : " + key + " : " + value);
				list[i] = new Array(key, value);
				
				rankingListProvider.addItem({
					dataGridColumn_preview: "-",
					dataGridColumn_ranking: i+1,
					dataGridColumn_videoName: list[i][1]+"\n" + list[i][0]
				}
				);
			}
			
			this.urlList = list;
			
//			statusLabel.text = Message.SUCCESS_NICOCHART_ACCESS;
			logManager.addLog(Message.SUCCESS_NICOCHART_ACCESS);
			
			dispatchEvent(new Event(NICOCHART_RANKING_GET_COMPLETE));
			
		}
		
		/* ニコチャートのランキング取得処理ここまで --------------------------------- */
		
		/* ニコニコ動画の検索一覧を取得-------------------------------------------- */
		/**
		 * 
		 * @param url
		 * @return 
		 * 
		 */
		private function watchSearch(url:String):URLLoader{
		
			var request:URLRequest;
			request = new URLRequest(url);
			var loader:URLLoader;
			loader = new URLLoader();
			
			request.method="GET";
			
			trace(url);
			
			loader.addEventListener(Event.COMPLETE, onSearchSuccess);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			loader.load(request);
			
			if(label_statusInfo != null){
				label_statusInfo.text = "検索結果を待っています";
			}
			
			return loader;
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function onSearchSuccess(event:Event):void
		{
			
			rankingListProvider.removeAll();
			
			if(label_statusInfo != null){
				label_statusInfo.text = "取得した検索結果を解析しています";
			}
			
			this.urlList = this.getSearch(searchLoader);
			
			// 検索ワードが含まれていないときは新着
			if(nicoSearchURL.indexOf("http://www.nicovideo.jp/?") != -1){
				this.categoryList = this.getCategoryList(listLoader);
			}
			
//			logManager.addLog(Message.SUCCESS_SEARTCH);
			
			dispatchEvent(new Event(NICO_SEARCH_COMPLETE));
			
		}
		
		/**
		 * 検索結果を解析、２次配列に格納する。
		 * 
		 * @param loader マイリスト登録ランキングへアクセスしているURLLoader。
		 * @param max 最大読み込み件数。特に指定がない場合は100として扱う。
		 * @return (動画のURL,動画の名前)を格納する２次元配列。
		 * 
		 */
		private function getSearch(loader:URLLoader, max:int=100):Array
		{
			
//			trace(loader.data);
			var pattern1:RegExp = NicoPattern.searchVideoUrlPattern;
			var pattern3:RegExp = NicoPattern.searchPageLinkPattern;
			var pattern4:RegExp = NicoPattern.searchNowPagePattern;
			
			var url_videoIdList:Array = loader.data.match(pattern1);
			
			var tempList:Array = new Array();
			for each(var id:String in url_videoIdList){
				if(tempList.indexOf(id) == -1){
					tempList.push(id);
				}
			}
			url_videoIdList = tempList;
			
			var url_pageLinkList:Array = new Array();
			
			var nowPage:Array = pattern4.exec(loader.data);
			if(nowPage != null){
				var nowPageArray:Array = new Array(nowPage[1], nowPage[1]);
				url_pageLinkList.push(nowPageArray);
			}
			
			var pageLink:Array = pattern3.exec(loader.data);
//			trace("\t"+pageLink);
			while(pageLink != null){
				
				var index:int = String(pageLink[1]).lastIndexOf("?");
				
				if(index != -1){
					
					var url:String = String(pageLink[1]).substring(0, index);
					var suffix:String = String(pageLink[1]).substring(index);
					
					//HTML特殊文字を変換(&amp;→&)
					suffix = HtmlUtil.convertSpecialCharacterNotIncludedString(suffix);
					url = url + suffix;
					
				}else{
					url = pageLink[1];
				}
				
				url_pageLinkList.push(new Array(url ,pageLink[2]));
				pageLink = pattern3.exec(loader.data);
			}
			
			this.pageLinkListProvider = url_pageLinkList;
			
			var urlList:Array = new Array(max);
			
			var changeNicoGUI:Boolean = false;
			
			for(var i:int = 0; max>0 && i<url_videoIdList.length; max--, i++)
			{
				var errorString:String;
				try{
					errorString = "動画URLの解析";
					var url:String = url_videoIdList[i];
					
					var thumbImage:String = PathMaker.getThumbImgUrl(PathMaker.getVideoID(url));
					urlList[i] = new Array("http://www.nicovideo.jp/" + url, thumbImage);
					
					errorString = "登録処理:" + url;
					var index:int = i+1;
					var video:NNDDVideo = (libraryManager.isExist(PathMaker.getVideoID(urlList[i][0])));
					var localURL:String = "";
					var videoCondition:String = "";
					if(video != null){
						localURL = video.getDecodeUrl();
						if(video.isEconomy){
							videoCondition = "動画(低画質)保存済\n右クリックから再生できます。"
						}else{
							videoCondition = "動画保存済\n右クリックから再生できます。";
						}
					}
					
					rankingListProvider.addItem({
						dataGridColumn_ranking: index+((this.pageIndex-1)*url_videoIdList.length),
						dataGridColumn_preview: urlList[i][1],
						dataGridColumn_videoName: urlList[i][0],
						dataGridColumn_videoInfo: "...取得中",
						dataGridColumn_condition: videoCondition,
						dataGridColumn_videoPath: localURL,
						dataGridColumn_nicoVideoUrl: urlList[i][0]
					});
					
					this.getThumbInfo(PathMaker.getVideoID(url), i, false);
					
				}catch(error:Error){
					logManager.addLog("検索結果ページの解析に失敗しました。:" + i + "個目の解析," + errorString + "\n"+error.getStackTrace());
					changeNicoGUI = true;
				}
			}
			
			if(changeNicoGUI){
				logManager.addLog("ニコニコ動画の仕様が変わっている可能性があります。\n検索結果が正しく取得できていない可能性があります。");
				Alert.show("ニコニコ動画の仕様が変わっている可能性があります。\n検索結果が正しく取得できていない可能性があります。", "警告");
			}
			
			return urlList;
		}
		
		/* ニコニコ動画の検索一覧取得ここまで -------------------------------------- */
		
		/* ランキング取得処理ここから -------------------------------------------- */
		
		/**
		 * ランキングのページを参照する
		 * @param url マイリスト登録ランキングのURL
		 * @return マイリスト登録ランキングへのアクセスを保持するURLLoader
		 * 
		 **/
		private function watchRanking(period:int, target:int, category:String, page:int):URLLoader
		{
			
			if(period != 5){
				this.nicoRankingURL = NicoRankingUrl.NICO_RANKING_URLS[period][target] + category;
			}else{
				this.nicoRankingURL = NicoRankingUrl.NICO_RANKING_URLS[period][0];
			}
			var request:URLRequest = new URLRequest(nicoRankingURL);
			var variables:URLVariables = new URLVariables();
			variables.rss = "2.0";
			variables.page = page;
			
			request.data = variables;
			
			trace(request.url);
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, onRankingWatchSuccess);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				
			urlLoader.load(request);
			
			if(label_statusInfo != null){
				label_statusInfo.text = "ニコニコ動画へアクセスしています";
			}
			
			return urlLoader;
			
		}
		
		/**
		 * ランキングのページを取得したときに呼ばれるリスナー
		 * @param evt
		 * 
		 */
		private function onRankingWatchSuccess(evt:Event):void
		{
			
//			statusLabel.text = "ランキングを更新しました";
			trace("ランキングを更新しました"+evt);
			
			if(label_statusInfo != null){
				label_statusInfo.text = "取得したラインキングを解析しています";
			}
			
			rankingListProvider.removeAll();
			
			//ランキングの動画URLと動画名のリストを取得する。
			if(nicoRankingURL.indexOf("ranking") == -1 && nicoRankingURL.indexOf("newarrival") == -1 ){
				this.urlList = this.getSearch(listLoader);
				
				// 検索ワードが含まれていないときは新着
				if(nicoRankingURL.indexOf("http://www.nicovide.jp/?") != -1){
					this.categoryList = this.getCategoryList(listLoader);
				}
				
			}else{
				this.urlList = this.getRanking(listLoader);
				this.categoryList = this.getCategoryList(listLoader);
			}
//			trace(this.urlList);
			
			var df:DateFormatter = new DateFormatter();
			df.formatString = "YYYYMMDDJJNNSS";
			var dateString:String = df.format(new Date());
			
			this.rankingListName = dateString;
			
//			statusLabel.text = "ランキング更新完了";
			
//			logManager.addLog(Message.SUCCESS_RANKING_RENEW);
			
			this.isRankingListGetting = false;
			this.isAccessing = false;
			
			dispatchEvent(new Event(RANKING_GET_COMPLETE));
		}

		/**
		 * ランキング内の動画URLおよびタイトルのリストを取得する。
		 * @param loader マイリスト登録ランキングへアクセスしているURLLoader。
		 * @param max 最大読み込み件数。特に指定がない場合は100として扱う。
		 * @return (動画のURL,動画の名前)を格納する２次元配列。
		 * 
		 */
		private function getRanking(loader:URLLoader, max:int=100):Array
		{
			
			var xml:XML = XML(loader.data);
			var rAnalyzer:RankingAnalyzer = new RankingAnalyzer();
			rAnalyzer.analyze(xml);
			rAnalyzer.rankingItems;
			var changeNicoGUI:Boolean = false;
			var index:int = 1;
			
			for each(var item:RankingItem in rAnalyzer.rankingItems){
				var errorString:String;
				try{

					var videoId:String = PathMaker.getVideoID(item.link);
					var video:NNDDVideo = (libraryManager.isExist(videoId));
					var videoCondition:String = "";
					var localURL:String = "";
					if(video != null){
						localURL = video.getDecodeUrl();
						if(video.isEconomy){
							videoCondition = "動画(低画質)保存済\n右クリックから再生できます。";
						}else{
							videoCondition = "動画保存済\n右クリックから再生できます。";
						}
					}
					
					var rankingStringIndex:int = item.title.indexOf("位：");
					
					var videoTitle:String = item.title;
					if(rankingStringIndex != -1){
						videoTitle = videoTitle.substr(rankingStringIndex + 2);
					}
					
					rankingListProvider.addItem({
						dataGridColumn_ranking: index,
						dataGridColumn_preview: PathMaker.getThumbImgUrl(PathMaker.getVideoID(item.link)),
						dataGridColumn_videoName: videoTitle,
						dataGridColumn_videoInfo: "...取得中",
						dataGridColumn_condition: videoCondition,
						dataGridColumn_videoPath: localURL,
						dataGridColumn_nicoVideoUrl: item.link
					});
					
					this.getThumbInfo(videoId, index-1, false);
					
					index++;
					
				}catch(error:Error){
					logManager.addLog("ランキングページの解析に失敗しました。:" + index + "個目の解析\n"+error.getStackTrace());
					changeNicoGUI = true;
				}
			}
			
			if(changeNicoGUI){
				
				if(loader.data.indexOf("このランキングは準備中です。") != -1){
					logManager.addLog("このランキングは準備中です。(ニコニコ動画より)");
					rankingListProvider.addItem({
						dataGridColumn_ranking: 1,
						dataGridColumn_preview: "",
						dataGridColumn_videoName: "このランキングは準備中です。(ニコニコ動画より)",
						dataGridColumn_videoInfo: "",
						dataGridColumn_condition: "",
						dataGridColumn_videoPath: "",
						dataGridColumn_nicoVideoUrl: ""
					});
				}else{
					logManager.addLog("ニコニコ動画の仕様が変わっている可能性があります。検索結果が正しく取得できていない可能性があります。");
					Alert.show("ニコニコ動画の仕様が変わっている可能性があります。\n検索結果が正しく取得できていない可能性があります。", "警告");
				}
			}
			
			if(index == 1){
				logManager.addLog("１件も取得できませんでした");
				rankingListProvider.addItem({
					dataGridColumn_ranking: 1,
					dataGridColumn_preview: "",
					dataGridColumn_videoName: "１件も取得できませんでした",
					dataGridColumn_videoInfo: "",
					dataGridColumn_condition: "",
					dataGridColumn_videoPath: "",
					dataGridColumn_nicoVideoUrl: ""
				});
			}
			
			return urlList;
		}
		
		/**
		 * カテゴリ一覧を、それに対応するurlの末尾も文字列(all,music,ent など)を含む２次元配列を返します。
		 * 
		 * <pre>
		 * Array(){
		 * 	Array("総合","all");
		 * 	Array("音楽","music");
		 * 	...
		 * }
		 * </pre>
		 * 
		 * @param urlLoader
		 * @return カテゴリと対応するurlの末尾文字列の２次元配列です。
		 * 
		 */
		private function getCategoryList(urlLoader:URLLoader):Array{
			
			var catList:Array = new Array();

			var pattern1:RegExp = NicoPattern.rankingCategoryPattern;
			
//			var category:Array = pattern1.exec(urlLoader.data);
//			while(category != null){
//				catList.push(new Array(category[1], category[2]));
//				category = pattern1.exec(urlLoader.data);
//			}
			catList.push(new Array("カテゴリ合算","all"));
			
			catList.push(new Array("エンタ・音楽・スポ","g_ent"));
			catList.push(new Array("  エンターテイメント","ent"));
			catList.push(new Array("  音楽","music"));
			catList.push(new Array("  スポーツ","sport"));
			
			catList.push(new Array("教養・生活","g_life"));
			catList.push(new Array("  動物","animal"));
//			catList.push(new Array("  ファッション","fashion"));
			catList.push(new Array("  料理","cooking"));
			catList.push(new Array("  日記","diary"));
			catList.push(new Array("  自然","nature"));
			catList.push(new Array("  科学","science"));
			catList.push(new Array("  歴史","history"));
			catList.push(new Array("  ラジオ","radio"));
			catList.push(new Array("  ニコニコ動画講座","lecture"));
			
			catList.push(new Array("政治","g_politics"));
			
			catList.push(new Array("やってみた","g_try"));
			catList.push(new Array("  歌ってみた","sing"));
			catList.push(new Array("  演奏してみた","play"));
			catList.push(new Array("  踊ってみた","dance"));
			catList.push(new Array("  描いてみた","draw"));
			catList.push(new Array("  ニコニコ技術部","tech"));
			
			catList.push(new Array("アニメ・ゲーム","g_culture"));
			catList.push(new Array("  アニメ","anime"));
			catList.push(new Array("  ゲーム","game"));
			
			catList.push(new Array("殿堂入りカテゴリ","g_popular"));
			catList.push(new Array("  アイドルマスター","imas"));
			catList.push(new Array("  東方","toho"));
			catList.push(new Array("  VOCALOID","vocaloid"));
			catList.push(new Array("  例のアレ","are"));
			catList.push(new Array("  その他","other"));
			
			return catList;
		}
		
		/* ランキング取得処理ここまで -------------------------------------------- */
		
		/* 動画取得処理ここから ----------------------------------------------- */	
		
		/**
		 * 見てるフリ処理を実施する。<br>
		 * デフォルトでは動画を取りにいきます。
		 * @param mUrl "見てるフリ"をする対象の動画のURL
		 * @return "見てるフリ"をしているURLLoader。
		 * 
		 */
		private function watchVideo(mUrl:String, type:int = VIDEO_DOWNLOAD):URLLoader
		{
			this.videoID = mUrl.substring(mUrl.lastIndexOf("/")+1);
			
			//trace("videoID:"+this.videoID);
				
			var loader:URLLoader;
			
			//そのページを見ているフリをする為のリクエストを準備する。
			var watchURL:URLRequest = new URLRequest(mUrl);
			watchURL.method = "GET";
			
			loader = new URLLoader();
			if(type == VIDEO_DOWNLOAD){
				loader.addEventListener(Event.COMPLETE, accessWatchSuccessForVideo);
			}else if(type == COMMENT_DOWNLOAD){
				loader.addEventListener(Event.COMPLETE, accessWatchSuccessForComment);
			}else if(type == NICOWARI_DOWNLOAD){
				loader.addEventListener(Event.COMPLETE, accessWatchSuccessForNicowari);
			}
			
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);            
			
			//HTTPリクエストを実行。
			loader.load(watchURL);
			
			if(downloadProvider !=  null && queueIndex != -1){
				downloadProvider.setItemAt({
					col_videoName:downloadProvider[queueIndex].col_videoName,
					col_videoUrl:downloadProvider[queueIndex].col_videoUrl,
					col_status:"動画へアクセス中",
					col_a2n:downloadProvider[queueIndex].col_a2n
				}, queueIndex);
			}
			
			if(!this.isStreamingPlay){
				if(rankingListProvider != null && rankingIndex != -1 && rankingListProvider.length > rankingIndex){
					if(rankingVideoName != null && rankingVideoName == rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName){
						this.rankingListProvider.setItemAt({
							dataGridColumn_ranking: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_ranking,
							dataGridColumn_preview: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_preview,
							dataGridColumn_videoName: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName,
							dataGridColumn_Info: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_Info,
							dataGridColumn_videoInfo: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoInfo,
							dataGridColumn_condition: "動画へアクセス中\n",
							dataGridColumn_videoPath: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoPath,
							dataGridColumn_date: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_date
						},rankingIndex);
					}
				}
			}
			
			return loader;
		
		}
		
		/**
		 * 見ているフリ処理で行っているリクエストが完了したら呼ばれる。 
		 * @param evt
		 * 
		 */
		private function accessWatchSuccessForVideo(evt:Event):void
		{
			try{
				
				trace("アクセス成功" + evt);
				
				logManager.addLog(Message.SUCCESS_ACCESS_TO_NICONICODOUGA);
				
				videoTitle = this.getVideoName(watchLoader, true);
				trace(videoTitle);
				
				//FLVのURLを取得する処理を実行。
				downLoader = this.getAPIResult(videoID, VIDEO_DOWNLOAD);
				
			}catch(error:Error){
				logManager.addLog("ニコニコ動画へのアクセスに失敗:" + error.getStackTrace());
				Alert.show("ニコニコ動画へのアクセスに失敗。\n" + error);
				allClose(true);
			}
		}
		
		
		/**
		 * コメント用
		 * 見てるフリ処理が終わったら呼ばれる。
		 * @param evt
		 * 
		 */
		private function accessWatchSuccessForComment(evt:Event):void
		{
			try{
				trace("アクセス成功" + evt);
				logManager.addLog(Message.SUCCESS_ACCESS_TO_NICONICODOUGA);
				
				videoTitle = this.getVideoName(watchLoader, false);
				trace(videoTitle);
				
				//FLVのURLを取得する処理を実行。
				downLoader = this.getAPIResult(videoID, COMMENT_DOWNLOAD);
			
			}catch(error:Error){
				logManager.addLog("ニコニコ動画へのアクセスに失敗:" + error.getStackTrace());
				Alert.show("ニコニコ動画へのアクセスに失敗。\n" + error);
				allClose(true);
			}
		}
		
		/**
		 * ニコ割用
		 * 見てるフリ処理が終わったら呼ばれる。 
		 * @param evt
		 * 
		 */
		private function accessWatchSuccessForNicowari(evt:Event):void
		{
			try{
				logManager.addLog(Message.SUCCESS_ACCESS_TO_NICONICODOUGA);
				
				videoTitle = this.getVideoName(watchLoader, false);
				videoTitle = videoTitle + "[Nicowari]["+ nicowariID +"]";
				trace(videoTitle);
				
				//指定されたアドレスのニコ割を取得する処理を実行
				downLoader = this.getAPIResult(nicowariID, NICOWARI_DOWNLOAD);
			}catch(error:Error){
				logManager.addLog("ニコニコ動画へのアクセスに失敗:" + error.getStackTrace());
				Alert.show("ニコニコ動画へのアクセスに失敗。\n" + error);
				allClose(true);
			}
		}
		
		/**
		 * 動画のタイトルを取得する。
		 * @param loader "見てるフリ"をしているURLLoader
		 * @param isVideoGet Video本体のダウンロードかどうか
		 * @return 動画のタイトル。
		 * 
		 */
		private function getVideoName(loader:URLLoader, isVideoGet:Boolean):String
		{
			var videoName:String = "";
			
			//trace("loader.data:"+loader.data);
			
			if(isCommentOnly && !isVideoGet || isNicowariGetting && (this.downloadedVideoFileName != null && this.downloadedVideoFileName != "" )){
				videoName = this.downloadedVideoFileName + " - [" + videoID + "]";
			}else{
				//<title>タグからページの名前を取得する。これを使って保存するファイル名を決定する。
				//ココ変えれば良い気がする。でもどうやってHTMLスペシャルキャラクターを変換するんだ？
				var pattern:RegExp = new RegExp("<title>.*</title>","ig"); 
				videoName = loader.data.match(pattern)[0];
				videoName = videoName.substr(7,videoName.length-15);
				
				videoName = videoName + " - [" + videoID + "]";
			}
			return videoName;
		}	
				
		/**
		 * FLVのURLを取得する為のAPIへのアクセスを行う
		 * @param videoID 英数字２文字＋数字 で表される動画のID
		 * @param type ダウンロード対象がVideoか、Commentか。
		 * @return APIへのリクエストを行うURLLoader
		 * 
		 */
		private function getAPIResult(videoID:String, type:int = VIDEO_DOWNLOAD):URLLoader
		{
			var loader:URLLoader;
			loader = new URLLoader();
			
			//FLVのURLを取得する為にニコニコ動画のAPIにアクセスする
			var getAPIResult:URLRequest;
			getAPIResult = new URLRequest("http://www.nicovideo.jp/api/getflv?v=" + videoID);
			getAPIResult.method = "GET";
			
			if(type == VIDEO_DOWNLOAD){
				loader.addEventListener(Event.COMPLETE, accessAPISuccessForVideo);
			}else if(type == COMMENT_DOWNLOAD){
				loader.addEventListener(Event.COMPLETE, accessAPISuccessForComment);
			}else if(type == NICOWARI_DOWNLOAD){
				loader.addEventListener(Event.COMPLETE, accessAPISuccessForNicowari);
			}
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);   
			
			loader.load(getAPIResult);
			
			if(downloadProvider !=  null && queueIndex != -1){
				downloadProvider.setItemAt({
					col_videoName:downloadProvider[queueIndex].col_videoName,
					col_videoUrl:downloadProvider[queueIndex].col_videoUrl,
					col_status:"APIの応答待ち",
					col_a2n:downloadProvider[queueIndex].col_a2n
				}, queueIndex);
			}
			
			if(!this.isStreamingPlay){
				if(rankingListProvider != null && rankingListProvider.length > rankingIndex){
					if(rankingVideoName != null && rankingIndex != -1 && rankingVideoName == rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName){
						this.rankingListProvider.setItemAt({
							dataGridColumn_ranking: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_ranking,
							dataGridColumn_preview: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_preview,
							dataGridColumn_videoName: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName,
							dataGridColumn_Info: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_Info,
							dataGridColumn_videoInfo: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoInfo,
							dataGridColumn_condition: "APIの応答待ち\n",
							dataGridColumn_videoPath: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoPath,
							dataGridColumn_date: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_date
						},rankingIndex);
					}
				}
			}
			
			return loader;
		}
		
		/**
		 * APIからの応答が得られたら呼ばれる
		 * @param evt
		 * 
		 */
		private function accessAPISuccessForVideo(evt:Event):void
		{
			logManager.addLog(Message.SUCCESS_ACCESS_TO_NICOAPI);
			
//			statusLabel.text = "アドレスの取得に成功";
			trace("アドレスの取得に成功" + evt);
			trace(downLoader.data);
			
			//得られた応答を元にvideoを取得
			videoLoader = this.getVideo(downLoader);
			
		}
		
		private function accessAPISuccessForNicowari(evt:Event):void{
			logManager.addLog(Message.SUCCESS_ACCESS_TO_NICOAPI);
			
			trace("アドレスの取得に成功" + evt);
			
			videoLoader = this.getVideo(downLoader);
			
		}
		
		/**
		 * 
		 * @param evt
		 * 
		 */
		private function accessAPISuccessForComment(evt:Event):void
		{
			logManager.addLog(Message.SUCCESS_ACCESS_TO_NICOAPI);

			if(isVideoGetting && !isStreamingPlay && !isOtherVideo){
				/* エコノミーのときのキャンセル判定 */
				if(checkEconomy(downLoader.data) && isContactTheUser){
					Alert.show(Message.M_ECONOMY_MODE_NOW, Message.M_MESSAGE,(Alert.OK | Alert.CANCEL),null,function(event:CloseEvent):void{
						if(event.detail == Alert.CANCEL){
							videoType = "";
							videoDownloadCancel();
						}else if(event.detail == Alert.OK){
							try{
								isEconomy = true;
								commentLoader = getComment(downLoader);
							}catch(error:Error){
								logManager.addLog(Message.ERROR + ":" + error.getStackTrace());
								Alert.show("予期せぬ例外が発生しました。\n" + error, Message.M_ERROR);
								allClose(true);
							}
						}
					}, null, 4);
				}else{
					isEconomy = false;
					commentLoader = getComment(downLoader);
				}
			}else{
				isEconomy = false;
				commentLoader = getComment(downLoader);
			}
		}
		
		/**
		 * APIから得たデータを元に、再生（ダウンロード）予定の動画がエコノミーモードかどうかチェックします。
		 * @param apiResult
		 * @return 
		 * 
		 */
		private function checkEconomy(apiResult:String):Boolean{
			
			var pattern:RegExp = new RegExp("&url=http.*low&link=");
			if(apiResult.search(pattern) != -1){
				return true;
			}
			return false;
		}
		
		/**
		 * APIから得られたデータを元に動画をダウンロードする
		 * @param getApiResultLoader アクセスさせたいURLLoader
		 * @return アクセスさせたURLLoader
		 * 
		 */
		private function getVideo(getApiResultLoader:URLLoader):URLLoader
		{
			var loader:URLLoader;
			loader = new URLLoader();
			//APIから得られたデータの"&url="にあるURLを探す
			var videoURL:String = new String();
			//trace(getApiResultLoader.data);
			videoURL = getApiResultLoader.data.substring(getApiResultLoader.data.indexOf("&url=")+5, getApiResultLoader.data.indexOf("&", getApiResultLoader.data.indexOf("&url")+1));
			videoURL = unescape(videoURL);
			
			trace(unescape(getApiResultLoader.data));
			
			if(videoURL.indexOf("smile?m=")!=-1){
				videoType = ".mp4";
			}else if(videoURL.indexOf("smile?v=")!=-1){
				videoType = ".flv";
			}else if(videoURL.indexOf("smile?s=")!=-1){
				videoType = ".swf";
			}
			
			trace(videoURL);
			
			if(this.isStreamingPlay){
				
				playerController.playMovie(videoURL, null, -1, videoTitle + videoType);
				
			}else{
				//探したURLを使ってFLVのダウンロードを行う。
				var getVideo:URLRequest;
				getVideo = new URLRequest(videoURL);
				loader.dataFormat=URLLoaderDataFormat.BINARY;
				loader.addEventListener(Event.COMPLETE, videoLoadSuccess);
				loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
				loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				loader.load(getVideo);
			}
			
			return loader;
		}
		
		/**
		 * コメントを取得するところ。
		 * @param getApiResultLoader
		 * @return 
		 * 
		 */
		private function getComment(getApiResultLoader:URLLoader):URLLoader
		{
				
			//<thread res_from="-500" version="20061206" thread="スレッドID" />
			
			trace(unescape(getApiResultLoader.data));
			
			//APIから得られたデータの"thread_ID="にあるスレッドIDを探す
			var threadId:String = getApiResultLoader.data.substring(getApiResultLoader.data.indexOf("thread_ID=")+11, getApiResultLoader.data.indexOf("&"));
			var userID:String = getApiResultLoader.data.substring(getApiResultLoader.data.indexOf("user_id=")+8, getApiResultLoader.data.indexOf("&", getApiResultLoader.data.indexOf("user_id=")+9));
			//APIから得られたデータの"&ms="にあるURLを探す
			var commentURL:String = getApiResultLoader.data.substring(getApiResultLoader.data.indexOf("&ms=")+4, getApiResultLoader.data.indexOf("&", getApiResultLoader.data.indexOf("&ms")+1));
			//APIから得られたデータの"&is_premium="にある数字を探す
			var isPremium:String = getApiResultLoader.data.substring(getApiResultLoader.data.indexOf("&is_premium=")+12, getApiResultLoader.data.indexOf("&", getApiResultLoader.data.indexOf("&is_premium=")+1));
			this.messageServerUrl = commentURL;
			this.userID = userID;
			this.isPremium = isPremium;
			
			var getComment:URLRequest = new URLRequest(unescape(commentURL));
			getComment.method = "POST";
			getComment.requestHeaders = new Array(new URLRequestHeader("Content-Type", "text/html"));
			
			videoType = ".xml";
			
			//200810061400
			//var xml:String = "<thread fork=\"1\" user_id=\"" + user_id + "\" res_from=\"1000\" version=\"20061206\" thread=\"" + threadId + "\" />";
			var xml:String = "";
			if(!isCommentPost){
				xml = "<thread res_from=\"-1000\" version=\"20061206\" thread=\"" + threadId + "\" />";
				getComment.data = xml;
			}else{
				xml = "<thread res_from=\"-1\" version=\"20061206\" thread=\"" + threadId + "\" />"; 
				getComment.data = xml;
			}
			
			var loader:URLLoader;
			loader = new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, commentLoadSuccess);
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			loader.load(getComment);
			
			//trace(getComment.url + "," + unescape(new String(getComment.data)));
			
			trace("xml取得開始");
			
			return loader;
			
		}
		
				
		/**
		 * xmlのダウンロードが完了したら呼ばれる
		 * @param evt
		 * 
		 */
		private function commentLoadSuccess(evt:Event):void
		{
			logManager.addLog(Message.SUCCESS_DOWNLOAD_USER_COMMENT);
			if(downloadProvider !=  null && queueIndex != -1){
				downloadProvider.setItemAt({
					col_videoName:downloadProvider[queueIndex].col_videoName,
					col_videoUrl:downloadProvider[queueIndex].col_videoUrl,
					col_status:"コメントXML\nダウンロード成功",
					col_a2n:downloadProvider[queueIndex].col_a2n
				}, queueIndex);
			}
			
			trace("ユーザーコメントXMLダウンロード成功" + evt);
			
			//コメントのPostが目的ならここで終わり
			if(isCommentPost){
				trace(commentLoader.data);
				getPostKey(commentLoader.data);
				return;
				
			//通常のコメント取得なら保存。
			}else if(this.saveComment(commentLoader)){
				logManager.addLog(Message.SUCCESS_SAVE_USER_COMMENT);
			}else{
				logManager.addLog(Message.FAIL_SAVE_USER_COMMENT);
			}
			
			if(!isCancel){
				//投稿者コメントを取りにいく
				commentLoader = this.getOwnerComment(downLoader);
			}
		}


		/**
		 * 投稿者コメントを取得するところ。
		 * @param getApiResultLoader
		 * @return 
		 * 
		 */
		private function getOwnerComment(getApiResultLoader:URLLoader):URLLoader
		{
			//<thread res_from="-500" version="20061206" thread="スレッドID" />
			
			trace(unescape(getApiResultLoader.data));
			
			//APIから得られたデータの"thread_ID="にあるスレッドIDを探す
			var threadId:String = getApiResultLoader.data.substring(getApiResultLoader.data.indexOf("thread_ID=")+11, getApiResultLoader.data.indexOf("&"));
			//APIから得られたデータの"&ms="にあるURLを探す
			var commentURL:String = getApiResultLoader.data.substring(getApiResultLoader.data.indexOf("&ms=")+4, getApiResultLoader.data.indexOf("&", getApiResultLoader.data.indexOf("&ms")+1));
			
			var getComment:URLRequest = new URLRequest(unescape(commentURL));
			getComment.method = "POST";
			getComment.requestHeaders = new Array(new URLRequestHeader("Content-Type", "text/html"));
			
			videoType = ".xml";
			
			//var xml:String = "<thread fork=\"1\" user_id=\"" + user_id + "\" res_from=\"1000\" version=\"20061206\" thread=\"" + threadId + "\" />";
			var xml:String = "<thread res_from=\"-1000\" fork=\"1\" version=\"20061206\" thread=\"" + threadId + "\" />"; 
			getComment.data = xml;
			
			var loader:URLLoader;
			loader = new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, ownerCommentLoadSuccess);
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			loader.load(getComment);
			
			//trace(getComment.url + "," + unescape(new String(getComment.data)));
			
			trace("投稿者xml取得開始");
			
			return loader;
			
		}
		
		
		/**
		 * 投稿者コメントxmlのダウンロードが完了したら呼ばれる
		 * @param evt
		 * 
		 */
		private function ownerCommentLoadSuccess(evt:Event):void
		{
			logManager.addLog(Message.SUCCESS_DOWNLOAD_OWNER_COMMENT);
			if(downloadProvider !=  null && queueIndex != -1){
				downloadProvider.setItemAt({
					col_videoName:downloadProvider[queueIndex].col_videoName,
					col_videoUrl:downloadProvider[queueIndex].col_videoUrl,
					col_status:"投稿者コメントXML\nダウンロード成功",
					col_a2n:downloadProvider[queueIndex].col_a2n
				}, queueIndex);
			}
			trace("投稿者コメントXMLダウンロード成功" + evt);
			
			//オーナーコメント取得完了。
			if(this.saveComment(commentLoader, true)){
				logManager.addLog(Message.SUCCESS_SAVE_OWNER_COMMENT);
				if(downloadProvider !=  null && queueIndex != -1){
					downloadProvider.setItemAt({
						col_videoName:downloadProvider[queueIndex].col_videoName,
						col_videoUrl:downloadProvider[queueIndex].col_videoUrl,
						col_status:"投稿者コメントXML\n保存成功",
						col_a2n:downloadProvider[queueIndex].col_a2n
					}, queueIndex);
				}
			}else{
				logManager.addLog(Message.FAIL_SAVE_OWNER_COMMENT);
				if(downloadProvider !=  null && queueIndex != -1){
					downloadProvider.setItemAt({
						col_videoName:downloadProvider[queueIndex].col_videoName,
						col_videoUrl:downloadProvider[queueIndex].col_videoUrl,
						col_status:"投稿者コメントXML\n保存失敗",
						col_a2n:downloadProvider[queueIndex].col_a2n
					}, queueIndex);
				}
			}
			
			if(!isCommentOnly){
				//サムネイルを取得しにいく
				this.getThumbInfoByNomalDLProcess(videoURL.substring(videoURL.lastIndexOf("/")+1), rankingIndex, !this.isStreamingPlay);
			
			}else{
				
				//コメントのみの取得。
				allClose();
			}
		}
		 
		/**
		 * 通常のDLプロセスの中でサムネイル情報を取得しにいきます。
		 *
		 * @param url
		 * @param rankingIndex
		 * @param isSave
		 * 
		 */
		private function getThumbInfoByNomalDLProcess(url:String, rankingIndex:int, isSave:Boolean):void{
			this.addEventListener(NICO_THUMB_INFO_GET_COMPLETE, function(event:Event):void{
				getIchibaInfoByNomalDLProcess(url, rankingIndex, isSave);

			});
			this.getThumbInfo(url, rankingIndex, isSave);
		}
		
		/**
		 * 通常のDLプロセスの中で市場情報を取得しにいきます。
		 * 
		 * @param url
		 * @param rankingIndex
		 * @param isSave
		 * 
		 */
		private function getIchibaInfoByNomalDLProcess(url:String, rankingIndex:int, isSave:Boolean):void{
			this.addEventListener(NICO_ICHIBA_INFO_GET_COMPLETE, function(event:Event):void{
				nicowariOrVideoStart();
			});
			this.getIchibaInfo(url, rankingIndex, isSave);
		}
		
		/**
		 * コメントローダーの結果からニコ割の有無をチェックし、ニコ割があればニコ割をダウンロードします。
		 * 無ければ、動画のダウンロードを始めます。
		 * 
		 */
		private function nicowariOrVideoStart():void{
			
			if(this.commentLoader != null && this.commentLoader.data != null ){
				var xml:XML = new XML(this.commentLoader.data);
				var xmlList:XMLList = xml.chat;
				
				var command:Command = new Command();
				for each(var com:String in xmlList){
					var nicowariID:String = command.getNicowariVideoID(com)[0];
					if( nicowariID != null && nicowariID != ""){
						this.myNicowariVideoIDs.push(nicowariID);
					}
				}
			}
			//ニコ割が一つ以上あれば先にニコ割を取得。
			if(myNicowariVideoIDs != null && myNicowariVideoIDs.length >= 1){
				getNicowari(myNicowariVideoIDs);
			}else{
				if(!isOtherVideo){
					watchLoader = watchVideo(videoURL, VIDEO_DOWNLOAD);
				}else{
					allClose();
				}
			}
		}
		
		/**
		 * ニコ割を取得します。その後の流れで、終了と動画取得に処理が分かれます。
		 * 
		 * @param nicowariID
		 * 
		 */
		private function getNicowari(nicowariIDs:Array):void{
			var myNicowariVideoID:String = nicowariIDs.shift();
			if(myNicowariVideoID != null && myNicowariVideoID != ""){
				trace("ユーザーニコ割をダウンロード:" + myNicowariVideoID);
				var a2n:Access2Nico = new Access2Nico(downloadProvider, null, null, logManager, null);
				a2n.addEventListener(Access2Nico.NICOWARI_DOWNLOAD_COMPLETE, function(event:Event):void{
					
					trace("ニコ割のDL完了");
					if(nicowariIDs.length < 1){
						if(!isCommentOnly){
							watchLoader = watchVideo(videoURL, VIDEO_DOWNLOAD);
						}else{
							allClose();
						}
					}else if(nicowariIDs.length >= 1){
						getNicowari(nicowariIDs);
					}
					
				});
				a2n.request_downLoad_Nicowari(Access2Nico.TOP_PAGE_URL, Access2Nico.LOGIN_URL, videoURL, mailAddress, password, this.path, myNicowariVideoID, this.downloadedVideoFileName, queueIndex);
			}
		}
		
		/**
		 * 動画のダウンロードが完了したら呼ばれる
		 * @param evt
		 * 
		 */
		private function videoLoadSuccess(evt:Event):void
		{
			if(rankingListProvider != null){
				if(rankingVideoName != null && rankingIndex != -1 && rankingVideoName == rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName){
					this.rankingListProvider.setItemAt({
						dataGridColumn_ranking: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_ranking,
						dataGridColumn_preview: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_preview,
						dataGridColumn_videoName: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName,
						dataGridColumn_Info: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_Info,
						dataGridColumn_videoInfo: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoInfo,
						dataGridColumn_condition: "DL済\n100%",
						dataGridColumn_videoPath: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoPath,
						dataGridColumn_date: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_date
					},rankingIndex);
				}
			}
			
			if(!isNicowariGetting){
				logManager.addLog(Message.SUCCESS_DOWNLOAD_VIDEO + ":" + videoTitle + videoType);
			}else{
				logManager.addLog(Message.SUCCESS_DOWNLOAD_NICOWARI + ":" + videoTitle + videoType);
			}
			
			//ダウンロードしたFLVを保存する。
			if(this.saveVideo(videoLoader) && !isNicowariGetting ){
				
				if(rankingListProvider != null){
					if(rankingVideoName != null && rankingIndex != -1 && rankingVideoName == rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName){
						this.rankingListProvider.setItemAt({
							dataGridColumn_ranking: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_ranking,
							dataGridColumn_preview: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_preview,
							dataGridColumn_videoName: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName,
							dataGridColumn_Info: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_Info,
							dataGridColumn_videoInfo: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoInfo,
							dataGridColumn_condition: "動画保存済\n右クリックから再生できます。",
							dataGridColumn_downloadedItemUrl: path + FileIO.getSafeFileName(videoTitle) + videoType,
							dataGridColumn_videoPath: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoPath,
							dataGridColumn_date: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_date
						},rankingIndex);
					}
				}
				
				if(downloadProvider != null){
					if(downloadProvider.length > queueIndex && downloadProvider[queueIndex] != null){
						downloadProvider.setItemAt({
							col_videoName: videoTitle,
							col_videoUrl: downloadProvider[queueIndex].col_videoUrl,
							col_status: "動画保存済\n右クリックから再生できます。",
							col_a2n: downloadProvider[queueIndex].col_a2n,
							col_downloadedPath: path + FileIO.getSafeFileName(videoTitle) + videoType
						}, queueIndex);
					}
				}
				
				logManager.addLog(Message.SUCCESS_SAVE_VIDEO + ":" + videoTitle + videoType);
			}else if( !isNicowariGetting ){
				if(rankingListProvider != null){
					if(rankingVideoName != null && rankingIndex != -1 && rankingVideoName == rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName){
						this.rankingListProvider.setItemAt({
							dataGridColumn_ranking: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_ranking,
							dataGridColumn_preview: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_preview,
							dataGridColumn_videoName: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName,
							dataGridColumn_Info: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_Info,
							dataGridColumn_videoInfo: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoInfo,
							dataGridColumn_condition: "動画保存失敗",
							dataGridColumn_videoPath: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoPath,
							dataGridColumn_date: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_date
						},rankingIndex);
					}
				}
				
				if(downloadProvider != null){
					if(rankingVideoName != null && rankingIndex != -1 && rankingVideoName == downloadProvider[queueIndex].col_videoName){
						downloadProvider.setItemAt({
							col_videoName: downloadProvider[queueIndex].col_videoName,
							col_videoUrl: downloadProvider[queueIndex].col_videoUrl,
							col_status: "動画保存失敗",
							col_a2n: downloadProvider[queueIndex].col_a2n,
							col_downloadedPath: ""
						}, queueIndex);
					}
				}
				
				logManager.addLog(Message.FAIL_SAVE_VIDEO + ":" + videoTitle + videoType);
			}
			
			this.allClose();
		}
		
		/**
		 * 
		 * @param videoLoader
		 * 
		 */
		private function saveVideo(videoLoader:URLLoader):Boolean
		{
			var fileIO:FileIO = null;
			if(videoLoader.dataFormat != URLLoaderDataFormat.BINARY){
				
				trace(videoLoader.dataFormat);
				logManager.addLog("動画が正常にダウンロードできていませんでした。ダウンロードしたデータがバイナリではありません。（フォーマット:" + videoLoader.dataFormat + ",ファイル名:" + this.videoTitle + this.videoType + "）");
				
				return false;
			}
			
			try{
				fileIO = new FileIO(logManager);
				
				//HTML特殊文字を元に戻す
				this.videoTitle = getSpecialCharacterNotIncludedVideoName(this.videoTitle);
				
				if(!isNicowariGetting){
					//ライブラリに同じ物があれば削除
					var videoId:String = PathMaker.getVideoID(this.videoTitle);
					if(videoId != null){
						var oldVideo:NNDDVideo = libraryManager.remove(videoId, false);
						if(oldVideo != null){
							try{
								//既にDL済のファイルが存在するが、エコノミーモードだった等の理由でファイル名（拡張子）が違う。ファイルが２個できるのを防ぐため、古い方を削除。
								var oldFile:File = new File(oldVideo.uri);
								if(oldFile.exists){
									oldFile.deleteFile();
								}
							}catch(error:Error){
								logManager.addLog("ダウンロード済みの古いファイルを削除しようとしましたが、失敗しました。:" + oldVideo.getDecodeUrl() + "\nError:" + error.getStackTrace());
							}
						}
					}
				}
					
				//ファイルの保存
				var file:File = fileIO.saveVideoByURLLoader(videoLoader, this.videoTitle + this.videoType, this.path);
				
				fileIO.closeFileStream();
				logManager.addLog("[" + this.videoTitle + this.videoType + "]のダウンロードが完了しました。\nファイル:" + file.nativePath );
				
				if(!isNicowariGetting){
					
					//タグ情報を読み込んでライブラリに反映
					var video:NNDDVideo = new LocalVideoInfoLoader().loadInfo(decodeURIComponent(file.url));
					video.isEconomy = isEconomy;
					var localThumbImgPath:String = PathMaker.createThumbImgFilePath(decodeURIComponent(file.url));
					if((new File(localThumbImgPath)).exists){
						video.thumbUrl = localThumbImgPath;
					}
					
					libraryManager.add(video, true, true);
					downLoadedListManager.refresh();
				}
			}catch(e:Error){
				trace(e);
				logManager.addLog("[" + videoTitle + videoType + "]の保存中に予期せぬエラーが発生しました。\nError:" + e.getStackTrace());
				try{
					fileIO.closeFileStream();
				}catch(error:Error){
					/*nothing*/
				}
				return false;
			}
			return true;
		}
		
		/**
		 * HTML特殊文字を使用していない動画のタイトルを返します。
		 * @param videoName
		 * @return 
		 * 
		 */
		public function getSpecialCharacterNotIncludedVideoName(videoName:String):String{
			var tempName:String = videoName;
			
			while(true){
				videoName = XML(videoName);
				if(videoName == tempName){
					break;
				}
				tempName = videoName;
			}
			
			return tempName;
		}
		
		/**
		 * 
		 * @param commentLoader
		 * @param isOwner
		 * 
		 */
		private function saveComment(commentLoader:URLLoader, isOwner:Boolean = false):Boolean
		{
			
			//HTML特殊文字を元に戻す
			this.videoTitle = getSpecialCharacterNotIncludedVideoName(videoTitle);
			
			var filePath:String = this.path;
			var fileName:String = this.videoTitle;
			
//			trace("保存処理を実装していません！:Access2Nico.saveComment()");
			try{
				var fileIO:FileIO = new FileIO(logManager);
//				trace(path + videoTitle + videoType);
				
				if(isStreamingPlay == true){
					filePath = filePath + "temp/"
					fileName = "nndd";
				}
				trace(filePath + fileName + videoType);
				
				if(!isOwner){
					
					fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
						fileIO.closeFileStream();
						ioErrorHandler(event);
					});
					fileIO.addFileStreamEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void{
						fileIO.closeFileStream();
						securityErrorHandler(event);
					});
					fileIO.saveComment(commentLoader.data, fileName + videoType, filePath, false, Application.application.getSaveCommentMaxCount());
					fileIO.closeFileStream();
					lastSaveComment = fileName + videoType;
					logManager.addLog("[" + fileName + videoType + "]のダウンロードが完了しました。\nファイル:" + filePath + fileName + videoType);
					
				}else{
					fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
						fileIO.closeFileStream();
						ioErrorHandler(event);
					});
					fileIO.addFileStreamEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void{
						fileIO.closeFileStream();
						securityErrorHandler(event);
					});
					
					fileName = fileName + "[Owner]";
					
					fileIO.saveComment(commentLoader.data, fileName + videoType, filePath, false, Application.application.getSaveCommentMaxCount());
					
					fileIO.closeFileStream();
					logManager.addLog("[" + fileName + videoType + "]のダウンロードが完了しました。\nファイル:" + filePath + fileName + videoType);
					lastSaveOwnerComment = fileName + videoType;
					
				}
			}catch(e:Error){
				trace("コメントのダウンロードに失敗：" + e);
				trace("\t" + filePath + fileName + videoType);
				logManager.addLog("[" + fileName + videoType + "]の保存中に予期せぬエラーが発生しました。\nError:" + e.getStackTrace());
				return false;
			}
			return true;
		}
		
		/* 動画取得処理ここまで ----------------------------------------------- */
		
		/* コメントポストここから ----------------------------------------------- */
		/**
		 * 
		 * @param res
		 * 
		 */
		private function getPostKey(res:String):void{
			//<?xml version="1.0" encoding="UTF-8"?><packet><thread click_revision="925" last_res="84981" resultcode="0" revision="1" server_time="1232873115" thread="1214840698" ticket="0x1a274db8"/><view_counter id="sm3821007" mylist="17558" video="768016"/><chat date="1232870058" no="84981" thread="1214840698" user_id="2729410" vpos="16492">０</chat><num_click count="30" no="81372" thread="1214840698"/></packet>
			//http://www.nicovideo.jp/api/getpostkey?thread=id&block_no=xxx
			
			var xml:XML = new XML(res);
			var xmlList:XMLList = xml.thread;
			var ticket:String = xmlList[0].@ticket;
			var threadID:String = xmlList[0].@thread;
			var commentCount:int = xmlList[0].@last_res;
			var block_no:int = (commentCount)/100;
			
			var loader:URLLoader;
			loader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			loader.addEventListener(Event.COMPLETE, function(event:Event):void{
				trace(event.target.data);
				var postKey:String = (event.target.data as String).substring(event.target.data.indexOf("=")+1);
				postComment(postKey, userID, ticket, mail, String(vpos), threadID, isPremium);
			});
			var url:String = "http://www.nicovideo.jp/api/getpostkey/?block_no=" + block_no + "&thread=" + threadID + "&yugi=";
			trace(url);
			loader.load(new URLRequest(url));
			
			
		}
		
		/**
		 * 
		 * @param postKey
		 * @param user_id
		 * @param ticket
		 * @param mail
		 * @param vpos
		 * @param thread
		 * @param isPremium
		 * 
		 */
		private function postComment(postKey:String, user_id:String, ticket:String, mail:String, vpos:String, thread:String, isPremium:String):void{
			
			trace(postKey + ", " + user_id + ", " + ticket + ", " + mail + ", " + vpos + ", " + thread);
			
			trace(unescape(messageServerUrl));
				
			var getComment:URLRequest = new URLRequest(unescape(messageServerUrl));
			getComment.method = "POST";
			getComment.requestHeaders = new Array(new URLRequestHeader("Content-Type", "text/html"));
			
			//<chat premium="" postkey="" user_id="" ticket="" mail="" vpos="" thread="" >コメント</chat>
			//var xml:String = "<chat premium=\"0\" postkey=\"" + postKey + "\" user_id=\""+ user_id +"\" ticket=\"" + ticket + "\" mail=\"184 "+ mail +"\" vpos=\""+ vpos +"\" thread=\""+ thread +"\" >"+comment+"</chat>"; 
			//1175847782
			//<chat thread="1175847782" vpos="1990" mail="184 " ticket="0x16ac3880" user_id="573999" postkey="FPqn4X-8ewB13EmciwUVNaWZmM0" premium="1">test</chat>
			var chat:XML = <chat />;
			chat.@thread = thread;
			chat.@vpos = vpos;
			chat.@mail = "184 " + mail;
			chat.@ticket = ticket;
			chat.@user_id = user_id;
			chat.@postkey = postKey;
			chat.@premium = isPremium;
			chat.appendChild(comment);
			
			getComment.data = chat;
			
			var loader:URLLoader;
			loader = new URLLoader();
			loader.dataFormat=URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function():void{
				
				var resXml:XML = new XML(loader.data);
				
				try{
					
					if(String(resXml.chat_result.@status) == "0"){
						logManager.addLog("コメントを投稿:" + videoURL);
						postCommentXML = chat;
					}else{
						logManager.addLog("コメントの投稿に失敗:" + videoURL + ":status=[" + String(resXml.chat_result.@status) + "]");
						Alert.show("コメントの投稿に失敗\nstatus=[" + String(resXml.chat_result.@status) + "]", Message.M_ERROR);
					}
					trace("コメントを投稿:" + videoURL + ":" + chat.toXMLString() + ":" + loader.data);
				
				}catch(error:Error){
					trace(error.getStackTrace());
					logManager.addLog("コメントの投稿に失敗:" + error + ":" + error.getStackTrace());
					Alert.show("コメントの投稿に失敗\n" + error, Message.M_ERROR);
				}
				
				allClose();
				
			});
			loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			loader.load(getComment);
			
		}
		
		/* コメントポストここまで ----------------------------------------------- */
		
		/* 市場情報取得ここから ------------------------------------------------ */
		
		private function getIchibaInfo(videoID:String, index:int, isSave:Boolean, videoName:String = null):void{
			//http://ichiba5.nicovideo.jp/embed/?action=showMain&v=sm280671&country=jp&rev=20090119
			var loader:URLLoader;
			loader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void{
				if(videoName == null){
					logManager.addLog("エラー:市場情報の取得に失敗。\n対象のWebサービスが現在利用可能かどうか確認してください。");
					tagArray.push("市場情報の取得に失敗。");
					dispatchEvent(new Event(Access2Nico.NICO_ICHIBA_INFO_GET_COMPLETE));
				}
				if(index != -1){
					if(videoName != null && videoName == rankingListProvider.getItemAt(index).dataGridColumn_videoName){
						rankingListProvider.setItemAt({
							dataGridColumn_ranking: rankingListProvider.getItemAt(index).dataGridColumn_ranking,
							dataGridColumn_preview: rankingListProvider.getItemAt(index).dataGridColumn_preview,
							dataGridColumn_videoName: rankingListProvider.getItemAt(index).dataGridColumn_videoName,
							dataGridColumn_Info: rankingListProvider.getItemAt(index).dataGridColumn_Info,
							dataGridColumn_videoInfo: "市場情報の取得に失敗。",
							dataGridColumn_condition: rankingListProvider.getItemAt(index).dataGridColumn_condition,
							dataGridColumn_downloadedItemUrl: rankingListProvider.getItemAt(index).dataGridColumn_downloadedItemUrl
						}, index);
					}
					dispatchEvent(new Event(Access2Nico.NICO_ICHIBA_INFO_GET_COMPLETE));
				}
				loader.close();
				loader = null;
			});
			loader.addEventListener(Event.COMPLETE, function(event:Event):void{
				
				try{
					loader.close();
					
					if(isSave){
						var fileIO:FileIO = new FileIO(logManager);
						var filePath:String = path;
						var fileName:String = videoTitle;
						
						fileIO.saveComment(loader.data, fileName + "[IchibaInfo].html", filePath, false, Application.application.getSaveCommentMaxCount());
						fileIO.closeFileStream();
						logManager.addLog("[" + fileName + "[IchibaInfo].html" + "]のダウンロードが完了しました。\nファイル:" + path + fileName + "[IchibaInfo].html");
					}
					loader = null;
					ichibaInfo = (event.target as URLLoader).data;
					
					dispatchEvent(new Event(Access2Nico.NICO_ICHIBA_INFO_GET_COMPLETE));
				}catch(error:Error){
					logManager.addLog(Message.ERROR + ":" + error.getStackTrace());
					Alert.show("予期せぬ例外が発生しました。\n" + error, Message.M_ERROR);
					allClose(true);
				}
			});
			var balance:int = (Math.random()*100)%5;
			if(balance == 0){
				balance++;
			}
			var url:String = "http://ichiba" +balance+ ".nicovideo.jp/embed/?action=showMain&v="+ videoID +"&rev=20090122";
			trace(url);
			loader.load(new URLRequest(url));
			
		}
		
		/* 市場情報取得ここまで ------------------------------------------------ */
		
		/* サムネイル情報取得ここから -------------------------------------------- */
		
		/**
		 * サムネイル情報取得用APIにアクセスし、結果を取得します。<br>
		 * @param videoID
		 * @param index 単体取得か、ランキング取得か。ランキング取得の場合はランキングのインデックスを入れる。
		 * @param isSave 取得したXMLを保存するかどうか
		 * 
		 */
		private function getThumbInfo(videoID:String, index:int, isSave:Boolean):void{
			//http://www.nicovideo.jp/api/getthumbinfo/動画ID
			var loader:URLLoader;
			loader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void{
				if(index != -1){
					if(videoID != null && videoID == PathMaker.getVideoID(rankingListProvider.getItemAt(index).dataGridColumn_nicoVideoUrl)){
						rankingListProvider.setItemAt({
							dataGridColumn_ranking: rankingListProvider.getItemAt(index).dataGridColumn_ranking,
							dataGridColumn_preview: rankingListProvider.getItemAt(index).dataGridColumn_preview,
							dataGridColumn_videoName: rankingListProvider.getItemAt(index).dataGridColumn_videoName  + "\n    サムネイル情報の取得に失敗",
							dataGridColumn_Info: rankingListProvider.getItemAt(index).dataGridColumn_Info,
							dataGridColumn_videoInfo: "サムネイル情報の取得に失敗",
							dataGridColumn_condition: rankingListProvider.getItemAt(index).dataGridColumn_condition,
							dataGridColumn_videoPath: rankingListProvider.getItemAt(index).dataGridColumn_videoPath,
							dataGridColumn_nicoVideoUrl: rankingListProvider.getItemAt(index).dataGridColumn_nicoVideoUrl
						}, index);
					}
					dispatchEvent(new Event(Access2Nico.NICO_THUMB_INFO_GET_COMPLETE));
					
				}
				loader.close();
				loader = null;
			});
			loader.addEventListener(Event.COMPLETE, function(event:Event):void{
				var thumbInfoXML:XML = new XML(event.currentTarget.data);
//				trace(thumbInfoXML);
				var status:String = Message.L_VIDEO_DELETED;
				if(rankingListProvider.length <= index){
					return;
				}
				var videoName:String = rankingListProvider.getItemAt(index).dataGridColumn_videoName;
				var videoNameFooter:String = "";
				
				analyzer = new ThumbInfoAnalyzer(thumbInfoXML);
				var dateFormatter:DateFormatter = new DateFormatter();
				dateFormatter.formatString = "YYYY/MM/DD JJ:NN:SS";
				
				if(analyzer.status == "ok"){
					status = "再生:" + analyzer.viewCounter +
						" コメント:" + analyzer.commentNum +
						"\nマイリスト:" + analyzer.myListNum +
						"\n" + analyzer.lastResBody;
					videoNameFooter = "\n    再生時間 " + analyzer.length + 
						"\n    投稿日時 " + dateFormatter.format(analyzer.getDateByFirst_retrieve());
					
					videoStatus =  "再生:" + analyzer.viewCounter +
							" コメント:" + analyzer.commentNum +
							" マイリスト:" + analyzer.myListNum;
					
					owner_description = analyzer.description;
					
					videoName = HtmlUtil.convertSpecialCharacterNotIncludedString(analyzer.title);
					
				}else if(analyzer.status == "fail"){
					
					if(analyzer.errorCode == "COMMUNITY"){
						
						owner_description = "公式動画(COMMUNITY)には非対応";
						status = "公式動画(COMMUNITY)には非対応";
						videoStatus = "公式動画(COMMUNITY)には非対応";
						
					}else{
						
						//status!="ok"。削除されている。
						owner_description = Message.L_VIDEO_DELETED;
						status = Message.L_VIDEO_DELETED;
						videoStatus = Message.L_VIDEO_DELETED;
						
					}
				
				}
				
				if(tagArray != null){
					for each(var tag:String in analyzer.tagArray){
						tagArray.push(HtmlUtil.convertSpecialCharacterNotIncludedString(tag));
					}
				}
				
				if(index != -1){
					if(videoID != null && rankingListProvider.length > index && videoID == PathMaker.getVideoID(rankingListProvider.getItemAt(index).dataGridColumn_nicoVideoUrl)){
						rankingListProvider.setItemAt({
							dataGridColumn_ranking: rankingListProvider.getItemAt(index).dataGridColumn_ranking,
							dataGridColumn_preview: rankingListProvider.getItemAt(index).dataGridColumn_preview,
							dataGridColumn_videoName: videoName + videoNameFooter,
							dataGridColumn_Info: rankingListProvider.getItemAt(index).dataGridColumn_Info,
							dataGridColumn_videoInfo: status,
							dataGridColumn_condition: rankingListProvider.getItemAt(index).dataGridColumn_condition,
							dataGridColumn_videoPath: rankingListProvider.getItemAt(index).dataGridColumn_videoPath,
							dataGridColumn_nicoVideoUrl: rankingListProvider.getItemAt(index).dataGridColumn_nicoVideoUrl
						}, index);
					}
				}
				loader.close();
				
				if(isSave){
					var fileIO:FileIO = new FileIO(logManager);
					var filePath:String = path;
					var fileName:String = videoTitle;
					
					try{
					
						//ThumbInfo.xmlを保存
						fileIO.saveComment(loader.data, fileName + "[ThumbInfo].xml", filePath, false, Application.application.getSaveCommentMaxCount());
						fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
							logManager.addLog("サムネイル情報の保存に失敗しました。:" + event.target + ":" +event + "\n" + path + fileName + "[ThumbInfo]" + videoType);
							Alert.show("サムネイル情報の保存に失敗しました。\n" + event);
						});
						fileIO.closeFileStream();
						logManager.addLog("[" + fileName + "[ThumbInfo].xml" + "]のダウンロードが完了しました。\nファイル:" + path + fileName + "[ThumbInfo]" + videoType);
						
						//thumbImgを保存。
						var thumbImgUrl:String = "";
						if(thumbInfoXML.thumb.thumbnail_url != null && thumbInfoXML.thumb.thumbnail_url != ""){
							thumbImgUrl = thumbInfoXML.thumb.thumbnail_url;
							
							getThumbImg(thumbImgUrl, videoID, videoTitle + "[ThumbImg].jpeg", filePath);
							
						}
						
					}catch(error:Error){
						logManager.addLog("サムネイル情報の保存に失敗しました。:" + error.getStackTrace());
						Alert.show("サムネイル情報の保存に失敗しました。\n" + error);
						allClose(true);
					}
					
				}else{
					dispatchEvent(new Event(Access2Nico.NICO_SINGLE_THUMB_INFO_GET_COMPLETE));
//					allClose();
				}
				loader = null;
				
			});
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
			
			loader.load(new URLRequest("http://ext.nicovideo.jp/api/getthumbinfo/" + videoID));
		}
		
		/* サムネイル情報取得ここまで -------------------------------------------- */
		/* サムネイル画像保存処理ココから */
		
		/**
		 * サムネイル画像をダウンロードして、指定されたファイルに出力します。
		 * 
		 * @param thumbImgUrl
		 * @param videoID
		 * @param fileName
		 * @param path
		 * 
		 */
		private function getThumbImg(thumbImgUrl:String, videoID:String, fileName:String, path:String):void{
			
			isThumbImgGetting = true;
			
			var imgLoader:URLLoader = new URLLoader();
			imgLoader.dataFormat = URLLoaderDataFormat.BINARY;
			imgLoader.addEventListener(Event.COMPLETE, function(event:Event):void{
				try{
					
					/* サムネイル画像保存処理 */
					var fileIO:FileIO = new FileIO(logManager);
					var file:File = new File(path+fileName);
					if(file.exists){
						file.deleteFile();
					}
					fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
						logManager.addLog("サムネイル画像の保存に失敗しました。:" + event.target + ":" +event + "\n" + decodeURIComponent(file.url));
						Alert.show("サムネイル画像の保存に失敗しました。\n" + event);
					});
					fileIO.saveByteArray(fileName, path, imgLoader.data);
					
					/* すでに保存済の動画ならライブラリのNNDDVideoにthumbImgのURLを追加 */
					var video:NNDDVideo = libraryManager.isExist(videoID);
					if(video != null){
						video.thumbUrl = file.url;
						libraryManager.update(video, true);
						downLoadedListManager.refresh();
					}
					
//					allClose(false, false);
					if(isCommentOnly){
						dispatchEvent(new Event(Access2Nico.NICO_SINGLE_THUMB_INFO_GET_COMPLETE));
					}else{
						dispatchEvent(new Event(Access2Nico.NICO_THUMB_INFO_GET_COMPLETE));
					}
				}catch(error:Error){
					logManager.addLog("サムネイル画像の保存に失敗しました。:" + error.getStackTrace());
					Alert.show("サムネイル画像の保存に失敗しました。\n" + error);
					allClose(false, true);
				}
				
			});
			imgLoader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			
			imgLoader.load(new URLRequest(thumbImgUrl));
			
		}
		
		/* サムネイル画像保存処理ココまで */
		
		/**
		 * 進捗状況を表示するハンドラ
		 * @param evt
		 * 
		 */
		private function progressHandler(evt:ProgressEvent):void
		{
			
			var loadedValue:Number = new Number(evt.bytesLoaded/1000000);
			var totalValue:Number = new Number(evt.bytesTotal/1000000);
			var formatter:NumberFormatter = new NumberFormatter();
			formatter.precision = 1;
			
			if(!this.isStreamingPlay){
				if(rankingListProvider != null  && rankingIndex != -1 && rankingListProvider.length > rankingIndex){
					if(rankingVideoName != null && rankingVideoName.indexOf(rankingListProvider[rankingIndex].dataGridColumn_videoName) != -1){
						if(evt.currentTarget == this.commentLoader){
							this.rankingListProvider.setItemAt({
								dataGridColumn_ranking: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_ranking,
								dataGridColumn_preview: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_preview,
								dataGridColumn_videoName: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName,
								dataGridColumn_Info: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_Info,
								dataGridColumn_videoInfo: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoInfo,
								dataGridColumn_condition: "コメントをDL中\n" + new int((evt.bytesLoaded/evt.bytesTotal)*100) + "%\n" + 
										formatter.format(loadedValue)+"MB/"+formatter.format(totalValue)+"MB",
								dataGridColumn_videoPath: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoPath,
								dataGridColumn_date: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_date
							},rankingIndex);
						}else{
							this.rankingListProvider.setItemAt({
								dataGridColumn_ranking: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_ranking,
								dataGridColumn_preview: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_preview,
								dataGridColumn_videoName: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName,
								dataGridColumn_Info: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_Info,
								dataGridColumn_videoInfo: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoInfo,
								dataGridColumn_condition: "動画をDL中\n" + new int((evt.bytesLoaded/evt.bytesTotal)*100) + "%\n" + 
										formatter.format(loadedValue)+"MB/"+formatter.format(totalValue)+"MB",
								dataGridColumn_videoPath: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoPath,
								dataGridColumn_date: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_date
							},rankingIndex);
						}
					}
				}
			}
			
			if(!this.isStreamingPlay){
				if(downloadProvider !=  null && downloadProvider.length > queueIndex && queueIndex >= 0){
					if(evt.currentTarget == this.commentLoader){
						downloadProvider.setItemAt({
							col_videoName:downloadProvider[queueIndex].col_videoName,
							col_videoUrl:downloadProvider[queueIndex].col_videoUrl,
							col_status:"コメントをDL中\n" + new int((evt.bytesLoaded/evt.bytesTotal)*100) + "%\n" + 
									formatter.format(loadedValue)+"MB/"+formatter.format(totalValue)+"MB",
							col_a2n:downloadProvider[queueIndex].col_a2n
						}, queueIndex);
					}else{
						downloadProvider.setItemAt({
							col_videoName:downloadProvider[queueIndex].col_videoName,
							col_videoUrl:downloadProvider[queueIndex].col_videoUrl,
							col_status:"動画をDL中\n" + new int((evt.bytesLoaded/evt.bytesTotal)*100) + "%\n" + 
									formatter.format(loadedValue)+"MB/"+formatter.format(totalValue)+"MB",
							col_a2n:downloadProvider[queueIndex].col_a2n
						}, queueIndex);
					}
				}
			}
			
		}
		
		/**
		 * セキュリティエラーが発生したときに呼ばれるハンドラ。
		 * @param evt
		 * 
		 */
		private function securityErrorHandler(evt:SecurityErrorEvent):void{
			Alert.show(evt.text, "SecurityError");
			
			logManager.addLog(Message.ERROR + ":" + evt.text);
			this.allClose();
		}
		
		/**
		 * IOエラーが発生したときのハンドラ。
		 * @param evt
		 * 
		 */
		private function ioErrorHandler(evt:IOErrorEvent):void{
			//Alert.show(evt.text, "IOError");
			
			trace(evt);
			
			if(this.isVideoGetting){
				this.logManager.addLog("次のファイルがダウンロードできませんでした。\n対象のWebサービスが現在利用可能かどうか確認してください。\n" + this.videoTitle + this.videoType + "\nErrorCode:" + decodeURIComponent(evt.text));
			}else if(this.isRankingListGetting){
				this.logManager.addLog("ランキングリストの取得に失敗。\n" + evt.target + ":" + evt);
				Alert.show("エラー：ランキングリストの取得に失敗。\n対象のWebサービスが現在利用可能かどうか確認してください。", "Error");
			}else if(this.isSearch){
				this.logManager.addLog("エラー:単語による検索に失敗。" + evt.target + ":" + evt);
				Alert.show("エラー：ランキングリストの取得に失敗。\n対象のWebサービスが現在利用可能かどうか確認してください。", "Error");
			}else if(this.isCommentOnly){
				this.logManager.addLog("エラー:コメントの取得に失敗。" + evt.target + ":" + evt);
				Alert.show("エラー：コメントの取得に失敗。\n対象のWebサービスが現在利用可能かどうか確認してください。", "Error");
			}else if(this.isMyListGroupRenew){
				this.logManager.addLog("エラー:マイリスト一覧の取得失敗。" + evt.target + ":" + evt);
				Alert.show("エラー：マイリスト一覧の取得失敗。\n対象のWebサービスが現在利用可能かどうか確認してください。", "Error");
			}else if(this.isMyListRenew){
				this.logManager.addLog("エラー:マイリストの更新に失敗。" + evt.target + ":" + evt);
				Alert.show("エラー：マイリストの更新に失敗。\n対象のWebサービスが現在利用可能かどうか確認してください。", "Error");
			}else if(this.isGetThumbInfo){
				this.logManager.addLog("エラー:サムネイル情報の更新に失敗。" + evt.target + ":" + evt);
//				Alert.show("エラー：サムネイル情報の取得に失敗。\n対象のWebサービスが現在利用可能かどうか確認してください。", "Error");
			}else if(this.isGetIchiba){
				this.logManager.addLog("エラー:市場情報の更新に失敗。" + evt.target + ":" + evt);
//				Alert.show("エラー：エラー:マイリストの更新に失敗。\n対象のWebサービスが現在利用可能かどうか確認してください。", "Error");
			}else if(this.isCommentPost){
				this.logManager.addLog("エラー:コメントの投稿に失敗。" + evt.target + ":" + evt);
			}else if(this.isThumbImgGetting){
				this.logManager.addLog("エラー:サムネイル画像の取得に失敗。" + evt.target + ":" + evt);
			}else{
				this.logManager.addLog("予期せぬエラー:" + evt);
//				Alert.show("エラー：予期せぬエラーが発生しました。\n対象のWebサービスが現在利用可能かどうか確認してください。\n" + evt.target + ":" + evt);
			}
			
			this.allClose(true, true);
			this.isVideoGetting = false;
			this.isRankingListGetting = false;
			
			//trace("isRetring:"+this.isRetring);
		}
		
		/**
		 * 動画のダウンロードをキャンセルし、DataGridおよびステータスラベルの更新を行います。
		 */
		public function videoDownloadCancel():void{
			if(rankingListProvider != null && rankingIndex != -1 && rankingListProvider.length > rankingIndex){
				if(rankingVideoName != null && rankingVideoName == rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName){
					this.rankingListProvider.setItemAt({
						dataGridColumn_ranking: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_ranking,
						dataGridColumn_preview: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_preview,
						dataGridColumn_videoName: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoName,
						dataGridColumn_Info: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_Info,
						dataGridColumn_videoInfo: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoInfo,
						dataGridColumn_condition: "キャンセル",
						dataGridColumn_videoPath: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_videoPath,
						dataGridColumn_date: rankingListProvider.getItemAt(rankingIndex).dataGridColumn_date
					},rankingIndex);
				}
			}
			
			if(downloadProvider != null){
				if(rankingVideoName != null && queueIndex < downloadProvider.length && queueIndex >= 0 &&
						downloadProvider[queueIndex] != null && rankingVideoName == downloadProvider[queueIndex].col_videoName){
					downloadProvider.setItemAt({
						col_videoName: downloadProvider[queueIndex].col_videoName,
						col_videoUrl: downloadProvider[queueIndex].col_videoUrl,
						col_status: "待機中",
						col_a2n: downloadProvider[queueIndex].col_a2n,
						col_downloadedPath: ""
					}, queueIndex);
				}
			}
			
			allClose(true);
			logManager.addLog("動画のダウンロードがキャンセルされました:" + videoTitle + videoType);
		}
		
		/**
		 * コメントのダウンロードをキャンセルし、ステータスラベルの更新を行います。
		 */
		public function commentDownloadCancel():void{
			allClose();
			isCancel = true;
			
			logManager.addLog("コメントのダウンロードがキャンセルされました:" + videoTitle + videoType);
		}
		
		/**
		 * 検索をキャンセルし、ステータスラベルの更新を行います。
		 * 
		 */
		public function searchCancel():void{
			allClose();
			isCancel = true;
			logManager.addLog("検索がキャンセルされました。");
		}
		
		/**
		 * ランキングの更新をキャンセルし、ステータスラベルの更新を行います。
		 * 
		 */
		public function rankingRenewCancel():void{
			allClose();
			isCancel = true;
			
			logManager.addLog("ランキングリストの更新がキャンセルされました。");
		}
		
		/**
		 * 既存のコメントキャッシュを削除します
		 */
		private function removeCache():void{
			var comment:File = new File(path + "temp/nndd.xml");
			if(comment.exists){
				comment.deleteFile();
			}
			
			var ownerComment:File = new File(path + "temp/nndd[Owner].xml");
			if(ownerComment.exists){
				ownerComment.deleteFile();
			}
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getThumbInfoAnalzyer():ThumbInfoAnalyzer{
			return this.analyzer;
		}
		
		/**
		 * 一括してクローズ処理を行う
		 * 
		 */
		public function allClose(isCancel:Boolean = false, isError:Boolean = false):void
		{
			try{
				this.loginLoader.close();
				this.loginLoader = null;
			}catch(e:Error){
				
			}
			
			try{
				this.downLoader.close();
				this.downLoader = null;
		 	}catch(e:Error){
//		 		trace(e);
		 	}
		 	try{
		    	this.watchLoader.close();
		    	this.watchLoader = null;
		 	}catch(e:Error){
//		 		trace(e);
		 	}
		 	try{
		 		this.listLoader.close();
				this.listLoader = null;
		 	}catch(e:Error){
//		 		trace(e);
		 	}
		 	try{
		 		this.videoLoader.close();
		 		this.videoLoader = null;
		 	}catch(e:Error){
//		 		trace(e);
		 	}
		 	try{
		 		this.commentLoader.close();
		 		this.commentLoader = null;
		 	}catch(e:Error){
//		 		trace(e);
		 	}
		 	try{
		 		this.oldListLoader.close()
		 		this.oldListLoader = null;
		 	}catch(e:Error){
		 		
		 	}
		 	try{
		 		this.searchLoader.close();
		 		this.searchLoader = null;
		 	}catch(e:Error){
		 		
		 	}
		 	try{
		 		this.myListGroupLoader.close();
		 		this.myListGroupLoader = null;
		 	}catch(e:Error){
		 		
		 	}
		 	try{
		 		this.myListLoader.close();
		 		this.myListLoader = null;
		 	}catch(e:Error){
		 		
		 	}
		 	
			if(this.isCommentPost && !isError){
		 		dispatchEvent(new Event(NICO_POST_COMMENT_COMPLETE));
		 	}else if(this.isCommentPost && isError){
		 		dispatchEvent(new Event(NICO_POST_COMMENT_FAIL));
		 	}else if(this.isRankingListGetting){
		 		dispatchEvent(new Event(RANKING_GET_COMPLETE));
		 	}else if(this.isCommentOnly || this.isOtherVideo){
		 		dispatchEvent(new Event(COMMENT_DOWNLOAD_COMPLETE));
		 	}else if(this.isSearch){
		 		dispatchEvent(new Event(NICO_SEARCH_COMPLETE));
		 	}else if(this.isMyListGroupRenew){
		 		dispatchEvent(new Event(NICO_MY_PAGE_LIST_GET_COMPLETE));
		 	}else if(this.isMyListRenew){
		 		dispatchEvent(new Event(NICO_MY_LIST_GET_COMPLETE));
		 	}else if(this.isGetThumbInfo){
		 		dispatchEvent(new Event(NICO_SINGLE_THUMB_INFO_GET_COMPLETE));
		 	}else if(this.isNicowariGetting){
		 		dispatchEvent(new Event(NICOWARI_DOWNLOAD_COMPLETE));
		 	}else if(this.isGetIchiba){
		 		dispatchEvent(new Event(NICO_ICHIBA_INFO_GET_COMPLETE));
		 	}else if(isCancel && !isError){
		 		dispatchEvent(new Event(DOWNLOAD_CANCEL));
		 	}else if(isCancel && isError){
		 		dispatchEvent(new Event(DOWNLOAD_ERROR_CANCEL));
		 	}else{
		 		dispatchEvent(new Event(DOWNLOAD_COMPLETE));
		 	}
		}

	}
}