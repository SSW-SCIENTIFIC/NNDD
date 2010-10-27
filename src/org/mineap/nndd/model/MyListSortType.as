package org.mineap.nndd.model
{
	public class MyListSortType
	{
		
		/**
		 * 昇順か降順か
		 */
		public var sortFiledDescending:Boolean = false;
		
		/**
		 * ソートを適用するフィールドの名前
		 */
		public var sortFiledName:String = null;
		
		
		/**
		 * 
		 * @param name
		 * @param descending
		 * 
		 */
		public function MyListSortType(name:String, descending:Boolean)
		{
			this.sortFiledName = name;
			this.sortFiledDescending = descending;
		}
	}
}