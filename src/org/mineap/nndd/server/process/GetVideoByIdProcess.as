package org.mineap.nndd.server.process
{
	import com.tilfin.airthttpd.server.HttpResponse;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import org.mineap.nndd.FileIO;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.server.IRequestProcess;
	
	/**
	 * ID指定の動画取得APIが呼ばれたときの処理です
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class GetVideoByIdProcess implements IRequestProcess
	{
		public function GetVideoByIdProcess()
		{
		}
		
		public function process(requestXml:XML, httpResponse:HttpResponse):void
		{
			
			var libraryManager:ILibraryManager = LibraryManagerBuilder.instance.libraryManager;
			
			var videoId:String = requestXml.video.@id;
			
			if (videoId == null)
			{
				httpResponse.statusCode = 404;
				return;
			}
			
			var video:NNDDVideo = libraryManager.isExistByVideoId(videoId);
			
			if (video == null)
			{
				httpResponse.statusCode = 404;
				return;
			}
			
			var videoFile:File = video.file;
			
			if (videoFile == null || !videoFile.exists)
			{
				httpResponse.statusCode = 404;
				return;
			}
			
			var videoUrl:String = "http://" + httpResponse.httpRequest.host + "/NNDDServer/" + video.key;
			
			var resXML:XML = <nnddResponse />;

			resXML.video.@id = video.id;
			resXML.video.@isEconomy = video.isEconomy;
			resXML.video.@videoUrl = videoUrl;
			if (videoFile.extension != null) 
			{
				resXML.video.@extension = videoFile.extension;
			}
			resXML.video.appendChild(video.videoName);
			
			httpResponse.body = resXML.toXMLString();
			httpResponse.statusCode = 200;
			return;
			
		}
	}
}