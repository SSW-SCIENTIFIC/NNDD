package org.mineap.nndd.server
{
	import com.tilfin.airthttpd.server.HttpRequest;
	import com.tilfin.airthttpd.server.HttpResponse;
	import com.tilfin.airthttpd.services.IService;
	
	import flash.utils.ByteArray;
	
	import org.mineap.nndd.LogManager;
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
			
			LogManager.instance.addLog("通信を受付:path=" + request.path + ", remoteAddress=" + response.httpConnection.socket.remoteAddress);
			
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
						response.statusCode = 404;
						return;
					}
					
				}
				else if (request.path.indexOf("/NNDDServer/") == 0 && request.path.length > 13)
				{
					
					if (ServerManager.instance.allowVideo)
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
				else
				{
					response.statusCode = 404;
					LogManager.instance.addLog("リクエスト解析不可:resCode=" + response.statusCode);
					return;
				}
			}
			catch(error:Error)
			{
				trace(error.getStackTrace());
				response.statusCode = 500;
				LogManager.instance.addLog("エラー発生:error=" + error + ", resCode=" + response.statusCode);
			}
			
		}
	}
}