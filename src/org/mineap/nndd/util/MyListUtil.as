package org.mineap.nndd.util
{
	public class MyListUtil
	{
		
		public function MyListUtil()
		{
		}
		
		/**
		 * 渡された文字列からマイリストIDを探して返します。
		 * 
		 * @param string
		 * @return 
		 * 
		 */
		public static function getMyListId(string:String):String{
			
			var myListId:String = null;
			
			var pattern:RegExp = new RegExp("http://www.nicovideo.jp/mylist/(\\d*)");
			var array:Array = pattern.exec(string);
			if(array != null && array.length >= 1 && array[1].length >= 1){
				myListId = array[1];
				return myListId;
			}
			pattern = new RegExp("[mylist/]*(\\d+)");
			array = pattern.exec(string);
			if(array != null && array.length >= 1 && array[1].length >= 1){
				myListId = array[array.length-1];
				return myListId;
			}
			pattern = new RegExp("http://www.nicovideo.jp/my/mylist/#/(\\d*)");
			array = pattern.exec(string);
			if(array != null && array.length >= 1 && array[1].length >= 1){
				myListId = array[array.length-1];
				return myListId;
			}
			
			return myListId;
		}
		
		/**
		 * 
		 * @param string
		 * @return 
		 * 
		 */
		public static function getChannelId(string:String):String{
			
			var channelId:String = null;
			
			//http://ch.nicovideo.jp/channel/ben-to
			
			var pattern:RegExp = new RegExp("http://ch.nicovideo.jp/channel/(.+)");
			var array:Array = pattern.exec(string);
			if(array != null && array.length >= 1 && array[1].length >= 1){
				channelId = array[1];
				return channelId;
			}
			pattern = new RegExp("channel/(.+)");
			array = pattern.exec(string);
			if(array != null && array.length >= 1 && array[1].length >= 1){
				channelId = array[array.length-1];
				return channelId;
			}
			
			return channelId;
		}
		
	}
}