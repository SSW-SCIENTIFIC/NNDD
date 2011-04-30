package org.mineap.nndd.util
{
	import flash.errors.IOError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.controls.Alert;

	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class LogUtil
	{
		
		private static const _logUtil:LogUtil = new LogUtil();
		
		/**
		 * 
		 */
		public static function get instance():LogUtil{
			return _logUtil;
		}
		
		private var logOutputFail:Boolean = false;
		
		/**
		 * 
		 * 
		 */
		public function LogUtil()
		{
		}
		
		/**
		 * 指定されたfilePathのファイルにoutで指定された文字列を書き出します。
		 * @param out
		 * @param filePath
		 * 
		 */
		public function addLog(out:String, filePath:String):void{
			
			var fileStream:FileStream = new FileStream();
			
			try{
				var file:File;
				file = new File(filePath);
				
				fileStream.open(file, FileMode.APPEND);
				fileStream.writeUTFBytes(out);
				fileStream.close();
				logOutputFail = false;
			}catch (error:Error){
				if(!logOutputFail){
					logOutputFail = true;
					Alert.show("ログの出力に失敗しました。(" + error + ")\n" +
						"出力先が存在しないか、アクセス権がない可能性があります。\n\n" +
						"出力先:" + filePath + "\n" +
						"StackTrace:" + error.getStackTrace());
				}
				trace(error.getStackTrace());
				if(fileStream != null){
					try{
						fileStream.close();
					}catch(error:Error){
						trace(error.getStackTrace());
					}
				}
			}
			
		}
		
	}
}