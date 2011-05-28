package org.mineap.nndd.player.comment
{
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	
	import mx.controls.Text;
	import mx.events.FlexEvent;
	
	import org.mineap.nInterpreter.IAnalyzeResult;
	import org.mineap.nInterpreter.ResultType;
	import org.mineap.nInterpreter.operation.jump.JumpResult;
	import org.mineap.nInterpreter.operation.seek.SeekResult;
	import org.mineap.nndd.model.NNDDComment;
	import org.mineap.nndd.player.PlayerController;
	import org.mineap.nndd.view.NNDDText;

	/**
	 * CommentManager.as
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class CommentManager
	{
		private var comments:Comments;
		
		private var videoPlayer:VideoPlayer;
		private var videoInfoView:VideoInfoView;
		private var playerController:PlayerController;
		
		private var jihouVideoIdMap:Object = new Object();
		private var jihouIsPlayMap:Object = new Object();
		
		private var _commentAlpha:Number = 1;
		private var _isAntiAliasEnable:Boolean = false;
		
		private var _isCommentBold:Boolean = false;
		
		private var commentNomalTextArray:Vector.<Vector.<NNDDText>> = new Vector.<Vector.<NNDDText>>(2);
		
		private var commentUeTextArray:Vector.<NNDDText> = new Vector.<NNDDText>(12);
		
		private var commentShitaTextArray:Vector.<NNDDText> = new Vector.<NNDDText>(12);
		
		/**
		 * コンストラクタ<br>
		 * 指定されたVidepPlayerでCommentManagerを初期化します。
		 * @param videoPlayer
		 * 
		 */
		public function CommentManager(videoPlayer:VideoPlayer, videoInfoView:VideoInfoView, playerController:PlayerController)
		{
			
			commentNomalTextArray[0] = new Vector.<NNDDText>(12);
			commentNomalTextArray[1] = new Vector.<NNDDText>(12);
			
			this.videoPlayer = videoPlayer;
			this.videoInfoView = videoInfoView;
			this.playerController = playerController;
		}
		
		/**
		 * デストラクタ
		 * 保持するCommentsがnullで無い場合、Comments.destructor()を呼び出してGCを助けます。
		 * さらに、Commentsに対してnull参照を設定します。
		 */
		public function destructor():void{
			if(this.comments != null){
				this.comments.destructor();
			}
			this.comments = null;
		}
		
		/**
		 * 引数で渡されたコメントでCommentManagerを初期化します。<br>
		 * このメソッドは、FLV、SWFのどちらでも利用できます。 
		 * @param comments
		 * @param displayObject
		 * @return 
		 * 
		 */
		public function initComment(comments:Comments, displayObject:DisplayObjectContainer):Boolean{
			
			// 
			this.destructor();
			
			// 持ってるもの全部リセット
			this.removeAll();
			
			this.comments = comments;
			this.addText(displayObject);
			return true;
		}
		
		/**
		 * 引数で渡されたCommentsオブジェクトでCommentManagerが保持するコメントを上書きします。
		 * 
		 * @param comments
		 * 
		 */
		public function setComments(comments:Comments):void
		{
			this.comments = comments;
		}
		
		/**
		 * 現在CommentManagerに設定されているCommentsオブジェクトを返します。
		 * @return 
		 * 
		 */
		public function getComments():Comments
		{
			return this.comments;
		}
		
		/**
		 * 通常のコメントを移動させます。
		 * @param progressInterval　呼び出しの遅延時間（秒）です。
		 * @param showSec コメントを画面に表示する時間（秒）です。
		 * @param isReverce コメントを逆方向に動かすかどうかを指定します。
		 */
		public function moveComment(progressInterval:Number, showSec:int = 3, isReverce:Boolean = false):void{
			for(var j:int = 0; j<commentNomalTextArray.length; j++){
				for(var i:int = 0; i<commentNomalTextArray[j].length; i++){
					if(commentNomalTextArray[j][i] != null && commentNomalTextArray[j][i].vpos != -1){
						
						var width:int = videoPlayer.nativeWindow.width;
						var dist:int = (width/(showSec))*progressInterval;
						commentNomalTextArray[j][i].x -= (dist + (dist/50)*commentNomalTextArray[j][i].text.length);
						
					}
				}
			}
		}
		
		/**
		 * ueコメントおよびshitaコメントを適した場所に移動させます。
		 * 
		 */
		public function adjustCommentHight():void{
			//TODO 
		}
		
		
		/**
		 * 指定されたvposとmailを使って動画再生用ビューにコメントをセットします。
		 * @param vpos 表示タイミングです。
		 * @param interval このメソッドが呼び出されるインターバルです。
		 * @param isShow コメントの表示状態です。
		 * @return 
		 * 
		 */
		public function setComment(vpos:Number, interval:int, isShow:Boolean):Vector.<NNDDComment>
		{
			var commentArray:Vector.<NNDDComment> = comments.getComment(vpos, interval);
			var command:Command = new Command();
			var result:Boolean = false;
			var returnCommentArray:Vector.<NNDDComment> = new Vector.<NNDDComment>();
			
			var comment:NNDDComment = null;
			var iSize:uint = commentArray.length;
			for(var i:int = 0; i<iSize; i++){
				comment = commentArray[i];
				
				var firstChar:String = comment.text.charAt(0);
				if(firstChar == "@" || firstChar == "＠" || firstChar == "/"){
					
					// TODO 命令解析はもう少しシンプルにやりたい
					var secondChar:String = comment.text.charAt(1);
					var analyzeResult:Array = null;
					var iAnalyzeResult:IAnalyzeResult = null;
					
					if(firstChar == "/"){
						//これはニワン語
						// TODO ニワン語かどうかの判定とか、コメントから命令を解析する機能とか、そういうのも必要。
						
						//解析
						iAnalyzeResult = command.getAnalyzeResult(comment.text);
						
						if(iAnalyzeResult != null){
							
							if(iAnalyzeResult.resultType == ResultType.JUMP){
								var jumpResult:JumpResult = JumpResult(iAnalyzeResult);
								playerController.jump(jumpResult.id, jumpResult.msg);
							}else if(iAnalyzeResult.resultType == ResultType.SEEK){
								var seekResul:SeekResult = SeekResult(iAnalyzeResult);
								playerController.seekOperation(Number(seekResul.vpos));
							}
							
						}
						
						
					}else if(secondChar == "C" || secondChar == "Ｃ"){
						analyzeResult = command.getNicowariVideoID(comment.text);
						
						var nicowariVideoID:String = analyzeResult[0];
						var isPlay:int = analyzeResult[1];
						var time:String = analyzeResult[2];
						if(nicowariVideoID != null && nicowariVideoID != "" && (time == null || time == "")){
							//ニコ割再生開始
							playerController.playNicowari(nicowariVideoID, isPlay);
						}else{
							//時報を設定
							setJihou(nicowariVideoID, isPlay, time);
						}
					}else if(secondChar == "ジ"){
						
						//TODO　ココがうまくいってない
						iAnalyzeResult = command.getAnalyzeResultByNicoScript(comment.text);
						
						if(iAnalyzeResult != null){
							
							if(iAnalyzeResult.resultType == ResultType.JUMP){
								var jumpResult:JumpResult = JumpResult(iAnalyzeResult);
								playerController.jump(jumpResult.id, jumpResult.msg);
							}else if(iAnalyzeResult.resultType == ResultType.SEEK){
								var seekResul:SeekResult = SeekResult(iAnalyzeResult);
								playerController.seekOperation(Number(seekResul.vpos));
							}
							
						}
					}
					
				}else{
					/* 通常コメント */
					var commandPosition:int = command.getPosition(comment.mail);
					if(comment.text != ""){
						returnCommentArray.push(comment);
						if(isShow){
							switch(commandPosition){
								case Command.UE:
									this.addUeComment(comment.vpos, comment.text, command.getSize(comment.mail), command.getColorByCommand(comment.mail), comment.no, comment.mail);
									break;
								case Command.SHITA:
									this.addShitaComment(comment.vpos, comment.text, command.getSize(comment.mail), command.getColorByCommand(comment.mail), comment.no, comment.mail);
									break;
								case Command.NAKA:
								default:
									this.addNomalComment(comment.vpos, comment.text, command.getSize(comment.mail), command.getColorByCommand(comment.mail), comment.no, comment.mail);
									break;
							}
						}
					}
				}
			}
			
			return returnCommentArray;
		}
		
		/**
		 * 時報を設定します。指定した時刻には一つのニコ割IDしか登録できません。
		 * 
		 * @param videoId 時報で再生するニコ割ID
		 * @param isPlay 時報再生時に動画本体の再生を続けるかどうか。Comments.NICOWARI_PLAYなら再生する、NICOWARI_STOPなら停止する。
		 * @param time 時報を再生する時刻。hhmm形式。
		 * 
		 */
		public function setJihou(videoId:String, isPlay:int, time:String):void{
			jihouVideoIdMap[time] = videoId;
			jihouIsPlayMap[time] = isPlay;
		}
		
		/**
		 * hhmm形式で渡された時刻が時報の再生対象かどうか調べ、対象であればニコ割IDおよびComments.NICOWARI_PLAY or NICOWARI_STOPを返します。
		 * 対象の時刻でなければnullを返します。
		 * @param time
		 * @return Array("ニコ割ID", Comments.NICOWARI_PLAY or Comments.NICOWARI_STOP)
		 */
		public function isJihouSettingTime(time:String):Array{
			var result:Array = null;			
			var videoId:String = jihouVideoIdMap[time];
			var isPlay:int = jihouIsPlayMap[time];
			
			if(videoId != null){
				if(isPlay != Command.NICOWARI_PLAY && isPlay != Command.NICOWARI_STOP){
					isPlay = Command.NICOWARI_PLAY;
				}
				
				result = new Array(videoId, isPlay);
			}
			
			return result;
		}
		
		/**
		 * 指定された時刻に対応する時報設定を削除します。
		 * 
		 * @param time
		 * 
		 */
		public function removeJihouSettingTime(time:String):void{
			jihouIsPlayMap[time] = null;
			jihouVideoIdMap[time] = null;
		}
		
		/**
		 * ポストされたコメントを画面上に追加します。
		 * array [vpos,comment,mail]
		 */
		public function addPostComment(comment:NNDDComment):void{
			var command:Command = new Command();
			var commandPosition:int = command.getPosition(comment.mail);
			switch(commandPosition){
				case Command.UE:
					this.addUeComment(comment.vpos, comment.text, command.getSize(comment.mail), command.getColorByCommand(comment.mail), comment.no, comment.mail);
					break;
				case Command.SHITA:
					this.addShitaComment(comment.vpos, comment.text, command.getSize(comment.mail), command.getColorByCommand(comment.mail), comment.no, comment.mail);
					break;
				case Command.NAKA:
				default:
					this.addNomalComment(comment.vpos, comment.text, command.getSize(comment.mail), command.getColorByCommand(comment.mail), comment.no, comment.mail);
					break;
			}
		}
		
		
		/**
		 * 通常コメントを追加します。
		 * @param vpos
		 * @param comment
		 * @param size
		 * @param color
		 * @return 
		 * 
		 */
		private function addNomalComment(vpos:int, comment:String, size:int, color:int, no:Number, mail:String):void
		{
			for(var j:int = 0; j<commentNomalTextArray.length; j++){
				for(var i:int = 0; i<commentNomalTextArray[j].length; i++){
					if(commentNomalTextArray[j][i].vpos == -1){
						if((j == 0 && 
								((commentNomalTextArray[commentNomalTextArray.length-1][i].vpos == -1) 
									|| commentNomalTextArray[commentNomalTextArray.length-1][i].x + commentNomalTextArray[commentNomalTextArray.length-1][i].width 
										< commentNomalTextArray[commentNomalTextArray.length-1][i].parent.width/2))
								|| (j!=0 && commentNomalTextArray[j-1][i].x + commentNomalTextArray[j-1][i].width < commentNomalTextArray[j-1][i].parent.width/2)){
							
							commentNomalTextArray[j][i].text = comment;
							commentNomalTextArray[j][i].vpos = vpos;
							commentNomalTextArray[j][i].no = no;
							commentNomalTextArray[j][i].mail = mail;
							commentNomalTextArray[j][i].visible = true;
							commentNomalTextArray[j][i].setStyle("color", color);
							
							if(no<0){
								commentNomalTextArray[j][i].setStyle("textDecoration", "underline");
							}else{
								commentNomalTextArray[j][i].clearStyle("textDecoration");
							}
							
							switch(size){
								case Command.BIG:
									size = (commentNomalTextArray[j][i]).parent.height/15;
									break;
								case Command.SMALL:
									size = (commentNomalTextArray[j][i]).parent.height/25;
									break;
								case Command.MEDIUM:
									size = (commentNomalTextArray[j][i]).parent.height/20;
									break;
							}
							
							size = size*videoInfoView.commentScale;
							(commentNomalTextArray[j][i]).setStyle("fontSize", size);
							
							var filterArray:Array = new Array();
							if(color == int("0x000000")){
								filterArray.push(new DropShadowFilter(2, 45, int("0xffffff"), 1, 5, 5, 2));
							}else{
								filterArray.push(new DropShadowFilter(2, 45, 0, 1, 5, 5, 2));
							}
							
							(commentNomalTextArray[j][i]).filters = filterArray;
							
							if(!(commentNomalTextArray[j][i]).hasEventListener(MouseEvent.CLICK)){
								(commentNomalTextArray[j][i]).addEventListener(MouseEvent.CLICK, commentClickEventHandler);
							}
							
							(commentNomalTextArray[j][i]).alpha = 0;
							(commentNomalTextArray[j][i]).addEventListener(FlexEvent.UPDATE_COMPLETE, yCoordinateUpdateCompleteHandler);
							
							return;
						}
					}
				}
			}
		}
		
		
		/**
		 * テキストコンポーネントが表示される直前に、テキストコンポーネントがウィンドウからはみ出していないかどうかをチェックし、
		 * はみ出していればテキストコンポーネントを上に移動します。
		 * @param event
		 * 
		 */
		private function yCoordinateUpdateCompleteHandler(event:FlexEvent):void{
			(event.target as Text).alpha = this._commentAlpha;
			if(this.videoPlayer.canvas_video.getChildren().length > 0){
				
				var nowUnderY:int = (event.target as Text).height + (event.target as Text).y;
	
				var dist:int = 0;
				if(this.videoPlayer.canvas_video.getChildAt(0).height < nowUnderY){
					dist = nowUnderY - this.videoPlayer.canvas_video.getChildAt(0).height;
					var newY:int = (event.target as Text).y - dist;
					if(newY <= 0){
						newY = 0;
					}
					(event.target as Text).y = newY;
					
					if((event.target as Text).textHeight > this.videoPlayer.canvas_video.getChildAt(0).height ){
						
						var size:int = (event.target as Text).getStyle("fontSize")*0.9;
						(event.target as Text).setStyle("fontSize", size);
					}
					
				}else{
					
					(event.target as Text).removeEventListener(FlexEvent.UPDATE_COMPLETE, yCoordinateUpdateCompleteHandler);
	
				}
				
			}
			
		}
		
		/**
		 * 画面の上に表示するコメントを追加します。
		 * @param vpos
		 * @param comment
		 * @param size
		 * @param color
		 * 
		 */
		private function addUeComment(vpos:int, comment:String, size:int, color:int, no:Number, mail:String):void
		{
			for(var i:int = 0; i < commentUeTextArray.length; i++){
				if(commentUeTextArray[i].vpos == -1){
//					trace("コメント[" + comment + "](" + vpos + ")を追加");
					commentUeTextArray[i].text = comment;
					commentUeTextArray[i].vpos = vpos;
					commentUeTextArray[i].no = no;
					commentUeTextArray[i].mail = mail;
					commentUeTextArray[i].visible = true;
					commentUeTextArray[i].setStyle("color", color);
					
					//TODO コメント表示位置調整中
					if(i>0){
						(commentUeTextArray[i]).nnddText = (commentUeTextArray[i-1]);
						(commentUeTextArray[i]).pos = Command.UE;
//						var newY:int = (commentUeTextArray[i-1][1] as NNDDText).y + (commentUeTextArray[i-1][1] as NNDDText).textHeight;
//						(commentUeTextArray[i][1] as NNDDText).validateNow();
//						(commentUeTextArray[i][1] as NNDDText).y = (int)(newY + (commentUeTextArray[i][1] as NNDDText).textHeight);
					}
					
					if(no<0){
						commentUeTextArray[i].setStyle("textDecoration", "underline");
					}else{
						commentUeTextArray[i].clearStyle("textDecoration");
					}
					
					var fontSize:int = Command.MEDIUM;
					(commentUeTextArray[i] as NNDDText).size = size;
					switch(size){
						case Command.BIG:
							fontSize = (commentUeTextArray[i]).parent.height/15;
							break;
						case Command.SMALL:
							fontSize = (commentUeTextArray[i]).parent.height/25;
							break;
						case Command.MEDIUM:
							fontSize = (commentUeTextArray[i]).parent.height/20;
							break;
					}
					
					fontSize = fontSize*videoInfoView.commentScale;
					commentUeTextArray[i].setStyle("fontSize", fontSize);
					
					var filterArray:Array = new Array();
					if(color == int("0x000000")){
						filterArray.push(new DropShadowFilter(2, 45, int("0xffffff"), 1, 5, 5, 2));
					}else{
						filterArray.push(new DropShadowFilter(2, 45, 0, 1, 5, 5, 2));
					}
					(commentUeTextArray[i]).filters = filterArray;
					
					if(!(commentUeTextArray[i]).hasEventListener(MouseEvent.CLICK)){
						(commentUeTextArray[i]).addEventListener(MouseEvent.CLICK, commentClickEventHandler);
					}
					
					(commentUeTextArray[i]).alpha = 0;
					(commentUeTextArray[i]).addEventListener(FlexEvent.UPDATE_COMPLETE, fontSizeUpdateCompleteHandler);
					
					break;
				}
			}
		}
		
		/**
		 * 画面の下に表示するコメントを追加します。
		 * @param vpos
		 * @param comment
		 * @param size
		 * @param color
		 * 
		 */
		private function addShitaComment(vpos:int, comment:String, size:int, color:int, no:Number, mail:String):void
		{
			for(var i:int = 0; i < commentShitaTextArray.length; i++){
				if(commentShitaTextArray[i].vpos == -1){
					commentShitaTextArray[i].text = comment;
					commentShitaTextArray[i].vpos = vpos;
					commentShitaTextArray[i].no = no;
					commentShitaTextArray[i].mail = mail;
					commentShitaTextArray[i].visible = true;
					commentShitaTextArray[i].setStyle("color", color);
					
					//TODO コメント表示位置調整中
					if(i>0){
						(commentShitaTextArray[i]).nnddText = commentShitaTextArray[i-1];
						(commentShitaTextArray[i]).pos = Command.SHITA;
//						var newY:int = (commentShitaTextArray[i-1][1] as NNDDText).y;
//						(commentUeTextArray[i][1] as NNDDText).validateNow();
//						(commentShitaTextArray[i][1] as NNDDText).y = (int)(newY - (commentShitaTextArray[i][1] as NNDDText).textHeight);
					}
					
					if(no<0){
						commentShitaTextArray[i].setStyle("textDecoration", "underline");
					}else{
						commentShitaTextArray[i].clearStyle("textDecoration");
					}
					
					var fontSize:int = Command.MEDIUM;
					(commentShitaTextArray[i]).size = size;
					switch(size){
						case Command.BIG:
							fontSize = (commentShitaTextArray[i]).parent.height/15;
							break;
						case Command.SMALL:
							fontSize = (commentShitaTextArray[i]).parent.height/25;
							break;
						case Command.MEDIUM:
							fontSize = (commentShitaTextArray[i]).parent.height/20;
							break;
					}
					
					fontSize = fontSize*videoInfoView.commentScale;
					(commentShitaTextArray[i]).setStyle("fontSize", fontSize);
					
					var filterArray:Array = new Array();
					if(color == int("0x000000")){
						filterArray.push(new DropShadowFilter(2, 45, int("0xffffff"), 1, 5, 5, 2));
					}else{
						filterArray.push(new DropShadowFilter(2, 45, 0, 1, 5, 5, 2));
					}
					(commentShitaTextArray[i]).filters = filterArray;
					
					if((commentShitaTextArray[i]).hasEventListener(MouseEvent.CLICK)){
						(commentShitaTextArray[i]).removeEventListener(MouseEvent.CLICK, commentClickEventHandler);
					}
					(commentShitaTextArray[i]).addEventListener(MouseEvent.CLICK, commentClickEventHandler);
					
					(commentShitaTextArray[i]).alpha = 0;
					(commentShitaTextArray[i]).addEventListener(FlexEvent.UPDATE_COMPLETE, fontSizeUpdateCompleteHandler);

					break;
				}
			}
			
		}
		
		/**
		 * 表示コメントのソート関数です。<br />
		 * xがyより前に来る場合は1、yがxより後に来る場合は-1を返します。
		 * xとyが等しい場合は0を返します。
		 * @param x
		 * @param y
		 * @return 
		 * 
		 */
		private function compare(x:NNDDComment, y:NNDDComment):Number{
			if(x.vpos < y.vpos){
				return 1;
			}else if(x.vpos == y.vpos){
				return 0;
			}else{
				return -1;
			}
		}
		
		/**
		 * コメントがクリックされた際に呼ばれるメソッドです。
		 * 
		 * @param event
		 * 
		 */
		private function commentClickEventHandler(event:MouseEvent):void{
//			trace((event.currentTarget as Text).text);
			videoInfoView.selectComment((event.currentTarget as NNDDText).no);
			
			videoPlayer.videoController.commentPostView.textInput_comment.text = (event.currentTarget as NNDDText).text;
			videoPlayer.videoController.commentPostView.textinput_command.text = (event.currentTarget as NNDDText).mail;
			
			videoPlayer.videoController_under.commentPostView.textInput_comment.text = (event.currentTarget as NNDDText).text;
			videoPlayer.videoController_under.commentPostView.textinput_command.text = (event.currentTarget as NNDDText).mail;
		}
		
		/**
		 * テキストコンポーネントが表示される直前に、コンポーネントがウィンドウ内に収まっているかどうか確認し、収まっていなければフォントのサイズを小さくします。
		 * @param event
		 * 
		 */
		private function fontSizeUpdateCompleteHandler(event:FlexEvent):void{
			
			if((event.target as NNDDText).pos == Command.UE){
				var newY:int = (event.target as NNDDText).nnddText.y + (event.target as NNDDText).nnddText.textHeight;
				(event.target as NNDDText).y = (int)(newY + (event.target as NNDDText).textHeight);
			}else if((event.target as NNDDText).pos == Command.SHITA){
				var newY:int = (event.target as NNDDText).nnddText.y;
				(event.target as NNDDText).y = (int)(newY - (event.target as NNDDText).textHeight);
			}
			
			if(this.videoPlayer.canvas_video.getChildren().length > 0){
				if((event.target as Text).textHeight > this.videoPlayer.canvas_video.getChildAt(0).height ||
						 (event.target as Text).textWidth > this.videoPlayer.canvas_video.getChildAt(0).width){
					
					if((event.target as Text).y > 0){
						var nowUnderY:int = (event.target as Text).height + (event.target as Text).y;
						var dist:int = nowUnderY - this.videoPlayer.canvas_video.getChildAt(0).height;
						if(dist >= 0){
							var newY:int = (event.target as Text).y - dist;
							if(newY <= 0){
								newY = 0;
							}
							(event.target as Text).y = newY;
						}
					}
					
//					var dist:int = (event.target as Text).textHeight - (event.target as Text).parent.height;
//					if(dist > 0){
//						var newY:int = (-1)*(dist/2);
//						(event.target as NNDDText).y = newY;
//					}
					
					if((event.target as NNDDText).size != Command.BIG ){
						var size:int = (event.target as Text).getStyle("fontSize")*0.9;
						(event.target as Text).setStyle("fontSize", size);
						(event.target as Text).visible = false;
					}else{
						(event.target as Text).alpha = this._commentAlpha;
						(event.target as Text).removeEventListener(FlexEvent.UPDATE_COMPLETE, fontSizeUpdateCompleteHandler);
						(event.target as Text).setConstraintValue("horizontalCenter", 0);
						(event.target as Text).visible = true;
					}
					
				}else{
					(event.target as Text).alpha = this._commentAlpha;
					(event.target as Text).removeEventListener(FlexEvent.UPDATE_COMPLETE, fontSizeUpdateCompleteHandler);
					(event.target as Text).setConstraintValue("horizontalCenter", 0);
					(event.target as Text).visible = true;
				}
			}
		}
		
		
		/**
		 * 表示可能時間を経過したコメント表示用のTextコンポーネントからテキストを削除します。
		 * ノーマルコメント表示用のTextコンポーネントは右端の画面外に移動します。
		 * @param nowvpos 現在の時刻(vpos)
		 * @param showInterval 表示可能時間(vpos)
		 * 
		 */
		public function removeComment(nowvpos:int, showInterval:int):void
		{
			var i:int = 0;
			var index:int = 0;
			var col:int = 1;
			
			for(var j:int = 0; j<commentNomalTextArray.length; j++){
				for(i = 0; i<commentNomalTextArray[j].length; i++){
					if(commentNomalTextArray[j][i].vpos != -1 && (commentNomalTextArray[j][i].x + commentNomalTextArray[j][i].width) < 0 ){
						commentNomalTextArray[j][i].vpos = -1;
						commentNomalTextArray[j][i].text = "";
						commentNomalTextArray[j][i].no = 0;
						commentNomalTextArray[j][i].visible = false;
						commentNomalTextArray[j][i].x = videoPlayer.canvas_video.width;
						commentNomalTextArray[j][i].y = ((commentNomalTextArray[j][i] as Text).parent.height/12)*i;
					}
				}
			}
			
			for(i = 0; i<commentShitaTextArray.length; i++){
				if(commentShitaTextArray[i].vpos != -1 && commentShitaTextArray[i].vpos*10 < nowvpos - showInterval){
					commentShitaTextArray[i].vpos = -1;
					commentShitaTextArray[i].text = "";
					commentShitaTextArray[i].no = 0;
					commentShitaTextArray[i].visible = false;
					commentShitaTextArray[i].x = videoPlayer.canvas_video.width;
					commentShitaTextArray[i].y = videoPlayer.canvas_video.height - (videoPlayer.canvas_video.height/12)*(i+2);
				}
			}
			
			for(i = 0; i<commentUeTextArray.length; i++){
				if(commentUeTextArray[i].vpos != -1 && commentUeTextArray[i].vpos*10 < nowvpos - showInterval){
					commentUeTextArray[i].vpos = -1;
					commentUeTextArray[i].text = "";
					commentUeTextArray[i].no = 0;
					commentUeTextArray[i].visible = false;
					commentUeTextArray[i].x = videoPlayer.canvas_video.width;
					commentUeTextArray[i].y = (videoPlayer.canvas_video.height/12)*i;
				}
			}
			
		}
		
		/**
		 * 引数で渡されたDisplayObjectContainerオブジェクトにコメント用のTextControlを追加します。<br>
		 * @param displayObjectContainer
		 * 
		 */
		private function addText(displayObjectContainer:DisplayObjectContainer):void
		{
			var commentText:NNDDText = new NNDDText();
			
			for(var l:int = 0; l<commentNomalTextArray.length; l++){
				for(var i:int = 0; i<commentNomalTextArray[l].length; i++){
					
					commentText = new NNDDText();
					
					commentText.setStyle("color", 0x000000);
					commentText.setStyle("fontSize", displayObjectContainer.height/20);
//					commentText.setStyle("fontAntiAliasType", flash.text.AntiAliasType.ADVANCED);
					if(_isCommentBold){
						commentText.setStyle("fontWeight", "bold");
					}else{
						commentText.setStyle("fontWeight", "nomal");
					}
					commentText.filters.push(new DropShadowFilter(10,45));
					
					commentNomalTextArray[l][i] = commentText;
					
					displayObjectContainer.addChild(commentNomalTextArray[l][i]);
					
					commentNomalTextArray[l][i].text = "";
					commentNomalTextArray[l][i].x = displayObjectContainer.width;
					commentNomalTextArray[l][i].y = (this.videoPlayer.canvas_video.height/15)*(i);
					
				}
			}
			
			for(var j:int = 0; j<commentShitaTextArray.length; j++){
				
				commentText = new NNDDText();
				
				commentText.setStyle("color", 0xffffff);
				commentText.setStyle("fontSize", displayObjectContainer.height/20);
//				commentText.setStyle("fontAntiAliasType", flash.text.AntiAliasType.ADVANCED);
				if(_isCommentBold){
					commentText.setStyle("fontWeight", "bold");
				}else{
					commentText.setStyle("fontWeight", "nomal");
				}
				commentText.filters.push(new DropShadowFilter(10,45));
				
				commentShitaTextArray[j] = commentText;
				
				displayObjectContainer.addChild(commentShitaTextArray[j]);
				
				commentShitaTextArray[j].text = "";
				commentShitaTextArray[j].x = displayObjectContainer.width;
				commentShitaTextArray[j].y = displayObjectContainer.height - (displayObjectContainer.height/15)*(j+2);
				
			}
			
			for(var k:int = 0; k<commentUeTextArray.length; k++){
				
				commentText = new NNDDText();
				
				commentText.setStyle("color", 0xffffff);
				commentText.setStyle("fontSize", displayObjectContainer.height/20);
//				commentText.setStyle("fontAntiAliasType", flash.text.AntiAliasType.ADVANCED);
				if(_isCommentBold){
					commentText.setStyle("fontWeight", "bold");
				}else{
					commentText.setStyle("fontWeight", "nomal");
				}
				commentText.filters.push(new DropShadowFilter(10,45));
				
				commentUeTextArray[k] = commentText;
				
				displayObjectContainer.addChild(commentUeTextArray[k]);
				
				commentUeTextArray[k].text = "";
				commentUeTextArray[k].x = displayObjectContainer.width;
				commentUeTextArray[k].y = (displayObjectContainer.height/15)*i;
				
			}
			
		}
		
		/**
		 * 全てのコメントの位置を再計算し、配置し直します。
		 * 
		 */
		public function validateCommentPosition():void{
			
			var i:int = 0;
			if(commentNomalTextArray != null){
				for(var j:int = 0; j<commentNomalTextArray.length; j++){
					for(i = 0; i<commentNomalTextArray[j].length; i++){
						if(commentNomalTextArray[j][i] != null){
							
							var fontSize:int = 0;
							var command:int = (commentNomalTextArray[j][i]).size;
							if((commentNomalTextArray[j][i]).parent != null){
								switch(command){
									case Command.BIG:
										fontSize = (commentNomalTextArray[j][i]).parent.height/15;
										break;
									case Command.SMALL:
										fontSize = (commentNomalTextArray[j][i]).parent.height/25;
										break;
									case Command.MEDIUM:
										fontSize = (commentNomalTextArray[j][i]).parent.height/20;
										break;
								}
								fontSize = fontSize*videoInfoView.commentScale;
								commentNomalTextArray[j][i].setStyle("fontSize", fontSize);
							}
							
							if(!commentNomalTextArray[j][i].visible || commentNomalTextArray[j][i].text == ""){
								commentNomalTextArray[j][i].x = this.videoPlayer.canvas_video.width;
							}
							commentNomalTextArray[j][i].y = (this.videoPlayer.canvas_video.height/15)*(i);
						}
					}
				}
			}
			
			if(commentShitaTextArray != null){
				for(i = 0; i<commentShitaTextArray.length; i++){
					if(commentShitaTextArray[i] != null){
						
						var fontSize:int = 0;
						var command:int = (commentShitaTextArray[i]).size;
						if((commentShitaTextArray[i]).parent != null){
							switch(command){
								case Command.BIG:
									fontSize = (commentShitaTextArray[i]).parent.height/15;
									break;
								case Command.SMALL:
									fontSize = (commentShitaTextArray[i]).parent.height/25;
									break;
								case Command.MEDIUM:
									fontSize = (commentShitaTextArray[i]).parent.height/20;
									break;
							}
							fontSize = fontSize*videoInfoView.commentScale;
							commentShitaTextArray[i].setStyle("fontSize", fontSize);
						}
						
						commentShitaTextArray[i].x = this.videoPlayer.canvas_video.width;
						commentShitaTextArray[i].y = this.videoPlayer.canvas_video.height - (this.videoPlayer.canvas_video.height/15)*(i+2);
					}
				}
			}
			
			if(commentUeTextArray != null){
				for(i = 0; i<commentUeTextArray.length; i++){
					if(commentUeTextArray[i] != null){
						
						var fontSize:int = 0;
						var command:int = (commentUeTextArray[i]).size;
						if((commentUeTextArray[i]).parent != null){
							switch(command){
								case Command.BIG:
									fontSize = (commentUeTextArray[i]).parent.height/15;
									break;
								case Command.SMALL:
									fontSize = (commentUeTextArray[i]).parent.height/25;
									break;
								case Command.MEDIUM:
									fontSize = (commentUeTextArray[i]).parent.height/20;
									break;
							}
							fontSize = fontSize*videoInfoView.commentScale;
							commentUeTextArray[i].setStyle("fontSize", fontSize);
						}
						
						commentUeTextArray[i].x = this.videoPlayer.canvas_video.width;
						commentUeTextArray[i].y = (this.videoPlayer.canvas_video.height/15)*(i);
					}
				}
			}
			
		}
		
		
		/**
		 * すべてのコメントに空の文字列を代入し、右の画面外に移動させます。
		 * 上コメントと下コメントの場所はそのままです。
		 * 
		 */
		public function removeAll():void
		{
			var i:int = 0;
			if(commentNomalTextArray != null){
				for(var j:int = 0; j<commentNomalTextArray.length; j++){
					for(i = 0; i<commentNomalTextArray[j].length; i++){
						if(commentNomalTextArray[j][i] != null){
							commentNomalTextArray[j][i].vpos = -1;
							commentNomalTextArray[j][i].text = "";
							commentNomalTextArray[j][i].no = 0;
							commentNomalTextArray[j][i].visible = false;
							commentNomalTextArray[j][i].x = this.videoPlayer.canvas_video.width;
							commentNomalTextArray[j][i].y = (this.videoPlayer.canvas_video.height/15)*(i);
						}
					}
				}
			}
			
			if(commentShitaTextArray != null){
				for(i = 0; i<commentShitaTextArray.length; i++){
					if(commentShitaTextArray[i] != null){
						commentShitaTextArray[i].vpos = -1;
						commentShitaTextArray[i].text = "";
						commentShitaTextArray[i].no = 0;
						commentShitaTextArray[i].visible = false;
						commentShitaTextArray[i].x = this.videoPlayer.canvas_video.width;
						commentShitaTextArray[i].y = this.videoPlayer.canvas_video.height - (this.videoPlayer.canvas_video.height/15)*(i+2);
					}
				}
			}
			
			if(commentUeTextArray != null){
				for(i = 0; i<commentUeTextArray.length; i++){
					if(commentUeTextArray[i] != null){
						commentUeTextArray[i].vpos = -1;
						commentUeTextArray[i].text = "";
						commentUeTextArray[i].no = 0;
						commentUeTextArray[i].visible = false;
						commentUeTextArray[i].x = this.videoPlayer.canvas_video.width;
						commentUeTextArray[i].y = (this.videoPlayer.canvas_video.height/15)*(i);
					}
				}
			}
		}
		
		/**
		 * 
		 * @param commentAlpha
		 * 
		 */
		public function setCommentAlpha(commentAlpha:Number):void{
			
			this._commentAlpha = commentAlpha;
			
			var i:int = 0;
			for(var j:int = 0; j<commentNomalTextArray.length; j++){
				for(i = 0; i<commentNomalTextArray[j].length; i++){
					if(commentNomalTextArray[j][i] != null){
						commentNomalTextArray[j][i].alpha = this._commentAlpha;
					}
				}
			}
			for(i = 0; i<commentShitaTextArray.length; i++){
				if(commentShitaTextArray[i] != null){
					commentShitaTextArray[i].alpha = this._commentAlpha;
				}
			}
			for(i = 0; i<commentUeTextArray.length; i++){
				if(commentUeTextArray[i] != null){
					commentUeTextArray[i].alpha = this._commentAlpha;
				}
			}
			
		}
		
		/**
		 * 表示コメントの太字を切り替えます。
		 * @param isCommentBold
		 * 
		 */
		public function setCommentBold(isCommentBold:Boolean):void{
			
			this._isCommentBold = isCommentBold;
			
			try{
				
				var i:int = 0;
				for(var j:int = 0; j<commentNomalTextArray.length; j++){
					for(i = 0; i<commentNomalTextArray[j].length; i++){
						if(isCommentBold){
							(commentNomalTextArray[j][i]).setStyle("fontWeight", "bold");
						}else{
							(commentNomalTextArray[j][i]).setStyle("fontWeight", "nomal");
						}
					}
				}
				for(i = 0; i<commentShitaTextArray.length; i++){
					if(isCommentBold){
						(commentShitaTextArray[i]).setStyle("fontWeight", "bold");
					}else{
						(commentShitaTextArray[i]).setStyle("fontWeight", "nomal");
					}
				}
				for(i = 0; i<commentUeTextArray.length; i++){
					if(isCommentBold){
						(commentUeTextArray[i]).setStyle("fontWeight", "bold");
					}else{
						(commentUeTextArray[i]).setStyle("fontWeight", "nomal");
					}
				}
			
			}catch(error:Error){
				trace("まだ準備が終わってない(setBold):"+error.getStackTrace());
			}
		}
		
		/**
		 * テキストの可視性を設定します
		 * 
		 * @param isVisible
		 * 
		 */
		public function setCommentVisible(isVisible:Boolean):void{
			try{
				var i:int = 0;
				for(var j:int = 0; j<commentNomalTextArray.length; j++){
					for(i = 0; i<commentNomalTextArray[j].length; i++){
						(commentNomalTextArray[j][i] as NNDDText).visible = isVisible;
					}
				}
				for(i = 0; i<commentShitaTextArray.length; i++){
					(commentShitaTextArray[i] as NNDDText).visible = isVisible;
				}
				for(i = 0; i<commentUeTextArray.length; i++){
					(commentUeTextArray[i] as NNDDText).visible = isVisible;
				}
			}catch(error:Error){
				trace("まだ準備が終わっていない(isVisible):" + error.getStackTrace());
			}
		}
		
		
		/**
		 * 
		 * @param isAntiAliasEnable
		 * 
		 */
		public function setAntiAlias(isAntiAliasEnable:Boolean):void{
//			this._isAntiAliasEnable = isAntiAliasEnable;
//			var i:int = 0;
//			var j:int = 0;
//			if(isAntiAliasEnable){
//				for(j = 0; j<commentNomalTextArray.length; j++){
//					for(i = 0; i<commentNomalTextArray[j].length; i++){
//						(commentNomalTextArray[j][i][1] as NNDDText).setStyle("fontSharpness", 400);
//					}
//				}
//				for(i = 0; i<commentShitaTextArray.length; i++){
//					(commentShitaTextArray[i][1] as NNDDText).setStyle("fontSharpness", 400);
//				}
//				for(i = 0; i<commentUeTextArray.length; i++){
//					(commentUeTextArray[i][1] as NNDDText).setStyle("fontSharpness", 400);
//				}
//			}else{
//				for(j = 0; j<commentNomalTextArray.length; j++){
//					for(i = 0; i<commentNomalTextArray[j].length; i++){
//						(commentNomalTextArray[j][i][1] as NNDDText).setStyle("fontSharpness", -400);
//					}
//				}
//				for(i = 0; i<commentShitaTextArray.length; i++){
//					(commentShitaTextArray[i][1] as NNDDText).setStyle("fontSharpness", -400);
//				}
//				for(i = 0; i<commentUeTextArray.length; i++){
//					(commentUeTextArray[i][1] as NNDDText).setStyle("fontSharpness", -400);
//				}
//			}
		}
		
	}
}