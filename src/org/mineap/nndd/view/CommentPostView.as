/**
 * CommentPostView.as
 * 
 * Copyright (c) 2008-2009 MAP - MineApplicationProject. All Rights Reserved.
 *  
 * @author shiraminekeisuke
 * 
 */	
 
import org.mineap.nndd.player.PlayerController;

import mx.containers.Canvas;

private var playerController:PlayerController;
private var videoPlayer:VideoPlayer;
private var videoInfoView:VideoInfoView;

public function init(playerController:PlayerController, videoPlayer:VideoPlayer, videoInfoView:VideoInfoView):void{
	this.playerController = playerController;
	this.videoPlayer = videoPlayer;
	this.videoInfoView = videoInfoView;
}

public function postButtonClicked(event:Event):void{
//	(this.videoPlayer.canvas_video_back as Canvas).setFocus();
	if((textInput_comment.text as String).length != 0){
		this.playerController.postMessage(textInput_comment.text, textinput_command.text);
		textInput_comment.text = "";
//		textinput_command.text = "";
	}
}
