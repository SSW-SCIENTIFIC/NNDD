package org.mineap.nndd.util
{
	import flash.events.HTTPStatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * 
	 * @author mine
	 * 
	 */
	public class ShortUrlChecker extends URLLoader
	{
		
		private var _url:String = null;
		
		public var shortUrls:Vector.<String> = Vector.<String>(["http://nico.ms", "http://bit.ly", "http://t.co"]);
		
		public function ShortUrlChecker(urlRequest:URLRequest = null)
		{
			super(urlRequest);
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get url():String
		{
			return _url;
		}

		/**
		 * 
		 * @param url
		 * @return 
		 * 
		 */
		public function isShortUrl(url:String):Boolean
		{
			
			for each(var str:String in shortUrls)
			{
				var i:int = url.indexOf(str);
				if (i != -1)
				{
					return true;
				}
			}
			
			return false;
		}
		
		/**
		 * 
		 * @param url
		 * 
		 */
		public function expansion(url:String):void
		{
			
			var request:URLRequest = new URLRequest(url);
			this.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				_url = event.responseURL;
			});
			this.load(request);
		}
		
	}
}