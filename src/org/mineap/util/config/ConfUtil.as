package org.mineap.util.config
{
	public class ConfUtil
	{
		public function ConfUtil()
		{
		}
		
		
		/**
		 * 
		 * @param value
		 * @return 
		 * 
		 */
		public static function parseBoolean(value:Object):Boolean{
			
			if(value == null){
				return false;
			}
			
			if(value is Boolean){
				return Boolean(value);
			}
			
			if(value is String){
				if(String(value).toLowerCase() == "false"){
					return false;
				}else{
					return true;
				}
			}
			
			return Boolean(value);
			
		}
		
		
	}
}