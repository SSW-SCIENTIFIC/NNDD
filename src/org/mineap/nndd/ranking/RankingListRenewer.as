package org.mineap.nndd.ranking
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import org.mineap.nndd.util.NicoPattern;
	import org.mineap.nndd.util.PathMaker;
	import org.mineap.nicovideo4as.RankingPatterns;
	import org.mineap.nicovideo4as.ThumbInfoLoader;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.Message;
	
	public class RankingListRenewer
	{
		
		private var _logManager:LogManager;
		private var _libraryManager:LibraryManager;
		private var _arrayCollection:ArrayCollection;
		
		/**
		 * 
		 * @param logManager
		 * @param libraryManager
		 * 
		 */
		public function RankingListRenewer(logManager:LogManager, libraryManager:LibraryManager)
		{
			this._libraryManager = libraryManager;
			this._logManager = logManager;
		}
		
		/**
		 * 
		 * @param html
		 * @param rankingPatterns
		 * @param pageIndex
		 * @param dataProvider
		 * 
		 */
		public function renewRankingList(html:String, rankingPatterns:RankingPatterns, pageIndex:int, dataProvider:ArrayCollection):void{
			
			this._arrayCollection = dataProvider;
			
			var pattern_thumbImg:RegExp = NicoPattern.rankingThumbImgPattern;
			var pattern_video:RegExp = NicoPattern.rankingVideoPattern
			
			var videoArray:Array = pattern_video.exec(html);
			var thumbImgArray:Array = pattern_thumbImg.exec(html);
			
			var rankingList:Array = new Array();
			
			while(videoArray != null && thumbImgArray != null){
				rankingList.push(new Array("http://www.nicovideo.jp/" + videoArray[1], thumbImgArray[1], videoArray[2]));
				videoArray = pattern_video.exec(html);
				thumbImgArray = pattern_thumbImg.exec(html);
			}
			
			var changeNicoGUI:Boolean = false;
			
			if(rankingList == null || rankingList.length == 0){
				changeNicoGUI = true;
			}
			
			var date:Date = new Date();
			var temp:Number = date.getTime();
			
			//ライブラリのMapを更新
			this._libraryManager.renewLibraryMap();

			for(var i:int = 0; i<rankingList.length; i++)
			{
				var errorString:String;
				try{
					
					var index:int = i+1;
					var video:NNDDVideo = (this._libraryManager.isExistsOnMap(PathMaker.getVideoID(rankingList[i][0])));
					
					var localURL:String = "";
					var videoCondition:String = "";
					if(video != null){
						localURL = video.getDecodeUrl();
						if(video.isEconomy){
							videoCondition = "動画(低画質)保存済\n右クリックから再生できます。"
						}else{
							videoCondition = "動画保存済\n右クリックから再生できます。";
						}
					}
					
					var videoName:String = PathMaker.getSpecialCharacterNotIncludedVideoName(rankingList[i][2])+"\n" + rankingList[i][0];
					
					this._arrayCollection.addItem({
						dataGridColumn_preview: rankingList[i][1],
						dataGridColumn_ranking: index+((pageIndex-1)*100),
						dataGridColumn_videoName: videoName,
						dataGridColumn_condition: videoCondition,
						dataGridColumn_videoPath: localURL,
						dataGridColumn_nicoVideoUrl: rankingList[i][0]
					});
					
					this.renewThumbInfo(PathMaker.getVideoID(rankingList[i][0]), i, videoName);
					
				}catch(error:Error){
					this._logManager.addLog("ランキングページの解析に失敗しました。:" + i + "個目の解析\n" + error + ":" + error.getStackTrace());
					changeNicoGUI = true;
				}
			}
			
			if(changeNicoGUI){
				this._logManager.addLog("ニコニコ動画の仕様が変わっている可能性があります。\n検索結果が正しく取得できていない可能性があります。");
				Alert.show("ニコニコ動画の仕様が変わっている可能性があります。\n検索結果が正しく取得できていない可能性があります。", "警告");
			}
			
		}
		
		/**
		 * カテゴリ一覧を、それに対応するurlの末尾も文字列(all,music,ent など)を含む２次元配列を返します。
		 * 
		 * <pre>
		 * Array(){
		 * 	Array("総合","all");
		 * 	Array("音楽","music");
		 * 	...
		 * }
		 * </pre>
		 * 
		 * @param urlLoader
		 * @param pattern
		 * @return 
		 * 
		 */
		public function getCategoryList(html:String, pattern:RegExp):Array{
			
			var catList:Array = new Array();
			
			var category:Array = pattern.exec(html);
			while(category != null){
				catList.push(new Array(category[1], category[2]));
				category = pattern.exec(html);
			}
			
			return catList;
		}
		
		
		/**
		 * 
		 * @param videoId
		 * @param index
		 * @param videoName
		 * 
		 */
		private function renewThumbInfo(videoId:String, index:int, videoName:String):void{
			var thumbInfoLoader:ThumbInfoLoader = new ThumbInfoLoader();
			thumbInfoLoader.addEventListener(Event.COMPLETE, function(event:Event):void{
				var thumbInfoXML:XML = new XML(event.currentTarget.data);
				var status:String = Message.L_VIDEO_DELETED;
				
				if(thumbInfoXML.attribute("status") == "ok"){
					status = "再生:" + thumbInfoXML.thumb.view_counter +
						",コメント:" + thumbInfoXML.thumb.comment_num +
						"\nマイリスト:" + thumbInfoXML.thumb.mylist_counter +
						"\n" + thumbInfoXML.thumb.last_res_body;
						
				}else{
					//status!="ok"。削除されている。
					status = Message.L_VIDEO_DELETED;
				}
				
				if(index != -1){
					if(videoName != null && _arrayCollection.length > index && videoName == _arrayCollection[index].dataGridColumn_videoName){
						_arrayCollection.setItemAt({
							dataGridColumn_ranking: _arrayCollection[index].dataGridColumn_ranking,
							dataGridColumn_preview: _arrayCollection[index].dataGridColumn_preview,
							dataGridColumn_videoName: _arrayCollection[index].dataGridColumn_videoName,
							dataGridColumn_Info: _arrayCollection[index].dataGridColumn_Info,
							dataGridColumn_videoInfo: status,
							dataGridColumn_condition: _arrayCollection[index].dataGridColumn_condition,
							dataGridColumn_videoPath: _arrayCollection[index].dataGridColumn_videoPath,
							dataGridColumn_nicoVideoUrl: _arrayCollection[index].dataGridColumn_nicoVideoUrl
						}, index);
					}
				}
				thumbInfoLoader.close();
				thumbInfoLoader = null;
			});
			thumbInfoLoader.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void{
				if(index != -1){
					if(videoName != null && videoName == _arrayCollection[index].dataGridColumn_videoName){
						_arrayCollection.setItemAt({
							dataGridColumn_ranking: _arrayCollection[index].dataGridColumn_ranking,
							dataGridColumn_preview: _arrayCollection[index].dataGridColumn_preview,
							dataGridColumn_videoName: _arrayCollection[index].dataGridColumn_videoName,
							dataGridColumn_Info: _arrayCollection[index].dataGridColumn_Info,
							dataGridColumn_videoInfo: "サムネイル情報の取得に失敗。",
							dataGridColumn_condition: _arrayCollection[index].dataGridColumn_condition,
							dataGridColumn_videoPath: _arrayCollection[index].dataGridColumn_videoPath,
							dataGridColumn_nicoVideoUrl: _arrayCollection[index].dataGridColumn_nicoVideoUrl
						}, index);
					}
					_arrayCollection.refresh();
				}
				thumbInfoLoader.close();
				thumbInfoLoader = null;
			});
			thumbInfoLoader.getThumbInfo(videoId);
		}
		

	}
}