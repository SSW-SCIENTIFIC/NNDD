package org.mineap.nndd.versionCheck
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.DownloadErrorEvent;
	import air.update.events.StatusFileUpdateErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.UpdateEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	
	import mx.core.FlexGlobals;
	
	import org.mineap.nndd.LogManager;

	/**
	 * NNDDのバージョンチェックを行うクラスです。
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class VersionChecker implements IVersionChecker
	{
		
		private static const checker:VersionChecker = new VersionChecker();
		
		private var updater:ApplicationUpdaterUI = new ApplicationUpdaterUI();
		
		private var checkOnInit:Boolean = false;
		
		/**
		 * VersionCheckerの唯一のインスタンスを取得します
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():VersionChecker{
			return checker;
		}
		
		public function VersionChecker()
		{
			if(checker != null){
				throw ArgumentError("VersionCheckerはインスタンス化できません。");
			}
		}
		
		/**
		 * 初期化処理。
		 * @param checkOnInit
		 * 
		 */
		public function init(checkOnInit:Boolean):void{
			this.checkOnInit = checkOnInit;
			
			updater.configurationFile = new File("app:/config/updateConfig.xml");
			updater.addEventListener(UpdateEvent.INITIALIZED, updaterInitializedEventHandler);
			updater.addEventListener(DownloadErrorEvent.DOWNLOAD_ERROR, updaterDownloadErrorEventHandler);
			updater.addEventListener(ErrorEvent.ERROR, updaterErrorEventHandler);
			updater.addEventListener(StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, updaterErrorEventHandler);
			updater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, updaterErrorEventHandler);
			updater.initialize();
			
		}
		
		private function updaterErrorEventHandler(event:ErrorEvent):void{
			trace(event);
		}
		
		private function updaterDownloadErrorEventHandler(event:DownloadErrorEvent):void{
			trace(event);
		}
		
		private function updaterInitializedEventHandler(event:UpdateEvent):void{
			if(this.checkOnInit){
				this.checkUpdate();
			}
		}
		
		/**
		 * バージョンチェックを行います。
		 * 
		 * @param isCheckForUpdate アップデート確認前メッセージを表示するかどうか。デフォルトはfalseで表示しない。
		 * 
		 */
		public function checkUpdate(isCheckForUpdate:Boolean = false):void{
			LogManager.instance.addLog("バージョンチェック(currentVersion:" + updater.currentVersion + ")");
			updater.isCheckForUpdateVisible = isCheckForUpdate;
			updater.checkNow();
			
		}
		
	}
}