package org.mineap.nndd.util {
    public class MyListUtil {

        public function MyListUtil() {
        }

        /**
         * 渡された文字列からマイリストIDを探して返します。
         *
         * @param string
         * @return
         *
         */
        public static function getMyListId(string: String): String {
            var matches: Array;

            // Case: mylist/[MyListID]
            //       myListId/[MyListID] (default MyList)
            if (matches = string.match(/^(?i:mylist(?:id)?)\/([1-9][0-9]*)$/)) {
                return matches[1];
            }

            // Case: http://www.nicovideo.jp/mylist/[MyListID]
            //       http://www.nicovideo.jp/my/mylist/#/[MyListID]
            //       https://www.nicovideo.jp/mylist/[MyListID]
            //       https://www.nicovideo.jp/my/mylist/#/[MyListID]
            if (matches = string.match(/^https?:\/\/www\.nicovideo\.jp\/(?:mylist|my\/mylist\/#)\/([1-9][0-9]*)$/)) {
                return matches[1];
            }

            return null;
        }

        /**
         *
         * @param string
         * @return
         *
         */
        public static function getUserUploadVideoListId(string: String): String {
            var matches: Array;

            // Case: user/[UserID]
            //       /user/[UserID]/mylist (from XML file)
            if (matches = string.match(/^\/?(?i:user)\/([1-9][0-9]*)/)) {
                return matches[1];
            }

            // Case: http://www.nicovideo.jp/user/[UserID]/video
            //       http://www.nicovideo.jp/user/[UserID]
            //       https://www.nicovideo.jp/user/[UserID]/video
            //       https://www.nicovideo.jp/user/[UserID]
            if (matches = string.match(/^https?:\/\/www\.nicovideo\.jp\/user\/([1-9][0-9]*)/)) {
                return matches[1];
            }

            return null;
        }


        /**
         *
         * @param string
         * @return
         *
         */
        public static function getChannelId(string: String): String {
            var matches: Array;

            // Case: channel/[ChannelID]
            if (matches = string.match(/^(?i:channel)\/([^\/]+)$/)) {
                return matches[1];
            }

            // Case: http://ch.nicovideo.jp/[ChannelID]
            //       https://ch.nicovideo.jp/[ChannelID]
            //       http://ch.nicovideo.jp/[ChannelID]/video
            //       https://ch.nicovideo.jp/[ChannelID]/video
            //       http://ch.nicovideo.jp/video/[ChannelID]
            //       https://ch.nicovideo.jp/video/[ChannelID]
            if (matches = string.match(/^https?:\/\/ch\.nicovideo\.jp\/(?:video\/)?([^\/]+)/)) {
                return matches[1];
            }

            return null;
        }

        /**
         *
         * @param url
         * @return
         */
        public static function getCommunityId(url: String): String {
            var matches: Array;

            // Case: community/[CommunityID]
            if (matches = url.match(/^(?i:community)\/([a-z0-9]+)$/)) {
                return matches[1];
            }

            // Case: http://com.nicovideo.jp/community/[CommunityID]
            //       https://com.nicovideo.jp/community/[CommunityID]
            //       http://com.nicovideo.jp/video/[CommunityID]
            //       https://com.nicovideo.jp/video/[CommunityID]
            if (matches = url.match(/^https?:\/\/com\.nicovideo\.jp\/(?:community|video)\/([a-z0-9]+)$/)) {
                return matches[1];
            }

            return null;
        }
    }
}