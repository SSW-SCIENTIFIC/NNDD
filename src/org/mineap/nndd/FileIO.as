package org.mineap.nndd
{
		
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.mineap.nndd.model.NNDDVideo;
	import org.mineap.nndd.util.DateUtil;
	import org.mineap.nndd.util.PathMaker;

	/**
	 * FileIO.as
	 * 主にNNDDに特化した、ローカルのファイルへのアクセスを提供します。
	 * 
	 * Copyright (c) 2008 MAP - MineApplicationProject. All Rights Reserved.
	 *  
	 * @author shiraminekeisuke
	 * 
	 */	
	public class FileIO extends EventDispatcher
	{
		private var fileStream:FileStream;
		private var file:File;
		private var commentLoader:URLLoader;
		private var playListLoader:URLLoader;
		private var logManager:LogManager;
		
		public static const LIBRARY_LOAD_FAIL:String = "LibraryLoadFail";
		public static const LIBRARY_LOAD_SUCCESS:String = "LibraryLoadSuccess";
		public static const LIBRARY_LOAD_SUCCESS_WITH_VUP:String = "LibraryLoadSuccessWithVup";
		
		
		/**
		 * コンストラクタ<br>
		 * 
		 */
		public function FileIO(logManager:LogManager = null)
		{
			fileStream = new FileStream();
			commentLoader = new URLLoader();
			playListLoader = new URLLoader();
			this.logManager = logManager;
		}
		
		/**
		 * 指定されたURLLoaderのdataを、指定されたファイル名でディスクに書き出します。<br>
		 * このメソッドはdataをバイナリデータとして書き出します。動画を書き出すために使用してください。<br>
		 * @param loader URLLoader
		 * @param fileName 保存したいファイル名
		 * @param path 保存先のディレクトリまでの絶対パス。<br>
		 *             最後は/で終わっている必要があります。
		 * @return 保存した動画のフルパスを返します。このフルパスは禁則文字を置き換え済です。
		 */
		public function saveVideoByURLLoader(loader:URLLoader, fileName:String, path:String):File
		{
			
				
			fileName = getSafeFileName(fileName);
			
			if(path.charAt(path.length) != "/"){
				path += "/";
			}
			
			file = new File(path + fileName);
			
			if(file.exists){
				file.moveToTrash();
			}
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(loader.data);
			fileStream.close();
			
			return file;
			
		}
		
		/**
		 * 禁則文字を全角文字に置換した文字列を返します。
		 * @param fileName
		 * @return 
		 * 
		 */
		public static function getSafeFileName(fileName:String):String{
			
			//禁則文字　/ : ? \ * " % < > | # ;
			
			while(fileName.indexOf("/") != -1){
				fileName = fileName.replace(new RegExp("/"), "／");
			}
			while(fileName.indexOf(":") != -1){
				fileName = fileName.replace(new RegExp(":"), "：");
			}
			while(fileName.indexOf("?") != -1){
				fileName = fileName.replace(new RegExp("\\?"), "？");
			}
			while(fileName.indexOf("\\") != -1){
				fileName = fileName.replace(new RegExp("\\\\"), "＼");
			}
			while(fileName.indexOf("*") != -1){
				fileName = fileName.replace(new RegExp("\\*"), "＊");
			}
			while(fileName.indexOf("\"") != -1){
				fileName = fileName.replace(new RegExp("\""), "”");
			}
			while(fileName.indexOf("%") != -1){
				fileName = fileName.replace(new RegExp("%"), "％");
			}
			while(fileName.indexOf("<") != -1){
				fileName = fileName.replace(new RegExp("<"), "＜");
			}
			while(fileName.indexOf(">") != -1){
				fileName = fileName.replace(new RegExp(">"), "＞");
			}
			while(fileName.indexOf("|") != -1){
				fileName = fileName.replace(new RegExp("\\|"), "｜");
			}
			while(fileName.indexOf("#") != -1){
				fileName = fileName.replace(new RegExp("#"), "＃");
			}
			while(fileName.indexOf(";") != -1){
				fileName = fileName.replace(new RegExp(";"), "；");
			}
			
			return fileName;
		}
		
		/**
		 * 指定された文字列を、指定されたファイル名でディスクに書き出します。<br>
		 * このメソッドはdataをUTFの文字列として書き出します。<br>
		 * @param comment XML
		 * @param fileName 保存したいファイル名
		 * @param path 保存先のディレクトリまでの絶対パス。<br>
		 *             最後は/で終わっている必要があります。
		 * @param isAppend 既にファイルがある場合、ファイルを追記して保存するかどうかです。
		 * @param maxCount isAppendがtrueの場合、追記後のコメントの最大値を指定します。
		 */
		public function saveComment(comment:XML, fileName:String, path:String, isAppend:Boolean, maxCount:Number):File
		{
			fileName = getSafeFileName(fileName);
			
			if(path.charAt(path.length) != "/"){
				path += "/";
			}
			
			file = new File(path + fileName);
			
			if(file.exists && isAppend){
				this.addComments(file.nativePath, comment, maxCount);
			}else{
				this.saveXMLSync(file, comment, false);
			}
			
			return file;
		}
		
		/**
		 * filePathで指定されたファイルのロードを行います。<br>
		 * 読み込んだ結果はイベントリスナーを登録してチェックする必要があります。
		 * @param filePath
		 * 
		 */
		public function loadComment(filePath:String):XML
		{
			return loadXMLSync(filePath, true);
		}
		
		/**
		 * 
		 * @param str
		 * 
		 */
		public function saveHtml(html:String, fileName:String, path:String):File{
			fileName = getSafeFileName(fileName);
			
			if(path.charAt(path.length) != "/"){
				path += "/";
			}
			
			file = new File(path + fileName);
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(html);
			fileStream.close();
			
			return file;
		}
		
		/**
		 * 指定されたファイルを同期的に読み込み、テキストとして返します。
		 * 
		 * @param filePath
		 * @return 
		 * 
		 */
		public function loadTextSync(filePath:String):String{
			
			file = new File(filePath);
			if(!file.exists){
				return null;
			}
			
			fileStream.open(file, FileMode.READ);
			var str:String = fileStream.readUTFBytes(file.size);
			fileStream.close();
			
			return str;
		}
		
		/**
		 * filePathで指定されたファイルをXMLとして開き、指定されたcommentを追加します。
		 * @param filePath
		 * @param comment
		 * 
		 */
		public function addComment(filePath:String, comment:XML):void{
			file = new File(filePath);
			if(!file.exists){
				return;
			}
			try{	
				
				var commentXML:XML = this.loadXMLSync(file.nativePath, true);
				commentXML.appendChild(comment);
				
				this.saveXMLSync(file, commentXML, false);		
				logManager.addLog("投稿したコメントをローカルに保存:" + decodeURIComponent(file.url));
				
			}catch(error:Error){
				logManager.addLog("投稿したコメントをローカルに保存できませんでした。:" + file.nativePath + ":" + error);
				Alert.show("投稿したコメントをローカルのコメントXMLに保存できませんでした。"+ error, Message.M_ERROR);
			}
			
		}
		
		/**
		 * filePathで指定されたファイルをXMLとして開き、指定されたコメントを追加します。
		 * @param filePath
		 * @param comments
		 * @param maxCount
		 */
		public function addComments(filePath:String, newComments:XML, maxCount:Number):void{
			file = new File(filePath);
			if(!file.exists){
				return;
			}
			try{
				var oldComments:XML = this.loadXMLSync(file.nativePath, true);
				var newCommentOfOldComments:XML = null;
				if((oldComments.chat as XMLList).length() > 0){
					newCommentOfOldComments = oldComments.chat[(oldComments.chat as XMLList).length()-1];
				}
				var oldCommentOfOldComments:XML = null;
				if((oldComments.chat as XMLList).length() > 0){
					oldCommentOfOldComments = oldComments.chat[0];
				}
				
				if(newCommentOfOldComments == null || oldCommentOfOldComments == null){
					//古いコメントが空だったら全部追加
					oldComments.appendChild(newComments.chat);
				}else if(newCommentOfOldComments != null && oldCommentOfOldComments != null){
					
					if((newComments.chat as XMLList).length() > 0){
						
						var oldOfOldNo:int = int(oldCommentOfOldComments.@no);
						var newOfOldNo:int = int(newCommentOfOldComments.@no);
						
						var insertCount:int = 0;
						
						for each(var xml:XML in newComments.chat){
							
							var newNo:int = int(xml.@no);
							
							if(newNo < oldOfOldNo){
								// 新しく取得したコメントがローカルコメントのどれよりも古い
								if(insertCount == 0){
									oldComments.insertChildBefore(oldComments.chat[0], xml);
								}else{
									oldComments.insertChildAfter(oldComments.chat[insertCount-1], xml);
								}
								insertCount++;
								
							}else if(newNo > newOfOldNo){
								// 新しく取得したコメントがローカルコメントのどれよりも新しい
								
								var lastChatIndex:int = -1;
								if((oldComments.chat as XMLList).length() > 0){
									lastChatIndex = (oldComments.chat as XMLList).length() - 1;
								}
								
								if(lastChatIndex != -1){
									oldComments.insertChildAfter(oldComments.chat[lastChatIndex], xml);
								}else{
									oldComments.appendChild(xml);
								}
							}
						}
						
					}else{
						// 新しいコメントが空だったら何もしない
					}
					
				}else{
					trace("データが変です...");
				}
				
				// コメントは最大個数以下しか保存させない
				while((oldComments.chat as XMLList).length() > maxCount){
					delete (oldComments.chat as XMLList)[0];
				}
				
				this.saveXMLSync(file, oldComments, false);
				
			}catch(error:Error){
				trace(error.getStackTrace());
				LogManager.instance.addLog("コメントをローカルに追加できませんでした。:" + file.nativePath + ":" + error);
				Alert.show("コメントをローカルのコメントXMLに追加できませんでした。"+ error, Message.M_ERROR);
			}
		}
		
		/**
		 * 同期的にローカルのXMLファイルを開き、XMLオブジェクトにして返します。
		 * @param localFilePath
		 * @param isIgnoreWhilteSpace 空白ノードを無視するかどうか。
		 * @return 
		 * 
		 */
		public function loadXMLSync(localFilePath:String, isIgnoreWhilteSpace:Boolean):XML{
			file = new File(localFilePath);
			XML.ignoreWhitespace = isIgnoreWhilteSpace;
			
			var xml:XML;
			
			if(file.exists){
				
				fileStream.open(file, FileMode.READ);
				var string:String = fileStream.readUTFBytes(file.size);
				try{
					xml = new XML(string);
				}catch(error:Error){
					xml = null;
				}
				
				fileStream.close();
				
			}
			
			return xml;
				
		}
		
		/**
		 * 渡されたXMLを指定されたFileとして保存します。
		 * @param file
		 * @param xml
		 * 
		 */
		public function saveXMLSync(file:File, xml:XML, backUpEnable:Boolean = true):void{
			
			// まずは一時ファイルを作ってそちらに保存
			var tempFile:File = new File(file.url + ".temp");
			
			fileStream.open(tempFile, FileMode.WRITE);
			fileStream.writeUTFBytes(xml);
			fileStream.close();
			
			if(!file.exists){
				//存在しないなら何もしない
				
			}else{
				//すでにファイルが存在するなら
				
				var tempSize:Number = tempFile.size;
				var fileSize:Number = file.size;
				
				var diff:Number = fileSize - tempSize;
				if(backUpEnable && (diff > fileSize * 0.25 || (tempSize < 100 && fileSize > 100))){
					// 一時ファイルと既に保存済みファイルの容量の差が25%以上、もしくは
					// tempファイルの容量が著しく小さい時
					// (ただし、fileSizeが既に小さい値の場合は".back2"を作らない)
					
					// 元ファイルを".back2"として保存
					var back2File:File = new File(file.nativePath + ".back2");
					try{
						if(file.exists){
							file.copyTo(back2File, true);
						}
					}catch(error:Error){
						logManager.addLog("バックアップファイルの作成に失敗:" + back2File.nativePath + ":" + error);
						trace(error.getStackTrace());
					}
					
				}else{
					// 変更の差が25%以下の時は何もしない
				}
				
				// 既に存在するファイルをバックアップに変更
				var newFile:File = new File(file.nativePath + ".back");
				try{
					if(backUpEnable && file.exists){
						file.copyTo(newFile, true);
					}
				}catch(error:Error){
					logManager.addLog("バックアップファイルの作成に失敗:" + newFile.nativePath + ":" + error);
					trace(error.getStackTrace());
				}
				
			}
			
			// 一時ファイルを本ファイルとして保存
			tempFile.copyTo(file, true);
			tempFile.deleteFile();
			
		}
		
		/**
		 * filePathで指定されたファイル名でプレイリストを作成し、保存します。<br>
		 * @param filePath
		 * @param playList
		 * 
		 */
		public function savePlayList(filePath:String, videos:Vector.<NNDDVideo>):void{
			file = new File(filePath);
			XML.ignoreWhitespace = true;
			
			var buffer:String = "";
			for(var i:int=0; i<videos.length; i++){
				var video:NNDDVideo = videos[i];
				buffer = buffer + video.getDecodeUrl() + "\n" + "#EXTINF:" + video.time + "," + video.getVideoNameWithVideoID() + "\n";
			}
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeUTFBytes(buffer);
			fileStream.close();
			
			if(logManager != null){
				logManager.addLog("プレイリストの保存完了:" + file.nativePath);
			}
		}
		
		/**
		 * 指定されたバイト列を指定されたファイルパスに書き出します。
		 * 
		 * @param filePath
		 * @param bytes
		 * @return 保存したサムネイル画像を表すFileオブジェクトです。
		 */
		public function saveByteArray(fileName:String, path:String, bytes:ByteArray):File{
			
			fileName = getSafeFileName(fileName);
			
			if(path.charAt(path.length) != "/"){
				path += "/";
			}
			
			file = new File(path + fileName);
			
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(bytes, 0, bytes.length);
			fileStream.close();
			
			if(logManager != null){
				logManager.addLog("サムネイル画像の保存完了:" + file.nativePath);
			}
			
			return file;
			
		}
		
		
		/**
		 * Fileにリスナーを追加します。<br>
		 * FileI/Oの完了などの通知を得たい場合はリスナーを追加してください。
		 * @param eventType
		 * @param handler
		 * 
		 */
		public function addFileEventListener(eventType:String, handler:Function):void
		{
			file.addEventListener(eventType,handler); 
		}
		
		/**
		 * FileStreamにリスナーを追加します。<br>
		 * FileI/Oの完了などの通知を得たい場合はリスナーを追加してください。
		 * @param eventType
		 * @param handler
		 * 
		 */
		public function addFileStreamEventListener(eventType:String, handler:Function):void
		{
			fileStream.addEventListener(eventType,handler);
		}
		
		/**
		 * URLLoaderにリスナーを追加します<br>
		 * URLLoaderのロード完了などの通知を得たい場合はリスナーを追加してください。
		 * @param eventType
		 * @param handler
		 * 
		 */
		public function addURLLoaderEventListener(eventType:String, handler:Function):void
		{
			commentLoader.addEventListener(eventType,handler);
		}
		
		/**
		 * 開かれているファイルストリームを閉じます。
		 */
		public function closeFileStream():void{
			try{
				this.fileStream.close();
			}catch(error:Error){
				
			}
		}
		
	}
}