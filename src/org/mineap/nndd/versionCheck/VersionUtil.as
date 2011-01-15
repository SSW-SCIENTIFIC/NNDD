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
		public function get versionNumber():String
		{
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var air:Namespace = appXML.namespaceDeclarations()[0];
			var version:String = appXML.air::versionNumber;
			version = version.substring(1);
			return version;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get versionLabel():String
		{
			var appXML:XML = NativeApplication.nativeApplication.applicationDescriptor;
			var air:Namespace = appXML.namespaceDeclarations()[0];
			var version:String = appXML.air::versionLabel;
			version = version.substring(1);
			return version;
		}
		
		
	}
}