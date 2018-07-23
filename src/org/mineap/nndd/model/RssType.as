package org.mineap.nndd.model {
    public class RssType {

        public static const MY_LIST: RssType = new RssType("MY_LIST");

        public static const CHANNEL: RssType = new RssType("CHANNEL");

        public static const USER_UPLOAD_VIDEO: RssType = new RssType("USER_UPLOAD_VIDEO");

        private var value: String = null;

        public function RssType(value: String) {
            this.value = value;
        }

        public function toString(): String {
            return value;
        }

        public static function convertStrToRssType(typeStr: String): RssType {
            if (MY_LIST.value == typeStr) {
                return MY_LIST;
            }
            else if (CHANNEL.value == typeStr) {
                return CHANNEL;
            }
            else if (USER_UPLOAD_VIDEO.value == typeStr) {
                return USER_UPLOAD_VIDEO;
            }
            return null;
        }

    }
}