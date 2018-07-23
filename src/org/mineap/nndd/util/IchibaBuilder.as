package org.mineap.nndd.util {
    import mx.collections.ArrayCollection;

    import org.mineap.nicovideo4as.util.HtmlUtil;
    import org.mineap.nndd.LogManager;

    /**
     *
     * IchibaBuilder.as
     *
     * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
     *
     * @author shiraminekeisuke
     *
     */
    public class IchibaBuilder {

        private var logManager: LogManager;

        public function IchibaBuilder(logManager: LogManager) {
            this.logManager = logManager;
        }

        /**
         * 引数で渡されたHTMLから市場情報を解析し、ArrayCollectionに格納して返します。
         * @param ichibaHTML
         * @return
         *
         */
        public function makeIchibaInfo(ichibaHTML: String): ArrayCollection {
            if ("市場情報が取得できませんでした。" == ichibaHTML) {
                var array: ArrayCollection = new ArrayCollection();
                array.addItem({
                    col_image: "",
                    col_info: ichibaHTML,
                    col_link: ""
                });
                return array;
            } else {
                return parse(ichibaHTML);
            }
        }


        /**
         * 引数で渡されたHTMLから市場情報を解析し、imgタグのsrc属性のURLと、title属性の文字列を、出現順にArrayCollectionに格納します。
         * @param ichibaHTML
         * @return
         *
         */
        public function parse(ichibaHTML: String): ArrayCollection {
            //イメージへのリンク
            //Amazonは変換する。
            //<img src="http://ecx.images-amazon.com/images/I/41p9BgbR-oL._AA146_.jpg" title="東方麻雀牌携帯ストラップ 八雲 紫" width="146" height="146">
            //<img src="http://a248.e.akamai.net/f/248/37952/7d/image.shopping.yahoo.co.jp/i/g/wcanvas_500011418000" title="東方マスコットキーチェーン 紫（第5弾） ＜ホワイトキャンバス＞" width="76" height="76">

            //商品へのリンク
            //Amazon
            //<a href="http://www.amazon.co.jp/dp/B001I8K43Q/ref=asc_df_B001I8K43Q56388/?tag=nicovideojp-22&amp;creative=380333&amp;creativeASIN=B001I8K43Q&amp;linkCode=asn" class="ichiba_item" target="_blank" onmousedown="return ichibaB_az.item_click('azB001I8K43Q')">
            //http://www.amazon.co.jp/exec/obidos/ASIN/B001I8K43Q/mi01b-22/ref=nosim

            //Yahoo
            //<a href="http://ck.jp.ap.valuecommerce.com/servlet/referral?sid=2466861&amp;pid=876879864&amp;vc_url=http%3A%2F%2Frd.store.yahoo.co.jp%2Fwcanvas%2F500011418000.html&amp;vcptn=yswcanvas_500011418000" class="ichiba_item" target="_blank" onmousedown="return ichibaB_ys.item_click('yswcanvas_500011418000')">

            /*
                //開始
                <img src="http://exc\.images-amazon\.com/ ..... or <img src="http://[^.]+\.e\.akamai\.net/ ....
                //終了
                <img src="http://res.nicovideo.jp/img/watch/ichiba/go_ichiba.gif" alt="ニコニコ市場" class="go_ichiba">
            */

            //(http://[^/]+\\.e\\.akamai\\.net/[^/]+/[^/]+/[^/]+/[^/]+/image\\.shopping\\.yahoo\\.co\\.jp/././[^\"]+)
            var array: ArrayCollection = new ArrayCollection();
            var gIndex: Number = 0;
            while (true) {
                var imageURL: String = "";
                var linkURL: String = "";
                var itemInfo: String = "";
                var endIndex: Number = 0;

                //画像のURLとタイトルを取得
                var pattern_imgUrlAndTitle: RegExp = new RegExp(
                        "(http://ecx.images-amazon.com/images/./[^\"]*|" +
                        "http://item.shopping.c.yimg.jp/././[^\"]*|" +
                        "http://[^/]*.e.akamai.net/[^/]*/[^/]*/[^/]*/[^/]*/image.shopping.yahoo.co.jp/././[^\"]*)\".*title=\"([^\"]*)\"[^>]*>", "ig");
                pattern_imgUrlAndTitle.lastIndex = gIndex;
                var execIandT: Object = pattern_imgUrlAndTitle.exec(ichibaHTML);
                if (execIandT == null) {
                    //現状は市場の上に出てくる５つしか抽出していない。
                    break;
                }
                imageURL = execIandT[1];
                itemInfo = HtmlUtil.convertSpecialCharacterNotIncludedString(execIandT[2]);

                //この商品の終わり抽出
                var pattern_itemEnd_old: RegExp = new RegExp("ニコニコ市場へ", "ig");	//古い市場情報
                var pattern_itemEnd: RegExp = new RegExp("</div></td>", "ig");			//新しい市場情報
                pattern_itemEnd_old.lastIndex = execIandT.index;
                pattern_itemEnd.lastIndex = execIandT.index;
                var endExec: Object = pattern_itemEnd.exec(ichibaHTML);
                if (endExec == null) {
                    endExec = pattern_itemEnd_old.exec(ichibaHTML);
                }
                if (endExec != null) {
                    endIndex = endExec.index;
                }

                var pattern_itemLink: RegExp;
                pattern_itemLink = new RegExp(".*href=\"(http://www.amazon.co.jp/dp/[^\"]*)\".*", "ig");
                pattern_itemLink.lastIndex = execIandT.index;
                var execASIN: Object = pattern_itemLink.exec(ichibaHTML);
                if (execASIN != null && execASIN.index < endIndex) {
                    linkURL = execASIN[1];
                    gIndex = execASIN.index;
                } else {
                    //ASIN not found = Yahooの時
                    pattern_itemLink = new RegExp("href=\".*(http\\%3A\\%2F\\%2Frd.store.yahoo.co.jp\\%2.*.html)[^\"]*\" class=\"ichiba_item\"", "ig");
                    pattern_itemLink.lastIndex = execIandT.index;
                    execASIN = pattern_itemLink.exec(ichibaHTML);
                    if (execASIN != null && execASIN.index < endIndex) {
                        linkURL = decodeURIComponent(execASIN[1]);
                        gIndex = execASIN.index;
                    }
                }

                if (linkURL == null || linkURL.length == 0) {
                    break;
                }

                //価格抽出
                var pattern_value: RegExp = new RegExp("([¥|￥][^(</)]+)", "ig");
                pattern_value.lastIndex = execIandT.index;
                var execValue: Object = pattern_value.exec(ichibaHTML);
                if (execValue != null && execValue.index < endIndex) {
                    itemInfo += "\n" + execValue[1];
                    gIndex = execValue.index;
                } else {
                    //value not found
                }

                //発売日抽出
                var pattern_OnSaleDate: RegExp = new RegExp("(\\d\\d\\d\\d/\\d\\d/\\d\\d|\\d\\d\\d\\d\-\\d\\d\-\\d\\d)", "ig");
                pattern_OnSaleDate.lastIndex = execIandT.index;
                var execOnSaleDate: Object = pattern_OnSaleDate.exec(ichibaHTML);
                if (execOnSaleDate != null && execOnSaleDate.index < endIndex) {
                    itemInfo += "\n発売日:" + execOnSaleDate[1];
                    gIndex = execOnSaleDate.index;
                } else {
                    //value not found
                }

                //購入者数抽出
                var pattern_BuyCount: RegExp = new RegExp(">([\\d|,]*)人</strong>", "ig");
                pattern_BuyCount.lastIndex = execIandT.index;
                var execBuyCount: Object = pattern_BuyCount.exec(ichibaHTML);
                if (execBuyCount != null && execBuyCount.index < endIndex) {
                    itemInfo += "\n購入者数:" + execBuyCount[1];
                    gIndex = execBuyCount.index;

                    //アクセス数抽出
                    var pattern_AllClickCount: RegExp = new RegExp("全体で([\\d|,]*)人がクリック", "ig");
                    pattern_AllClickCount.lastIndex = execIandT.index;
                    var execAllClickCount: Object = pattern_AllClickCount.exec(ichibaHTML);
                    if (execAllClickCount != null && execAllClickCount.index < endIndex) {
                        itemInfo += "/クリック数:" + execAllClickCount[1];
                        gIndex = execAllClickCount.index;
                    } else {
                        //value not found
                    }

                } else {
                    //value not found
                }

                if (imageURL.indexOf("amazon") != -1) {
                    itemInfo += "\n(amazon.co.jp)";
                } else {
                    itemInfo += "\n(Yahoo! JAPAN)";
                }

                array.addItem({
                    col_image: imageURL,
                    col_info: itemInfo,
                    col_link: linkURL
                });

//				gIndex = endIndex;


            }

            if (array.length == 0) {
                array.addItem({
                    col_info: "市場情報が存在しないか、\n市場情報の解析に失敗しました。"
                });
            }

            return array;
        }


    }

}