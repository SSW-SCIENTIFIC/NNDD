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
			
			if (request.path != "/NNDDServer" && request.path != "/NNDDServer/")
			{
				response.statusCode = 404;
				return;
			}
			
			try {
				
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
			catch(error:Error)
			{
				trace(error.getStackTrace());
				response.statusCode = 500;
			}
			
		}
	}
}