package org.mineap.nndd.server {
    import com.tilfin.airthttpd.server.HttpResponse;

    public interface IRequestProcess {
        /**
         *
         * リクエストに対応する処理を行った後、レスポンスに結果を格納します。
         *
         * @param requestXml
         * @param httpResponse
         *
         */
        function process(requestXml: XML, httpResponse: HttpResponse): void;

    }
}