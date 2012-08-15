package org.mineap.nndd.server
{
	public class RequestType
	{
		
		public static const GET_MYLIST_LIST:RequestType = new RequestType("GET_MYLIST_LIST");
		
		public static const GET_MYLIST_BY_ID:RequestType = new RequestType("GET_MYLIST_BY_ID");
		
		public static const GET_VIDEO_ID_LIST:RequestType = new RequestType("GET_VIDEO_ID_LIST");
		
		public static const GET_VIDEO_BY_ID:RequestType = new RequestType("GET_VIDEO_BY_ID");
			
		private var _type:String;
			
		public function RequestType(type:String)
		{
			_type = type;
		}
		
		public function get typeStr():String
		{
			return _type;
		}
		
	}
}