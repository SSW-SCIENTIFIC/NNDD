package org.mineap.nndd.versionCheck
{
	import flash.desktop.NativeApplication;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class VersionUtil
	{
		
		private static const _versionUtil:VersionUtil = new VersionUtil();
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():VersionUtil{
			return _versionUtil;
		}
		
		public function VersionUtil()
		{
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get version():String
		{
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var air:Namespace = appXML.namespaceDeclarations()[0];
			var version:String = appXML.air::version;
			version = version.substring(1);
			return version;
		}
		
		
	}
}