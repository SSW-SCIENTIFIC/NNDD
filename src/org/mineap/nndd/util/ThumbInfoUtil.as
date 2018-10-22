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

            var patterns: Array = [];
            patterns.push(new RegExp("https?://www\\.nicovideo\\.jp/(mylist/[1-9][0-9]*)"));
            patterns.push(new RegExp("https?://www\\.nicovideo\\.jp/(user/[1-9][0-9]*)"));
            patterns.push(new RegExp("https?://ch\\.nicovideo\\.jp/(channel/ch[^\"]+)"));
            patterns.push(new RegExp("https?://com\\.nicovideo\\.jp/(community/co[^\"]+)"));

            var video_pattern: RegExp = new RegExp("https?://www\\.nicovideo\\.jp/watch/([^\"]+)");

            var fontsize_pattern: RegExp = new RegExp("size=\"(\\d+)\"", "ig");

            // 小さすぎるサイズを全置換
            text = text.replace(fontsize_pattern, function (): String {
                var str: String = arguments[0];
                if (arguments.length > 1 && arguments[1] != "") {
                    var size: int = int(arguments[1]);
                    if (size < 10) {
                        size = size + 8;
                        str = String(size);
                    }
                }
                return "size=\"" + size + "\"";
            });

            var returnString: String = text;
            returnString = returnString.replace(/<(?i:a\s+href)="([^"]+)"[^>]*?>.*?<\/(?i:a)>/g, function (): String {
                var url: String = arguments[1];
                var matches: Array = null;
                for each(var pattern: RegExp in patterns) {
                    matches = matches || url.match(pattern);
                    if (matches) {
                        myLists.push(matches[1]);
                        return "<a href=\"event:" + matches[1] + "\"><u><font color=\"#0000ff\">" + matches[1] + "</font></u></a>";
                    }
                }

                if (matches = url.match(video_pattern)) {
                    var videoId: String = matches[1];
                    return "<a href=\"event:watch/" + videoId + "\"><u><font color=\"#0000ff\">" + videoId + "</font></u></a>";
                }

                return arguments[0];
            });

            return returnString;
        }


    }
}