package org.mineap.nndd.util
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nicovideo4as.WatchVideoPage;

	/**
	 * ニコニコ動画以外のウェブサービスへのアクセスを行うユーティリティクラスです
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class WebServiceAccessUtil
	{
		public function WebServiceAccessUtil()
		{
		}
		
		public static function openNiconicoDougaForVideo(videoId:String):void{
			var url:String = null;
			if(videoId != null){
				url = WatchVideoPage.WATCH_VIDEO_PAGE_URL + videoId;
				navigateToURL(new URLRequest(url));
				LogManager.instance.addLog("ウェブブラウザで開く:" + url);
			}
		}
		
		/**
		 * 
		 * @param videoId
		 * 
		 */
		public static function openNicomimi(videoId:String):void{
			var url:String = null;
			
			if(videoId != null){
				url = "http://www.nicomimi.net/play/" + videoId;
				navigateToURL(new URLRequest(url));
				LogManager.instance.addLog("nicomimi-にこみみ-で開く:" + url);
			}
		}
		
		/**
		 * 
		 * @param videoId
		 * 
		 */
		public static function openNicoSound(videoId:String):void{
			var url:String = null;
			
			if(videoId != null){
				url = "http://nicosound.anyap.info/sound/" + videoId;
				navigateToURL(new URLRequest(url));
				LogManager.instance.addLog("にこ☆さうんど#で開く:" + url);
			}
		}
		
		/**
		 * 
		 * @param videoId
		 * @param title
		 * 
		 */
		public static function addHatenaBookmark(videoId:String, title:String):void{
			var url:String = null;
			
			if(videoId != null){
				url = "http://www.nicovideo.jp/watch/" + videoId;
				navigateToURL(new URLRequest("http://b.hatena.ne.jp/add?mode=confirm&is_bm=1&title=" + encodeURIComponent(title) + "&url=" + url));
				LogManager.instance.addLog("はてなダイアリーに登録:" + title + ":" + url);
			}
		}
		
		/**
		 * 
		 * @param videoId
		 * @param title
		 * 
		 */
		public static function tweet(videoId:String, title:String):void{
			var tweet:String = "";
			var url:String = "";
			
			if(videoId != null){
				url = "http://nico.ms/" + videoId + " #nicovideo #nndd #" + videoId;
			
				var index:int = title.indexOf("- [");
				if(index > 0){
					title = title.substr(0, index);
				}
				
				tweet = title + " " + url;
				
				navigateToURL(new URLRequest("http://twitter.com/home/?status=" + encodeURIComponent(tweet)));
				LogManager.instance.addLog("twitterでつぶやく:" + title);
			}
		}
		
	}
}