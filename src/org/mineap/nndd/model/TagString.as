package org.mineap.nndd.model
{
	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class TagString
	{
		
		private var _id:Number = -1;
		
		private var _tag:String = null;
		
		/**
		 * 
		 * @param tag
		 * 
		 */
		public function TagString(tag:String = null)
		{
			if(tag != null){
				_tag = tag;
			}
		}

		public function get id():Number
		{
			return _id;
		}

		public function set id(value:Number):void
		{
			_id = value;
		}

		public function get tag():String
		{
			return _tag;
		}

		public function set tag(value:String):void
		{
			_tag = value;
		}


	}
}