package org.mineap.nndd.myList {
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import mx.core.FlexGlobals;

    import org.mineap.nndd.LogManager;
    import org.mineap.nndd.NNDDMyListLoader;
    import org.mineap.nndd.NNDDMyListsLoader;
    import org.mineap.nndd.event.MyListRenewProgressEvent;
    import org.mineap.nndd.library.LibraryManagerBuilder;
    import org.mineap.nndd.model.MyListRenewResultType;
    import org.mineap.nndd.model.RssType;

    [Event(name="complete", type="Event")]
    [Event(name="mylistRenewProgress", type="MyListRenewProgressEvent")]

    /**
     * マイリスト更新のスケジューリングおよび実行を行います。
     *
     * @author shiraminekeisuke(MineAP)
     *
     */ public class MyListRenewScheduler extends EventDispatcher {

        /**
         * スケジューリング対象のマイリストの一覧を保持します
         */
        private var _myLists: Vector.<MyList> = new Vector.<MyList>();

        /**
         * マイリストIDをキーにマイリスト取得結果を格納するMapです
         */
        private var _myListRenewResultMap: Object = new Object();

        /**
         * スケジュール実行用タイマー
         */
        private var _timer: Timer = null;

        /**
         * デフォルトの待ち時間。1000ms(=1s) * 60 * 30 = 30分
         */
        private var _delay: Number = 1000 * 60 * 30;

        /**
         * インデックス
         */
        private var _index: int = 0;

        /**
         *
         */
        private var _renewing: Boolean = false;

        /**
         *
         */
        private static const _myListRenewScheduler: MyListRenewScheduler = new MyListRenewScheduler();

        /**
         *
         */
        public static const MyListRenewScheduleTimeArray: Array = new Array(15, 30, 60, 120, 240, 480);

        /**
         *
         */
        private var _mailAddress: String;

        /**
         *
         */
        private var _password: String;

        /**
         * マイリスト更新一つあたりの間隔。ミリ秒で指定する。
         */
        private var _delayOfMylist: int = 1000;

        private var enableNNDDServerAccess: Boolean = false;
        private var nnddServerAddress: String;
        private var nnddServerPort: int;

        private var _nnddMyListsLoader: NNDDMyListsLoader;

        /**
         *
         * @param mailAddress
         *
         */
        public function set mailAddress(mailAddress: String): void {
            this._mailAddress = mailAddress;
        }

        /**
         *
         * @param password
         *
         */
        public function set password(password: String): void {
            this._password = password;
        }

        /**
         * シングルトンパターン
         *
         */
        public function MyListRenewScheduler() {
            if (_myListRenewScheduler != null) {
                throw ArgumentError("MyListRenewSchedulerはインスタンス化できません。");
            }
        }

        /**
         * 唯一のMyListRenewSchedulerのインスタンスを返します。
         * @return
         *
         */
        public static function get instance(): MyListRenewScheduler {
            return _myListRenewScheduler;
        }

        /**
         * 指定されたマイリストをスケジューリング対象に追加します。
         * @param myListId
         *
         */
        public function addMyList(myList: MyList): void {

            var myListId: String = myList.id;

            if (myListId != null) {

                var exist: Boolean = false;
                for each(var temp: MyList in this._myLists) {
                    if (temp.id == myListId) {
                        exist = true;
                        break;
                    }
                }
                if (!exist) {
                    this._myLists.splice(0, 0, myList);
                }
            }
        }

        /**
         *
         *
         */
        public function myListReset(): void {
            this._myLists.splice(0, this._myLists.length);
        }

        /**
         * スケジュール実行を停止します
         *
         */
        public function stop(): void {
            if (this._timer != null) {
                this._timer.stop();
                this._timer.removeEventListener(TimerEvent.TIMER, timerEventListener);
                this._timer = null;
            }
        }

        /**
         * スケジュール実行を開始します。
         *
         * @param delay スケジューリング間隔。デフォルトは1800000ms。
         *
         */
        public function start(delay: Number = 1800000): void {
            this._delay = delay;

            if (this._timer != null) {
                this._timer.stop();
                this._timer.removeEventListener(TimerEvent.TIMER, timerEventListener);
                this._timer = null;
            }

            this._timer = new Timer(this._delay, 0);
            this._timer.addEventListener(TimerEvent.TIMER, timerEventListener);
            this._timer.start();

        }

        /**
         * マイリスト更新を今すぐ実行します。
         *
         */
        public function startNow(): void {
            trace("マイリスト更新即時実行");
            LogManager.instance.addLog("マイリスト更新即時実行");

            updateMyListsForNNDDServer();

            if (!this._renewing) {	//実行中で無ければ実施
                next(0);
            } else {
                LogManager.instance.addLog("既に実行中なのでマイリスト更新をスキップ");
            }

        }

        /**
         * タイマーから発行されるTimerイベントのリスナです。
         *
         * @param event
         *
         */
        private function timerEventListener(event: TimerEvent): void {
            trace("マイリスト更新のスケジュール実行(間隔:" + this._delay + "ms)");
            LogManager.instance.addLog("マイリスト更新のスケジュール実行(間隔:" + this._delay + "ms)");

            if (!this._renewing) {	//実行中で無ければ実施
                next(0);
            } else {
                LogManager.instance.addLog("既に実行中なのでマイリスト更新をスキップ");
            }

        }

        /**
         * 次のマイリストの取得を行います。
         * startIndexを指定しないと、純粋にindexを加算します。指定した場合は、指定されたindexから更新を開始します。
         * @param startIndex
         *
         */
        private function next(startIndex: int = -1): void {

            this._renewing = true;

            if (startIndex == -1) {
                this._index++;
            } else {
                this._index = startIndex;
            }

            if (this._index >= this._myLists.length) {
                dispatchEvent(new Event(Event.COMPLETE));
                LogManager.instance.addLog("マイリスト更新のスケジュール実行完了");
                this._renewing = false;
                return;
            }

            var myList: MyList = this._myLists[this._index];

            if (myList != null) {
                myListRenew(myList);
            } else {
                next();
            }
        }

        /**
         * マイリストの一覧をNNDDServerから取得します
         *
         */
        private function updateMyListsForNNDDServer(): void {

            if (enableNNDDServerAccess) {
                if (_nnddMyListsLoader != null) {
                    try {
                        _nnddMyListsLoader.close();
                    } catch (error: Error) {
                    }
                }

                LogManager.instance.addLog("NNDDサーバに対してマイリスト一覧を要求します:" + nnddServerAddress + ":" + nnddServerPort);

                _nnddMyListsLoader = new NNDDMyListsLoader();
                _nnddMyListsLoader.addEventListener(NNDDMyListsLoader.GET_MYLISTS_COMPLETE, myListsLoadCompleteHandler);
                _nnddMyListsLoader.addEventListener(IOErrorEvent.IO_ERROR, myListsLoadErrorHandler);
                _nnddMyListsLoader.getMyLists(nnddServerAddress, nnddServerPort);
            } else {
                next(0);
            }
        }

        /**
         *
         * @param event
         *
         */
        protected function myListsLoadCompleteHandler(event: Event): void {
            trace(event);
            LogManager.instance.addLog("NNDDサーバ応答あり:" + event);

            var myLists: Vector.<MyList> = (event.currentTarget as NNDDMyListsLoader).myLists;

            for each(var myList: MyList in myLists) {
                if (!MyListManager.instance.isExistsForId(myList.id, myList.type)) {
                    trace("新しいマイリスト:" + myList.idWithPrefix);
                    LogManager.instance.addLog("NNDDServerから新しいマイリストを受信:" + myList.idWithPrefix);

                    // マイリスト管理に追加
                    MyListManager.instance.addMyList(myList.myListUrl, myList.myListName, false, false);

                    // 更新対象に追加
                    this.addMyList(myList);

                } else {
                    trace("このマイリストはある:" + myList.id + "," + myList.type);
                }
            }
            MyListManager.instance.saveMyListSummary(LibraryManagerBuilder.instance.libraryManager.systemFileDir);

            if (FlexGlobals.topLevelApplication.tree_myList != null) {
                // 表示の更新
                FlexGlobals.topLevelApplication.tree_myList.validateNow();
            }

            next(0);
        }

        /**
         *
         * @param event
         *
         */
        protected function myListsLoadErrorHandler(event: ErrorEvent): void {
            trace(event);
            LogManager.instance.addLog("NNDDサーバ応答なし:" + event);
            next(0);
        }

        /**
         * 結果を取得します。結果が取得できていない場合はnullが返されます。
         * @param myListId
         * @return
         *
         */
        public function getResult(myListId: String): MyListRenewResultType {
            return this._myListRenewResultMap[myListId];
        }

        /**
         * 指定されたマイリストを更新します。
         *
         * @param myListId
         * @param enableNext
         * @return
         *
         */
        private function myListRenew(myList: MyList, enableNext: Boolean = true): void {

            if (this._mailAddress != null && this._mailAddress != "" && this._password != null && this._password !=
                "") {

                var nnddMyListLoader: NNDDMyListLoader = new NNDDMyListLoader();

                var myListId: String = myList.id;

                var myListStr: String;
                if (myList.type == RssType.CHANNEL) {
                    myListStr = "channel/" + myList.id + " " + myList.myListName;
                } else if (myList.type == RssType.COMMUNITY) {
                    myListStr = "community/" + myListId + " " + myList.myListName;
                } else if (myList.type == RssType.USER_UPLOAD_VIDEO) {
                    myListStr = "user/" + myList.id + " " + myList.myListName;
                } else {
                    myListStr = "mylist/" + myList.id + " " + myList.myListName;
                }

                LogManager.instance.addLog("マイリスト/チャンネルのスケジュール更新開始(" + (this._index + 1) + "/" + this._myLists.length +
                                           "):" + myListStr);

                dispatchEvent(new MyListRenewProgressEvent(
                    MyListRenewProgressEvent.MYLIST_RENEW_PROGRESS,
                    false,
                    false,
                    this._index + 1,
                    this._myLists.length,
                    myListStr
                ));

                nnddMyListLoader.enableNNDDServer = enableNNDDServerAccess;
                nnddMyListLoader.nnddServerAddress = nnddServerAddress;
                nnddMyListLoader.nnddServerPort = nnddServerPort;

                nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_COMPLETE, myListGetComplete);
                nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_FAIL, myListGetFail);
                nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_CANCELD, myListGetFail);
                nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_ERROR, myListGetFail);

                switch (myList.type) {
                    case RssType.CHANNEL:
                        nnddMyListLoader.requestDownloadForChannel(_mailAddress, _password, myListId);
                        break;
                    case RssType.COMMUNITY:
                        nnddMyListLoader.requestDownloadForCommunity(_mailAddress, _password, myListId);
                        break;
                    case RssType.USER_UPLOAD_VIDEO:
                        nnddMyListLoader.requestDownloadForUserVideoList(_mailAddress, _password, myListId);
                        break;
                    default:
                        nnddMyListLoader.requestDownloadForMyList(_mailAddress, _password, myListId);
                }

                function myListGetComplete(event: Event): void {
                    nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_COMPLETE, myListGetComplete);
                    nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_FAIL, myListGetFail);
                    nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_CANCELD, myListGetFail);
                    nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_ERROR, myListGetFail);

                    nnddMyListLoader.close(false, false);

                    var xml: XML = nnddMyListLoader.xml;
                    if (xml != null) {
                        MyListManager.instance.saveMyList(myListId, myList.type, xml, true);
                        LogManager.instance.addLog("マイリスト/チャンネルのスケジュール更新完了(" + myListStr + ")");
                        _myListRenewResultMap[myListId] = MyListRenewResultType.SUCCESS;
                    } else {
                        LogManager.instance.addLog("マイリスト/チャンネルのスケジュール更新失敗(" + myListStr + ")");
                        _myListRenewResultMap[myListId] = MyListRenewResultType.FAIL;
                    }
                }

                function myListGetFail(event: Event): void {

                    if (event.type == NNDDMyListLoader.DOWNLOAD_PROCESS_CANCELD || event.type ==
                        NNDDMyListLoader.DOWNLOAD_PROCESS_ERROR) {
                        nnddMyListLoader.removeEventListener(
                            NNDDMyListLoader.DOWNLOAD_PROCESS_COMPLETE,
                            myListGetComplete
                        );
                        nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_FAIL, myListGetFail);
                        nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_CANCELD, myListGetFail);
                        nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_ERROR, myListGetFail);
                    }

                    nnddMyListLoader.close(false, false);

                    LogManager.instance.addLog("マイリスト/チャンネルのスケジュール更新失敗(" + myListStr + ")");
                    _myListRenewResultMap[myListId] = MyListRenewResultType.FAIL;

                }

                if (enableNext) {
                    var timer: Timer = new Timer(this._delayOfMylist, 1);
                    timer.addEventListener(TimerEvent.TIMER_COMPLETE, function (event: Event): void {
                        next();
                    });
                    timer.start();
                }

            } else {
                LogManager.instance.addLog("マイリスト/チャンネルのスケジュール更新失敗(メールアドレスとパスワードが未設定)");
            }

        }

        /**
         *
         */
        public function get delayOfMylist(): int {
            return _delayOfMylist;
        }

        /**
         * @private
         */
        public function set delayOfMylist(value: int): void {
            _delayOfMylist = value;
        }

        /**
         *
         * @param enableNNDDServerAccess
         * @param nnddServerAddress
         * @param nnddServerPort
         *
         */
        public function updateNNDDServerAccessSetting(
            enableNNDDServerAccess: Boolean,
            nnddServerAddress: String,
            nnddServerPort: int
        ): void {
            this.enableNNDDServerAccess = enableNNDDServerAccess;
            this.nnddServerAddress = nnddServerAddress;
            this.nnddServerPort = nnddServerPort;
        }

    }

}