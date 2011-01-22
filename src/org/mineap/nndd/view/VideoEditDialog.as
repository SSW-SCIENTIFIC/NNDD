// ActionScript file
import flash.events.Event;
import flash.filesystem.File;
import flash.net.FileFilter;
import flash.profiler.showRedrawRegions;

import mx.controls.Alert;
import mx.events.CloseEvent;

import org.mineap.nicovideo4as.ThumbImgLoader;
import org.mineap.nndd.FileIO;
import org.mineap.nndd.LogManager;
import org.mineap.nndd.Message;
import org.mineap.nndd.library.LibraryManagerBuilder;
import org.mineap.nndd.model.NNDDVideo;
import org.mineap.nndd.util.PathMaker;

private var _oldVideo:NNDDVideo;
private var _newVideo:NNDDVideo;
private var _videoFile:File;

[Bindable]
private var economyTypeArray:Array = new Array("はい", "いいえ");

public function init(video:NNDDVideo, logMangaer:LogManager):void{
	
	this._oldVideo = video;
	
	if(video.file != null && video.file.exists){
		textInput_videoTitle.text = video.file.name;
		this._videoFile = video.file;
		button_videoFileOpen.enabled = false;
	}else{
		textInput_videoTitle.enabled = false;
		textInput_videoTitle.toolTip = "動画ファイルが見つかりません。";
		button_edit.enabled = false;
		button_edit.toolTip = "動画ファイルが見つかりません。";
		textInput_videoTitle.text = video.getVideoNameWithVideoID();
	}
	
	try{
		label_editVideoPath.text = (new File(video.getDecodeUrl())).nativePath;
	}catch(e:Error){
		label_editVideoPath.text = video.getDecodeUrl();
	}
	
	try{
		textInput_thumbImgPath.text = (new File(video.thumbUrl)).nativePath;
	}catch(e:Error){
		textInput_thumbImgPath.text = unescape(decodeURIComponent(video.thumbUrl));
	}
	
	if(video.isEconomy){
		comboBox_isEconomyMode.selectedIndex = 0;
	}else{
		comboBox_isEconomyMode.selectedIndex = 1;
	}
}

private function videoEditCancelButtonClicked():void{
	this._newVideo = this._oldVideo;
	dispatchEvent(new Event(Event.CANCEL));
}

private function videoFileOpenButtonClicked(event:Event):void{
	var directory:File = null;
	try{
		directory = LibraryManagerBuilder.instance.libraryManager.libraryDir;
	}catch(e:ArgumentError){
		directory = File.documentsDirectory;
	}
	
	var videoFilter:FileFilter = new FileFilter("Videos", "*.flv;*.swf;*.mp4");
	
	directory.browseForOpen("動画ファイルを選択", [videoFilter]);
	
	// ファイル選択イベントのリスナを登録
	directory.addEventListener(Event.SELECT, function(event:Event):void{
		// イベントのターゲットが選択されたファイルなので、`File`型に変換
		var file:File = File(event.target);
		textInput_videoTitle.text = file.name;
		label_editVideoPath.text = file.nativePath;
		
		textInput_videoTitle.enabled = true;
		textInput_videoTitle.toolTip = null;
		button_edit.enabled = true;
		button_edit.toolTip = null;
		
	});
}

private function imageFileOpenButtonClicked(event:Event):void{
	var directory:File = null;
	try{
		directory = new File(textInput_thumbImgPath.text);
		directory = directory.parent;
	}catch(e:ArgumentError){
		directory = File.documentsDirectory;
	}
	
	var imagesFilter:FileFilter = new FileFilter("Images", "*.jpg;*.jpeg;*.gif;*.png");
	
	directory.browseForOpen("サムネイル画像を選択", [imagesFilter]);
	
	// ファイル選択イベントのリスナを登録
	directory.addEventListener(Event.SELECT, function(event:Event):void{
		// イベントのターゲットが選択されたファイルなので、`File`型に変換
		var file:File = File(event.target);
		textInput_thumbImgPath.text = file.nativePath;
	});
}

