package org.mineap.nndd.server
{
	import com.tilfin.airthttpd.events.BlockResponseSignal;
	import com.tilfin.airthttpd.server.HttpResponse;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.model.NNDDVideo;
	
	public class GetVideoDataProcess 
	{
		
		private var buffer:ByteArray = new ByteArray();
		
		private var httpResponse:HttpResponse;
		
		public function GetVideoDataProcess()
		{
		}
		
		public function process(videoId:String, httpResponse:HttpResponse):void
		{
			var libraryManager:ILibraryManager = LibraryManagerBuilder.instance.libraryManager;
			
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
			
			LogManager.instance.addLog("動画の配信を開始:id=" + videoId + ", " + videoFile.size + " bytes");
			
			var fileStream:FileStream = new FileStream();
			try 
			{
				// TODO でかい動画(50MBとか)を同期で読み込むとGUIスレッドが止まるのでなんとかしたい
				// でもこのprocess()がreturnするとレスポンスが返っちゃうので要検討。
				
				fileStream.addEventListener(Event.COMPLETE, fileInputCompleteHandler);
				fileStream.addEventListener(IOErrorEvent.IO_ERROR, fileInputIOErrorHandler);
				fileStream.addEventListener(ProgressEvent.PROGRESS, fileInputProgressHandler);
				
				fileStream.openAsync(videoFile, FileMode.READ);
				fileStream.readBytes(buffer);
				
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
			
			this.httpResponse = httpResponse;
			
			httpResponse.comet = true;
			throw new BlockResponseSignal();
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		protected function fileInputProgressHandler(event:ProgressEvent):void
		{
			var fileStream:FileStream = (event.currentTarget as FileStream);
			
			if (fileStream.bytesAvailable <= 0)
			{
				return;
			}
			
			fileStream.readBytes(buffer, buffer.length);
			
			if (buffer.length > 100000)
			{
				trace(event);
				httpResponse.httpConnection.socket.writeBytes(buffer, 0, buffer.length);
				buffer.clear();
			}
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		protected function fileInputIOErrorHandler(event:IOErrorEvent):void
		{
			trace(event);
			LogManager.instance.addLog("動画の配信に失敗:" + event);
			try 
			{
				var fileStream:FileStream = (event.currentTarget as FileStream);
				fileStream.close();
			}catch (error:Error)
			{
				trace(error.getStackTrace());
			}
			
			httpResponse.statusCode = 500;
			httpResponse.completeComet();
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		protected function fileInputCompleteHandler(event:Event):void
		{
			trace(event);
			LogManager.instance.addLog("動画の配信を完了");
			
			var fileStream:FileStream = (event.currentTarget as FileStream);
			
			if (fileStream.bytesAvailable > 0)
			{
				fileStream.readBytes(buffer, buffer.length);
				
				httpResponse.httpConnection.socket.writeBytes(buffer, 0, buffer.length);
				buffer.clear();
			}
			
			httpResponse.statusCode = 200;
			httpResponse.completeComet();
			
		}		
		
	}
}