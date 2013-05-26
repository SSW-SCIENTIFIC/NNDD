/**
 * LoginDialog.as
 * 指定されたサイトへのログイン処理を行う。
 * 
 * Copyright (c) 2008 MAP - MineApplicationProject. All Rights Reserved.
 * 
 */
 
import flash.data.EncryptedLocalStore;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.utils.ByteArray;

import mx.controls.Alert;
import mx.controls.Button;
import mx.events.FlexEvent;

import org.mineap.nicovideo4as.Login;
import org.mineap.nndd.LogManager;
import org.mineap.nndd.Message;
import org.mineap.nndd.view.LoadingPicture;
import org.mineap.util.config.ConfigManager;

public static const ON_LOGIN_SUCCESS:String = "onFirestTimeLoginSuccess";
public static const LOGIN_FAIL:String = "LoginFail";
public static const NO_LOGIN:String = "noLogin";

public static var TOP_PAGE_URL:String;
public static var LOGIN_URL:String;

public static var LABEL_CANCEL:String = "キャンセル";
public static var LABEL_LOGIN:String = "ログイン";
public static var LABEL_NO_LOGIN:String = "ログインしない";

private var isStoreName:Boolean = false;
private var isStorePass:Boolean = false;
private var isAutoLogin:Boolean = false;
private var isLogout:Boolean = false;
private var logManager:LogManager= null;

//ログイン用URLローダー
private var _login:Login = null;

private var loading:LoadingPicture = new LoadingPicture();

private var userName:String = null;
private var password:String = null;


public function initLoginDialog(topURL:String, loginURL:String, logManager:LogManager, isLogout:Boolean = false):void
{
	TOP_PAGE_URL = topURL;
	LOGIN_URL = loginURL;
	loginButton.enabled = true;
	noLoginButton.enabled = true;
	
	this.logManager = logManager;
	this.isLogout = isLogout;
	
	textInput_userName.setFocus();
}

private function execAutoLogin():void
{
	if(isAutoLogin && !isLogout){
		
		if(userName != null && userName.length > 0 && password != null && password.length > 0){
			login();
		}
	}
}

private function enterHandler(event:FlexEvent):void {
	
	if(this.userName.length >= 1 && this.password.length >= 1){
		login();
	}
	
}

// ログインボタン押下字の処理
private function login():void 
{
	if(loginButton.label == LoginDialog.LABEL_LOGIN){
		noLoginButton.enabled = false;
		loginButton.label = LoginDialog.LABEL_CANCEL;
	    
		if(_login != null){
			_login.close();
		}
		
	    _login = new Login();
		_login.addEventListener(Login.LOGIN_SUCCESS, loginSuccess);
		_login.addEventListener(Login.LOGIN_FAIL, loginFail);
		_login.login(this.userName, this.password);
		
	}else if(loginButton.label == LoginDialog.LABEL_CANCEL){
		noLoginButton.enabled = true;
		if(_login != null){
			try{
				_login.close();
			}catch(error:Error){
				trace(error.getStackTrace());
			}
		}
		loginButton.label = LoginDialog.LABEL_LOGIN;
	}
}

private function notLogin():void
{
	saveStore();
	
	loginButton.enabled = false;
	noLoginButton.enabled = false;
	loginButton.label = LoginDialog.LABEL_LOGIN;
    dispatchEvent(new HTTPStatusEvent(NO_LOGIN));
}

