/**
 * VideoInfoView.as
 * 
 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
 *  
 * @author shiraminekeisuke
 * 
 */	

import flash.display.StageDisplayState;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.events.TextEvent;
import flash.geom.Rectangle;
import flash.sampler.getInvocationCount;
import flash.utils.Timer;

import mx.collections.ArrayCollection;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.controls.Alert;
import mx.controls.CheckBox;
import mx.controls.ComboBox;
import mx.controls.DataGrid;
import mx.controls.HSlider;
import mx.controls.RadioButton;
import mx.core.Application;
import mx.core.DragSource;
import mx.core.FlexGlobals;
import mx.core.Window;
import mx.events.AIREvent;
import mx.events.CloseEvent;
import mx.events.DataGridEvent;
import mx.events.DragEvent;
import mx.events.FlexEvent;
import mx.events.ListEvent;
import mx.events.NumericStepperEvent;
import mx.events.SliderEvent;

import org.mineap.nicovideo4as.model.SearchType;
import org.mineap.nndd.LogManager;
import org.mineap.nndd.Message;
import org.mineap.nndd.model.NNDDVideo;
import org.mineap.nndd.model.PlayList;
import org.mineap.nndd.model.SearchItem;
import org.mineap.nndd.model.SearchSortString;
import org.mineap.nndd.playList.PlayListManager;
import org.mineap.nndd.player.PlayerController;
import org.mineap.nndd.util.DataGridColumnWidthUtil;
import org.mineap.nndd.util.PathMaker;
import org.mineap.util.config.ConfUtil;
import org.mineap.util.config.ConfigManager;
import org.mineap.util.font.FontUtil;

private var videoPlayer:VideoPlayer;
private var playerController:PlayerController;
private var logManager:LogManager;

public var isPlayListRepeat:Boolean = false;
public var isSyncComment:Boolean = true;
public var isPlayerFollow:Boolean = true;
public var isRenewCommentEachPlay:Boolean = false;
public var isRenewOtherCommentWithCommentEachPlay:Boolean = false;
public var isResizePlayerEachPlay:Boolean = true;
public var isHideUnderController:Boolean = false;
public var commentScale:Number = 1.0;
public var fps:Number = 15;
public var isShowOnlyPermissionComment:Boolean = false;
public var showCommentCountPerMin:int = 50;
public var showOwnerCommentCountPerMin:int = 50;
public var showCommentSec:int = 3;
public var isAntiAlias:Boolean = true;
public var commentAlpha:int = 100;
public var isEnableJump:Boolean = true;
public var isAskToUserOnJump:Boolean = true;
public var isInfoViewAlwaysFront:Boolean = false;
public var isCommentFontBold:Boolean = true;
public var isShowAlwaysNicowariArea:Boolean = false;
public var selectedResizeType:int = RESIZE_TYPE_NICO;
public var isAlwaysEconomyForStreaming:Boolean = false;
public var isHideTagArea:Boolean = false;
public var isAppendComment:Boolean = false;
public var isHideSekaShinComment:Boolean = false;
public var isShowHTMLOwnerComment:Boolean = true;
public var isEnableWideMode:Boolean = true;
public var relationSortIndex:int = 0;
public var relationOrderIndex:int = 0;
public var isNgUpEnable:Boolean = true;
public var isSmoothing:Boolean = true;
public var isSmoothingOnlyNotPixelIdenticalDimensions:Boolean = true;
public var playerQuality:int = 2;
public var isFollowInfoViewHeight:Boolean = false;
public var isNotPlayNicowari:Boolean = false;
public var isOpenFileDialogWhenOpenPlayer:Boolean = false;

public static const RESIZE_TYPE_NICO:int = 1;
public static const RESIZE_TYPE_VIDEO:int = 2;

public var videoUrlMap:Object = new Object();

public var myListMap:Object = new Object();

private var lastRect:Rectangle = new Rectangle();

private var seekTimer:Timer;
private var seekValue:Number = 0;

public var isActive:Boolean = false;

public var playListName:String = "";

[Bindable]
public var commentListProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var ownerCommentProvider:ArrayCollection = new ArrayCollection();
[Bindable]
private var playListProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var localTagProvider:Array = new Array();
[Bindable]
public var nicoTagProvider:Array = new Array();
[Bindable]
public var ichibaLocalProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var ichibaNicoProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var ngListProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var owner_text_nico:String = "";
[Bindable]
public var owner_text_local:String = "";
[Bindable]
private var myListDataProvider:Array = new Array();
[Bindable]
public var savedCommentListProvider:Array = new Array();
[Bindable]
public var owner_text_temp:String = "";
[Bindable]
public var relationDataProvider:ArrayCollection = new ArrayCollection();
[Bindable]
public var relationSortComboboxDataProvider:Array = new Array("オススメ度", "コメント数", "再生数", "投稿日");
[Bindable]
public var relationOrderComboboxDataProvider:Array = new Array("降順", "昇順");
[Bindable]
private var label_playListTitle_dataProvider:String = "";
[Bindable]
public var videoType:String = "";
[Bindable]
public var connectionType:String = "";
[Bindable]
public var videoServerUrl:String = "";
[Bindable]
public var messageServerUrl:String = "";
[Bindable]
public var economyMode:String = "";
[Bindable]
public var nickName:String = "";
[Bindable]
public var isPremium:String = "";
[Bindable]
public var pubUserNameIconUrl:String = "";
[Bindalbe]
public var pubUserName:String = "";
[Bindalbe]
public var pubUserLinkButtonText:String = "";

public function init(playerController:PlayerController, videoPlayer:VideoPlayer, logManager:LogManager):void{
	this.videoPlayer = videoPlayer;
	this.playerController = playerController;
	this.logManager = logManager;
	
	this.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
		stage.addEventListener(AIREvent.WINDOW_ACTIVATE, function(event:AIREvent):void{
			isActive = true;
		});
		stage.addEventListener(AIREvent.WINDOW_DEACTIVATE, function(event:AIREvent):void{
			isActive = false;
		});
	});
	
	readStore();
}

public function resetInfo():void{
	localTagProvider = new Array();
	nicoTagProvider = new Array();
	ichibaLocalProvider = new ArrayCollection();
	ichibaNicoProvider = new ArrayCollection();
	
	owner_text_local = "";
	owner_text_nico = "";
	owner_text_temp = "";
}

private function windowClosing(event:Event):void{
	
	event.preventDefault();
	
//	if(this.videoPlayer != null && !this.videoPlayer.closed){
//		this.videoPlayer.close();
//	}
//	
//	this.playerController.destructor();
	
	this.visible = false;
	
}

private function play():void{
	this.playerController.play();
}

private function stop():void{
	this.playerController.stop();
}

private function checkBoxAppendCommentChanged(event:Event):void{
	this.isAppendComment = event.target.selected;
	FlexGlobals.topLevelApplication.setAppendComment(this.isAppendComment);
}

public function setAppendComment(boolean:Boolean):void{
	this.isAppendComment = boolean;
	if(checkBox_isAppendComment != null){
		checkBox_isAppendComment.selected = boolean;
	}
}

public function relationItemDoubleClickHandler(event:ListEvent):void{
	if(relationDataProvider.length > event.rowIndex){
		var url:String = relationDataProvider[event.rowIndex].col_link;
		if(url != null && url.length > 0){
			var videoId:String = PathMaker.getVideoID(url);
			if(videoId != null){
				playerController.playMovie(url);
			}
		}
	}
}

