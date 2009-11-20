package org.mineap.a2n4as
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * 
	 */
	public class RankingLoader
	{
		
		private var _rankingLoader:URLLoader;
		
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
			
			var request:URLRequest = new URLRequest(NicoRankingUrl.NICO_RANKING_URLS[period][target] + category + "?page=" + pageCount);
			
			this._rankingLoader.load(request);
			
		}
		
		/**
		 * URLLoaderにリスナを追加します。
		 * @param event
		 * @param listener
		 * 
		 */
		public function addEventListener(event:String, listener:Function):void{
			this._rankingLoader.addEventListener(event, listener);
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
		}
		


	}
}