private function saveStore():void{
	var bytes:ByteArray = new ByteArray();
	
	if(checkBox_storeUserName.selected){
		
		ConfigManager.getInstance().removeItem("userName");
		ConfigManager.getInstance().setItem("userName", this.userName);
		
		ConfigManager.getInstance().removeItem("storeName");
		ConfigManager.getInstance().setItem("storeName", true);
		
	}else{
		
		ConfigManager.getInstance().removeItem("userName");
		ConfigManager.getInstance().setItem("userName", "");
		
		ConfigManager.getInstance().removeItem("storeName");
		ConfigManager.getInstance().setItem("storeName", false);
		
	}
	
	if(checkBox_storePassword.selected)
	{
		savePassword(this.password);
		
		ConfigManager.getInstance().removeItem("storePass");
		ConfigManager.getInstance().setItem("storePass", true);
	}
	else
	{
		removePass();
		
		ConfigManager.getInstance().removeItem("storePass");
		ConfigManager.getInstance().setItem("storePass", false);
	}
	
	
	ConfigManager.getInstance().removeItem("isAutoLogin");
	ConfigManager.getInstance().setItem("isAutoLogin", checkbox_autoLogin.selected);
	
	try{
		ConfigManager.getInstance().save();
	}catch(error:Error){
		trace(error.getStackTrace());
		Alert.show(Message.M_CONF_FILE_CAN_NOT_SAVE + "\n\n" + error, Message.M_ERROR);
	}
}

private function loginFail(event:ErrorEvent):void
{
	this._login.close();
	
	if(event.text != Login.LOGIN_FAIL_MESSAGE){
		
		Alert.show("ログインに失敗しました。以下の原因が考えられます。\n" +
			"\t1.インターネットに接続されていない。\n" +
			"\t2.ニコニコ動画へのアクセスが制限されている。\n" +
			"\t3.ニコニコ動画のログインサーバーが応答しない。\n\n" +
			event.text, Message.M_ERROR);	
		logManager.addLog("ログイン失敗:ニコニコ動画にアクセスできない:" + event);
		
	}else{
		
		Alert.show("ログインできませんでした。\n" +
			"メールアドレス、もしくはパスワードが間違っています。\n" +
			event.text, Message.M_ERROR);
		logManager.addLog("ログイン失敗:メールアドレスもしくはパスワードの設定ミス:" + event);
	}
	
	loginButton.enabled = true;
	noLoginButton.enabled = true;
	loginButton.label = LoginDialog.LABEL_LOGIN;
	
	return;
}

private function removePass():void{
	
	var temp:Error = null;
	try{
		EncryptedLocalStore.removeItem("password");
	}catch(error:Error){
		trace(error.getStackTrace());
		temp = error;
	}
	
	if(temp != null){
		var message:String = Message.M_PASSWORD_CAN_NOT_SAVE + "\n" + temp;
		logManager.addLog(message);
		Alert.show(message, Message.M_ERROR);
	}
	
	EncryptedLocalStore.reset();
	
}

private function savePassword(pass:String):void{
	var bytes:ByteArray = new ByteArray();
	var temp:Error = null;
	try{
		EncryptedLocalStore.removeItem("password");
		bytes = new ByteArray();
		bytes.writeUTFBytes(pass);
		EncryptedLocalStore.setItem("password", bytes); 
	}catch(error:Error){
		trace(error.getStackTrace());
		temp = error;
	}
	
	if(temp != null){
		var message:String = Message.M_PASSWORD_CAN_NOT_SAVE + "\n" + temp;
		logManager.addLog(message);
		Alert.show(message, Message.M_ERROR);
	}
}

	
private function loginSuccess(event:Event):void 
{	
	this._login.close();
	
	trace(event);
	saveStore();
	logManager.addLog("ログイン成功:" + event);
    
    // イベントを送出
    dispatchEvent(new HTTPStatusEvent(ON_LOGIN_SUCCESS));
}

private function buttonKeyUp(event:KeyboardEvent):void{
	if(event.keyCode == Keyboard.ENTER){
		if((event.target as Button).label == LoginDialog.LABEL_CANCEL){
			this.login();
		}else if((event.target as Button).label == LoginDialog.LABEL_LOGIN){
			this.login();
		}else if((event.target as Button).label == LoginDialog.LABEL_NO_LOGIN){
			this.notLogin();
		}
	}	
}