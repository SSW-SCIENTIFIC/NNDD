package org.mineap.nndd.library.namedarray
{
	import flash.utils.escapeMultiByte;
	import flash.utils.unescapeMultiByte;
	
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.util.LibraryUtil;
	import org.mineap.nndd.util.PathMaker;
	
	public class LibraryXMLHelper
	{
		public function LibraryXMLHelper()
		{
		}
		
		/**
		 * 渡されたNNDDVideoをvalueに持つ連想配列からXMLを生成して返します。
		 * 
		 * @param videoMap
		 * @return 
		 * 
		 */
		public function convert(videoMap:Object):XML{
			var libraryXML:XML = <libraryItem/>;
			var index:int = 0;
			for each(var video:NNDDVideo in videoMap){
				libraryXML.item[index] = escapeMultiByte(video.getDecodeUrl());
				(libraryXML.item[index] as XML).@isEconomy = video.isEconomy;
				(libraryXML.item[index] as XML).@modificationDate = (video.modificationDate as Date).time;
				(libraryXML.item[index] as XML).@creationDate = (video.creationDate as Date).time;
				(libraryXML.item[index] as XML).@thumbImgUrl = escapeMultiByte(video.thumbUrl);
				(libraryXML.item[index] as XML).@playCount = video.playCount;
				var lastPlayDate:Date = (video.lastPlayDate as Date);
				if(lastPlayDate != null){
					(libraryXML.item[index] as XML).@lastPlayDate = lastPlayDate.time;
				}
				var pubDate:Date = (video.pubDate as Date);
				if(pubDate != null){
					(libraryXML.item[index] as XML).@pubDate = pubDate.time;
				}
				
				libraryXML.item[index].tags = <tags/>;
				for(var i:int = 0; i<video.tagStrings.length; i++){
					var tagString:String = video.tagStrings[i];
					var tagXML:XML = <tag/>;
					tagXML.setChildren(escapeMultiByte(tagString));
					libraryXML.item[index].tags.tag[i] = tagXML;
				}
				index++;
			}
			
			return libraryXML;
		}
		
		/**
		 * 渡されたXMLを元にNNDDVideoオブジェクトを生成し、
		 * {@link NNDDVidoe#getDecodeUrl()} を元に生成したキーを使った
		 * 連想配列に格納して返します。
		 * 
		 * @param libraryXML
		 * @return NNDDVideoオブジェクトvalueに持った連想配列
		 * 
		 */
		public function perseXML(libraryXML:XML):Object{
			
			var map:Object = new Object();
			
			var libraryItemList:XMLList = libraryXML.children();
			for each(var item:XML in libraryItemList){
				if(item != null){
					var video:NNDDVideo;
					//エコノミーモードかどうかを取得
					var fileName:String = unescapeMultiByte(item.text());
					if((item as XML).@isEconomy != undefined && (item as XML).@isEconomy == "true"){
						video = new NNDDVideo(fileName, null, true);
					}else{
						video = new NNDDVideo(fileName, null, false);
					}
					//タグを取得
					if((item as XML).tags != null){
						try{
							var tags:XMLList = item.children()[1].children();
							for(var i:int=0; i<tags.length(); i++){
								var tag:String = (tags[i] as XML).text();
								tag = unescapeMultiByte(tag);
								video.tagStrings.push(tag);
							}
						}catch(error:Error){
							trace(error.getStackTrace());
							trace(item);
						}
					}
					//作成日時取得
					if((item as XML).@creationDate != undefined && (item as XML).@creationDate != ""){
						video.creationDate = new Date(Number(item.@creationDate));
					}else{
						video.creationDate = null
					}
					//編集日時取得
					if((item as XML).@modificationDate != undefined && (item as XML).@modificationDate != ""){
						video.modificationDate = new Date(Number(item.@modificationDate));
					}else{
						video.modificationDate = null;
					}
					//サムネイル画像のURLを取得
					if((item as XML).@thumbImgUrl != undefined && (item as XML).@thumbImgUrl != ""){
						video.thumbUrl = unescapeMultiByte(item.@thumbImgUrl);
					}else{
						video.thumbUrl = "";
					}
					//再生回数を取得
					if((item as XML).@playCount != undefined && (item as XML).@playCount != ""){
						video.playCount = Number(item.@playCount[0]);
					}else{
						video.playCount = 0;
					}
					//最終再生時刻を取得
					if((item as XML).@lastPlayDate != undefined && (item as XML).@lastPlayDate != ""){
						video.lastPlayDate = new Date(Number(item.@lastPlayDate));
					}else{
						video.lastPlayDate = null;
					}
					//投稿日時を取得
					if((item as XML).@pubDate != undefined && (item as XML).@pubDate != ""){
						video.pubDate = new Date(Number(item.@pubDate));
					}else{
						video.pubDate = null;
					}
					
					var key:String = LibraryUtil.getVideoKey(video.getDecodeUrl());
					map[key] = video;
				}
			}
			
			return map;
		}
		
		
	}
}