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
			
			var extension:String = videoFile.extension;
			if (extension != null) 
			{
				if (extension.toUpperCase() == "FLV")
				{
					httpResponse.contentType = "video/flv";
				}else if (extension.toUpperCase() == "MP4")
				{
					httpResponse.contentType = "video/mp4";
				}else if (extension.toUpperCase() == "SWF")
				{
					httpResponse.contentType = "application/x-shockwave-flash";
				}
			}
			
			var time:Number = new Date().time;
			
			var byteArray:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			try 
			{
				// TODO でかい動画(50MBとか)を同期で読み込むとGUIスレッドが止まるのでなんとかしたい
				// でもこのprocess()がreturnするとレスポンスが返っちゃうので要検討。
				fileStream.open(videoFile, FileMode.READ);
				fileStream.readBytes(byteArray);
				fileStream.close();
			}catch (error:Error)
			{
				try 
				{
					fileStream.close();	
				}
				catch (error:Error)
				{
					// nothing
				}
				trace(error.getStackTrace());
				httpResponse.statusCode = 500;
				return;
			}
			
			time = new Date().time - time;
			trace("送信にかかった時間:" + time + " ms");
			
			httpResponse.body = byteArray;
			httpResponse.statusCode = 200;
			
		}
	}
}