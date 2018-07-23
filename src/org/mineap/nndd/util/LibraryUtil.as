package org.mineap.nndd.util {
    import flash.filesystem.File;

    /**
     *
     * @author shiraminekeisuke
     *
     */
    public class LibraryUtil {
        /**
         *
         *
         */
        public function LibraryUtil() {
        }

        /**
         * LibraryManagerからNNDDオブジェクトを探すためのキーを返します。<br />
         * 動画IDが存在すれば動画IDを、存在しなければ拡張子を除いた動画のタイトルをかえします。
         *
         * @param videoTitle
         * @return
         */
        public static function getVideoKey(videoTitle: String): String {
            var videoId: String = PathMaker.getVideoID(videoTitle);
            if (videoId == null) {
                videoId = videoTitle;
                var index: int = videoTitle.lastIndexOf("/");
                if (index != -1) {
                    videoId = videoTitle.substring(index + 1);
                }
                //拡張子を取り除く
                index = videoId.lastIndexOf(".");
                if (index != -1) {
                    videoId = videoId.substring(0, index);
                }
            }
            return videoId;
        }

    }
}