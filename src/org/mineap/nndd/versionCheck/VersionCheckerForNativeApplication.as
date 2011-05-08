package org.mineap.nndd.versionCheck
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * NNDDのバージョンチェックを行うクラスです。(ネイティブインストーラ用)
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class VersionCheckerForNativeApplication implements IVersionChecker
	{
		
		private var updater:NNDDUpdaterWindow = null;
		
		private var checkOnInit:Boolean = false;
		
		private static const checker:VersionCheckerForNativeApplication = new VersionCheckerForNativeApplication();
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public static function get instance():VersionCheckerForNativeApplication
		{
			return checker;
		}
		
		public function VersionCheckerForNativeApplication()
		{
			if(checker != null){
				throw new ArgumentError("VersionCheckerForNativeApplicationクラスはインスタンス化できません。");
			}
		}
		
		/**
		 * 
		 * @param checkOnInit
		 * 
		 */
		public function init(checkOnInit:Boolean):void
		{
			this.checkOnInit = checkOnInit;
			
			if(checkOnInit){
				this.updater = new NNDDUpdaterWindow();
				this.updater.isAutoCheck = true;
				this.updater.open();
			}
			
			timerStart();
		}
		
		private function timerStart():void{
			var timer:Timer = new Timer( 1000 * 60 * 60 * 24 ,1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
				try{
					checkUpdate(false);
				}catch(error:Error){
					
				}
				timerStart();
			});
			timer.start();
		}
		
		/**
		 * 
		 * @param isCheckForUpdate
		 * 
		 */
		public function checkUpdate(isCheckForUpdate:Boolean=false):void
		{
			if(updater != null){
				if(!updater.closed){
					updater.close();
				}
				updater = null;
			}
			
			this.updater = new NNDDUpdaterWindow();
			this.updater.open();
		}
	}
}