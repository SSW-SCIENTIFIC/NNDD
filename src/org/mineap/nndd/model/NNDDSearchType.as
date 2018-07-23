package org.mineap.nndd.model {
    /**
     * SearchType.as<br>
     * SearchTypeクラスは、検索種別を表す定数を保持するクラスです。<br>
     * <br>
     * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.<br>
     *
     * @author shiraminekeisuke
     *
     */
    public class NNDDSearchType {
        /**
         * 検索種別がキーワードである事を表す定数です
         */
        public static const KEY_WORD: int = 0;
        /**
         * 検索種別がタグによる検索である事を表す定数です
         */
        public static const TAG: int = 1;

        public function NNDDSearchType() {
        }
    }
}