public function checkBoxNgUpChanged(event:Event):void{
	this.isNgUpEnable = checkBox_isNgUpEnable.selected;
	if(this.playerController != null){
		this.playerController.reloadLocalComment();
	}
}

public function checkBoxSmoothingChanged(event:Event):void{
	this.isSmoothing = checkBox_isSmoothing.selected;
	checkBox_isSmoothingOnlyNotPixelIdenticalDimensions.enabled = this.isSmoothing;
	if(this.playerController != null){
		this.playerController.setVideoSmoothing(this.isSmoothing);
	}
}

public function checkBoxSmoothingOnlyNotPixelIdenticalDimensionsChanged(event:Event):void
{
	this.isSmoothingOnlyNotPixelIdenticalDimensions = checkBox_isSmoothingOnlyNotPixelIdenticalDimensions.selected;
	if (this.playerController != null)
	{
		this.playerController.setVideoSmoothing(this.isSmoothing);
	}
}

private function checkBoxPlayerAlwaysFrontChanged(event:Event):void{
	this.videoPlayer.isAlwaysFront = (event.currentTarget as CheckBox).selected;
	this.videoPlayer.alwaysInFront = (event.currentTarget as CheckBox).selected;
}

private function checkBoxInfoViewAlwaysFrontChanged(event:Event):void{
	this.isInfoViewAlwaysFront = (event.currentTarget as CheckBox).selected;
	this.alwaysInFront = (event.currentTarget as CheckBox).selected;
}

private function checkBoxCommentFontBoldChanged(event:Event):void{
	this.isCommentFontBold = this.checkBox_commentBold.selected;
	playerController.setCommentFontBold(this.isCommentFontBold);
}

private function checkboxSyncCommentChanged():void{
	this.isSyncComment = this.checkbox_SyncComment.selected;
	this.commentListProvider.sort = new Sort();
	this.commentListProvider.sort.fields = [new SortField("vpos_column",true)];
	this.commentListProvider.refresh();
}

private function checkboxRepeatAllChanged():void{
	this.isPlayListRepeat = this.checkBox_repeatAll.selected;
	if(isPlayListRepeat){
		videoPlayer.setIsRepeat(false);
	}
}

private function checkboxPlayerFollowChanged(event:Event):void{
	this.isPlayerFollow = this.checkbox_playerFollow.selected;
	if((event.currentTarget as CheckBox).selected){
		this.videoPlayer.followInfoView(this.videoPlayer.lastRect);
	}
}

private function checkboxFollowInfoViewHeight(event:Event):void
{
	this.isFollowInfoViewHeight = this.checkbox_followInfoViewHeight.selected;
	if ((event.currentTarget as CheckBox).selected)
	{
		this.videoPlayer.resizeInfoView();
	}
}

private function checkboxHideUnderControllerChanged(event:Event):void{
	this.isHideUnderController = this.checkbox_hideUnderController.selected;
	if(this.videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){
		if((event.currentTarget as CheckBox).selected){
			//下コントローラを隠す
			this.videoPlayer.showUnderController(false, true);
		}else{
			//下コントローラを表示
			this.videoPlayer.showUnderController(true, true);
		}
	}
	this.videoPlayer.videoController.resetAlpha(true);
}

private function checkboxHideTagAreaChanged(event:Event):void{
	this.isHideTagArea = this.checkbox_hideTagArea.selected;
	if(this.videoPlayer.stage.displayState != StageDisplayState.FULL_SCREEN_INTERACTIVE){
		if((event.currentTarget as CheckBox).selected){
			//タグ表示領域を隠す
			this.videoPlayer.showTagArea(false, true);
		}else{
			//タグ表示利用域を表示する
			this.videoPlayer.showTagArea(true, true);
		}
	}
	this.videoPlayer.videoController.resetAlpha(true);
}

public function changeWideMode():void{
	if(isResizePlayerEachPlay){
		if(this.selectedResizeType == VideoInfoView.RESIZE_TYPE_NICO){
			isEnableWideMode = !isEnableWideMode;
			if(checkbox_enableWideMode != null){
				checkbox_enableWideMode.selected = isEnableWideMode;
			}
			this.playerController.resizePlayerJustVideoSize(this.videoPlayer.nowRatio);
		}
	}
}

private function checkboxResizePlayerEachPlay(event:Event):void{
	this.isResizePlayerEachPlay = this.checkbox_resizePlayerEachPlay.selected;
	radioGroup_resizeType.selectedValue = selectedResizeType;
	if(this.isResizePlayerEachPlay){
		this.playerController.resizePlayerJustVideoSize(this.videoPlayer.nowRatio);
		this.radioButton_resizeNicoDou.enabled = true;
		this.radioButton_resizeVideo.enabled = true;
		if(this.selectedResizeType == VideoInfoView.RESIZE_TYPE_NICO){
			this.checkbox_enableWideMode.enabled = true;
		}else{
			this.checkbox_enableWideMode.enabled = false;
		}
	}else{
		this.videoPlayer.nowRatio = -1;
		this.radioButton_resizeNicoDou.enabled = false;
		this.radioButton_resizeVideo.enabled = false;
		this.checkbox_enableWideMode.enabled = false;
	}
	
}

private function checkBoxAlwaysEconomyChanged(event:Event):void{
	isAlwaysEconomyForStreaming = this.checkBox_isAlwaysEconomyForStreaming.selected;
}


private function checkBoxShowAlwaysNicowariAreaChanged(event:Event):void{
	isShowAlwaysNicowariArea = this.checkBox_showAlwaysNicowariArea.selected;
	videoPlayer.setShowAlwaysNicowariArea(isShowAlwaysNicowariArea);
}

private function checkBoxIsNotPlayNicowariChanged(event:Event):void
{
	this.isNotPlayNicowari = this.checkBox_isNotPlayNicowari.selected;
	
	if (isNotPlayNicowari)
	{
		playerController.stopNicowari();
		videoPlayer.hideNicowariArea();
	}
	else if (isShowAlwaysNicowariArea)
	{
		videoPlayer.showNicowariArea();
	}
}

public function setShowAlwaysNicowariArea(isShow:Boolean):void{
	if(this.checkBox_showAlwaysNicowariArea != null){
		this.checkBox_showAlwaysNicowariArea.selected = isShow;
	}
	isShowAlwaysNicowariArea = isShow;
}

private function checkBoxRenewCommentChanged():void{
	isRenewCommentEachPlay = checkBox_renewComment.selected;
	checkBox_renewTagAndNicowari.enabled = isRenewCommentEachPlay;
	checkBox_isAppendComment.enabled = isRenewCommentEachPlay;
}

private function checkBoxCommentBoldChanged(event:Event):void{
	this.isCommentFontBold = checkBox_commentBold.selected;
	playerController.setCommentFontBold(this.isCommentFontBold);
}

public function setRelationComboboxEnable(enabled:Boolean):void{
	if(combobox_relationSort != null){
		(combobox_relationSort as ComboBox).enabled = enabled;
	}
	if(combobox_relationOrder != null){
		(combobox_relationOrder as ComboBox).enabled = enabled;
	}
}

private function thumbPress(event:SliderEvent):void{
	this.playerController.sliderChanging = true;
}

private function thumbRelease(event:SliderEvent):void{
	this.playerController.sliderChanging = false;
	this.playerController.seek(event.value);
}

private function sliderVolumeChanged(evt:SliderEvent):void{
	this.playerController.setVolume(evt.value);	
}

private function sliderFpsChanged(event:SliderEvent):void{
	this.fps = getFps(event.value);
	this.playerController.changeFps(this.fps);
}


