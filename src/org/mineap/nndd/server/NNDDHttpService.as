package org.mineap.nndd.server
{
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;
	import com.tilfin.airthttpd.services.IService;
	
	import flash.utils.ByteArray;
	
	import org.mineap.nndd.model.RssType;
	import org.mineap.nndd.myList.MyList;
	import org.mineap.nndd.myList.MyListManager;
	import org.mineap.nndd.util.MyListUtil;
	
	public class NNDDHttpService implements IService
	{
		public function NNDDHttpService()
		{
			//TODO: implement function
		}
		
		public function doService(request:HttpRequest, response:HttpResponse):void
		{
			
			try {
				
				if (request.path == "/NNDDServer" || request.path == "/NNDDServer/")
				{
					
					var byteArray:ByteArray = request.requestBody;
					
					var reqBody:String = String(byteArray);
					
					var nnddRequest:XML = new XML(reqBody);
					
					var process:IRequestProcess = RequestProcessFactory.createProcess(nnddRequest);
					
					if (process != null)
					{
						process.process(nnddRequest, response);
					}
					else
					{
						// リクエストエンティティ(=XML)の内容が妥当ではない
						response.statusCode = 422;
					}
					
				}
				else if (request.path.indexOf("/NNDDServer/") == 0 && request.path.length > 13)
				{
					var getVideoData:GetVideoDataProcess = new GetVideoDataProcess();
					
					var lastIndex:int = request.path.lastIndexOf("/");
					
					if (lastIndex < 10) 
					{
						response.statusCode = 404;
						return;
					}
					
					var videoId:String = request.path.substring(lastIndex+1);
					
					getVideoData.process(videoId, response);
				
				}
				else
				{
					response.statusCode = 404;
					return;
				}
			}
			catch(error:Error)
			{
				trace(error.getStackTrace());
				response.statusCode = 500;
			}
			
		}
	}
}