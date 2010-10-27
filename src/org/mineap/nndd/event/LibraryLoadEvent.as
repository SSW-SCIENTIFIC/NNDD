package org.mineap.nndd.event
{
	import flash.events.Event;
	import flash.filesystem.File;

	public class LibraryLoadEvent extends Event
	{
		
		public static const LIBRARY_LOAD_COMPLETE:String = "LibraryLoadComplete";
		public static const LIBRARY_LOADING:String = "LibraryLoading";
		
		private var _loadingItem:File = null;
		
		private var _totalVideoCount:int = 0;
		
		private var _completeVideoCount:int = 0;
		
		/**
		 * 
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param totalVideoCount
		 * @param completeVideoCount
		 * @param loadingItem
		 * 
		 */
		public function LibraryLoadEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, totalVideoCount:int = 0, completeVideoCount:int = 0, loadingItem:File = null){
			super(type, bubbles, cancelable);
			
			this._completeVideoCount = completeVideoCount;
			this._totalVideoCount = totalVideoCount;
			this._loadingItem = loadingItem;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get totalVideoCount():int
		{
			return _totalVideoCount;
		}

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get completeVideoCount():int
		{
			return _completeVideoCount;
		}

		/**
		 * 
		 * @return 
		 * 
		 */
		public function get loadingItem():File
		{
			return _loadingItem;
		}



	}
}