private function commentCountNumStepperChanged(event:NumericStepperEvent):void
{
	this.showCommentCountPerMin = event.value;
}

private function ownerCommentCountNumStepperChanged(event:NumericStepperEvent):void
{
	this.showOwnerCommentCountPerMin = event.value;
}

private function addNGListIdButtonClicked():void{
	var index:int = -1;
	if(tabNavigator_comment.selectedIndex == 0){
		index = this.dataGrid_comment.selectedIndex;
	}else if(tabNavigator_comment.selectedIndex == 1){
		index = this.dataGrid_oldComment.selectedIndex;
	}
	if(index > -1){
		this.playerController.ngListManager.addNgID(commentListProvider.getItemAt(index).user_id_column);
	}
}

private function addNGListWordButtonClicked():void{
	var index:int = -1;
	if(tabNavigator_comment.selectedIndex == 0){
		index = this.dataGrid_comment.selectedIndex;
	}else if(tabNavigator_comment.selectedIndex == 1){
		index = this.dataGrid_oldComment.selectedIndex;
	}
	if(index > -1){
		this.playerController.ngListManager.addNgWord(commentListProvider.getItemAt(index).comment_column);
	}
}

private function addPermissionIdButtonClicked():void{
	var index:int = -1;
	if(tabNavigator_comment.selectedIndex == 0){
		index = this.dataGrid_comment.selectedIndex;
	}else if(tabNavigator_comment.selectedIndex == 1){
		index = this.dataGrid_oldComment.selectedIndex;
	}
	if(index > -1){
		this.playerController.ngListManager.addPermissionId(commentListProvider.getItemAt(index).user_id_column);
	}
}

private function headerReleaseHandler(event:DataGridEvent):void{
	if(event.columnIndex == 1){
		this.isSyncComment = false;
		this.checkbox_SyncComment.selected = false;
	}
}

/**
 * TextInputに入力されているIDをNGリストに追加します
 * 
 */
private function addItemToNgList():void{
	playerController.ngListManager.addItemToNgList(textInput_ng.text, combobox_ngKind.selectedLabel);
}

private function ngListItemClicked(event:ListEvent):void{
	playerController.ngListManager.ngListItemClicked(event);
}

/**
 * 選択されているNG項目をNGリストカラ取り除きます。
 * 
 */
private function removeItemFromNgList():void{
	playerController.ngListManager.removeItemFromNgList();
}

private function ngTextInputEnter(event:FlexEvent):void{
	playerController.ngListManager.addItemToNgList(textInput_ng.text, combobox_ngKind.selectedLabel);
}

private function fpsDataTipFormatFunction(value:Number):String{
	return new String(getFps(value));
}

private function getFps(value:Number):Number{
	switch(value){
		case 1:
			return 7.5;
		case 2:
			return 15;
		case 3:
			return 30;
		case 4:
			return 60;
		case 5:
			return 120;
		default:
			return 15;
	}
}

private function getValueByFps(fps:Number):int{
	switch(fps){
		case 7.5:
			return 1;
		case 15:
			return 2;
		case 30:
			return 3;
		case 60:
			return 4;
		case 120:
			return 5;
		default:
			return 2;
	}
}

private function keyListener(event:KeyboardEvent):void{
	if(event.keyCode == Keyboard.ESCAPE){
	}else if(event.keyCode == Keyboard.F11 || (event.keyCode == Keyboard.F && (event.controlKey || event.commandKey))){
//		trace("Ctrl + " + event.keyCode);
		this.videoPlayer.changeFull();
	}else if(event.keyCode == Keyboard.C){
//		trace(event.keyCode);
		this.stage.nativeWindow.activate();
	}else if(event.keyCode == Keyboard.SPACE){
		this.playerController.play();
	}else if(event.keyCode == Keyboard.LEFT){
		//左
		if(seekTimer != null){
			seekTimer.stop();
		}
		seekTimer = new Timer(100, 1);
		seekTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
			var newValue:Number = videoPlayer.videoController.slider_timeline.value + seekValue;
			if(newValue <= (videoPlayer.videoController.slider_timeline as HSlider).minimum){
				newValue = 0;
			}else if(newValue >= (videoPlayer.videoController.slider_timeline as HSlider).maximum){
				newValue = (videoPlayer.videoController.slider_timeline as HSlider).maximum;
			}
			trace(newValue +" = "+videoPlayer.videoController.slider_timeline.value +"+"+ seekValue);
			playerController.seek(newValue);
			seekValue = 0;
		});
		seekTimer.start();
		this.seekValue -= 10;
	}else if(event.keyCode == Keyboard.RIGHT){
		//右
		if(seekTimer != null){
			seekTimer.stop();
		}
		seekTimer = new Timer(100, 1);
		seekTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:Event):void{
			var newValue:Number = videoPlayer.videoController.slider_timeline.value + seekValue;
			if(newValue <= (videoPlayer.videoController.slider_timeline as HSlider).minimum){
				newValue = 0;
			}else if(newValue >= (videoPlayer.videoController.slider_timeline as HSlider).maximum){
				newValue = (videoPlayer.videoController.slider_timeline as HSlider).maximum;
			}
			trace(newValue +" = "+videoPlayer.videoController.slider_timeline.value +"+"+ seekValue);
			playerController.seek(newValue);
			seekValue = 0;
		});
		seekTimer.start();
		this.seekValue += 10;
	}else if(event.keyCode == Keyboard.UP){
		this.playerController.setVolume(this.videoPlayer.videoController.slider_volume.value + 0.05);
	}else if(event.keyCode == Keyboard.DOWN){
		this.playerController.setVolume(this.videoPlayer.videoController.slider_volume.value - 0.05);
	}
}

private function radioButtonResizeTypeChanged(event:Event):void{
	this.selectedResizeType = int(RadioButton(event.currentTarget).value);
	
	if(this.selectedResizeType == VideoInfoView.RESIZE_TYPE_NICO){
		this.checkbox_enableWideMode.enabled = true;
	}else{
		this.checkbox_enableWideMode.enabled = false;
	}
	
	this.playerController.resizePlayerJustVideoSize(this.videoPlayer.nowRatio);
}

private function checkboxEnableWideModeChanged(event:Event):void{
	this.isEnableWideMode = event.target.selected;
	this.playerController.resizePlayerJustVideoSize(this.videoPlayer.nowRatio);
}

private function checkBox_repeatAllCompleteHandler(event:FlexEvent):void{
	checkBox_repeatAll.selected = isPlayListRepeat;
}

private function checkBoxIsSOPCChanged(event:MouseEvent):void{
	isShowOnlyPermissionComment = checkBox_isShowOnlyPermissionComment.selected;
	if(this.playerController != null){
		this.playerController.reloadLocalComment();
	}
}

private function checkBoxRenewTagNicowariChanged():void{
	isRenewOtherCommentWithCommentEachPlay = checkBox_renewTagAndNicowari.selected;
}

private function checkBoxIsEnableJump(event:MouseEvent):void{
	isEnableJump = event.currentTarget.selected;
	(checkBox_askToUserOnJump as CheckBox).enabled = isEnableJump;
}

private function checkBoxIsAskToUserOnJump(event:MouseEvent):void{
	isAskToUserOnJump = event.currentTarget.selected;
}

private function checkBoxHideSekaShinComment(event:MouseEvent):void{
	isHideSekaShinComment = event.currentTarget.selected;
	
	if(this.playerController != null){
		this.playerController.reloadLocalComment();
	}
}

