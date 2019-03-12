package org.mineap.nndd {
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.utils.setTimeout;

    import org.mineap.nicovideo4as.Login;
    import org.mineap.nicovideo4as.loader.ChannelLoader;
    import org.mineap.nicovideo4as.loader.CommunityLoader;
    import org.mineap.nicovideo4as.loader.PublicMyListLoader;
    import org.mineap.nicovideo4as.loader.UserVideoListLoader;
    import org.mineap.nndd.library.ILibraryManager;
    import org.mineap.nndd.library.LibraryManagerBuilder;
    import org.mineap.nndd.model.NNDDVideo;
    import org.mineap.nndd.model.RssType;
    import org.mineap.nndd.myList.MyListManager;
    import org.mineap.nndd.server.RequestType;
    import org.mineap.nndd.util.LibraryUtil;
    import org.mineap.util.config.ConfigManager;

    [Event(name="loginSuccess", type="NNDDMyListLoader")]
    [Event(name="loginFail", type="NNDDMyListLoader")]
    [Event(name="downloadSuccess", type="NNDDMyListLoader")]
    [Event(name="downloadGetFail", type="NNDDMyListLoader")]

    [Event(name="downloadProcessComplete", type="NNDDMyListLoader")]
    [Event(name="donwloadProcessCancel", type="NNDDMyListLoader")]
    [Event(name="downloadProccessError", type="NNDDMyListLoader")]

    /**
     *
     * @author shiraminekeisuke(MineAP)
     *
     */ public class NNDDMyListLoader extends EventDispatcher {

        private var _login: Login;

        private var _channelLoader: ChannelLoader;
        private var _communityLoader: CommunityLoader;
        private var _publicMyListLoader: PublicMyListLoader;
        private var _userVideoListLoader: UserVideoListLoader;
        private var _currentPage: int;
        private var _retryCount: int;

        private var _nnddServerUrlLoader: URLLoader;

        private var _libraryManager: ILibraryManager;

        private var _myListId: String;
        private var _channelId: String;
        private var _communityId: String;
        private var _uploadUserId: String;

        public var enableNNDDServer: Boolean = false;
        public var nnddServerAddress: String = null;
        public var nnddServerPort: int = -1;

        private var _xml: XML;

        /**
         *
         */
        public static const LOGIN_SUCCESS: String = "LoginSuccess";

        /**
         *
         */
        public static const LOGIN_FAIL: String = "LoginFail";

        /**
         *
         */
        public static const DOWNLOAD_SUCCESS: String = "DownloadSuccess";

        /**
         *
         */
        public static const DOWNLOAD_FAIL: String = "DownloadFail";

        public static const DOWNLOAD_RETRY: String = "RetryDownload";

        /**
         * ダウンロード処理が通常に終了したとき、typeプロパティがこの定数に設定されたEventが発行されます。
         */
        public static const DOWNLOAD_PROCESS_COMPLETE: String = "DownloadProcessComplete";

        /**
         * 動画リストが複数のページにまたがる場合のログに出力されます
         */
        public static const DOWNLOAD_PROCESS_INPROGRESS: String = "DownloadProcessInprogress";

        /**
         * ダウンロード処理が中断された際に、typeプロパティがこの定数に設定されたEventが発行されます。
         */
        public static const DOWNLOAD_PROCESS_CANCELD: String = "DonwloadProcessCancel";

        /**
         * ダウンロード処理が異状終了した際に、typeプロパティがこの定数に設定されたEventが発行されます。
         */
        public static const DOWNLOAD_PROCESS_ERROR: String = "DownloadProccessError";

        public static const RETRY_COUNT_LIMIT: int = 10;

        /**
         *
         * @param logManager
         *
         */
        public function NNDDMyListLoader() {
            this._libraryManager = LibraryManagerBuilder.instance.libraryManager;
            this._login = new Login();
        }

        /**
         *
         * @param user
         * @param password
         * @param id
         *
         */
        public function requestDownloadForMyList(user: String, password: String, id: String): void {
            trace("start - requestDownload(" + user + ", ****, mylist/" + id + ")");

            this._myListId = id;

            login(user, password);
        }

        /**
         *
         * @param user
         * @param password
         * @param id
         *
         */
        public function requestDownloadForChannel(user: String, password: String, id: String): void {

            trace("start - requestDownload(" + user + ", ****, channel/" + id + ")");

            this._channelId = id;
            this._currentPage = 1;
            this._retryCount = 0;
            login(user, password);

        }

        /**
         *
         * @param user
         * @param password
         * @param communityId
         */
        public function requestDownloadForCommunity(user: String, password: String, communityId: String): void {
            trace("start - requestDownload(" + user + ", ****, community/" + communityId + ")");
            this._communityId = communityId;
            this._currentPage = 1;
            this._retryCount = 0;
            login(user, password);
        }

        /**
         *
         * @param user
         * @param password
         * @param uploadUserId
         *
         */
        public function requestDownloadForUserVideoList(user: String, password: String, uploadUserId: String): void {
            trace("start - requestDownload(" + user + ", ****, user/" + uploadUserId + ")");
            this._uploadUserId = uploadUserId;
            this._currentPage = 1;
            this._retryCount = 0;
            login(user, password);
        }

        /**
         *
         * @param user
         * @param password
         *
         */
        private function login(user: String, password: String): void {

            this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccess);
            this._login.addEventListener(Login.LOGIN_FAIL, function (event: ErrorEvent): void {
                (event.target as Login).close();
                LogManager.instance.addLog(DOWNLOAD_FAIL + event.target + ":" + event.text);
                trace(event + ":" + event.target + ":" + event.text);
                dispatchEvent(new ErrorEvent(DOWNLOAD_FAIL, false, false, event.text));
                close(true, true, event);
            });
            this._login.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function (event: HTTPStatusEvent): void {
                trace(event);
                LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
            });

            this._login.login(user, password);
        }

        /**
         *
         * @param event
         *
         */
        private function loginSuccess(event: Event): void {

            //ログイン成功通知
            trace(LOGIN_SUCCESS + ":" + event);
            dispatchEvent(new Event(LOGIN_SUCCESS));

            if (enableNNDDServer) {

                var type: RssType = null;
                var id: String = null;

                if (this._myListId != null) {
                    id = this._myListId;
                    type = RssType.MY_LIST;
                } else if (this._channelId != null) {
                    id = this._channelId;
                    type = RssType.CHANNEL;
                } else if (this._communityId != null) {
                    id = this._communityId;
                    type = RssType.COMMUNITY;
                } else if (this._uploadUserId != null) {
                    id = this._uploadUserId;
                    type = RssType.USER_UPLOAD_VIDEO;
                }

                _nnddServerUrlLoader = new URLLoader();

                _nnddServerUrlLoader.addEventListener(Event.COMPLETE, function (event: Event): void {
                    _nnddServerUrlLoader.close();

                    try {
                        if (_nnddServerUrlLoader.data != null) {

                            var resXml: XML = new XML(_nnddServerUrlLoader.data);

                            var videoIds: Vector.<String> = new Vector.<String>();
                            for each(var item: XML in resXml.channel.item) {
                                if ("true" == String(item.played.text())) {
                                    var videoId: String = LibraryUtil.getVideoKey(item.link.text());
                                    if (videoId != null) {
                                        videoIds.push(videoId);
                                    }
                                }
                            }

                            LogManager.instance.addLog("NNDDServerから取得したマイリスト情報をもとに、" + videoIds.length +
                                                       "件の動画を視聴済みに設定(id:" + id + ", type:" + type + ")");
                            MyListManager.instance.updatePlayedAndSave(id, type, videoIds, true);

                        }
                    } catch (error: Error) {
                        trace(error.getStackTrace());
                    }

                    loadRss();
                });
                _nnddServerUrlLoader.addEventListener(IOErrorEvent.IO_ERROR, function (event: IOErrorEvent): void {
                    _nnddServerUrlLoader.close();

                    trace(event);
                    LogManager.instance.addLog("NNDDServerからマイリスト情報を取得しようとしましたが失敗しました:" + event);

                    loadRss();
                });

                var reqXml: XML = <nnddRequest/>;
                reqXml.@type = RequestType.GET_MYLIST_BY_ID.typeStr;
                reqXml.rss.@rssType = type.toString();
                reqXml.rss.@id = id;

                var videos: Vector.<NNDDVideo> = MyListManager.instance.readLocalMyListByNNDDVideo(id, type);
                for each(var video: NNDDVideo in videos) {
                    if (video.yetReading) {
                        var videoXml: XML = <video/>;
                        videoXml.@id = video.key;
                        videoXml.@played = video.yetReading;
                        reqXml.rss.appendChild(videoXml);
                    }
                }

                var timeout: int = 1000;

                var timeoutStr: String = ConfigManager.getInstance().getItem("connectToNnddServerTimeout");
                if (timeoutStr != null) {
                    timeout = int(timeoutStr);
                }

                var urlRequest: URLRequest = new URLRequest("http://" + nnddServerAddress + ":" + nnddServerPort +
                                                            "/NNDDServer");
                urlRequest.method = "POST";
                urlRequest.data = reqXml.toXMLString();
                urlRequest.idleTimeout = timeout;

                LogManager.instance.addLog("NNDDServerからマイリスト情報を取得します:" + urlRequest.url);

                _nnddServerUrlLoader.load(urlRequest);

            } else {
                loadRss();
            }

        }

        protected function loadRss(): void {
            if (this._myListId != null) {
                this._publicMyListLoader = new PublicMyListLoader();
                this._publicMyListLoader.addEventListener(Event.COMPLETE, getXMLSuccess);
                this._publicMyListLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoadIOErrorHandler);
                this._publicMyListLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoadIOErrorHandler);

                this._publicMyListLoader.getMyList(this._myListId);
            } else if (this._channelId != null) {
                this._channelLoader = new ChannelLoader();
                this._channelLoader.addEventListener(Event.COMPLETE, getXMLSuccess);
                this._channelLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoadIOErrorHandler);
                this._channelLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoadIOErrorHandler);

                this._channelLoader.getChannel(this._channelId, this._currentPage);
            } else if (this._communityId != null) {
                this._communityLoader = new CommunityLoader();
                this._communityLoader.addEventListener(Event.COMPLETE, getXMLSuccess);
                this._communityLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoadIOErrorHandler);
                this._communityLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoadIOErrorHandler);

                this._communityLoader.getCommunity(this._communityId, this._currentPage);
            } else if (this._uploadUserId != null) {
                this._userVideoListLoader = new UserVideoListLoader();
                this._userVideoListLoader.addEventListener(Event.COMPLETE, getXMLSuccess);
                this._userVideoListLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoadIOErrorHandler);
                this._userVideoListLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoadIOErrorHandler);

                this._userVideoListLoader.getVideoList(this._uploadUserId, this._currentPage);
            }
        }

        /**
         *
         * @param event
         *
         */
        private function xmlLoadIOErrorHandler(event: ErrorEvent): void {
            (event.target as URLLoader).close();

            var targetId: String = "";
            if (this._myListId != null) {
                targetId = "mylist/" + this._myListId;
            } else if (this._channelId != null) {
                targetId = "channel/" + this._channelId + "/" + this._currentPage;
            } else if (this._communityId != null) {
                targetId = "community/" + this._communityId + "/" + this._currentPage;
            } else {
                targetId = "user/" + this._uploadUserId + "/video/" + this._currentPage;
            }

            LogManager.instance.addLog(DOWNLOAD_FAIL + ":" + targetId + ":" + event + ":" + event.target + ":" +
                                       event.text);
            trace(DOWNLOAD_FAIL + ":" + targetId + ":" + event + ":" + event.target + ":" + event.text);

            if (this._currentPage > 0 && this._retryCount < RETRY_COUNT_LIMIT) {
                this._retryCount++;
                LogManager.instance.addLog(DOWNLOAD_RETRY + ": Count: " + this._retryCount + "/" + RETRY_COUNT_LIMIT);
                setTimeout(this.loadRss, 60000);
                return;
            }

            dispatchEvent(new IOErrorEvent(DOWNLOAD_FAIL, false, false, event.text));
            close(false, false);
        }

        /**
         *
         * @param event
         *
         */
        private function getXMLSuccess(event: Event): void {
//			trace((event.target as URLLoader).data);

            try {
                var xml: XML = new XML((event.target as URLLoader).data);
                var items: XMLList = xml.child("channel")[0].child("item");
                var next: Boolean = items.length() > 0;
                if (this._xml == null) {
                    this._xml = xml;
                } else {
                    for each(var tmp: XML in items) {
                        if (tmp.name() == "item") {
                            this._xml.child("channel")[0].appendChild(tmp);
                        }
                    }
                }

                // default wait par page is set by 100ms.
                var wait: int = 100;
                if (next && this._currentPage > 0) {
                    if (this._communityId != null) {
                        // community page load limit is very severe
                        wait = this._currentPage % 5 === 0 ? 10000 : 1000;
                        wait += this._currentPage > 20 ? 5000 : 0;
                        LogManager.instance.addLog(DOWNLOAD_PROCESS_INPROGRESS + ": community/" + this._communityId +
                                                   "/" + this._currentPage);
                    } else if (this._channelId != null) {
                        LogManager.instance.addLog(DOWNLOAD_PROCESS_INPROGRESS + ": channel/" + this._uploadUserId +
                                                   "/" + this._currentPage);
                    } else if (this._uploadUserId != null) {
                        LogManager.instance.addLog(DOWNLOAD_PROCESS_INPROGRESS + ": user/" + this._uploadUserId + "/" +
                                                   this._currentPage);
                    }

                    setTimeout(this.loadRss, wait);
                    this._currentPage++;
                    this._retryCount = 0;
                    return;
                }

//			trace(DOWNLOAD_PROCESS_COMPLETE + ":" + event + ":" + xml);
                if (this._myListId != null) {
                    LogManager.instance.addLog(DOWNLOAD_PROCESS_COMPLETE + ": mylist/" + this._myListId);
                } else if (this._channelId != null) {
                    LogManager.instance.addLog(DOWNLOAD_PROCESS_COMPLETE + ": channel/" + this._channelId);
                } else if (this._communityId != null) {
                    LogManager.instance.addLog(DOWNLOAD_PROCESS_COMPLETE + ": community/" + this._communityId);
                } else {
                    LogManager.instance.addLog(DOWNLOAD_PROCESS_COMPLETE + ": user/" + this._uploadUserId);
                }

                dispatchEvent(new Event(DOWNLOAD_PROCESS_COMPLETE));
            } catch (e: *) {
                if (this._myListId != null) {
                    trace(DOWNLOAD_PROCESS_ERROR + ": mylist/" + this._myListId);
                    LogManager.instance.addLog(DOWNLOAD_PROCESS_ERROR + ": mylist/" + this._myListId);
                } else if (this._channelId != null) {
                    trace(DOWNLOAD_PROCESS_ERROR + ": channel/" + this._channelId);
                    LogManager.instance.addLog(DOWNLOAD_PROCESS_ERROR + ": channel/" + this._channelId);
                } else if (this._communityId != null) {
                    trace(DOWNLOAD_PROCESS_ERROR + ": community/" + this._communityId);
                    LogManager.instance.addLog(DOWNLOAD_PROCESS_ERROR + ": community/" + this._communityId);
                } else {
                    trace(DOWNLOAD_PROCESS_ERROR + ": user/" + this._uploadUserId);
                    LogManager.instance.addLog(DOWNLOAD_PROCESS_ERROR + ": user/" + this._uploadUserId);
                }
                dispatchEvent(new Event(DOWNLOAD_PROCESS_ERROR));
            }
        }

        /**
         *
         *
         */
        public function get xml(): XML {
            return this._xml;
        }

        /**
         *
         *
         */
        private function terminate(): void {
            this._channelId = null;
            this._myListId = null;
            this._communityId = null;
            this._uploadUserId = null;
            this._login = null;
            this._publicMyListLoader = null;
            this._channelLoader = null;
            this._userVideoListLoader = null;
        }

        /**
         * Loaderをすべて閉じます。
         *
         */
        public function close(isCancel: Boolean, isError: Boolean, event: ErrorEvent = null): void {

            //終了処理
            try {
                this._login.close();
                trace(this._login + " is closed.");
            } catch (error: Error) {
            }
            try {
                this._publicMyListLoader.close();
                trace(this._publicMyListLoader + " is closed.");
            } catch (error: Error) {
            }
            try {
                this._channelLoader.close();
                trace(this._channelLoader + " is closed.");
            } catch (error: Error) {
            }
            try {
                this._communityLoader.close();
                trace(this._communityLoader + " is closed.");
            } catch (error: Error) {
            }
            try {
                this._userVideoListLoader.close();
                trace(this._userVideoListLoader + " is closed.");
            } catch (error: Error) {
            }

            terminate();

            var eventText: String = "";
            if (event != null) {
                eventText = event.text;
            }
            if (isCancel && !isError) {
                dispatchEvent(new Event(DOWNLOAD_PROCESS_CANCELD));
            } else if (isCancel && isError) {
                dispatchEvent(new IOErrorEvent(DOWNLOAD_PROCESS_ERROR, false, false, eventText));
            }
        }

    }
}