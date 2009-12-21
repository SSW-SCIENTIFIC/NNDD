package org.mineap.a2n4as
{
	/**
	 * ランキングのURLに関する定数を保持するクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class NicoRankingUrl
	{
		
		/**
		 * 毎日(期間)
		 */
		public static const DAILY:int = 0;
		
		/**
		 * 週間(期間)
		 */
		public static const WEEKLEY:int = 1;
		
		/**
		 * 月間(期間)
		 */
		public static const MONTHLY:int = 2;
		
		/**
		 * 毎時(期間)
		 */
		public static const HOURLY:int = 3;
		
		/**
		 * 合計(期間)
		 */
		public static const TOTAL:int = 4;
		
		/**
		 * 新着(期間)
		 */
		public static const NEWARRIVAL:int = 5;
		
		
		/**
		 * マイリスト数(種別)
		 */
		public static const MYLIST:int = 0;
		
		/**
		 * 再生数(種別)
		 */
		public static const VIEW:int = 1;
		
		/**
		 * コメント数(種別)
		 */
		public static const COMMENT:int = 2;
		
		/**
		 * 総合(種別)
		 */
		public static const FAV:int = 3;
		
		/**
		 * ニコニコ動画のランキングURLです。
		 * NICO_RANKING_URLS[ランキング期間][ランキング種別]で指定します。
		 */
		public static const NICO_RANKING_URLS:Array = new Array(
			new Array("http://www.nicovideo.jp/ranking/mylist/daily/","http://www.nicovideo.jp/ranking/view/daily/","http://www.nicovideo.jp/ranking/res/daily/","http://www.nicovideo.jp/ranking/fav/daily/"),
			new Array("http://www.nicovideo.jp/ranking/mylist/weekly/","http://www.nicovideo.jp/ranking/view/weekly/","http://www.nicovideo.jp/ranking/res/weekly/","http://www.nicovideo.jp/ranking/fav/weekly/"),
			new Array("http://www.nicovideo.jp/ranking/mylist/monthly/","http://www.nicovideo.jp/ranking/view/monthly/","http://www.nicovideo.jp/ranking/res/monthly/","http://www.nicovideo.jp/ranking/fav/monthly/"),
			new Array("http://www.nicovideo.jp/ranking/mylist/hourly/","http://www.nicovideo.jp/ranking/view/hourly/","http://www.nicovideo.jp/ranking/res/hourly/","http://www.nicovideo.jp/ranking/fav/hourly/"),
			new Array("http://www.nicovideo.jp/ranking/mylist/total/","http://www.nicovideo.jp/ranking/view/total/all/","http://www.nicovideo.jp/ranking/res/total/","http://www.nicovideo.jp/ranking/fav/total/"),
			new Array("http://www.nicovideo.jp/")
		);
		

	}
}