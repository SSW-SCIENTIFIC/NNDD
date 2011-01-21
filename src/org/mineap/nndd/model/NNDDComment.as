package org.mineap.nndd.model
{
	import org.mineap.nicovideo4as.model.Comment;
	import org.mineap.nndd.player.comment.Command;
	
	public class NNDDComment extends Comment
	{
		
		private var _isShow:Boolean = true;
		
		private var _sizeCommand:int = Command.MEDIUM;
		
		/**
		 * 
		 * @param vpos
		 * @param text
		 * @param mail
		 * @param user_id
		 * @param no
		 * @param thread
		 * @param isShow
		 * 
		 */
		public function NNDDComment(vpos:Number, text:String, mail:String, user_id:String, no:Number, thread:String, isShow:Boolean)
		{
			
			super(vpos, text, mail, user_id, no, thread);
			this._isShow = isShow;
			
		}
		
		public function get isShow():Boolean
		{
			return _isShow;
		}

		public function set isShow(value:Boolean):void
		{
			_isShow = value;
		}

		public function get sizeCommand():int
		{
			return _sizeCommand;
		}

		public function set sizeCommand(value:int):void
		{
			_sizeCommand = value;
		}


	}
}