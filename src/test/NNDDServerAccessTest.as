package test
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.OutputProgressEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	
	import org.mineap.nndd.server.RequestType;

	public class NNDDServerAccessTest
	{
		public function NNDDServerAccessTest(test:Test)
		{
		}
		
		
		public function test_myList():void
		{
			
			var nnddRequest:XML = new XML("<nnddRequest></nnddRequest>");
//				nnddRequest.@type = RequestType.GET_MYLIST_LIST.typeStr;
				nnddRequest.@type = RequestType.GET_MYLIST_BY_ID.typeStr;
				nnddRequest.rss.@id = "434361";
				nnddRequest.rss.@rssType = "MY_LIST";
			
			var request:URLRequest = new URLRequest("http://localhost:12300/NNDDServer");
			request.method = "POST";
			request.data = nnddRequest.toXMLString();
			
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, function(event:Event):void
			{
				trace(urlLoader.data);
				
			});
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void
			{
				trace(event);
			});
			urlLoader.load(request);
		}
		
		public function test_videoId_list():void
		{
			
			var nnddRequest:XML = new XML("<nnddRequest></nnddRequest>");
			nnddRequest.@type = RequestType.GET_VIDEO_ID_LIST.typeStr;
			
			var request:URLRequest = new URLRequest("http://localhost:12300/NNDDServer");
			request.method = "POST";
			request.data = nnddRequest.toXMLString();
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, function(event:Event):void
			{
				trace(urlLoader.data);
				
			});
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void
			{
				trace(event);
			});
			urlLoader.load(request);
		}
		
		public function test_video():void
		{
			var nnddRequest:XML = new XML("<nnddRequest></nnddRequest>");
			nnddRequest.@type = RequestType.GET_VIDEO_BY_ID.typeStr;
			nnddRequest.video.@id = "sm17701237";
			
			var request:URLRequest = new URLRequest("http://localhost:12300/NNDDServer");
			request.method = "POST";
			request.data = nnddRequest.toXMLString();
			
			
			var buffer:ByteArray = new ByteArray();
			var extension:String = null;
			var urlStream:URLStream = new URLStream();
			var desktop:File = File.desktopDirectory;
			var outputFile:File = null;
			
			urlStream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void
			{
				for each(var header:URLRequestHeader in event.responseHeaders)
				{
					if (header.name == "Content-Type")
					{
						if (header.value == "video/flv")
						{
							extension = ".flv";
						}
						if (header.value == "video/mp4")
						{
							extension = ".mp4";
						}
						if (header.value == "application/x-shockwave-flash")
						{
							extension = ".swf";
						}
						
						outputFile = desktop.resolvePath(new Date().time + extension);
						
						break;
					}
				}
			});
			urlStream.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void
			{
				trace(event);
				
				if (urlStream.bytesAvailable > 0)
				{
					urlStream.readBytes(buffer, buffer.length);
					
					
					if (buffer.length > 100000)
					{
						output(outputFile, buffer);
						buffer.clear();
					}
				}
				
			});
			urlStream.addEventListener(Event.COMPLETE, function(event:Event):void
			{
				
				trace(event);
				
				output(outputFile, buffer);
				
			});
			urlStream.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void
			{
				trace(event);
			});
			urlStream.load(request);
		}
		
		private function output(file:File, outData:ByteArray):void
		{
			
			var stream:FileStream = new FileStream();
			stream.open(file, FileMode.APPEND);
			stream.writeBytes(outData);
			stream.close();
			
			outData.clear();
			
		}
		
		
	}
}