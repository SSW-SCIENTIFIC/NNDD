package org.mineap.nndd.util {
    import org.mineap.nicovideo4as.util.VideoTypeUtil;

    /**
     *
     *
     * @author shiraminekeisuke(MineAP)
     *
     */
    public class ThumbInfoUtil {
        public function ThumbInfoUtil() {
        }

        /**
         * 渡されたStringのマイリストID、ユーザーID、動画IDをNNDD用のHTML表現に置き換えて返します。
         * @param text
         * @return
         *
         */
        public static function encodeThumbInfo(text: String): String {

            var myLists: Array = [];
            // TODO: Better replacement
//            var linkPattern: RegExp = new RegExp(
//                    "<(?i:a)(?:\\s+[^\\s\"'>/=]+(?:\\s*=\\s*(?:[^\\s\"'=><`]+|'[^']*'|\"[^\"]*\"))?)*" +
//                    "(?:\\s+(?i:href)\\s*=\\s*([^\\s\"'=><`]+|'[^']*'|\"[^\"]*\"))" +
//                    "(?:\\s+[^\\s\"'>/=]+(?:\\s*=\\s*(?:[^\\s\"'=><`]+|'[^']*'|\"[^\"]*\"))?)*>.+?</(?i:a)>",
//                    "g"
//            );
//

            var myList_pattern: RegExp = new RegExp(
                "<(?i:a href)=\"http://www\\.nicovideo\\.jp/mylist/[1-9][0-9]*\"[^>]*>((?i:mylist)/[1-9][0-9]*)</(?i:a)>|((?i:mylist)/[1-9][0-9]*)",
                "g"
            );
            var user_pattern: RegExp = new RegExp(
                "<(?i:a href)=\"http://www\\.nicovideo\\.jp/user/[1-9][0-9]*\"[^>]*>((?i:user)/[1-9][0-9]*)</a>|((?i:user)/[1-9][0-9]*)",
                "g"
            );
            var videoId_pattern: RegExp = new RegExp("<(?i:a href)=\"http://www\\.nicovideo\\.jp/watch/[^\"]+\"[^>]*>([^<]+)</a>|" +
                                                     VideoTypeUtil.VIDEO_ID_WITHOUT_NUMONLY_SEARCH_PATTERN_STRING,
                                                     "g"
            );
            var channel_pattern: RegExp = new RegExp(
                "<(?i:a href)=\"https?://ch\\.nicovideo\\.jp/(channel/ch[^\"]+)\"[^>]*>[^<]+</a>|((?i:channel)/\\w+)",
                "g"
            );  // TODO
            var community_pattern: RegExp = new RegExp(
                "<(?i:a href)=\"https?://com\\.nicovideo\\.jp/(community/co[^\"]+)\"[^>]*>[^<]+</a>|((?i:co)[1-9][0-9]+)",
                "g"
            );

            var fontsize_pattern: RegExp = new RegExp("size=\"(\\d+)\"", "ig");

            // 小さすぎるサイズを全置換
            text = text.replace(fontsize_pattern, replFn_changeFontSize);

            function replFn_changeFontSize(): String {
                var str: String = arguments[0];
                if (arguments.length > 1 && arguments[1] != "") {
                    var size: int = int(arguments[1]);
                    if (size < 10) {
                        size = size + 8;
                        str = String(size);
                    }
                }
                return "size=\"" + size + "\"";
            }

            var returnString: String = text;
            returnString = returnString.replace(myList_pattern, replacer);
            returnString = returnString.replace(channel_pattern, replacer);
            returnString = returnString.replace(community_pattern, replacer);
            returnString = returnString.replace(user_pattern, replacer);

            function replacer(): String {
                var str: String = arguments[0];
                if (arguments.length > 1 && arguments[1] != "") {
                    str = arguments[1];
                }
                if (str.match(/^co[1-9][0-9]*$/i)) {
                    str = "community/" + str;
                }
                myLists.push(str);
                return "<a href=\"event:" + str + "\"><u><font color=\"#0000ff\">" + str + "</font></u></a>";
            }

            returnString = returnString.replace(videoId_pattern, replFN);

            function replFN(): String {

                var htmltag: String = arguments[0];
                var videoId: String = arguments[1];

                if (videoId != null && videoId == "") {
                    videoId = arguments[0];
                }

                //color="#0000ff"を見つけたときはスキップ
                if (videoId == "0000") {
                    return arguments[0];
                }

                //マイリストとして登録済みならスキップ
                // TODO この方法だとマイリストと同じ番号を持つ動画にたいしてはリンクが設定されないが、その可能性は低いので問題はないとする。
                for each(var mylist: String in myLists) {
                    var id: String = mylist.substring(7);
                    if (id == videoId) {
                        return arguments[0];
                    }
                }

                return "<a href=\"event:watch/" + videoId + "\"><u><font color=\"#0000ff\">" + videoId +
                       "</font></u></a>";

            }

            return returnString;

        }


    }
}