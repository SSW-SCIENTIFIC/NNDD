package org.mineap.nndd.server.process {
    import com.tilfin.airthttpd.server.HttpResponse;

    import org.mineap.nndd.LogManager;
    import org.mineap.nndd.model.RssType;
    import org.mineap.nndd.myList.MyListManager;
    import org.mineap.nndd.server.IRequestProcess;
    import org.mineap.nndd.server.ServerManager;

    /**
     * ID指定のマイリスト取得処理が呼ばれたときの処理
     *
     * @author shiraminekeisuke
     *
     */
    public class GetMyListByIdProcess implements IRequestProcess {
        public function GetMyListByIdProcess() {
        }

        public function process(requestXml: XML, httpResponse: HttpResponse): void {

            // ID指定マイリスト取得
            var rssTypeStr: String = requestXml.rss.@rssType;
            var rssId: String = requestXml.rss.@id;

            // 再生済みにセットされた動画があれば取得
            var playedVideoIds: Vector.<String> = new Vector.<String>();
            for each (var videoXML: XML in requestXml.rss.video) {
                if ("true" == videoXML.@played) {
                    playedVideoIds.push(videoXML.@id);
                }
            }

            var rssType: RssType = RssType.convertStrToRssType(rssTypeStr);

            if (playedVideoIds.length > 0 && ServerManager.instance.allowSyncMyListYetPlay) {
                MyListManager.instance.updatePlayedAndSave(rssId, rssType, playedVideoIds, true);
            }

            var xml: XML = MyListManager.instance.readLocalMyList(rssId, rssType);

            if (xml != null) {
                httpResponse.body = xml.toXMLString();
                httpResponse.statusCode = 200;
            }
            else {
                // NOT_FOUND
                httpResponse.statusCode = 404;
            }

            LogManager.instance.addLog("ID指定マイリスト取得要求:type=" + rssType + ", id=" + rssId + ", resCode=" + httpResponse.statusCode);

        }
    }
}