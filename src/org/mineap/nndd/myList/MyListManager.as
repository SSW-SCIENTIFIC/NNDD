package org.mineap.nndd.myList {
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.filesystem.File;

    import mx.controls.Alert;

    import org.mineap.nicovideo4as.util.HtmlUtil;
    import org.mineap.nndd.FileIO;
    import org.mineap.nndd.LogManager;
    import org.mineap.nndd.Message;
    import org.mineap.nndd.NNDDMyListLoader;
    import org.mineap.nndd.library.ILibraryManager;
    import org.mineap.nndd.library.LibraryManagerBuilder;
    import org.mineap.nndd.model.MyListSortType;
    import org.mineap.nndd.model.NNDDVideo;
    import org.mineap.nndd.model.RssType;
    import org.mineap.nndd.util.MyListUtil;
    import org.mineap.nndd.util.PathMaker;
    import org.mineap.nndd.util.TreeDataBuilder;
    import org.mineap.util.config.ConfUtil;
    import org.mineap.util.config.ConfigManager;

    /**
     * MyListManager.as<br>
     * MyListManagerクラスは、マイリストを管理するクラスです。<br>
     *
     * @author shiraminekeisuke(MineAP)
     *
     */
    public class MyListManager extends EventDispatcher {

        public static const MYLIST_RENEW_COMPLETE: String = "MylistRenewComplete";

        /**
         * マイリスト名とマイリストオブジェクトのMapです
         */
        private var _myListName_MyList_Map: Object = new Object();

        /**
         * 動画IDとマイリストIDのMapです
         */
        private var _videoId_myListIds_map: Object = new Object();

        /**
         *
         */
        private var _libraryManager: ILibraryManager;

        /**
         *
         */
        private var _tree_MyList: Array;

        /**
         *
         */
        private var _logManager: LogManager;

        /**
         *
         */
        private var _nnddMyListLoader: NNDDMyListLoader = null;

        /**
         *
         */
        private var _myListGroupLoader: NNDDMyListGroupLoader;

        /**
         *
         */
        public var lastTitle: String = "";

        /**
         * 唯一のMyListManagerのインスタンス
         */
        private static const _myListManager: MyListManager = new MyListManager();

        /**
         * コンストラクタ
         *
         */
        public function MyListManager() {
            if (_myListManager != null) {
                throw new ArgumentError("MyListManagerはインスタンス化できません");
            }
        }

        /**
         * シングルトンパターン
         * @return
         *
         */
        public static function get instance(): MyListManager {
            return MyListManager._myListManager;
        }

        /**
         *
         * @param tree_myList
         *
         */
        public function initialize(tree_myList: Array): void {
            this._tree_MyList = tree_myList;

            this._libraryManager = LibraryManagerBuilder.instance.libraryManager;
            this._logManager = LogManager.instance;

        }

        /**
         * マイリストを上書きします。
         *
         * @param myListUrl マイリストのURL
         * @param myListName マイリストの名前
         * @param isDir ディレクトリかどうか
         * @param isSave 上書き後保存するかどうか
         * @param oldName マイリストの古い名前
         * @param children 上書き対象のマイリストの子供(対象のマイリストがディレクトリの際に指定する)
         * @return 上書きしたマイリストに対応するツリー表示用のオブジェクト
         *
         */
        public function updateMyList(myListUrl: String, myListName: String, isDir: Boolean, isSave: Boolean, oldName: String, children: Array = null): Object {

            var myList: MyList = new MyList(myListUrl, myListName, isDir);
            var object: Object = searchByName(oldName, this._tree_MyList);

            myList.type = checkType(myListUrl);

            delete this._myListName_MyList_Map[oldName];

            var builder: TreeDataBuilder = new TreeDataBuilder();
            var folder: Object = builder.getFolderObject(myListName);

            object.label = myListName;
            if (children != null) {
                object.children = children;
            }

            this._myListName_MyList_Map[myListName] = myList;

            if (isSave) {
                this.saveMyListSummary(this._libraryManager.systemFileDir);
            }

            // マイリストの登録済み動画IDを更新
            updateMyListVideoId(myList);

            return object;
        }

        /**
         *
         * @param name 指定された名前の項目をマイリストのツリーから探して返します。
         * @return
         *
         */
        public function search(name: String): Object {
            return searchByName(name, this._tree_MyList);
        }

        /**
         * 指定された名前を持つオブジェクト(Leaf)を、渡されたオブジェクト(tree)の中から探します。
         *
         * @param myListName 探したいLeafの名前
         * @param array 探す対象のtree
         * @return
         *
         */
        public function searchByName(myListName: String, array: Array): Object {
            for (var index: int = 0; index < array.length; index++) {

                var object: Object = array[index];
                if (object.hasOwnProperty("children")) {

                    if (object.label == myListName) {
                        return object;
                    } else {
                        //フォルダのなかの項目かもしれない。探す。
                        var tempObject: Object = searchByName(myListName, object.children);
                        if (tempObject != null) {
                            return tempObject;
                        }
                    }
                } else {
                    //ファイル
                    if (object.label == myListName) {
                        return object;
                    }
                }

            }
            return null;
        }


        /**
         * マイリストを追加します。同名のマイリスト名は追加できません。
         *
         * @param myListUrl
         * @param myListName
         * @param isDir
         * @param isSave
         * @param index
         * @param children ディレクトリを追加した際に同時に追加する子。
         * @return
         *
         */
        public function addMyList(myListUrl: String, myListName: String, isDir: Boolean, isSave: Boolean, index: int = -1, children: Array = null): Object {
            var exsits: Boolean = false;
            var myList: MyList = new MyList(myListUrl, myListName, isDir);

            myList.type = checkType(myListUrl);

            var addedTreeObject: Object = null;

            if (this._myListName_MyList_Map[myListName] != null) {
                exsits = true;
            }

            if (!exsits) {

                var builder: TreeDataBuilder = new TreeDataBuilder();

                if (isDir) {

                    /* フォルダのとき */
                    var folder: Object = builder.getFolderObject(myListName);
                    if (children != null) {
                        folder.children = children;
                    }

                    if (index == -1) {
                        this._tree_MyList.push(folder);
                    } else {
                        this._tree_MyList.splice(index, 0, folder);
                    }
                    this._myListName_MyList_Map[myListName] = myList;

                    addedTreeObject = folder;

                } else {

                    /* マイリストのとき */
                    var file: Object = builder.getFileObject(myListName);

                    if (index == -1) {
                        this._tree_MyList.push(file);
                    } else {
                        this._tree_MyList.splice(index, 0, file);
                    }
                    this._myListName_MyList_Map[myListName] = myList;

                    addedTreeObject = file;

                    // マイリストの登録済み動画IDを更新
                    updateMyListVideoId(myList);

                }

                if (isSave) {
                    this.saveMyListSummary(this._libraryManager.systemFileDir);
                }

                return addedTreeObject;
            } else {
                return null;
            }

        }


        /**
         * 指定された名前のマイリストが存在するかどうかを返します。
         * @param myListName
         * @return
         *
         */
        public function isExists(myListName: String): Boolean {

            var object: Object = this._myListName_MyList_Map[myListName];
            if (object != null) {
                return true;
            }
            return false;
        }

        /**
         *
         * @param rssId
         * @param rssType
         * @return
         *
         */
        public function isExistsForId(rssId: String, rssType: RssType): Boolean {
            for each(var myList: MyList in this._myListName_MyList_Map) {
                if (myList.id == rssId && rssType == myList.type) {
                    return true;
                }
            }
            return false;
        }

        /**
         * マイリストを削除します。
         *
         * @param myListName
         * @return
         *
         */
        public function removeMyList(myListName: String, isSave: Boolean): Object {
            var deletedObject: Object = deleteMyListItemFromTree(myListName, this._tree_MyList);
            if (deletedObject != null) {
                if (isSave) {
                    this.saveMyListSummary(this._libraryManager.systemFileDir);
                }
                delete this._myListName_MyList_Map[myListName];
                return deletedObject;
            }
            return null;
        }

        /**
         * 指定されたTreeのデータプロバイダであるArrayからmyListNameを探して削除します。
         * @param myListName
         * @param myListArray
         * @return
         *
         */
        public function deleteMyListItemFromTree(myListName: String, myListArray: Array): Object {
            for (var index: int = 0; index < myListArray.length; index++) {

                var object: Object = myListArray[index];
                if (object.hasOwnProperty("children") && object.children != null) {

                    if (object.label == myListName) {
                        //フォルダそのものを消す
                        return myListArray.splice(index, 1)[0];

                    } else {
                        //フォルダのなかの項目かもしれない。探す。
                        var deleteObject: Object = deleteMyListItemFromTree(myListName, object.children);
                        if (deleteObject != null) {
                            return deleteObject;
                        }
                    }
                } else {
                    //ファイル
                    if (object.label == myListName) {

                        return myListArray.splice(index, 1)[0];
                    }
                }

            }
            return null;
        }

        /**
         * URLを返します。ただし、http://〜で始まるとは限りません。マイリストの番号である可能性もあります。
         * @param myListName
         * @return
         *
         */
        public function getUrl(myListName: String): String {
            var myList: MyList = MyList(this._myListName_MyList_Map[myListName]);
            if (myList == null || myList.isDir) {
                return "";
            }
            return myList.myListUrl;
        }

        /**
         * マイリストのタイトルを返します。
         * @param index
         * @return
         *
         */
        public function getMyListName(index: int): String {
            var object: Object = this._tree_MyList[index];
            if (object.hasOwnProperty("children")) {
                return this._tree_MyList[index].label;
            } else {
                return this._tree_MyList[index];
            }
        }

        /**
         * 指定されたマイリストがディレクトリかどうかを返します。
         *
         * @param myListName
         * @return
         *
         */
        public function getMyListIdDir(myListName: String): Boolean {
            var myList: MyList = this._myListName_MyList_Map[myListName];
            if (myList == null) {
                return false;
            }

            return myList.isDir;
        }

        /**
         * 指定された名前のマイリストについて、未再生動画数を返します。
         *
         * @param myListName
         * @return
         *
         */
        public function getMyListUnPlayVideoCount(myListName: String): int {
            var myList: MyList = this._myListName_MyList_Map[myListName];
            if (myList == null) {
                return 0;
            }

            return myList.unPlayVideoCount;
        }

        /**
         * マイリストに動画を追加します。(マイリスト一覧情報XMLから読み込む用)
         *
         * @param xml
         * @param myListArray
         * @param myListMap
         *
         */
        public function addMyListItemFromXML(xml: XML, myListArray: Array, myListMap: Object): void {

            for each(var temp: XML in xml.children()) {

                var name: String = decodeURIComponent(String(temp.@name));
                var myList: MyList = null;

                var builder: TreeDataBuilder = new TreeDataBuilder();

                if (temp.@isDir != null && temp.@isDir != undefined && temp.@isDir == "true") {
                    //ディレクトリの時。

                    var folder: Object = builder.getFolderObject(name);

                    myList = new MyList("", name, true);
                    myListArray.push(folder);
                    myListMap[name] = myList;

                    if (temp.children().length() > 0) {
                        addMyListItemFromXML(temp, folder.children, myListMap);
                    }
                } else {
                    var url: String = decodeURIComponent(String(temp.@url));
                    if (url == null || url == "") {
                        url = decodeURIComponent(String(temp.text()));
                    }

                    var file: Object = builder.getFileObject(name);
                    file.unPlayVideoCount = MyListManager.instance.getMyListUnPlayVideoCount(name);

                    myList = new MyList(url, name);
                    if ((temp.@isChannel != null && temp.@isChannel == "true") || (url != null && url.indexOf("channel/") != -1)) {
                        myList.type = RssType.CHANNEL;
                    }
                    if ((temp.@type != null && temp.@type == RssType.CHANNEL.toString())
                            || (url != null && url.indexOf("channel/") != -1)) {
                        myList.type = RssType.CHANNEL;
                    }
                    if ((temp.@type != null && temp.@type == RssType.USER_UPLOAD_VIDEO.toString())
                            || (url != null && url.indexOf("user/") != -1)) {
                        myList.type = RssType.USER_UPLOAD_VIDEO;
                    }

                    myListArray.push(file);
                    myListMap[name] = myList;

                    updateMyListVideoId(myList);
                }
            }

        }

        /**
         * 指定されたMyListオブジェクトに対応する動画IDを登録して返します
         *
         * @param myListId
         *
         */
        private function updateMyListVideoId(myList: MyList): MyList {
            if (myList == null) {
                return null;
            }

            myList.clearNNDDVideoId();

            var type: RssType = checkType(myList.myListUrl);

            /* 動画IDをマイリストに登録 */
            var myVideos: Vector.<NNDDVideo> = readLocalMyListByNNDDVideo(myList.id, type);
            for each(var tempVideo: NNDDVideo in myVideos) {
                myList.addNNDDVideoId(tempVideo.key);

                /* 動画IDとマイリストIDのマップも作る */
                setVideoId_MyListId_Map(tempVideo.key, myList.id, type);

            }
            trace(type.toString() + ":" + myList.id + "に登録されている動画:" + myVideos.length);
            LogManager.instance.addLog(type.toString() + ":" + myList.id + "に登録されている動画のチェック完了:" + myVideos.length);

            return myList;
        }

        /**
         * 指定されたVideoIdをキーに、myListIdを videoId_myListId マップに登録します。
         * @param videoId
         * @param myListId
         *
         */
        private function setVideoId_MyListId_Map(videoId: String, myListId: String, type: RssType): void {
            switch (type) {
                case RssType.CHANNEL:
                    myListId = "channel/" + myListId;
                    break;
                case RssType.COMMUNITY:
                    myListId = "community/" + myListId;
                    break;
                case RssType.USER_UPLOAD_VIDEO:
                    myListId = "user/" + myListId;
                    break;
                case RssType.MY_LIST:
                    myListId = "myList/" + myListId;
                    break;
            }

            var myListIds: Vector.<String> = _videoId_myListIds_map[videoId];
            if (myListIds == null) {
                myListIds = new Vector.<String>();
            }

            var exist: Boolean = false;
            for each(var tempMyListId: String in myListIds) {
                if (myListId == tempMyListId) {
                    exist = true;
                    break;
                }
            }
            if (!exist) {
                myListIds.push(myListId);
            }

            _videoId_myListIds_map[videoId] = myListIds;
        }

        /**
         * 指定されたディレクトリのマイリストの一覧を読み込みます。
         *
         * @param dir
         *
         */
        public function readMyListSummary(dir: File = null): Boolean {

            if (dir == null) {
                dir = this._libraryManager.systemFileDir;
            }

            var saveFile: File = new File(dir.url + "/myLists.xml");

            if (saveFile.exists) {

                var fileIO: FileIO = new FileIO(LogManager.instance);
                var xml: XML = fileIO.loadXMLSync(saveFile.url, true);

                _tree_MyList.splice(0, _tree_MyList.length);
                _myListName_MyList_Map = new Object();

                addMyListItemFromXML(xml, _tree_MyList, _myListName_MyList_Map);

                _logManager.addLog("マイリスト一覧の読み込み完了:" + saveFile.nativePath);

                initScheduler();

                return true;

            } else {
                _logManager.addLog("マイリスト一覧が存在しません:" + saveFile.nativePath);

                return false;
            }
        }

        /**
         * マイリストのソート状態を保存します。
         *
         * @param myListName
         * @param myListSortType
         *
         */
        public function setMyListSortType(myListName: String, myListSortType: MyListSortType): void {

            var file: File = new File(LibraryManagerBuilder.instance.libraryManager.systemFileDir.url + "/myLists.xml");

            if (file.exists) {
                var fileIO: FileIO = new FileIO(LogManager.instance);
                var xml: XML = fileIO.loadXMLSync(file.url, true);

                var xmlList: XMLList = xml.children();
                var myList: XML = searchXMLFromMyListXML(xmlList, myListName);

                if (myList != null) {
                    myList.@sortFiledName = decodeURIComponent(myListSortType.sortFiledName);
                    myList.@sortFiledDescending = myListSortType.sortFiledDescending;

                    fileIO.saveXMLSync(file, xml);
                }
            }

        }

        /**
         * XMLから指定された名前のマイリスト(XML)を探します
         *
         * @return
         *
         */
        private function searchXMLFromMyListXML(xmlList: XMLList, targetName: String): XML {
            for each(var myList: XML in xmlList) {

                if ("true" == myList.@isDir) {
                    var xml: XML = searchXMLFromMyListXML(myList.children(), targetName);
                    if (xml != null) {
                        return xml;
                    }

                } else {
                    if (decodeURIComponent(myList.@name) == targetName) {
                        return myList;
                    }
                }
            }
            return null;
        }


        /**
         * 指定された名前のマイリストから、当該マイリストのソート種別を取得します。
         *
         * @param myListName
         * @return
         *
         */
        public function getMyListSortType(myListName: String): MyListSortType {

            var file: File = LibraryManagerBuilder.instance.libraryManager.systemFileDir.resolvePath("myLists.xml");

            var name: String = null;
            var descending: Boolean = false;

            if (file.exists) {
                var fileIO: FileIO = new FileIO(LogManager.instance);
                var xml: XML = fileIO.loadXMLSync(file.url, true);

                var xmls: XMLList = xml.children();

                var sortType: MyListSortType = seachSortTypeFromXML(xmls, myListName);

                if (sortType != null) {
                    name = sortType.sortFiledName;
                    descending = sortType.sortFiledDescending;
                }
            }

            return new MyListSortType(name, descending);
        }

        /**
         * 引数で指定されたXMLListから、targetNameで指定された名称のMyListSortTypeを探して返します。
         *
         * @param xmlList
         * @param targetName
         * @return
         *
         */
        private function seachSortTypeFromXML(xmlList: XMLList, targetName: String): MyListSortType {
            for each(var myList: XML in xmlList) {

                if ("true" == myList.@isDir) {
                    var subList: XMLList = myList.children();
                    var sortType: MyListSortType = seachSortTypeFromXML(subList, targetName);

                    if (sortType != null) {
                        return sortType;
                    }

                } else {

                    var tempName: String = null;
                    try {
                        tempName = decodeURIComponent(myList.@name);
                    } catch (error: Error) {
                        tempName = myList.@name;
                    }

                    if (tempName == targetName) {
                        var name: String = myList.@sortFiledName;
                        var descending: Boolean = ConfUtil.parseBoolean(myList.@sortFiledDescending.toString());
                        return new MyListSortType(name, descending);
                    }
                }
            }

            return null;
        }

        /**
         * マイリスト自動更新用のスケジューラを初期化します
         *
         */
        public function initScheduler(): void {

            MyListRenewScheduler.instance.myListReset();

            for each(var myList: MyList in this._myListName_MyList_Map) {
                MyListRenewScheduler.instance.addMyList(myList);
            }
        }


        /**
         * 渡されたXMLに渡されたマイリスト名順にマイリストを追加します。
         *
         * @param xml
         * @param myListNameArray
         * @param myListMap
         * @return
         *
         */
        public function addMyListItemToXML(xml: XML, myListNameArray: Array, myListMap: Object): XML {

            for (var i: int = 0; i < myListNameArray.length; i++) {

                var myList: MyList = myListMap[myListNameArray[i].label];
                var myListItem: XML = <myList/>;

                if (myList != null) {

                    var myListSortType: MyListSortType = getMyListSortType(myList.myListName);

                    if (myList.isDir) {

                        //ディレクトリの時
                        myList = myListMap[myListNameArray[i].label];

                        myListItem.@url = "";
                        myListItem.@name = encodeURIComponent(myList.myListName);
                        myListItem.@isDir = true;

                        if (myListSortType.sortFiledName != null) {
                            myListItem.@sortFiledName = encodeURIComponent(myListSortType.sortFiledName);
                            myListItem.@sortFiledDescending = myListSortType.sortFiledDescending;
                        }

                        var array: Array = myListNameArray[i].children;
                        if (array != null && array.length >= 1) {
                            myListItem = addMyListItemToXML(myListItem, array, myListMap);
                        }

                    } else {

                        myListItem.@url = encodeURIComponent(myList.myListUrl);
                        myListItem.@name = encodeURIComponent(myList.myListName);
                        myListItem.@type = myList.type.toString();
                        myListItem.@isDir = false;

                        if (myListSortType.sortFiledName != null) {
                            myListItem.@sortFiledName = encodeURIComponent(myListSortType.sortFiledName);
                            myListItem.@sortFiledDescending = myListSortType.sortFiledDescending;
                        }
                    }


                    xml.appendChild(myListItem);
                }
            }

            return xml;
        }


        /**
         * マイリストの一覧情報を保持するXMLを指定されたディレクトリに保存します
         *
         * @param dir
         *
         */
        public function saveMyListSummary(dir: File): void {

            var xml: XML = <myLists/>;
            xml = addMyListItemToXML(xml, this._tree_MyList, this._myListName_MyList_Map);

            var saveFile: File = new File(dir.url + "/myLists.xml");

            var fileIO: FileIO = new FileIO(_logManager);
            fileIO.addFileStreamEventListener(Event.COMPLETE, function (event: Event): void {
                _logManager.addLog("マイリスト一覧を保存:" + dir.nativePath);
                trace(event);
                dispatchEvent(event);
            });
            fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function (event: IOErrorEvent): void {
                _logManager.addLog("マイリスト一覧の保存に失敗:" + dir.nativePath + ":" + event);
                trace(event + ":" + dir.nativePath);
                dispatchEvent(event);
            });
            fileIO.saveXMLSync(saveFile, xml);

        }

        /**
         * 指定されたxmlをマイリストとして保存します。
         *
         * @param myListId
         * @param type
         * @param xml
         * @param savedXMLprecedence 保存済みのXMLの既読/未読を優先するかどうか。trueの場合優先する。falseの場合は引数で渡した既読/未読を優先する。
         *
         */
        public function saveMyList(myListId: String, type: RssType, xml: XML, savedXMLprecedence: Boolean): void {

            try {

                var file: File = this._libraryManager.systemFileDir;

                switch (type) {
                    case RssType.CHANNEL:
                        _logManager.addLog("チャンネル(" + myListId + ")を保存中...");
                        file = new File(file.url + "/channel/" + myListId + ".xml");
                        break;
                    case RssType.COMMUNITY:
                        _logManager.addLog("コミュニティ(" + myListId + ")を保存中...");
                        file = new File(file.url + "/community/" + myListId + ".xml");
                        break;
                    case RssType.USER_UPLOAD_VIDEO:
                        _logManager.addLog("投稿動画一覧(" + myListId + ")を保存中...");
                        file = new File(file.url + "/user/" + myListId + ".xml");
                        break;
                    default:
                        _logManager.addLog("マイリスト(" + myListId + ")を保存中...");
                        file = new File(file.url + "/myList/" + myListId + ".xml");
                }

                var xmlList: XMLList = xml.descendants("item");
                if (xmlList.length() == 0) {
                    // xmlが正しくないと思われる
                    return;
                }

                var vector: Vector.<String> = null;

                if (file.exists) {

//					// 保存済みのxmlとDLしたxmlをマージ
//					var map:Object = new Object();
//					for each(var item:XML in xmlList)
//					{
//						map[item.link] = item;
//					}
//					
//					var tempXML:XML = readLocalMyList(myListId, type);
//					
//					var localItemList:XMLList = tempXML.descendants("item");
//					
//					var count:int = localItemList.length();
//					for each(var tempItem:XML in localItemList)
//					{
//						if (map[tempItem.link] == null)
//						{
//							// ユーザ投稿動画の保存上限
//							if (count > 500)
//							{
//								break;
//							}
//							
//							// DLしたXMLに、ローカルにはある動画が無いので追加
//							xml.channel.appendChild(tempItem);
//							count++;
//						}
//					}

                    if (savedXMLprecedence) {
                        // 保存済みXMLの既読/未読を優先

                        // 保存済みの再生済み項目を取得
                        var tempXML: XML = readLocalMyList(myListId, type);
                        vector = searchPlayedItem(tempXML);

                        // 再生済み項目を新規XMLに反映
                        updatePlayed(vector, xml, true);

                        // 保存済みの未再生項目を取得
                        var tempVector: Vector.<String> = searchUnPlaydItem(tempXML, true);

                        // 未視聴に上書き
                        if (tempVector != null && tempVector.length > 0) {
                            updatePlayed(tempVector, xml, false);
                        }
                    }
                    else {
                        // 新しく渡したXMLの既読/未読を使う
                    }
                }

                var fileIO: FileIO = new FileIO(_logManager);
                fileIO.addFileStreamEventListener(Event.COMPLETE, function (event: Event): void {
                    _logManager.addLog(myListId + "を保存:" + file.nativePath);
                    trace(event);
                });
                fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function (event: IOErrorEvent): void {
                    _logManager.addLog(myListId + "の保存に失敗:" + file.nativePath + ":" + event);
                    trace(event + ":" + file.nativePath);
                });
                fileIO.saveXMLSync(file, xml);

                /* 動画IDをマイリストに登録 */
                for each(var myList: MyList in this._myListName_MyList_Map) {
                    if (myList.isDir == true) {
                        continue;
                    }

                    if (myList.id == myListId) {

                        var type: RssType = checkType(myList.myListUrl);

                        updateMyListVideoId(myList);

                        // 未再生の動画数を登録
                        myList.unPlayVideoCount = countUnPlayVideos(myList.id, type);
                        break;
                    }
                }

            } catch (error: Error) {
                _logManager.addLog("マイリストの保存に失敗:" + error + ":" + error.getStackTrace());
                trace(error.getStackTrace());
            }

        }

        /**
         * ローカルに保存されているマイリストを読み込みます
         *
         * @param myListId
         * @return
         *
         */
        public function readLocalMyList(myListId: String, type: RssType): XML {

            try {

                var file: File = this._libraryManager.systemFileDir;

                switch (type) {
                    case RssType.MY_LIST:
                        file = new File(file.url + "/myList/" + myListId + ".xml");
                        break;
                    case RssType.CHANNEL:
                        file = new File(file.url + "/channel/" + myListId + ".xml");
                        break;
                    case RssType.COMMUNITY:
                        file = new File(file.url + "/community/" + myListId + ".xml");
                        break;
                    case RssType.USER_UPLOAD_VIDEO:
                        file = new File(file.url + "/user/" + myListId + ".xml");
                        break;
                }

                var fileIO: FileIO = new FileIO(_logManager);
                fileIO.addFileStreamEventListener(Event.COMPLETE, function (event: Event): void {
                    _logManager.addLog("マイリストの読み込み:" + file.nativePath);
                    trace(event);
                });
                fileIO.addFileStreamEventListener(IOErrorEvent.IO_ERROR, function (event: IOErrorEvent): void {
                    _logManager.addLog("マイリストの読み込みに失敗:" + file.nativePath + ":" + event);
                    trace(event + ":" + file.nativePath);
                });
                var xml: XML = fileIO.loadXMLSync(file.url, true);

                return xml;

            } catch (error: Error) {
                _logManager.addLog("マイリストの読み込みに失敗:" + error + ":" + error.getStackTrace());
                trace(error.getStackTrace());
            }

            return null;

        }

        /**
         *
         * @param name
         * @return
         *
         */
        public function getSubDirMyList(name: String): Vector.<MyList> {
            var vector: Vector.<MyList> = new Vector.<MyList>();

            var leaf: Object = searchByName(name, this._tree_MyList);
            if (leaf == null) {
                return vector;
            }

            if (leaf.hasOwnProperty("children")) {
                // これはフォルダ
                var children: Array = leaf.children;
                for each(var tempObject: Object in children) {

                    var tempVector: Vector.<MyList> = getSubDirMyList(tempObject.label);
                    for each(var tempMyList: MyList in tempVector) {
                        vector.splice(0, 0, tempMyList);
                    }

                }

            } else {
                //これはファイル
                var myList: MyList = this._myListName_MyList_Map[leaf.label];
                vector.splice(0, 0, myList);
            }
            return vector;
        }


        /**
         * 指定されたディレクトリ下のマイリスト(XML)の一覧を取得します。
         *
         * @param file
         *
         */
        public function readFromSubDirMyList(name: String): Vector.<XML> {
            var vector: Vector.<XML> = new Vector.<XML>();

            var myLists: Vector.<MyList> = getSubDirMyList(name);
            for each(var myList: MyList in myLists) {
                if (!myList.isDir) {
                    var type: RssType = checkType(myList.myListUrl);
                    var xml: XML = this.readLocalMyList(myList.id, type);
                    vector.splice(0, 0, xml);
                }
            }

            return vector;
        }

        /**
         * 指定されたマイリストの、指定された動画の項目を既読/未読に設定します
         * @param myListId
         * @param videoIds
         * @param isPlayed
         *
         */
        public function updatePlayedAndSave(myListId: String, type: RssType, videoIds: Vector.<String>, isPlayed: Boolean): void {

            var xml: XML = readLocalMyList(myListId, type);

            if (xml != null) {

                var str: String = "";
                for each(var videoId: String in videoIds) {
                    str += (videoId + ", ");
                }

                if (!updatePlayed(videoIds, xml, isPlayed)) {
                    _logManager.addLog(str + "は isPlayed = " + isPlayed + " に設定済(" + type.toString() + ":" + myListId + ")");
                    return;
                }
                saveMyList(myListId, type, xml, false);

                _logManager.addLog(str + "を isPlayed = " + isPlayed + " に設定(" + type.toString() + ":" + myListId + ")");

            }

        }

        /**
         * ローカルのプレイリストを読み込み、既読判定を行ったNNDDVideoを格納するVectorを返します。
         *
         * @param myListId
         * @return
         *
         */
        public function readLocalMyListByNNDDVideo(myListId: String, type: RssType): Vector.<NNDDVideo> {

            var videoArray: Vector.<NNDDVideo> = new Vector.<NNDDVideo>();

            var xml: XML = readLocalMyList(myListId, type);

            if (xml != null) {
                var xmlList: XMLList = xml.child("channel");

                xmlList = xmlList.child("item");
                for each(var tempXML: XML in xmlList) {
                    var link: String = decodeURIComponent(tempXML.link);
                    var title: String = tempXML.title;
                    try {
                        title = HtmlUtil.convertSpecialCharacterNotIncludedString(title);
                        title = decodeURIComponent(unescape(title));
                    } catch (error: Error) {
                        trace("デコード前の名前を使用:" + title);
                        trace(error.getStackTrace());
                    }
                    var played: String = tempXML.played;
                    if (link != null && title != null) {

                        var nnddVideo: NNDDVideo = new NNDDVideo(link, title);

                        if (played != null && played == "true") {
                            nnddVideo.yetReading = true;
                        }

                        videoArray.splice(0, 0, nnddVideo);

                    }

                }

            }

            return videoArray;

        }


        /**
         * XML内から、指定されたvideoIdの項目を探し、既読/未読を設定します。
         *
         * @param videoId
         * @param xml
         * @param isPlayed
         * @return
         *
         */
        private function updatePlayed(videoIds: Vector.<String>, xml: XML, isPlayed: Boolean): Boolean {

            if (videoIds == null || videoIds.length <= 0) {
                return false;
            }

            if (xml != null) {

                var videoIdMap: Object = new Object();
                for each(var videoId: String in videoIds) {
                    videoIdMap[videoId] = videoId;
                }

                var setCount: int = 0;
                var isChange: Boolean = false;

                var xmlList: XMLList = xml.child("channel");

                xmlList = xmlList.child("item");

                // マイリストから動画のURLの一覧を取得
                for each(var tempXML: XML in xmlList) {
                    var link: String = tempXML.link;
                    if (link != null) {
                        var tempVideoId: String = PathMaker.getVideoID(link);

                        // 動画が既読設定対象か？
                        if (videoIdMap[tempVideoId] != null) {
                            delete videoIdMap[tempVideoId];
                            setCount++;
                            var list: XMLList = tempXML.played;
                            if (list != null && list.length() > 0) {
                                list[0] = new XML("<played>" + String(isPlayed) + "</played>");
                            } else {
                                tempXML.appendChild(new XML("<played>" + String(isPlayed) + "</played>"));
                            }
                            isChange = true;
                        }
                    }
                    if (setCount >= videoIds.length) {
                        if (isChange) {
                            trace("変更あり");
                        }
                        return isChange;
                    }
                }
            }

            return false;
        }

        /**
         * 渡されたXMLから既読項目(<played>要素がtrueの動画ID)を探します
         *
         * @param xml
         * @return
         *
         */
        private function searchPlayedItem(xml: XML): Vector.<String> {

            var videoIds: Vector.<String> = new Vector.<String>();

            if (xml != null) {

                var xmlList: XMLList = xml.child("channel");

                xmlList = xmlList.child("item");

                for each(var tempXML: XML in xmlList) {
                    var items: XMLList = tempXML.played;
                    try {
                        if (items != null && items.length() > 0) {
                            if ((items[0] as XML).text().toString() == "true") {
                                videoIds.splice(-1, 0, PathMaker.getVideoID(tempXML.link));
                            }
                        }
                    } catch (error: Error) {
                        trace(error.getStackTrace());
                    }
                }
            }

            return videoIds;
        }

        /**
         * 指定されたXMLから未視聴の動画を探し、未視聴の動画IDの一覧をVector.<String>に格納して返します。
         *
         * @param xml
         * @param onlyIsPlayFalse isPlayedがfalseと明示的に設定されているもののみをカウントするかどうか。trueの時はfalseに設定されているもののみ取得
         * @param withOutDownloadedVideo DL済みの動画をリストからのぞくかどうか。falseの時はDL済みでも、未視聴の動画はリストに含まれます。trueの場合は、DL済みなら視聴済みであると判断します。
         * @return
         *
         */
        private function searchUnPlaydItem(xml: XML, onlyIsPlayFalse: Boolean = false, withOutDownloadedVideo: Boolean = false): Vector.<String> {
            var videoIds: Vector.<String> = new Vector.<String>();

            if (xml != null) {

                var xmlList: XMLList = xml.child("channel");

                xmlList = xmlList.child("item");

                for each(var tempXML: XML in xmlList) {
                    var items: XMLList = tempXML.played;
                    try {
                        var videoId: String = null;
                        if (!onlyIsPlayFalse && (items == null || (items != null && items.length() == 0))) {
                            videoId = PathMaker.getVideoID(tempXML.link);
                        }
                        else if (items != null && items.length() > 0) {
                            if ((items[0] as XML).text().toString() == "false") {
                                videoId = PathMaker.getVideoID(tempXML.link);
                            }
                        }

                        if (withOutDownloadedVideo) {
                            if (this._libraryManager.isExist(videoId) != null) {
                                videoId = null;
                            }
                        }

                        if (videoId != null) {
                            videoIds.push(videoId);
                        }

                    } catch (error: Error) {
                        trace(error.getStackTrace());
                    }
                }
            }

            return videoIds;
        }

        /**
         * ローカルに保存されているすべてのマイリストについて、
         * 未視聴の動画の数をカウントし、その数を返します。
         *
         * @return
         *
         */
        public function countUnPlayVideosFromAll(): int {

            var count: int = 0;

            for each(var myList: MyList in this._myListName_MyList_Map) {
                var myListId: String = MyListUtil.getMyListId(myList.myListUrl);
                if (myListId != null) {
                    var type: RssType = checkType(myList.myListUrl);
                    var myCount: int = countUnPlayVideos(myListId, type);
                    myList.unPlayVideoCount = myCount;
                    count += myCount;
                }
            }

            return count;
        }

        /**
         * 指定されたマイリストの未再生の動画の数を数えて返します。
         *
         * @param myListId
         * @return
         *
         */
        public function countUnPlayVideos(myListId: String, type: RssType): int {

            var xml: XML = readLocalMyList(myListId, type);

            // DL済み動画を未再生としてカウントするかどうか(デフォルトしない)
            var withOutDownloadedVideo: Boolean = false;
            var str: String = ConfigManager.getInstance().getItem("withOutDownloadedVideo");
            if (str != null) {
                withOutDownloadedVideo = ConfUtil.parseBoolean(str);
            }
            else {
                ConfigManager.getInstance().setItem("withOutDownloadedVideo", "false");
                ConfigManager.getInstance().save();
            }

            if (xml != null) {
                var vector: Vector.<String> = searchUnPlaydItem(xml, false, withOutDownloadedVideo);
                return vector.length;
            } else {
                return 0;
            }

        }

        /**
         * ユーザのマイリスト一覧を取得し、MyListManagerに追加します。
         *
         * @param mailAddress
         * @param password
         *
         */
        public function renewMyListIds(mailAddress: String, password: String): void {

            if (this._myListGroupLoader != null) {
                this._myListGroupLoader.close();
                this._myListGroupLoader = null;
            }

            this._myListGroupLoader = new NNDDMyListGroupLoader();

            this._myListGroupLoader.addEventListener(NNDDMyListGroupLoader.SUCCESS, function (event: Event): void {
                for each(var str: String in _myListGroupLoader.myListIds) {

                    var myList: MyList = MyListManager.instance.getMyList(str);
                    if (myList == null) {
                        myList = new MyList("myListId/" + str, "あなたのマイリスト(" + str + ")", false);
                        MyListManager.instance.addMyList(myList.myListUrl, myList.myListName, myList.isDir, true);
                    }
                    trace(str);
                }
                dispatchEvent(new Event(MYLIST_RENEW_COMPLETE));
                Alert.show("マイリストを追加しました", Message.M_MESSAGE);
                _myListGroupLoader.close();
                _myListGroupLoader = null;
            });
            this._myListGroupLoader.addEventListener(NNDDMyListGroupLoader.FAILURE, function (event: Event): void {
                _myListGroupLoader.close();
                _myListGroupLoader = null;
                Alert.show("マイリスト一覧の更新に失敗\n" + event, Message.M_ERROR);
                dispatchEvent(new Event(MYLIST_RENEW_COMPLETE));
            });

            this._myListGroupLoader.getMyListGroup(mailAddress, password);
        }

        /**
         * マイリストIDからマイリストオブジェクトを探して返します
         *
         * @param myListId
         * @return
         *
         */
        public function getMyList(myListId: String): MyList {

            for each(var myList: MyList in this._myListName_MyList_Map) {
                if (myList.id == myListId) {
                    return myList;
                }
            }
            return null;
        }

        /**
         * 指定された動画IDの動画を保持するマイリストのマイリストIDの一覧を返します。
         * このマイリストIDには、myList/ や channel/ などのプレフィックスが含まれます。
         *
         * @param videoId
         * @return
         *
         */
        public function searchMyListIdWithPrefix(videoId: String): Vector.<String> {
            var myListIds: Vector.<String> = this._videoId_myListIds_map[videoId];

            var vector: Vector.<String> = new Vector.<String>();

            if (myListIds == null) {
                return new Vector.<String>();
            }
            else {
                for each(var id: String in myListIds) {
                    vector.push(id);
                }
            }

            return vector;
        }

        /**
         * 指定されたURLのRSS種別を調べて返します。
         *
         * @param url
         * @return
         *
         */
        public static function checkType(url: String): RssType {
            if (url != null) {
                if (url.indexOf("channel/") !== -1 || url.indexOf("ch.nicovideo.jp") !== -1) {
                    return RssType.CHANNEL;
                } else if (url.indexOf("community/") !== -1 || url.indexOf("com.nicovideo.jp") !== -1) {
                    return RssType.COMMUNITY;
                } else if (url.indexOf("user/") != -1) {
                    return RssType.USER_UPLOAD_VIDEO;
                }
            }

            return RssType.MY_LIST;
        }

        /**
         * マイリストIDの一覧を返します。
         * @return
         *
         */
        public function getAllMyList(): Vector.<MyList> {
            var myLists: Vector.<MyList> = new Vector.<MyList>();
            for each(var myList: MyList in _myListName_MyList_Map) {
                if (!myList.isDir) {
                    myLists.push(myList);
                }
            }

            return myLists;
        }

    }
}