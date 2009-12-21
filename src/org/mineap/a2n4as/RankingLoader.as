package org.mineap.a2n4as
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	
	[Event(name="success", type="Event")]
	[Event(name="fail", type="ErrorEvent")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * ニコニコ動画のランキングRSSへのアクセスを担当するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 */
	public class RankingLoader extends EventDispatcher
	{
		
		private var _rankingLoader:URLLoader;
		
		private var _result:XML;
		
		public static const SUCCESS:String = "Success";
		
		public static const FAIL:String = "Fail";
		
		/**
		 * 
		 * 
		 */
		public function RankingLoader()
		{
			this._rankingLoader = new URLLoader();
		}
		
		/**
		 * 指定された期間、種別からURLを生成し、ランキングにアクセスします。
		 * 期間、種別は{@link NicoRankingUrl}を参照してください。
		 * 
		 * @param period NicoRankingUrlクラスの期間に関するプロパティを参照してください。
		 * @param target NicoRankingUrlクラスの種別に関するプロパティを参照してください。
		 * @param pageCount ページ番号 「?page=」の後に付ける数字を指定します。0および1の場合は1ページ目です。デフォルトでは1です。
		 * @param category カテゴリを表す文字列を指定します。例えば"all"や"music"です。デフォルトではall（総合）です。
		 * 
		 */
		public function getRanking(period:int, target:int, pageCount:int = 1, category:String = "all"):void{
			
			var request:URLRequest = new URLRequest(NicoRankingUrl.NICO_RANKING_URLS[period][target] + category);
			
			var variables:URLVariables = new URLVariables();
			variables.page = pageCount;
			variables.rss = "2.0";
			
			request.data = variables;
			
			this._rankingLoader.addEventListener(Event.COMPLETE, getRankingSuccess);
			this._rankingLoader.addEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			this._rankingLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
			this._rankingLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._rankingLoader.load(request);
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function getRankingSuccess(event:Event):void{
			try{
				this._result = new XML(event.currentTarget.data);
			}catch(error:Error){
				trace(error.getStackTrace());
				dispatchEvent(new ErrorEvent(FAIL, false, false, error.toString()));
			}
			dispatchEvent(new Event(SUCCESS));
			removeAllHandler();
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function errorEventHandler(event:ErrorEvent):void{
			dispatchEvent(new ErrorEvent(FAIL, false, false, event.text));
			removeAllHandler();
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseStatusEventHandler(event:HTTPStatusEvent):void{
			dispatchEvent(event);
		}
		
		/**
		 * 
		 * @param target
		 * 
		 */
		private function removeAllHandler():void{
			this._rankingLoader.removeEventListener(Event.COMPLETE, getRankingSuccess);
			this._rankingLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHandler);
			this._rankingLoader.removeEventListener(IOErrorEvent.IO_ERROR, errorEventHandler);
			this._rankingLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorEventHandler);
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			try{
				this._rankingLoader.close();
			}catch(error:Error){
				
			}
			removeAllHandler();
		}

		/**
		 * 取得した結果を表すXMLです。取得に失敗した場合はnullを返します。<br />
		 * (例)
		 * <pre>
		 * <rss>
		 *   <channel>
		 *     <item>
		 *       ...
		 *     </item>
		 *     <item>
		 *       <title>第100位：【バトレボ実況】第二十六回 厨ポケ狩り講座！-講師の休日-</title>
		 *       <link>http://www.nicovideo.jp/watch/sm8988717</link>
		 *       <guid isPermaLink="false">tag:nicovideo.jp,2009-12-03:/watch/sm8988717</guid>
		 *       <pubDate>Mon, 07 Dec 2009 06:00:00 +0900</pubDate>
		 *       <description><![CDATA[
		 *         <p class="nico-thumbnail"><img alt="【バトレボ実況】第二十六回 厨ポケ狩り講座！-講師の休日-" src="http://tn-skr2.smilevideo.jp/smile?i=8988717" width="94" height="70" border="0"/></p>
		 *         <p class="nico-description">冒頭の謝罪は涙腺注意かと。　　　・お蔵入り予定だった試合を適当につなげたものです。所々おかしいこと言ってますが気にしないでください。内容は良いはずなんで。・アットマーク云々の件は、sm8436970で解決しております。・動画時間長くて画質音質共に悪いですが演出だと思ってもらえれば　前回sm8949325　次回→木曜までに　マイリスmylist/12734389　■大会開催中。詳細はブログhttp://blog.livedoor.jp/f_liszt_/　大会マイリスmylist/15663523</p>
		 *         <p class="nico-info"><small><strong class="nico-info-number">90,999</strong>pts.｜<strong class="nico-info-length">28:43</strong>｜<strong class="nico-info-date">2009年12月03日 19：12：21</strong> 投稿<br/><strong>合計</strong>　再生：<strong class="nico-info-total-view">63,422</strong>　コメント：<strong class="nico-info-total-res">21,657</strong>　マイリスト：<strong class="nico-info-total-mylist">755</strong><br/><strong>週間</strong>　再生：<strong class="nico-info-weekly-view">63,422</strong>　コメント：<strong class="nico-info-weekly-res">21,657</strong>　マイリスト：<strong class="nico-info-weekly-mylist">755</strong><br/></small></p>
		 *       ]]></description>
		 *     </item>
		 *   </channel>
		 * </rss>
		 * </pre>
		 * @return 
		 * 
		 */
		public function get result():XML
		{
			return _result;
		}
		


	}
}