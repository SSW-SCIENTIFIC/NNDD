package org.mineap.nndd.event
{
	import flash.events.ProgressEvent;
	
	public class MyListRenewProgressEvent extends ProgressEvent
	{
		public static const MYLIST_RENEW_PROGRESS:String = "MyListRenewProgress";
		
		private var _renewingMyListId:String = null;
		
		public function MyListRenewProgressEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, bytesLoaded:Number=0, bytesTotal:Number=0, renewingMyListId:String = null)
		{
			super(type, bubbles, cancelable, bytesLoaded, bytesTotal);
			this._renewingMyListId = renewingMyListId;
		}
		
		public function get renewingMyListId():String{
			return this._renewingMyListId;
		}
		
	}
}