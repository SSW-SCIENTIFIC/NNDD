package org.mineap.nndd.server.process
{
	import com.tilfin.airthttpd.server.HttpResponse;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.myList.MyList;
	import org.mineap.nndd.myList.MyListManager;
	import org.mineap.nndd.server.IRequestProcess;
	
	/**
	 * マイリスト一覧取得APIが呼ばれた場合の処理
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class GetMyListProcess implements IRequestProcess
	{
		public function GetMyListProcess()
		{
		}
		
		public function process(requestXml:XML, httpResponse:HttpResponse):void
		{
			
			// マイリスト一覧情報取得 (フォルダ以外)
			var myLists:Vector.<MyList> = MyListManager.instance.getAllMyList();
			
			var nnddResponse:XML = <nnddResponse />;
			for each (var myList:MyList in myLists) 
			{
				var rss:XML = <rss />
				rss.@id = myList.id;
				rss.@rssType = myList.type.toString();
				rss.@name = myList.myListName;
				(nnddResponse as XML).appendChild(rss);
			}
			
			httpResponse.body = nnddResponse.toXMLString();
			httpResponse.statusCode = 200;
			
			LogManager.instance.addLog("マイリスト一覧取得要求:list.len=" + myLists.length +  ", resCode=" + httpResponse.statusCode);
			
		}
	}
}