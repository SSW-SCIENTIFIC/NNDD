package org.mineap.a2n4as.util
{
	
	import org.mineap.a2n4as.model.RankingItem;
	
	/**
	 * 
	 * ランキングRSSの取得結果を解析するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class RankingAnalyzer
	{
		
		private var _rankingItems:Vector.<RankingItem> = new Vector.<RankingItem>();
		
		/**
		 * 
		 * 
		 */
		public function RankingAnalyzer()
		{
		}
		
		/**
		 * 
		 * @param xml
		 * @return 
		 * 
		 */
		public function analyze(xml:XML):Boolean{
			
			try{
				
				var channel:XML = xml.channel[0];
				
				var i:int = 0;
				for each(var item:XML in channel.item){
					
					var rankingItem:RankingItem = new RankingItem(
						item.title, 
						item.link, 
						item.guid, 
						item.pubDate, 
						item.description.text());
					
					_rankingItems[i] = rankingItem;
					
					i++;
					
				}
				
			}catch(error:Error){
				trace(error.getStackTrace());
				return false;
			}
			
			return true;
			
		}

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get rankingItems():Vector.<RankingItem>
		{
			return _rankingItems;
		}
		
	}
}