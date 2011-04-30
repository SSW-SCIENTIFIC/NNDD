package org.mineap.nndd.versionCheck
{
	import flash.desktop.NativeProcess;
	import flash.system.Capabilities;

	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class VersionCheckerFactory
	{
		public function VersionCheckerFactory()
		{
			// nothing
		}
		
		/**
		 * IVersionCheckerのインスタンスを生成して返します。
		 * 
		 * @return 
		 * 
		 */
		public static function create():IVersionChecker{
			
			if (NativeProcess.isSupported)
			{
				// ネイティブプロセス用
				return VersionCheckerForNativeApplication.instance;	
			}
			else
			{
				// AIR用
				return VersionChecker.instance;
			}
			
			
		}
		
	}
}