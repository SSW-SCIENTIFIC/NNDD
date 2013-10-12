package org.mineap.nndd.model
{
	import org.mineap.nicovideo4as.model.search.SearchSortType;

	/**
	 * NNDDSearchSortType.as<br>
	 * NNDDSearchSortTypeクラスは、検索結果のソート順に関する定数を保持するクラスです。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.<br>
	 *  
	 * @author shiraminekeisuke
	 * 
	 */
	public class NNDDSearchSortType
	{
		
		/**
		 * 投稿日時
		 */
		public static const CONTRIBUTE:int = 0;
		/**
		 * 再生数
		 */
		public static const PLAY_COUNT:int = 1;
		/**
		 * コメント数
		 */
		public static const COMMENT_COUNT:int = 2;
		/**
		 * コメント日時
		 */
		public static const COMMENT_TIME:int = 3;
		/**
		 * マイリスト
		 */
		public static const MYLIST_COUNT:int = 4;
		/**
		 * 再生時間
		 */
		public static const PLAY_TIME:int = 5;
		
		
		/**
		 * 降順 (descending) 新しい、多い、長い
		 */
		public static const ORDER_D:int = 0;
		/**
		 * 昇順 (ascending) 古い、少ない、短い
		 */
		public static const ORDER_A:int = 1;
		
		/*------- ↓ ココから検索実行時に使う文字 ----------*/
		
		/**
		 * 
		 */
		public static const CONTRIBUTE_STRING:String = "f";
		/**
		 * 
		 */
		public static const PLAY_COUNT_STRING:String = "v";
		/**
		 * 
		 */
		public static const COMMENT_COUNT_STRING:String = "r";
		/**
		 * 
		 */
		public static const COMMENT_TIME_STRING:String = "n";
		/**
		 * 
		 */
		public static const MYLIST_COUNT_STRING:String = "m";
		/**
		 * 
		 */
		public static const PLAY_TIME_STRING:String = "l";
		
		/**
		 * 
		 */
		public static const ORDER_D_STRING:String = "d";
		/**
		 * 
		 */
		public static const ORDER_A_STRING:String = "a"
		
		/**
		 * 指定されたintのソート順序をnicovideo4asのSearchSortTypeに変換して返します
		 * 
		 * @param type
		 * @return 
		 * 
		 */
		public static function convertSortTypeNumToN4A(type:int):org.mineap.nicovideo4as.model.search.SearchSortType{
			
			var typeStr:org.mineap.nicovideo4as.model.search.SearchSortType = org.mineap.nicovideo4as.model.search.SearchSortType.MYLIST_COUNTER;
			
			switch(type){
				case COMMENT_TIME:
					typeStr = org.mineap.nicovideo4as.model.search.SearchSortType.NEW_COMMENT;
					break;
				case PLAY_COUNT:
					typeStr = org.mineap.nicovideo4as.model.search.SearchSortType.VIEW_COUNTER;
					break;
				case COMMENT_COUNT:
					typeStr = org.mineap.nicovideo4as.model.search.SearchSortType.NUM_RES;
					break;
				case MYLIST_COUNT:
					typeStr = org.mineap.nicovideo4as.model.search.SearchSortType.MYLIST_COUNTER;
					break;
				case CONTRIBUTE:
					typeStr = org.mineap.nicovideo4as.model.search.SearchSortType.FIRST_RETRIVE;
					break;
				case PLAY_TIME:
					typeStr = org.mineap.nicovideo4as.model.search.SearchSortType.LENGTH;
					break;
			}
			
			return typeStr;
		}
		
		/**
		 * 指定されたオーダーのint表現に対応するnicovideo4asのSearchOrderTypeを返します
		 *  
		 * @param order
		 * @return 
		 * 
		 */
		public static function convertSortOrderTypeNumToN4A(order:int):org.mineap.nicovideo4as.model.search.SearchOrderType{
			if(order == ORDER_A){
				return org.mineap.nicovideo4as.model.search.SearchOrderType.ASCENDING;
			}
			return org.mineap.nicovideo4as.model.search.SearchOrderType.DESCENDING;
		}
		
		/**
		 * 
		 */
		public var sort:int = 0;
		
		/**
		 * 
		 */
		public var order:int = 0;
		
		/**
		 * 
		 * @param sort
		 * @param order
		 * 
		 */
		public function NNDDSearchSortType(sort:int, order:int)
		{
			this.sort = sort;
			this.order = order
		}
	}
}