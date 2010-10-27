package org.mineap.nndd.playList
{
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.util.PathMaker;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class PlayListAnalyzer
	{
		public function PlayListAnalyzer()
		{
		}
		
		/**
		 * 渡された文字列をプレイリストとして解析し、その結果をVector.<NNDDVideo>に格納して返します。
		 * @param string
		 * @return 
		 * 
		 */
		public static function analyze(str:String):Vector.<NNDDVideo>{
			
			var videoArray:Vector.<NNDDVideo> = new Vector.<NNDDVideo>();
			
			var pattern1:RegExp = new RegExp("[^\\n]+", "ig");
			var pattern2:RegExp = new RegExp("#EXTINF:([\\d]*),(.*)");
			var playItems:Array = str.match(pattern1);
			
			for(var i:int = 0; i<playItems.length ; i++){
				try{
					if(playItems[i].indexOf("#") != 0){
						//コメントアウト部分ではない
						var filePath:String = String(playItems[i]);
						var video:NNDDVideo = new NNDDVideo(filePath);
						
						if(filePath.indexOf("http") != -1){
							var videoId:String = PathMaker.getVideoID(filePath);
							if(videoId != null){
								var thumbImgUrl:String = PathMaker.getThumbImgUrl(videoId);
								if(thumbImgUrl != null){
									video.thumbUrl = thumbImgUrl;
								}
							}
						}
						
						if((i+1)<playItems.length && playItems[i+1].indexOf("#EXTINF:") != -1){
							//ファイルパスの次が付加情報
							var array:Array = pattern2.exec(playItems[i+1]);
							if(array != null){
								video.time = array[1];//曲の長さ
								video.videoName = array[2];//タイトル
							}
							i++;
						}else{
							//違ったら次の行へ
						}
						
						videoArray.push(video);
						
					}
				}catch(error:Error){
					//読み込みエラー。スキップ。
					LogManager.instance.addLog("プレイリストが不正:Line=[" + i + "]");
					trace(error.getStackTrace());
				}
			}
			
			return videoArray;
			
		}
		
	}
}