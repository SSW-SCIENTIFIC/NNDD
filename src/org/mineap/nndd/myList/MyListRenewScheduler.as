package org.mineap.nndd.myList
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.NNDDMyListLoader;
	import org.mineap.nndd.event.MyListRenewProgressEvent;
	import org.mineap.nndd.model.MyListRenewResultType;
	import org.mineap.nndd.util.MyListUtil;

	[Event(name="complete", type="Event")]
	[Event(name="mylistRenewProgress", type="MyListRenewProgressEvent")]
	
	/**
	 * マイリスト更新のスケジューリングおよび実行を行います。
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class MyListRenewScheduler extends EventDispatcher
	{
		
		/**
		 * スケジューリング対象のマイリストIDの一覧を保持します
		 */
		private var _myListIds:Vector.<String> = new Vector.<String>();
		
		/**
		 * マイリストIDをキーにマイリスト取得結果を格納するMapです
		 */
		private var _myListRenewResultMap:Object = new Object();
		
		/**
		 * スケジュール実行用タイマー
		 */
		private var _timer:Timer = null;
		
		/**
		 * デフォルトの待ち時間。1000ms(=1s) * 60 * 30 = 30分
		 */
		private var _delay:Number = 1000*60*30;
		
		/**
		 * インデックス
		 */
		private var _index:int = 0;
		
		/**
		 * 
		 */
		private var _renewing:Boolean = false;
		
		/**
		 * 
		 */
		private static const _myListRenewScheduler:MyListRenewScheduler = new MyListRenewScheduler();
		
		/**
		 * 
		 */
		public static const MyListRenewScheduleTimeArray:Array = new Array(15, 30, 60, 120, 240, 480);
		
		/**
		 * 
		 */
		private var _mailAddress:String;
		
		/**
		 * 
		 */
		private var _password:String;
		
		/**
		 * マイリスト更新一つあたりの間隔。ミリ秒で指定する。
		 */
		private var _delayOfMylist:int = 1000;
		
		/**
		 * 
		 * @param mailAddress
		 * 
		 */
		public function set mailAddress(mailAddress:String):void{
			this._mailAddress = mailAddress;
		}
		
		/**
		 * 
		 * @param password
		 * 
		 */
		public function set password(password:String):void{
			this._password = password;
		}
		
		/**
		 * シングルトンパターン
		 * 
		 */
		public function MyListRenewScheduler()
		{
			if(_myListRenewScheduler != null){
				throw ArgumentError("MyListRenewSchedulerはインスタンス化できません。");
			}
		}
		
		/**
		 * 唯一のMyListRenewSchedulerのインスタンスを返します。
		 * @return 
		 * 
		 */
		public static function get instance():MyListRenewScheduler{
			return _myListRenewScheduler;
		}
		
		/**
		 * 指定されたマイリストをスケジューリング対象に追加します。
		 * @param myListId
		 * 
		 */
		public function addMyListId(myListId:String):void{
			
			myListId = MyListUtil.getMyListId(myListId);
			
			if(myListId != null){
				if(this._myListIds.indexOf(myListId) == -1){
					this._myListIds.splice(0,0, myListId);
				}
			}
		}
		
		/**
		 * 
		 * 
		 */
		public function myListReset():void{
			this._myListIds.splice(0, this._myListIds.length);
		}
		
		/**
		 * スケジュール実行を停止します
		 * 
		 */
		public function stop():void{
			if(this._timer != null){
				this._timer.stop();
				this._timer.removeEventListener(TimerEvent.TIMER, timerEventListener);
				this._timer = null;
			}
		}
		
		/**
		 * スケジュール実行を開始します。
		 * 
		 * @param delay スケジューリング間隔。デフォルトは1800000ms。
		 * 
		 */
		public function start(delay:Number = 1800000):void{
			this._delay = delay;
			
			if(this._timer != null){
				this._timer.stop();
				this._timer.removeEventListener(TimerEvent.TIMER, timerEventListener);
				this._timer = null;
			}
			
			this._timer = new Timer(this._delay, 0);
			this._timer.addEventListener(TimerEvent.TIMER, timerEventListener);
			this._timer.start();
			
		}
		
		/**
		 * マイリスト更新を今すぐ実行します。
		 * 
		 */
		public function startNow():void{
			trace("マイリスト更新即時実行");
			LogManager.instance.addLog("マイリスト更新即時実行");
			
			if(!this._renewing){	//実行中で無ければ実施
				next(0);
			}else{
				LogManager.instance.addLog("既に実行中なのでマイリスト更新をスキップ");
			}
			
		}
		
		/**
		 * タイマーから発行されるTimerイベントのリスナです。
		 * 
		 * @param event
		 * 
		 */
		private function timerEventListener(event:TimerEvent):void{
			trace("マイリスト更新のスケジュール実行(間隔:" + this._delay + "ms)");
			LogManager.instance.addLog("マイリスト更新のスケジュール実行(間隔:" + this._delay + "ms)");
			
			if(!this._renewing){	//実行中で無ければ実施
				next(0);
			}else{
				LogManager.instance.addLog("既に実行中なのでマイリスト更新をスキップ");
			}
			
		}
		
		/**
		 * 次のマイリストの取得を行います。
		 * startIndexを指定しないと、純粋にindexを加算します。指定した場合は、指定されたindexから更新を開始します。
		 * @param startIndex
		 * 
		 */
		private function next(startIndex:int = -1):void{
			
			this._renewing = true;
			
			if(startIndex == -1){
				this._index++;
			}else{
				this._index = startIndex;
			}
			
			if(this._index >= this._myListIds.length){
				dispatchEvent(new Event(Event.COMPLETE));
				LogManager.instance.addLog("マイリスト更新のスケジュール実行完了");
				this._renewing = false;
				return;
			}
			
			var id:String = this._myListIds[this._index];
			
			if(id != null){
				myListRenew(id);
			}else{
				next();
			}
		}
		
		/**
		 * 結果を取得します。結果が取得できていない場合はnullが返されます。
		 * @param myListId
		 * @return 
		 * 
		 */
		public function getResult(myListId:String):MyListRenewResultType{
			return this._myListRenewResultMap[myListId];
		}
		
		/**
		 * 指定されたマイリストを更新します。
		 * 
		 * @param myListId
		 * @param enableNext
		 * @return 
		 * 
		 */
		private function myListRenew(myListId:String, enableNext:Boolean = true):void{
			
			if(this._mailAddress != null && this._mailAddress != "" && this._password != null && this._password != ""){
				
				var nnddMyListLoader:NNDDMyListLoader = new NNDDMyListLoader();
				
				LogManager.instance.addLog("マイリストのスケジュール更新開始(" + (this._index + 1) + "/" + this._myListIds.length + "):" + myListId);
				
				dispatchEvent(new MyListRenewProgressEvent(MyListRenewProgressEvent.MYLIST_RENEW_PROGRESS, false, false, this._index+1, this._myListIds.length, myListId));
				
				nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_COMPLETE, myListGetComplete);
				nnddMyListLoader.addEventListener(NNDDMyListLoader.PUBLIC_MY_LIST_GET_FAIL, myListGetFail);
				nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_CANCELD, myListGetFail);
				nnddMyListLoader.addEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_ERROR, myListGetFail);
				nnddMyListLoader.requestDownloadForPublicMyList(_mailAddress, _password, myListId);
				
				function myListGetComplete(event:Event):void{
					nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_COMPLETE, myListGetComplete);
					nnddMyListLoader.removeEventListener(NNDDMyListLoader.PUBLIC_MY_LIST_GET_FAIL, myListGetFail);
					nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_CANCELD, myListGetFail);
					nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_ERROR, myListGetFail);
					
					nnddMyListLoader.close(false, false);
					
					var xml:XML = nnddMyListLoader.xml;
					if(xml != null){
						MyListManager.instance.saveMyList(myListId, xml);
						LogManager.instance.addLog("マイリストのスケジュール更新完了(" + myListId + ")");
						_myListRenewResultMap[myListId] = MyListRenewResultType.SUCCESS;
					}else{
						LogManager.instance.addLog("マイリストのスケジュール更新失敗(" + myListId + ")");
						_myListRenewResultMap[myListId] = MyListRenewResultType.FAIL;
					}
				}
				
				function myListGetFail(event:Event):void{
					nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_COMPLETE, myListGetComplete);
					nnddMyListLoader.removeEventListener(NNDDMyListLoader.PUBLIC_MY_LIST_GET_FAIL, myListGetFail);
					nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_CANCELD, myListGetFail);
					nnddMyListLoader.removeEventListener(NNDDMyListLoader.DOWNLOAD_PROCESS_ERROR, myListGetFail);
					
					nnddMyListLoader.close(false, false);
					
					LogManager.instance.addLog("マイリストのスケジュール更新失敗(" + myListId + ")");
					_myListRenewResultMap[myListId] = MyListRenewResultType.FAIL;
					
				}
				
				if(enableNext){
					var timer:Timer = new Timer(this._delayOfMylist,1);
					timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
						next();
					});
					timer.start();
				}
				
			}else{
				LogManager.instance.addLog("マイリストのスケジュール更新失敗(メールアドレスとパスワードが未設定)");
			}
			
		}

		/**
		 * 
		 */
		public function get delayOfMylist():int
		{
			return _delayOfMylist;
		}

		/**
		 * @private
		 */
		public function set delayOfMylist(value:int):void
		{
			_delayOfMylist = value;
		}

		
	}
	
}