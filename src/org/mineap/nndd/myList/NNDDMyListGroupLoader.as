package org.mineap.nndd.myList
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	
	import org.mineap.nndd.LogManager;
	import org.mineap.nicovideo4as.Login;
	import org.mineap.nicovideo4as.analyzer.MyListGroupAnalyzer;
	import org.mineap.nicovideo4as.loader.MyListGroupLoader;
	
	[Event(name="success", type="NNDDMyListGroupLoader")]
	[Event(name="failure", type="NNDDMyListGroupLoader")]
	[Event(name="httpResponseStatus", type="HTTPStatusEvent")]
	
	/**
	 * 
	 * @author shiraminekeisuke(MineAP)
	 * 
	 */
	public class NNDDMyListGroupLoader extends EventDispatcher
	{
		
		public static const SUCCESS:String = "Success";
		public static const FAILURE:String = "Failure";
		
		private var _login:Login;
		
		private var _myListGroupLoader:MyListGroupLoader;
		
		private var _myListIds:Vector.<String> = new Vector.<String>();
		
		public function NNDDMyListGroupLoader()
		{
		}
		
		public function getMyListGroup(mailAddress:String, password:String):void{
			
			this._login = new Login();
			
			this._login.addEventListener(Login.LOGIN_SUCCESS, loginSuccessEventHandler);
			this._login.addEventListener(Login.LOGIN_FAIL, loginFailEventHandler);
			this._login.login(mailAddress, password);
			
		}
		
		private function loginSuccessEventHandler(event:Event):void{
			
			this._myListGroupLoader = new MyListGroupLoader();
			this._myListGroupLoader.addEventListener(Event.COMPLETE, myListGroupGetSuccessEventHandler);
			this._myListGroupLoader.addEventListener(IOErrorEvent.IO_ERROR, myListGroupGetFailEventHandler);
			this._myListGroupLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHanlder);
			this._myListGroupLoader.getMyListGroup();
			
		}
		
		private function loginFailEventHandler(event:ErrorEvent):void{
			removeHandler();
			close();
			LogManager.instance.addLog("\t\t" + Login.LOGIN_FAIL + ":" + event);
			trace(event);
			dispatchEvent(new ErrorEvent(FAILURE, false, false, event.text));
		}
		
		private function myListGroupGetSuccessEventHandler(event:Event):void{
			
			var myListGroupAnalyzer:MyListGroupAnalyzer = new MyListGroupAnalyzer();
			
			myListGroupAnalyzer.analyzer(String(this._myListGroupLoader.data));
			
			if(myListGroupAnalyzer.result == MyListGroupAnalyzer.OK){
				
				this._myListIds = myListGroupAnalyzer.myListIds;
				
				LogManager.instance.addLog("\t\t" + NNDDMyListGroupLoader.SUCCESS + ":" + event);
				trace(event);
				
				dispatchEvent(new Event(SUCCESS, false, false));
				
			}else{
				
				LogManager.instance.addLog("\t\t" + myListGroupAnalyzer.result + ":" + event);
				trace(myListGroupAnalyzer.result);
				
				dispatchEvent(new ErrorEvent(FAILURE, false, false, myListGroupAnalyzer.result));
				
			}
			
		}
		
		/**
		 * マイリストグループ取得に失敗した場合に呼ばれるリスナーです。
		 * @param event
		 * 
		 */
		private function myListGroupGetFailEventHandler(event:ErrorEvent):void{
			removeHandler();
			close();
			LogManager.instance.addLog("\t\t" + NNDDMyListGroupLoader.FAILURE + ":" + event);
			trace(event);
			dispatchEvent(new ErrorEvent(FAILURE, false, false, event.text));
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function httpResponseStatusEventHanlder(event:HTTPStatusEvent):void{
			LogManager.instance.addLog("\t\t" + HTTPStatusEvent.HTTP_RESPONSE_STATUS + ":" + event);
			trace(event);
			dispatchEvent(event);
		}
		
		/**
		 * 登録したリスナを取り除きます
		 * 
		 */
		private function removeHandler():void{
			
			if(this._login != null){
				this._login.removeEventListener(Login.LOGIN_SUCCESS, loginSuccessEventHandler);
				this._login.removeEventListener(Login.LOGIN_FAIL, loginFailEventHandler);
			}
			
			if(this._myListGroupLoader != null){
				this._myListGroupLoader.removeEventListener(Event.COMPLETE, myListGroupGetSuccessEventHandler);
				this._myListGroupLoader.removeEventListener(IOErrorEvent.IO_ERROR, myListGroupGetFailEventHandler);
				this._myListGroupLoader.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, httpResponseStatusEventHanlder);
			}
			
		}
		
		/**
		 * ニコニコ動画へのアクセスをクローズします。
		 * 
		 */
		public function close():void{
			
			removeHandler();
			
			if(this._login != null){
				try{
					this._login.close();
				}catch(error:Error){
					trace(error.getStackTrace());
				}
			}
			this._login = null;
			
			if(this._myListGroupLoader != null){
				try{
					this._myListGroupLoader.close();
				}catch(error:Error){
					trace(error.getStackTrace());
				}
			}
			this._myListGroupLoader = null;
			
		}
		
		/**
		 * マイリストの一覧を返します。<br />
		 * 取得に失敗した場合は空のVectorを返します。
		 * @return 
		 * 
		 */
		public function get myListIds():Vector.<String>{
			return this._myListIds;
		}
		
		
	}
}