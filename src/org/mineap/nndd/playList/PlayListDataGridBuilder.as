package org.mineap.nndd.playList
{
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.util.DateUtil;
	import org.mineap.nndd.util.PathMaker;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class PlayListDataGridBuilder
	{
		
		private var libraryManager:ILibraryManager = LibraryManagerBuilder.instance.libraryManager;
		
		public function PlayListDataGridBuilder()
		{
		}
		
		public function build(videos:Vector.<NNDDVideo>):ArrayCollection{
			
			var arrayCollection:ArrayCollection = new ArrayCollection();
			
			for each(var video:NNDDVideo in videos){
				var thumbUrl:String = "";
				var creationDate:String = "-";
				var pubDate:String = "-";
				var playCount:Number = 0;
				var status:String = "";
				var tempVideo:NNDDVideo = libraryManager.isExist(PathMaker.getVideoID(video.getDecodeUrl()));
				var time:Number = 0;
				
				if(tempVideo != null){
					video = tempVideo;
				}
				
				if(video.uri.indexOf("http://") != -1){
					status = "未ダウンロード";
				}
				
				thumbUrl = video.thumbUrl;
				if(video.creationDate != null){
					creationDate = DateUtil.getDateString(video.creationDate);
				}else{
					creationDate = "-";
				}
				if(video.pubDate != null){
					pubDate = DateUtil.getDateString(video.pubDate);
				}else{
					pubDate = "-";
				}
				playCount = video.playCount;
				if(thumbUrl == ""){
					thumbUrl = PathMaker.createThumbImgFilePath(video.getDecodeUrl(), true);
					
					try{
						if(!(new File(thumbUrl).exists)){
							thumbUrl = PathMaker.getThumbImgUrl(PathMaker.getVideoID(video.getDecodeUrl()));
						}
					}catch(error:Error){
						thumbUrl = PathMaker.getThumbImgUrl(PathMaker.getVideoID(video.getDecodeUrl()));
					}
				}
				
				time = video.time;
				var timeString:String = "-";
				if(time != 0){
					var m:String = String(int(time/60));
					var s:String = String(int(time%60));
					if(s.length == 1){
						s = "0" + s;
					}
					timeString = m + ":" + s;
				}
				
				arrayCollection.addItem({
					dataGridColumn_thumbImage: thumbUrl,
					dataGridColumn_videoName: video.getVideoNameWithVideoID(),
					dataGridColumn_date: creationDate,
					dataGridColumn_pubdate: pubDate,
					dataGridColumn_count: playCount,
					dataGridColumn_condition: status,
					dataGridColumn_time: timeString,
					dataGridColumn_videoPath: video.getDecodeUrl()
				});
			}
			
			return arrayCollection;
		}
		
	}
}