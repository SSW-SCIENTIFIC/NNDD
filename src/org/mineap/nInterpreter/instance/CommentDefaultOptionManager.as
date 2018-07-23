package org.mineap.nInterpreter.instance {
    /**
     * コメントのデフォルト設定(色、位置、大きさなど)を保持するクラスです。
     *
     * @author shiraminekeisuke (MineAP)
     *
     */
    public class CommentDefaultOptionManager {

        private static const manager: CommentDefaultOptionManager = new CommentDefaultOptionManager();

        private var defaultColor: int = int(0xffffff);

        public function CommentDefaultOptionManager() {
            if (manager != null) {
                throw new ArgumentError("CommentDefaultOptionManagerはインスタンス化できません.");
            }
        }

        /**
         *
         * @return
         *
         */
        public static function get instance(): CommentDefaultOptionManager {
            return CommentDefaultOptionManager.manager;
        }

        /**
         *
         *
         */
        public function initalize(): void {
            defaultColor = int(0xffffff);
        }

        /**
         *
         * @param color
         *
         */
        public function set commentColor(color: int): void {
            this.defaultColor = color;
        }

        /**
         *
         * @return
         *
         */
        public function get commentColor(): int {
            return this.defaultColor;
        }


    }
}