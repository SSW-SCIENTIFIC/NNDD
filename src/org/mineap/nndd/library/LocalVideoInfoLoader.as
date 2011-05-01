package org.mineap.nndd.library
{
	import flash.filesystem.File;
	
	import org.mineap.nndd.FileIO;
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.util.DateUtil;
	import org.mineap.nndd.util.LibraryUtil;
	import org.mineap.nndd.util.PathMaker;
	
	
	/**
	 * 
	 * @author shiraminekeisuke (MineAP)
	 * 
	 */
	public class LocalVideoInfoLoader
	{
		
		/**
		 * 
		 */
		private var logManager:LogManager = LogManager.instance;
		
		/**
		 * 
		 * 
		 */
		public function LocalVideoInfoLoader()
		{
		}
		
		/**
		 * ライブラリへの登録に必要な情報をロードし、その情報を格納したNNDDVideoオブジェクトを返します。
		 * また、古いライブラリ情報から動画がエコノミーモードかどうかもチェックし、該当するVideoがあればそのデータを反映します。
		 * 
		 * @param filePath
		 * @return 収集した結果のNNDDVideoオブジェクト。失敗した場合はnullを返す。
		 * 
		 */
		public function loadInfo(filePath:String):NNDDVideo{
			var fileIO:FileIO = new FileIO(logManager);
			var thumbInfoXML:XML = fileIO.loadXMLSync(PathMaker.createThmbInfoPathByVideoPath(filePath), true);
			
			var file:File = null;
			
			var thumbUrl:String = "";
			var pubDate:Date = null;
			var time:Number = 0;
			if(thumbInfoXML == null){
				
				try{
					file = new File(filePath);
					if(!file.exists){
						trace("file not found:" + filePath);
						return null;
					}
				}catch(error:Error){
					trace(error.getStackTrace());
					return null;
				}
				
				var id:String = PathMaker.getVideoID(file.name);
				
				if(id != null && id != ""){
					thumbUrl = PathMaker.getThumbImgUrl(id);
				}
				
				return new NNDDVideo(file.url, file.name, false, null, file.modificationDate, file.creationDate, thumbUrl, 0, time, null, null);
				
			}
			
			var tagArray:Vector.<String> = new Vector.<String>;
			if(thumbInfoXML != null && thumbInfoXML.attribute("status") == "ok"){
				var tags:XMLList = thumbInfoXML.thumb.tags;
				for(var i:int=0; i<tags.tag.length(); i++){
					tagArray.push((tags.tag[i] as XML).toString());
				}
				thumbUrl = thumbInfoXML.thumb.thumbnail_url;
				var lengthString:String = thumbInfoXML.thumb.length;
				if(lengthString != null && lengthString.length > 0){
					time = DateUtil.getTimeForThumbXML(lengthString);
				}
				pubDate = DateUtil.getDateForThumbXML(thumbInfoXML.thumb.first_retrieve);
			}else{
				// サムネイル情報が存在しない時、もしくは動画が削除されているときは、既存の動画からタグ情報を取得
				var tempVideo:NNDDVideo = LibraryManagerBuilder.instance.libraryManager.isExist(LibraryUtil.getVideoKey(decodeURIComponent(filePath)));
				if(tempVideo != null){
					tagArray = tempVideo.tagStrings;
				}
			}
			
			var video:NNDDVideo = new NNDDVideo(filePath, null, false, tagArray, null, null, null, 0, time, null, pubDate);
			file = new File(filePath);
			if(file.exists){
				video.creationDate = file.creationDate;
				video.modificationDate = file.modificationDate;
			}else{
				video.creationDate = new Date();
				video.modificationDate = new Date();
			}
			
			//thumbUrlが指定されていなければThumbXMLの値を設定
			var localThumbUrl:String = PathMaker.createThumbImgFilePath(video.getDecodeUrl(), true);
			if((new File(localThumbUrl)).exists){
				//ローカルにサムネイルがあればそれを使う
				video.thumbUrl = localThumbUrl;
			}else if( thumbUrl != null){
				//無ければthumbXMLのurlを使う
				video.thumbUrl = thumbUrl;
			}
			
			if(thumbUrl == null || thumbUrl == ""){
				//無ければ自動生成
				var videoID:String = PathMaker.getVideoID(video.getVideoNameWithVideoID());
				if(videoID != null && videoID != "" ){
					video.thumbUrl = PathMaker.getThumbImgUrl(videoID);
				}
			}
			
			var key:String = LibraryUtil.getVideoKey(video.getDecodeUrl());
			if(key != null){
				var oldVideo:NNDDVideo = LibraryManagerBuilder.instance.libraryManager.isExist(key);
				if(oldVideo != null){
					video.isEconomy = oldVideo.isEconomy;
					video.playCount = oldVideo.playCount;
				}
			}
			
			return video;
			
		}
	}
}