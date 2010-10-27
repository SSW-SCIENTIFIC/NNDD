package org.mineap.nndd.event
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class LocalCommentSearchEvent extends Event
	{
		
		/**
		 * 
		 */
		public static const LOCAL_COMMENT_SEARCH_COMPLETE:String = "LocalCommentSearchComplete";
		
		private var _commentFiles:Vector.<File> = new Vector.<File>();
		
		/**
		 * 
		 * @param type
		 * @param bubbles
		 * @param cancelable
		 * @param commentFiles
		 * 
		 */
		public function LocalCommentSearchEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, commentFiles:Vector.<File> = null)
		{
			super(type, bubbles, cancelable);
			
			if(commentFiles != null){
				this._commentFiles = commentFiles;
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get commentFiles():Vector.<File>{
			return this._commentFiles;
		}
	}
}