package org.mineap.nndd.util {
    import flash.events.Event;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    import flash.net.navigateToURL;

    import mx.controls.Alert;
    import mx.core.FlexGlobals;

    import org.mineap.nicovideo4as.WatchVideoPage;
    import org.mineap.nndd.LogManager;

    /**
     * ニコニコ動画以外のウェブサービスへのアクセスを行うユーティリティクラスです
     *
     * @author shiraminekeisuke(MineAP)
     *
     */
    public class WebServiceAccessUtil {
        public function WebServiceAccessUtil() {
        }

        public static function openNiconicoDougaForVideo(videoId: String): void {
            var url: String = null;
            if (videoId != null) {
                url = WatchVideoPage.WATCH_VIDEO_PAGE_URL + videoId;
                navigateToURL(new URLRequest(url));
                LogManager.instance.addLog("ウェブブラウザで開く:" + url);
            }
        }

        /**
         *
         * @return
         *
         */
        public static function openNicoSound(videoId: String): void {
            var watch: WatchVideoPage = new WatchVideoPage();
            watch.addEventListener(WatchVideoPage.WATCH_SUCCESS, function (event: Event): void {
                var url: String = watch.audioDownloadUrl;

                if (url == null) {
                    Alert.show("この動画はNicoSoundでダウンロードできません。", "情報");
                    FlexGlobals.topLevelApplication.activate();
                    LogManager.instance.addLog("この動画はNicoSoundに非対応:" + videoId);
                }
                else {
                    navigateToURL(new URLRequest(url));
                    LogManager.instance.addLog("NicoSoundで開く:" + url);
                }

            });
            watch.addEventListener(WatchVideoPage.WATCH_FAIL, function (event: Event): void {
                Alert.show("ダウンロードページを開けませんでした。\n" + event, "エラー");
                FlexGlobals.topLevelApplication.activate();
                LogManager.instance.addLog("NicoSoundで開くのに失敗:" + event);
            });
            watch.watchVideo(videoId, true);

        }

        /**
         *
         * @param videoId
         * @param title
         *
         */
        public static function addHatenaBookmark(videoId: String, title: String): void {
            var url: String = null;

            if (videoId != null) {
                url = "http://www.nicovideo.jp/watch/" + videoId;
                navigateToURL(new URLRequest("http://b.hatena.ne.jp/add?mode=confirm&is_bm=1&title=" + encodeURIComponent(title) + "&url=" + url));
                LogManager.instance.addLog("はてなダイアリーに登録:" + title + ":" + url);
            }
        }

        /**
         *
         * @param videoId
         * @param title
         *
         */
        public static function tweet(videoId: String, title: String): void {
            var tweet: String = "";
            var url: String = "";

            if (videoId != null) {
                url = "http://nico.ms/" + videoId + " #nicovideo #nndd #" + videoId;

                var index: int = title.indexOf("- [");
                if (index > 0) {
                    title = title.substr(0, index);
                }

                tweet = title + " " + url;

                var urlRequest: URLRequest = new URLRequest("https://twitter.com/");
                var variables: URLVariables = new URLVariables();
                variables.status = tweet;

                urlRequest.data = variables;

                navigateToURL(urlRequest);
                LogManager.instance.addLog("twitterでつぶやく:" + title);
            }
        }

    }
}