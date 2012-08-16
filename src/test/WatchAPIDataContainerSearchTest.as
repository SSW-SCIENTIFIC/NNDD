package test
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.mineap.nicovideo4as.util.HtmlUtil;

	public class WatchAPIDataContainerSearchTest
	{
		public function WatchAPIDataContainerSearchTest(test:Test)
		{
			
		}
		
		
		public function test():void {
			var urlRequest:URLRequest = new URLRequest("http://www.nicovideo.jp/watch/sm17659157");
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, function(event:Event):void{
				var str:String = loader.data;
				
				var index:int = str.indexOf("watchAPIDataContainer");
				
				str = str.substr(index);
				
				index = str.indexOf("</div>");
				str = str.substring(0, index);
				
				index = str.indexOf("{");
				
				str = str.substr(index);	//30584
				
				var regexp:RegExp = new RegExp("<div id=\"watchAPIDataContainer\" style=\"display:none\">(.+?)</div>");
				var obj:Object = regexp.exec(loader.data);
				var str2:String = obj[1];	//42257
				
				trace(str);	
				trace(str2);
				
				str = HtmlUtil.convertSpecialCharacterNotIncludedString(str);
				
				trace(str);
				trace(str.length);
				
				var jsonObj:Object = JSON.parse(str);
				trace(jsonObj);
				
				trace(jsonObj.videoDetail.description);
				
			});
			loader.load(urlRequest);
		
		}
		
		
	}
}