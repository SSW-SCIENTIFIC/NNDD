package org.mineap.nndd.player
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.Message;
	import org.mineap.nndd.NNDDMyListAdder;

	/**
	 * マイリストへの追加を行うクラスです。(Player用)
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class PlayerMylistAddr
	{
		
		private static var playerMylistAddr:PlayerMylistAddr = new PlayerMylistAddr();
		
		private var _myListAddr:NNDDMyListAdder = null;
		
		private var _logger:LogManager = LogManager.instance;
		
		private var _videoTitle:String = null;
		
		/**
		 * 
		 * @return 唯一のPlayerMylistAddrのインスタンスを返す
		 * 
		 */
		public static function get instance():PlayerMylistAddr
		{
			return playerMylistAddr;
		}
		
		/**
		 * コンストラクタ。シングルトンなので使用不可。
		 * 
		 */
		public function PlayerMylistAddr()
		{
			if(playerMylistAddr != null){
				throw new ArgumentError("PlayerMylistAddrはインスタンス化できません。");
			}
		}
		
		/**
		 * 指定されたユーザーアカウントおよびマイリストに、動画を追加します。
		 * 
		 * @param mailAddress
		 * @param password
		 * @param myListId
		 * @param videoId
		 * @param videoTitle
		 * 
		 */
		public function addMyList(mailAddress:String, password:String, myListId:String, videoId:String, videoTitle:String):void
		{
			
			_logger.addLog("***マイリストへの追加***");
			
			if(this._myListAddr != null)
			{
				_logger.addLog("既に実行中です...");
				return;
			}
			
			if(myListId == null || myListId == ""){
				Alert.show("マイリストが選択されていません。", Message.M_ERROR);
				_logger.addLog("***マイリストへの追加失敗***");
				FlexGlobals.topLevelApplication.activate();
				return;
			}
			if(mailAddress == null || mailAddress == "" || password == null || password == ""){
				Alert.show("ニコニコ動画にログインできません。ユーザー名とパスワードを設定してください。");
				_logger.addLog("***マイリストへの追加失敗***");
				FlexGlobals.topLevelApplication.activate();
				return;
			}
			if(videoId == null){
				Alert.show("動画のIDが取得できませんでした。動画を再生し直した後、もう一度試してみてください。", Message.M_ERROR);
				_logger.addLog("***マイリストへの追加失敗***");
				FlexGlobals.topLevelApplication.activate();
				return;
			}
			
			this._videoTitle = videoTitle;
			
			this._myListAddr = new NNDDMyListAdder(this._logger);
			
			this._myListAddr.addEventListener(NNDDMyListAdder.ADD_MYLIST_SUCESS, function(event:Event):void{
				_logger.addLog("次の動画をマイリストに追加:" + videoTitle);
				_logger.addLog("***マイリストへの追加成功***");
				var text:String = "次の動画をマイリストに追加しました。\n" + videoTitle;
				var alert:Alert = Alert.show(text, Message.M_MESSAGE);
				var timer:Timer = new Timer(1000, 5);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void{
					if(alert != null){
						trace("remove");
						PopUpManager.removePopUp(alert);
					}
				});
				timer.start();
				_myListAddr.close();
				_myListAddr = null;
			});
			this._myListAddr.addEventListener(NNDDMyListAdder.ADD_MYLIST_DUP, function(event:Event):void{
				_logger.addLog("次の動画はすでにマイリストに登録済:" + videoTitle);
				_logger.addLog("***マイリストへの追加失敗***");
				Alert.show("次の動画は既にマイリストに追加されています。\n" + videoTitle, Message.M_MESSAGE);
				_myListAddr.close();
				_myListAddr = null;
			});
			this._myListAddr.addEventListener(NNDDMyListAdder.ADD_MYLIST_NOT_EXIST, function(event:Event):void{
				_logger.addLog("次の動画は存在しない:" + videoTitle);
				_logger.addLog("***マイリストへの追加失敗***");
				Alert.show("次の動画をマイリストに追加しようとしましたが、動画が存在しませんでした。\n" + videoTitle, Message.M_MESSAGE);
				_myListAddr.close();
				_myListAddr = null;
			});
			this._myListAddr.addEventListener(NNDDMyListAdder.ADD_MYLSIT_FAIL, function(event:ErrorEvent):void{
				_logger.addLog("マイリストへの登録に失敗:" + videoTitle + ":" + event);
				_logger.addLog("***マイリストへの追加失敗***");
				Alert.show("マイリストへの登録に失敗\n" + event, Message.M_ERROR);
				FlexGlobals.topLevelApplication.activate();
				_myListAddr.close();
				_myListAddr = null;
			});
			this._myListAddr.addEventListener(NNDDMyListAdder.LOGIN_FAIL, function(event:Event):void{
				_logger.addLog("マイリストへの登録に失敗:" + videoTitle + ":" + event);
				_logger.addLog("***マイリストへの追加失敗***");
				Alert.show("マイリストへの登録に失敗\n" + event, Message.M_ERROR);
				FlexGlobals.topLevelApplication.activate();
				_myListAddr.close();
				_myListAddr = null;
			});
			this._myListAddr.addEventListener(NNDDMyListAdder.GET_MYLISTGROUP_FAIL, function(event:Event):void{
				_logger.addLog("マイリストへの登録に失敗:" + videoTitle + ":" + event);
				_logger.addLog("***マイリストへの追加失敗***");
				Alert.show("マイリストへの登録に失敗\n" + event, Message.M_ERROR);
				FlexGlobals.topLevelApplication.activate();
				_myListAddr.close();
				_myListAddr = null;
			});
			
			this._myListAddr.addMyList("http://www.nicovideo.jp/watch/" + videoId, myListId, mailAddress, password);	
		}
		
		/**
		 * ニコニコ動画への通信をクローズします
		 * 
		 */
		public function close():void
		{
			_logger.addLog("マイリストへの登録をキャンセル:" + _videoTitle);
			_logger.addLog("***マイリストへの追加失敗***");
			
			try{
				_myListAddr.close();
			}catch(error:Error){
				trace(error.getStackTrace());
			}
			_myListAddr = null;
		}
		
		/**
		 * PlayerMylistAddrが現在マイリストへの追加処理中かどうかを返します。
		 * 
		 * @return 
		 * 
		 */
		public function get isAdding():Boolean{
			if(_myListAddr == null)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		
	}
}