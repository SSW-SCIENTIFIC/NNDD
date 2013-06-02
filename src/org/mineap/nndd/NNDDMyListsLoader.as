package org.mineap.nndd
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.sampler.NewObjectSample;
	
	import org.mineap.nndd.model.RssType;
	import org.mineap.nndd.myList.MyList;
	import org.mineap.nndd.server.RequestType;
	import org.mineap.util.config.ConfigManager;
	
	
	/**
	 * NNDDServerからマイリストの一覧を取得するためのクラスです
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class NNDDMyListsLoader extends URLLoader
	{
		private var _myLists:Vector.<MyList> = new Vector.<MyList>();
		public static const GET_MYLISTS_COMPLETE:String = "GetMylistsComplete";
		
		/**
		 * 
		 * @param request
		 * 
		 */
		public function NNDDMyListsLoader(request:URLRequest=null)
		{
			addEventListener(Event.COMPLETE, completeEventHander);
			super(request);
		}
		
		
		/**
		 * 
		 * @param nnddServerIpAddress
		 * @param nnddServerPort
		 * 
		 */
		public function getMyLists(nnddServerAddress:String, nnddServerPort:int):void
		{
			var timeout:int = 1000;
			
			var timeoutStr:String = ConfigManager.getInstance().getItem("connectToNnddServerTimeout");
			if (timeoutStr != null)
			{
				timeout = int(timeoutStr);
			}
			
			var reqXml:XML = <nnddRequest />;
			reqXml.@type = RequestType.GET_MYLIST_LIST.typeStr;
			
			var urlRequest:URLRequest = new URLRequest("http://" + nnddServerAddress + ":" + nnddServerPort + "/NNDDServer");
			urlRequest.method = "POST";
			urlRequest.data = reqXml.toXMLString();
			urlRequest.idleTimeout = timeout;
			
			super.load(urlRequest);
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		protected function completeEventHander(event:Event):void
		{
			
			var object:Object = (event.currentTarget as URLLoader).data;
			
			if (object != null)
			{
				var xml:XML = new XML(object);
				
				for each(var rss:XML in xml.rss)
				{
					var myListId:String = rss.@id;
					var myListType:String = rss.@rssType;
					var myListName:String = rss.@name;
					
					var myListUrl:String = myListId;
					
					var type:RssType = RssType.convertStrToRssType(myListType);
					if (type == RssType.CHANNEL)
					{
						myListUrl = "channel/" + myListId;
					} 
					else if (type == RssType.USER_UPLOAD_VIDEO)
					{
						myListUrl = "user/" + myListId;
					}
					else
					{
						myListUrl = "myList/" + myListId;
					}
					
					if (myListName == null || myListName.length == 0)
					{
						myListName = myListUrl;
					}
					
					var myList:MyList = new MyList(myListUrl, myListName);
					myList.type = type;
					
					_myLists.push(myList);
					
					trace("myListId:" + myListId + ", myListType:" + myListType + "," + myList.idWithPrefix);
				}
			}
			
			dispatchEvent(new Event(GET_MYLISTS_COMPLETE));
			
		}		
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get myLists():Vector.<MyList>
		{
			return this._myLists;
		}
		
		
	}
}