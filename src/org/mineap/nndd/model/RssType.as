package org.mineap.nndd.model {
    public class RssType {

        public static const MY_LIST: RssType = new RssType("MY_LIST");

        public static const CHANNEL: RssType = new RssType("CHANNEL");

        public static const COMMUNITY: RssType = new RssType("COMMUNITY");

        public static const USER_UPLOAD_VIDEO: RssType = new RssType("USER_UPLOAD_VIDEO");

        private var value: String = null;

        public function RssType(value: String) {
            this.value = value;
        }

        public function toString(): String {
            return value;
        }

        public static function convertStrToRssType(typeStr: String): RssType {
            switch (typeStr) {
                case MY_LIST.value:
                    return MY_LIST;
                case CHANNEL.value:
                    return CHANNEL;
                case COMMUNITY.value:
                    return COMMUNITY;
                case USER_UPLOAD_VIDEO.value:
                    return USER_UPLOAD_VIDEO;
                default:
                    return null;
            }
        }

    }
}