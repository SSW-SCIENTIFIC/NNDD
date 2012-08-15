package org.mineap.nndd.server
{
	public class ResponseType
	{
		
		public static const SUCCESS:ResponseType = new ResponseType(200);
		
		public static const REQUEST_INVALID:ResponseType = new ResponseType(400);
		
		public static const SERVER_INTERNAL_ERROR:ResponseType = new ResponseType(500);
		
		private var code:int;
		
		public function ResponseType(code:int)
		{
			this.code = code;
		}
		
		public function get responseCode():int
		{
			return this.code;
		}
	}
}