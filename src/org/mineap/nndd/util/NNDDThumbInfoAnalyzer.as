package org.mineap.nndd.util
{

	import org.mineap.nicovideo4as.analyzer.ThumbInfoAnalyzer;
	import org.mineap.nicovideo4as.util.HtmlUtil;
	import org.mineap.nndd.Message;
	
	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class NNDDThumbInfoAnalyzer extends ThumbInfoAnalyzer
	{
		
		/**
		 * 
		 * @param xml
		 * 
		 */
		public function NNDDThumbInfoAnalyzer(xml:XML)
		{
			super(xml);
		}
		
		/**
		 * HTML形式の動画のタイトルを返します。
		 * @return 
		 * 
		 */
		public function get htmlTitle():String{
			if(this.status == "ok"){
				return "<a href=\"http://www.nicovideo.jp/watch/" + videoId + "\"><u><font color=\"#0000ff\">" + title + "</font></u></a>";
			}else{
				return "(削除されています)";
			}
		}
		
		/**
		 * 「再生:(数字) コメント:(数字)　マイリスト:(数字)」という形式の文字列を返します。
		 * @return 
		 * 
		 */
		public function get playCountAndCommentCountAndMyListCount():String{
			if(this.status == "ok"){
				return "再生:" + viewCounter + " コメント:" + commentNum + " マイリスト:" + myListNum;
			}else{
				return "再生:- コメント:- マイリスト:-";
			}
			
		}
		
		/**
		 * 投稿者説明文の動画IDおよびマイリストIDをリンクに置き換えた文字列を返します。
		 * @return 
		 * 
		 */
		public function get thumbInfoHtml():String{

			var returnString:String = "";
			
			if(errorCode == "DELETED"){
				returnString = "(削除されています)";
			} if (errorCode == "NOT_FOUND" ){
				returnString = "(見つかりませんでした)";
			}else{
				if(this.description != null){
					returnString = ThumbInfoUtil.encodeThumbInfo(this.description);
				}else{
					returnString = errorCode;
				}
			}
			
			return returnString;
		}
		

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get commentNumString():String
		{
			return NumberUtil.addComma(String(commentNum));
		}

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get viewCounterString():String
		{
			return NumberUtil.addComma(String(viewCounter));
		}

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get myListNumString():String
		{
			return NumberUtil.addComma(String(myListNum));
		}

	}
}