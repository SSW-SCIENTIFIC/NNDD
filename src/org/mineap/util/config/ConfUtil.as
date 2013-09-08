package org.mineap.util.config
{
	import flash.errors.IOError;
	import flash.filesystem.File;
	import flash.system.Capabilities;

	public class ConfUtil
	{
		public function ConfUtil()
		{
		}
		
		
		/**
		 * 
		 * @param value
		 * @return 
		 * 
		 */
		public static function parseBoolean(value:Object):Boolean{
			
			if(value == null){
				return false;
			}
			
			if(value is Boolean){
				return Boolean(value);
			}
			
			if(value is String){
				if(String(value).toLowerCase() == "false"){
					return false;
				}else{
					return true;
				}
			}
			
			return Boolean(value);
			
		}
		
		
		/**
		 * AIR3.2世代のアプリケーションストレージにある設定ファイルを、AIR3.3世代のアプリケーションストレージにコピーします。
		 */
		public static function movePrefToAppSupport():void {
			
			if (Capabilities.os.toLowerCase().indexOf("mac") != -1
					&& File.applicationStorageDirectory.getDirectoryListing().length == 0) {
				
				// AIR3.2以前
				var oldDir:File = File.userDirectory.resolvePath("Library/Preferences/org.mineap.nndd/Local Store/");
				
				if (!oldDir.exists){
					return;
				}
					
				// AIR3.3以降
				var newDir:File = File.applicationStorageDirectory;
				
				for each(var oldFile:File in oldDir.getDirectoryListing()) {
					try {
						oldFile.copyTo(newDir.resolvePath(oldFile.name), false);
					} catch (e:IOError) {
						trace(e);
					}
				}
			}
			
		}
		
	}
}