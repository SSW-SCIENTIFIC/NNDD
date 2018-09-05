package org.mineap.nndd.player {
    /**
     * PlayerControllerを管理するクラスです。
     *
     * @author shiraminekeisuke
     *
     */
    public class PlayerManager {

        private var players: Vector.<PlayerController> = new Vector.<PlayerController>();

        private static const _playerManager: PlayerManager = new PlayerManager();
        private var searchNNDDServerVideo: Boolean;
        private var nnddServerAddress: String;
        private var nnddServerPortNum: int;


        public function PlayerManager() {
            if (_playerManager != null) {
                throw new ArgumentError("PlayerManagerはインスタンス化できません。");
            }
        }

        /**
         *
         * @return
         *
         */
        public static function get instance(): PlayerManager {
            return _playerManager;
        }

        /**
         * 既に閉じられたPlayerControllerをリストから取り除く
         *
         */
        private function gc(): void {

            var newTargets: Vector.<PlayerController> = new Vector.<PlayerController>();

            for each(var playerController: PlayerController in players) {
                if (playerController.isOpen()) {
                    newTargets.push(playerController);
                }
            }

            this.players = newTargets;

        }

        /**
         * 最後に構築したPlayerControllerを返します。一度もPlayerControllerを構築した事が無い場合と、最後に開いたPlayerが既に閉じられている場合は、新たに作成して返します。
         * @return
         *
         */
        public function getLastPlayerController(): PlayerController {

            gc();

            var playerController: PlayerController = null;
            if (players.length <= 0) {
                playerController = new PlayerController();
                playerController.open();

                players.push(playerController);
                updateNNDDServerSetting(searchNNDDServerVideo, nnddServerAddress, nnddServerPortNum);
            } else {
                if (!players[players.length - 1].isOpen()) {
                    playerController = new PlayerController();
                    playerController.open();

                    players.push(playerController);
                    updateNNDDServerSetting(searchNNDDServerVideo, nnddServerAddress, nnddServerPortNum);
                }
            }

            return players[players.length - 1];
        }

        /**
         * 指定したindexのPlayerControllerを返します。
         * @param index
         * @return
         *
         */
        public function getPlayerAt(index: int): PlayerController {
            if (players.length > index) {
                return players[index];
            } else {
                return null;
            }
        }

        /**
         * 新しいPlayerを生成して返します。
         * なお、同時に開く事ができるPlayerの数は10個までです。
         * @return
         *
         */
        public function getNewPlayer(): PlayerController {
            gc();

            var player: PlayerController = null;
            if (this.players.length > 9) {
                player = getLastPlayerController();
            } else {
                player = new PlayerController();
                player.open();

                players.push(player);
                updateNNDDServerSetting(searchNNDDServerVideo, nnddServerAddress, nnddServerPortNum);
            }
            return player;
        }

        /**
         *
         * @param url
         *
         */
        public function playAtNewPlayerController(url: String): void {
            var player: PlayerController = getNewPlayer();
            player.playMovie(url);
        }

        /**
         *
         * @param url
         * @return
         *
         */
        public function playLastPlayerController(url: String): void {
            var playerController: PlayerController = getLastPlayerController();
            playerController.playMovie(url);
        }

        /**
         *
         *
         */
        public function closeAll(): void {
            for each(var player: PlayerController in players) {
                if (player.isOpen()) {
                    player.playerExit();
                }
            }
        }

        /**
         *
         *
         */
        public function stopAll(): void {
            gc();

            for each(var player: PlayerController in players) {
                if (player.isOpen()) {
                    player.stop();
                }
            }
        }

        /**
         *
         *
         */
        public function resetWindowPosition(): void {
            closeAll();
            gc();
            var player: PlayerController = getLastPlayerController();
            player.resetWindowPosition();
        }

        /**
         *
         * @param value
         *
         */
        public function setAppendComment(value: Boolean): void {
            gc();

            for each(var player: PlayerController in players) {
                if (player.isOpen()) {
                    player.videoInfoView.setAppendComment(value);
                }
            }
        }

        /**
         *
         * @param fontName
         *
         */
        public function setFont(fontName: String): void {
            gc();

            for each(var player: PlayerController in players) {
                if (player.isOpen()) {
                    player.setFont(fontName);
                }
            }
        }

        /**
         *
         * @param fontSize
         *
         */
        public function setFontSize(fontSize: Number): void {
            gc();

            for each(var player: PlayerController in players) {
                if (player.isOpen()) {
                    player.setFontSize(fontSize);
                }
            }
        }

        /**
         * いずれかのPlayerで、Fileを開くダイアログがopenしているかを返します。
         * @return 一つでもダイアログが開いている場合はfalse
         *
         */
        public function isOpenFileDialogFocusIn(): Boolean {
            for each(var player: PlayerController in players) {
                if (player.isOpen()) {
                    if (player.videoPlayer.isFileOpenDialogFocusIn) {
                        return true;
                    }
                }
            }
            return false;
        }

        /**
         *
         * @param enable
         * @param address
         * @param port
         * @return
         *
         */
        public function updateNNDDServerSetting(enable: Boolean, address: String, port: int): void {
            this.searchNNDDServerVideo = enable;
            this.nnddServerAddress = address;
            this.nnddServerPortNum = port;

            for each(var player: PlayerController in players) {
                player.searchNNDDServerVideo = enable;
                player.nnddServerAddress = address;
                player.nnddServerPortNum = port;
            }
        }
    }
}