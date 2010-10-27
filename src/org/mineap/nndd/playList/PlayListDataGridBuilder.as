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
				var playCount:Number = 0;
				var status:String = "";
				var tempVideo:NNDDVideo = libraryManager.isExist(PathMaker.getVideoID(video.getDecodeUrl()));
				
				if(tempVideo != null){
					video = tempVideo;
				}
				
				if(video.uri.indexOf("http://") != -1){
					status = "未ダウンロード";
				}
				
				thumbUrl = video.thumbUrl;
				creationDate = DateUtil.getDateString(video.creationDate);
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
				
				arrayCollection.addItem({
					dataGridColumn_thumbImage: thumbUrl,
					dataGridColumn_videoName: video.getVideoNameWithVideoID(),
					dataGridColumn_date: creationDate,
					dataGridColumn_count: playCount,
					dataGridColumn_condition: status,
					dataGridColumn_videoPath: video.getDecodeUrl()
				});
			}
			
			return arrayCollection;
		}
		
	}
}