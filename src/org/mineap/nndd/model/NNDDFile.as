package org.mineap.nndd.model
{
	import flash.filesystem.File;

	public class NNDDFile extends File
	{
		
		private var _id:Number = -1;
		
		public function NNDDFile(path:String = null)
		{
			super(path);
		}

		public function get id():Number
		{
			return _id;
		}

		public function set id(value:Number):void
		{
			_id = value;
		}

	}
}