// ActionScript file
import flash.events.Event;
import flash.filesystem.File;
import flash.net.FileFilter;

import org.mineap.nndd.LogManager;
import org.mineap.nndd.model.NNDDVideo;

private var _oldVideo:NNDDVideo;
private var _newVideo:NNDDVideo;

[Bindable]
private var economyTypeArray:Array = new Array("はい", "いいえ");

public function init(video:NNDDVideo, logMangaer:LogManager):void{
	
	this._oldVideo = video;
	
	textInput_videoTitle.text = video.videoName;
	
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

private function fileOpenButtonClicked(event:Event):void{
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
	
	var isEconomy:Boolean = false;
	if(comboBox_isEconomyMode.selectedIndex == 0){
		isEconomy = true;
	}
	var thumbImgPath:String = "";
	try{
		thumbImgPath = (new File(textInput_thumbImgPath.text)).url;
	}catch(e:ArgumentError){
		thumbImgPath = textInput_thumbImgPath.text;
	}
	
	this._newVideo = new NNDDVideo(_oldVideo.uri, _oldVideo.videoName, isEconomy, _oldVideo.tagStrings, _oldVideo.modificationDate, _oldVideo.creationDate, thumbImgPath);
	
	dispatchEvent(new Event(Event.COMPLETE));
}

public function get oldVideo():NNDDVideo{
	return this._oldVideo;
}

public function get newVideo():NNDDVideo{
	return this._newVideo;
}