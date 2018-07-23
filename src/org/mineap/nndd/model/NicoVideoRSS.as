package org.mineap.nndd.model {
    import org.mineap.nndd.util.MyListUtil;


    /**
     * マイリストやチャネルなどの、RSSのアドレスを表現するクラスです。
     *
     * (v2.1では未使用)
     *
     * @author shiraminekeisuke (MineAP)
     *
     */
    public class NicoVideoRSS {

        /**
         * RSSのURLです<br>
         * ただし、URLとは限りません。URL以外にも、mylist/*****や、*****の形式である事があります。
         */
        public var url: String = "";

        /**
         * NNDD上で管理するためのRSSの名前です
         */
        public var name: String = "";

        /**
         * このマイリストオブジェクトがディレクトリを表すかどうかです。
         */
        public var isDir: Boolean = false;

        /**
         * 未読動画数
         */
        public var unPlayVideoCount: int = 0;

        /**
         * RSSに登録されている動画IDの一覧
         */
        private var videoIds: Object = new Object();

        /**
         * コンストラクタ。
         *
         * @param url
         * @param name
         * @param isDir
         * @param videoIds
         */
        public function NicoVideoRSS(url: String, name: String, isDir: Boolean = false, videoIds: Vector.<String> = null) {
            if (url != null) {
                this.url = url;
            }
            if (name != null) {
                this.name = name;
            }

            this.isDir = isDir;

            if (videoIds != null) {
                for each(var id: String in videoIds) {
                    videoIds[id] = id;
                }
            }
        }

        /**
         * このRSSのマイリストIDを返します
         * @return
         *
         */
        public function get id(): String {
            return MyListUtil.getMyListId(this.url);
        }

        /**
         * このマイリストオブジェクトに、指定された動画IDを登録します
         *
         * @param video
         *
         */
        public function addNNDDVideoId(videoId: String): void {
            if (videoId == null) {
                videoIds[videoId] = videoId;
            }
        }

        /**
         * このマイリストオブジェクトから、指定された動画IDを取り除きます
         *
         * @param videoId
         *
         */
        public function deleteNNDDVideoId(videoId: String): void {
            if (videoId == null) {
                delete videoIds[videoId];
            }
        }

        /**
         * このマイリストオブジェクトが保持する動画IDを全てクリアします
         *
         */
        public function clearNNDDVideoId(): void {
            videoIds = new Object();
        }

        /**
         * 指定された動画IDがこのマイリストに登録されているかどうか調べます
         *
         * @param videoId
         * @return
         *
         */
        public function contains(videoId: String): Boolean {
            if (videoIds[videoId] != null) {
                return true;
            }
            return false;
        }

    }
}