private function commentListDoubleClicked(event:ListEvent):void{
	var time:String = event.target.selectedItem.vpos_column;
	
	var min:int = int(time.substring(0,time.indexOf(":")));
	var sec:int = int(time.substring(time.indexOf(":")+1));
	
	if(playerController.windowType == PlayerController.WINDOW_TYPE_FLV){
		this.playerController.seek(min*60 + sec);
	}else{
		this.playerController.seek((min*60 + sec)*playerController.swfFrameRate);
	}
}

private function ichibaDataGridDoubleClicked(event:ListEvent):void{
	trace((event.currentTarget as DataGrid).dataProvider[event.rowIndex].col_link);
	var url:String = (event.currentTarget as DataGrid).dataProvider[event.rowIndex].col_link;
	if(url != null){
		navigateToURL(new URLRequest(url));
	}
}

private function commentScaleSliderChanged(event:SliderEvent):void{
	this.commentScale = event.value;
	this.playerController.windowResized(true);
}

private function sliderShowCommentTimeChanged(event:SliderEvent):void{
	this.showCommentSec = event.value;
}

private function sliderCommentAlphaChanged(event:SliderEvent):void{
	this.commentAlpha = event.value;
	playerController.getCommentManager().setCommentAlpha(this.commentAlpha/100);
}

private function myDataTipFormatFunction(value:Number):String{
	var nowSec:String="00",nowMin:String="0";
	nowSec = String(int(value%60));
	nowMin = String(int(value/60));
	
	if(nowSec.length == 1){
		nowSec = "0" + nowSec; 
	}
	if(nowMin.length == 1){
		nowMin = "0" + nowMin;
	}
	return nowMin + ":" + nowSec;
}

private function windowCompleteHandler():void{
	
	videoPlayer.alwaysInFront = videoPlayer.isAlwaysFront;
	this.alwaysInFront = this.isInfoViewAlwaysFront;
	
//	checkbox_repeat.selected = isRepeat;
//	checkbox_showComment.selected = isShowComment;
	checkbox_SyncComment.selected = isSyncComment;
	checkBox_isShowOnlyPermissionComment.selected = isShowOnlyPermissionComment;
	checkbox_showHtml.selected = isShowHTMLOwnerComment;
	
	videoPlayer.setShowAlwaysNicowariArea(isShowAlwaysNicowariArea);
	playerController.setCommentFontBold(this.isCommentFontBold);
	
	videoPlayer.showUnderController(!isHideUnderController, true);
	videoPlayer.showTagArea(!isHideTagArea, true);
	
	this.setStyle("fontFamily", ConfigManager.getInstance().getItem("fontFamily"));
	this.setStyle("fontSize", Number(ConfigManager.getInstance().getItem("fontSize")));
}

private function comboboxRelationOrderCreationCompleteHandler(event:FlexEvent):void
{
	combobox_relationOrder.selectedIndex = relationOrderIndex;
}

private function comboboxRelationSortCreationCompleteHandler(event:FlexEvent):void
{
	combobox_relationSort.selectedIndex = relationSortIndex;
}

private function relationSortComboboxChange(event:Event):void{
	relationSortIndex = combobox_relationSort.selectedIndex;
	playerController.setNicoRelationInfoForRelationSortTypeChange();
}

private function relationOrderComboboxChange(event:Event):void{
	relationOrderIndex = combobox_relationOrder.selectedIndex;
	playerController.setNicoRelationInfoForRelationSortTypeChange();
}

private function playerQualitySliderChanged(event:Event):void{
	playerQuality = slider_playerQuality.value;
	
	if(playerController != null){
		playerController.setPlayerQuality(playerQuality);
	}
}

private function configCanvas1CreationCompleteHandler(event:FlexEvent):void{
	checkbox_resizePlayerEachPlay.selected = isResizePlayerEachPlay;
	
	radioGroup_resizeType.selectedValue = selectedResizeType;
	if(isResizePlayerEachPlay){
		radioButton_resizeNicoDou.enabled = true;
		radioButton_resizeVideo.enabled = true;
	}else{
		radioButton_resizeNicoDou.enabled = false;
		radioButton_resizeVideo.enabled = false;
	}
	
	checkbox_enableWideMode.selected = isEnableWideMode;
	checkBox_isSmoothing.selected = isSmoothing;
	checkBox_isSmoothingOnlyNotPixelIdenticalDimensions.enabled = isSmoothing;
	checkBox_isSmoothingOnlyNotPixelIdenticalDimensions.selected = isSmoothingOnlyNotPixelIdenticalDimensions;
	
	if(playerController.getCommentManager() != null){
		playerController.getCommentManager().setAntiAlias(isAntiAlias);
	}
	
	checkBox_isAlwaysEconomyForStreaming.selected = isAlwaysEconomyForStreaming;
	
	slider_playerQuality.value = playerQuality;
	
}

private function configCanvas2CreationCompleteHandler(event:FlexEvent):void{
	checkBox_commentBold.selected = isCommentFontBold;
	checkBox_hideSekaShinComment.selected = isHideSekaShinComment;
	checkBox_isNgUpEnable.selected = isNgUpEnable;
	
	slider_commentScale.value = commentScale;
	slider_fps.value = getValueByFps(fps);
	
	commentNumStepper.value = showCommentCountPerMin;
	ownerCommentNumStepper.value = showOwnerCommentCountPerMin;
	
	slider_showCommentTime.value = showCommentSec;
	slider_commentAlpha.value = commentAlpha;
	
	
}

private function configCanvas3CreationCompleteHandler(event:FlexEvent):void{
	checkbox_PlayerAlwaysFront.selected = videoPlayer.isAlwaysFront;
	checkbox_InfoViewAlwaysFront.selected = isInfoViewAlwaysFront;
	
	checkbox_playerFollow.selected = isPlayerFollow;
	checkBox_renewComment.selected = isRenewCommentEachPlay;
	checkBox_renewTagAndNicowari.selected = isRenewOtherCommentWithCommentEachPlay;
	checkBox_renewTagAndNicowari.enabled = isRenewCommentEachPlay;
	
	isAppendComment = FlexGlobals.topLevelApplication.getAppendComment();
	checkBox_isAppendComment.selected = isAppendComment;
	checkBox_isAppendComment.enabled = isRenewCommentEachPlay;
	
	checkbox_followInfoViewHeight.selected = isFollowInfoViewHeight;
	
	checkBox_isNotPlayNicowari.selected = isNotPlayNicowari;
	checkBox_showAlwaysNicowariArea.selected = isShowAlwaysNicowariArea;
	checkbox_hideTagArea.selected = isHideTagArea;
	checkbox_hideUnderController.selected = isHideUnderController;
	
	checkBox_enableJump.selected = isEnableJump;
	checkBox_askToUserOnJump.selected = isAskToUserOnJump;
	checkBox_askToUserOnJump.enabled = isEnableJump;
	
	
}


public function isRepeatAll():Boolean{
	return this.isPlayListRepeat;
}

private function windowResized(event:NativeWindowBoundsEvent):void{
	lastRect = event.afterBounds;
}

private function windowMove(event:NativeWindowBoundsEvent):void{
	lastRect = event.afterBounds;
}

public function playListDoubleClicked():void{
	if(playListProvider.length > 0){
		var url:String = videoUrlMap[playListProvider[dataGrid_playList.selectedIndex]];
		playerController.initForVideoPlayer(url, dataGrid_playList.selectedIndex);
	}
}

/**
 * 指定された番号のコメントをコメントリストで選択された状態にします。
 * 
 */
