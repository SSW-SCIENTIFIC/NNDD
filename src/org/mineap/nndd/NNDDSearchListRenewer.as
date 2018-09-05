package org.mineap.nndd {
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.HTTPStatusEvent;
    import flash.events.IOErrorEvent;

    import mx.collections.ArrayCollection;

    import org.mineap.nicovideo4as.Login;
    import org.mineap.nicovideo4as.analyzer.SearchResultAnalyzer;
    import org.mineap.nicovideo4as.loader.api.ApiSearchAccess;
    import org.mineap.nicovideo4as.model.search.SearchOrderType;
    import org.mineap.nicovideo4as.model.search.SearchResultItem;
    import org.mineap.nicovideo4as.model.search.SearchSortType;
    import org.mineap.nicovideo4as.model.search.SearchType;
    import org.mineap.nndd.library.LibraryManagerBuilder;
    import org.mineap.nndd.model.NNDDSearchSortType;
    import org.mineap.nndd.model.NNDDVideo;
    import org.mineap.nndd.util.NumberUtil;

    /**
     *
     * @author shiraminekeisuke
     *
     */
    public class NNDDSearchListRenewer extends EventDispatcher {

        public static const RENEW_SUCCESS: String = "RenewSuccess";
        public static const RENEW_FAIL: String = "RenewFail";


        private var _login: Login = new Login();

        private var _searchLoader: ApiSearchAccess = new ApiSearchAccess();

        private var _user: String;

        private var _password: String;

        private var _word: String;

        private var _sort: int = 0;

        private var _order: int = 0;

        private var _page: int = 1;

        private var _searchType: SearchType = SearchType.SEARCH;

        private var _result: SearchResultAnalyzer;

        public function NNDDSearchListRenewer() {
        }


        public function renew(
            user: String,
            password: String,
            word: String,
            searchType: SearchType,
            sort: int,
            order: int,
            page: int
        ): void {

            LogManager.instance.addLog("検索を開始します(word:" + word + ", sort:" + sort + ", order:" + order + ", page:" +
                                       page + ")");

            this._user = user;
            this._password = password;
            this._word = word;
            this._sort = sort;
            this._order = order;
            this._page = page;
            this._searchType = searchType;

            login();
        }

        private function login(): void {

            this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccessEventHandler);
            this._login.addEventListener(Login.NO_LOGIN, loginSuccessEventHandler);
            this._login.addEventListener(Login.LOGIN_FAIL, failEventHandler);

            this._login.login(this._user, this._password);

        }

        private function loginSuccessEventHandler(event: Event): void {

            this._searchLoader.addEventListener(Event.COMPLETE, loadCompleteEventHandler);
            this._searchLoader.addEventListener(
                HTTPStatusEvent.HTTP_RESPONSE_STATUS,
                function (event: HTTPStatusEvent): void {
                    trace(event);
                    LogManager.instance.addLog("\t\t" + event.type + ", status=" + event.status);
                }
            );
            this._searchLoader.addEventListener(IOErrorEvent.IO_ERROR, failEventHandler);

            var sort: SearchSortType = NNDDSearchSortType.convertSortTypeNumToN4A(this._sort);
            var order: SearchOrderType = NNDDSearchSortType.convertSortOrderTypeNumToN4A(this._order);

            LogManager.instance.addLog("検索APIへアクセス中...");

            this._searchLoader.search(_searchType, encodeURIComponent(_word), _page, sort, order);
        }

        private function loadCompleteEventHandler(event: Event): void {

            try {

                var serachResutlAnalyzer: SearchResultAnalyzer = new SearchResultAnalyzer(this._searchLoader.data);

                _result = serachResutlAnalyzer;

                LogManager.instance.addLog("検索完了");

                close();
                dispatchEvent(new Event(RENEW_SUCCESS));

            } catch (error: Error) {
                LogManager.instance.addLog("検索失敗:" + error);
                trace(error);
                close();
                dispatchEvent(new ErrorEvent(RENEW_FAIL, false, false, error.message));
            }

        }

        private function failEventHandler(event: Event): void {
            LogManager.instance.addLog("検索失敗:" + event);
            trace(event);
            close();
            dispatchEvent(new ErrorEvent(RENEW_FAIL, false, false, event.toString()));
        }

        public function close(): void {
            try {
                this._login.close();
            } catch (error: Error) {
                error.getStackTrace();
            }

            try {
                this._searchLoader.close();
            } catch (error: Error) {
                error.getStackTrace();
            }
        }

        public function get result(): SearchResultAnalyzer {
            return this._result;
        }

        public function createSearchList(): ArrayCollection {
            var arrayCollection: ArrayCollection = new ArrayCollection();

            var index: int = 0;

            for each(var searchItem: SearchResultItem in this._result.itemList) {

                index++;

                var videoId: String = searchItem.videoId;
                var videoCondition: String = "";
                var video: NNDDVideo = LibraryManagerBuilder.instance.libraryManager.isExist(searchItem.videoId);
                var localURL: String;
                if (video != null) {
                    localURL = video.getDecodeUrl();
                    if (video.isEconomy) {
                        videoCondition = "動画(低画質)保存済\n右クリックから再生できます。";
                    } else {
                        videoCondition = "動画保存済\n右クリックから再生できます。";
                    }
                }

                var videoStatus: String = "再生:" + NumberUtil.addComma(String(searchItem.playCount)) + " コメント:" +
                                          NumberUtil.addComma(String(searchItem.commentCount)) + "\nマイリスト:" +
                                          NumberUtil.addComma(String(searchItem.myListCount)) + "\n" +
                                          searchItem.lastResBody;

                arrayCollection.addItem({
                                            dataGridColumn_ranking: index + 32 * (this._page - 1),
                                            dataGridColumn_preview: searchItem.thumbImgUrl,
                                            dataGridColumn_videoName: searchItem.title + "\n    再生時間 " +
                                                                      searchItem.videoLength + "\n    投稿日時 " +
                                                                      searchItem.contribute,
                                            dataGridColumn_videoInfo: videoStatus,
                                            dataGridColumn_condition: videoCondition,
                                            dataGridColumn_videoPath: localURL,
                                            dataGridColumn_nicoVideoUrl: "http://www.nicovideo.jp/watch/" +
                                                                         searchItem.videoId
                                        });

            }

            return arrayCollection;

        }

    }
}