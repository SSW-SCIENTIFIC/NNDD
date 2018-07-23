package org.mineap.nndd.myList {
    import org.mineap.nndd.model.RssType;
    import org.mineap.nndd.util.MyListUtil;
    import org.mineap.util.config.ConfigIO;
    import org.mineap.util.config.ConfigManager;

    /**
     * マイリストの履歴を保持するクラス。
     *
     * @author shiraminekeisuke(MineAP)
     *
     */
    public class MyListHistoryManager {

        private static const manager: MyListHistoryManager = new MyListHistoryManager();

        private var maxHistoryCount: int = 10;

        private var history: Vector.<MyList> = new Vector.<MyList>();

        /**
         *
         *
         */
        public function MyListHistoryManager() {
            if (manager != null) {
                throw new ArgumentError("MyListHistoryManagerはインスタンス化できません。");
            }

            for (var i: int = 0; i < 10; i++) {
                var name: String = ConfigManager.getInstance().getItem("myListHistoryName" + i);
                var url: String = ConfigManager.getInstance().getItem("myListHistoryUrl" + i);

                if (url != null && url.length > 0) {
                    history.push(new MyList(url, name, false, null));
                } else {
                    break;
                }

            }
        }

        /**
         * シングルトンパターン
         *
         * @return
         *
         */
        public static function get instace(): MyListHistoryManager {
            return manager;
        }

        /**
         *
         * @param myList
         *
         */
        public function addHistory(myList: MyList): void {
            if (myList == null) {
                return;
            }
            if (myList.isDir) {
                return;
            }
            if (myList.id == null) {
                return;
            }

            // すでに登録済みでないかチェック
            var exist: Boolean = false;
            var index: int = 0;
            for each (var addedItem: MyList in history) {
                if (myList.idWithPrefix == addedItem.idWithPrefix) {
                    exist = true;
                    break;
                }
                index++;
            }

            // 重複した項目があったら削除
            if (exist) {
                history.splice(index, 1);
            }

            // 先頭に追加
            history.splice(0, 0, myList);


            // サイズを10以下にする
            while (true) {
                if (history.length > 10) {
                    history.splice(-1, 1);
                } else {
                    break;
                }
            }

            saveHistory();

        }

        /**
         * 履歴を返します。
         * @return
         *
         */
        public function getHistory(): Vector.<MyList> {
            var tempHistory: Vector.<MyList> = new Vector.<MyList>();

            for each(var myList: MyList in history) {
                tempHistory.push(new MyList(myList.myListUrl, myList.myListName, false, null));
            }

            return tempHistory;

        }

        /**
         * 履歴を削除します
         *
         */
        public function clearHistory(): void {
            history.splice(0, history.length);
            saveHistory();
        }

        /**
         *
         *
         */
        public function saveHistory(): void {
            for (var i: int = 0; i < history.length; i++) {
                var myList: MyList = history[i];
                ConfigManager.getInstance().setItem("myListHistoryName" + i, myList.myListName);
                ConfigManager.getInstance().setItem("myListHistoryUrl" + i, myList.myListUrl);
            }

            ConfigManager.getInstance().save();

        }

    }
}