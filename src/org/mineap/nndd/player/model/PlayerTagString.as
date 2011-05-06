package org.mineap.nndd.player.model
{
	import org.mineap.nndd.model.TagString;
	
	public class PlayerTagString extends TagString
	{
		
		private var _loc:String = null;
		
		private var _lock:Boolean = false;
		
		
		public function PlayerTagString(tag:String=null)
		{
			super(tag);
		}

		/**
		 * ロックされているかどうか
		 */
		public function get lock():Boolean
		{
			return _lock;
		}

		/**
		 * @private
		 */
		public function set lock(value:Boolean):void
		{
			_lock = value;
		}

		/**
		 * ロケール
		 */
		public function get loc():String
		{
			return _loc;
		}

		/**
		 * @private
		 */
		public function set loc(value:String):void
		{
			_loc = value;
		}

	}
}