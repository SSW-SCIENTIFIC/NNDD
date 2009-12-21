package org.mineap.a2n4as.model
{
	/**
	 *
	 * ランキングの一項目を表現するクラスです。
	 *  
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class RankingItem
	{
		
		private var _title:String = null;
		
		private var _link:String = null;
		
		private var _guid:String = null;
		
		private var _pubDate:String = null;
		
		private var _description:String = null;
		
		/**
		 * 
		 * @param title 動画のタイトル
		 * @param link 動画へのリンク
		 * @param guid GUID
		 * @param pubDate 投稿日
		 * @param description 説明文
		 * 
		 */
		public function RankingItem(title:String, link:String, guid:String, pubDate:String, description:String)
		{
			
			this._title = title;
			this._link = link;
			this._guid = guid;
			this._pubDate = pubDate;
			this._description = description;
			
		}

		public function get title():String
		{
			return _title;
		}

		public function get link():String
		{
			return _link;
		}

		public function get guid():String
		{
			return _guid;
		}

		public function get pubDate():String
		{
			return _pubDate;
		}

		public function get description():String
		{
			return _description;
		}


	}
}