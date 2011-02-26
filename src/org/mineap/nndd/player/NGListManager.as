package org.mineap.nndd.player
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	
	import mx.controls.Alert;
	
	import org.mineap.nicovideo4as.model.Comment;
	import org.mineap.nndd.FileIO;
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.Message;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.player.comment.Command;
	import org.mineap.nndd.player.comment.Comments;
	
	/**
	 * NGListManager.as
	 * 
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */	
	public class NGListManager
	{
		
		private var playerController:PlayerController;
		private var videoPlayer:VideoPlayer;
		private var videoInfoView:VideoInfoView;
		private var logManager:LogManager;
		private var libraryManager:ILibraryManager;
		
		private var ngMap:Object;
		
		/**
		 * 
		 * @param playerController
		 * @param videoPlayer
		 * @param videoInfoView
		 * @param logManager
		 * 
		 */
		public function NGListManager(playerController:PlayerController, videoPlayer:VideoPlayer, videoInfoView:VideoInfoView, logManager:LogManager)
		{
			this.libraryManager = LibraryManagerBuilder.instance.libraryManager;
			this.playerController = playerController;
			this.videoPlayer = videoPlayer;
			this.videoInfoView = videoInfoView;
			this.logManager = logManager;
			this.ngMap = new Object();
		}
		
		/**
		 * 
		 * @param libraryFile
		 * 
		 */
		public function loadNgList(libraryFile:File):Boolean{
			try{
				
				/* NGリスト読み出し */
				var fileIO:FileIO = new FileIO();
				
				if(videoInfoView.ngListProvider.length > 0){
					videoInfoView.ngListProvider.removeAll();
				}
				
				var ngListFile:File = new File(libraryFile.url + "/ngList.xml");
				if(!ngListFile.exists){
					logManager.addLog("NGリストが存在しませんでした。" + ngListFile.nativePath);
					return false;
				}
				
				var ngXML:XML = fileIO.loadXMLSync(libraryFile.url + "/ngList.xml", true);
				var ngList:XMLList = ngXML.children();
				
				if(ngList.length() < 1){
					// ngListが空。
					return false;
				}
				
				for each(var ng:XML in ngList){
					var kind:String = ng.@kind;
					if(kind != Comments.NG_KIND_ARRAY[Comments.NG_ID] &&
							kind != Comments.NG_KIND_ARRAY[Comments.NG_WORD] &&
							kind != Comments.NG_KIND_ARRAY[Comments.PERMISSION_ID] &&
							kind != Comments.NG_KIND_ARRAY[Comments.NG_COMMAND]){
						kind = Comments.NG_KIND_ARRAY[Comments.NG_ID];
					}
					var string:String = decodeURIComponent(ng.text());
					
					videoInfoView.ngListProvider.addItem({
						ng_kind_column:kind,
						ng_word_column:string
					});
				}
				if(logManager != null){
					logManager.addLog("NGリストの読み込み完了:"+ (new File(libraryFile.url + "/ngList.xml")).nativePath);
				}
				ngXML = null;
				ngList = null;
				
				refreshNgMap();
			
				return true;
				
			}catch(error:Error){
				Alert.show("NGリストの読み込みに失敗しました。", "エラー");
				logManager.addLog("NGリストの読み込みに失敗:" + error + ":" + error.getStackTrace());
			}
			
			return false;
		}
		
		/**
		 * NGMapを再構築します。
		 * 
		 */
		public function refreshNgMap():void{
			this.ngMap = new Object();
			for(var i:int = 0; i<videoInfoView.ngListProvider.length; i++){
				
				var ngId:String = videoInfoView.ngListProvider[i].ng_word_column;
				var ngKind:String = videoInfoView.ngListProvider[i].ng_kind_column;
				
				if(ngKind == Comments.NG_KIND_ARRAY[Comments.NG_COMMAND]){
					this.ngMap[ngId.toUpperCase()] = ngKind;
				}else{
					this.ngMap[ngId] = ngKind;
				}
 			}
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get ngWordList():Array{
			var array:Array = new Array();
			for(var i:int = 0; i<videoInfoView.ngListProvider.length; i++){
				if(videoInfoView.ngListProvider[i].ng_kind_column == Comments.NG_KIND_ARRAY[Comments.NG_WORD]){
					array.push(videoInfoView.ngListProvider[i].ng_word_column);
				}
			}
			return array;
		}
		
		/**
		 * 指定されたidがNG(もしくは許可)かどうかチェックし、結果を返します。
		 * 
		 * @param id ユーザID
		 * @param ngKind NGか許可か
		 */
		public function isNgId(id:String, ngKind:String):Boolean{
			var kind:String = this.ngMap[id];
			if(kind != null && ngKind == kind){
				return true;
			}else{
				return false;
			}
		}
		
		/**
		 * 指定されたコマンドがNGコマンドとして登録されているかどうかチェックします
		 * 
		 * @param command コマンド文字列。
		 * @return コマンドがNGとして登録されている場合にtrueを返します。空白区切りのコマンド群を指定すると、コマンド群に含まれるコマンドに一つ以上NGコマンドが存在した場合にtrueを返します。
		 * 
		 */
		public function isNgCommand(command:String):Boolean{
			//　分割
			var array:Array = command.toUpperCase().split(" ");
			
			for each(var com:String in array){
				
				var kind:String = this.ngMap[com];
				
				if(Comments.NG_KIND_ARRAY[Comments.NG_COMMAND] == kind){
					return true;
				}
				
			}
			
			return false;
		}
		
		/**
		 * 
		 * @param libraryFile
		 * 
		 */
		public function saveNgList(libraryFile:File):void{
			//NGリストを保存
			var fileIO:FileIO = new FileIO(logManager);
			var file:File = new File(libraryFile.url + "/ngList.xml");
			
			try{
				
				var ngXML:XML = <ng/>;
				for(var i:int=0; i < videoInfoView.ngListProvider.length; i++){
					ngXML.item[i] = encodeURIComponent(videoInfoView.ngListProvider[i].ng_word_column);
					(ngXML.item[i] as XML).@kind = videoInfoView.ngListProvider[i].ng_kind_column;
				}
				
				fileIO.saveXMLSync(file, ngXML);
				
				logManager.addLog("NGリストを保存:" + file.nativePath);
				
			}catch(error:Error){
				logManager.addLog("NGリストの保存に失敗:" + file.nativePath + ":" + error);
				Alert.show("NGリストの保存に失敗:" + file.nativePath + ":" + error, Message.M_ERROR);
				error.getStackTrace();
			}
			
			try{
				//古いファイルを消す
				var oldFile:File = libraryManager.libraryDir;
				oldFile = new File(oldFile.url + "/ngList.xml");
				if(oldFile.exists){
					oldFile.moveToTrash();
				}
			}catch(error:Error){
				error.getStackTrace();
			}
			
		}
		
		/**
		 * 
		 */
		public function removeItemFromNgList():void{
			videoInfoView.ngListProvider.removeItemAt(videoInfoView.dataGrid_NG.selectedIndex);
			videoInfoView.dataGrid_NG.dataProvider = videoInfoView.ngListProvider;
			videoInfoView.textInput_ng.text = "";
			
			refreshNgMap();
			
			if(this.playerController != null){
				this.playerController.reloadLocalComment();
			}
			
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		public function ngListItemClicked(event:Event):void{
			if(videoInfoView.dataGrid_NG != null){
				videoInfoView.textInput_ng.text = videoInfoView.dataGrid_NG.selectedItem.ng_word_column;
			}
		}
		
		/**
		 * TextInputのIDをNGリストに追加します。
		 */
		public function addItemToNgList(ng:String, ngKind:String):void{
//			var ng:String = videoInfoView.textInput_ng.text;
//			var ngKind:String = videoInfoView.combobox_ngKind.selectedLabel;
			
			if(ng.length > 0){
				for(var index:int = 0; index<videoInfoView.ngListProvider.length; index++){
					if(videoInfoView.ngListProvider[index][0] == ngKind && videoInfoView.ngListProvider[index][1] == ng){
						return;
					}
				}
				videoInfoView.ngListProvider.addItem({
					ng_kind_column:ngKind,
					ng_word_column:ng
				});
				videoInfoView.dataGrid_NG.dataProvider = videoInfoView.ngListProvider;
			}
			
			videoInfoView.textInput_ng.text = "";
			
			refreshNgMap();
			
			if(this.playerController != null){
				this.playerController.reloadLocalComment();
			}
		}
		
		/**
		 * NGリストにNGIDを追加します。
		 * @param id
		 * 
		 */
		public function addNgID(id:String):void{
			for(var index:int = 0; index<videoInfoView.ngListProvider.length; index++){
				if(videoInfoView.ngListProvider[index][0] == Comments.NG_KIND_ARRAY[Comments.NG_ID] && videoInfoView.ngListProvider[index][1] == id){
					return;
				}
			}
			this.videoInfoView.ngListProvider.addItem({
				ng_kind_column:Comments.NG_KIND_ARRAY[Comments.NG_ID],
				ng_word_column:id
			});
			
			refreshNgMap();
			
			if(this.playerController != null){
				this.playerController.reloadLocalComment();
			}
		}
		
		/**
		 * NGリストに許可IDを追加します。
		 * @param id
		 * 
		 */
		public function addPermissionId(id:String):void{
			for(var index:int = 0; index<videoInfoView.ngListProvider.length; index++){
				if(videoInfoView.ngListProvider[index][0] == Comments.NG_KIND_ARRAY[Comments.PERMISSION_ID] && videoInfoView.ngListProvider[index][1] == id){
					return;
				}
			}
			this.videoInfoView.ngListProvider.addItem({
				ng_kind_column:Comments.NG_KIND_ARRAY[Comments.PERMISSION_ID],
				ng_word_column:id
			});
			
			refreshNgMap();
			
			if(this.playerController != null){
				this.playerController.reloadLocalComment();
			}
		}
		
		/**
		 * 
		 * @param word
		 * 
		 */
		public function addNgWord(word:String):void{
			for(var index:int = 0; index<videoInfoView.ngListProvider.length; index++){
				if(videoInfoView.ngListProvider[index][0] == Comments.NG_KIND_ARRAY[Comments.NG_WORD] && videoInfoView.ngListProvider[index][1] == word){
					return;
				}
			}
			this.videoInfoView.ngListProvider.addItem({
				ng_kind_column:Comments.NG_KIND_ARRAY[Comments.NG_WORD],
				ng_word_column:word
			});
			
			refreshNgMap();
			
			if(this.playerController != null){
				this.playerController.reloadLocalComment();
			}
		}
		
		/**
		 * 
		 * @param command
		 * 
		 */
		public function addNgCommand(command:String):void{
			for(var index:int = 0; index<videoInfoView.ngListProvider.length; index++){
				if(videoInfoView.ngListProvider[index][0] == Comments.NG_KIND_ARRAY[Comments.NG_COMMAND] && videoInfoView.ngListProvider[index][1] == command){
					return;
				}
			}
			this.videoInfoView.ngListProvider.addItem({
				ng_kind_column:Comments.NG_KIND_ARRAY[Comments.NG_COMMAND],
				ng_word_column:command
			});
			
			refreshNgMap();
			
			if(this.playerController != null){
				this.playerController.reloadLocalComment();
			}
		}
		
		
		/**
		 * 
		 */
		public function ngListRenew(event:Event):void{
			if(videoInfoView.ngListProvider != null && videoInfoView.dataGrid_NG != null){
				videoInfoView.dataGrid_NG.dataProvider = videoInfoView.ngListProvider;
				refreshNgMap();
			}
		}
		
	}
}