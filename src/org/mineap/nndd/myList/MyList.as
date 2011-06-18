package org.mineap.nndd.myList
{
	import org.mineap.nndd.model.NNDDVideo;
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
		 * マイリストに登録されている動画IDの一覧
		 */
		private var myListVideoIds:Object = new Object();
		
		/**
		 * コンストラクタ。
		 * 
		 * @param myListUrl
		 * @param myListName
		 * @param isDir
		 * @param videoIds
		 */
		public function MyList(myListUrl:String, myListName:String, isDir:Boolean = false, videoIds:Vector.<String> = null)
		{
			if(myListUrl != null){
				this.myListUrl = myListUrl;
			}
			if(myListName != null){
				this.myListName = myListName;
			}
			
			this.isDir = isDir;
			
			if (videoIds != null)
			{
				for each(var id:String in videoIds)
				{
					myListVideoIds[id] = id;
				}
			}
		}
		
		/**
		 * このマイリストのマイリストIDを返します
		 * @return 
		 * 
		 */
		public function get myListId():String{
			return MyListUtil.getMyListId(myListUrl);
		}
		
		/**
		 * このマイリストオブジェクトに、指定された動画IDを登録します
		 * 
		 * @param video
		 * 
		 */
		public function addNNDDVideoId(videoId:String):void
		{
			if(videoId == null)
			{
				myListVideoIds[videoId] = videoId;
			}
		}
		
		/**
		 * このマイリストオブジェクトから、指定された動画IDを取り除きます
		 * 
		 * @param videoId
		 * 
		 */
		public function deleteNNDDVideoId(videoId:String):void
		{
			if(videoId == null)
			{
				delete myListVideoIds[videoId];
			}
		}
		
		/**
		 * このマイリストオブジェクトが保持する動画IDを全てクリアします
		 * 
		 */
		public function clearNNDDVideoId():void
		{
			myListVideoIds = new Object();
		}
		
		/**
		 * 指定された動画IDがこのマイリストに登録されているかどうか調べます
		 * 
		 * @param videoId
		 * @return 
		 * 
		 */
		public function contains(videoId:String):Boolean
		{
			if (myListVideoIds[videoId] != null)
			{
				return true;
			}
			return false;
		}
		
	}
}