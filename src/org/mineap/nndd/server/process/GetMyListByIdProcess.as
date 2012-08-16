package org.mineap.nndd.server.process
{
	import com.tilfin.airthttpd.server.HttpResponse;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.model.RssType;
	import org.mineap.nndd.myList.MyListManager;
	import org.mineap.nndd.server.IRequestProcess;
	
	/**
	 * ID指定のマイリスト取得処理が呼ばれたときの処理
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class GetMyListByIdProcess implements IRequestProcess
	{
		public function GetMyListByIdProcess()
		{
		}
		
		public function process(requestXml:XML, httpResponse:HttpResponse):void
		{
			
			// ID指定マイリスト取得
			var rssTypeStr:String = requestXml.rss.@rssType;
			var rssId:String = requestXml.rss.@id;
			
			var rssType:RssType = RssType.convertStrToRssType(rssTypeStr);
			var xml:XML = MyListManager.instance.readLocalMyList(rssId, rssType);
			
			
			if (xml != null)
			{
				httpResponse.body = xml.toXMLString();
				httpResponse.statusCode = 200;
			}
			else
			{
				// NOT_FOUND
				httpResponse.statusCode = 404;
			}
			
			LogManager.instance.addLog("ID指定マイリスト取得要求:type=" + rssType + ", id=" + rssId + ", resCode=" + httpResponse.statusCode);
			
		}
	}
}