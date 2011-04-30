package org.mineap.nndd.versionCheck
{
	public interface IVersionChecker
	{
		
		function init(checkOnInit:Boolean):void;
		
		function checkUpdate(isCheckForUpdate:Boolean = false):void;
		
	}
}