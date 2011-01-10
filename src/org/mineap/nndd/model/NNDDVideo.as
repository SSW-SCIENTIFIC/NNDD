package org.mineap.nndd.model
{
	import flash.filesystem.File;
	
	import org.mineap.nndd.util.LibraryUtil;
	import org.mineap.nndd.util.PathMaker;

	/**
	 * NNDDVideo.as<br>
	 * NNDDVideoクラスは、NNDDが管理する動画についての情報を格納するクラスです。<br>
	 * <br>
	 * Copyright (c) 2009 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */	
	public class NNDDVideo
	{
		
		private var _id:Number = -1;
		
		/** 動画の場所を示すURIです。 */
		private var _uri:String = "";
		
		/** 動画の名前です。 */
		public var videoName:String = "";
		
		/** この動画がエコノミーモードで保存されたかどうかを表します。 */
		public var isEconomy:Boolean = false;
		
		/** この動画に設定されたタグです。 */
		public var tagStrings:Vector.<String> = new Vector.<String>();
		
		/** この動画が最後に更新された日時です。これはコメントの更新等で変更されます。 */
		public var modificationDate:Date = new Date();
		
		/** この動画がダウンロードされた日です。 */
		public var creationDate:Date = new Date();
		
		/** この動画のローカルのサムネイル画像のURLです */
		public var thumbUrl:String = "";
		
		/** この動画のトータル再生回数です */
		public var playCount:Number = 0;
		
		/** この動画の長さ（秒）です。 */
		public var time:Number = 0;
		
		/** この動画が最後に再生された日時です。この値はnullである可能性があります。 */
		public var lastPlayDate:Date = null;
		
		/** この動画が既読かどうかです。既読の場合はtrueです。これはマイリスト管理に使用されます。 */
		public var yetReading:Boolean = false;
		
		/** この動画が投稿された日付です。この値はnullである可能性があります。 */
		public var pubDate:Date = null;
		
		/**
		 * 
		 * コンストラクタ
		 * 
		 * @param uri 
		 * @param videoName
		 * @param isEconomy
		 * @param tags
		 * @param modificationDate
		 * @param creationDate
		 * @param thumbUrl
		 * @param playCount
		 * @param time
		 * @param lastPlayDate
		 * @param pubDate
		 * 
		 */
		public function NNDDVideo(uri:String , videoName:String = null, isEconomy:Boolean = false, tags:Vector.<String> = null,
				 modificationDate:Date = null, creationDate:Date = null, thumbUrl:String = null, playCount:Number = 0, time:Number = 0,
				 lastPlayDate:Date = null, pubDate:Date = null)
		{
			if(uri.indexOf("%") == -1){
				this._uri = encodeURI(uri);
			}else{
				this._uri = uri;
			}
			if(videoName == null){
				this.videoName = decodeURIComponent(PathMaker.getVideoName(this._uri));
			}else{
				this.videoName = videoName;
			}
			this.isEconomy = isEconomy;
			if(tags != null){
				this.tagStrings = tags;
			}
			if(modificationDate != null){
				this.modificationDate = modificationDate;
			}
			if(creationDate != null){
				this.creationDate = creationDate;
			}
			if(thumbUrl != null){
				this.thumbUrl = thumbUrl;
			}
			if(playCount != 0){
				this.playCount = playCount;
			}
			if(time != 0){
				this.time = time;
			}
			if(lastPlayDate != null){
				this.lastPlayDate = lastPlayDate;
			}
			if(pubDate != null){
				this.pubDate = pubDate;
			}
		}
		
		/**
		 * 
		 * @param uri
		 * 
		 */
		public function set uri(uri:String):void{
			
			this._uri = uri;
			this.videoName = decodeURIComponent(PathMaker.getVideoName(uri));
			
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get uri():String{
			return this._uri;
		}
		
		/**
		 * デコードされたURLを返します。
		 * @return 
		 * 
		 */
		public function getDecodeUrl():String{
			var url:String = decodeURIComponent(this._uri);
			return url;
		}
		
		/**
		 * この動画が存在するディレクトリを返します。
		 * この動画がローカルファイルシステム上に存在しない場合はnullを返します。
		 * @return 
		 * 
		 */
		public function get dir():File{
			var url:String = getDecodeUrl();
			var file:File = null;
			
			try{
				file = new File(url);
				
				if(file.isDirectory){
					//ディレクトリならそのまま
				}else{
					// ファイルなら親ディレクトリを返す
					file = file.parent;
				}
				
			}catch(error:Error){
				return null;
			}
			
			return file;
		}
		
		/**
		 * 動画IDを含む動画のタイトルを返します。
		 * @return 
		 * 
		 */
		public function getVideoNameWithVideoID():String{
			var videoTitle:String = this.videoName;
			
			// videoのタイトルに拡張子が含まれるかどうか調べる
			var extension:String = videoTitle.substring(-3);
			if(extension != null){
				extension = extension.toUpperCase();
				
				if(extension == VideoType.FLV_L || extension == VideoType.MP4_L || extension == VideoType.SWF_L){
					
					//含まれていれば取り除く
					var index:int = videoTitle.lastIndexOf(".");
					if(index != -1){
						videoTitle = videoTitle.substr(0, index);
					}
				}
			}
			
			var videoId:String = PathMaker.getVideoID(this.getDecodeUrl());
			if(videoId != null){
				// videoIdが含まれていなければ付加する
				if(videoTitle.indexOf(videoId) == -1){
					videoTitle = videoTitle + " - [" + videoId + "]";
				}
			}
			return videoTitle;
		}
		
		/**
		 * 
		 * @return 
		 * 
		 */
		public function get key():String{
			return LibraryUtil.getVideoKey(this.getDecodeUrl());
		}
		
		/**
		 * この動画の場所を表現するFileオブジェクトを返します。
		 * この動画がローカルに存在しない場合はnullを返します。
		 * @return 
		 * 
		 */
		public function get file():File{
			var file:File = null;
			try{
				file = new File(this.uri);
			}catch(error:Error){
				file = null;
			}
			return file;
		}

		/** SQLiteを用いて永続化する場合に付加されるインデックスです */
		public function get id():Number
		{
			return _id;
		}

		/**
		 * @private
		 */
		public function set id(value:Number):void
		{
			_id = value;
		}

		
	}
}