package org.mineap.nndd.myList
{
	import org.mineap.nndd.util.MyListUtil;
	

	/**
	 * マイリストを表現するクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class MyList
	{
		
		/**
		 * マイリストのURLです<br>
		 * ただし、URLとは限りません。URL以外にも、mylist/*****や、*****の形式である事があります。
		 */
		public var myListUrl:String = "";
		
		/**
		 * NNDD上で管理するためのマイリストの名前です
		 */
		public var myListName:String = "";
		
		/**
		 * このマイリストオブジェクトがディレクトリを表すかどうかです。
		 */
		public var isDir:Boolean = false;
		
		/**
		 * 未読動画数
		 */
		public var unPlayVideoCount:int = 0;
		
		/**
		 * コンストラクタ。
		 * 
		 * @param myListUrl
		 * @param myListName
		 * 
		 */
		public function MyList(myListUrl:String, myListName:String, isDir:Boolean = false)
		{
			if(myListUrl != null){
				this.myListUrl = myListUrl;
			}
			if(myListName != null){
				this.myListName = myListName;
			}
			
			this.isDir = isDir;
		}
		
		/**
		 * 
		 */
		public function get myListId():String{
			return MyListUtil.getMyListId(myListUrl);
		}
		
	}
}