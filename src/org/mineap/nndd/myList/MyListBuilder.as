package org.mineap.nndd.myList
{
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nndd.library.ILibraryManager;
	import org.mineap.nndd.library.LibraryManagerBuilder;
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.util.NicoPattern;
	import org.mineap.nndd.util.PathMaker;
	import org.mineap.nicovideo4as.util.HtmlUtil;
	


	/**
	 * 
	 * @author shiraminekeisuke
	 * 
	 */
	public class MyListBuilder
	{
		private var _logManger:LogManager;
		private var _libraryManager:ILibraryManager;
		private var _title:String = "";
		private var _description:String = "";
		private var _creator:String = "";
		
		/**
		 * 
		 * @param logManager
		 * 
		 */
		public function MyListBuilder()
		{
			this._logManger = LogManager.instance;
			this._libraryManager = LibraryManagerBuilder.instance.libraryManager;
		}
		
		/**
		 * 渡されたマイリストのRSS(XML)から、表示用のArrayCollectionを生成します。
		 * @param xml
		 * @return 
		 * 
		 */
		public function getMyListArrayCollection(xml:XML, onlyUnPlay:Boolean = false):ArrayCollection{
			
			/*
				<channel>
				<rss>
			 	<item>
			      <title>東方VocalSelection “千歳の夢を遠く過ぎても” [原曲 プレインエイジア]</title>
			      <link>http://www.nicovideo.jp/watch/sm4508441</link>
			      <guid isPermaLink="false">tag:nicovideo.jp,2008-09-03:/watch/1220438142</guid>
			      <pubDate>Fri, 24 Apr 2009 22:51:06 +0900</pubDate>
			      <description><![CDATA[
			      <p class="nico-memo"># tr.42</p>
			      <p class="nico-thumbnail"><img alt="東方VocalSelection “千歳の夢を遠く過ぎても” [原曲 プレインエイジア]" src="http://tn-skr2.smilevideo.jp/smile?i=4508441" width="94" height="70" border="0"/></p>
			      <p class="nico-description">夜が明けたら、君のところへ――　　　Circle：IOSYS　　　Album：東方想幽森雛　　　Vocal：あさ��　　　Original：プレインエイジア　　　Blazing：mylist/7121837　　　Twilight：mylist/8446649　　　最後まで再生すると次の動画にジャンプします　　　■想幽森雛収録のRemixシリーズはもっと評価されるべきだと思います。</p>
			      <p class="nico-info"><small><strong class="nico-info-length">5:39</strong>｜<strong class="nico-info-date">2008年09月03日 19：35：42</strong> 投稿</small></p>
			      ]]></description>
			    </item>
			    </channel>
				</rss>
			 */ 
			
			var arrayCollection:ArrayCollection = new ArrayCollection();
			var index:int = 1;
			
			var links:XMLList = xml.channel.link;
			var myListId:String = null;
			for each(var link:XML in links){
				myListId = link.text();
				if(myListId != null){
					var lastIndex:int = myListId.lastIndexOf("/");
					if(lastIndex != -1){
						myListId = myListId.substr(lastIndex);
					}
				}
			}
			
			var videoArray:Vector.<NNDDVideo> = null;
			var videoMap:Object = new Object();
			if(myListId != null){
				videoArray = MyListManager.instance.readLocalMyListByNNDDVideo(myListId);
				for each(var nnddVideo:NNDDVideo in videoArray){
					var id:String = PathMaker.getVideoID(nnddVideo.getVideoNameWithVideoID());
					videoMap[id] = nnddVideo;
				}
			}
			
			for each(var temp:XML in xml.channel.children()){
				if(temp.name() == "title"){
					this._title = temp.text();
				}else if(temp.name() == "description"){
					this._description = temp.text();
				}else if(temp.name() == "http://purl.org/dc/elements/1.1/::creator"){
					this._creator = temp.text();
				}else if(temp.name() == "item"){
					
					var condition:String = "";
					var videoUrl:String = temp.link.text();
					
					var videoId:String = PathMaker.getVideoID(temp.link.text());
					var video:NNDDVideo = this._libraryManager.isExist(videoId);
					var played:Boolean = false;
					var videoLocalPath:String = "";
					if(video != null){
						condition = "動画保存済\n右クリックから再生できます。";
						videoLocalPath = video.getDecodeUrl();
					}
					
					if(videoArray != null){
						var str:String = "";
						var tempVideo:NNDDVideo = videoMap[videoId];
						if(tempVideo != null && tempVideo.yetReading || video != null){
//							str = "既読";
							played = true;
							
							if(onlyUnPlay){
								//未視聴のみ指定の場合は次の項目へ
								continue;
							}
						}else{
							str = "未視聴";
							played = false;
						}
						
						if(condition != null && condition.length > 0){
							condition += "\n";
						}
						condition += str;
					}
					
					var thumbUrl:String = "";
					var array:Array = NicoPattern.myListThumbImgUrlPattern.exec(temp.description.text());
					if(array != null && array.length >= 1){
						thumbUrl = array[1];
					}
					
					var info:String = "";
					array = null;
					array = NicoPattern.myListMemoPattern.exec(temp.description.text());
					if(array != null && array.length >= 1){
						info = array[1];
						try{
							info = decodeURIComponent(info);
							info = HtmlUtil.convertSpecialCharacterNotIncludedString(info);
						}catch(error:Error){
							trace(error);
						}
						
					}
					
					var length:String = "";
					array = null;
					array = NicoPattern.myListLength.exec(temp.description.text());
					if(array != null && array.length >= 1){
						length = "    再生時間 " + array[1];
					}
					
					var date:String = "";
					array = null;
					array = NicoPattern.myListInfoDate.exec(temp.description.text());
					if(array != null && array.length >= 1){
						date = "    投稿日時 " + array[1];
					}
					
					var title:String = temp.title;
					try{
						title = decodeURIComponent(title);
						title = HtmlUtil.convertSpecialCharacterNotIncludedString(title);
					}catch(error:Error){
						trace(error);
					}
					
					arrayCollection.addItem({
						dataGridColumn_index:index++,
						dataGridColumn_preview:thumbUrl,
						dataGridColumn_videoName:title + "\n" + length + "\n" + date,
						dataGridColumn_videoInfo:info,
						dataGridColumn_condition:condition,
						dataGridColumn_videoUrl:videoUrl,
						dataGridColumn_videoLocalPath:videoLocalPath,
						dataGridColumn_played:played,
						dataGridColumn_videoId:videoId,
						dataGridColumn_myListId:myListId
					});
					
				}
				
			}
			
			return arrayCollection;
		}
		
		public function get title():String{
			return this._title;
		}
		
		public function get description():String{
			return this._description;
		}
		
		public function get creator():String{
			return this._creator;
		}

	}
}