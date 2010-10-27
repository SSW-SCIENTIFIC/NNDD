// ActionScript file
import flash.events.Event;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;

import mx.core.Application;

public static const UPDATE_DIALOG_CLOSE:String = "UpdateDialogClose";

private function okButtonClicked(event:MouseEvent):void{
	dispatchEvent(new Event(UPDATE_DIALOG_CLOSE));
}

private function goToDownload():void{
	
	var urlRequest:URLRequest = new URLRequest("http://sourceforge.jp/projects/nndd/releases/");
	urlRequest.userAgent = "NNDD " + Application.application.version;
	
	navigateToURL(urlRequest);
	dispatchEvent(new Event(UPDATE_DIALOG_CLOSE));
}
