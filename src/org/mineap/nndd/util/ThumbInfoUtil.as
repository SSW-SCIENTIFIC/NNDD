package org.mineap.nndd.util
{
	import org.mineap.nicovideo4as.util.VideoTypeUtil;

	/**
	 * 
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class ThumbInfoUtil
	{
		public function ThumbInfoUtil()
		{
		}
		
		/**
		 * 渡されたStringのマイリストID、ユーザーID、動画IDをNNDD用のHTML表現に置き換えて返します。
		 * @param text
		 * @return 
		 * 
		 */
		public static function encodeThumbInfo(text:String):String{
			
			var myLists:Array = new Array();
			var users:Array = new Array();
			
			var myList_pattern:RegExp = new RegExp("<a href=\"http://www.nicovideo.jp/mylist/\\d+\"[^>]*>(mylist/\\d+)</a>|(mylist/\\d+)", "ig");
			var user_pattern:RegExp = new RegExp("<a href=\"http://www.nicovideo.jp/user/\\d+\"[^>]*>(user/\\d+)</a>|(user/\\d+)", "ig");
			var videoId_pattern:RegExp = new RegExp("<a href=\"http://www.nicovideo.jp/watch/[^\"]+\"[^>]*>([^<]+)</a>|" + VideoTypeUtil.VIDEO_ID_WITHOUT_NUMONLY_SEARCH_PATTERN_STRING, "ig");
			
			var returnString:String = text.replace(myList_pattern, replFN_mylist);
			
			function replFN_mylist():String{
				var str:String = arguments[0];
				if(arguments.length>1 && arguments[1] != "" ){
					str = arguments[1];
				}
				myLists.push(str);
				return "<a href=\"event:" + str + "\"><u><font color=\"#0000ff\">" + str + "</font></u></a>";
			}
			
			returnString = returnString.replace(user_pattern, replFN_user);
			
			function replFN_user():String{
				var str:String = arguments[0];
				if(arguments.length>1 && arguments[1] != "" ){
					str = arguments[1];
				}
				users.push(str);
				return "<a href=\"http://www.nicovideo.jp/" + str + "\"><u><font color=\"#0000ff\">" + str + "</font></u></a>";
			}
			
			returnString = returnString.replace(videoId_pattern, replFN);
			
			function replFN():String {
				
				var htmltag:String = arguments[0];
				var videoId:String = arguments[1];
				
				if(videoId != null && videoId == ""){
					videoId = arguments[0];
				}
				
				//color="#0000ff"を見つけたときはスキップ
				if(videoId == "0000"){
					return arguments[0];
				}
				
				//マイリストとして登録済みならスキップ
				// TODO この方法だとマイリストと同じ番号を持つ動画にたいしてはリンクが設定されないが、その可能性は低いので問題はないとする。
				for each(var mylist:String in myLists){
					var id:String = mylist.substring(7);
					if(id == videoId){
						return arguments[0];
					}
				}
				
				for each(var user:String in users){
					var userid:String = user.substring(5);
					if(userid == videoId){
						return arguments[0];
					}
				}
				
				return "<a href=\"event:watch/" + videoId + "\"><u><font color=\"#0000ff\">" + videoId + "</font></u></a>";
				
			}
			
			return returnString;
			
		}
	}
}