public function selectComment(no:Number):void{
	
	for(var i:int = 0; i<commentListProvider.length; i++){
		if(commentListProvider[i].no_column == no){
			(dataGrid_comment as DataGrid).selectedIndex = i;
			
			return;
		}
	}
	
}

private function readStore():void{
	
	try{
		/*ローカルストアから値の呼び出し*/
		
		var confValue:String = null;
		confValue = ConfigManager.getInstance().getItem("isPlayListRepeat");
		if (confValue == null) {
			//何もしない
		}else{
			isPlayListRepeat = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isSyncComment");
		if (confValue == null) {
			//何もしない
		}else{
			isSyncComment = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isPlayerFollow");
		if (confValue == null) {
			//何もしない
		}else{
			isPlayerFollow = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isRenewCommentEachPlay");
		if (confValue == null) {
			//何もしない
		}else{
			isRenewCommentEachPlay = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isResizePlayerEachPlay");
		if (confValue == null) {
			//何もしない
		}else{
			isResizePlayerEachPlay = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isHideUnderController");
		if (confValue == null) {
			//何もしない
		}else{
			isHideUnderController = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("commentScale");
		if (confValue == null) {
			//何もしない
		}else{
			commentScale = Number(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("commentFps");
		if (confValue == null) {
			//何もしない
		}else{
			this.fps = Number(confValue);
			this.playerController.changeFps(this.fps);
		}
		
		confValue = ConfigManager.getInstance().getItem("isShowOnlyPermissionComment");
		if (confValue == null) {
			//何もしない
		}else{
			isShowOnlyPermissionComment = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("showCommentCount");
		if (confValue == null) {
			//何もしない
		}else{
			showCommentCountPerMin = int(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("showOwnerCommentCount");
		if (confValue == null) {
			showOwnerCommentCountPerMin = showCommentCountPerMin;
		}else{
			showOwnerCommentCountPerMin = int(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("showCommentSec");
		if (confValue == null) {
			//何もしない
		}else{
			showCommentSec = int(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isRenewOtherCommentWithCommentEachPlay");
		if (confValue == null) {
			//何もしない
		}else{
			isRenewOtherCommentWithCommentEachPlay = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isAntiAlias");
		if (confValue == null) {
			//何もしない
		}else{
			isAntiAlias = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("commentAlpha");
		if (confValue == null) {
			//何もしない
		}else{
			commentAlpha = int(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isEnableJump");
		if (confValue == null) {
			//何もしない
		}else{
			isEnableJump = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isAskToUserOnJump");
		if (confValue == null) {
			//何もしない
		}else{
			isAskToUserOnJump = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isInfoViewAlwaysFront");
		if (confValue == null) {
			//何もしない
		}else{
			isInfoViewAlwaysFront = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("selectedResizeType");
		if (confValue == null) {
			//何もしない
		}else{
			selectedResizeType = int(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isCommentFontBold");
		if (confValue == null) {
			//何もしない
		}else{
			isCommentFontBold = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isShowAlwaysNicowariArea");
		if (confValue == null) {
			//何もしない
		}else{
			isShowAlwaysNicowariArea = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isHideTagArea");
		if (confValue == null) {
			//何もしない
		}else{
			isHideTagArea = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isAlwaysEconomyForStreaming");
		if (confValue == null) {
			//何もしない
		}else{
			isAlwaysEconomyForStreaming = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isAppendComment");
		if (confValue == null) {
			//何もしない
		}else{
			isAppendComment = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isHideSekaShinComment");
		if (confValue == null) {
			//何もしない
		}else{
			isHideSekaShinComment = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isShowHTMLOwnerComment");
		if (confValue == null) {
			//何もしない
		}else{
			isShowHTMLOwnerComment = ConfUtil.parseBoolean(confValue);
		}
		
		//x,y,w,h
		confValue = ConfigManager.getInstance().getItem("controllerWindowPosition_x");
		var controllerPosition_x:Number = 0;
		if (confValue == null) {
			//何もしない
		}else{
			controllerPosition_x = Number(confValue);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
				nativeWindow.x = lastRect.x = controllerPosition_x;
			});
		}
		
		confValue = ConfigManager.getInstance().getItem("controllerWindowPosition_y");
		var controllerPosition_y:Number = 0;
		if (confValue == null) {
			//何もしない
		}else{
			controllerPosition_y = Number(confValue);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
				nativeWindow.y = lastRect.y = controllerPosition_y;
			});
		}
		
		confValue = ConfigManager.getInstance().getItem("controllerWindowPosition_w");
		var controllerPosition_w:Number = 380;
		if (confValue == null) {
			//何もしない
		}else{
			controllerPosition_w = Number(confValue);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
				nativeWindow.width = lastRect.width = controllerPosition_w;
			});
		}
		
		confValue = ConfigManager.getInstance().getItem("controllerWindowPosition_h");
		var controllerPosition_h:Number = 520;
		if (confValue == null) {
			//何もしない
		}else{
			controllerPosition_h = Number(confValue);
			this.addEventListener(FlexEvent.CREATION_COMPLETE, function():void{
				nativeWindow.height = lastRect.height = controllerPosition_h;
			});
		}
		
		confValue = ConfigManager.getInstance().getItem("isEnableWideMode");
		if(confValue == null){
			//何もしない
			isEnableWideMode = true;
		}else{
			isEnableWideMode = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("relationSortIndex");
		if(confValue == null){
			//何もしない
		}else{
			relationSortIndex = int(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("relationOrderIndex");
		if(confValue == null){
			//何もしない
		}else{
			relationOrderIndex = int(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isNgUpEnable");
		if(confValue == null){
			// 何もしない
		}else{
			isNgUpEnable = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isSmoothing");
		if(confValue != null){
			isSmoothing = ConfUtil.parseBoolean(confValue);
		}
		if(playerController != null){
			playerController.setVideoSmoothing(this.isSmoothing);
		}
		
		confValue = ConfigManager.getInstance().getItem("isSmoothingOnlyNotPixelIdenticalDimensions");
		if(confValue != null){
			isSmoothingOnlyNotPixelIdenticalDimensions = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("playerQuality");
		if(confValue != null){
			playerQuality = int(confValue);
		}
		if(playerController != null){
			playerController.setPlayerQuality(this.playerQuality);
		}
		
		confValue = ConfigManager.getInstance().getItem("isEnableWideMode");
		if(confValue != null){
			isEnableWideMode = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isFollowInfoViewHeight");
		if (confValue != null)
		{
			isFollowInfoViewHeight = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isNotPlayNicowari");
		if (confValue != null)
		{
			isNotPlayNicowari = ConfUtil.parseBoolean(confValue);
		}
		
		confValue = ConfigManager.getInstance().getItem("isOpenFileDialogWhenOpenPlayer");
		if (confValue != null)
		{
			this.isOpenFileDialogWhenOpenPlayer = ConfUtil.parseBoolean(confValue);
		}
		
	}catch(error:Error){
		trace(error.getStackTrace());
		Alert.show(Message.M_CONF_FILE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.FAIL_LOAD_CONF_FILE_FOR_VIDEO_INFO_VIEW + ":" + Message.M_CONF_FILE_IS_BROKEN + ":" + ConfigManager.getInstance().confFileNativePath + ":" + error);
	}
	
}

public function saveStore():void{
	
	try{
		
		trace("saveStore_videoInfoView");
		
		/*ローカルストアに値を保存*/
		ConfigManager.getInstance().removeItem("isPlayListRepeat");
		ConfigManager.getInstance().setItem("isPlayListRepeat", isPlayListRepeat);
		
		ConfigManager.getInstance().removeItem("isSyncComment");
		ConfigManager.getInstance().setItem("isSyncComment", isSyncComment);
		
		ConfigManager.getInstance().removeItem("isPlayerFollow");
		ConfigManager.getInstance().setItem("isPlayerFollow", isPlayerFollow);
		
		ConfigManager.getInstance().removeItem("isRenewCommentEachPlay");
		ConfigManager.getInstance().setItem("isRenewCommentEachPlay", isRenewCommentEachPlay);
		
		ConfigManager.getInstance().removeItem("isResizePlayerEachPlay");
		ConfigManager.getInstance().setItem("isResizePlayerEachPlay", isResizePlayerEachPlay);
		
		ConfigManager.getInstance().removeItem("isHideUnderController");
		ConfigManager.getInstance().setItem("isHideUnderController", isHideUnderController);
		
		// ウィンドウの位置情報保存
		ConfigManager.getInstance().removeItem("controllerWindowPosition_x");
		ConfigManager.getInstance().setItem("controllerWindowPosition_x", lastRect.x);
		
		ConfigManager.getInstance().removeItem("controllerWindowPosition_y");
		ConfigManager.getInstance().setItem("controllerWindowPosition_y", lastRect.y);
		
		ConfigManager.getInstance().removeItem("controllerWindowPosition_w");
		ConfigManager.getInstance().setItem("controllerWindowPosition_w", lastRect.width);
		
		ConfigManager.getInstance().removeItem("controllerWindowPosition_h");
		ConfigManager.getInstance().setItem("controllerWindowPosition_h", lastRect.height);
		
		ConfigManager.getInstance().removeItem("commentScale");
		ConfigManager.getInstance().setItem("commentScale", commentScale);
		
		ConfigManager.getInstance().removeItem("commentFps");
		ConfigManager.getInstance().setItem("commentFps", fps);
		
		ConfigManager.getInstance().removeItem("isShowOnlyPermissionComment");
		ConfigManager.getInstance().setItem("isShowOnlyPermissionComment", isShowOnlyPermissionComment);
		
		ConfigManager.getInstance().removeItem("showCommentCount");
		ConfigManager.getInstance().setItem("showCommentCount", showCommentCountPerMin);
		
		ConfigManager.getInstance().removeItem("showOwnerCommentCount");
		ConfigManager.getInstance().setItem("showOwnerCommentCount", showOwnerCommentCountPerMin);
		
		ConfigManager.getInstance().removeItem("showCommentSec");
		ConfigManager.getInstance().setItem("showCommentSec", showCommentSec);
		
		ConfigManager.getInstance().removeItem("isRenewOtherCommentWithCommentEachPlay");
		ConfigManager.getInstance().setItem("isRenewOtherCommentWithCommentEachPlay", isRenewOtherCommentWithCommentEachPlay);
		
		ConfigManager.getInstance().removeItem("isAntiAlias");
		ConfigManager.getInstance().setItem("isAntiAlias", isAntiAlias);
		
		ConfigManager.getInstance().removeItem("commentAlpha");
		ConfigManager.getInstance().setItem("commentAlpha", commentAlpha);
		
		ConfigManager.getInstance().removeItem("isEnableJump");
		ConfigManager.getInstance().setItem("isEnableJump", isEnableJump);
		
		ConfigManager.getInstance().removeItem("isAskToUserOnJump");
		ConfigManager.getInstance().setItem("isAskToUserOnJump", isAskToUserOnJump);
		
		ConfigManager.getInstance().removeItem("isInfoViewAlwaysFront");
		ConfigManager.getInstance().setItem("isInfoViewAlwaysFront", isInfoViewAlwaysFront);
		
		ConfigManager.getInstance().removeItem("selectedResizeType");
		ConfigManager.getInstance().setItem("selectedResizeType", selectedResizeType);
		
		ConfigManager.getInstance().removeItem("isCommentFontBold");
		ConfigManager.getInstance().setItem("isCommentFontBold", isCommentFontBold);
		
		ConfigManager.getInstance().removeItem("isShowAlwaysNicowariArea");
		ConfigManager.getInstance().setItem("isShowAlwaysNicowariArea", isShowAlwaysNicowariArea);
		
		ConfigManager.getInstance().removeItem("isAlwaysEconomyForStreaming");
		ConfigManager.getInstance().setItem("isAlwaysEconomyForStreaming", isAlwaysEconomyForStreaming);
		
		ConfigManager.getInstance().removeItem("isHideTagArea");
		ConfigManager.getInstance().setItem("isHideTagArea", isHideTagArea);
		
		ConfigManager.getInstance().removeItem("isAppendComment");
		ConfigManager.getInstance().setItem("isAppendComment", isAppendComment);
		
		ConfigManager.getInstance().removeItem("isHideSekaShinComment");
		ConfigManager.getInstance().setItem("isHideSekaShinComment", isHideSekaShinComment);
		
		ConfigManager.getInstance().removeItem("isShowHTMLOwnerComment");
		ConfigManager.getInstance().setItem("isShowHTMLOwnerComment", isShowHTMLOwnerComment);
		
		ConfigManager.getInstance().removeItem("isEnableWideMode");
		ConfigManager.getInstance().setItem("isEnableWideMode", isEnableWideMode);
		
		ConfigManager.getInstance().removeItem("relationSortIndex");
		ConfigManager.getInstance().setItem("relationSortIndex", relationSortIndex);
		
		ConfigManager.getInstance().removeItem("relationOrderIndex");
		ConfigManager.getInstance().setItem("relationSortIndex", relationSortIndex);
		
		ConfigManager.getInstance().removeItem("isNgUpEnable");
		ConfigManager.getInstance().setItem("isNgUpEnable", isNgUpEnable);
		
		ConfigManager.getInstance().removeItem("isSmoothing");
		ConfigManager.getInstance().setItem("isSmoothing",isSmoothing);
		
		ConfigManager.getInstance().removeItem("isSmoothingOnlyNotPixelIdenticalDimensions");
		ConfigManager.getInstance().setItem("isSmoothingOnlyNotPixelIdenticalDimensions", isSmoothingOnlyNotPixelIdenticalDimensions);
		
		ConfigManager.getInstance().removeItem("playerQuality");
		ConfigManager.getInstance().setItem("playerQuality", playerQuality);
		
		ConfigManager.getInstance().removeItem("isEnableWideMode");
		ConfigManager.getInstance().setItem("isEnableWideMode", isEnableWideMode);
		
		ConfigManager.getInstance().removeItem("isFollowInfoViewHeight");
		ConfigManager.getInstance().setItem("isFollowInfoViewHeight", isFollowInfoViewHeight);
		
		ConfigManager.getInstance().removeItem("isNotPlayNicowari");
		ConfigManager.getInstance().setItem("isNotPlayNicowari", isNotPlayNicowari);
		
		
		/* DataGridの列幅保存 */
		if (dataGrid_comment != null)
		{
			DataGridColumnWidthUtil.save(dataGrid_comment, new Vector.<String>("mail_column"));
		}
		
		if (dataGrid_oldComment != null)
		{
			DataGridColumnWidthUtil.save(dataGrid_oldComment, new Vector.<String>("mail_column"));
		}
		
		ConfigManager.getInstance().removeItem("isOpenFileDialogWhenOpenPlayer");
		ConfigManager.getInstance().setItem("isOpenFileDialogWhenOpenPlayer", isOpenFileDialogWhenOpenPlayer);
		
		ConfigManager.getInstance().save();
		
	}catch(error:Error){
		Alert.show(Message.M_CONF_FILE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.FAIL_SAVE_CONF_FILE_FOR_VIDEO_INFO_VIEW + ":" + Message.M_CONF_FILE_IS_BROKEN + ":" + ConfigManager.getInstance().confFileNativePath + ":" + error);
		trace(error.getStackTrace());
	}
	
}

public function resetWindowPosition():void{
	// ウィンドウの位置情報保存
	try{
		
		// ウィンドウの位置情報保存を初期値で上書き
		ConfigManager.getInstance().removeItem("controllerWindowPosition_x");
		ConfigManager.getInstance().setItem("controllerWindowPosition_x", 0);
		
		ConfigManager.getInstance().removeItem("controllerWindowPosition_y");
		ConfigManager.getInstance().setItem("controllerWindowPosition_y", 0);
		
		ConfigManager.getInstance().removeItem("controllerWindowPosition_w");
		ConfigManager.getInstance().setItem("controllerWindowPosition_w", 400);
		
		ConfigManager.getInstance().removeItem("controllerWindowPosition_h");
		ConfigManager.getInstance().setItem("controllerWindowPosition_h", 580);
		
		ConfigManager.getInstance().save();
		
		this.readStore();
		
	}catch(error:Error){
		Alert.show(Message.M_CONF_FILE_IS_BROKEN, Message.M_ERROR);
		logManager.addLog(Message.FAIL_SAVE_CONF_FILE_FOR_VIDEO_INFO_VIEW + ":" + Message.M_CONF_FILE_IS_BROKEN + ":" + ConfigManager.getInstance().confFileNativePath + ":" + error);
		trace(error.getStackTrace());
	}
	
	if(this.nativeWindow != null && !(this as Window).closed){
		
		this.visible = true;
		
		this.nativeWindow.x = 0;
		this.nativeWindow.y = 0;
		
		this.width = 380;
		this.height = 520;
	}
}

/**
 * 
 * @param urlList
 * @param videoNameList
 * @param playListName
 */
public function setPlayList(urlList:Array, videoNameList:Array, playListName:String):void{
	
	this.playListName = playListName;
	label_playListTitle_dataProvider = playListName;
	
	for each(var title:String in videoNameList){
		playListProvider.addItem(title);
	}
	
	for(var index:int = 0; index<urlList.length; index++){
		videoUrlMap[videoNameList[index]] = urlList[index];
	}
	
	if(this.dataGrid_playList != null){
//		(dataGrid_playList as DataGrid).validateDisplayList();
	}
}

/**
 * 
 * @param url
 * @param title
 * 
 */
public function addPlayListItem(url:String, title:String):void{
	
	videoUrlMap[title] = url;
	
}

/**
 * 
 * @param url
 * @param title
 * @param index
 * 
 */
public function addPlayListItemWithList(url:String, title:String, index:int):void{
	playListProvider.addItemAt(title,index);
	
	addPlayListItem(url, title);
	
	if(this.dataGrid_playList != null){
		(dataGrid_playList as DataGrid).dataProvider = playListProvider;
		(dataGrid_playList as DataGrid).validateDisplayList();
	}
	
}


/**
 * 
 * @param title
 * @param index
 * 
 */
public function removePlayListItem(index:int):void{
	var title:String = String(playListProvider.removeItemAt(index));
	
	//同名のファイルが存在しないかどうかチェック
	for each(var videoName:String in playListProvider){
		if(title == videoName){
			//存在するならvideoUrlMapからは消さない
			return;
		}
	}
	//存在しないならvideoUrlMapから消す
	videoUrlMap[title] = null;
	
	if(this.dataGrid_playList != null){
		(dataGrid_playList as DataGrid).dataProvider = playListProvider;
		(dataGrid_playList as DataGrid).validateDisplayList();
	}
}

/**
 * 
 * @return 
 * 
 */
public function getPlayList():Array{
	var array:Array = new Array();
	for(var i:int = 0; i<playListProvider.length; i++){
		array.push(String(playListProvider[i]));
	}
	
	var returnArray:Array = new Array();
	
	for each(var title:String in array){
		returnArray.push(videoUrlMap[title]);
	}
	
	return returnArray;
}

/**
 * プレイリスト内の項目の名前一覧を返します。
 * @return 
 * 
 */
public function getNameList():Array{
	var array:Array = new Array();
	for(var i:int = 0; i<playListProvider.length; i++){
		array.push(String(playListProvider[i]));
	}
	
	return array;
}

/**
 * 
 * 
 */
public function resetPlayList():void{
	this.playListName = "";
	if(label_playListTitle != null){
		label_playListTitle.text = playListName;
	}else{
		canvas_videoInfo.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
			canvas_playList.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
				label_playListTitle.text = playListName;
			});
		});
	}
	
	videoUrlMap = new Object();
	
	playListProvider.removeAll();
	
	if(this.dataGrid_playList != null){
		(dataGrid_playList as DataGrid).dataProvider = playListProvider;
		(dataGrid_playList as DataGrid).validateDisplayList();
		(dataGrid_playList as DataGrid).validateNow();
	}
}

/**
 * プレイリストをシャッフルします
 * 
 * @details edvakf氏のソースをマージ
 * @see https://github.com/edvakf/NNDDMOD/commit/6984ba8919727a98c249e1bc8a4848705de27df5
 */
public function shufflePlayList():void{
	
	var selectedObject:Object = null;
	if (dataGrid_playList != null)
	{
		selectedObject = dataGrid_playList.selectedItem;
	}
	
	var tempArrayCollection:ArrayCollection = new ArrayCollection();
	for each(var object:Object in playListProvider){
		tempArrayCollection.addItem(object);
	}
	var i:int = tempArrayCollection.length;
	while (--i) {
		var j:int = Math.floor( Math.random() * (i + 1) );
		if (i == j) {
			continue;
		}
		var object:Object = tempArrayCollection.getItemAt(i);
		tempArrayCollection.setItemAt( tempArrayCollection.getItemAt(j), i );
		tempArrayCollection.setItemAt( object, j );
	}
	playListProvider = tempArrayCollection;
	
	if (dataGrid_playList != null && selectedObject != null)
	{
		dataGrid_playList.selectedItem = selectedObject;
	}
}

/**
 * 
 * @param index
 * @return 
 * 
 */
public function getPlayListUrl(index:int):String{
	var videoTitle:String = playListProvider[index];
	
	return videoUrlMap[videoTitle];
}

/**
 * 
 * @param event
 * 
 */
public function playListDragDropHandler(event:DragEvent):void{
	if(event.dragInitiator == dataGrid_playList){
		
		//何もしない(デフォルトの並べ替えのみ実行)
		
	}else{
		
		//DataGridからのDrag。中身を詰め替える。
		
		if(event.dragInitiator as DataGrid){
			var selectedItems:Array = (event.dragInitiator as DataGrid).selectedItems;
			var addItems:Array = new Array();
			
			for(var i:int=0; i<selectedItems.length; i++){
				
				//ライブラリの場合
				var url:String = selectedItems[i].dataGridColumn_videoPath;
				if(url == null || url == ""){
					//ランキング or 検索でvideoPathが空だった場合
					url = selectedItems[i].dataGridColumn_nicoVideoUrl;
					
					if(url == null || url == ""){
						//マイリストだったとき
						url = selectedItems[i].dataGridColumn_videoLocalPath;
						
						if(url == null || url == ""){
							//マイリストでvideoLocalPathが空だったとき
							url = selectedItems[i].dataGridColumn_videoUrl;
							
							if(url == null || url == ""){
								//いずれでもない。
								continue;
							}
						}
					}
				}
				
				var title:String = selectedItems[i].dataGridColumn_videoName;
				var index:int = title.indexOf("\n");
				if(index != -1){
					//タイトルに改行が含まれている場合は改行の前を取得
					title = title.substring(0, index);
				}
				
				addItems.push(title);
				addPlayListItem(url, title);
			}
			
		}
		
		event.dragSource = new DragSource();
		event.dragSource.addData(addItems, "items");
	}
}

/**
 * 
 * @param event
 * 
 */
public function playListClearButtonClicked(event:MouseEvent):void{
	resetPlayList();
}

public function playListShuffleButtonClicked(event:MouseEvent):void{
	shufflePlayList();
}

/**
 * 
 * @param event
 * 
 */
public function playListItemDeleteButtonClicked(event:MouseEvent):void{
	var selectedIndices:Array =  (dataGrid_playList as DataGrid).selectedIndices;
	
	for(var index:int = selectedIndices.length; index != 0; index--){
		removePlayListItem(selectedIndices[index-1]);
	}
}

/**
 * 
 * @param event
 * 
 */
public function playListSaveButtonClicked(event:MouseEvent):void{
	//1.プレイリストのファイルを物理的に追加（or置き換え）
	//2.プレイリストの一覧を再読み込み
	//3.プレイリストを再読み込み
	var urlArray:Array = new Array();
	var nameArray:Array = new Array();
	for each(var name:String in playListProvider){
		urlArray.push(videoUrlMap[name]);
		nameArray.push(name);
	}
	
	var isExist:Boolean = false;
	if(playListName != null){
		var playList:PlayList = PlayListManager.instance.isExist(playListName);
		
		if(playList != null){
			isExist = true;
		}
	}
	
	if(!isExist){
		// 存在しないので追加
		playerController.addNewPlayList(urlArray, nameArray);
	}else{
		FlexGlobals.topLevelApplication.activate();
		Alert.show("既存のプレイリスト(" + playListName + ")を上書きしますか？\n（「いいえ」を選択すると新しいプレイリストを作成します。）", Message.M_MESSAGE, Alert.YES | Alert.NO | Alert.CANCEL, null, function(event:CloseEvent):void{
			if(event.detail == Alert.YES){
				// 上書き
				playerController.updatePlayList(playListName, urlArray, nameArray);
			}else if(event.detail == Alert.NO){
				// 別名で追加
				var title:String = playerController.addNewPlayList(urlArray, nameArray);
				label_playListTitle_dataProvider = title;
			}else{
				
			}
		});
		
	}
	
}

/**
 * 
 * @param index
 * 
 */
public function showPlayingTitle(index:int):void{
	if(dataGrid_playList != null){
		(dataGrid_playList as DataGrid).scrollToIndex(index);
		(dataGrid_playList as DataGrid).selectedIndex = index;
	}else{
		canvas_playList.addEventListener(FlexEvent.CREATION_COMPLETE, function(event:FlexEvent):void{
			(dataGrid_playList as DataGrid).scrollToIndex(index);
			(dataGrid_playList as DataGrid).selectedIndex = index;
		});
	}
}

/**
 * 
 * @param event
 * 
 */
public function tagListDoubleClickEventHandler(event:ListEvent):void{
	if(event.itemRenderer.data != null){
		if(event.itemRenderer.data is String){
			var word:String = String(event.itemRenderer.data);
			Application.application.search(new SearchItem(word, 
				SearchSortString.convertSortTypeFromIndex(4), SearchType.TAG, word));
		}
	}
}

/**
 * 
 * @param event
 * 
 */
public function button_goToWebClicked(event:Event):void{
	this.playerController.watchOnWeb();
}

/**
 * 
 * @param event
 * 
 */
public function tweet(event:Event):void{
	this.playerController.tweet();
}

/**
 * 
 * @param event
 * 
 */
public function addHatenaBookmark(event:Event):void{
	this.playerController.addHatenaBookmark();
}

/**
 * 
 * @param event
 * 
 */
public function openNicoSound(event:Event):void{
	this.playerController.openNicoSound();
}

/**
 * 
 * @param event
 * 
 */
public function openNicomimi(event:Event):void{
	this.playerController.openNicomimi();
}

/**
 * 
 * @param event
 * 
 */
public function button_addDownloadList(event:Event):void{
	
	this.playerController.addDlList();

}

/**
 * 
 * @param event
 * 
 */
public function myListAddButtonClicked(event:Event):void{
	var selectedItem:Object = comboBox_mylist.selectedItem;
	
	if(selectedItem != null){
		var name:String = String(selectedItem);
		this.playerController.addMyList(myListMap[name]);
	
	}else{
		
	}
}

/**
 * 
 * @param myListNames
 * @param myListNums
 * 
 */
public function setMyLists(myListNames:Array, myListNums:Array):void{
	
	var selectedIndex:int = comboBox_mylist.selectedIndex;
	var selectedName:String = myListDataProvider[selectedIndex];
	
	myListDataProvider = new Array();
	for(var i:int = 0; i<myListNames.length; i++){
		myListMap[myListNames[i]] = myListNums[i];
		myListDataProvider[i] = myListNames[i];
		if(selectedName == myListDataProvider[i]){
			selectedIndex = i;
		}
	}
	
	comboBox_mylist.dataProvider = myListDataProvider;
	
	if(myListDataProvider.length >= 1){
		comboBox_mylist.selectedIndex = 0;
	}
	
	comboBox_mylist.validateNow();
	
	if(selectedIndex == -1){
		var value:Object = ConfigManager.getInstance().getItem("infoViewSelectedMyListIndex");
		if(value != null){
			selectedIndex = int(value);
		}else{
			selectedIndex = 0;
		}
	}
	comboBox_mylist.selectedIndex = selectedIndex;
	
}

private function ownerTextLinkClicked(event:TextEvent):void{
	if (event.text.indexOf("mylist/") != -1)
	{
//		trace(event.text);
		FlexGlobals.topLevelApplication.renewMyList(event.text);
	}else if (event.text.indexOf("channel/") != -1)
	{
		FlexGlobals.topLevelApplication.renewMyList(event.text);
	}else if (event.text.indexOf("watch/") != -1)
	{
		var videoId:String = PathMaker.getVideoID(event.text);
//		trace(videoId);
		playerController.playMovie("http://www.nicovideo.jp/watch/" + videoId);
	}else
	{
		trace(event);
	}
}

private function playListReverseButtonClicked(event:Event):void{
	var tempArrayCollection:ArrayCollection = new ArrayCollection();
	
	var newIndex:int = -1;
	if (dataGrid_playList != null)
	{
		var selectedIndex:int = dataGrid_playList.selectedIndex;
		if (selectedIndex != -1)
		{
			newIndex = (playListProvider.length-1) - selectedIndex;
		}
	}
	
	for each(var object:Object in playListProvider){
		tempArrayCollection.addItemAt(object, 0);
	}
	
	playListProvider = tempArrayCollection;
	
	if (dataGrid_playList != null && newIndex != -1)
	{
		dataGrid_playList.selectedIndex = newIndex;
	}
}

public function get playList():PlayList{
	var playList:PlayList = null;
	
	if(getPlayList().length > 0){
		
		playList = new PlayList();
		
		playList.name = playListName;
		
		for(var index:int = 0; index < (getPlayList() as Array).length; index++){
			var path:String = getPlayList()[index];
			var name:String = getNameList()[index];
			var nnddVideo:NNDDVideo = new NNDDVideo(path, name);
			
			playList.items.push(nnddVideo);
		}
	}
	
	return playList;
}