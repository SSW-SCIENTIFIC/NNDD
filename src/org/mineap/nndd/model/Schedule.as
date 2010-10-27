package org.mineap.nndd.model
{
	import flash.events.EventDispatcher;

	/**
	 * スケジュールを表すオブジェクトです。<br>
	 * 1.間隔（毎週、毎日）<br>
	 * 2.間隔が毎週の場合は、実行する曜日<br>
	 * 3.時間（時、分）<br>
	 * を保持します。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class Schedule extends EventDispatcher
	{
		
		/**
		 * 「毎週」を表す定数です
		 */
		public static const WEEKLY:int = 0;
		
		/**
		 * 「毎日」を表す定数です
		 */
		public static const DAILY:int = 1;
		
		/**
		 * 間隔を表す文字列表現です。
		 */
		public static const INTERVAL_NAME_ARRAY:Array = new Array("毎週","毎日");
		
		/**
		 * 曜日を表す文字列表現です。
		 */
		public static const DAY_NAME_ARRAY:Array = new Array("日曜","月曜","火曜","水曜","木曜","金曜","土曜");
		
		/**
		 * スケジュール実行間隔です
		 */
		public var interval:int = Schedule.WEEKLY;
		
		/**
		 * スケジュール実行間隔が「毎週」の時の実行する曜日です
		 */
		public var dayOfTheWeek:int = -1;
		
		/**
		 * スケジュールを実行する時間です
		 */
		public var hour:int = 0;
		
		/**
		 * スケジュールを実行する分です
		 */
		public var minutes:int = 0;
		
		/**
		 * コンストラクタ。<br>
		 * @param interval スケジュール間隔。Schedule.DAILYかSchedule.WEEKLYを指定します。
		 * @param dayOfTheWeek 曜日を指定します。「日、月、火、水、木、金、土」に対応する数字、「0,1,2,3,4,5,6」を指定してください。
		 * @param hour 時間を指定します。0-23の値です。
		 * @param minites 分を指定します。0-59の値です。
		 * 
		 */
		public function Schedule(interval:int = Schedule.DAILY, dayOfTheWeek:int = -1, hour:int = 0, minites:int = 0)
		{
			this.interval = interval;
			
			if(interval == Schedule.WEEKLY){
				this.dayOfTheWeek = dayOfTheWeek;
			}else{
				this.dayOfTheWeek = -1;
			}
			
			this.hour = hour;
			
			this.minutes = minites;
		}
		
		/**
		 * 設定された曜日の文字列表現を返します。<br>
		 * ただし、曜日が-1の時は空の文字列を返します。
		 * @return 
		 * 
		 */
		public function get dayString():String{
			if(this.dayOfTheWeek == -1){
				return "";
			}
			return Schedule.DAY_NAME_ARRAY[this.dayOfTheWeek];
		}
		
		/**
		 * 設定された間隔の文字列表現を返します。
		 * @return 
		 * 
		 */
		public function get intervalString():String{
			return Schedule.INTERVAL_NAME_ARRAY[this.interval];
		}
		
		/**
		 * 設定された時間の文字列表現を返します。
		 * @return 
		 * 
		 */
		public function get timeString():String{
			var hours:String = String(this.hour);
			var minutes:String = String(this.minutes);
			if(hours.length == 1){
				hours = "0" + hours;
			}
			if(minutes.length == 1){
				minutes = "0" + minutes;
			}
			
			return hours + ":" + minutes;
		}
		
	}
}