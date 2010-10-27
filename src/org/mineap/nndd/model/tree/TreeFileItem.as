package org.mineap.nndd.model.tree
{
	import flash.filesystem.File;

	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public dynamic class TreeFileItem implements ITreeItem
	{
		private var _label:String;
		
		private var _file:File;
		
		private var _parent:ITreeItem;
		
		/**
		 * 
		 * @param file
		 * 
		 */
		public function TreeFileItem(file:File = null)
		{
			this._file = file;
		}
		
		public function get label():String{
			return this._label;
		}
		
		public function set label(value:String):void
		{
			this._label = value;
		}

		public function get file():File
		{
			return _file;
		}

		public function get parent():ITreeItem
		{
			return _parent;
		}

		public function set parent(value:ITreeItem):void
		{
			_parent = value;
		}
		

	}
}