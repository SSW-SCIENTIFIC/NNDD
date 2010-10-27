package org.mineap.nndd.model.tree
{
	import flash.filesystem.File;

	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public dynamic class TreeFolderItem implements ITreeItem
	{
		
		private var _label:String;
		
		private var _children:Array;
		
		private var _file:File;
		
		private var _parent:ITreeItem;
		
		/**
		 * 
		 * @param file
		 * 
		 */
		public function TreeFolderItem(file:File = null)
		{
			_file = file;
		}
		
		public function get label():String
		{
			return this._label;
		}

		public function set label(value:String):void
		{
			this._label = value;
		}

		public function get children():Array
		{
			return this._children;
		}

		public function set children(value:Array):void
		{
			this._children = value;
		}

		public function get file():File
		{
			return _file;
		}
		
		public function set file(value:File):void
		{
			this._file = value;
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