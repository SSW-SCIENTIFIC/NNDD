package org.mineap.nndd.server {
    import com.tilfin.airthttpd.server.HttpListener;

    import flash.errors.IllegalOperationError;

    import org.mineap.nndd.LogManager;

    /**
     * NNDDのサーバ機能を管理するクラスです
     *
     * @author shiraminekeisuke
     *
     */
    public class ServerManager {

        private static const manager: ServerManager = new ServerManager();

        private var httpListener: HttpListener = null;

        private var _allowVideo: Boolean = false;
        private var _allowMyList: Boolean = false;
        private var _allowSyncMyListYetPlay: Boolean = false;

        /**
         * 唯一の ServerManager のインスタンスを変えす。
         * @return
         *
         */
        public static function get instance(): ServerManager {
            return manager;
        }

        /**
         * コンストラクタ
         *
         */
        public function ServerManager() {
            if (manager != null) {
                throw new IllegalOperationError("ServerManagerはインスタンスを生成できません。");
            }
        }

        /**
         * 指定されたポート番号で通信の待ち受けを開始します。
         *
         * @param localPort
         * @param allowVideo
         * @param allowMyList
         * @return
         *
         */
        public function startServer(
            localPort: int,
            allowVideo: Boolean,
            allowMyList: Boolean,
            allowSyncMyListYetPlay: Boolean
        ): Boolean {
            stopServer();

            this.allowMyList = allowMyList;
            this.allowVideo = allowVideo;
            this.allowSyncMyListYetPlay = allowSyncMyListYetPlay;

            try {

                httpListener = new HttpListener(httpLogCallbackFunction);

                httpListener.service = new NNDDHttpService();
                httpListener.listen(localPort);

                LogManager.instance.addLog("他のNNDDからの通信待ち受けを開始しました:localPort=" + localPort);

                return true;

            } catch (error: Error) {
                LogManager.instance.addLog("他のNNDDからの通信待ち受けの開始に失敗:localPort=" + localPort + ", [" + error + "]");
                trace(error.getStackTrace());
            }

            return false;
        }

        /**
         *
         * @param msg
         * @return
         *
         */
        protected function httpLogCallbackFunction(msg: String): void {
            trace(msg);
        }

        /**
         * 通信の待ち受けを終了します。
         *
         */
        public function stopServer(): void {
            if (httpListener != null) {
                // 既にServerSocketが動いていたら一度閉じる
                try {
                    httpListener.shutdown();
                } catch (error: Error) {
                    trace(error.getStackTrace());
                }

                httpListener = null;

            }

            LogManager.instance.addLog("他のNNDDからの通信待ち受けを停止");

        }

        public function get allowVideo(): Boolean {
            return _allowVideo;
        }

        public function set allowVideo(value: Boolean): void {
            _allowVideo = value;
        }

        public function get allowMyList(): Boolean {
            return _allowMyList;
        }

        public function set allowMyList(value: Boolean): void {
            _allowMyList = value;
        }

        public function get allowSyncMyListYetPlay(): Boolean {
            return _allowSyncMyListYetPlay;
        }

        public function set allowSyncMyListYetPlay(value: Boolean): void {
            _allowSyncMyListYetPlay = value;
        }


    }
}