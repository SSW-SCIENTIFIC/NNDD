package org.mineap.a2n4as.util
{
	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class GetThreadKeyResultAnalyzer
	{
		
		private var _threadkey:String = "";
		
		private var _force_184:String = "";
		
		public function GetThreadKeyResultAnalyzer()
		{
		}
		
		/**
		 * 
		 * @param result
		 * @return 
		 * 
		 */
		public function analyze(result:String):Boolean{
			try{
				
				var map:Object = new Object();
				for each(var results:String in decodeURIComponent(result).split("&")){
					// threadkey="" と force_184="" が取れる
					var words:Array = results.split("=");
					map[words[0]] = words[1];
				}
				
				this._threadkey = map["threadkey"];
				this._force_184 = map["force_184"];
				
				return true;
			
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			return false;
			
		}

		public function get threadkey():String
		{
			return _threadkey;
		}

		public function get force_184():String
		{
			return _force_184;
		}

		
	}
}