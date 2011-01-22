package org.mineap.nndd
{
	public class Message
	{
		/* ラベル用 */
		public static var L_PLAY:String = "再生";
		public static var L_PAUSE:String = "一時停止";
		public static var L_STOP:String = "停止";
		public static var L_RENEW:String = "更新";
		
		public static var L_DOWNLOAD:String = "ダウンロード";
		public static var L_CANCEL:String = "キャンセル";
		
		public static var L_SHORTCUT_INFO:String = "Ctrl(Cmd)+F:スクリーン切替";
		public static var L_SHOW_UNDER_CONTROLLER:String = "下のコントローラを表示しない";
		
		public static var L_FULL:String = "FULL";
		public static var L_NORMAL:String = "NORMAL";
		public static var L_FULL_OR_NOMAL:String = "フルスクリーン/通常スクリーン";
		public static var L_INFOVIEW_SHOW_OR_HIDE:String = "InfoView表示/非表示";
		
		public static var L_COMMENT_SHOW_OR_HIDE:String = "コメント表示/非表示";
		
		public static var L_COMMENT_FILE_NOT_FOUND:String = "コメントが見つかりません";
		
		public static var L_LIBRARY_LOADING:String = "ライブラリを読み込んでいます。";
		public static var L_LIBRARY_RENEWING:String = "ライブラリを更新しています。";
		
		public static var L_VIDEO_DELETED:String = "削除されています。";
		
		public static var L_RANKING_MENU_ITEM_LABEL_PLAY:String = "DL済の動画を再生";
		public static var L_RANKING_MENU_ITEM_LABEL_STREAMING_PLAY:String = "ストリーミング再生";
		public static var L_RANKING_MENU_ITEM_LABEL_ADD_DL_LIST:String = "DLリストに追加";
		public static var L_DOWNLOADED_MENU_ITEM_LABEL_DELETE:String = "動画を削除";
		public static var L_DOWNLOADED_MENU_ITEM_LABEL_PLAY:String = "動画を再生";
		public static var L_DOWNLOADED_MENU_ITEM_LABEL_PLAY_BY_QUEUE:String = "動画を再生";
		public static var L_DOWNLOADED_MENU_ITEM_LABEL_DELETE_BY_QUEUE:String = "動画をリストから削除";
		public static var L_DOWNLOADED_MENU_ITEM_LABEL_EDIT:String = "動画を編集";
		public static var L_FILE_SYSTEM_TREE_MENU_ITEM_LABEL_RENEW:String = "このフォルダの情報を再収集";
		public static var L_FILE_SYSTEM_TREE_MENU_ITEM_LABEL_RENEW_WITH_SUBDIR:String = "このフォルダとサブフォルダの情報を再収集";
		public static var L_FILE_SYSTEM_TREE_MENU_ITEM_LABEL_PLAYALL:String = "一覧を連続再生";
		public static var L_TAB_LIST_MENU_ITEM_LABEL_SEARCH:String = "タグをニコニコで検索";
		public static var L_TAB_LIST_MENU_ITEM_LABEL_JUMP_DIC:String = "タグをニコニコ大百科で表示";
		public static var L_TAB_LIST_MENU_ITEM_LABEL_SHOW_TAG:String = "タグを表示";
		public static var L_TAB_LIST_MENU_ITEM_LABEL_HIDE_TAG:String = "タグを隠す";
		public static var L_COPY_URL:String = "URLをコピー";
		public static var L_ADD_PLAYER_PLAYLIST_AND_PLAY:String = "一覧を連続再生";
		public static var L_MYLIST_MENU_ITEM_LABEL_SET_PLAYED:String = "動画を視聴済に設定";
		
		public static var L_PLAYLIST_ADD_SELECTED_ITEM:String = "プレイリストに追加";
		
		public static var L_BACK:String = "一つ前の動画に戻る";
		public static var L_OPEN_FILE:String = "ファイル/URLを指定して動画を開く";
		public static var L_OPEN_NICOMIMI:String = "nicomimi-にこみみ- でひらく(MP3)";
		public static var L_OPEN_NICOSOUND:String = "にこ☆さうんど# でひらく(MP3)";
		public static var L_OPEN_DEFAULT_WEB_BROWSER:String = "既定のブラウザで再生";
		public static var L_TWEET:String = "twitterでつぶやく";
		public static var L_ADD_HATENA_BOOKMARK:String = "はてなブックマークに追加";
		public static var L_OPEN_NICONICO_DOUGA:String = "ニコニコ動画で再生";
		public static var L_NOMAL_OR_WIDE:String = "4:3モード/16:9モード";
		public static var L_COPY_VIDEO_URL:String = "動画のURLをコピー";
		public static var L_COPY_VIDEO_URL_WITH_TITLE:String = "動画のタイトルとURLをコピー";
		public static var L_RELOAD_VIDEO:String = "動画を再読み込み";
		
		/*主にメッセージ出力*/
		public static var M_LOCAL_STORE_IS_BROKEN:String = "ローカルストアが破損している可能性があったため、ローカルストアのデータをリセットしました。";
		public static var M_CONF_FILE_IS_BROKEN:String = "設定ファイルから正しい設定がロードできませんでした。";
		public static var M_CONF_FILE_CAN_NOT_SAVE:String = "設定ファイルを保存できませんでした。";
		public static var M_FAIL_VIDEO_DELETE:String = "動画の削除に失敗しました。ファイルが開かれていない状態でもう一度試してください。";
		public static var M_FAIL_OTHER_DELETE:String = "削除できなかった項目があります。";
		public static var M_FAIL_MOVE_FILE:String = "ファイルの移動に失敗しました。";
		public static var M_FILE_NOT_FOUND_REFRESH:String = "ファイルが存在しません。設定 > 保存先の内容を更新 でライブラリを更新するか、再生しようとした動画が存在する事を確認してください。";
		public static var M_FAIL_ARGUMENT_BOOT:String = "引数で指定された値を使って動画を再生しようとしましたが失敗しました。";
		
		public static var M_ALREADY_UPDATE_PROCESS_EXIST:String = "他の更新が進行中です。";
		public static var M_ALREADY_DOWNLOAD_PROCESS_EXIST:String = "他のダウンロードが進行中です。";
		
		public static var M_ALREADY_DOWNLOADED_VIDEO_EXIST:String = "既にダウンロード済みです。もう一度ダウンロードしますか？";
		public static var M_ALREADY_DLLIST_VIDEO_EXIST:String = "既にダウンロードリストに追加済みです。もう一度追加しますか？";
		
		public static var M_ECONOMY_MODE_NOW:String = "現在エコノミーモードです。ダウンロードしますか？";
		
		public static var M_NOT_NICO_URL:String = "指定されたURLはニコニコ動画のURLではありません。";
		
		public static var M_VIDEOID_NOTFOUND:String = "この動画のファイル名には動画IDが存在しないため、コメント・サムネイル情報・ユーザーニコ割をダウンロードできません。";
		public static var M_VIDEOID_NOTFOUND_FOR_COMMENT_ONLY:String = "この動画のファイル名には動画IDが存在しないため、コメントをダウンロードできません。";
		
		public static var M_DOWNLOAD_PROCESSING:String = "全ての項目をリストから削除しようとしています。よろしいですか？\n" +
			"(未ダウンロードの項目も削除されます。)";
		
		public static var M_ALL_DOWNLOADED_VIDEO_DELETE:String = "ダウンロード済みの項目を全てリストから削除します。よろしいですか？";
		
		public static var M_THIS_ITEM_IS_DOWNLOADING:String = "ダウンロードが進行中です。削除してもよろしいですか？";
		
		public static var M_FILE_ALREADY_EXISTS:String = "移動先に同名のファイルが存在します。上書きしますか？";
		
		public static var M_OUT_PLAYER_NOT_FOUND:String = "外部プレーヤが見つかりませんでした。「設定」タブで外部プレーヤのパスを設定し直すか、外部プレーヤを使用しない設定に変更してください。";
		
		public static var M_DOWNLOAD_LIST_COUNT_OVER:String = "DLリストに既に100件の項目が存在します。これ以上追加する場合はDLリストから項目を削除してください。";
		
		public static var M_DOWNLOAD_LIST_COUNT_OVER_DELETE:String = "DLリストに既に100件の項目が存在します。DL済の項目を削除しますか？";
		
		public static var M_RENEW_MYLIST_GROUP:String = "あなたのニコニコ動画上のマイリストをNNDDのマイリストの一覧に追加しますか？\n\n(この操作は「設定」>「ランキング・検索・マイリスト」の「自分のマイリストをマイリスト一覧に追加」からも実行できます。)";
		
		public static var M_LIBRARY_FILE_NOT_FOUND:String = "指定されたライブラリの保存先が見つからなかったため、保存先をリセットしました。\n\n見つからなかった保存先:";
		
		public static var M_SHORT_URL_EXPANSION_FAIL:String = "短縮URLの展開に失敗しました。";
		
		public static var M_ERROR:String = "エラー";
		public static var M_MESSAGE:String = "通知";
		
		/*主にログ出力*/
		public static var BOOT_TIME_LOG:String = "アプリケーションの起動 - NNDD\n" + 
				"\t***** NNDDはMineAppProjectが作成しています。 *****\n" + 
				"\tNNDDプロジェクト\thttp://sourceforge.jp/projects/nndd/\n" +
				"\tMineAppProjectブログ\thttp://d.hatena.ne.jp/MineAP/\n" + 
				"\t*********************************************";
		
		public static var DELETE_FILE:String = "ファイルを削除";
		public static var MOVE_FILE:String = "ファイルを移動";
		
		public static var PLAY_VIDEO:String = "動画を再生";
		public static var INVOKE_ARGUMENT:String = "引数で値が渡されました";
		
		public static var SUCCESS_NICOCHART_ACCESS:String = "ニコニコチャートランキングの取得完了";
		public static var SUCCESS_SEARTCH:String = "検索結果を更新";
		public static var SUCCESS_RANKING_RENEW:String = "ランキングを更新"
		
		public static var SUCCESS_ACCESS_TO_NICONICODOUGA:String = "ニコニコ動画との接続に成功";
		public static var SUCCESS_ACCESS_TO_NICOAPI:String = "APIからアドレスの取得に成功";
		
		public static var SUCCESS_DOWNLOAD_USER_COMMENT:String = "ユーザーコメントXMLのダウンロードに成功";
		public static var SUCCESS_DOWNLOAD_OWNER_COMMENT:String = "投稿者コメントXMLのダウンロードに成功";
		public static var SUCCESS_DOWNLOAD_NICOWARI:String = "ユーザーニコ割のダウンロードに成功"
		public static var SUCCESS_DOWNLOAD_VIDEO:String = "動画のダウンロードに成功"
		
		public static var SUCCESS_SAVE_USER_COMMENT:String = "ユーザーコメントXMLの保存に成功";
		public static var FAIL_SAVE_USER_COMMENT:String = "ユーザーコメントXMLの保存に失敗";
		
		public static var SUCCESS_SAVE_OWNER_COMMENT:String = "投稿者コメントXMLの保存に成功";
		public static var FAIL_SAVE_OWNER_COMMENT:String = "投稿者コメントXMLの保存に失敗";
		
		public static var SUCCESS_SAVE_NICOWARI:String = "ユーザーニコ割の保存に成功";
		public static var FAIL_SAVE_NICOWARI:String = "ユーザーニコ割の保存に失敗";
		
		public static var SUCCESS_SAVE_VIDEO:String = "動画の保存に成功";
		public static var FAIL_SAVE_VIDEO:String = "動画の保存に失敗";
		
		public static var FAIL_LIBRARY_UNCONFORMITY_WAS_FOUND:String = "ライブラリファイルと実際のファイル構成に不整合があります。";
		
		public static var FILE_NOT_FOUND:String = "次のファイルが見つかりませんでした。"
		
		public static var ERROR:String = "エラーが発生しました。";
		
		public static var WINDOW_POSITION_RESET:String = "ウィンドウ位置をリセットしました。";
		
		public static var START_PLAY_EACH_COMMENT_DOWNLOAD:String = "コメント・サムネイル・ニコ割を更新しています...";
		public static var COMPLETE_PLAY_EACH_COMMENT_DOWNLOAD:String = "コメント・サムネイル・ニコ割を更新が完了しました";
		public static var PLAY_EACH_COMMENT_DOWNLOAD_CANCEL:String = "コメント・サムネイル・ニコ割がキャンセルされました";
		public static var FAIL_PLAY_EACH_COMMENT_DOWNLOAD:String = "コメント・サムネイル・ニコ割の更新に失敗しました";
		
		public static var FAIL_LOAD_LOCAL_STORE_FOR_NNDD_MAIN_WINDOW:String = "NNDDメインウィンドウのローカルストア情報読み込みに失敗";
		public static var FAIL_LOAD_CONF_FILE_FOR_NNDD_MAIN_WINDOW:String = "NNDDメインウィンドウの設定ファイル読み込みに失敗";
		public static var FAIL_LOAD_CONF_FILE_FOR_VIDEO_CONTROLLER:String = "VideoControllerの設定ファイル読み込みに失敗";
		public static var FAIL_LOAD_CONF_FILE_FOR_VIDEO_PLAYER:String = "VideoPlayerの設定ファイル読み込みに失敗";
		public static var FAIL_LOAD_CONF_FILE_FOR_VIDEO_INFO_VIEW:String = "VideoInfoViewの設定ファイル読み込みに失敗";
		
		public static var FAIL_SAVE_LOCAL_STORE_FOR_NNDD_MAIN_WINDOW:String = "NNDDメインウィンドウのローカルストア情報書き込みに失敗";
		public static var FAIL_SAVE_CONF_FILE_FOR_NNDD_MAIN_WINDOW:String = "NNDDメインウィンドウの設定ファイル書き込みに失敗";
		public static var FAIL_SAVE_CONF_FILE_FOR_VIDEO_CONTROLLER:String = "VideoControllerの設定ファイル書き込みに失敗";
		public static var FAIL_SAVE_CONF_FILE_FOR_VIDEO_PLAYER:String = "VideoPlayerの設定ファイル書き込みに失敗";
		public static var FAIL_SAVE_CONF_FILE_FOR_VIDEO_INFO_VIEW:String = "VideoInfoViewの設定ファイル書き込みに失敗";

		public static var FAIL_MOVE_FILE:String = "ファイルの移動に失敗";
		public static var FAIL_ARGUMENT_BOOT:String = "引数で指定された値を使った動画の再生に失敗";

		public static var ARGUMENT_FORMAT:String = "例)nndd.exe -d http://www.nicovideo.jp/watch/ex0000\n※-dオプションをつけるとDLリストに追加、つけないとストリーミング再生。"
		
		public static const DONOT_USE_CHAR_FOR_FILE_NAME:String = "/ : ? \\ * \" % < > | # ;";
		
		public function Message()
		{
		}

	}
}