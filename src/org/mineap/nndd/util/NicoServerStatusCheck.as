package org.mineap.nndd.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.player.comment.Command;
	
	import mx.controls.Label;

	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class NicoServerStatusCheck extends EventDispatcher
	{
		
		private var _logManager:LogManager = null;
		private var _loader:URLLoader = null;
		
		private var _count:int = 0;
		private var _successCount:int = 0;
		private var _maxCount:int = 1;
		
		private var _time:Date = null;
		
		private var _urlArray:Array = null;
		private var _diffArray:Array = new Array();
		
		private var _stop:Boolean = false;
		
		/**
		 * 
		 * @param logManager
		 * 
		 */
		public function NicoServerStatusCheck(logManager:LogManager)
		{
			this._logManager = logManager;
		}
		
		/**
		 * 
		 * @param urlArray
		 * @param label
		 * 
		 */
		public function check(urlArray:Array, label:Label, header:String):void{
			
			this._maxCount = urlArray.length;
			this._urlArray = urlArray;
			
			checkUrl(urlArray[0], label, header);
			
		}
		
		/**
		 * 
		 * @param url
		 * @param label
		 * 
		 */
		public function checkUrl(url:String, label:Label, header:String):void{
			
			this._count++;
			
			label.setStyle("color", 734012);
			label.setStyle("fontWeight", "nomal");
			label.text = this._count + "/" + this._maxCount + "のURLについて調査中...";
			label.toolTip = label.text;
			label.validateNow();
			
			this._time = new Date();
			
			this._loader = new URLLoader();
			this._loader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, function(event:HTTPStatusEvent):void{
				URLLoader(event.currentTarget).close();
				
				var time:Date = new Date();
				var diff:Number = time.getTime() - _time.getTime();
				_diffArray.push(diff);
				
				label.text = _count + "/" + _maxCount + "完了 [応答: " + diff + " ms]";
				label.toolTip = label.text;
				
				if(event.status >= 500){
					label.text = _count + "/" + _maxCount + "完了 [応答: " + diff + " ms, ステータス: "+ event.status +"]";
					_logManager.addLog("サーバーがエラーを報告しています [status: " + event.status + ", url: " + event.responseURL + "]");
				}else{
					_successCount++;
				}
				
				var timer:Timer = new Timer(1000, 1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void{
					next(label, header);
				});
				timer.start();
				
			});
			this._loader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				URLLoader(event.currentTarget).close();
				
				var time:Date = new Date();
				var diff:Number = time.getTime() - _time.getTime();
				_diffArray.push(diff);
				
				label.text = _count + "/" + _maxCount + "完了 [応答: " + diff + " ms, エラー: "+ event.text +"]";
				label.toolTip = label.text;
				
				_logManager.addLog("サーバーに接続できませんでした(入出力エラー) [text: " + event.text + ", url: " + decodeURIComponent(url) + "]");
				
				var timer:Timer = new Timer(500, 1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void{
					next(label, header);
				});
				timer.start();
				
			});
			this._loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void{
				URLLoader(event.currentTarget).close();
				
				var time:Date = new Date();
				var diff:Number = time.getTime() - _time.getTime();
				_diffArray.push(diff);
				
				label.text = _count + "/" + _maxCount + "完了 [応答: " + diff + " ms, エラー: "+ event.text +"]";
				label.toolTip = label.text;
				_logManager.addLog("サーバーに接続できませんでした(セキュリティエラー) [text: " + event.text + ", url: " + decodeURIComponent(url) + "]");
				
				var timer:Timer = new Timer(1000, 1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function():void{
					next(label, header);
				});
				timer.start();
				
			});
			
			this._loader.load(new URLRequest(url));
		}
		
		/**
		 * 
		 * @param label
		 * 
		 */
		private function next(label:Label, header:String):void{
			
			if(this._stop){
				
				label.setStyle("color", null);
				label.text = "キャンセル [平均応答時間:" + int(getAverage()) + " ms]";
				label.setStyle("fontWeight", "nomal");
				dispatchEvent(new Event(Event.COMPLETE));
				
			}else{
				
				if(this._count >= this._maxCount || this._urlArray == null){
					
					if(this._successCount == 0){
						label.text = "サーバーから応答がありません [平均応答時間:" + int(getAverage()) + " ms]";
						label.setStyle("color", Command.COLLOR_VALUE_ARRAY[Command.RED]);
						label.setStyle("fontWeight", "bold");
						label.toolTip = label.text;
					}else if(this._maxCount - this._successCount > 0){
						label.text = "応答が無いサーバーがありました [平均応答時間:" + int(getAverage()) + " ms]";
						label.setStyle("color", int("0xC06010"));
						label.setStyle("fontWeight", "bold");
						label.toolTip = label.text;
					}else{
						if(getAverage() < 1000){
							label.text = "正常にアクセスできました [平均応答時間:" + int(getAverage()) + " ms]";
							label.setStyle("color", int("0x006010"));
							label.setStyle("fontWeight", "nomal");
							label.toolTip = label.text;
						}else{
							label.text = "混み合っています [平均応答時間:" + int(getAverage()) + " ms]";
							label.setStyle("color", int("0xC06010"));
							label.setStyle("fontWeight", "bold");
							label.toolTip = label.text;
						}
					}
					_logManager.addLog(header + ":" + label.text);
					
					dispatchEvent(new Event(Event.COMPLETE));
					
				}else{
					checkUrl(this._urlArray[this._count], label, header);
				}
			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function getAverage():Number{
			
			var sum:Number = 0;
			
			for each(var num:Number in this._diffArray){
				sum += num;
			}
			
			return sum/this._diffArray.length;
		}
		
		/**
		 * 
		 * 
		 */
		public function close():void{
			
			this._stop = true;
			
			try{
				this._loader.close();
			}catch(error:Error){
				trace(error.getStackTrace());
			}	
		}
		
	}
}