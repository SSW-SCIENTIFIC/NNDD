package org.mineap.nndd.server {
    import org.mineap.nndd.LogManager;
    import org.mineap.nndd.server.process.GetMyListByIdProcess;
    import org.mineap.nndd.server.process.GetMyListProcess;
    import org.mineap.nndd.server.process.GetVideoByIdProcess;
    import org.mineap.nndd.server.process.GetVideoIdListProcess;

    /**
     *
     * @author shiraminekeisuke
     *
     */
    public class RequestProcessFactory {

        /**
         *
         *
         */
        public function RequestProcessFactory() {
            // nothing;
        }

        /**
         * 指定されたリクエストに対応する処理クラスを返します。リクエストに対応する処理クラスが存在しない場合はnullを返します。
         *
         * @param request
         * @return
         *
         */
        public static function createProcess(request: XML): IRequestProcess {

            if (request == null) {
                return null;
            }

            var type: String = request.@type;
            LogManager.instance.addLog("通信のリクエスト種別:" + type);

            if (type.indexOf(RequestType.GET_MYLIST_LIST.typeStr) != -1) {
                if (ServerManager.instance.allowMyList) {
                    return new GetMyListProcess();
                }
            }
            else if (type.indexOf(RequestType.GET_MYLIST_BY_ID.typeStr) != -1) {
                if (ServerManager.instance.allowMyList) {
                    return new GetMyListByIdProcess();
                }
            }
            else if (type.indexOf(RequestType.GET_VIDEO_ID_LIST.typeStr) != -1) {
                if (ServerManager.instance.allowVideo) {
                    return new GetVideoIdListProcess();
                }
            }
            else if (type.indexOf(RequestType.GET_VIDEO_BY_ID.typeStr) != -1) {
                if (ServerManager.instance.allowVideo) {
                    return new GetVideoByIdProcess();
                }
            }
            else {
                // NOT_FOUND
            }

            return null;

        }


    }
}