package org.mineap.nndd.model.tree
{
	import flash.filesystem.File;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public interface ITreeItem
	{
		
		function get label():String;
		
		function set label(label:String):void;
		
		function get file():File;
		
		function get parent():ITreeItem;
		
		function set parent(value:ITreeItem):void;
		
		
	}
}