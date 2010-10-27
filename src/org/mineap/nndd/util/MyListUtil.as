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
			
			var pattern:RegExp = new RegExp("http://www.nicovideo.jp/mylist/(\\d*)", "ig");
			var array:Array = pattern.exec(string);
			if(array != null && array.length >= 1){
				myListId = array[1];
			}
			pattern = new RegExp("[mylist/]*(\\d+)", "ig");
			array = pattern.exec(string);
			if(array != null && array.length >= 1 && array[1].length >= 1){
				myListId = array[array.length-1];
			}
			
			return myListId;
		}
		
	}
}