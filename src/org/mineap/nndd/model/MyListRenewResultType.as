package org.mineap.nndd.model
{
	public final class MyListRenewResultType
	{
		
		public static const SUCCESS:MyListRenewResultType = new MyListRenewResultType("SUCCESS");
		public static const FAIL:MyListRenewResultType = new MyListRenewResultType("FAIL");
		
		private var _type:String;
		
		public function MyListRenewResultType(type:String){
			this._type = type;
		}
		
		public function toString():String{
			return this._type;
		}		

	}
}