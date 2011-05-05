package org.mineap.nndd.library
{
	import org.mineap.nndd.library.namedarray.NamedArrayLibraryManager;
	import org.mineap.nndd.library.sqlite.SQLiteLibraryManager;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class LibraryManagerBuilder
	{
		private static const libraryManagerBuilder:LibraryManagerBuilder = new LibraryManagerBuilder();
		
		/**
		 * 
		 */
		public static const LIBRARY_TYPE_SQL:String = "LibraryTypeSql";
		
		/**
		 * 
		 */
		public static const LIBRARY_TYPE_NAMED_ARRAY:String = "LibraryTypeNamedArray";
		
		private var _type:String = LibraryManagerBuilder.LIBRARY_TYPE_NAMED_ARRAY;
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():LibraryManagerBuilder{
			return libraryManagerBuilder;
		}
		
		/**
		 * 
		 * 
		 */
		public function LibraryManagerBuilder()
		{
			if(libraryManagerBuilder != null){
				throw new ArgumentError("LibraryManagerBuilderはインスタンス化できません。");
			}
		}
		
		/**
		 * 
		 * @param type
		 * 
		 */
		public function set libraryType(type:String):void{
			
			if(LIBRARY_TYPE_SQL == type){
				this._type = LIBRARY_TYPE_SQL;
			}else{
				this._type = LIBRARY_TYPE_NAMED_ARRAY;
			}
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get libraryManager():ILibraryManager{
			
			if(LIBRARY_TYPE_NAMED_ARRAY == this._type){
				return NamedArrayLibraryManager.instance;
			}else{
				return SQLiteLibraryManager.instance;
			}
			
		}
		
	}
}