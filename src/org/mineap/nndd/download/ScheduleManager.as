package org.mineap.nndd.download
{
	import flash.data.EncryptedLocalStore;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import mx.controls.Alert;

	import org.mineap.nndd.Message;
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.model.Schedule;

	/**
	 * ScheduleManager.as<br>
	 * ScheduleManagerクラスは、スケジュールを管理するクラスです。<br>
	 * 指定されたスケジュールを元に、ダウンロードを実施します。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class ScheduleManager
	{
		private var _logManager:LogManager = null;
		private var _downloadManager:DownloadManager = null;
		private var _schedule:Schedule = null;
		private var _scheduleTimer:Timer = null;
		private var _isDownloading:Boolean = false;
		private var _isScheduleEnable:Boolean = false;
		
		/**
		 * コンストラクタ<br>
		 * スケジューラを初期化します。
		 * 
		 * @param logManager
		 * @param downloadManager
		 * 
		 */
		public function ScheduleManager(logManager:LogManager, downloadManager:DownloadManager)
		{
			this._downloadManager = downloadManager;
			this._logManager = logManager;
			
			this.loadSchedule();
			
		}
		
		
		/**
		 * 現在のスケジュールを返します。
		 * @return 
		 * 
		 */
		public function get schedule():Schedule
		{
			return _schedule;
		}

		/**
		 * スケジュールを設定します。<br>
		 * 設定時にすでに動作中のスケジュールがある場合は、そのスケジュールを停止します。<br>
		 * ただし、スケジュールを設定しただけではスケジューラは起動しません。別途、timerStart()を呼んでください。
		 * @param v
		 * 
		 */
		public function set schedule(v:Schedule):void
		{
			this.timerStop();
			_schedule = v;
			
			saveSchedule();
		}
		
		/**
		 * (指定された)スケジュールを使ってスケジューリングを開始します。<br>
		 * 
		 * @param schedule
		 */
		public function timerStart(schedule:Schedule = null):void{
			if(schedule != null){
				this._schedule = schedule;
			}
			
			if(this._schedule == null){
				Alert.show("有効なスケジュールが設定されていません。", Message.M_ERROR);
				return;
			}
			
			this.timerStop();
			
			this._scheduleTimer = new Timer(100);
			this._scheduleTimer.addEventListener(TimerEvent.TIMER, scheduleTimerHandler);
			this._scheduleTimer.start();
			
			this._logManager.addLog("スケジュール開始:" + this.scheduleString );
			
			saveSchedule();
		}
		
		/**
		 * スケジューリングを停止します。
		 * 
		 */
		public function timerStop():void{
			if(this._scheduleTimer != null){
				this._scheduleTimer.stop();
				this._scheduleTimer = null;
			}
			
			saveSchedule();
		}
		
		/**
		 * スケジューラが動作しているかどうかを返します。
		 * @return 
		 * 
		 */
		public function get isRunning():Boolean{
			if(this.schedule != null){
				return this._scheduleTimer.running;
			}else{
				return false;
			}
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function scheduleTimerHandler(event:TimerEvent):void{
			//現在の時刻を取得
			var nowDate:Date = new Date();
			
			//曜日(毎日ならいらない)
			var day:Number = nowDate.day;
			//時
			var hours:Number = nowDate.hours;
			//分
			var minitues:Number = nowDate.minutes;
			
			//毎週のとき
			if(this._schedule.interval == Schedule.WEEKLY){
				//曜日が違ったらreturn
				if(this._schedule.dayOfTheWeek != day){
					return;
				}
			}
			
			//指定された時刻か？
			if(this._schedule.hour == hours && this._schedule.minutes == minitues){
				//ダウンロード中ではないか？
				if(!this._isDownloading){
					this._logManager.addLog("ダウンロードをスケジュール実行:" + new Date().toLocaleString());
					// スキップフラグを無視する
					this._downloadManager.next(true);
					this._isDownloading = true;
				}else{
					//すでにダウンロード中。タイマー再起動。
					this.timerStop();
					this.timerStart();
				}
			}else{
				//ダウンロード中フラグを元に戻す
				this._isDownloading = false;
			}
		}
		
		/**
		 * スケジューリングが有効かどうかを返します。
		 * @return 
		 * 
		 */
		public function get isScheduleEnable():Boolean{
			return this._isScheduleEnable;
		}
		
		/**
		 * スケジューリングが有効かどうかを設定します。
		 * @param v 
		 */
		public function set isScheduleEnable(v:Boolean):void{
			this._isScheduleEnable = v;
			
			saveSchedule();
		}
		
		/**
		 * スケジュール実行時予定時刻の文字列を返します。
		 * @return 
		 * 
		 */
		public function get scheduleString():String{
			if(this._isScheduleEnable && this._schedule != null){
				var time:String = this.schedule.intervalString;
				time = time + " " + this.schedule.dayString; 
				time = time + " " + this.schedule.timeString;
				return time;
			}else{
				return "なし";
			}
		}
		
		/**
		 * スケジュールを保存します
		 * 
		 */
		public function saveSchedule():void{
			
			try{
				
				//スケジューリングが有効かどうか
				EncryptedLocalStore.removeItem("isScheduleEnable");
				var bytes:ByteArray = new ByteArray();
				bytes.writeBoolean(this._isScheduleEnable);
				EncryptedLocalStore.setItem("isScheduleEnable", bytes);
				
				if(this._schedule != null){
					
					//スケジュール実行間隔
					EncryptedLocalStore.removeItem("scheduleInterval");
					bytes = new ByteArray();
					bytes.writeInt(this._schedule.interval);
					EncryptedLocalStore.setItem("scheduleInterval", bytes);
					
					//スケジュール曜日
					EncryptedLocalStore.removeItem("scheduleDay");
					bytes = new ByteArray();
					bytes.writeInt(this._schedule.dayOfTheWeek);
					EncryptedLocalStore.setItem("scheduleDay", bytes);
					
					//スケジュール実行時間
					EncryptedLocalStore.removeItem("scheduleHours");
					bytes = new ByteArray();
					bytes.writeInt(this._schedule.hour);
					EncryptedLocalStore.setItem("scheduleHours", bytes);
					
					//スケジュール実行分
					EncryptedLocalStore.removeItem("scheduleMinutes");
					bytes = new ByteArray();
					bytes.writeInt(this._schedule.minutes);
					EncryptedLocalStore.setItem("scheduleMinutes", bytes);
				}
				
			}catch(error:Error){
				this._logManager.addLog("スケジュールの保存に失敗:" + error + ":" + error.getStackTrace());
			}
		}
		
		/**
		 * スケジュールをロードします<br>
		 * 
		 */
		public function loadSchedule():void{
			
			var interval:int = -1;
			var day:int = -1;
			var hours:int = -1;
			var minuites:int = -1;
			
			try{
				
				//スケジューリングが有効かどうか
				var storedValue:ByteArray = EncryptedLocalStore.getItem("isScheduleEnable");
				if(storedValue != null){
					this._isScheduleEnable = storedValue.readBoolean();
				}
				
				
				//スケジュール間隔
				storedValue = EncryptedLocalStore.getItem("scheduleInterval");
				if(storedValue != null){
					interval = storedValue.readInt();
				}
				
				//スケジュール曜日
				storedValue = EncryptedLocalStore.getItem("scheduleDay");
				if(storedValue != null){
					day = storedValue.readInt();
				}
				
				//スケジュール実行時間
				storedValue = EncryptedLocalStore.getItem("scheduleHours");
				if(storedValue != null){
					hours = storedValue.readInt();
				}
				
				//スケジュール実行分
				storedValue = EncryptedLocalStore.getItem("scheduleMinutes");
				if(storedValue != null){
					minuites = storedValue.readInt();
				}
				
			}catch(error:Error){
				this._logManager.addLog("スケジュールの読み込みに失敗:" + error + ":" + error.getStackTrace());
			}
			
			if(interval != -1 && ((interval == Schedule.WEEKLY && day != -1) || interval == Schedule.DAILY ) && hours != -1 && minuites != -1){
				this._schedule = new Schedule(interval, day, hours, minuites);
			}
			
		}
		
	}
}