private function videoEditButtonClicked():void{
	
	//TODO ファイル名の変更は未実装
//	var url:String = _oldVideo.getDecodeUrl().substring(0, _oldVideo.getDecodeUrl().lastIndexOf("/")+1);
//	var extention:String = PathMaker.getExtension(url);
//	url += FileIO.getSafeFileName(textInput_videoTitle.text);
//	url += extention;
	
	// ファイル名の変更
	var oldFile:File = this._oldVideo.file;
	var newTitle:String = textInput_videoTitle.text;
	
	var newSafeTitle:String = FileIO.getSafeFileName(newTitle);
	
	if(newSafeTitle != newTitle){
		// タイトルを保存可能な形式に変更
		Alert.show("保存できない文字列が含まれていたため、次のように置き換えます。よろしいですか？\n\n" + newSafeTitle, Message.M_MESSAGE, (Alert.OK | Alert.CANCEL), null, function(event:CloseEvent):void{
			if(event.detail == Alert.OK){
				_videoFile = oldFile.parent.resolvePath(newSafeTitle);
				createNewVideo();
			}else{
				// 何もしない
			}
		});
	}else{
		
		_videoFile = oldFile.parent.resolvePath(newSafeTitle);
		createNewVideo();
		
	}
	
	
	
}

private function createNewVideo():void{
	
	// ファイル名の変更チェック
	if(this._oldVideo.file.name == _videoFile.name){
		// ファイル名に変更無し
		this._videoFile  = this._oldVideo.file;
	}else{
		
		var fileName:String = _videoFile.name;
		
		var videoId:String = PathMaker.getVideoID(this._oldVideo.getDecodeUrl());
		if(videoId != null && fileName.indexOf(videoId) == -1 ){
			// 新しいファイル名にvideoIdが含まれていないので付加
			
			var dotIndex:int = fileName.lastIndexOf(".");
			if(dotIndex != -1){
				// 拡張子がある
				var videoTitle:String = fileName.substring(0, dotIndex);
				var extension:String = fileName.substring(dotIndex);
				fileName = videoTitle + " - [" + videoId + "]" + extension;
			}else{
				// 拡張子が無い
				fileName += " - [" + videoId + "]";
			}
		}
		
		var parentFile:File = _oldVideo.file.parent;
		var newFile:File = parentFile.resolvePath(fileName);
		
		// 拡張子がついていなければつける
		if(newFile.extension == null){
			newFile = parentFile.resolvePath(fileName + "." +  _oldVideo.file.extension);
		}
		
		// ファイルを移動
		if(newFile.exists){
		}else{
			this._oldVideo.file.moveTo(newFile, false);
		}
		this._videoFile = newFile;
	}
	
	// エコノミーの登録
	var isEconomy:Boolean = false;
	if(comboBox_isEconomyMode.selectedIndex == 0){
		isEconomy = true;
	}
	
	// サムネ画像の登録
	var thumbImgPath:String = "";
	try{
		thumbImgPath = (new File(textInput_thumbImgPath.text)).url;
	}catch(e:ArgumentError){
		thumbImgPath = textInput_thumbImgPath.text;
	}
	
	this._newVideo = new NNDDVideo(_videoFile.url, _videoFile.name, 
		isEconomy, _oldVideo.tagStrings, _oldVideo.modificationDate, 
		_oldVideo.creationDate, thumbImgPath, _oldVideo.playCount, 
		_oldVideo.time, _oldVideo.lastPlayDate, _oldVideo.pubDate);
	
	dispatchEvent(new Event(Event.COMPLETE));
}

public function get oldVideo():NNDDVideo{
	return this._oldVideo;
}

public function get newVideo():NNDDVideo{
	return this._newVideo;
}