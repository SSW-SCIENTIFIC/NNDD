package org.mineap.nndd.model
{
	
	import org.mineap.nicovideo4as.model.SearchSortType;

	/**
	 * 検索ソート順の文字列を表現するクラスです。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class SearchSortString
	{
		
		/**
		 * 検索結果のソート順の文字列表現です
		 */
		public static const NICO_SEARCH_SORT_TEXT_ARRAY:Array = new Array(
			"投稿が新しい順","投稿が古い順","再生が多い順","再生が少ない順","コメントが多い順","コメントが少ない順","コメントが新しい順","コメントが古い順","マイリストが多い順","マイリストが少ない順","再生時間が長い順","再生時間が短い順"
		);
		
		/**
		 * 指定されたソート順文字列表現の配列インデックスから SearchSortType を返します。
		 * 
		 * @param index
		 * @return 
		 * 
		 */
		public static function convertSortTypeFromIndex(index:int):SearchSortType{
			return convertSortTypeFromString(NICO_SEARCH_SORT_TEXT_ARRAY[index]);
		}
		
		/**
		 * 指定されたソート順の文字列表現から SearchSortType を返します。
		 * 
		 * @param text
		 * @return 
		 * 
		 */
		public static function convertSortTypeFromString(text:String):SearchSortType{
			
			for(var index:int=0 ; NICO_SEARCH_SORT_TEXT_ARRAY.length > index; index++){
				if(NICO_SEARCH_SORT_TEXT_ARRAY[index] == text){
					var order:int = SearchSortType.ORDER_D;
					if((index % 2) == 1){
						// 2で割ったあまりが1
						order = SearchSortType.ORDER_A;
					}
					
					return new SearchSortType(index, order);
				}
			}
			
			return new SearchSortType(SearchSortType.COMMENT_COUNT, SearchSortType.ORDER_D);
		}
		
		/**
		 * SearchSortTypeから対応するNICO_SEARCH_SORT_TEXT_ARRAYのインデックスを返します
		 * @param searchSortType
		 * @return 
		 * 
		 */
		public static function convertTextArrayIndexFromSearchSortType(searchSortType:SearchSortType):int{
			var index:int = 0;
			index = searchSortType.sort;
			index += searchSortType.order;
			return index;
		}
		
	}
}