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
				
				var type:String = nnddRequest.@type;
				
				var nnddResponse:XML = new XML("<nnddResponse></nnddResponse>");
				
				if (type.indexOf(RequestType.GET_MYLIST_LIST.typeStr) != -1)
				{
					// マイリスト一覧情報取得
					var myLists:Vector.<MyList> = MyListManager.instance.getAllMyList();
					
					for each (var myList:MyList in myLists) 
					{
						var rss:XML = new XML("<rss></rss>");
						rss.@id = myList.id;
						rss.@rssType = myList.type.toString();
						(nnddResponse as XML).appendChild(rss);
					}
					
				}
				else if (type.indexOf(RequestType.GET_MYLIST_BY_ID.typeStr) != -1)
				{
					// ID指定マイリスト取得
					
					var rssTypeStr:String = nnddRequest.rss.@rssType;
					var rssId:String = nnddRequest.rss.@id;
					
					var rssType:RssType = RssType.convertStrToRssType(rssTypeStr);
					var xml:XML = MyListManager.instance.readLocalMyList(rssId, rssType);
					
					if (xml != null) 
					{
						nnddResponse = xml;
					}
					
				}
				else if (type.indexOf(RequestType.GET_VIDEO_ID_LIST.typeStr) != -1)
				{
					// 動画一覧取得
				}
				else if (type.indexOf(RequestType.GET_VIDEO_BY_ID.typeStr) != -1)
				{
					// 動画取得
				}
				else
				{
					// NOT_FOUND
				}
				
				if (nnddResponse != null)
				{
					response.statusCode = 200;
					response.body = nnddResponse.toXMLString();
				}
				else
				{
					response.statusCode = 404;
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