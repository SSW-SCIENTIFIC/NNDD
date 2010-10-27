package org.mineap.nndd.util
{
	import mx.collections.ArrayCollection;
	
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
	public class IchibaBuilder
	{
		
		private var logManager:LogManager;
		
		public function IchibaBuilder(logManager:LogManager)
		{
			this.logManager = logManager;
		}
		
		/**
		 * 引数で渡されたHTMLから市場情報を解析し、ArrayCollectionに格納して返します。
		 * @param ichibaHTML
		 * @return 
		 * 
		 */
		public function makeIchibaInfo(ichibaHTML:String):ArrayCollection{
			if("市場情報が取得できませんでした。" == ichibaHTML){
				var array:ArrayCollection = new ArrayCollection();
				array.addItem({
					col_image:"",
					col_info:ichibaHTML,
					col_link:""
				});
				return array;
			}else{
				return parse(ichibaHTML);
			}
		}
		
		
		/**
		 * 引数で渡されたHTMLから市場情報を解析し、imgタグのsrc属性のURLと、title属性の文字列を、出現順にArrayCollectionに格納します。
		 * @param ichibaHTML
		 * @return 
		 * 
		 */
		public function parse(ichibaHTML:String):ArrayCollection{
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
			/*例
			
				<img src="http://ecx.images-amazon.com/images/I/41p9BgbR-oL._AA146_.jpg" title="東方麻雀牌携帯ストラップ 八雲 紫" width="146" height="146">
            </div>
            <span id="azB001I8K43Q_mq" style="position:absolute; top:1px; z-index:2; width:146px; font-weight: bold; text-decoration:none;">
            </span>
            <a style="cursor:pointer;" href="http://www.amazon.co.jp/dp/B001I8K43Q/ref=asc_df_B001I8K43Q56388/?tag=nicovideojp-22&amp;creative=380333&amp;creativeASIN=B001I8K43Q&amp;linkCode=asn" class="ichiba_item" target="_blank" onmousedown="return ichibaB_az.item_click('azB001I8K43Q')">
                <div style="opacity:0; -moz-opacity:0; filter: alpha(opacity=0); background-color:black; position:absolute; top:0px; left:0px; width:146px; height:146px; z-index:10;" onmouseover="marquee.enable('azB001I8K43Q', 146, 146, 8);" onmouseout="marquee.disable('azB001I8K43Q');"> 
                </div>
            </a>
        </div>
    </td>
    <td style="vertical-align:middle;">
        <p>
            <img src="http://res.nicovideo.jp/img/watch/ichiba/from_amazon.gif" alt="amazon.co.jp">
        </p>
        <div style="margin:4px 0;">
            <p style="font-size:14px; line-height:1.25;">
                <a href="http://www.amazon.co.jp/dp/B001I8K43Q/ref=asc_df_B001I8K43Q56388/?tag=nicovideojp-22&amp;creative=380333&amp;creativeASIN=B001I8K43Q&amp;linkCode=asn" class="ichiba_item" target="_blank" onmousedown="return ichibaB_az.item_click('azB001I8K43Q')">
                    <h3 style="font-family:verdana,arial,helvetica,sans-serif; display:inline; font-size:14px; line-height:1.25;">東方麻雀牌携帯ストラップ 八雲 紫
                    </h3>
                </a>
                <span class="item_genre">おもちゃ＆ホビー
                </span>
            </p>
            <p class="TXT12">
                <strong style="font-weight:bold;">中国
                </strong>
            </p>
            <p class="TXT12">
                <strong style="font-weight:bold;">
                </strong>
            </p>
        </div>
        <p class="TXT12">
            <strong style="color:#F30;font-weight:bold;">27人
            </strong>が購入しました / この動画で
            <strong style="font-weight:bold;">230人
            </strong>、全体で1,277人がクリック
            <p class="TXT12">
                <a href="http://ichiba.nicovideo.jp/item/azB001I8K43Q" target="_blank" style="color:#F60;">&gt;&gt;ニコニコ市場へ
                    <img src="http://res.nicovideo.jp/img/watch/ichiba/go_ichiba.gif" alt="ニコニコ市場" class="go_ichiba">
			
			*/
			//(http://[^/]+\\.e\\.akamai\\.net/[^/]+/[^/]+/[^/]+/[^/]+/image\\.shopping\\.yahoo\\.co\\.jp/././[^\"]+)
			var array:ArrayCollection = new ArrayCollection();
			var gIndex:Number = 0;
			while(true){
				var imageURL:String = "";
				var linkURL:String = "";
				var itemInfo:String = "";
				var endIndex:Number = 0;
				
				//画像のURLとタイトルを取得
				var pattern_imgUrlAndTitle:RegExp = new RegExp("<img src=\"(http://ecx.images-amazon.com/images/./[^\"]*|http://[^/]*.e.akamai.net/[^/]*/[^/]*/[^/]*/[^/]*/image.shopping.yahoo.co.jp/././[^\"]*)\"" + 
						".*title=\"([^\"]*)\"[^>]*>", "ig");
				pattern_imgUrlAndTitle.lastIndex = gIndex;
				var execIandT:Object = pattern_imgUrlAndTitle.exec(ichibaHTML);
				if(execIandT == null){
					//現状は市場の上に出てくる５つしか抽出していない。
					break;
				}
				imageURL = execIandT[1];
				itemInfo = execIandT[2];
				
				//この商品の終わり抽出
				var pattern_itemEnd_old:RegExp = new RegExp("ニコニコ市場へ", "ig");	//古い市場情報
				var pattern_itemEnd:RegExp = new RegExp("</nobr>", "ig");			//新しい市場情報
				pattern_itemEnd_old.lastIndex = execIandT.index;
				pattern_itemEnd.lastIndex = execIandT.index;
				var endExec:Object = pattern_itemEnd.exec(ichibaHTML);
				if(endExec == null){
					endExec = pattern_itemEnd_old.exec(ichibaHTML);
				}
				if(endExec != null){
					endIndex = endExec.index;
				}
				
				var pattern_itemLink:RegExp;
				pattern_itemLink = new RegExp(".*href=\"(http://www.amazon.co.jp/dp/[^\"]*)\".*", "ig");
				pattern_itemLink.lastIndex = execIandT.index;
				var execASIN:Object = pattern_itemLink.exec(ichibaHTML);
				if(execASIN != null && execASIN.index < endIndex){
					linkURL = execASIN[1];
					gIndex = execASIN.index;
				}else{
					//ASIN not found = Yahooの時
					pattern_itemLink = new RegExp("href=\".*(http\\%3A\\%2F\\%2Frd.store.yahoo.co.jp\\%2.*.html)[^\"]*\" class=\"ichiba_item\"", "ig");
					pattern_itemLink.lastIndex = execIandT.index;
					execASIN = pattern_itemLink.exec(ichibaHTML);
					if(execASIN != null && execASIN.index < endIndex){
						linkURL = decodeURIComponent(execASIN[1]);
						gIndex = execASIN.index;
					}
				}
				
				
				//価格抽出
				var pattern_value:RegExp = new RegExp("([¥|￥][^(</)]+)", "ig");
				pattern_value.lastIndex = execIandT.index;
				var execValue:Object = pattern_value.exec(ichibaHTML);
				if(execValue != null && execValue.index < endIndex){
					itemInfo += "\n" + execValue[1];
					gIndex = execValue.index;
				}else{
					//value not found
				}
				
				//発売日抽出
				var pattern_OnSaleDate:RegExp = new RegExp("(\\d\\d\\d\\d/\\d\\d/\\d\\d|\\d\\d\\d\\d\-\\d\\d\-\\d\\d)", "ig");
				pattern_OnSaleDate.lastIndex = execIandT.index;
				var execOnSaleDate:Object = pattern_OnSaleDate.exec(ichibaHTML);
				if(execOnSaleDate != null && execOnSaleDate.index < endIndex){
					itemInfo += "\n発売日:" + execOnSaleDate[1];
					gIndex = execOnSaleDate.index;
				}else{
					//value not found
				}
				
				//購入者数抽出
				var pattern_BuyCount:RegExp = new RegExp(">([\\d|,]*)人</strong>", "ig");
				pattern_BuyCount.lastIndex = execIandT.index;
				var execBuyCount:Object = pattern_BuyCount.exec(ichibaHTML);
				if(execBuyCount != null && execBuyCount.index < endIndex){
					itemInfo += "\n購入者数:" + execBuyCount[1];
					gIndex = execBuyCount.index;
					
					//アクセス数抽出
					var pattern_AllClickCount:RegExp = new RegExp("全体で([\\d|,]*)人がクリック", "ig");
					pattern_AllClickCount.lastIndex = execIandT.index;
					var execAllClickCount:Object = pattern_AllClickCount.exec(ichibaHTML);
					if(execAllClickCount != null && execAllClickCount.index < endIndex){
						itemInfo += "/クリック数:" + execAllClickCount[1];
						gIndex = execAllClickCount.index;
					}else{
						//value not found
					}
					
				}else{
					//value not found
				}
				
				if(imageURL.indexOf("amazon") != -1){
					itemInfo += "\n(amazon.co.jp)";
				}else{
					itemInfo += "\n(Yahoo! JAPAN)";
				}
				
				array.addItem({
					col_image:imageURL,
					col_info:itemInfo,
					col_link:linkURL
				});
				
				gIndex = endIndex;
				
				
			}
			
			if(array.length == 0){
				array.addItem({
					col_info:"市場情報が存在しないか、\n市場情報の解析に失敗しました。"
				});
			}
			
			return array;
		}


	}
	
}